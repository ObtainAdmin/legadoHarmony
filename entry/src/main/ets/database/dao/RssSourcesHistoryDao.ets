/**
 * @author 2008
 * @datetime 2024/7/20 16:34
 * @className: rssSourcesHistoryDao
 * 
 * RSS源历史记录数据访问对象 (RSS Sources History Data Access Object)
 * 
 * 功能说明：
 * 1. 提供对rss_sources_history表的完整CRUD操作
 * 2. 管理用户最近使用的RSS源历史记录
 * 3. 记录RSS源的使用时间和频率
 * 4. 支持历史记录的搜索、排序和清理
 * 
 * 核心功能：
 * - RSS源历史记录表初始化
 * - 历史记录的增删改查
 * - 最近使用时间跟踪
 * - 批量操作支持
 * 
 * 使用场景：
 * - 显示最近使用的RSS源
 * - RSS源使用历史管理
 * - 清理历史记录
 * - 搜索历史RSS源
 */
import DbUtil from '../../common/utils/DbUtil';
import { showMessage } from '../../componets/common/promptShow';
import AppDatabaseUtil from '../AppDatabaseUtil';
import { rssSourcesHistory } from '../entities/rssSourcesHistory';
import { ColumnInfo } from '../types/ColumnInfo';

/**
 * RSS源历史记录DAO类
 * 负责rss_sources_history表的所有数据库操作
 */
class RssSourcesHistoryDao {
  /**
   * 表名常量
   * @type {string}
   */
  TABLE_NAME: string = 'rss_sources_history'

  /**
   * 初始化RSS源历史记录表
   * @returns {Promise<void>}
   * @description 
   * 1. 获取表的创建SQL语句
   * 2. 创建数据表
   * 3. 检查并补全缺失字段
   */
  async initRssSourcesHistoryTable() {
    try {
      const createSql = AppDatabaseUtil.getCreateSql(this.TABLE_NAME);
      if (!createSql) {
        return
      }
      await DbUtil.createTable(createSql)
      AppDatabaseUtil.existsTable(this.TABLE_NAME)
      return
    } catch (err) {
      console.info('TagInfo', JSON.stringify(err))
    }
  }

  /**
   * 查询RSS源历史记录
   * @param {string} [sourceUrl] - 源URL搜索关键词（可选）
   * @returns {Promise<rssSourcesHistory[]>} RSS源历史记录列表
   * @description 
   * 查询条件：
   * 1. 按源URL模糊搜索（如果提供sourceUrl参数）
   * 排序规则：
   * 1. 按最后更新时间降序（lastUpdateTime DESC）
   */
  async search(sourceUrl?:string) {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      let sql = `SELECT * FROM ${this.TABLE_NAME}`;
      // 动态添加 WHERE 子句
      let whereClause: string[] = [];
      if (sourceUrl) {
        whereClause.push(`(
        sourceUrl LIKE '%${sourceUrl}%'
      )`);

      }
      // 如果有 where 子句，添加 WHERE 关键字
      if (whereClause.length > 0) {
        sql += ` WHERE ${whereClause.join(' AND ')}`;
      }
      sql += `
  ORDER BY
    lastUpdateTime DESC
`;
      const rssSourcesDbList = await DbUtil.querySqlForList<rssSourcesHistory>(sql, column);
      console.log("TagInfo", '书源数量：' + rssSourcesDbList.length)
      return rssSourcesDbList
    } catch (err) {
      console.log("TagInfo", JSON.stringify(err))
      return []
    }
  }

  /**
   * 批量插入RSS源历史记录
   * @param {rssSourcesHistory[]} history - RSS源历史记录数组
   * @returns {Promise<boolean>} 操作是否成功
   * @description 遍历数组并逐个插入历史记录
   */
  async batchInsert(history: rssSourcesHistory[]) {
    try {
      for (let index = 0; index < history.length; index++) {
        const rssHistory = history[index];
        await this.insert(rssHistory)
      }
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 插入RSS源历史记录
   * @param {rssSourcesHistory} rssHistory - RSS源历史记录对象
   * @returns {Promise<boolean>} 插入是否成功
   * @description 
   * 1. 检查记录是否已存在（通过sourceUrl）
   * 2. 如果存在则执行更新操作
   * 3. 设置最后更新时间戳
   * 4. 插入新记录
   */
  async insert(rssHistory: rssSourcesHistory) {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('sourceUrl', rssHistory.sourceUrl)
      const count = await DbUtil.queryForCount(predicates, column)
      if (count > 0) {
        this.update(rssHistory)
        return true
      }
      rssHistory.lastUpdateTime = Date.now()
      await DbUtil.insert(this.TABLE_NAME, rssHistory, column)
      console.log('TagInfo', '创建成功')
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 更新RSS源历史记录
   * @param {rssSourcesHistory} rssHistory - RSS源历史记录对象
   * @returns {Promise<boolean>} 更新是否成功
   * @description 
   * 1. 检查记录是否存在
   * 2. 如果不存在则执行插入操作
   * 3. 更新最后更新时间戳
   * 4. 设置显示最近图标为true
   * 5. 执行更新操作
   */
  async update(rssHistory: rssSourcesHistory) {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('sourceUrl', rssHistory.sourceUrl)
      const count = await DbUtil.queryForCount(predicates, column)
      if (count === 0 && rssHistory instanceof rssSourcesHistory) {
        this.insert(rssHistory)
        return true
      }
      rssHistory.lastUpdateTime = Date.now()
      rssHistory.showRecentIcon = true
      await DbUtil.update(predicates, rssHistory, column)
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }

  }

  /**
   * 批量删除订阅源历史记录
   * @param {rssSourcesHistory[]} rssHistory - RSS源历史记录数组
   * @returns {Promise<boolean>} 删除是否成功
   * @description 
   * 1. 遍历数组并逐个删除历史记录
   * 2. 显示成功消息提示
   */
  async deleteRssSourcesHistoryList(rssHistory: rssSourcesHistory[]) {
    try {
      for (let index = 0; index < rssHistory.length; index++) {
        await this.deleteRssSourcesHistory(rssHistory[index].sourceUrl)
      }
      showMessage('清除最近使用')
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 删除单个订阅源历史记录
   * @param {string} rssHistoryUrl - RSS源URL
   * @returns {Promise<boolean>} 删除是否成功
   * @description 根据源URL删除指定的历史记录
   */
  async deleteRssSourcesHistory(rssHistoryUrl: string) {
    try {
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('sourceUrl', rssHistoryUrl)
      await DbUtil.delete(predicates)
      return true
    }  catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }
}

// 创建单例实例并导出
const rssSourcesHistoryDao = new RssSourcesHistoryDao()
export default rssSourcesHistoryDao as RssSourcesHistoryDao

/**
 * @author 2008
 * @datetime 2024/8/05 22:34
 * @className: BookHistoryDao
 * 
 * 书籍浏览历史数据访问对象 (Book History Data Access Object)
 * 
 * 功能说明：
 * 1. 提供对book_history表的完整CRUD操作
 * 2. 管理用户阅读历史记录
 * 3. 记录书籍的阅读进度和时间
 * 4. 支持历史记录的查询和清理
 * 
 * 核心功能：
 * - 阅读历史表初始化
 * - 历史记录的增删改查
 * - 阅读进度跟踪
 * - 历史记录排序和过滤
 * 
 * 使用场景：
 * - 继续阅读功能
 * - 阅读历史查看
 * - 阅读进度同步
 * - 历史记录管理
 */
import DbUtil from '../../common/utils/DbUtil';
import AppDatabaseUtil from '../AppDatabaseUtil';
import { BookHistory } from '../entities/BookHistory';
import { rssSourcesHistory } from '../entities/rssSourcesHistory';
import { BookHistoryTypeParams } from '../types/BookHistoryType';
import { ColumnInfo } from '../types/ColumnInfo';

/**
 * 书籍历史记录DAO类
 * 负责book_history表的所有数据库操作
 */
class BookHistoryDao {
  /**
   * 表名常量
   * @type {string}
   */
  TABLE_NAME: string = 'book_history'

  /**
   * 初始化书籍历史记录表
   * @returns {Promise<void>}
   * @description 
   * 1. 获取表的创建SQL语句
   * 2. 创建数据表
   * 3. 检查并补全缺失字段
   */
  async initBookHistoryTable() {
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
   * 查询书籍历史记录
   * @param {BookHistoryTypeParams} [params] - 查询参数
   * @returns {Promise<BookHistory[]>} 历史记录列表
   * @description 
   * 查询条件：
   * 1. 按书籍类型过滤（type参数）
   * 2. 默认包含系统类型（bookType = 123）
   * 排序规则：
   * 1. 按sort参数选择排序字段（0: durChapterTime, 其他: updateTime）
   * 2. 默认按最近阅读时间降序（durChapterTime DESC）
   */
  async search(params?:BookHistoryTypeParams) {
    const type = params?.type
    const sort = params?.sort
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      let sql = `SELECT * FROM ${this.TABLE_NAME}`;
      // 动态添加 WHERE 子句
      let whereClause: string[] = [];
      if (type !== undefined){
        whereClause.push(`bookType = ${type} OR bookType = 123`);
      }
      // 如果有 where 子句，添加 WHERE 关键字
      if (whereClause.length > 0) {
        sql += ` WHERE ${whereClause.join(' AND ')}`;
      }
      sql += ` ORDER BY`;
      if (sort !== undefined) {
        sql += ` ${sort === 0 ? 'durChapterTime' : 'updateTime'} DESC`
      } else {
        sql += ` durChapterTime DESC`;
      }
      const bookHistoryDbList = await DbUtil.querySqlForList<BookHistory>(sql, column);

      return bookHistoryDbList
    } catch (err) {
      console.log("TagInfo", JSON.stringify(err))
      return []
    }
  }
  
  /**
   * 查询最新的书籍历史记录
   * @returns {Promise<BookHistory[]>} 最新的历史记录（最多1条）
   * @description 
   * 查询最近阅读的书籍记录
   * 排序规则：按最近阅读时间降序，限制返回1条记录
   */
  async searchLimit() {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      let sql = `SELECT * FROM ${this.TABLE_NAME}`;
      // 动态添加 WHERE 子句
      let whereClause: string[] = [];

      // 如果有 where 子句，添加 WHERE 关键字
      if (whereClause.length > 0) {
        sql += ` WHERE ${whereClause.join(' AND ')}`;
      }
      sql += `
  ORDER BY
     durChapterTime DESC
     LIMIT 1
`;
      const bookHistoryDbList = await DbUtil.querySqlForList<BookHistory>(sql, column);
      return bookHistoryDbList
    } catch (err) {
      console.log("TagInfo", JSON.stringify(err))
      return []
    }
  }

  /**
   * 插入书籍历史记录
   * @param {BookHistory} bookHistory - 书籍历史记录对象
   * @returns {Promise<boolean>} 插入是否成功
   * @description 
   * 1. 检查记录是否已存在（通过ID）
   * 2. 如果存在则执行更新操作
   * 3. 设置创建时间戳
   * 4. 插入新记录
   */
  async insert(bookHistory: BookHistory) {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('id', bookHistory.id)
      const count = await DbUtil.queryForCount(predicates, column)
      if (count > 0) {
        this.update(bookHistory)
        return true
      }
      bookHistory.createTime = Date.now()
      await DbUtil.insert(this.TABLE_NAME, bookHistory, column)
      console.log('TagInfo', '创建成功')
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 更新书籍历史记录
   * @param {BookHistory} bookHistory - 书籍历史记录对象
   * @returns {Promise<boolean>} 更新是否成功
   * @description 
   * 1. 检查记录是否存在
   * 2. 如果不存在则执行插入操作
   * 3. 更新更新时间戳和最近阅读时间
   * 4. 执行更新操作
   */
  async update(bookHistory: BookHistory) {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('id', bookHistory.id)
      const count = await DbUtil.queryForCount(predicates, column)
      if (count === 0 && bookHistory instanceof BookHistory) {
        this.insert(bookHistory)
        return true
      }
      bookHistory.updateTime = Date.now()
      bookHistory.durChapterTime = Date.now()
      await DbUtil.update(predicates, bookHistory, column)
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 删除指定的阅读历史记录
   * @param {number} id - 历史记录ID
   * @returns {Promise<boolean>} 删除是否成功
   * @description 根据ID删除单条阅读历史记录
   */
  async deleteBookHistory(id: number) {
    try {
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('id', id)
      await DbUtil.delete(predicates)
      return true
    }  catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 删除所有阅读历史记录
   * @returns {Promise<boolean>} 删除是否成功
   * @description 清空整个阅读历史记录表
   */
  async deleteAllBookHistory() {
    try {
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      await DbUtil.delete(predicates)
      return true
    }  catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

}

// 创建单例实例并导出
const bookHistoryDao = new BookHistoryDao()
export default bookHistoryDao as BookHistoryDao

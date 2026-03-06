/**
 * RSS源分组数据访问对象 (RSS Source Group Data Access Object)
 * 
 * 功能说明：
 * 1. 提供对rss_source_group表的完整CRUD操作
 * 2. 管理RSS源的分组信息
 * 3. 支持RSS源分组的创建、查询、更新、删除
 * 4. 初始化默认的RSS源分组数据
 * 
 * 核心功能：
 * - RSS源分组表初始化
 * - 分组数据的增删改查
 * - 默认分组数据初始化
 * - 分组排序和置顶管理
 * 
 * 使用场景：
 * - RSS源分组管理
 * - RSS源分类展示
 * - 分组设置和配置
 */
import { ColumnInfo } from '../types/ColumnInfo';
import AppDatabaseUtil from '../AppDatabaseUtil'
import { JSON } from '@kit.ArkTS';
import DbUtil from '../../common/utils/DbUtil';
import { RssSourceGroup } from '../entities/RssSourceGroup';

/**
 * RSS源分组DAO类
 * 负责rss_source_group表的所有数据库操作
 */
class RssSourceGroupDao {
  /**
   * 表名常量
   * @type {string}
   */
  TABLE_NAME: string = 'rss_source_group'

  /**
   * 初始化RSS源分组表
   * @returns {Promise<void>}
   * @description 
   * 1. 获取表的创建SQL语句
   * 2. 创建数据表
   * 3. 检查并补全缺失字段
   * 4. 初始化默认分组数据
   */
  async initBookSourceGroupTable() {
    try {
      const createSql = AppDatabaseUtil.getCreateSql(this.TABLE_NAME);
      if (!createSql) {
        return
      }
      await DbUtil.createTable(createSql);
      await AppDatabaseUtil.existsTable(this.TABLE_NAME)
      this.initGroupData()
      return
    } catch (err) {
      console.info('TagInfo', JSON.stringify(err))
    }
  }

  /**
   * 查询所有RSS源分组
   * @returns {Promise<RssSourceGroup[]>} RSS源分组列表
   * @description 查询rss_source_group表中的所有记录
   */
  async search(){
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      let sql = `SELECT * FROM ${this.TABLE_NAME}`;
      // sql += `ORDER BY isTop DESC, groupSort ASC`;
      const groupDbList = await DbUtil.querySqlForList<RssSourceGroup>(sql, column);
      console.log("TagInfo", '书籍：' + groupDbList.length)
      return groupDbList
    } catch (err) {
      console.log("TagInfo", JSON.stringify(err))
      return []
    }
  }

  /**
   * 初始化系统默认的RSS源分组数据
   * @returns {Promise<void>}
   * @description 
   * 创建默认的RSS源分组：
   * 1. 小说
   * 2. 漫画
   * 3. 影视
   * 4. 资讯
   * 5. 收藏夹
   * 
   * 注意：只有在表为空时才会初始化
   */
  async initGroupData() {
    let initGroup = ['小说','漫画','影视','资讯','收藏夹']
    try {
      const groupList = await this.search()
      if (groupList.length > 0) {
        return
      }
      for (let index = 0; index < initGroup.length; index++) {
        let group = new RssSourceGroup()
        // group.rssGroupId = index
        group.rssGroupName = initGroup[index]
        group.groupSort = index
        group.isTop = false
        group.isDelete = false
        await this.insert(group)
      }
    }catch (e){
      console.log('TagInfo, Error, ', JSON.stringify(e))
    }
  }

  /**
   * 插入RSS源分组
   * @param {RssSourceGroup} rssGroup - RSS源分组对象
   * @returns {Promise<boolean>} 插入是否成功
   * @description 
   * 1. 检查分组是否已存在（通过rssGroupId）
   * 2. 如果存在则执行更新操作
   * 3. 插入新分组记录
   */
  async insert(rssGroup: RssSourceGroup) {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      if (rssGroup.rssGroupId) {
        const predicates = DbUtil.getPredicates(this.TABLE_NAME);
        predicates.equalTo('rssGroupId', rssGroup.rssGroupId)
        const count = await DbUtil.queryForCount(predicates, column)
        if (count > 0) {
          this.update(rssGroup)
          return true
        }
      }
      await DbUtil.insert(this.TABLE_NAME, rssGroup, column)
      console.log('TagInfo', '创建成功')
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 更新RSS源分组
   * @param {RssSourceGroup} rssGroup - RSS源分组对象
   * @returns {Promise<boolean>} 更新是否成功
   * @description 
   * 1. 检查分组是否存在
   * 2. 如果不存在则执行插入操作
   * 3. 更新分组信息
   */
  async update(rssGroup: RssSourceGroup) {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('rssGroupId', rssGroup.rssGroupId)
      const count = await DbUtil.queryForCount(predicates, column)
      if (count === 0 && rssGroup instanceof RssSourceGroup) {
        this.insert(rssGroup)
        return true
      }

      await DbUtil.update(predicates, rssGroup, column)
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

}

// 创建单例实例并导出
const rssSourceGroupDao = new RssSourceGroupDao()

export default rssSourceGroupDao as RssSourceGroupDao

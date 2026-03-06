/**
 * 数据库模块入口文件 (Database Module Entry)
 * 
 * 功能说明：
 * 1. 集中导入所有DAO（数据访问对象）类
 * 2. 提供统一的数据库初始化接口
 * 3. 作为数据库模块的对外统一出口
 * 
 * 模块结构：
 * - 导入所有DAO类：BookGroupsDao, BookHistoryDao, BooksDao等
 * - 提供DataBase类管理所有表的初始化
 * - 导出单例实例供其他模块使用
 * 
 * 使用场景：
 * - 应用启动时初始化所有数据库表
 * - 数据库模块重构时统一管理入口
 * - 其他模块需要访问数据库功能时从此导入
 */
import BookGroupsDao from './dao/BookGroupsDao'
import bookHistoryDao from './dao/BookHistoryDao'
import BooksDao from './dao/BooksDao'
import BookSourceDao from './dao/BookSourceDao'
import rssSourceGroupDao from './dao/rssSourceGroupDao'
import rssSourcesHistoryDao from './dao/RssSourcesHistoryDao'
import SubscriptionDao from './dao/SubscriptionDao'
import worksListsDao from './dao/WorksListsDao'

/**
 * 数据库管理类 (Database Manager)
 * 
 * 职责：
 * 1. 统一管理所有数据库表的初始化
 * 2. 协调各个DAO类的初始化顺序
 * 3. 提供简洁的初始化接口
 */
class DataBase {
  /**
   * 初始化所有数据库表
   * @returns {Promise<void>}
   * @description 
   * 按顺序初始化所有数据表，确保表之间的依赖关系正确：
   * 1. 书源表 (BookSource)
   * 2. RSS源历史表 (RssSourcesHistory)
   * 3. 订阅表 (Subscription)
   * 4. 书籍表 (Books)
   * 5. 书籍分组表 (BookGroups)
   * 6. 作品列表表 (WorksLists)
   * 7. 阅读历史表 (BookHistory)
   * 8. RSS源分组表 (RssSourceGroup)
   * 
   * 注意：初始化顺序可能影响外键约束，请勿随意更改
   */
  async initAllTable() {
    await BookSourceDao.initBookSourceTable()
    await rssSourcesHistoryDao.initRssSourcesHistoryTable()
    await SubscriptionDao.initSubscriptionTable()
    await BooksDao.initBooksTable()
    await BookGroupsDao.initGroupTable()
    await worksListsDao.initWorksListsTable()
    await bookHistoryDao.initBookHistoryTable()
    await rssSourceGroupDao.initBookSourceGroupTable()
  }
}

// 创建单例实例
const dataBase = new DataBase()

// 导出单例实例，确保整个应用使用同一个数据库管理实例
export default dataBase as DataBase

import { ColumnInfo, ColumnType } from '../types/ColumnInfo';
import { BookSource, BookSourceDb, ToBookSource, ToBookSourceDb, ToBookSourcePart } from '../entities/BookSource';
import AppDatabaseUtil from '../AppDatabaseUtil' // 数据库表结构工具类
import { JSON } from '@kit.ArkTS'; // ArkTS JSON工具
import DbUtil from '../../common/utils/DbUtil'; // 数据库通用操作工具类
import { BookSourcePart } from '../entities/BookSourcePart'; // 书籍源部分字段实体类
import { BookSourceSearchParams } from '../types/BookSourceType'; // 书籍源搜索参数类型

/**
 * 书籍源数据访问对象（DAO）
 * 负责book_sources表的所有CRUD（创建、读取、更新、删除）操作
 * 封装与书籍源相关的数据库交互逻辑，对外提供统一的操作接口
 */
class BookSourceDao {
  // 数据库表名 - 书籍源表
  TABLE_NAME: string = 'book_sources'

  /**
   * 初始化书籍源数据表
   * 创建book_sources表（如果不存在）
   * @returns {Promise<void>} 无返回值
   */
  async initBookSourceTable() {
    try {
      // 获取创建表的SQL语句
      const createSql = AppDatabaseUtil.getCreateSql(this.TABLE_NAME);
      // 如果没有获取到创建SQL，直接返回
      if (!createSql) {
        return
      }
      // 执行创建表操作
      await DbUtil.createTable(createSql);
      // 标记表已存在（内部逻辑）
      AppDatabaseUtil.existsTable(this.TABLE_NAME)
      return
    } catch (err) {
      // 捕获并打印创建表过程中的异常
      console.info('TagInfo', JSON.stringify(err))
    }
  }

  /**
   * 获取流式查询的列信息配置
   * 用于flowAll和flowSearch方法的字段映射
   * @returns {ColumnInfo[]} 列信息数组
   */
  getFlowColumn() {
    // 获取基础列信息（从表结构配置中读取）
    const column: ColumnInfo[] = AppDatabaseUtil.getAssignColumn(this.TABLE_NAME,
      ['bookSourceUrl', 'bookSourceName', 'bookSourceGroup', 'bookSourceGrade', 'bookSourceScore', 'customOrder',
        'enabled', 'enabledExplore', 'lastUpdateTime', 'respondTime', 'weight', 'isTop', 'showRecentIcon',
        'showExplore']);
    // 追加计算列（hasLoginUrl、hasExploreUrl）的列信息
    column.push(...[
      {
        name: 'hasLoginUrl',
        columnName: 'hasLoginUrl',
        type: ColumnType.BOOLEAN
      },
      {
        name: 'hasExploreUrl',
        columnName: 'hasExploreUrl',
        type: ColumnType.BOOLEAN
      }
    ] as ColumnInfo[])
    return column;
  }

  /**
   * 查询所有书籍源的部分字段（轻量级查询）
   * 仅返回常用字段，减少数据传输和解析开销
   * @returns {Promise<BookSourcePart[]>} 书籍源部分字段列表
   */
  async flowAll(): Promise<BookSourcePart[]> {
    try {
      // 构建查询SQL，包含计算列（trim(loginUrl) <> '' 判断是否有登录URL）
      const sql = `select bookSourceUrl, bookSourceName, bookSourceGroup, bookSourceGrade, bookSourceScore, customOrder, enabled, enabledExplore,
      trim(loginUrl) <> '' hasLoginUrl, lastUpdateTime, respondTime, weight, trim(exploreUrl) <> '' hasExploreUrl, isTop, showRecentIcon, showExplore
      from book_sources order by customOrder asc`
      // 获取列信息配置
      const column: ColumnInfo[] = this.getFlowColumn()
      // 执行SQL查询并映射为BookSourcePart对象列表
      return await DbUtil.querySqlForList<BookSourcePart>(sql, column)
    } catch (err) {
      // 异常处理：打印错误并返回空列表
      console.log("TagInfo", JSON.stringify(err))
      return []
    }
  }

  /**
   * 获取启用状态且启用探索功能的书籍源（按自定义顺序排序）
   * @returns {Promise<BookSource[]>} 符合条件的完整书籍源列表
   */
  async getEnabledPartByGroup() {
    try {
      // 获取表的所有列信息
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      // 构建查询SQL：筛选enabled=1且enabledExplore=1的记录
      const sql = `SELECT * FROM book_sources WHERE enabled = 1 AND enabledExplore = 1 ORDER BY customOrder ASC`
      // 执行查询获取数据库实体列表
      const bookSourceDbList = await DbUtil.querySqlForList<BookSourceDb>(sql, column);
      // 转换为业务层BookSource对象
      const bookSourceList = bookSourceDbList.map((item): BookSource => ToBookSource(item));
      return bookSourceList
    } catch (e) {
      console.log("TagInfo", JSON.stringify(e))
      return []
    }
  }

  /**
   * 带条件的轻量级书籍源查询（仅返回部分字段）
   * @param {BookSourceSearchParams} [searchParams] 搜索参数
   * @returns {Promise<BookSourcePart[]>} 符合条件的书籍源部分字段列表
   */
  async flowSearch(searchParams?: BookSourceSearchParams): Promise<BookSourcePart[]> {
    // 解构搜索参数，设置默认值
    const searchKey = searchParams?.searchKey ?? '';
    const type = searchParams?.type;
    const enabled = searchParams?.enabled;
    const bookSourceGrade = searchParams?.bookSourceGrade;
    const hasLoginUrl = searchParams?.hasLoginUrl;
    const showExplore = searchParams?.showExplore;
    const order = searchParams?.order;

    try {
      // 基础查询SQL（仅查询部分字段）
      let sql = `
  SELECT
    bookSourceUrl,
    bookSourceName,
    bookSourceGroup,
    bookSourceGrade,
    bookSourceScore,
    customOrder,
    enabled,
    enabledExplore,
    trim(loginUrl) <> '' AS hasLoginUrl,
    lastUpdateTime,
    respondTime,
    weight,
    trim(exploreUrl) <> '' AS hasExploreUrl,
    isTop,
    showRecentIcon,
    showExplore
  FROM
    book_sources
`;

      // 动态构建WHERE条件子句
      let whereClause: string[] = [];
      // 按类型筛选
      if (type !== undefined) {
        whereClause.push(`bookSourceType = ${type}`);
      }
      // 按启用状态筛选
      if (enabled !== undefined) {
        whereClause.push(`enabled = ${enabled ? 1 : 0}`);
      }
      // 按是否显示探索筛选
      if (showExplore !== undefined) {
        whereClause.push(`showExplore = ${showExplore ? 1 : 0}`);
      }
      // 按书籍源等级筛选
      if (bookSourceGrade !== undefined) {
        whereClause.push(`bookSourceGrade = ${bookSourceGrade}`);
      }
      // 按是否有登录URL筛选（COALESCE处理NULL值）
      if (hasLoginUrl !== undefined) {
        whereClause.push(`COALESCE(loginUrl, '') ${hasLoginUrl ? '<>' : '='} ''`);
      }
      // 按关键词模糊搜索（名称、分组、URL、备注）
      if (searchKey) {
        whereClause.push(`(
    bookSourceName LIKE '%${searchKey}%'
    OR bookSourceGroup LIKE '%${searchKey}%'
    OR bookSourceUrl LIKE '%${searchKey}%'
    OR bookSourceComment LIKE '%${searchKey}%'
  )`);
      }

      // 如果有筛选条件，拼接WHERE子句
      if (whereClause.length > 0) {
        sql += ` WHERE ${whereClause.join(' AND ')}`;
      }

      // 构建排序子句
      sql += ` ORDER BY`;
      if (order !== undefined) {
        // 自定义排序：0按分组降序，其他按最后更新时间降序
        sql += ` ${order === 0 ? 'bookSourceGroup' : 'lastUpdateTime'} DESC`
      } else {
        // 默认排序：是否置顶降序 -> 自定义顺序升序
        sql += ` isTop DESC, customOrder ASC`;
      }

      // 执行查询并返回结果
      const column: ColumnInfo[] = this.getFlowColumn()
      return await DbUtil.querySqlForList<BookSourcePart>(sql, column)
    } catch (err) {
      console.log("TagInfo", JSON.stringify(err))
      return []
    }
  }

  /**
   * 带条件的完整书籍源查询（返回所有字段）
   * 主查询方法，用于业务层获取完整的书籍源信息
   * @param {BookSourceSearchParams} [searchParams] 搜索参数
   * @returns {Promise<BookSource[]>} 符合条件的完整书籍源列表
   */
  async search(searchParams?: BookSourceSearchParams) {
    // 解构搜索参数，设置默认值
    const searchKey = searchParams?.searchKey ?? '';
    const type = searchParams?.type;
    const enabled = searchParams?.enabled;
    const hasExploreUrl = searchParams?.hasExploreUrl;
    const showExplore = searchParams?.showExplore;

    try {
      // 获取表的所有列信息
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      // 基础查询SQL（查询所有字段）
      let sql = `SELECT * FROM book_sources`;

      // 动态构建WHERE条件子句
      let whereClause: string[] = [];
      // 按类型筛选
      if (type !== undefined) {
        whereClause.push(`bookSourceType = ${type}`);
      }
      // 按启用状态筛选
      if (enabled !== undefined) {
        whereClause.push(`enabled = ${enabled ? 1 : 0}`);
      }
      // 按是否有探索URL筛选
      if (hasExploreUrl !== undefined) {
        whereClause.push(`COALESCE(exploreUrl, '') ${hasExploreUrl ? '<>' : '='} ''`);
      }
      // 按是否显示探索筛选
      if (showExplore !== undefined) {
        whereClause.push(`showExplore = ${showExplore ? 1 : 0}`);
      }
      // 按关键词模糊搜索
      if (searchKey) {
        whereClause.push(`(
    bookSourceName LIKE '%${searchKey}%'
    OR bookSourceGroup LIKE '%${searchKey}%'
    OR bookSourceUrl LIKE '%${searchKey}%'
    OR bookSourceComment LIKE '%${searchKey}%'
  )`);
      }

      // 拼接WHERE子句
      if (whereClause.length > 0) {
        sql += ` WHERE ${whereClause.join(' AND ')}`;
      }

      // 排序：是否置顶降序 -> 自定义顺序升序
      sql += `
  ORDER BY
    isTop DESC, customOrder ASC
`;

      // 执行查询并转换为业务对象
      const bookSourceDbList = await DbUtil.querySqlForList<BookSourceDb>(sql, column);
      const bookSourceList = bookSourceDbList.map((item): BookSource => ToBookSource(item));
      console.log("TagInfo",bookSourceList.toString())
      // 打印查询结果数量（调试用）
      console.log("TagInfo", '书源数量：' + bookSourceList.length)
      return bookSourceList
    } catch (err) {
      console.log("TagInfo", JSON.stringify(err))
      return []
    }
  }

  /**
   * 根据书籍源URL获取单个完整书籍源信息
   * @param {string} key 书籍源URL（唯一标识）
   * @returns {Promise<BookSource | null>} 书籍源对象（不存在则返回null）
   */
  async getBookSource(key: string): Promise<BookSource | null> {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      // 构建查询条件：bookSourceUrl等于指定值
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('bookSourceUrl', key)

      // 执行查询
      const bookSourceDbList = await DbUtil.queryForList<BookSourceDb>(predicates, column);
      const bookSourceList = bookSourceDbList.map((item): BookSource => ToBookSource(item));

      // 处理查询结果
      if (bookSourceList.length > 0) {
        // 如果需要显示最近图标，更新图标状态
        if (bookSourceList[0].showRecentIcon) {
          this.updateRecentIcon(ToBookSourcePart(bookSourceList[0]))
        }
        return bookSourceList[0]
      }
      return null
    } catch (err) {
      console.log("TagInfo", JSON.stringify(err))
      return null
    }
  }

  /**
   * 插入/更新单个书籍源（存在则更新，不存在则插入）
   * @param {BookSource} bookSource 书籍源对象
   * @returns {Promise<boolean>} 操作是否成功
   */
  async insert(bookSource: BookSource) {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      // 检查是否已存在该书籍源（通过URL）
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('bookSourceUrl', bookSource.bookSourceUrl)
      const count = await DbUtil.queryForCount(predicates, column)

      // 存在则更新，不存在则插入
      if (count !== 0) {
        this.update(bookSource)
        return true
      }

      // 转换为数据库实体并设置最后更新时间
      const bookSourceDb = ToBookSourceDb(bookSource)
      bookSourceDb.lastUpdateTime = Date.now()
      // 执行插入操作
      await DbUtil.insert(this.TABLE_NAME, bookSourceDb, column)
      console.log('TagInfo', '创建成功')
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 批量插入/更新书籍源
   * @param {BookSource[]} bookSources 书籍源对象数组
   * @returns {Promise<boolean>} 操作是否成功
   */
  async batchInsert(bookSources: BookSource[]) {
    try {
      // 遍历执行单个插入操作
      for (let index = 0; index < bookSources.length; index++) {
        const bookSource = bookSources[index];
        await this.insert(bookSource)
      }
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 更新书籍源的部分字段（轻量级更新）
   * @param {BookSourcePart} bookSource 书籍源部分字段对象
   * @returns {Promise<boolean>} 操作是否成功
   */
  async updateFlow(bookSource: BookSourcePart) {
    try {
      // 构建更新条件：按URL匹配
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('bookSourceUrl', bookSource.bookSourceUrl)
      // 更新最后更新时间
      bookSource.lastUpdateTime = Date.now()
      // 获取部分列信息（排除最后两个计算列）
      const columnPart: ColumnInfo[] = this.getFlowColumn().slice(0, -2)
      // 执行更新操作
      await DbUtil.update(predicates, bookSource, columnPart)
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 更新完整的书籍源信息（不存在则插入）
   * @param {BookSource} bookSource 书籍源对象
   * @returns {Promise<boolean>} 操作是否成功
   */
  async update(bookSource: BookSource) {
    try {
      const column: ColumnInfo[] = AppDatabaseUtil.getColumn(this.TABLE_NAME);
      // 检查是否存在该书籍源
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('bookSourceUrl', bookSource.bookSourceUrl)
      const count = await DbUtil.queryForCount(predicates, column)

      // 不存在则插入
      if (count === 0) {
        this.insert(bookSource)
        return true
      }

      // 转换为数据库实体并更新最后更新时间
      const bookSourceDb = ToBookSourceDb(bookSource)
      bookSourceDb.lastUpdateTime = Date.now()
      // 执行更新操作
      await DbUtil.update(predicates, bookSourceDb, column)
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 批量更新书籍源的部分字段
   * @param {BookSourcePart[]} bookSources 书籍源部分字段对象数组
   * @returns {Promise<boolean>} 操作是否成功
   */
  async batchUpdateFlow(bookSources: BookSourcePart[]) {
    try {
      // 遍历执行单个部分更新操作
      for (let index = 0; index < bookSources.length; index++) {
        const bookSource = bookSources[index];
        await this.updateFlow(bookSource)
      }
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 更新书籍源的最近图标显示状态（设置为不显示）
   * @param {BookSourcePart} bookSources 书籍源部分字段对象
   * @returns {Promise<boolean>} 操作是否成功
   */
  async updateRecentIcon(bookSources: BookSourcePart) {
    try {
      // 设置为不显示最近图标
      bookSources.showRecentIcon = false
      // 执行部分更新
      this.updateFlow(bookSources)
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 根据URL删除单个书籍源
   * @param {string} key 书籍源URL（唯一标识）
   * @returns {Promise<boolean>} 操作是否成功
   */
  async delete(key: string) {
    try {
      // 构建删除条件
      const predicates = DbUtil.getPredicates(this.TABLE_NAME);
      predicates.equalTo('bookSourceUrl', key)
      // 执行删除操作
      await DbUtil.delete(predicates);
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }

  /**
   * 批量删除书籍源
   * @param {string[]} keys 书籍源URL数组
   * @returns {Promise<boolean>} 操作是否成功
   */
  async batchDelete(keys: string[]) {
    try {
      // 遍历执行单个删除操作
      for (let index = 0; index < keys.length; index++) {
        const key = keys[index];
        await this.delete(key)
      }
      return true
    } catch (err) {
      console.log('TagInfo, Error, ', JSON.stringify(err))
      return false
    }
  }
}

// 创建DAO单例实例
const bookSourceDao = new BookSourceDao()

// 导出单例对象
export default bookSourceDao as BookSourceDao
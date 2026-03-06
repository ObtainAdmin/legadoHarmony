/**
 * 数据库工具类 (App Database Utility)
 * 
 * 功能说明：
 * 1. 提供数据库表结构的操作工具方法
 * 2. 处理数据库表的字段检测和动态添加
 * 3. 转换数据库字段信息为统一的列信息格式
 * 4. 支持获取表的创建SQL语句
 * 
 * 核心功能：
 * - 表结构验证和字段补全
 * - 字段信息查询和转换
 * - 动态表结构维护
 * 
 * 使用场景：
 * - 数据库迁移和升级
 * - 表结构验证
 * - 动态字段管理
 * - 数据库调试和维护
 */
import { FieldsType } from './types/AppDatabaseType'
import { ColumnInfo, ColumnValue, ColumnType } from './types/ColumnInfo'
import AppDatabase from './AppDatabase'
import DbUtil from '../common/utils/DbUtil'

class AppDatabaseUtil {
  /**
   * 获取表的创建SQL语句
   * @param {string} tableName - 表名
   * @returns {string | undefined} 创建表的SQL语句，如果表不存在则返回undefined
   * @description 从数据库实体配置中获取指定表的创建SQL，并替换表名占位符
   */
  getCreateSql(tableName: string) {
    const entities = AppDatabase.database.entities
    const tableInfo = entities.find(item => item.tableName === tableName)
    return tableInfo?.createSql.replace('${TABLE_NAME}', tableName)
  }

  /**
   * 获取表的字段定义
   * @param {string} tableName - 表名
   * @returns {FieldsType[] | undefined} 字段定义数组，如果表不存在则返回undefined
   * @description 查询指定表的所有字段定义信息
   */
  getFields(tableName: string): FieldsType[] | undefined {
    const entities = AppDatabase.database.entities
    const tableInfo = entities.find(item => item.tableName === tableName)
    return tableInfo?.fields
  }

  /**
   * 检测表中的字段是否缺失，若是缺失则新增
   * @param {string} tableName - 表名
   * @returns {Promise<void>}
   * @description 
   * 1. 查询表中现有的所有列名
   * 2. 对比实体定义中的字段列表
   * 3. 如果发现缺失字段，自动执行ALTER TABLE语句添加
   * 4. 支持字段的默认值设置
   * 
   * 使用场景：数据库升级时动态添加新字段
   */
  async existsTable(tableName: string) {
    try {
      const rowNames = await DbUtil.queryRowNames(tableName);
      const fields = this.getFields(tableName)
      if (!fields?.length) return
      for (let index = 0; index < fields.length; index++) {
        const element = fields[index];
        if (!rowNames.includes(element.columnName)) {
          console.info(`TagInfo 数据表【${tableName}】缺失字段，开始新增字段：`, element.columnName)
          let executeSql =  `ALTER TABLE '${tableName}' ADD COLUMN '${element.columnName}' ${element.affinity}`
          if (element.defaultValue) {
            executeSql += ` DEFAULT '${element.defaultValue}'`
          }
          await DbUtil.executeSql(executeSql)
          console.info('TagInfo', `数据表【${tableName}】新增字段【${element.columnName}】成功`)
        }
      }
    } catch (e) {
      console.info('TagInfo Error:', JSON.stringify(e))
    }
  }

  /**
   * 获取表的列信息
   * @param {string} tableName - 表名
   * @returns {ColumnInfo[]} 列信息数组
   * @description 将表的字段定义转换为统一的ColumnInfo格式
   */
  getColumn(tableName: string) {
    const entities = AppDatabase.database.entities
    const tableInfo = entities.find(item => item.tableName === tableName)
    return this.fieldsToColumnInfo(tableInfo?.fields || [])
  }

  /**
   * 获取指定的列信息
   * @param {string} tableName - 表名
   * @param {string[]} assignColumn - 指定的列名数组
   * @returns {ColumnInfo[]} 过滤后的列信息数组
   * @description 从表的列信息中筛选出指定的列
   */
  getAssignColumn(tableName: string, assignColumn: string[]) {
    const columns = this.getColumn(tableName)
    return columns.filter(item => assignColumn.includes(item.columnName))
  }

  /**
   * 将字段定义转换为列信息
   * @param {FieldsType[]} fields - 字段定义数组
   * @returns {ColumnInfo[]} 列信息数组
   * @description 
   * 转换规则：
   * 1. 字段路径 -> name属性
   * 2. 数据库列名 -> columnName属性
   * 3. 布尔类型特殊处理，其他类型通过affinity映射
   * 4. 保留默认值设置
   */
  fieldsToColumnInfo(fields: FieldsType[]): ColumnInfo[] {
    return fields.map(item => {
      const columnInfo: ColumnInfo = {
        name: item.fieldPath,
        // 数据库列名
        columnName: item.columnName,
        // 列类型
        type: item.boolean ? ColumnType.BOOLEAN : ColumnValue[item.affinity],
        defaultValue: item.defaultValue
      }
      return columnInfo
    })
  }
}

// 创建单例实例并导出
const appDatabaseUtil = new AppDatabaseUtil();
export default appDatabaseUtil as AppDatabaseUtil;

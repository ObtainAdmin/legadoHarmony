/**
 * 数据库工具类 - 封装HarmonyOS关系型数据库操作的工具类
 * 
 * Copyright (C), 2024-06-24
 * @author LinXun
 * @date 2024-06-24 11:47
 * @version 1.0
 * 
 * 功能：封装HarmonyOS的relationalStore API，提供统一的数据库操作接口
 * 核心特性：
 *   1. 数据库管理：初始化、删除数据库
 *   2. 表操作：创建表、查询表结构
 *   3. 数据操作：增删改查（CRUD）操作
 *   4. 类型安全：支持TypeScript泛型，确保数据类型安全
 *   5. 错误处理：统一的错误日志记录
 * 使用场景：应用数据持久化、书籍信息存储、用户数据管理等
 */
import { relationalStore, ValuesBucket, ValueType } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import CommonConstants from '../constants/CommonConstants';
import Logger from './Logger';
import { ColumnInfo, ColumnType } from '../../database/types/ColumnInfo';

class DbUtil {
  /**
   * 数据库实例
   * 功能：relationalStore.RdbStore对象，用于执行所有数据库操作
   * 注意：使用懒加载，通过initDB方法初始化
   */
  rdbStore: relationalStore.RdbStore | undefined = undefined;
  /**
   * 初始化数据库
   * 功能：初始化关系型数据库连接，获取RdbStore实例
   * @param context - UIAbility上下文，用于获取数据库存储路径
   * 返回值：Promise<void> - 初始化成功或失败的Promise
   * 使用场景：应用启动时初始化数据库连接
   * 处理流程：
   *   1. 调用relationalStore.getRdbStore获取数据库实例
   *   2. 将实例保存到this.rdbStore属性
   *   3. 记录初始化成功日志
   *   4. 如果失败，记录错误日志并拒绝Promise
   * 注意：此方法必须在其他数据库操作之前调用
   */
  initDB(context: common.UIAbilityContext): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      relationalStore.getRdbStore(context, CommonConstants.STORE_CONFIG)
        .then(rdbStore => {
          this.rdbStore = rdbStore;
          Logger.debug(`[${CommonConstants.RDB_TAG}]`, 'rdbStore 初始化成功');
          resolve();
        })
        .catch((reason: string) => {
          Logger.error(`[${CommonConstants.RDB_TAG}]`, 'rdbStore 初始化失败', JSON.stringify(reason));
          reject(reason);
        })
    });
  }

  /**
   * 创建RdbPredicates对象
   * 功能：创建用于数据库查询的条件对象
   * @param tableName - 表名
   * 返回值：relationalStore.RdbPredicates - 查询条件对象
   * 使用场景：构建数据库查询条件，用于query、delete、update等操作
   * 说明：RdbPredicates是HarmonyOS关系型数据库的查询条件构建器
   */
  getPredicates (tableName: string): relationalStore.RdbPredicates {
    return new relationalStore.RdbPredicates(tableName);
  }

  /**
   * 删除数据库
   * 功能：删除整个数据库文件
   * @param context - UIAbility上下文
   * 返回值：Promise<void> - 删除成功或失败的Promise
   * 使用场景：清除用户数据、重置应用状态
   * 处理流程：
   *   1. 检查数据库实例是否存在
   *   2. 调用relationalStore.deleteRdbStore删除数据库文件
   *   3. 清空this.rdbStore引用
   *   4. 记录删除成功日志
   * 注意：删除操作不可逆，会永久删除所有数据
   */
  deleteDB(context: common.UIAbilityContext): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      if (this.rdbStore === undefined) {
        resolve();
      }
      relationalStore.deleteRdbStore(context, CommonConstants.STORE_CONFIG, (error) => {
        if (error) {
          Logger.error(`[${CommonConstants.RDB_TAG}]`, 'rdbStore 删除失败', JSON.stringify(error));
          reject(error);
        }
        this.rdbStore = undefined;
        resolve();
      })
    });
  }

  /**
   * 创建表
   * 功能：执行SQL语句创建数据库表
   * @param createSQL - 创建表的SQL语句
   * 返回值：Promise<void> - 创建成功或失败的Promise
   * 使用场景：初始化数据库表结构
   * 处理流程：调用executeSql方法执行创建表语句
   * 示例：CREATE TABLE books (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)
   */
  createTable(createSQL: string): Promise<void> {
    return this.executeSql(createSQL);
  }

  /**
   * 执行任意SQL语句
   * 功能：执行任意SQL语句，支持DDL和DML操作
   * @param executeSql - 要执行的SQL语句
   * 返回值：Promise<void> - 执行成功或失败的Promise
   * 使用场景：执行复杂的SQL操作，如创建索引、修改表结构等
   * 处理流程：
   *   1. 调用rdbStore.executeSql执行SQL语句
   *   2. 记录执行成功日志
   *   3. 如果失败，记录错误日志并拒绝Promise
   * 注意：此方法可以执行任何SQL语句，包括危险操作，使用时需谨慎
   */
  executeSql(executeSql: string): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      this.rdbStore?.executeSql(executeSql)
        .then(() => {
          console.info('TagInfo', '执行成功');
          Logger.debug(`[${CommonConstants.RDB_TAG}]`,'执行成功');
          resolve();
        })
        .catch((reason: string) => {
          console.info('TagInfo Error:', reason);
          Logger.error(`[${CommonConstants.RDB_TAG}]`,'执行失败', JSON.stringify(reason));
          reject(reason);
        })
    });
  }

  /**
   * 获取数据表的所有列名
   * 功能：查询指定表的结构信息，获取所有列名
   * @param tableName - 表名
   * 返回值：Promise<string[]> - 列名数组
   * 使用场景：动态获取表结构，用于反射或动态查询
   * 处理流程：
   *   1. 执行PRAGMA table_info查询表结构
   *   2. 遍历结果集，提取每行的name字段
   *   3. 返回列名数组
   * SQL说明：PRAGMA table_info是SQLite特有的命令，用于查询表结构
   */
  queryRowNames(tableName: string): Promise<string[]> {
    return new Promise<string[]>((resolve, reject) => {
      this.rdbStore?.querySql(`PRAGMA  table_info(${tableName})`)
        .then((result) => {
          let rowNames: string[] = [];
          if (result.rowCount <= 0) {
            Logger.debug('无结果');
            resolve(rowNames);
          }
          while (!result.isAtLastRow) {
            result.goToNextRow();
            const row = result.getRow();
            rowNames.push(row.name as string);
          }
          Logger.debug(`[${CommonConstants.RDB_TAG}]`,'执行成功');
          resolve(rowNames);
        })
        .catch((reason: string) => {
          Logger.error(`[${CommonConstants.RDB_TAG}]`,'执行失败', JSON.stringify(reason));
          reject(reason);
        })
    });
  }

  /**
   * 插入数据
   * 功能：向指定表中插入一条数据
   * @param tableName - 表名
   * @param obj - 要插入的数据对象
   * @param columns - 列信息数组，定义对象属性与表列的映射关系
   * 返回值：Promise<number> - 插入行的ID
   * 使用场景：新增数据记录
   * 处理流程：
   *   1. 调用buildValueBucket构建ValuesBucket
   *   2. 调用rdbStore.insert插入数据
   *   3. 返回插入行的自增ID
   * 注意：obj对象的属性名应与columns中定义的name属性对应
   */
  insert(tableName: string, obj: object, columns: ColumnInfo[]): Promise<number> {
    return new Promise((resolve,
}
// 导出
let dbUtil: DbUtil = new DbUtil();
export default dbUtil as DbUtil;

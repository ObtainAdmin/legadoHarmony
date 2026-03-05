/**
 * 数据库工具类 - 封装HarmonyOS关系型数据库操作的通用工具类
 * 
 * @author LinXun
 * @date 2024-06-24 11:47
 * @version 1.0
 * 
 * 功能：提供统一的数据库操作接口，简化关系型数据库的使用
 * 核心特性：
 *   1. 数据库连接管理：初始化、删除数据库连接
 *   2. 表结构操作：创建表、获取表结构信息
 *   3. 数据CRUD操作：插入、查询、更新、删除数据
 *   4. 类型安全：支持泛型查询，自动类型转换
 *   5. 错误处理：统一的错误日志记录
 * 使用场景：应用数据持久化存储，支持多种数据类型
 * 
 * 技术栈：HarmonyOS relationalStore API
 * 数据库类型：SQLite
 */
import { relationalStore, ValuesBucket, ValueType } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import CommonConstants from '../constants/CommonConstants';
import Logger from './Logger';
import { ColumnInfo, ColumnType } from '../../database/types/ColumnInfo';

class DbUtil {
  /**
   * 数据库实例
   * 功能：存储当前数据库连接实例，所有操作都基于此实例
   * 类型：relationalStore.RdbStore | undefined
   * 生命周期：从initDB初始化到deleteDB销毁
   */
  rdbStore: relationalStore.RdbStore | undefined = undefined;
  
  /**
   * 初始化数据库连接
   * 功能：创建或打开数据库连接，建立与SQLite数据库的通信
   * @param context - 应用上下文，提供数据库存储路径等环境信息
   * 返回值：Promise<void> - 初始化成功或失败的Promise
   * 使用场景：应用启动时初始化数据库连接
   * 处理流程：
   *   1. 调用relationalStore.getRdbStore获取数据库实例
   *   2. 使用CommonConstants.STORE_CONFIG配置（数据库名、安全级别等）
   *   3. 将实例保存到this.rdbStore供后续操作使用
   *   4. 记录初始化成功日志
   * 错误处理：初始化失败时记录错误日志并reject
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
        });
    });
  }

  /**
   * 创建查询条件对象
   * 功能：创建RdbPredicates对象，用于构建数据库查询条件
   * @param tableName - 表名，指定要查询的数据表
   * 返回值：relationalStore.RdbPredicates - 查询条件对象
   * 使用场景：构建查询、更新、删除操作的条件
   * 功能扩展：返回的RdbPredicates对象支持链式调用，可添加各种查询条件
   *   例如：predicates.equalTo("name", "张三").and().greaterThan("age", 18)
   * 注意：此方法仅创建条件对象，不执行实际查询
   */
  getPredicates(tableName: string): relationalStore.RdbPredicates {
    return new relationalStore.RdbPredicates(tableName);
  }
  
  /**
   * 删除数据库
   * 功能：删除整个数据库文件，清理所有数据
   * @param context - 应用上下文，用于定位数据库文件路径
   * 返回值：Promise<void> - 删除成功或失败的Promise
   * 使用场景：用户清除应用数据、数据库重置、应用卸载前清理
   * 处理流程：
   *   1. 检查当前是否有数据库连接实例
   *   2. 调用relationalStore.deleteRdbStore删除数据库文件
   *   3. 清理this.rdbStore引用
   *   4. 记录删除成功日志
   * 注意：此操作不可逆，会永久删除所有数据
   * 安全考虑：删除前应提示用户确认
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
      });
    });
  }
  
  /**
   * 创建数据表
   * 功能：执行CREATE TABLE语句创建新表
   * @param createSQL - CREATE TABLE SQL语句，定义表结构和约束
   * 返回值：Promise<void> - 创建成功或失败的Promise
   * 使用场景：应用首次安装、数据库升级时创建新表
   * 处理流程：内部调用executeSql方法执行SQL语句
   * SQL示例：CREATE TABLE IF NOT EXISTS books (id INTEGER PRIMARY KEY, name TEXT, author TEXT)
   * 注意：表已存在时不会重复创建（通常使用IF NOT EXISTS）
   * 错误处理：SQL语法错误或权限问题会导致创建失败
   */
  createTable(createSQL: string): Promise<void> {
    return this.executeSql(createSQL);
  }
  
  /**
   * 执行任意SQL语句
   * 功能：执行自定义SQL语句，支持DDL和DML操作
   * @param executeSql - 要执行的SQL语句字符串
   * 返回值：Promise<void> - 执行成功或失败的Promise
   * 使用场景：执行复杂SQL操作、批量操作、数据库维护
   * 支持的操作类型：
   *   - DDL：CREATE, ALTER, DROP
   *   - DML：INSERT, UPDATE, DELETE
   *   - 查询：SELECT（但建议使用query方法）
   * 注意：直接执行SQL存在SQL注入风险，应谨慎使用
   * 安全建议：对于用户输入，应使用参数化查询或验证输入
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
          console.info('TagInfo Error:', reason)
          Logger.error(`[${CommonConstants.RDB_TAG}]`,'执行失败', JSON.stringify(reason));
          reject(reason);
        })
    });
  }
  /**
   * 获取数据表的所有列名
   * 功能：查询指定表的元数据信息，获取所有列名
   * @param tableName - 表名，要查询的表名称
   * 返回值：Promise<string[]> - 列名数组，如果表不存在或没有列则返回空数组
   * 使用场景：动态获取表结构、数据迁移、ORM映射
   * 处理流程：
   *   1. 执行SQLite的PRAGMA table_info命令获取表信息
   *   2. 遍历结果集，提取每一行的name字段（列名）
   *   3. 返回列名数组
   * SQLite PRAGMA说明：table_info命令返回表的列信息，包括cid、name、type、notnull、dflt_value、pk
   * 注意：此方法依赖于SQLite特定语法，不适用于其他数据库
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
          Logger.debug(`[${CommonConstants.RDB_TAG}]`, '执行成功');
          resolve(rowNames);
        })
        .catch((reason: string) => {
          Logger.error(`[${CommonConstants.RDB_TAG}]`, '执行失败', JSON.stringify(reason));
          reject(reason);
        });
    });
  }
  
  /**
   * 插入数据
   * 功能：向指定表中插入一条新记录
   * @param tableName - 表名，要插入数据的目标表
   * @param obj - 要插入的数据对象，键值对形式
   * @param columns - 列信息数组，定义列名、类型和映射关系
   * 返回值：Promise<number> - 插入记录的主键ID
   * 使用场景：新增数据记录，如添加新书籍、用户等
   * 处理流程：
   *   1. 使用buildValueBucket方法将对象转换为ValuesBucket
   *   2. 调用rdbStore.insert方法插入数据
   *   3. 返回自动生成的主键ID
   * 注意：obj对象的属性名应与columns中定义的name字段对应
   * 主键生成：如果表有自增主键，返回新记录的ID；否则返回0
   */
  insert(tableName: string, obj: object, columns: ColumnInfo[]): Promise<number> {
    return new Promise((resolve, reject) => {
      // 1.构建新增数据
      let value = this.buildValueBucket(obj, columns);
      // 2.新增
      this.rdbStore?.insert(tableName, value, (err, id) => {
        if (err) {
          Logger.error(`[${CommonConstants.RDB_TAG}]`, '新增失败！', JSON.stringify(err));
          reject(err);
        } else {
          Logger.debug(`[${CommonConstants.RDB_TAG}]`, '新增成功！新增id：', id.toString());
          resolve(id);
        }
      });
    });
  }
  
  /**
   * 删除数据
   * 功能：根据条件删除表中的记录
   * @param predicates - 查询条件对象，定义删除条件
   * 返回值：Promise<number> - 删除的记录行数
   * 使用场景：删除满足条件的记录，如删除用户、清理过期数据
   * 处理流程：
   *   1. 调用rdbStore.delete方法执行删除
   *   2. 返回实际删除的行数
   * 条件构建：使用getPredicates方法创建条件对象，可添加各种条件
   * 安全注意：删除操作不可逆，应谨慎使用，建议先查询确认
   */
  delete(predicates: relationalStore.RdbPredicates): Promise<number> {
    return new Promise((resolve, reject) => {
      this.rdbStore?.delete(predicates, (err, rows) => {
        if (err) {
          Logger.error(`[${CommonConstants.RDB_TAG}]`, '删除失败!,', JSON.stringify(err));
          reject(err);
        } else {
          Logger.debug(`[${CommonConstants.RDB_TAG}]`, '删除成功！删除行数：', rows.toString());
          resolve(rows);
        }
      });
    });
  }
  
  /**
   * 执行SQL查询并返回列表（泛型）
   * 功能：执行自定义SQL查询语句，返回指定类型的对象列表
   * @param sql - 完整的SQL查询语句
   * @param columns - 列信息数组，用于结果集解析和类型转换
   * 返回值：Promise<T[]> - 查询结果的对象数组
   * 使用场景：复杂查询、多表关联查询、聚合查询等
   * 处理流程：
   *   1. 执行SQL查询
   *   2. 使用parseResultSet方法解析结果集
   *   3. 关闭结果集释放资源
   * 类型安全：使用泛型T确保返回类型与预期一致
   * 注意：SQL注入风险，应避免拼接用户输入的SQL
   */
  querySqlForList<T>(sql: string, columns: ColumnInfo[]): Promise<T[]> {
    return new Promise((resolve, reject) => {
      this.rdbStore?.querySql(sql, (err, result) => {
        if (err) {
          Logger.error(`[${CommonConstants.RDB_TAG}]`, '查询失败!', JSON.stringify(err));
          reject(err);
        } else {
          Logger.debug(`[${CommonConstants.RDB_TAG}]`, '查询成功！查询行数：', result.rowCount.toString());
          resolve(this.parseResultSet(result, columns));
          result.close();
        }
      });
    });
  }
  
  /**
   * 条件查询返回列表（泛型）
   * 功能：根据条件对象查询数据，返回指定类型的对象列表
   * @param predicates - 查询条件对象
   * @param columns - 列信息数组，用于结果集解析和类型转换
   * 返回值：Promise<T[]> - 查询结果的对象数组
   * 使用场景：条件查询、分页查询、排序查询
   * 处理流程：
   *   1. 将列名数组传递给query方法
   *   2. 执行条件查询
   *   3. 使用parseResultSet方法解析结果集
   *   4. 关闭结果集释放资源
   * 与querySqlForList的区别：此方法使用条件对象而非SQL，更安全
   * 性能优化：只查询需要的列，避免SELECT *
   */
  queryForList<T>(predicates: relationalStore.RdbPredicates, columns: ColumnInfo[]): Promise<T[]> {
    return new Promise((resolve, reject) => {
      this.rdbStore?.query(predicates, columns.map(info => info.columnName), (err, result) => {
        if (err) {
          Logger.error(`[${CommonConstants.RDB_TAG}]`, '查询失败!', JSON.stringify(err));
          reject(err);
        } else {
          Logger.debug(`[${CommonConstants.RDB_TAG}]`, '查询成功！查询行数：', result.rowCount.toString());
          resolve(this.parseResultSet(result, columns));
          result.close();
        }
      });
    });
  }
  
  /**
   * 查询数据记录数
   * 功能：根据条件查询满足条件的记录数量
   * @param predicates - 查询条件对象
   * @param columns - 列信息数组（此参数实际未使用，为兼容性保留）
   * 返回值：Promise<number> - 满足条件的记录数量
   * 使用场景：分页查询时获取总记录数、统计数量
   * 处理流程：
   *   1. 执行条件查询
   *   2. 返回结果集的行数（rowCount）
   * 性能考虑：此方法比查询全部数据再计数更高效
   * 注意：columns参数在此方法中未使用，但为保持接口一致性而保留
   */
  queryForCount(predicates: relationalStore.RdbPredicates, columns: ColumnInfo[]): Promise<number> {
    return new Promise((resolve, reject) => {
      this.rdbStore?.query(predicates, columns.map(info => info.columnName), (err, result) => {
        if (err) {
          Logger.error(`[${CommonConstants.RDB_TAG}]`, '查询失败!', JSON.stringify(err));
          reject(err);
        } else {
          Logger.debug(`[${CommonConstants.RDB_TAG}]`, '查询成功！查询行数：', result.rowCount.toString());
          resolve(result.rowCount);
        }
      });
    });
  }
  
  /**
   * 更新数据
   * 功能：根据条件更新表中的记录
   * @param predicates - 查询条件对象，定义更新条件
   * @param obj - 要更新的数据对象，包含新值
   * @param columns - 列信息数组，定义列名、类型和映射关系
   * 返回值：Promise<number> - 更新的记录行数
   * 使用场景：修改数据记录，如更新用户信息、书籍状态等
   * 处理流程：
   *   1. 使用buildValueBucket方法将对象转换为ValuesBucket
   *   2. 调用rdbStore.update方法执行更新
   *   3. 返回实际更新的行数
   * 注意：更新0行表示没有满足条件的记录，不一定表示错误
   * 条件构建：可使用equalTo、greaterThan等方法构建精确条件
   */
  update(predicates: relationalStore.RdbPredicates, obj: object, columns: ColumnInfo[]): Promise<number> {
    return new Promise((resolve, reject) => {
      // 1.构建更新数据
      let value = this.buildValueBucket(obj, columns);
      // 2.更新
      this.rdbStore?.update(value, predicates, (err, result) => {
        if (err) {
          Logger.error(`[${CommonConstants.RDB_TAG}]`, '更新失败！', JSON.stringify(err));
          reject(err);
        } else {
          Logger.debug(`[${CommonConstants.RDB_TAG}]`, '更新成功！更新行数：', result.toString());
          resolve(result);
        }
      });
    });
  }
  
  /**
   * 解析结果集（核心方法）
   * 功能：将ResultSet结果集解析为指定类型的对象数组
   * @param result - 数据库查询结果集
   * @param columns - 列信息数组，定义列名、类型和映射关系
   * 返回值：T[] - 解析后的对象数组
   * 使用场景：所有查询方法的结果集解析
   * 处理流程：
   *   1. 初始化空数组
   *   2. 检查结果集是否有数据
   *   3. 遍历结果集的每一行
   *   4. 根据列类型调用相应的get方法获取值
   *   5. 构建对象并添加到数组
   * 类型转换：
   *   - LONG: 使用getLong获取整数值
   *   - DOUBLE: 使用getDouble获取浮点值
   *   - STRING: 使用getString获取字符串值
   *   - BLOB: 使用getBlob获取二进制数据
   *   - BOOLEAN: 使用getLong获取整数值后转换为布尔值
   * 空值处理：空字符串转换为undefined
   */
  parseResultSet<T>(result: relationalStore.ResultSet, columns: ColumnInfo[]): T[] {
    // 1.声明最终返回的结果
    let arr: T[] = [];
    // 2.判断是否有结果
    if (result.rowCount <= 0) {
      Logger.debug('无结果');
      return arr;
    }
    // 3.处理结果
    while (!result.isAtLastRow) {
      // 3.1 去下一行
      result.goToNextRow();
      // 3.2 解析这行数据，转为对象
      let obj: ValuesBucket | Record<string, undefined> = {};
      columns.forEach(info => {
        let val: ValueType | Uint8Array | undefined = undefined;
        switch (info.type) {
          case ColumnType.LONG:
            val = result.getLong(result.getColumnIndex(info.columnName));
            break;
          case ColumnType.DOUBLE:
            val = result.getDouble(result.getColumnIndex(info.columnName));
            break;
          case ColumnType.STRING:
            val = result.getString(result.getColumnIndex(info.columnName));
            break;
          case ColumnType.BLOB:
            val = result.getBlob(result.getColumnIndex(info.columnName));
            break;
          case ColumnType.BOOLEAN:
            val = !!result.getLong(result.getColumnIndex(info.columnName));
            break;
        }
        obj[info.name] = val === '' ? undefined : val;
      });
      // 3.3 将对象填入结果数组
      arr.push(obj as T);
    }
    return arr;
  }
  
  /**
   * 构建值集（辅助方法）
   * 功能：将对象转换为数据库操作所需的ValuesBucket格式
   * @param obj - 源数据对象，包含要操作的数据
   * @param columns - 列信息数组，定义列名、类型和映射关系
   * 返回值：ValuesBucket - 数据库操作所需的值集
   * 使用场景：插入和更新操作前的数据转换
   * 处理流程：
   *   1. 初始化空ValuesBucket
   *   2. 遍历列信息数组
   *   3. 检查对象中是否存在对应属性
   *   4. 如果存在，将值添加到ValuesBucket中
   * 映射关系：使用columnName作为数据库列名，obj[info.name]作为值
   * 注意：只包含有值的属性，undefined属性会被跳过
   */
  buildValueBucket(obj: object, columns: ColumnInfo[]): ValuesBucket {
    let value: ValuesBucket = {};
    columns.forEach(info => {
      if (typeof obj[info.name] !== 'undefined') {
        value[info.columnName] = obj[info.columnName];
      }
    });
    return value;
  }
}
// 导出
let dbUtil: DbUtil = new DbUtil();
export default dbUtil as DbUtil;

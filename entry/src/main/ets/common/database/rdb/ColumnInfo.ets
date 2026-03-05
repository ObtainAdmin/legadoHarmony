/**
 * 数据库列信息接口和枚举定义文件
 * 
 * Copyright (C), 2024-06-22
 * @author LinXun
 * @date 2024-06-22 10:08
 * @version 1.0
 * 
 * 功能：定义数据库列的相关信息，包括列名、类型等，用于ORM映射和数据库操作
 * 包含：
 *   1. ColumnInfo接口 - 数据库列信息接口
 *   2. ColumnType枚举 - 数据库列数据类型枚举
 * 使用场景：在关系型数据库操作中，描述表结构的列信息
 */

/**
 * 数据库列信息接口
 * 功能：描述数据库表中列的基本信息，用于实体属性与数据库列的映射
 * 使用场景：
 *   - ORM（对象关系映射）框架中实体类与数据库表的映射
 *   - 动态SQL生成时获取列信息
 *   - 数据库迁移时描述表结构
 */
export interface ColumnInfo {
  /**
   * 实体属性名
   * 功能：在TypeScript/JavaScript对象中使用的属性名称
   * 使用场景：代码中访问实体对象的属性
   * 示例：对于用户实体，可能是"userName"、"age"等
   */
  name: string
  
  /**
   * 数据库列名
   * 功能：在数据库表中实际的列名称
   * 使用场景：SQL查询、数据库操作
   * 示例：对于用户表，可能是"user_name"、"user_age"等
   * 注意：通常使用蛇形命名法（snake_case），与代码中的驼峰命名法对应
   */
  columnName: string
  
  /**
   * 列数据类型
   * 功能：指定数据库列的数据类型
   * 使用场景：创建表时定义列类型，查询时类型转换
   * 类型：ColumnType枚举值
   */
  type: ColumnType
}

/**
 * 数据库列数据类型枚举
 * 功能：定义数据库支持的数据类型，对应SQLite/HarmonyOS RDB的数据类型
 * 使用场景：创建表时指定列类型，查询时进行类型安全检查
 * 对应关系：
 *   - TypeScript类型 ↔ ColumnType枚举 ↔ 数据库类型
 */
export enum ColumnType {
  /**
   * 长整型
   * 功能：表示64位整数类型
   * 对应数据库类型：INTEGER
   * 对应TypeScript类型：number
   * 使用场景：ID、时间戳、大数字等
   */
  LONG,
  
  /**
   * 双精度浮点型
   * 功能：表示64位浮点数类型
   * 对应数据库类型：REAL
   * 对应TypeScript类型：number
   * 使用场景：价格、百分比、科学计算等
   */
  DOUBLE,
  
  /**
   * 字符串类型
   * 功能：表示文本字符串类型
   * 对应数据库类型：TEXT
   * 对应TypeScript类型：string
   * 使用场景：姓名、地址、描述等文本内容
   */
  STRING,
  
  /**
   * 二进制大对象类型
   * 功能：表示二进制数据类型
   * 对应数据库类型：BLOB
   * 对应TypeScript类型：Uint8Array或ArrayBuffer
   * 使用场景：图片、文件、序列化对象等二进制数据
   */
  BLOB,
  
  /**
   * 布尔类型
   * 功能：表示真/假值类型
   * 对应数据库类型：INTEGER（0或1）
   * 对应TypeScript类型：boolean
   * 使用场景：状态标志、开关选项等
   */
  BOOLEAN
}

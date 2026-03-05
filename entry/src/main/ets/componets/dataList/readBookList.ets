

/**
 * @file readBookList.ets
 * @description 阅读书籍列表数据模型类
 * 
 * 功能概述：
 * 1. 定义阅读书籍列表项的数据结构
 * 2. 提供阅读统计信息的完整字段定义
 * 3. 包含构造函数和默认值设置
 * 4. 用于阅读记录、阅读统计列表展示的数据模型
 * 
 * 使用场景：
 * - 阅读记录列表数据模型
 * - 阅读统计列表数据模型
 * - 最近阅读书籍列表
 * - 需要显示阅读进度和统计信息的场景
 * 
 * 数据字段说明：
 * 1. 书籍信息：
 *   - bookName: 书籍名称
 *   - coverImage: 封面图片资源字符串
 *   - author: 作者名称
 * 
 * 2. 阅读统计：
 *   - readingDuration: 阅读时长数组
 *   - dateTime: 当前阅读时间
 *   - schedule: 阅读进度（百分比）
 *   - bookmark: 书签位置
 *   - readFrequency: 读完次数
 * 
 * 3. 状态信息：
 *   - status: 选中状态
 * 
 * 设计特点：
 * - 使用TypeScript类定义数据模型
 * - 提供详细的字段注释
 * - 构造函数支持默认值
 * - 合理的默认值设置
 * 
 * 默认值策略：
 * - readFrequency: 默认0次
 * - status: 默认false（未选中）
 */

/**
 * @class readBookList
 * @description 阅读书籍列表数据模型类
 * 
 * 类职责：
 * 1. 定义阅读书籍列表项的数据结构
 * 2. 提供构造函数初始化数据
 * 3. 管理阅读统计信息的各个字段
 * 
 * 字段说明：
 */
export class readBookList{
  /** 
   * @property bookName - 书籍名称
   * @description 书籍的名称或标题
   * @type {string}
   */
  bookName:string
  
  /** 
   * @property coverImage - 封面图片
   * @description 书籍的封面图片资源字符串
   * @type {ResourceStr}
   */
  coverImage:ResourceStr
  
  /** 
   * @property author - 作者名称
   * @description 书籍的作者姓名
   * @type {string}
   */
  author:string
  
  /** 
   * @property readingDuration - 阅读时长
   * @description 阅读时长数组，可能包含多个时间段的阅读时长
   * 示例：[120, 90, 180] 表示三个阅读时段，单位可能是分钟
   * @type {number[]}
   */
  readingDuration:number[]
  
  /** 
   * @property dateTime - 当前阅读时间
   * @description 当前阅读的时间戳，记录最后一次阅读的时间
   * @type {Date}
   */
  dateTime:Date
  
  /** 
   * @property schedule - 阅读进度
   * @description 书籍的阅读进度，通常以百分比表示
   * 示例：75 表示已阅读75%
   * @type {number}
   */
  schedule:number
  
  /** 
   * @property bookmark - 书签位置
   * @description 书签的位置，可能是章节编号或页码
   * @type {number}
   */
  bookmark:number
  
  /** 
   * @property readFrequency - 读完次数
   * @description 书籍被完整阅读的次数
   * @type {number}
   */
  readFrequency:number
  
  /** 
   * @property status - 选中状态
   * @description 标识该书籍是否被选中
   * @type {boolean}
   */
  status:boolean

  /**
   * @constructor readBookList
   * @description 阅读书籍列表数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化阅读书籍列表项的所有字段
   * 2. 为可选参数提供合理的默认值
   * 3. 确保数据模型的完整性
   * 
   * 参数说明：
   * @param {string} bookName - 书籍名称（必需参数）
   * @param {ResourceStr} coverImage - 封面图片资源字符串（必需参数）
   * @param {string} author - 作者名称（必需参数）
   * @param {number[]} readingDuration - 阅读时长数组（必需参数）
   * @param {Date} dateTime - 当前阅读时间（必需参数）
   * @param {number} schedule - 阅读进度（必需参数）
   * @param {number} bookmark - 书签位置（必需参数）
   * @param {number} [readFrequency=0] - 读完次数，默认0
   * @param {boolean} [status=false] - 选中状态，默认false
   * 
   * 初始化逻辑：
   * 1. 将必需参数赋值给对应的类属性
   * 2. 将可选参数使用默认值或传入值
   * 3. 注意参数顺序：必需参数在前，可选参数在后
   * 
   * 设计理念：
   * - 必需参数在前，可选参数在后
   * - 为可选参数提供合理的默认值
   * - 默认值符合常见使用场景
   * - 保持数据模型的灵活性
   * 
   * 使用示例：
   * ```typescript
   * // 创建阅读书籍列表项
   * const readBook = new readBookList(
   *   '斗破苍穹',
   *   'app.media.cover_doupo',
   *   '天蚕土豆',
   *   [120, 90, 180],
   *   new Date(),
   *   75,
   *   150,
   *   1,
   *   true
   * );
   * ```
   * 
   * 字段用途说明：
   * 1. readingDuration: 数组形式，可以记录多个阅读时段，便于统计总阅读时长
   * 2. schedule: 进度百分比，直观显示阅读进度
   * 3. bookmark: 书签位置，方便用户快速跳转到上次阅读位置
   * 4. readFrequency: 读完次数，统计用户对书籍的喜爱程度
   * 5. dateTime: 记录最后一次阅读时间，用于排序和显示"最近阅读"
   * 
   * 注意事项：
   * - 类名使用小写开头，不符合常规类名规范（应为ReadBookList）
   * - 前7个参数为必需参数，后2个参数为可选参数
   * - coverImage类型为ResourceStr，不是Resource类型，使用时需要注意
   * - readingDuration是数组，需要确保数组格式正确
   * - schedule应该是0-100之间的数字，表示百分比
   * 
   * 扩展建议：
   * - 可以添加lastReadChapter属性记录最后阅读章节
   * - 可以添加totalReadingTime属性计算总阅读时长
   * - 可以添加rating属性记录用户评分
   * - 可以添加notesCount属性记录笔记数量
   * 
   * @returns {readBookList} 新的阅读书籍列表项实例
   */
  constructor(bookName: string, coverImage: ResourceStr, author: string, readingDuration: number[], dateTime: Date,
    schedule: number, bookmark: number,readFrequency:number=0, status: boolean=false) {
    this.bookName = bookName
    this.coverImage = coverImage
    this.author = author
    this.readingDuration = readingDuration
    this.dateTime = dateTime
    this.schedule = schedule
    this.bookmark = bookmark
    this.readFrequency=readFrequency
    this.status = status
  }
}

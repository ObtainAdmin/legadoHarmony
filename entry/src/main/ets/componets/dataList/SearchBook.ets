
/**
 * @file SearchBook.ets
 * @description 搜索书籍数据模型类
 * 
 * 功能概述：
 * 1. 定义搜索书籍结果项的数据结构
 * 2. 提供搜索书籍信息的完整字段定义
 * 3. 包含构造函数初始化数据
 * 4. 用于搜索结果列表展示的数据模型
 * 
 * 使用场景：
 * - 书籍搜索结果列表数据模型
 * - 书籍推荐列表数据模型
 * - 需要显示书籍详细信息的搜索场景
 * - 书籍发现页面的数据模型
 * 
 * 数据字段说明：
 * 1. 基本信息：
 *   - title: 书籍标题
 *   - describe: 书籍描述
 *   - bookImage: 书籍封面图片资源字符串
 *   - author: 作者名称
 * 
 * 2. 分类信息：
 *   - label: 书籍标签数组
 *   - sourceNumber: 源数量（可用的书籍源数量）
 * 
 * 3. 统计信息：
 *   - wordCount: 书籍字数
 *   - status: 是否完本状态
 * 
 * 设计特点：
 * - 使用TypeScript类定义数据模型
 * - 提供详细的字段注释
 * - 构造函数初始化所有字段
 * - 无默认值，所有参数必需
 * 
 * 技术特点：
 * - 使用ResourceStr类型支持图片资源字符串
 * - 使用String[]数组类型支持多个标签
 * - 简洁的构造函数参数传递
 */

/**
 * @class SearchBook
 * @description 搜索书籍数据模型类
 * 
 * 类职责：
 * 1. 定义搜索书籍结果项的数据结构
 * 2. 提供构造函数初始化数据
 * 3. 管理搜索书籍信息的各个字段
 * 
 * 字段说明：
 */
export class SearchBook {
  /** 
   * @property title - 书籍标题
   * @description 书籍的名称或标题
   * @type {string}
   */
  title:string
  
  /** 
   * @property describe - 书籍描述
   * @description 书籍的简介或描述信息
   * @type {string}
   */
  describe:string
  
  /** 
   * @property bookImage - 书籍封面图片
   * @description 书籍的封面图片资源字符串
   * @type {ResourceStr}
   */
  bookImage:ResourceStr
  
  /** 
   * @property author - 作者名称
   * @description 书籍的作者姓名
   * @type {string}
   */
  author:string
  
  /** 
   * @property label - 书籍标签
   * @description 书籍的分类标签数组
   * 示例：["玄幻", "热血", "穿越"]
   * @type {String[]}
   */
  label:String[]
  
  /** 
   * @property sourceNumber - 源数量
   * @description 可用的书籍源数量，表示有多少个来源提供该书籍
   * @type {number}
   */
  sourceNumber:number
  
  /** 
   * @property wordCount - 书籍字数
   * @description 书籍的总字数统计
   * @type {number}
   */
  wordCount:number
  
  /** 
   * @property status - 是否完本状态
   * @description 标识书籍是否已经完本
   * - true: 已完本
   * - false: 连载中
   * @type {boolean}
   */
  status:boolean

  /**
   * @constructor SearchBook
   * @description 搜索书籍数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化搜索书籍结果项的所有字段
   * 2. 所有参数均为必需参数
   * 3. 简单的参数赋值逻辑
   * 
   * 参数说明：
   * @param {string} title - 书籍标题（必需参数）
   * @param {string} describe - 书籍描述（必需参数）
   * @param {ResourceStr} bookImage - 书籍封面图片资源字符串（必需参数）
   * @param {string} author - 作者名称（必需参数）
   * @param {String[]} label - 书籍标签数组（必需参数）
   * @param {number} sourceNumber - 源数量（必需参数）
   * @param {number} wordCount - 书籍字数（必需参数）
   * @param {boolean} status - 是否完本状态（必需参数）
   * 
   * 初始化逻辑：
   * 1. 将title参数赋值给this.title
   * 2. 将describe参数赋值给this.describe
   * 3. 将bookImage参数赋值给this.bookImage
   * 4. 将author参数赋值给this.author
   * 5. 将label参数赋值给this.label
   * 6. 将sourceNumber参数赋值给this.sourceNumber
   * 7. 将wordCount参数赋值给this.wordCount
   * 8. 将status参数赋值给this.status
   * 
   * 设计理念：
   * - 所有参数必需，确保搜索结果的完整性
   * - 简单的数据结构，易于理解和使用
   * - 直接参数赋值，无复杂逻辑
   * 
   * 使用示例：
   * ```typescript
   * // 创建搜索书籍结果项
   * const searchBook = new SearchBook(
   *   '斗破苍穹',
   *   '废柴少年逆袭成为斗帝的故事',
   *   'app.media.cover_doupo',
   *   '天蚕土豆',
   *   ['玄幻', '热血', '穿越'],
   *   5,
   *   5000000,
   *   true
   * );
   * ```
   * 
   * 字段用途说明：
   * 1. sourceNumber: 表示有多少个书籍源提供该书籍，源越多表示越容易找到可阅读的版本
   * 2. wordCount: 书籍总字数，帮助用户了解书籍篇幅
   * 3. status: 完本状态，用户通常偏好已完本的书籍
   * 4. label: 标签数组，帮助用户快速了解书籍类型和特点
   * 
   * 注意事项：
   * - 所有参数都是必需的，没有默认值
   * - bookImage类型为ResourceStr，不是Resource类型，使用时需要注意
   * - label是String[]类型，注意是大写S，应该是string[]（TypeScript标准类型）
   * - sourceNumber应该是正整数，表示可用的源数量
   * - wordCount单位通常是"字"，不是"字节"
   * 
   * 扩展建议：
   * - 可以添加score属性记录书籍评分
   * - 可以添加updateTime属性记录最后更新时间
   * - 可以添加chapterCount属性记录章节数量
   * - 可以添加popularity属性记录书籍热度
   * 
   * @returns {SearchBook} 新的搜索书籍结果项实例
   */
  constructor( title:string,describe:string , bookImage:ResourceStr,author:string,label:String[],sourceNumber:number,wordCount:number,status:boolean) {
    this.title = title
    this.describe = describe
    this.bookImage = bookImage
    this.author = author
    this.label = label
    this.sourceNumber = sourceNumber
    this.wordCount = wordCount
    this.status = status
  }
}

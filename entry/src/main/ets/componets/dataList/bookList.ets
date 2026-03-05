/**
 * @file bookList.ets
 * @description 书籍列表数据模型类
 * 
 * 功能概述：
 * 1. 定义书籍列表项的数据结构
 * 2. 提供书籍信息的完整字段定义
 * 3. 包含构造函数和默认值设置
 * 4. 用于书籍列表展示的数据模型
 * 
 * 使用场景：
 * - 书架列表数据模型
 * - 搜索结果列表数据模型
 * - 书籍分类列表数据模型
 * - 需要统一书籍数据格式的场景
 * 
 * 数据字段说明：
 * 1. 基本信息：
 *   - bookId: 书籍唯一标识
 *   - title: 书籍标题
 *   - author: 作者名称
 *   - describe: 书籍描述
 *   - bookType: 书籍类型（如玄幻、武侠等）
 * 
 * 2. 阅读状态：
 *   - chapter: 当前阅读章节
 *   - isJoin: 是否已加入书架
 *   - isTop: 是否置顶
 *   - topUpdateTime: 置顶更新时间
 * 
 * 3. 资源信息：
 *   - bookImage: 书籍封面图片资源
 *   - bookUrl: 书籍本地路径
 *   - fileLink: 文件链接
 * 
 * 设计特点：
 * - 使用TypeScript类定义数据模型
 * - 提供详细的字段注释
 * - 构造函数支持默认值
 * - 合理的默认值设置（如默认作者、类型）
 * 
 * 默认值策略：
 * - author: 默认"卖报小郎君"
 * - bookType: 默认"玄幻"
 * - isJoin: 默认false（未加入书架）
 * - isTop: 默认false（未置顶）
 * - topUpdateTime: 默认当前时间
 * - fileLink: 默认空字符串
 * - bookUrl: 构造函数中初始化为空字符串
 */

/**
 * @class BookList
 * @description 书籍列表数据模型类
 * 
 * 类职责：
 * 1. 定义书籍列表项的数据结构
 * 2. 提供构造函数初始化数据
 * 3. 管理书籍信息的各个字段
 * 
 * 字段说明：
 */
export class BookList {
  /** 
   * @property bookId - 书籍唯一标识
   * @description 书籍的唯一标识符，用于区分不同的书籍
   * @type {string}
   */
  bookId: string
  
  /** 
   * @property title - 书籍标题
   * @description 书籍的名称或标题
   * @type {string}
   */
  title: string
  
  /** 
   * @property bookUrl - 书籍本地路径
   * @description 书籍文件在本地存储的路径
   * @type {string}
   */
  bookUrl: string
  
  /** 
   * @property describe - 书籍描述
   * @description 书籍的简介或描述信息
   * @type {string}
   */
  describe: string
  
  /** 
   * @property isJoin - 是否加入书架
   * @description 标识该书籍是否已加入用户的书架
   * @type {boolean}
   */
  isJoin: boolean
  
  /** 
   * @property chapter - 当前阅读章节
   * @description 用户当前阅读的章节信息
   * @type {string}
   */
  chapter: string
  
  /** 
   * @property bookImage - 书籍封面图片
   * @description 书籍的封面图片资源
   * @type {Resource}
   */
  bookImage: Resource
  
  /** 
   * @property bookType - 书籍类型
   * @description 书籍的分类类型，如玄幻、武侠、都市等
   * @type {string}
   */
  bookType: string
  
  /** 
   * @property isTop - 是否置顶
   * @description 标识该书籍是否在书架中置顶显示
   * @type {boolean}
   */
  isTop: boolean
  
  /** 
   * @property topUpdateTime - 置顶更新时间
   * @description 书籍置顶状态更新的时间戳
   * @type {Date}
   */
  topUpdateTime: Date
  
  /** 
   * @property author - 作者名称
   * @description 书籍的作者姓名
   * @type {string}
   */
  author: string
  
  /** 
   * @property fileLink - 文件链接
   * @description 书籍文件的网络链接或本地链接
   * @type {string}
   */
  fileLink: string

  /**
   * @constructor BookList
   * @description 书籍列表数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化书籍列表项的所有字段
   * 2. 为可选参数提供合理的默认值
   * 3. 确保数据模型的完整性
   * 
   * 参数说明：
   * @param {string} [bookId=''] - 书籍唯一标识，默认空字符串
   * @param {string} title - 书籍标题（必需参数）
   * @param {string} describe - 书籍描述（必需参数）
   * @param {string} chapter - 当前阅读章节（必需参数）
   * @param {Resource} bookImage - 书籍封面图片资源（必需参数）
   * @param {string} [author='卖报小郎君'] - 作者名称，默认"卖报小郎君"
   * @param {string} [bookType='玄幻'] - 书籍类型，默认"玄幻"
   * @param {string} [fileLink=''] - 文件链接，默认空字符串
   * @param {Date} [topUpdateTime=new Date()] - 置顶更新时间，默认当前时间
   * @param {boolean} [isJoin=false] - 是否加入书架，默认false
   * @param {boolean} [isTop=false] - 是否置顶，默认false
   * 
   * 初始化逻辑：
   * 1. 将参数赋值给对应的类属性
   * 2. bookUrl属性固定初始化为空字符串
   * 3. 其他属性使用参数值或默认值
   * 
   * 设计理念：
   * - 必需参数在前，可选参数在后
   * - 为可选参数提供合理的默认值
   * - 默认值符合常见使用场景
   * - 保持数据模型的灵活性
   * 
   * 使用示例：
   * ```typescript
   * // 创建书籍列表项
   * const book = new BookList(
   *   'book_001',
   *   '斗破苍穹',
   *   '废柴少年逆袭成为斗帝的故事',
   *   '第100章 突破',
   *   $r('app.media.book_cover_1'),
   *   '天蚕土豆',
   *   '玄幻',
   *   'https://example.com/book.pdf',
   *   new Date(),
   *   true,
   *   false
   * );
   * ```
   * 
   * 注意事项：
   * - title、describe、chapter、bookImage为必需参数
   * - bookUrl在构造函数中固定初始化为空字符串
   * - 默认作者"卖报小郎君"和类型"玄幻"可能不适用于所有场景
   * - 置顶时间默认当前时间，实际使用时可能需要调整
   * 
   * @returns {BookList} 新的书籍列表项实例
   */
  constructor(bookId: string = '', title: string, describe: string, chapter: string, bookImage: Resource,
    author: string = '卖报小郎君', bookType: string = '玄幻', fileLink: string = '', topUpdateTime: Date = new Date(),
    isJoin: boolean = false, isTop: boolean = false) {
    this.bookId = bookId
    this.title = title
    this.isJoin = isJoin
    this.describe = describe
    this.chapter = chapter
    this.bookImage = bookImage
    this.bookType = bookType
    this.isTop = isTop
    this.topUpdateTime = topUpdateTime
    this.author = author
    this.fileLink = fileLink
    this.bookUrl = ''
  }
}

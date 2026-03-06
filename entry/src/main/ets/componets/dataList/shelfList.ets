/**
 * @file shelfList.ets
 * @description 书架列表数据模型类
 * 
 * 功能概述：
 * 1. 定义书架列表项的数据结构
 * 2. 提供书架信息的完整字段定义
 * 3. 包含构造函数和默认值设置
 * 4. 用于书架列表展示的数据模型
 * 
 * 使用场景：
 * - 书单列表数据模型
 * - 推荐书单数据模型
 * - 书架分组数据模型
 * - 需要显示书单信息的场景
 * 
 * 数据字段说明：
 * 1. 基本信息：
 *   - id: 书架唯一标识
 *   - title: 书架标题
 *   - describe: 书架描述
 *   - recommendation: 推荐理由
 * 
 * 2. 状态信息：
 *   - isTop: 是否置顶
 *   - isShow: 是否显示
 *   - topUpdateTime: 置顶更新时间
 * 
 * 3. 内容信息：
 *   - bookList: 书籍内容列表（BookList对象数组）
 * 
 * 设计特点：
 * - 使用TypeScript类定义数据模型
 * - 提供详细的字段注释
 * - 构造函数支持默认值
 * - 合理的默认值设置
 * - 引用BookList类作为书籍内容
 * 
 * 默认值策略：
 * - isTop: 默认false（未置顶）
 * - isShow: 默认false（不显示）
 * - topUpdateTime: 默认当前时间
 */

import { BookList } from './bookList'

/**
 * @class shelfList
 * @description 书架列表数据模型类
 * 
 * 类职责：
 * 1. 定义书架列表项的数据结构
 * 2. 提供构造函数初始化数据
 * 3. 管理书架信息的各个字段
 * 4. 引用BookList类管理书籍内容
 * 
 * 字段说明：
 */
export class shelfList {
  /** 
   * @property id - 书架唯一标识
   * @description 书架的唯一标识符，用于区分不同的书架
   * @type {number}
   */
  id:number
  
  /** 
   * @property title - 书架标题
   * @description 书架的标题或名称
   * @type {string}
   */
  title:string

  /** 
   * @property describe - 书架描述
   * @description 书架的简介或描述信息
   * @type {string}
   */
  describe:string

  /** 
   * @property recommendation - 推荐理由
   * @description 书架的推荐理由或说明
   * @type {string}
   */
  recommendation:string

  /** 
   * @property isTop - 是否置顶
   * @description 标识该书架是否在列表中置顶显示
   * @type {boolean}
   */
  isTop:boolean
  
  /** 
   * @property isShow - 是否显示
   * @description 控制该书架是否在界面中显示
   * @type {boolean}
   */
  isShow:boolean

  /** 
   * @property topUpdateTime - 置顶更新时间
   * @description 书架置顶状态更新的时间戳
   * @type {Date}
   */
  topUpdateTime:Date

  /** 
   * @property bookList - 书籍内容列表
   * @description 书架中包含的书籍列表，使用BookList对象数组
   * @type {BookList[]}
   */
  bookList:BookList[]

  /**
   * @constructor shelfList
   * @description 书架列表数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化书架列表项的所有字段
   * 2. 为可选参数提供合理的默认值
   * 3. 确保数据模型的完整性
   * 
   * 参数说明：
   * @param {number} id - 书架唯一标识（必需参数）
   * @param {string} title - 书架标题（必需参数）
   * @param {string} describe - 书架描述（必需参数）
   * @param {string} recommendation - 推荐理由（必需参数）
   * @param {BookList[]} bookList - 书籍内容列表（必需参数）
   * @param {boolean} [isTop=false] - 是否置顶，默认false
   * @param {boolean} [isShow=false] - 是否显示，默认false
   * @param {Date} [topUpdateTime=new Date()] - 置顶更新时间，默认当前时间
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
   * - 引用BookList类，实现数据模型的复用
   * 
   * 使用示例：
   * ```typescript
   * // 创建书架列表项
   * const shelf = new shelfList(
   *   1,
   *   '玄幻小说精选',
   *   '精选热门玄幻小说',
   *   '根据用户阅读偏好推荐',
   *   [
   *     new BookList('book_001', '斗破苍穹', '废柴少年逆袭成为斗帝的故事', '第100章', $r('app.media.cover_doupo')),
   *     new BookList('book_002', '凡人修仙传', '凡人修仙的艰辛历程', '第50章', $r('app.media.cover_fanren'))
   *   ],
   *   true,
   *   true,
   *   new Date()
   * );
   * ```
   * 
   * 字段用途说明：
   * 1. isShow: 控制书架是否在界面中显示，可用于隐藏空书架或未完成的书架
   * 2. isTop: 控制书架是否置顶，重要书架可以置顶显示
   * 3. topUpdateTime: 记录置顶时间，可用于排序或显示"最近置顶"
   * 4. recommendation: 推荐理由，帮助用户了解书架的特色和价值
   * 5. bookList: 使用BookList对象数组，复用已有的书籍数据模型
   * 
   * 注意事项：
   * - 类名使用小写开头，不符合常规类名规范（应为ShelfList）
   * - 前5个参数为必需参数，后3个参数为可选参数
   * - bookList是BookList对象数组，需要先创建BookList实例
   * - topUpdateTime默认当前时间，实际使用时可能需要调整
   * - 需要导入BookList类：import { BookList } from './bookList'
   * 
   * 扩展建议：
   * - 可以添加coverImage属性显示书架封面
   * - 可以添加createTime属性记录创建时间
   * - 可以添加creator属性记录创建者
   * - 可以添加tags属性存储书架标签
   * 
   * @returns {shelfList} 新的书架列表项实例
   */
  constructor(id:number,title:string,describe:string
    ,recommendation:string,bookList:BookList[],isTop:boolean = false,isShow:boolean = false
    ,topUpdateTime:Date = new Date()
   ) {
    this.id = id
    this.title = title
    this.isTop = isTop
    this.describe = describe
    this.topUpdateTime = topUpdateTime
    this.isShow = isShow
    this.bookList = bookList
    this.recommendation = recommendation
  }
}

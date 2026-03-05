/**
 * @file folderList.ets
 * @description 文件夹列表数据模型类
 * 
 * 功能概述：
 * 1. 定义文件夹列表项的数据结构
 * 2. 提供文件夹信息的完整字段定义
 * 3. 包含构造函数和默认值设置
 * 4. 用于文件夹列表展示的数据模型
 * 
 * 使用场景：
 * - 书籍文件夹列表数据模型
 * - 分类文件夹列表数据模型
 * - 需要显示文件夹信息的场景
 * - 书架中的文件夹分组
 * 
 * 数据字段说明：
 * 1. 基本信息：
 *   - id: 文件夹唯一标识
 *   - title: 文件夹标题
 *   - describe: 文件夹描述
 *   - bookType: 书籍类型
 * 
 * 2. 统计信息：
 *   - countNumber: 书籍数量
 *   - bookImage: 文件夹封面图片
 *   - newUpdateBook: 最新更新的书籍
 * 
 * 3. 状态信息：
 *   - isTop: 是否置顶
 *   - isShow: 是否显示
 *   - isUpdateReminder: 是否有更新提醒
 *   - topUpdateTime: 置顶更新时间
 * 
 * 设计特点：
 * - 使用TypeScript类定义数据模型
 * - 提供详细的字段注释
 * - 构造函数支持默认值
 * - 合理的默认值设置
 * 
 * 默认值策略：
 * - newUpdateBook: 默认空字符串
 * - isShow: 默认false（不显示）
 * - isTop: 默认false（未置顶）
 * - describe: 默认空字符串
 * - topUpdateTime: 默认当前时间
 * - isUpdateReminder: 默认false（无更新提醒）
 */

/**
 * @class folderList
 * @description 文件夹列表数据模型类
 * 
 * 类职责：
 * 1. 定义文件夹列表项的数据结构
 * 2. 提供构造函数初始化数据
 * 3. 管理文件夹信息的各个字段
 * 
 * 字段说明：
 */
export class folderList {
  /** 
   * @property id - 文件夹唯一标识
   * @description 文件夹的唯一标识符，用于区分不同的文件夹
   * @type {number}
   */
  id:number
  
  /** 
   * @property title - 文件夹标题
   * @description 文件夹的名称或标题
   * @type {string}
   */
  title:string

  /** 
   * @property describe - 文件夹描述
   * @description 文件夹的简介或描述信息
   * @type {string}
   */
  describe:string

  /** 
   * @property bookType - 书籍类型
   * @description 文件夹中书籍的分类类型
   * @type {string}
   */
  bookType:string

  /** 
   * @property countNumber - 书籍数量
   * @description 文件夹中包含的书籍数量
   * @type {number}
   */
  countNumber:number

  /** 
   * @property bookImage - 文件夹封面图片
   * @description 文件夹的封面图片资源
   * @type {Resource}
   */
  bookImage:Resource

  /** 
   * @property isTop - 是否置顶
   * @description 标识该文件夹是否在列表中置顶显示
   * @type {boolean}
   */
  isTop:boolean

  /** 
   * @property isShow - 是否显示
   * @description 控制该文件夹是否在界面中显示
   * @type {boolean}
   */
  isShow:boolean

  /** 
   * @property newUpdateBook - 最新更新的书籍
   * @description 文件夹中最新更新的书籍名称
   * @type {string}
   */
  newUpdateBook:string

  /** 
   * @property topUpdateTime - 置顶更新时间
   * @description 文件夹置顶状态更新的时间戳
   * @type {Date}
   */
  topUpdateTime:Date

  /** 
   * @property isUpdateReminder - 是否有更新提醒
   * @description 标识该文件夹是否有新的更新需要提醒用户
   * @type {boolean}
   */
  isUpdateReminder:boolean

  /**
   * @constructor folderList
   * @description 文件夹列表数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化文件夹列表项的所有字段
   * 2. 为可选参数提供合理的默认值
   * 3. 确保数据模型的完整性
   * 
   * 参数说明：
   * @param {number} id - 文件夹唯一标识（必需参数）
   * @param {string} title - 文件夹标题（必需参数）
   * @param {number} countNumber - 书籍数量（必需参数）
   * @param {Resource} bookImage - 文件夹封面图片（必需参数）
   * @param {string} bookType - 书籍类型（必需参数）
   * @param {string} [newUpdateBook=''] - 最新更新的书籍，默认空字符串
   * @param {boolean} [isShow=false] - 是否显示，默认false
   * @param {boolean} [isTop=false] - 是否置顶，默认false
   * @param {string} [describe=''] - 文件夹描述，默认空字符串
   * @param {Date} [topUpdateTime=new Date()] - 置顶更新时间，默认当前时间
   * @param {boolean} [isUpdateReminder=false] - 是否有更新提醒，默认false
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
   * // 创建文件夹列表项
   * const folder = new folderList(
   *   1,
   *   '玄幻小说',
   *   25,
   *   $r('app.media.folder_fantasy'),
   *   '玄幻',
   *   '斗破苍穹',
   *   true,
   *   true,
   *   '包含各种玄幻小说',
   *   new Date(),
   *   true
   * );
   * ```
   * 
   * 字段用途说明：
   * 1. isShow: 控制文件夹是否在界面中显示，可用于隐藏空文件夹
   * 2. isUpdateReminder: 当文件夹中有新更新时设置为true，提醒用户查看
   * 3. newUpdateBook: 显示文件夹中最新更新的书籍，吸引用户点击
   * 4. topUpdateTime: 记录置顶时间，可用于排序或显示"最近置顶"
   * 
   * 注意事项：
   * - 类名使用小写开头，不符合常规类名规范（应为FolderList）
   * - 前5个参数为必需参数，后6个参数为可选参数
   * - bookImage类型为Resource，需要使用$r()函数加载资源
   * - topUpdateTime默认当前时间，实际使用时可能需要调整
   * 
   * 扩展建议：
   * - 可以添加createTime属性记录创建时间
   * - 可以添加sortOrder属性控制排序顺序
   * - 可以添加color属性控制文件夹颜色主题
   * - 可以添加tags属性存储文件夹标签
   * 
   * @returns {folderList} 新的文件夹列表项实例
   */
  constructor(id:number,title:string,countNumber:number,bookImage:Resource,bookType:string,newUpdateBook:string = '',isShow:boolean = false,isTop:boolean = false,describe:string = '', topUpdateTime:Date = new Date(),isUpdateReminder:boolean = false) {
    this.id = id
    this.title = title
    this.bookType = bookType
    this.isTop = isTop
    this.describe = describe
    this.countNumber = countNumber
    this.bookImage = bookImage
    this.newUpdateBook = newUpdateBook
    this.topUpdateTime = topUpdateTime
    this.isShow = isShow
    this.isUpdateReminder = isUpdateReminder
  }
}

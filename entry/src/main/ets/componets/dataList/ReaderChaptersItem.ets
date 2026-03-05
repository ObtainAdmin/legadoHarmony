/**
 * @file ReaderChaptersItem.ets
 * @description 章节项数据模型类
 * 
 * 功能概述：
 * 1. 定义书籍章节项的数据结构
 * 2. 提供章节信息的完整字段定义
 * 3. 包含构造函数和默认值设置
 * 4. 用于章节列表展示的数据模型
 * 
 * 使用场景：
 * - 书籍章节列表数据模型
 * - 目录列表数据模型
 * - 阅读器中的章节导航
 * - 需要显示章节信息的场景
 * 
 * 数据字段说明：
 * 1. number: 章节编号
 *   - 类型：number
 *   - 用途：章节的顺序编号，用于排序
 * 
 * 2. title: 章节标题
 *   - 类型：string
 *   - 用途：章节的名称或标题
 * 
 * 3. chapterTitleNumber: 章节标题编号
 *   - 类型：string
 *   - 用途：章节的格式化编号，如"第1章"、"第一章"等
 * 
 * 4. content: 章节内容
 *   - 类型：string
 *   - 用途：章节的文本内容
 * 
 * 设计特点：
 * - 使用TypeScript类定义数据模型
 * - 构造函数支持默认值
 * - 简洁的数据结构设计
 * - 合理的默认值设置
 * 
 * 默认值策略：
 * - title: 默认空字符串
 * - chapterTitleNumber: 默认空字符串
 * - content: 默认空字符串
 */

/**
 * @class chaptersItem
 * @description 章节项数据模型类
 * 
 * 类职责：
 * 1. 定义章节项的数据结构
 * 2. 提供构造函数初始化数据
 * 3. 管理章节信息的各个字段
 * 
 * 字段说明：
 */
export class chaptersItem {
  /** 
   * @property number - 章节编号
   * @description 章节的顺序编号，用于排序和标识章节位置
   * @type {number}
   */
  number: number
  
  /** 
   * @property content - 章节内容
   * @description 章节的文本内容
   * @type {string}
   */
  content: string
  
  /** 
   * @property chapterTitleNumber - 章节标题编号
   * @description 章节的格式化编号，用于显示
   * 示例："第1章"、"第一章"、"Chapter 1"
   * @type {string}
   */
  chapterTitleNumber: string
  
  /** 
   * @property title - 章节标题
   * @description 章节的名称或标题
   * @type {string}
   */
  title: string

  /**
   * @constructor chaptersItem
   * @description 章节项数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化章节项的所有字段
   * 2. 为可选参数提供合理的默认值
   * 3. 确保数据模型的完整性
   * 
   * 参数说明：
   * @param {number} number - 章节编号（必需参数）
   * @param {string} [title=''] - 章节标题，默认空字符串
   * @param {string} [chapterTitleNumber=''] - 章节标题编号，默认空字符串
   * @param {string} [content=''] - 章节内容，默认空字符串
   * 
   * 初始化逻辑：
   * 1. 将number参数赋值给this.number
   * 2. 将content参数赋值给this.content
   * 3. 将chapterTitleNumber参数赋值给this.chapterTitleNumber
   * 4. 将title参数赋值给this.title
   * 
   * 设计理念：
   * - 必需参数在前，可选参数在后
   * - 为可选参数提供合理的默认值
   * - 默认值符合常见使用场景
   * - 保持数据模型的灵活性
   * 
   * 使用示例：
   * ```typescript
   * // 创建章节项
   * const chapter = new chaptersItem(
   *   1,
   *   '陨落的天才',
   *   '第1章',
   *   '斗之力，三段！望着测验魔石碑上面闪亮得甚至有些刺眼的五个大字...'
   * );
   * 
   * // 创建只有编号的章节项
   * const simpleChapter = new chaptersItem(2);
   * ```
   * 
   * 字段关系说明：
   * 1. number: 纯数字编号，用于内部排序和计算
   * 2. chapterTitleNumber: 格式化后的显示编号，用于UI展示
   * 3. title: 章节的具体标题，描述章节内容
   * 4. content: 章节的完整文本内容，可能很长
   * 
   * 注意事项：
   * - 类名使用小写开头，不符合常规类名规范（应为ChaptersItem）
   * - number是必需参数，其他参数都有默认值
   * - content字段可能包含大量文本，使用时需要注意性能
   * - chapterTitleNumber和title都可以为空，但至少应该有一个用于显示
   * 
   * 扩展建议：
   * - 可以添加wordCount属性记录章节字数
   * - 可以添加readStatus属性记录阅读状态
   * - 可以添加bookmark属性记录书签位置
   * - 可以添加updateTime属性记录更新时间
   * 
   * @returns {chaptersItem} 新的章节项实例
   */
  constructor(number: number, title = '', chapterTitleNumber = '', content = '') {
    this.number = number
    this.content = content
    this.chapterTitleNumber = chapterTitleNumber
    this.title = title
  }
}

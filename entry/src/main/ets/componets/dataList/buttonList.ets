/**
 * @file buttonList.ets
 * @description 按钮列表数据模型类
 * 
 * 功能概述：
 * 1. 定义按钮列表项的数据结构
 * 2. 提供按钮信息的字段定义
 * 3. 包含构造函数初始化数据
 * 4. 用于按钮列表展示的数据模型
 * 
 * 使用场景：
 * - 操作按钮列表数据模型
 * - 工具按钮列表数据模型
 * - 功能菜单按钮数据模型
 * - 需要统一按钮数据格式的场景
 * 
 * 数据字段说明：
 * 1. id: 按钮唯一标识
 *   - 类型：number
 *   - 用途：区分不同的按钮项
 * 
 * 2. title: 按钮标题
 *   - 类型：string
 *   - 用途：显示在按钮上的文本
 * 
 * 3. icon: 按钮图标
 *   - 类型：Resource
 *   - 用途：显示在按钮上的图标资源
 * 
 * 设计特点：
 * - 简洁的数据结构：id + title + icon
 * - 使用TypeScript类定义数据模型
 * - 构造函数初始化所有字段
 * - 无默认值，所有参数必需
 * 
 * 技术特点：
 * - 使用Resource类型支持图标资源
 * - 简单的构造函数参数传递
 * - 易于序列化和反序列化
 * 
 * @author 2008
 * @datetime 2024/5/23 22:26
 */

/**
 * @class buttonList
 * @description 按钮列表数据模型类
 * 
 * 类职责：
 * 1. 定义按钮列表项的数据结构
 * 2. 提供构造函数初始化数据
 * 3. 管理按钮信息的各个字段
 * 
 * 字段说明：
 */
export class buttonList {
  /** 
   * @property id - 按钮唯一标识
   * @description 按钮的唯一标识符，用于区分不同的按钮项
   * @type {number}
   */
  id:number
  
  /** 
   * @property title - 按钮标题
   * @description 显示在按钮上的文本内容
   * @type {string}
   */
  title:string
  
  /** 
   * @property icon - 按钮图标
   * @description 显示在按钮上的图标资源
   * @type {Resource}
   */
  icon:Resource
  
  /**
   * @constructor buttonList
   * @description 按钮列表数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化按钮列表项的所有字段
   * 2. 所有参数均为必需参数
   * 3. 简单的参数赋值逻辑
   * 
   * 参数说明：
   * @param {number} id - 按钮唯一标识
   * @param {string} title - 按钮标题文本
   * @param {Resource} icon - 按钮图标资源
   * 
   * 初始化逻辑：
   * 1. 将id参数赋值给this.id
   * 2. 将title参数赋值给this.title
   * 3. 将icon参数赋值给this.icon
   * 
   * 设计理念：
   * - 简单的数据结构，易于理解和使用
   * - 所有参数必需，确保数据完整性
   * - 直接参数赋值，无复杂逻辑
   * 
   * 使用示例：
   * ```typescript
   * // 创建按钮列表项
   * const button = new buttonList(
   *   1,
   *   '设置',
   *   $r('app.media.icon_settings')
   * );
   * 
   * // 在组件中使用
   * operateIcon({ item: button })
   * ```
   * 
   * 关联组件：
   * - operateIcon.ets：使用buttonList作为数据源
   * - 其他需要按钮列表的组件
   * 
   * 注意事项：
   * - 所有参数都是必需的，没有默认值
   * - icon类型为Resource，需要使用$r()函数加载资源
   * - id应为唯一值，避免重复
   * - 该类名使用小写开头，不符合常规类名规范（应为ButtonList）
   * 
   * 扩展建议：
   * - 可以添加disabled属性控制按钮禁用状态
   * - 可以添加onClick属性存储点击回调
   * - 可以添加color属性控制按钮颜色
   * 
   * @returns {buttonList} 新的按钮列表项实例
   */
  constructor(id:number,title:string,icon:Resource){
    this.id = id
    this.title = title
    this.icon = icon
  }
}

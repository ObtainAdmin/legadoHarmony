
/**
 * @file serviceList.ets
 * @description 服务列表数据模型类
 * 
 * 功能概述：
 * 1. 定义服务列表项的数据结构
 * 2. 提供服务信息的字段定义
 * 3. 包含构造函数和默认值设置
 * 4. 用于服务列表展示的数据模型
 * 
 * 使用场景：
 * - 服务功能列表数据模型
 * - 工具服务列表数据模型
 * - 需要显示服务项的场景
 * - 带有渐变背景的服务卡片
 * 
 * 数据字段说明：
 * 1. name: 服务名称
 *   - 类型：string
 *   - 用途：服务的名称或标题
 * 
 * 2. value: 服务值
 *   - 类型：string
 *   - 用途：服务的值或描述
 * 
 * 3. img: 服务图标
 *   - 类型：ResourceStr
 *   - 用途：服务的图标资源字符串
 * 
 * 4. background: 背景颜色数组
 *   - 类型：Array<ResourceColor>
 *   - 用途：服务的背景颜色，支持渐变效果
 * 
 * 设计特点：
 * - 使用TypeScript类定义数据模型
 * - 构造函数支持默认值
 * - 支持渐变背景效果
 * - 合理的默认值设置
 * 
 * 默认值策略：
 * - name: 默认空字符串
 * - value: 默认空字符串
 * - img: 默认空字符串
 * - background: 默认空数组
 */

/**
 * @class serviceList
 * @description 服务列表数据模型类
 * 
 * 类职责：
 * 1. 定义服务列表项的数据结构
 * 2. 提供构造函数初始化数据
 * 3. 管理服务信息的各个字段
 * 
 * 字段说明：
 */
export class serviceList {
  /** 
   * @property name - 服务名称
   * @description 服务的名称或标题
   * @type {string}
   */
  name:string

  /** 
   * @property value - 服务值
   * @description 服务的值或描述信息
   * @type {string}
   */
  value:string

  /** 
   * @property img - 服务图标
   * @description 服务的图标资源字符串
   * @type {ResourceStr}
   */
  img:ResourceStr

  /** 
   * @property background - 背景颜色数组
   * @description 服务的背景颜色数组，支持渐变效果
   * 示例：[Color.Blue, Color.Green] 创建蓝到绿的渐变背景
   * @type {Array<ResourceColor>}
   */
  background:Array<ResourceColor>

  /**
   * @constructor serviceList
   * @description 服务列表数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化服务列表项的所有字段
   * 2. 为所有参数提供默认值
   * 3. 确保数据模型的完整性
   * 
   * 参数说明：
   * @param {string} [name=""] - 服务名称，默认空字符串
   * @param {string} [value=""] - 服务值，默认空字符串
   * @param {ResourceStr} [img=""] - 服务图标，默认空字符串
   * @param {Array<ResourceColor>} [background=[]] - 背景颜色数组，默认空数组
   * 
   * 初始化逻辑：
   * 1. 将name参数赋值给this.name
   * 2. 将value参数赋值给this.value
   * 3. 将img参数赋值给this.img
   * 4. 将background参数赋值给this.background
   * 
   * 设计理念：
   * - 所有参数都有默认值，简化使用
   * - 支持渐变背景，增强视觉效果
   * - 简洁的数据结构，易于理解
   * 
   * 使用示例：
   * ```typescript
   * // 创建服务列表项
   * const service = new serviceList(
   *   '云同步',
   *   '同步阅读进度',
   *   'app.media.icon_cloud',
   *   [Color.Blue, Color.LightBlue]
   * );
   * 
   * // 使用默认值创建
   * const defaultService = new serviceList();
   * ```
   * 
   * 字段用途说明：
   * 1. background: 颜色数组，可以创建渐变背景效果，增强UI视觉吸引力
   * 2. img: 图标资源，直观表示服务类型
   * 3. value: 服务值，可以是描述、状态或数值
   * 4. name: 服务名称，用户识别服务功能
   * 
   * 注意事项：
   * - 类名使用小写开头，不符合常规类名规范（应为ServiceList）
   * - 所有参数都有默认值，可以创建空对象
   * - background是Array<ResourceColor>类型，支持渐变背景
   * - img类型为ResourceStr，不是Resource类型，使用时需要注意
   * 
   * 扩展建议：
   * - 可以添加enabled属性控制服务启用状态
   * - 可以添加onClick属性存储点击回调
   * - 可以添加badge属性显示角标（如新功能提示）
   * - 可以添加description属性存储详细描述
   * 
   * @returns {serviceList} 新的服务列表项实例
   */
  constructor(name: string="", value: string="", img: ResourceStr="", background: Array<ResourceColor>=[]) {
    this.name = name
    this.value = value
    this.img = img
    this.background = background
  }
}

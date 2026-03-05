/**
 * @file dataItem.ets
 * @description 通用数据项数据模型类
 * 
 * 功能概述：
 * 1. 定义通用数据项的数据结构
 * 2. 提供灵活的数据类型支持
 * 3. 支持数据观察（@Observed装饰器）
 * 4. 用于各种数据列表展示的数据模型
 * 
 * 使用场景：
 * - 设置项列表数据模型
 * - 配置项列表数据模型
 * - 统计数据显示数据模型
 * - 需要灵活数据类型的通用数据项
 * 
 * 数据字段说明：
 * 1. title: 数据项标题
 *   - 类型：string
 *   - 用途：显示数据项的标题或名称
 * 
 * 2. value: 数据项值
 *   - 类型：number | string
 *   - 用途：存储数据项的具体值
 * 
 * 3. icon: 数据项图标
 *   - 类型：ResourceStr
 *   - 用途：显示数据项的图标资源字符串
 * 
 * 4. type: 数据项类型
 *   - 类型：number | string | boolean
 *   - 用途：标识数据项的类型或分类
 * 
 * 5. status: 数据项状态
 *   - 类型：boolean
 *   - 用途：表示数据项的启用/禁用、选中/未选中等状态
 * 
 * 设计特点：
 * - 使用@Observed装饰器支持数据观察
 * - 灵活的数据类型：value和type支持多种类型
 * - 完整的默认值设置
 * - 通用的数据结构设计
 * 
 * 技术特点：
 * - 使用TypeScript联合类型支持多种数据类型
 * - 使用ResourceStr类型支持图标资源字符串
 * - 使用@Observed装饰器实现数据响应式
 * - 构造函数提供所有参数的默认值
 */

/**
 * @class dataItem
 * @description 通用数据项数据模型类
 * 
 * 类职责：
 * 1. 定义通用数据项的数据结构
 * 2. 支持数据观察和响应式更新
 * 3. 管理数据项的各个字段
 * 4. 提供灵活的默认值设置
 * 
 * @decorator @Observed - 支持数据观察，当数据变化时触发UI更新
 */
@Observed
export class dataItem{
  /** 
   * @property title - 数据项标题
   * @description 数据项的标题或名称，用于显示
   * @default '' - 默认空字符串
   * @type {string}
   */
  title:string

  /** 
   * @property value - 数据项值
   * @description 数据项的具体值，支持数字或字符串类型
   * @default 0 - 默认0
   * @type {number | string}
   */
  value:number|string

  /** 
   * @property icon - 数据项图标
   * @description 数据项的图标资源字符串
   * @default '' - 默认空字符串
   * @type {ResourceStr}
   */
  icon:ResourceStr

  /** 
   * @property type - 数据项类型
   * @description 标识数据项的类型或分类，支持数字、字符串或布尔类型
   * @default 0 - 默认0
   * @type {number | string | boolean}
   */
  type:number|string|boolean

  /** 
   * @property status - 数据项状态
   * @description 表示数据项的启用/禁用、选中/未选中等状态
   * @default false - 默认false
   * @type {boolean}
   */
  status:boolean
  
  /**
   * @constructor dataItem
   * @description 通用数据项数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化数据项的所有字段
   * 2. 为所有参数提供默认值
   * 3. 支持灵活的数据类型
   * 
   * 参数说明：
   * @param {string} [title=''] - 数据项标题，默认空字符串
   * @param {number | string} [value=0] - 数据项值，默认0
   * @param {ResourceStr} [icon=''] - 数据项图标，默认空字符串
   * @param {number | string | boolean} [type=0] - 数据项类型，默认0
   * @param {boolean} [status=false] - 数据项状态，默认false
   * 
   * 初始化逻辑：
   * 1. 将title参数赋值给this.title
   * 2. 将value参数赋值给this.value
   * 3. 将icon参数赋值给this.icon
   * 4. 将type参数赋值给this.type
   * 5. 将status参数赋值给this.status
   * 
   * 设计理念：
   * - 灵活的数据类型设计，适应多种场景
   * - 完整的默认值设置，简化使用
   * - 简洁的构造函数，易于理解
   * - 支持数据观察，实现响应式UI
   * 
   * 使用示例：
   * ```typescript
   * // 创建设置项数据
   * const settingItem = new dataItem(
   *   '夜间模式',
   *   true,
   *   'app.media.icon_night',
   *   'switch',
   *   true
   * );
   * 
   * // 创建统计项数据
   * const statItem = new dataItem(
   *   '阅读时长',
   *   '120小时',
   *   'app.media.icon_time',
   *   'stat',
   *   false
   * );
   * ```
   * 
   * 数据类型说明：
   * 1. value字段：可以是数字（如计数）或字符串（如描述）
   * 2. type字段：可以是数字（类型编码）、字符串（类型名称）或布尔值（类型标识）
   * 3. icon字段：ResourceStr类型，通常是资源字符串，如'app.media.icon_name'
   * 
   * 注意事项：
   * - 类名使用小写开头，不符合常规类名规范（应为DataItem）
   * - 使用@Observed装饰器，确保数据变化时UI能响应更新
   * - type字段类型过于灵活，使用时需要确保类型一致性
   * - icon字段是ResourceStr类型，不是Resource类型，使用时需要注意
   * 
   * 扩展建议：
   * - 可以添加id属性作为唯一标识
   * - 可以添加onClick属性存储点击回调
   * - 可以添加description属性存储详细描述
   * - 可以添加color属性控制显示颜色
   * 
   * @returns {dataItem} 新的数据项实例
   */
  constructor(title:string='',value:number|string=0,icon:ResourceStr='',type:number|string|boolean=0,status:boolean=false){
    this.title=title;
    this.value=value;
    this.icon=icon;
    this.type=type
    this.status=status
  }
}


/**
 * @file SetListGroup.ets
 * @description 设置列表组数据模型类
 * 
 * 功能概述：
 * 1. 定义设置列表组的数据结构
 * 2. 提供设置项和设置组的完整字段定义
 * 3. 包含构造函数和默认值设置
 * 4. 用于设置页面列表展示的数据模型
 * 
 * 使用场景：
 * - 设置页面分组列表数据模型
 * - 配置项分组展示
 * - 需要分组显示设置项的场景
 * - 带有开关、箭头、文字等多样式设置项
 * 
 * 包含两个类：
 * 1. SetGroupList: 设置组类，包含组标题和设置项列表
 * 2. SetList: 设置项类，包含设置项的各个属性和状态
 * 
 * 设计特点：
 * - 使用TypeScript类定义数据模型
 * - 支持分组结构，便于组织设置项
 * - 支持多样式设置项（开关、箭头、文字等）
 * - 使用@Observed装饰器支持数据观察
 */

/**
 * @class SetGroupList
 * @description 设置组列表数据模型类
 * 
 * 类职责：
 * 1. 定义设置组的数据结构
 * 2. 管理组标题和设置项列表
 * 3. 提供构造函数初始化数据
 * 
 * 字段说明：
 */
export class SetGroupList {
  /** 
   * @property groupValue - 组标题
   * @description 设置组的标题或名称
   * @type {string}
   */
  groupValue: string

  /** 
   * @property setList - 设置项列表
   * @description 组内包含的设置项数组
   * @type {SetList[]}
   */
  setList: SetList[]

  /**
   * @constructor SetGroupList
   * @description 设置组列表数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化设置组的所有字段
   * 2. 所有参数均为必需参数
   * 3. 简单的参数赋值逻辑
   * 
   * 参数说明：
   * @param {string} groupValue - 组标题（必需参数）
   * @param {SetList[]} setList - 设置项列表（必需参数）
   * 
   * 初始化逻辑：
   * 1. 将groupValue参数赋值给this.groupValue
   * 2. 将setList参数赋值给this.setList
   * 
   * 设计理念：
   * - 简单的数据结构，易于理解和使用
   * - 所有参数必需，确保数据完整性
   * - 直接参数赋值，无复杂逻辑
   * 
   * 使用示例：
   * ```typescript
   * // 创建设置组
   * const group = new SetGroupList(
   *   '阅读设置',
   *   [
   *     new SetList(true, '夜间模式', true, '', '开启后使用深色主题'),
   *     new SetList(true, '自动翻页', false, '', '根据阅读速度自动翻页')
   *   ]
   * );
   * ```
   * 
   * 注意事项：
   * - 类名符合常规类名规范（首字母大写）
   * - 所有参数都是必需的，没有默认值
   * - setList是SetList对象数组，需要先创建SetList实例
   * 
   * @returns {SetGroupList} 新的设置组实例
   */
  constructor(groupValue: string, setList: SetList[]) {
    this.groupValue = groupValue;
    this.setList = setList;
  }
}

/**
 * @class SetList
 * @description 设置项数据模型类
 * 
 * 类职责：
 * 1. 定义设置项的数据结构
 * 2. 支持多样式设置项（开关、箭头、文字等）
 * 3. 提供构造函数初始化数据
 * 4. 支持数据观察（@Observed装饰器）
 * 
 * @decorator @Observed - 支持数据观察，当数据变化时触发UI更新
 */
@Observed
export class SetList{
  /** 
   * @property showArrow - 是否显示箭头
   * @description 控制设置项右侧是否显示箭头图标
   * - true: 显示箭头，表示可点击进入下级页面
   * - false: 不显示箭头
   * @type {boolean}
   */
  showArrow: boolean

  /** 
   * @property value - 设置项标题
   * @description 设置项的主要标题文本
   * @type {string}
   */
  value: string

  /** 
   * @property toggleStatus - 右边按钮状态
   * @description 设置项右侧开关按钮的状态（可选）
   * - true: 开关开启
   * - false: 开关关闭
   * @type {boolean | undefined}
   */
  toggleStatus?: boolean

  /** 
   * @property rightText - 右边文字
   * @description 设置项右侧显示的文字（可选）
   * 示例：版本号、状态描述等
   * @type {string | undefined}
   */
  rightText?: string

  /** 
   * @property bottomText - 下面文字
   * @description 设置项下方显示的描述文字（可选）
   * 用于详细说明设置项的功能
   * @type {string | undefined}
   */
  bottomText?: string

  /** 
   * @property storageName - 存储名称
   * @description 设置项在本地存储中的键名
   * 用于持久化保存设置项的状态
   * @type {string}
   */
  storageName: string

  /**
   * @constructor SetList
   * @description 设置项数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化设置项的所有字段
   * 2. 为可选参数提供合理的默认值
   * 3. 确保数据模型的完整性
   * 
   * 参数说明：
   * @param {boolean} showArrow - 是否显示箭头（必需参数）
   * @param {string} value - 设置项标题（必需参数）
   * @param {boolean} [toggleStatus] - 右边按钮状态，可选，默认false
   * @param {string} [rightText] - 右边文字，可选，默认空字符串
   * @param {string} [bottomText] - 下面文字，可选，默认空字符串
   * @param {string} [storageName] - 存储名称，可选，默认空字符串
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
   * - 支持数据观察，实现响应式UI
   * 
   * 使用示例：
   * ```typescript
   * // 创建带开关的设置项
   * const toggleItem = new SetList(
   *   false,
   *   '夜间模式',
   *   true,
   *   '',
   *   '开启后使用深色主题',
   *   'night_mode'
   * );
   * 
   * // 创建带箭头的设置项
   * const arrowItem = new SetList(
   *   true,
   *   '关于我们',
   *   undefined,
   *   'v1.0.0',
   *   '',
   *   ''
   * );
   * ```
   * 
   * 字段用途说明：
   * 1. showArrow: 控制是否显示箭头，决定用户是否可以点击进入下级页面
   * 2. toggleStatus: 开关状态，用于布尔类型的设置项
   * 3. rightText: 右侧文字，用于显示状态、版本号等信息
   * 4. bottomText: 底部描述文字，用于详细说明设置项功能
   * 5. storageName: 存储键名，用于将设置项状态保存到本地存储
   * 
   * 注意事项：
   * - 类名符合常规类名规范（首字母大写）
   * - 前2个参数为必需参数，后4个参数为可选参数
   * - 使用@Observed装饰器，确保数据变化时UI能响应更新
   * - toggleStatus、rightText、bottomText、storageName都有默认值
   * - storageName为空字符串时可能不会进行持久化存储
   * 
   * 扩展建议：
   * - 可以添加icon属性显示左侧图标
   * - 可以添加disabled属性控制设置项禁用状态
   * - 可以添加onClick属性存储点击回调
   * - 可以添加type属性区分不同类型的设置项
   * 
   * @returns {SetList} 新的设置项实例
   */
  constructor(
    showArrow: boolean,
    value: string,
    toggleStatus?: boolean,
    rightText?: string,
    bottomText?: string,
    storageName?: string
  ) {
    this.showArrow = showArrow;
    this.value = value;
    this.toggleStatus = toggleStatus || false; // 如果未传入toggleStatus，则默认为false
    this.rightText = rightText || ''; // 如果未传入rightText，则默认为空字符串
    this.bottomText = bottomText || ''; // 如果未传入bottomText，则默认为空字符串
    this.storageName = storageName || '';
  }
}

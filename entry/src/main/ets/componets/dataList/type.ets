/**
 * @file type.ets
 * @description 类型定义文件，包含导航项和主滚动条数据模型类
 * 
 * 功能概述：
 * 1. 定义导航项数据模型类（NavItem）
 * 2. 定义主滚动条数据模型类（MainScrollBar）
 * 3. 提供导航和滚动相关的数据结构定义
 * 4. 包含构造函数和默认值设置
 * 
 * 使用场景：
 * - 底部导航栏数据模型
 * - 选项卡导航数据模型
 * - 滚动条状态管理
 * - 需要管理导航和滚动状态的场景
 * 
 * 包含两个类：
 * 1. NavItem: 导航项类，用于底部导航栏或选项卡
 * 2. MainScrollBar: 主滚动条类，用于管理滚动状态和位置
 * 
 * 设计特点：
 * - 使用TypeScript类定义数据模型
 * - 提供详细的字段注释
 * - 构造函数支持默认值
 * - 合理的默认值设置
 */

/**
 * @class NavItem
 * @description 导航项数据模型类
 * 
 * 类职责：
 * 1. 定义导航项的数据结构
 * 2. 管理导航项的选中状态和样式
 * 3. 提供构造函数初始化数据
 * 
 * 字段说明：
 */
export class NavItem {
  /** 
   * @property selectImg - 选中图片
   * @description 导航项被选中时显示的图片资源
   * @type {Resource}
   */
  selectImg:Resource

  /** 
   * @property unselected - 未选中图片
   * @description 导航项未选中时显示的图片资源
   * @type {Resource}
   */
  unselected:Resource

  /** 
   * @property isSelect - 是否选择
   * @description 标识导航项是否被选中
   * @default false - 默认未选中
   * @type {boolean}
   */
  isSelect:boolean = false

  /** 
   * @property title - 标题
   * @description 导航项显示的标题文本
   * @type {string}
   */
  title:string

  /** 
   * @property index - 索引
   * @description 导航项的索引位置，用于标识和排序
   * @type {number}
   */
  index:number

  /**
   * @constructor NavItem
   * @description 导航项数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化导航项的所有字段
   * 2. 为可选参数提供合理的默认值
   * 3. 确保数据模型的完整性
   * 
   * 参数说明：
   * @param {number} [index=0] - 索引，默认0
   * @param {Resource} selectImg - 选中图片（必需参数）
   * @param {Resource} unselected - 未选中图片（必需参数）
   * @param {string} [title=''] - 标题，默认空字符串
   * 
   * 初始化逻辑：
   * 1. 将index参数赋值给this.index
   * 2. 将selectImg参数赋值给this.selectImg
   * 3. 将unselected参数赋值给this.unselected
   * 4. 将title参数赋值给this.title
   * 5. isSelect字段使用默认值false
   * 
   * 设计理念：
   * - 必需参数在前，可选参数在后
   * - 为可选参数提供合理的默认值
   * - 默认值符合常见使用场景
   * - 支持动态切换选中状态
   * 
   * 使用示例：
   * ```typescript
   * // 创建导航项
   * const navItem = new NavItem(
   *   0,
   *   $r('app.media.home_selected'),
   *   $r('app.media.home_unselected'),
   *   '首页'
   * );
   * 
   * // 切换选中状态
   * navItem.isSelect = true;
   * ```
   * 
   * 字段用途说明：
   * 1. selectImg/unselected: 根据选中状态显示不同的图标，增强用户体验
   * 2. isSelect: 控制选中状态，通常只有一个导航项被选中
   * 3. index: 用于标识导航项位置，便于排序和查找
   * 4. title: 显示导航项名称，帮助用户识别功能
   * 
   * 注意事项：
   * - 类名符合常规类名规范（首字母大写）
   * - selectImg和unselected为必需参数，index和title有默认值
   * - isSelect字段在构造函数中未初始化，使用默认值false
   * - 图片资源类型为Resource，需要使用$r()函数加载资源
   * 
   * 扩展建议：
   * - 可以添加badge属性显示角标（如消息数量）
   * - 可以添加disabled属性控制导航项禁用状态
   * - 可以添加onClick属性存储点击回调
   * - 可以添加color属性控制选中/未选中颜色
   * 
   * @returns {NavItem} 新的导航项实例
   */
  constructor(index = 0 ,selectImg:Resource,unselected:Resource ,title = '') {
    this.selectImg = selectImg
    this.unselected = unselected
    this.title = title
    this.index = index
  }
}

/**
 * @class MainScrollBar
 * @description 主滚动条数据模型类
 * 
 * 类职责：
 * 1. 定义滚动条状态的数据结构
 * 2. 管理滚动位置和滚动状态
 * 3. 提供构造函数初始化数据
 * 
 * 字段说明：
 */
export class MainScrollBar {
  /** 
   * @property isStop - 是否停止滚动
   * @description 标识滚动条是否停止滚动
   * @type {boolean}
   */
  isStop:boolean
  
  /** 
   * @property yOffsetTop - Y轴偏移顶部距离
   * @description 滚动条距离顶部的垂直偏移量
   * @default 0 - 默认在顶部
   * @type {number}
   */
  yOffsetTop:number = 0
  
  /** 
   * @property isScroll - 滚动控制器
   * @description 滚动条的控制器对象，用于控制滚动行为
   * @type {Scroller}
   */
  isScroll:Scroller

  /**
   * @constructor MainScrollBar
   * @description 主滚动条数据模型构造函数
   * 
   * 功能说明：
   * 1. 初始化滚动条的所有字段
   * 2. 为可选参数提供合理的默认值
   * 3. 确保数据模型的完整性
   * 
   * 参数说明：
   * @param {boolean} isStop - 是否停止滚动（必需参数）
   * @param {Scroller} isScroll - 滚动控制器（必需参数）
   * @param {number} [yOffsetTop=0] - Y轴偏移顶部距离，默认0
   * 
   * 初始化逻辑：
   * 1. 将isStop参数赋值给this.isStop
   * 2. 将yOffsetTop参数赋值给this.yOffsetTop
   * 3. 将isScroll参数赋值给this.isScroll
   * 
   * 设计理念：
   * - 必需参数在前，可选参数在后
   * - 为可选参数提供合理的默认值
   * - 默认值符合常见使用场景
   * - 封装滚动状态，便于统一管理
   * 
   * 使用示例：
   * ```typescript
   * // 创建滚动条状态
   * const scrollBar = new MainScrollBar(
   *   false,
   *   new Scroller(),
   *   100
   * );
   * 
   * // 停止滚动
   * scrollBar.isStop = true;
   * ```
   * 
   * 字段用途说明：
   * 1. isStop: 控制滚动条是否允许滚动，可用于实现滚动锁定
   * 2. yOffsetTop: 记录滚动位置，便于恢复滚动状态或实现滚动到指定位置
   * 3. isScroll: 滚动控制器，用于执行滚动操作和控制滚动行为
   * 
   * 注意事项：
   * - 类名符合常规类名规范（首字母大写）
   * - isStop和isScroll为必需参数，yOffsetTop有默认值
   * - isScroll类型为Scroller，是ArkTS的滚动控制器类
   * - yOffsetTop单位通常是像素(px)
   * 
   * 扩展建议：
   * - 可以添加xOffsetLeft属性记录水平滚动位置
   * - 可以添加scrollSpeed属性控制滚动速度
   * - 可以添加scrollDirection属性记录滚动方向
   * - 可以添加scrollListener属性添加滚动监听器
   * 
   * @returns {MainScrollBar} 新的滚动条实例
   */
  constructor(isStop:boolean,isScroll:Scroller,yOffsetTop:number = 0) {
    this.isStop = isStop
    this.yOffsetTop = yOffsetTop
    this.isScroll = isScroll
  }
}

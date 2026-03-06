/**
 * @file BookType.ets
 * @description 书籍类型组件
 * 
 * 功能概述：
 * 1. 显示书籍类型标签
 * 2. 支持选中状态的视觉反馈
 * 3. 提供圆角卡片式设计
 * 
 * 使用场景：
 * - 书籍分类筛选标签
 * - 类型选择按钮
 * - 需要突出显示当前选中类型的场景
 * 
 * 设计特点：
 * - 简洁的卡片式设计
 * - 选中状态有颜色和背景变化
 * - 统一的圆角和内边距
 * - 响应式背景色切换
 * 
 * 组件结构：
 * 1. Column容器：包裹文本内容，设置圆角和内边距
 * 2. Text文本：显示类型标题，根据选中状态应用不同颜色
 * 
 * 技术特点：
 * - 使用@Prop装饰器接收父组件数据
 * - 使用@StorageProp装饰器获取主题配置
 * - 使用条件渲染实现状态切换
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"

/**
 * @class BookType
 * @description 书籍类型组件
 * 
 * 组件职责：
 * 1. 显示书籍类型标签
 * 2. 根据选中状态应用不同样式
 * 3. 提供卡片式的视觉设计
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct BookType {
  /** 
   * @prop title - 标题文本
   * @description 类型显示的文本内容，从父组件传入
   * @type {string}
   */
  @Prop title:string
  
  /** 
   * @prop bookType - 书籍类型
   * @description 书籍类型标识，从父组件传入（当前未使用）
   * @type {string}
   */
  @Prop bookType:string
  
  /** 
   * @prop index - 当前类型索引
   * @description 当前类型的索引值，用于判断是否被选中，从父组件传入
   * @type {number}
   */
  @Prop index:number
  
  /** 
   * @prop bookTypeNumber - 书籍类型编号
   * @description 当前选中的书籍类型编号，从父组件传入
   * @default 0 - 默认第一个类型
   * @type {number}
   */
  @Prop bookTypeNumber:number = 0

  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method build
   * @description 构建书籍类型组件UI
   * 
   * 布局逻辑：
   * 1. Column容器：包裹文本内容，设置圆角和内边距
   * 2. Text文本：显示类型标题
   * 
   * 样式逻辑：
   * 1. 文字颜色：
   *    - 选中状态：主题主色（theme.mainColor）
   *    - 未选中状态：80%黑色（rgba(0,0,0,0.8)）
   * 2. 字体大小：固定12px
   * 3. 字体字重：固定700（粗体），选中和未选中状态相同
   * 4. 背景颜色：
   *    - 选中状态：主题次色（theme.secondColor）
   *    - 未选中状态：浅灰色（rgb(240,240,240)）
   * 5. 容器样式：
   *    - 圆角：8px
   *    - 内边距：8px
   * 
   * 选中状态判断：
   * - 条件：this.index === this.bookTypeNumber
   * - 当当前类型的索引等于选中的书籍类型编号时，应用选中样式
   * 
   * 设计理念：
   * - 简洁明了：专注于类型选择和状态显示
   * - 视觉层次：选中状态通过颜色和背景明显区分
   * - 统一设计：所有类型标签保持相同的尺寸和样式
   * - 响应式：状态变化即时反映在视觉上
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中使用
   * BookType({
   *   title: '小说',
   *   bookType: 'novel',
   *   index: 0,
   *   bookTypeNumber: this.selectedType
   * })
   * 
   * BookType({
   *   title: '漫画',
   *   bookType: 'comic',
   *   index: 1,
   *   bookTypeNumber: this.selectedType
   * })
   * ```
   * 
   * 颜色说明：
   * 1. theme.mainColor: 主题主色，用于选中状态的文字
   * 2. theme.secondColor: 主题次色，用于选中状态的背景
   * 3. rgba(0, 0, 0, 0.80): 80%黑色，用于未选中状态的文字
   * 4. rgb(240, 240, 240): 浅灰色，用于未选中状态的背景
   * 
   * 字体说明：
   * - 固定12px字体，700字重（粗体）
   * - 选中和未选中状态字重相同，仅颜色不同
   * 
   * 容器说明：
   * - 圆角：8px，提供卡片式视觉效果
   * - 内边距：8px，确保文字与边框有适当间距
   * 
   * 注意事项：
   * - bookType参数在当前组件中未使用，但保留以备扩展
   * - 字体字重在选中和未选中状态都是700，可考虑差异化设计
   * - 需要导入ThemeStorageKey和ThemeItem
   * 
   * 扩展建议：
   * - 可以添加点击事件回调
   * - 可以添加禁用状态
   * - 可以添加图标支持
   * - 可以添加动画过渡效果
   * - 可以调整选中和未选中状态的字重差异
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Text(this.title)
        .fontColor(this.index === this.bookTypeNumber ? this.theme.mainColor :  'rgba(0,0,0,0.8)')
        .fontSize(12)
        .fontWeight(this.index === this.bookTypeNumber ? 700 : 700)
    }
    .borderRadius(8)
    .padding(8)
    .backgroundColor(this.index === this.bookTypeNumber? this.theme.secondColor:'rgb(240,240,240)')
  }
}

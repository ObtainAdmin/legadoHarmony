/**
 * @file BookMark.ets
 * @description 书签组件
 * 
 * 功能概述：
 * 1. 显示可切换的书签标签
 * 2. 支持两种显示模式：主题背景模式和普通模式
 * 3. 提供选中状态的视觉反馈
 * 4. 支持平滑的动画过渡效果
 * 
 * 使用场景：
 * - 选项卡导航栏中的标签
 * - 分类切换按钮
 * - 需要高亮显示当前选中项的场景
 * 
 * 设计特点：
 * - 支持两种颜色模式：主题色模式和黑白模式
 * - 选中状态有显著的视觉变化（颜色、字体大小、字重）
 * - 提供平滑的动画过渡效果
 * - 支持自定义边距设置
 * 
 * 组件结构：
 * 1. Column容器：包裹文本内容
 * 2. 条件渲染：根据isBackground选择显示模式
 * 3. Text文本：显示标题，根据选中状态应用不同样式
 * 
 * 技术特点：
 * - 使用@Prop装饰器接收父组件数据
 * - 使用@StorageProp装饰器获取主题配置
 * - 使用条件渲染优化性能
 * - 使用动画效果增强用户体验
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"

/**
 * @class BookMark
 * @description 书签组件
 * 
 * 组件职责：
 * 1. 显示书签标签文本
 * 2. 根据选中状态应用不同样式
 * 3. 支持两种显示模式切换
 * 4. 提供平滑的动画效果
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct BookMark {
  /** 
   * @prop isBackground - 是否使用背景模式
   * @description 控制书签的显示模式：true使用主题色，false使用黑白模式
   * @default true - 默认使用主题背景模式
   * @type {boolean}
   */
  isBackground: boolean = true
  
  /** 
   * @prop title - 标题文本
   * @description 书签显示的文本内容，从父组件传入
   * @type {string}
   */
  @Prop title:string
  
  /** 
   * @prop currentIndex - 当前索引
   * @description 当前选中的索引值，从父组件传入
   * @type {number}
   */
  @Prop currentIndex:number
  
  /** 
   * @prop index - 当前书签索引
   * @description 当前书签的索引值，用于判断是否被选中，从父组件传入
   * @type {number}
   */
  @Prop index:number

  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method build
   * @description 构建书签组件UI
   * 
   * 布局逻辑：
   * 1. Column容器：包裹文本内容，设置边距
   * 2. 条件判断：根据isBackground选择显示模式
   * 
   * 主题背景模式（isBackground为true）：
   * - 选中状态：主题主色，25px字体，700字重
   * - 未选中状态：主题次色，16px字体，500字重
   * - 动画：200ms过渡动画
   * - zIndex：999确保在最上层
   * - 注释掉的背景图片功能：可用于添加下划线效果
   * 
   * 普通模式（isBackground为false）：
   * - 选中状态：100%黑色，25px字体，700字重
   * - 未选中状态：50%黑色，16px字体，500字重
   * - 动画：200ms过渡动画
   * - zIndex：999确保在最上层
   * 
   * 边距设置：
   * - 第一个书签（index为0）：左右边距为0
   * - 其他书签：左边距20px
   * 
   * 交互逻辑：
   * 1. 选中状态判断：currentIndex === index
   * 2. 样式切换：根据选中状态动态改变颜色、字体大小、字重
   * 3. 动画效果：所有样式变化都有200ms的平滑过渡
   * 
   * 设计理念：
   * - 清晰的视觉层次：选中状态明显区别于未选中状态
   * - 灵活的显示模式：支持主题色和黑白两种模式
   * - 平滑的交互体验：所有状态变化都有动画过渡
   * - 合理的布局间距：第一个书签无左边距，其他书签有间距
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中使用
   * BookMark({
   *   title: '首页',
   *   currentIndex: this.currentTab,
   *   index: 0,
   *   isBackground: true
   * })
   * 
   * BookMark({
   *   title: '书架',
   *   currentIndex: this.currentTab,
   *   index: 1,
   *   isBackground: true
   * })
   * ```
   * 
   * 颜色说明：
   * 1. theme.mainColor: 主题主色，用于选中状态的主题模式
   * 2. theme.secondColor: 主题次色，用于未选中状态的主题模式
   * 3. rgba(0, 0, 0, 1.00): 100%黑色，用于选中状态的普通模式
   * 4. rgba(0, 0, 0, 0.50): 50%黑色，用于未选中状态的普通模式
   * 
   * 字体说明：
   * 1. 选中状态：25px字体，700字重（粗体）
   * 2. 未选中状态：16px字体，500字重（中等）
   * 
   * 注意事项：
   * - 背景图片功能被注释掉，可根据需要启用
   * - zIndex设置为999，确保书签在最上层显示
   * - 动画duration为200ms，提供平滑的过渡效果
   * - 需要导入ThemeStorageKey和ThemeItem
   * 
   * 扩展建议：
   * - 可以添加点击事件回调
   * - 可以添加禁用状态
   * - 可以添加图标支持
   * - 可以添加角标功能（如未读数量）
   * 
   * @returns {void}
   */
  build() {
    Column() {
      if (this.isBackground) {
        Text(this.title)
          .fontColor(this.currentIndex === this.index ? this.theme.mainColor : this.theme.secondColor)
          .fontSize(this.currentIndex === this.index ? 25 : 16)
          .fontWeight(this.currentIndex === this.index ? 700 : 500)
          .lineHeight(30)
          .zIndex(999)
          // .backgroundImage(this.currentIndex === this.index ? $r('app.media.underline') : '')
          // .backgroundImageSize(this.currentIndex === this.index ? { width: '100%', height: 15 } : {})
          // .backgroundImagePosition(Alignment.Center)
          .animation({
            duration: 200,
          })
      } else {
        Text(this.title)
          .fontColor(this.currentIndex === this.index ? 'rgba(0, 0, 0, 1.00)' :  'rgba(0,0,0,0.5)')
          .fontSize(this.currentIndex === this.index ? 25 :  16)
          .fontWeight(this.currentIndex === this.index ? 700 : 500)
          .lineHeight(30).zIndex(999)
          .animation({
            duration: 200,
          })
      }
    }
    .margin(this.index !== 0 ? { left: 20 } : {
      left: 0,
      right: 0
    })
  }
}

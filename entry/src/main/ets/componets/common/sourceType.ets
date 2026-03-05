/**
 * @file sourceType.ets
 * @description 源类型标签组件
 * 
 * 功能概述：
 * 1. 显示源类型标签（如小说、漫画、有声书等）
 * 2. 支持激活状态的视觉反馈
 * 3. 提供平滑的激活状态切换动画
 * 4. 使用主题颜色配置
 * 
 * 使用场景：
 * - 源类型筛选标签
 * - 分类切换标签
 * - 需要激活状态指示的标签组件
 * 
 * 设计特点：
 * - 激活状态时显示底部指示条
 * - 文字颜色和字重根据激活状态变化
 * - 使用平滑的缩放动画
 * - 支持主题颜色配置
 * 
 * 激活状态样式：
 * 1. 文字样式：
 *   - 颜色：color_black_88（深色）
 *   - 字重：700（加粗）
 * 
 * 2. 非激活状态样式：
 *   - 颜色：color_black_45（浅色）
 *   - 字重：400（正常）
 * 
 * 3. 底部指示条：
 *   - 尺寸：12x3px
 *   - 颜色：主题主色
 *   - 圆角：4px
 *   - 动画：600ms缩放动画
 * 
 * 动画特点：
 * - 使用缩放动画（scale）
 * - 动画曲线：CommonConstants.UniCurve
 * - 持续时间：600ms
 * - 同时控制可见性和不透明度
 * 
 * 技术特点：
 * - 使用项目常量统一字体和动画配置
 * - 支持主题颜色配置
 * - 使用Visibility和Opacity控制显示
 */

import CommonConstants from '../../common/constants/CommonConstants'
import FontConstants from '../../common/constants/FontConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'

/**
 * @class sourceType
 * @description 源类型标签组件
 * 
 * 组件职责：
 * 1. 根据激活状态显示不同的样式
 * 2. 管理底部指示条的动画
 * 3. 应用主题颜色配置
 * 4. 使用项目常量确保样式一致性
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct sourceType {
  /** 
   * @prop title - 标签文本
   * @description 显示的源类型文本（如"小说"、"漫画"等）
   * @type {string}
   */
  @Prop title: string
  
  /** 
   * @prop active - 激活状态
   * @description 控制标签是否处于激活状态
   * @type {boolean}
   */
  @Prop active: boolean
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * @method build
   * @description 构建源类型标签UI
   * 
   * 布局结构：
   * 1. 外层Column：垂直布局容器
   * 2. 内层Text：标签文本
   * 3. 内层Row：底部指示条
   * 
   * 文本样式：
   * - 内容：title属性
   * - 字体大小：18px
   * - 颜色：激活时color_black_88，非激活时color_black_45
   * - 字重：激活时700（加粗），非激活时400（正常）
   * 
   * 底部指示条样式：
   * - 尺寸：12x3px
   * - 背景色：主题主色
   * - 圆角：4px
   * - 可见性：激活时可见，非激活时隐藏
   * - 不透明度：激活时1，非激活时0
   * 
   * 动画配置：
   * - 缩放：激活时缩放为1，非激活时缩放为0
   * - 缩放中心：50%中心点
   * - 持续时间：600ms
   * - 动画曲线：CommonConstants.UniCurve（统一曲线）
   * 
   * 容器样式：
   * - 垂直间距：2px（文本和指示条之间）
   * - 顶部内边距：7px
   * 
   * 设计理念：
   * - 通过颜色和字重区分激活状态
   * - 使用底部指示条提供明确的视觉反馈
   * - 平滑的动画增强用户体验
   * - 简洁的设计，不占用过多空间
   * 
   * 状态切换效果：
   * 1. 激活 -> 非激活：
   *   - 文字颜色变浅，字重变正常
   *   - 指示条缩放为0并隐藏
   * 
   * 2. 非激活 -> 激活：
   *   - 文字颜色变深，字重加粗
   *   - 指示条缩放为1并显示
   * 
   * 动画细节：
   * - 同时使用visibility、opacity和scale控制显示
   * - 确保动画平滑无闪烁
   * - 使用统一的动画曲线保持一致性
   * 
   * 使用示例：
   * ```typescript
   * // 激活状态
   * sourceType({ title: '小说', active: true })
   * 
   * // 非激活状态
   * sourceType({ title: '漫画', active: false })
   * ```
   * 
   * 注意事项：
   * - 指示条使用主题主色，确保与整体设计一致
   * - 动画持续时间较长（600ms），提供明显的过渡效果
   * - 使用资源文件中的颜色定义，确保主题一致性
   * 
   * @returns {void}
   */
  build() {
    Column({
      space: 2
    }) {
      Text(this.title)
        .fontColor(this.active ? $r('app.string.color_black_88') : $r('app.string.color_black_45'))
        .fontSize(18)
        .fontWeight(this.active ? FontConstants.FONT_WEIGHT_700 : FontConstants.FONT_WEIGHT_400)
      Row()
        .width(12)
        .height(3)
        .borderRadius(4)
        .backgroundColor(this.theme.mainColor)
        .visibility(this.active ? Visibility.Visible : Visibility.Hidden)
        .opacity(this.active ? 1 : 0)
        .scale({
          centerX: "50%",
          centerY: "50%",
          x: this.active ? 1 : 0,
          y: this.active ? 1 : 0,
        })
        .animation({
          duration: 600,
          curve: CommonConstants.UniCurve
        })
    }
    .padding({ top: 7 })
  }
}

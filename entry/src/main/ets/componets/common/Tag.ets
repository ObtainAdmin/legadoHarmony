/**
 * @file Tag.ets
 * @description 标签组件
 * 
 * 功能概述：
 * 1. 显示简单的文本标签
 * 2. 支持自定义文字颜色和背景色
 * 3. 提供统一的标签样式
 * 4. 简洁的胶囊形状设计
 * 
 * 使用场景：
 * - 分类标签显示
 * - 状态标签（如"热门"、"推荐"等）
 * - 简单的文本标记
 * - 需要自定义颜色的标签
 * 
 * 设计特点：
 * - 胶囊形状（圆角矩形）
 * - 固定高度：16px
 * - 小字体：10px
 * - 左右内边距：6px
 * - 左边距：8px（与其他元素的间距）
 * 
 * 样式特点：
 * 1. 容器样式：
 *   - 高度：16px固定高度
 *   - 内边距：左右6px
 *   - 圆角：4px（胶囊形状）
 *   - 对齐：垂直居中
 *   - 外边距：左边8px
 * 
 * 2. 文本样式：
 *   - 字体大小：10px
 *   - 颜色：通过color属性自定义
 *   - 背景色：通过bgColor属性自定义
 * 
 * 自定义能力：
 * - text：标签显示文本
 * - color：文字颜色（ResourceColor类型）
 * - bgColor：背景颜色（ResourceColor类型）
 * 
 * 技术特点：
 * - 使用ResourceColor类型支持多种颜色格式
 * - 简单的Column+Text布局
 * - 无外部依赖，独立组件
 */

/**
 * @class Tag
 * @description 标签组件
 * 
 * 组件职责：
 * 1. 显示自定义文本标签
 * 2. 应用自定义颜色样式
 * 3. 提供统一的标签布局
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct Tag {
  /** 
   * @prop text - 标签文本
   * @description 标签显示的文本内容
   * @default '' - 默认空字符串
   * @type {string}
   */
  text: string = ''
  
  /** 
   * @prop color - 文字颜色
   * @description 标签文字的颜色，支持ResourceColor类型
   * @default '' - 默认空字符串（使用系统默认颜色）
   * @type {ResourceColor}
   */
  color: ResourceColor = ''
  
  /** 
   * @prop bgColor - 背景颜色
   * @description 标签背景的颜色，支持ResourceColor类型
   * @default '' - 默认空字符串（使用系统默认颜色）
   * @type {ResourceColor}
   */
  bgColor: ResourceColor = ''
  
  /**
   * @method build
   * @description 构建标签组件UI
   * 
   * 布局结构：
   * 1. 外层Column：垂直布局容器
   * 2. 内层Text：标签文本
   * 
   * 文本样式：
   * - 内容：text属性
   * - 字体大小：10px（小字体）
   * - 颜色：color属性
   * 
   * 容器样式：
   * - 高度：16px固定高度（紧凑设计）
   * - 内边距：左右6px（确保文本有适当间距）
   * - 圆角：4px（胶囊形状）
   * - 对齐：垂直居中（FlexAlign.Center）
   * - 背景色：bgColor属性
   * - 外边距：左边8px（与其他元素保持间距）
   * 
   * 设计理念：
   * - 紧凑的尺寸，适合内联显示
   * - 胶囊形状提供现代感
   * - 通过颜色自定义实现灵活性
   * - 简单的API，易于使用
   * 
   * 使用示例：
   * ```typescript
   * // 红色文字，浅红色背景的标签
   * Tag({ text: '热门', color: Color.Red, bgColor: 0xFFE0E0 })
   * 
   * // 蓝色文字，浅蓝色背景的标签
   * Tag({ text: '推荐', color: Color.Blue, bgColor: 0xE0E0FF })
   * ```
   * 
   * 颜色支持：
   * - 十六进制颜色：0xFF0000
   * - 颜色常量：Color.Red
   * - 资源颜色：$r('app.string.color_red')
   * - 字符串颜色：'#FF0000'
   * 
   * 注意事项：
   * - 组件没有使用@Prop装饰器，属性是普通成员变量
   * - 颜色属性使用ResourceColor类型，支持多种颜色格式
   * - 默认颜色为空字符串，需要使用时必须提供
   * - 高度固定为16px，适合单行文本
   * 
   * 扩展建议：
   * - 可以添加边框颜色和宽度属性
   * - 可以添加字体大小和字重属性
   * - 可以添加点击事件支持
   * - 可以添加禁用状态
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Text(this.text)
        .fontSize(10)
        .fontColor(this.color)
    }
    .height(16)
    .margin({ left: 8 })
    .padding({ left: 6, right: 6 })
    .borderRadius(4)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.bgColor)
  }
}

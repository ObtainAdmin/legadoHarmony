/**
 * @file InsideCircleIcon.ets
 * @description 内部圆形图标组件
 * 
 * 功能概述：
 * 1. 显示圆形图标和标题文本
 * 2. 提供统一的圆形图标样式
 * 3. 支持自定义图标和标题
 * 
 * 使用场景：
 * - 功能菜单中的图标按钮
 * - 工具选项的图标展示
 * - 需要图标+文字组合的展示场景
 * 
 * 设计特点：
 * - 圆形图标容器设计
 * - 图标和文字垂直排列
 * - 统一的边框和圆角样式
 * - 使用资源文件中的颜色配置
 * - 底部有固定的内边距
 * 
 * 样式特点：
 * - 圆形容器：50圆角（完全圆形），0.5px浅灰色边框
 * - 图标：24x24大小，12px内边距（通过margin实现）
 * - 文字：12px字体，400字重，20px行高，使用资源颜色
 * - 整体：垂直间距8px，居中对齐，底部内边距28px
 * 
 * 与CircleIcon组件的区别：
 * - 底部内边距不同（InsideCircleIcon有28px底部内边距）
 * - 图标容器样式相同
 * - 文字样式相同
 */

/**
 * @class InsideCircleIcon
 * @description 内部圆形图标组件
 * 
 * 组件职责：
 * 1. 展示图标和标题组合
 * 2. 提供统一的圆形图标样式
 * 3. 支持自定义图标和标题
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct InsideCircleIcon{
  /** 
   * @prop icon - 图标资源
   * @description 圆形图标容器中显示的图标资源
   * @type {Resource}
   */
  @Prop icon:Resource
  
  /** 
   * @prop title - 标题文本
   * @description 图标下方显示的标题文本
   * @type {string}
   */
  @Prop title:string
  
  /**
   * @method build
   * @description 构建内部圆形图标UI
   * 
   * 布局结构：
   * 1. 顶部：圆形图标容器（包含图标）
   * 2. 底部：标题文本
   * 
   * 样式特点：
   * - 圆形容器：50圆角（完全圆形），0.5px浅灰色边框
   * - 图标：24x24大小，12px内边距（通过margin实现）
   * - 文字：12px字体，400字重，20px行高，使用资源颜色（color_black_65）
   * - 整体：垂直间距8px，居中对齐，底部内边距28px
   * 
   * 颜色配置：
   * - 使用资源文件中的颜色定义（$r('app.string.color_black_65')）
   * - 确保颜色主题一致性
   * 
   * 边框样式：
   * - 宽度：0.5px
   * - 颜色：15%黑色（rgba(0, 0, 0, 0.15)）
   * - 样式：实线边框
   * 
   * 内边距设计：
   * - 图标内边距：12px（通过margin实现，使图标居中）
   * - 组件底部内边距：28px（用于布局间距）
   * - 图标和文字间距：8px
   * 
   * 对齐方式：
   * - 水平居中对齐（HorizontalAlign.Center）
   * - 垂直排列（Column布局）
   * 
   * 设计理念：
   * - 简洁的图标+文字组合
   * - 统一的圆形设计语言
   * - 使用资源文件确保颜色一致性
   * 
   * @returns {void}
   */
  build() {
    Column({
      space:8
    }){
      Column(){
        Image(this.icon)
          .width(24)
          .height(24)
          .margin(12)
      }
      .borderRadius(50)
      .border({width:0.5,color:'rgba(0, 0, 0, 0.15)'})

      Text(this.title)
        .fontColor($r('app.string.color_black_65'))
        .fontSize(12)
        .fontWeight(400)
        .lineHeight(20)
    }
    .alignItems(HorizontalAlign.Center)
    .padding({bottom:28})
  }
}

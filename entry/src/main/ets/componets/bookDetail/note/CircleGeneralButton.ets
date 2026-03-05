/**
 * @file CircleGeneralButton.ets
 * @description 圆形通用按钮组件
 * 
 * 功能概述：
 * 1. 显示圆形图标按钮
 * 2. 提供按钮文字说明
 * 3. 支持自定义图标和文本
 * 
 * 使用场景：
 * - 功能操作按钮（如编辑、删除、分享等）
 * - 工具菜单中的图标按钮
 * - 需要图标+文字组合的按钮场景
 * 
 * 设计特点：
 * - 圆形图标容器设计
 * - 图标和文字垂直排列
 * - 统一的边框和圆角样式
 * - 支持自定义颜色主题
 * 
 * @copyright (C), 2024-05-15
 * @author LinXun
 * @date 2024/5/15 13:03
 * @version 1.0
 */

/**
 * @class CircleGeneralButton
 * @description 圆形通用按钮组件
 * 
 * 组件职责：
 * 1. 展示图标和文字组合的按钮
 * 2. 提供统一的圆形按钮样式
 * 3. 支持自定义图标和文本内容
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct CircleGeneralButton {
  /** 
   * @private icon - 按钮图标资源
   * @description 按钮中显示的图标，使用ResourceStr类型
   * @default $r('app.media.ic_public_edit') - 编辑图标
   * @type {ResourceStr}
   */
  private icon: ResourceStr = $r('app.media.ic_public_edit');
  
  /** 
   * @private text - 按钮文字
   * @description 按钮下方显示的文字说明
   * @default '编辑' - 示例文字
   * @type {string}
   */
  private text: string = '编辑';
  
  /**
   * @method build
   * @description 构建圆形按钮UI
   * 
   * 布局结构：
   * 1. 顶部：圆形图标容器（包含图标）
   * 2. 底部：按钮文字说明
   * 
   * 样式特点：
   * - 圆形容器：白色背景，0.5px灰色边框，200圆角（完全圆形）
   * - 图标：24x24大小，深灰色填充
   * - 文字：12px字体，深灰色，20px行高
   * - 整体：垂直间距8px，固定高度118px
   * - 内边距：顶部16px，底部12px
   * 
   * @returns {void}
   */
  build() {
    Column({space: 8}) {
      Column() {
        Image(this.icon)
          .width(24)
          .height(24)
          .fillColor('#a6000000')
      }
      .backgroundColor('#FFFFFF')
      .padding({
        left: 12,
        right: 12,
        top: 12,
        bottom: 12
      })
      .border({
        width: 0.5,
        color: '#26000000'
      })
      .borderRadius(200)
      Text(this.text)
        .fontSize(12)
        .fontWeight(400)
        .lineHeight(20)
        .fontColor('#a6000000')
    }
    .padding({top: 16, bottom: 12})
    .height(118)
  }
}

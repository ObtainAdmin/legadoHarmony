/**
 * @file dialogTitleFuction.ets
 * @description 对话框标题功能组件
 * 
 * 功能概述：
 * 1. 提供标准化的对话框标题样式
 * 2. 支持图标+文本组合显示
 * 3. 可选显示底部边框
 * 4. 使用项目常量统一样式
 * 
 * 使用场景：
 * - 对话框的标题区域
 * - 弹窗的标题显示
 * - 需要图标和文本组合的标题场景
 * 
 * 设计特点：
 * - 使用项目常量统一字体、图片、内边距等样式
 * - 支持可选图标显示
 * - 可选底部边框
 * - 居中对齐布局
 * 
 * 样式特点：
 * - 字体：14px，400字重，PingFANG字体
 * - 颜色：使用资源文件中的color_black_88
 * - 行高：22px（使用项目常量）
 * - 图标：20x20px（使用项目常量）
 * - 内边距：上下12px，左右20px（使用项目常量）
 * - 边框：可选1px浅灰色底部边框
 * 
 * @author 2008
 * @datetime 2024/6/28 22:24
 */

import CommonConstants from '../../common/constants/CommonConstants'
import FontConstants from '../../common/constants/FontConstants'
import ImageConstants from '../../common/constants/ImageConstants'
import PaddingConstants from '../../common/constants/PaddingConstants'
import TextConstants from '../../common/constants/TextConstants'

/**
 * @class dialogTitleFuction
 * @description 对话框标题功能组件
 * 
 * 组件职责：
 * 1. 提供标准化的对话框标题样式
 * 2. 管理图标和文本的组合显示
 * 3. 控制底部边框显示
 * 4. 应用项目常量确保样式一致性
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct dialogTitleFuction{
  /** 
   * @prop isBorder - 是否显示边框
   * @description 控制是否在标题底部显示边框
   * @default true - 默认显示边框
   * @type {boolean}
   */
  isBorder: boolean = true
  
  /** 
   * @prop title - 标题文本
   * @description 对话框中显示的标题文本
   * @type {string}
   */
  @Prop title:string
  
  /** 
   * @prop icon - 图标资源
   * @description 标题左侧显示的图标资源，可选
   * @type {Resource}
   */
  @Prop icon:Resource
  
  /**
   * @method build
   * @description 构建对话框标题UI
   * 
   * 布局结构：
   * 1. 外层Column：控制整体内边距
   * 2. 内层Row：包含图标和文本
   *   - 左侧：可选图标
   *   - 右侧：标题文本
   * 
   * 条件渲染：
   * - 根据icon属性决定是否显示图标
   * - 根据isBorder决定是否显示底部边框
   * 
   * 图标样式：
   * - 尺寸：20x20px（使用项目常量）
   * - 图标和文本间距：8px
   * 
   * 文本样式：
   * - 字体：14px，400字重（使用项目常量）
   * - 字体家族：PingFANG（使用项目常量）
   * - 颜色：使用资源文件中的color_black_88
   * - 行高：22px（使用项目常量）
   * 
   * 边框样式：
   * - 样式：实线（BorderStyle.Solid）
   * - 宽度：底部1px（根据isBorder决定）
   * - 颜色：浅灰色（#f5f5f5）
   * 
   * 内边距：
   * - Row内边距：上下12px（使用项目常量）
   * - Column内边距：左右20px（使用项目常量）
   * 
   * 对齐方式：
   * - 垂直居中对齐（VerticalAlign.Center）
   * - 水平居中对齐（FlexAlign.Center）
   * 
   * 设计理念：
   * - 使用项目常量确保样式一致性
   * - 通过条件渲染实现灵活性
   * - 使用资源文件管理颜色
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Row({
        space:8
      }){
        if (this.icon) {
          Image(this.icon)
            .width(ImageConstants.IMG_WIDTH_20)
            .height(ImageConstants.IMG_HEIGHT_20)
        }

        Text(this.title)
          .font({
            size:FontConstants.FONT_SIZE_14,
            weight:FontConstants.FONT_WEIGHT_400,
            family:CommonConstants.FAMILY_PingFANG
          })
          .fontColor($r('app.string.color_black_88'))
          .lineHeight(TextConstants.TEXT_LINE_HEIGHT_22)
      }
      .border({
        style: BorderStyle.Solid,
        width: { bottom: this.isBorder ? 1 : 0 },
        color: '#f5f5f5'
      })
      .padding({
        top:PaddingConstants.PADDING_12,
        bottom:PaddingConstants.PADDING_12})
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .padding({
      left:PaddingConstants.PADDING_20,
      right:PaddingConstants.PADDING_20,})
  }
}

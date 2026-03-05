/**
 * @file CircleIcon.ets
 * @description 圆形图标组件
 * 
 * 功能概述：
 * 1. 显示圆形图标和标题文本
 * 2. 支持自定义图标和标题
 * 3. 提供统一的圆形图标样式
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
 * 
 * @author 2008
 * @datetime 2024/7/19 22:35
 */

import { IconTitleVo } from '../../componetsmodel/IconTitleVo'
import { buttonList } from '../dataList/buttonList'

/**
 * @class CircleIcon
 * @description 圆形图标组件
 * 
 * 组件职责：
 * 1. 展示图标和标题组合
 * 2. 提供统一的圆形图标样式
 * 3. 支持从IconTitleVo对象获取数据
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct CircleIcon{
  /** 
   * @prop item - 图标标题数据对象
   * @description 包含图标资源和标题文本的数据对象
   * @type {IconTitleVo}
   */
  @Prop item: IconTitleVo
  
  /**
   * @method build
   * @description 构建圆形图标UI
   * 
   * 布局结构：
   * 1. 顶部：圆形图标容器（包含图标）
   * 2. 底部：标题文本
   * 
   * 样式特点：
   * - 圆形容器：50圆角（完全圆形），0.5px浅灰色边框
   * - 图标：24x24大小，使用资源颜色（color_black_65）
   * - 图标内边距：12px（通过margin实现）
   * - 文字：12px字体，400字重，20px行高，使用资源颜色
   * - 整体：垂直间距8px，居中对齐
   * 
   * 颜色配置：
   * - 使用资源文件中的颜色定义（$r('app.string.color_black_65')）
   * - 确保颜色主题一致性
   * 
   * @returns {void}
   */
  build() {
    Column({
      space:8
    }){
      Column(){
        Image(this.item.icon)
          .width(24)
          .height(24)
          .margin(12)
          .fillColor($r('app.string.color_black_65'))
      }.borderRadius(50)
      .border({width:0.5,color:'rgba(0, 0, 0, 0.15)'})
      Text(this.item.title)
        .fontColor($r('app.string.color_black_65'))
        .fontSize(12)
        .fontWeight(400)
        .lineHeight(20)
    }
    .alignItems(HorizontalAlign.Center)
  }
}

/**
 * @file operateIcon.ets
 * @description 操作图标组件
 * 
 * 功能概述：
 * 1. 显示图标和标题的操作按钮
 * 2. 使用buttonList数据模型
 * 3. 提供统一的图标+文字操作按钮样式
 * 
 * 使用场景：
 * - 功能操作按钮
 * - 工具选项按钮
 * - 需要图标和文字组合的操作按钮
 * 
 * 设计特点：
 * - 图标和文字垂直排列
 * - 使用资源文件中的颜色配置
 * - 居中对齐布局
 * - 固定的内边距
 * 
 * 样式特点：
 * - 图标：24x24大小，使用color_black_88填充色
 * - 文字：12px字体，400字重，20px行高，使用color_black_88颜色
 * - 间距：图标和文字之间4px间距
 * - 内边距：上下12px
 * 
 * 数据模型：
 * - 使用buttonList类型，包含icon和title属性
 * - 通过item属性传入数据
 * 
 * @author 2008
 * @datetime 2024/5/23 22:35
 * @note 类名注释有误：实际类名是operateIcon，但注释中写的是InsideCircleIcon
 */

import { buttonList } from '../dataList/buttonList'

/**
 * @class operateIcon
 * @description 操作图标组件
 * 
 * 组件职责：
 * 1. 展示图标和标题组合的操作按钮
 * 2. 使用buttonList数据模型
 * 3. 提供统一的样式和布局
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct operateIcon{
  /** 
   * @prop item - 按钮数据
   * @description 包含图标和标题的按钮数据对象
   * @type {buttonList}
   */
  @Prop item:buttonList
  
  /**
   * @method build
   * @description 构建操作图标UI
   * 
   * 布局结构：
   * 1. 顶部：图标（Image组件）
   * 2. 底部：标题文本（Text组件）
   * 
   * 图标样式：
   * - 尺寸：24x24大小
   * - 填充色：使用资源文件中的color_black_88
   * - 图标来源：从item.icon获取
   * 
   * 文本样式：
   * - 内容：从item.title获取
   * - 颜色：使用资源文件中的color_black_88
   * - 字体：12px，400字重
   * - 行高：20px
   * 
   * 容器样式：
   * - 垂直间距：图标和文字之间4px间距
   * - 对齐方式：水平居中对齐
   * - 内边距：上下12px
   * 
   * 设计理念：
   * - 简洁的图标+文字组合
   * - 统一的颜色主题（使用资源文件）
   * - 垂直排列，便于触摸操作
   * - 适当的内边距增加点击区域
   * 
   * 数据流：
   * - 通过item属性接收外部数据
   * - 数据包含icon（图标资源）和title（标题文本）
   * - 组件不处理业务逻辑，只负责展示
   * 
   * 注意事项：
   * - 类名注释有误：注释中写的是InsideCircleIcon，但实际类名是operateIcon
   * - 这可能是因为复制粘贴导致的错误
   * 
   * @returns {void}
   */
  build() {
    Column({
      space:4
    }){
      Image(this.item.icon)
        .width(24).height(24)
        .fillColor($r('app.string.color_black_88'))
      Text(this.item.title).fontColor($r('app.string.color_black_88')).fontSize(12).fontWeight(400).lineHeight(20)
    }
    .alignItems(HorizontalAlign.Center)
    .padding({top:12,bottom:12})
  }
}

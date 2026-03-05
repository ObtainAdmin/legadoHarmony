/**
 * @file TagIndex.ets
 * @description 书籍标签展示组件
 * 
 * 功能概述：
 * 1. 显示书籍分类或标签文本
 * 2. 提供统一的标签样式（圆角、背景色、文字颜色）
 * 3. 支持自定义标签内容
 * 
 * 使用场景：
 * - 书籍详情页的分类标签显示
 * - 书籍列表中的类型标识
 * - 任何需要标签式展示的文本内容
 * 
 * 设计特点：
 * - 简洁的圆角矩形设计
 * - 半透明背景和文字，增强视觉层次
 * - 使用项目常量统一字体大小
 * 
 * @copyright (C), 2024-05-03
 * @author LinXun
 * @date 2024/5/3 13:55
 * @version 1.0
 */

import CommonConstants from '../../common/constants/CommonConstants'

/**
 * @class TagIndex
 * @description 标签索引组件
 * 
 * 组件职责：
 * 1. 展示书籍标签文本
 * 2. 应用统一的标签样式
 * 3. 保持标签视觉一致性
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct TagIndex {
  /** 
   * @private tag - 标签文本
   * @description 要显示的标签内容，如书籍分类、类型等
   * @default '幻想修仙' - 示例标签
   * @type {string}
   */
  private tag: string = '幻想修仙';
  
  /**
   * @method build
   * @description 构建标签组件UI
   * 
   * 布局结构：
   * 1. 单文本组件显示标签内容
   * 2. 使用Column容器实现居中布局
   * 
   * 样式特点：
   * - 使用项目常量控制字体大小（FONT_NOVEL_DETAIL_TAG_SIZE）
   * - 半透明白色文字（#73ffffff）
   * - 更浅的半透明背景（#14ffffff）
   * - 固定高度（16px）和圆角（4px）
   * - 左右内边距（6px）确保文字不贴边
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Text(this.tag)
        .fontSize(CommonConstants.FONT_NOVEL_DETAIL_TAG_SIZE)
        .fontColor('#73ffffff')
    }
    .justifyContent(FlexAlign.Center)
    .padding({left: 6, right: 6})
    .borderRadius(4)
    .backgroundColor('#14ffffff')
    .height(16)
  }
}

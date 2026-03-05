/**
 * @file ReadRecordItem.ets
 * @description 阅读记录展示组件
 * 
 * 功能概述：
 * 1. 显示阅读统计数据（如阅读时长、阅读次数等）
 * 2. 支持数值和单位的组合显示
 * 3. 提供描述文本展示
 * 
 * 使用场景：
 * - 用户个人中心的阅读统计展示
 * - 书籍详情页的阅读记录显示
 * - 数据统计面板中的指标展示
 * 
 * 设计特点：
 * - 简洁的垂直布局设计
 * - 数值和单位使用不同字体大小区分
 * - 支持自定义颜色主题
 * 
 * @copyright (C), 2024-05-03
 * @author LinXun
 * @date 2024/5/3 15:40
 * @version 1.0
 */

/**
 * @class ReadRecordItem
 * @description 阅读记录项组件
 * 
 * 组件职责：
 * 1. 展示阅读统计数值
 * 2. 格式化数值和单位的显示
 * 3. 提供清晰的视觉层次
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct ReadRecordItem {
  /** 
   * @private count - 统计数值
   * @description 要显示的阅读统计数值，如阅读时长、阅读次数等
   * @default 243 - 示例值，实际使用时应该传入实际数据
   * @type {number}
   */
  private count: number = 243;
  
  /** 
   * @private unit - 数值单位
   * @description 统计数值的单位，如"小时"、"次"、"本"等
   * @default '小时' - 示例单位
   * @type {string}
   */
  private unit: string = '小时';
  
  /** 
   * @private placeText - 描述文本
   * @description 统计项目的描述文字，如"阅读时长"、"阅读次数"等
   * @default '阅读时长' - 示例描述
   * @type {string}
   */
  private placeText: string = '阅读时长';
  
  /**
   * @method build
   * @description 构建阅读记录项UI
   * 
   * 布局结构：
   * 1. 顶部：数值和单位组合（使用Span组件分别设置样式）
   * 2. 底部：描述文本
   * 
   * 样式特点：
   * - 数值使用较大字体（20px），单位使用较小字体（12px）
   * - 数值和描述文本使用不同透明度区分层次
   * - 固定宽度和高度，适合在网格布局中使用
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Text() {
        Span(this.count.toString())
          .fontSize(20)
          .fontWeight(400)
          .lineHeight(24)
        Span(this.unit)
          .fontSize(12)
          .fontWeight(400)
          .lineHeight(20)
      }
      .fontColor('#FFFFFF')
      .height(24)
      Text(this.placeText)
        .fontSize(12)
        .fontWeight(400)
        .lineHeight(20)
        .fontColor('#73ffffff')
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .height(44)
    .width(106)
  }
}

/**
 * 文本行高常量类 - 定义应用中使用的文本行高常量
 * 
 * @author 2008
 * @datetime 2024/6/28 22:36
 * @className: TextConstants
 * 
 * 功能：提供统一的文本行高（line-height）常量，确保应用文本排版的一致性
 * 使用方法：通过 TextConstants.常量名 访问对应的行高值
 * 注意事项：
 *   - 所有行高单位为像素（px）
 *   - 行高值通常比字体大小大4-8像素，以确保良好的可读性
 *   - 行高影响文本的垂直间距和整体排版效果
 */
export default class TextConstants {
  /**
   * 18像素文本行高
   * 功能：定义小号文本的行高
   * 使用场景：小字体文本、注释、标签等
   * 搭配字体：通常搭配12-14像素字体
   */
  static readonly TEXT_LINE_HEIGHT_18: number = 18;
  
  /**
   * 20像素文本行高
   * 功能：定义标准小号文本的行高
   * 使用场景：正文小字、描述文本等
   * 搭配字体：通常搭配14像素字体
   */
  static readonly TEXT_LINE_HEIGHT_20: number = 20;
  
  /**
   * 22像素文本行高
   * 功能：定义中等文本的行高
   * 使用场景：标准正文、列表项等
   * 搭配字体：通常搭配14-16像素字体
   */
  static readonly TEXT_LINE_HEIGHT_22: number = 22;
  
  /**
   * 24像素文本行高
   * 功能：定义较大文本的行高
   * 使用场景：小标题、重要提示等
   * 搭配字体：通常搭配16-18像素字体
   */
  static readonly TEXT_LINE_HEIGHT_24: number = 24;
  
  /**
   * 26像素文本行高
   * 功能：定义大文本的行高
   * 使用场景：次级标题、突出显示内容
   * 搭配字体：通常搭配18-20像素字体
   */
  static readonly TEXT_LINE_HEIGHT_26: number = 26;
  
  /**
   * 28像素文本行高
   * 功能：定义特大文本的行高
   * 使用场景：主标题、页面头部等
   * 搭配字体：通常搭配20-22像素字体
   */
  static readonly TEXT_LINE_HEIGHT_28: number = 28;
}

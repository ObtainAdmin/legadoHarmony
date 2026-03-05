/**
 * 字体常量类 - 定义应用中使用的字体大小和字体粗细常量
 * 
 * @author 2008
 * @datetime 2024/6/28 22:29
 * @className: FontConstants
 * 
 * 功能：提供统一的字体大小和字体粗细常量，确保应用UI的一致性
 * 使用方法：通过 FontConstants.常量名 访问对应的字体样式值
 * 分类：
 *   1. 字体大小常量（单位：像素）
 *   2. 字体粗细常量（字重值）
 * 注意事项：
 *   - 字体大小单位为像素（px）
 *   - 字体粗细值遵循CSS font-weight标准
 *   - 400为正常字体，700为粗体
 */
export default class FontConstants {
  // ==================== 字体大小常量（单位：像素） ====================
  
  /**
   * 12像素字体大小
   * 功能：定义小号字体尺寸
   * 使用场景：辅助文本、注释、标签等小字内容
   */
  static readonly FONT_SIZE_12: number = 12;
  
  /**
   * 14像素字体大小
   * 功能：定义标准小号字体尺寸
   * 使用场景：正文内容、描述文本、列表项等
   */
  static readonly FONT_SIZE_14: number = 14;
  
  /**
   * 16像素字体大小
   * 功能：定义中等字体尺寸
   * 使用场景：主要正文、按钮文字、导航项等
   */
  static readonly FONT_SIZE_16: number = 16;
  
  /**
   * 18像素字体大小
   * 功能：定义较大字体尺寸
   * 使用场景：小标题、重要提示、突出显示内容
   */
  static readonly FONT_SIZE_18: number = 18;
  
  /**
   * 20像素字体大小
   * 功能：定义大号字体尺寸
   * 使用场景：次级标题、重要按钮文字
   */
  static readonly FONT_SIZE_20: number = 20;
  
  /**
   * 22像素字体大小
   * 功能：定义特大字体尺寸
   * 使用场景：主要标题、页面头部
   */
  static readonly FONT_SIZE_22: number = 22;
  
  /**
   * 24像素字体大小
   * 功能：定义超大字体尺寸
   * 使用场景：页面主标题、重要提示标题
   */
  static readonly FONT_SIZE_24: number = 24;

  // ==================== 字体粗细常量（字重值） ====================
  
  /**
   * 字体粗细400（正常）
   * 功能：定义正常字体粗细
   * 使用场景：大部分正文文本、默认字体样式
   * CSS对应：font-weight: 400
   */
  static readonly FONT_WEIGHT_400: number = 400;
  
  /**
   * 字体粗细500（中等）
   * 功能：定义中等字体粗细
   * 使用场景：强调文本、按钮文字
   * CSS对应：font-weight: 500
   */
  static readonly FONT_WEIGHT_500: number = 500;
  
  /**
   * 字体粗细600（半粗体）
   * 功能：定义半粗体字体粗细
   * 使用场景：小标题、重要内容
   * CSS对应：font-weight: 600
   */
  static readonly FONT_WEIGHT_600: number = 600;
  
  /**
   * 字体粗细700（粗体）
   * 功能：定义粗体字体粗细
   * 使用场景：标题、重要提示、按钮强调
   * CSS对应：font-weight: 700
   */
  static readonly FONT_WEIGHT_700: number = 700;
  
  /**
   * 字体粗细800（特粗体）
   * 功能：定义特粗体字体粗细
   * 使用场景：主标题、特别强调内容
   * CSS对应：font-weight: 800
   */
  static readonly FONT_WEIGHT_800: number = 800;
}

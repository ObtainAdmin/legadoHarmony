/**
 * 图片常量类 - 定义应用中使用的图片宽度和高度常量
 * 
 * @author 2008
 * @datetime 2024/6/28 22:34
 * @className: ImageConstants
 * 
 * 功能：提供统一的图片尺寸常量，确保应用UI中图片显示的一致性
 * 使用方法：通过 ImageConstants.常量名 访问对应的图片尺寸值
 * 分类：
 *   1. 图片宽度常量（单位：像素）
 *   2. 图片高度常量（单位：像素）
 * 注意事项：
 *   - 所有尺寸单位为像素（px）
 *   - 宽度和高度常量通常成对使用，但也可以单独使用
 *   - 常用尺寸：24px（小图标）、40px（中等图标）、48px（大图标）
 */
export default class ImageConstants {
  // ==================== 图片宽度常量（单位：像素） ====================
  
  /**
   * 18像素图片宽度
   * 功能：定义超小图片宽度
   * 使用场景：极小图标、状态指示图标
   */
  static readonly IMG_WIDTH_18: number = 18;
  
  /**
   * 20像素图片宽度
   * 功能：定义很小图片宽度
   * 使用场景：小图标、工具栏图标
   */
  static readonly IMG_WIDTH_20: number = 20;
  
  /**
   * 24像素图片宽度
   * 功能：定义标准小图片宽度
   * 使用场景：标准图标、按钮图标、导航图标
   */
  static readonly IMG_WIDTH_24: number = 24;
  
  /**
   * 32像素图片宽度
   * 功能：定义中等偏小图片宽度
   * 使用场景：中等图标、列表项图标
   */
  static readonly IMG_WIDTH_32: number = 32;
  
  /**
   * 40像素图片宽度
   * 功能：定义中等图片宽度
   * 使用场景：中等大小图标、头像图标
   */
  static readonly IMG_WIDTH_40: number = 40;
  
  /**
   * 48像素图片宽度
   * 功能：定义大图片宽度
   * 使用场景：大图标、重要功能图标
   */
  static readonly IMG_WIDTH_48: number = 48;
  
  /**
   * 124像素图片宽度
   * 功能：定义特大图片宽度
   * 使用场景：大图展示、封面图片
   */
  static readonly IMG_WIDTH_124: number = 124;

  // ==================== 图片高度常量（单位：像素） ====================
  
  /**
   * 18像素图片高度
   * 功能：定义超小图片高度
   * 使用场景：极小图标、状态指示图标
   */
  static readonly IMG_HEIGHT_18: number = 18;
  
  /**
   * 20像素图片高度
   * 功能：定义很小图片高度
   * 使用场景：小图标、工具栏图标
   */
  static readonly IMG_HEIGHT_20: number = 20;
  
  /**
   * 24像素图片高度
   * 功能：定义标准小图片高度
   * 使用场景：标准图标、按钮图标、导航图标
   */
  static readonly IMG_HEIGHT_24: number = 24;
  
  /**
   * 32像素图片高度
   * 功能：定义中等偏小图片高度
   * 使用场景：中等图标、列表项图标
   */
  static readonly IMG_HEIGHT_32: number = 32;
  
  /**
   * 40像素图片高度
   * 功能：定义中等图片高度
   * 使用场景：中等大小图标、头像图标
   */
  static readonly IMG_HEIGHT_40: number = 40;
  
  /**
   * 48像素图片高度
   * 功能：定义大图片高度
   * 使用场景：大图标、重要功能图标
   */
  static readonly IMG_HEIGHT_48: number = 48;
  
  /**
   * 120像素图片高度
   * 功能：定义特大图片高度
   * 使用场景：大图展示、封面图片
   */
  static readonly IMG_HEIGHT_120: number = 120;
}

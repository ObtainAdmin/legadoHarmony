/**
 * 内边距/外边距常量类 - 定义应用中使用的间距常量
 * 
 * @author 2008
 * @datetime 2024/6/28 23:00
 * @className: PaddingConstants
 * 
 * 功能：提供统一的内边距（padding）和外边距（margin）常量，确保应用UI布局的一致性
 * 使用方法：通过 PaddingConstants.常量名 访问对应的间距值
 * 分类：
 *   1. 小间距（1-6像素）：用于细微调整和紧凑布局
 *   2. 中间距（8-15像素）：用于标准组件间距
 *   3. 大间距（16-22像素）：用于较大组件间距和分组
 *   4. 特大间距（24-32像素）：用于页面级间距和分隔
 * 注意事项：
 *   - 所有间距单位为像素（px）
 *   - 这些常量可用于padding和margin属性
 *   - 遵循8像素网格系统（8、16、24、32等是8的倍数）
 */
export default class PaddingConstants {
  // ==================== 小间距（1-6像素） ====================
  // 用于细微调整和紧凑布局
  
  static readonly PADDING_1: number = 1;   // 1像素间距，最小间距单位
  static readonly PADDING_2: number = 2;   // 2像素间距，细微调整
  static readonly PADDING_3: number = 3;   // 3像素间距，小间距调整
  static readonly PADDING_4: number = 4;   // 4像素间距，标准小间距
  static readonly PADDING_5: number = 5;   // 5像素间距，中等偏小间距
  static readonly PADDING_6: number = 6;   // 6像素间距，标准紧凑间距

  // ==================== 中间距（8-15像素） ====================
  // 用于标准组件间距
  
  static readonly PADDING_8: number = 8;   // 8像素间距，标准网格单位，常用基础间距
  static readonly PADDING_9: number = 9;   // 9像素间距
  static readonly PADDING_10: number = 10; // 10像素间距，常用组件间距
  static readonly PADDING_11: number = 11; // 11像素间距
  static readonly PADDING_12: number = 12; // 12像素间距，标准中等间距
  static readonly PADDING_13: number = 13; // 13像素间距
  static readonly PADDING_14: number = 14; // 14像素间距
  static readonly PADDING_15: number = 15; // 15像素间距，中等偏大间距

  // ==================== 大间距（16-22像素） ====================
  // 用于较大组件间距和分组
  
  static readonly PADDING_16: number = 16; // 16像素间距，标准大间距（8的2倍）
  static readonly PADDING_17: number = 17; // 17像素间距
  static readonly PADDING_18: number = 18; // 18像素间距，常用大间距
  static readonly PADDING_19: number = 19; // 19像素间距
  static readonly PADDING_20: number = 20; // 20像素间距，标准组件分组间距
  static readonly PADDING_21: number = 21; // 21像素间距
  static readonly PADDING_22: number = 22; // 22像素间距

  // ==================== 特大间距（24-32像素） ====================
  // 用于页面级间距和分隔
  
  static readonly PADDING_24: number = 24; // 24像素间距，标准特大间距（8的3倍）
  static readonly PADDING_32: number = 32; // 32像素间距，最大标准间距（8的4倍）
}

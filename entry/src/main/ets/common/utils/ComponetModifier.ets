/**
 * 组件修饰器工具类 - 提供统一组件样式的修饰器
 * 
 * 功能：封装HarmonyOS组件的样式设置，提供统一的样式配置接口
 * 核心特性：
 *   1. 统一样式管理：集中管理组件的padding、margin、背景色等样式
 *   2. 链式调用：支持链式调用设置多个样式属性
 *   3. 默认值配置：提供合理的默认样式值
 * 使用场景：UI组件样式统一配置、主题切换、响应式布局
 */
import { PublicConstants, TextConstants } from '../constants/PublicConstants';

/**
 * Column组件修饰器类 - 统一Column组件的样式设置
 * 
 * 功能：提供Column组件的统一样式配置，包括padding、margin、背景色等
 * 实现：实现AttributeModifier<ColumnAttribute>接口
 * 使用场景：页面布局、卡片布局、列表项等Column组件的样式统一
 */
export class ColumnModifier implements AttributeModifier<ColumnAttribute> {
  /**
   * 内边距配置
   * 功能：设置Column组件的内边距
   * 默认值：{ left: 20, right: 20 }（左右各20单位）
   */
  private paddingNumber: Padding = { left: 20, right: 20 };
  
  /**
   * 外边距配置
   * 功能：设置Column组件的外边距
   * 默认值：0（无外边距）
   */
  private marginNumber: Margin | Length = 0;
  
  /**
   * 顶部矩形高度
   * 功能：从AppStorage获取的顶部矩形高度，用于适配状态栏
   * 来源：AppStorage.get("topRectHeight")
   */
  private topRectHeight = AppStorage.get("topRectHeight") as number;
  
  /**
   * 底部矩形高度
   * 功能：从AppStorage获取的底部矩形高度，用于适配导航栏
   * 来源：AppStorage.get("bottomRectHeight")
   */
  private bottomRectHeight = AppStorage.get("bottomRectHeight") as number;
  
  /**
   * 背景颜色
   * 功能：设置Column组件的背景颜色
   * 默认值：PublicConstants.WINDOW_BACKGROUND_COLOR（窗口背景色）
   */
  private backgroundColors: ResourceColor = PublicConstants.WINDOW_BACKGROUND_COLOR;

  /**
   * 应用普通属性
   * 功能：将配置的样式属性应用到Column组件实例
   * @param instance - Column组件属性实例
   * 处理流程：
   *   1. 设置上下内边距为顶部和底部矩形高度
   *   2. 应用内边距配置
   *   3. 应用外边距配置
   *   4. 应用背景颜色
   */
  applyNormalAttribute(instance: ColumnAttribute): void {
    this.paddingNumber.top = this.topRectHeight;
    this.paddingNumber.bottom = this.bottomRectHeight;
    instance.padding(this.paddingNumber);
    instance.margin(this.marginNumber);
    instance.backgroundColor(this.backgroundColors);
  }

  /**
   * 设置自定义内边距
   * 功能：完全自定义内边距配置，并重置上下矩形高度为0
   * @param Padding - 完整的内边距配置对象
   * 返回值：ColumnModifier - 支持链式调用
   * 使用场景：需要完全自定义内边距的场景
   */
  setCustom(Padding: Padding): ColumnModifier {
    this.paddingNumber = Padding;
    this.topRectHeight = 0;
    this.bottomRectHeight = 0;
    return this;
  }

  /**
   * 设置左右内边距
   * 功能：仅设置左右内边距，保持上下内边距不变
   * @param left - 左内边距
   * @param right - 右内边距
   * 返回值：ColumnModifier - 支持链式调用
   * 使用场景：只需要调整左右内边距的场景
   */
  setPadding(left: number, right: number): ColumnModifier {
    this.paddingNumber.left = left;
    this.paddingNumber.right = right;
    return this;
  }

  /**
   * 设置外边距
   * 功能：设置Column组件的外边距
   * @param marginNumber - 外边距值（可以是数字或Margin对象）
   * 返回值：ColumnModifier - 支持链式调用
   */
  margin(marginNumber: Margin | Length): ColumnModifier {
    this.marginNumber = marginNumber;
    return this;
  }

  /**
   * 设置背景颜色
   * 功能：设置Column组件的背景颜色
   * @param backgroundColors - 背景颜色值
   * 返回值：ColumnModifier - 支持链式调用
   */
  backgroundColor(backgroundColors: ResourceColor): ColumnModifier {
    this.backgroundColors = backgroundColors;
    return this;
  }
}

/**
 * Text组件修饰器类 - 统一Text组件的样式设置
 * 
 * 功能：提供Text组件的统一样式配置，包括字体大小、行高等
 * 实现：实现AttributeModifier<TextAttribute>接口
 * 使用场景：文本显示、标签、按钮文字等Text组件的样式统一
 */
export class TextModifier implements AttributeModifier<TextAttribute> {
  /**
   * 字体大小
   * 功能：设置Text组件的字体大小
   * 默认值：TextConstants.TEXT_FONT_SIZE（文本常量中的字体大小）
   */
  private publicFontSize: number | string | Resource = TextConstants.TEXT_FONT_SIZE;
  
  /**
   * 行高
   * 功能：设置Text组件的行高
   * 默认值：TextConstants.TEXT_LINE_HEIGHT（文本常量中的行高）
   */
  private publicLineHeight: number | string | Resource = TextConstants.TEXT_LINE_HEIGHT;

  /**
   * 应用普通属性
   * 功能：将配置的样式属性应用到Text组件实例
   * @param instance - Text组件属性实例
   * 处理流程：
   *   1. 应用字体大小
   *   2. 应用行高
   */
  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize(this.publicFontSize);
    instance.lineHeight(this.publicLineHeight);
  }

  /**
   * 设置字体大小
   * 功能：设置Text组件的字体大小，支持特殊文本类型
   * @param fontSize - 字体大小值
   * @param textType - 文本类型（0:普通文本, 1:使用默认字体大小）
   * 返回值：TextModifier - 支持链式调用
   * 逻辑：如果textType为1，则使用TextConstants.TEXT_FONT_SIZE；否则使用传入的fontSize
   */
  fontSize(fontSize: number | string | Resource, textType: number = 0) {
    this.publicFontSize = textType == 1 ? TextConstants.TEXT_FONT_SIZE : fontSize;
    return this;
  }

  /**
   * 设置行高
   * 功能：设置Text组件的行高，支持特殊文本类型
   * @param lineHeight - 行高值
   * @param textType - 文本类型（0:普通文本, 1:使用默认行高）
   * 返回值：TextModifier - 支持链式调用
   * 逻辑：如果textType为1，则使用TextConstants.TEXT_LINE_HEIGHT；否则使用传入的lineHeight
   */
  lineHeight(lineHeight: number | string | Resource, textType: number = 0) {
    this.publicLineHeight = textType == 1 ? TextConstants.TEXT_LINE_HEIGHT : lineHeight;
    return this;
  }
}

/**
 * @file FormInput.ets
 * @description 表单输入组件
 * 
 * 功能概述：
 * 1. 提供自定义的表单输入框组件
 * 2. 支持图标显示、清除按钮、字数统计
 * 3. 支持主题颜色配置
 * 4. 支持输入长度限制和验证
 * 
 * 使用场景：
 * - 表单页面中的输入框
 * - 设置页面中的配置项输入
 * - 需要带图标和清除功能的输入框
 * - 需要显示字数统计的输入场景
 * 
 * 设计特点：
 * - 使用Stack布局实现图标、输入框、清除按钮和字数统计的叠加
 * - 支持主题颜色配置（光标颜色）
 * - 提供清除按钮，方便用户清空输入
 * - 显示实时字数统计
 * - 支持是否显示标题的配置
 * 
 * 组件结构：
 * 1. 标题区域（条件显示）：当showTitle为true时显示label
 * 2. 输入区域（Stack布局）：
 *   - 左侧：图标
 *   - 中间：文本输入框
 *   - 右侧：清除按钮（条件显示）和字数统计
 * 
 * 技术特点：
 * - 使用@Prop装饰器实现双向数据绑定
 * - 使用@StorageProp装饰器获取主题配置
 * - 使用enum定义表单项类型
 * - 使用条件渲染优化性能
 */

import PaddingConstants from '../../common/constants/PaddingConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'

/**
 * @enum FormItemType
 * @description 表单项类型枚举
 * 
 * 枚举值：
 * - Input: 输入框类型
 * 
 * 扩展说明：
 * 当前只定义了Input类型，未来可以扩展其他表单类型
 */
export enum FormItemType {
  Input
}

/**
 * @author 2008
 * @datetime 2024/7/20 01:21
 */

/**
 * @class FormInput
 * @description 表单输入组件
 * 
 * 组件职责：
 * 1. 提供自定义的表单输入框
 * 2. 管理输入状态和交互
 * 3. 应用主题颜色配置
 * 4. 提供输入验证和字数统计
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export  default  struct FormInput {
  /** 
   * @prop value - 输入值
   * @description 输入框的当前值，支持双向数据绑定
   * @type {string}
   */
  @Prop value: string
  
  /** 
   * @prop type - 表单项类型
   * @description 表单项的类型，当前固定为FormItemType.Input
   * @default FormItemType.Input
   * @type {FormItemType}
   */
  type: FormItemType = FormItemType.Input
  
  /** 
   * @prop label - 标签文本
   * @description 输入框的标签文本，用于显示标题和占位符
   * @default '图标名'
   * @type {string}
   */
  label: string = '图标名'
  
  /** 
   * @prop isLength - 是否启用长度限制
   * @description 控制是否启用输入长度限制（当前未使用）
   * @default false
   * @type {boolean}
   */
  isLength: boolean = false
  
  /** 
   * @prop maxLength - 最大长度
   * @description 输入框允许的最大字符长度
   * @default 5
   * @type {number}
   */
  maxLength: number = 5
  
  /** 
   * @prop onChange - 输入变化回调
   * @description 输入内容发生变化时调用的回调函数
   * @default (_value: string) => {} - 空函数
   * @type {Function}
   */
  onChange: Function = (_value: string) => {}
  
  /** 
   * @prop showTitle - 是否显示标题
   * @description 控制是否在输入框上方显示标签标题
   * @default false
   * @type {boolean}
   */
  showTitle: boolean = false
  
  /** 
   * @prop icon - 图标
   * @description 输入框左侧显示的图标，支持Resource或string类型
   * @default $r('app.media.icon_rss_source_check_image_font')
   * @type {Resource | string}
   */
  icon:Resource|string = $r('app.media.icon_rss_source_check_image_font')
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * @method build
   * @description 构建表单输入组件UI
   * 
   * 布局结构：
   * 1. 外层Column：垂直布局容器
   * 2. 标题Row：条件显示标签标题
   * 3. 输入Stack：图标、输入框、清除按钮和字数统计的叠加布局
   * 
   * 标题区域（条件显示）：
   * - 显示条件：this.showTitle为true
   * - 内容：this.label文本
   * - 样式：16px字体，垂直居中对齐
   * - 布局：Row水平布局，两端对齐
   * 
   * 输入区域（Stack布局）：
   * 1. 主Row（图标+输入框）：
   *   - 图标Image：24x24尺寸，左边距16px
   *   - 文本输入框TextInput：
   *     * 文本：this.value
   *     * 占位符：`请输入${this.label}`
   *     * 最大长度：this.maxLength
   *     * 背景色：透明
   *     * 占位符颜色：#73000000（45%黑色）
   *     * 占位符字体：16px，400字重
   *     * 光标颜色：主题主色
   *     * 边距：上下10px
   *     * 字体：16px，颜色#E0000000（87%黑色）
   *     * 变化事件：调用this.onChange回调
   * 
   * 2. 右侧Row（清除按钮+字数统计）：
   *   - 清除按钮（条件显示）：
   *     * 显示条件：this.value.length > 0
   *     * 图标：$r('app.media.clear_input_icon')
   *     * 尺寸：16x16
   *     * 点击事件：清空this.value
   *   - 字数统计Text：
   *     * 内容：`${当前长度}/${最大长度}`
   *     * 样式：14px字体，#73000000颜色（45%黑色）
   *     * 边距：右边距16px
   * 
   * 容器样式：
   * - Stack：圆角4px，背景色color_black_6，内容右对齐
   * - Column：顶部边距12px，100%宽度，左对齐
   * 
   * 交互逻辑：
   * 1. 输入变化：TextInput的onChange事件触发this.onChange回调
   * 2. 清除输入：点击清除按钮将this.value设置为空字符串
   * 3. 字数统计：实时显示当前输入长度和最大长度
   * 
   * 设计理念：
   * - 清晰的视觉层次：标题（可选）+ 输入区域
   * - 便捷的交互：图标提示 + 清除按钮
   * - 实时的反馈：字数统计 + 光标颜色
   * - 灵活的配置：支持多种属性自定义
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中使用
   * FormInput({
   *   value: this.inputValue,
   *   label: '用户名',
   *   maxLength: 20,
   *   showTitle: true,
   *   onChange: (value: string) => {
   *     this.inputValue = value
   *   }
   * })
   * ```
   * 
   * 颜色说明：
   * 1. #73000000: 45%黑色，用于占位符和辅助文字
   * 2. #E0000000: 87%黑色，用于主要文字
   * 3. color_black_6: 6%黑色，用于输入框背景
   * 4. theme.mainColor: 主题主色，用于光标
   * 
   * 注意事项：
   * - isLength属性当前未使用，可能是预留功能
   * - icon属性支持Resource和string两种类型，确保传入正确的类型
   * - 清除按钮通过直接修改this.value清空输入，会触发数据更新
   * - 使用??操作符处理value可能为undefined的情况
   * - 需要导入PaddingConstants、ThemeStorageKey、ThemeItem等依赖
   * 
   * 扩展建议：
   * - 可以添加inputType属性支持密码、数字等输入类型
   * - 可以添加errorText属性显示错误提示
   * - 可以添加disabled属性控制输入框禁用状态
   * - 可以添加onFocus/onBlur事件支持焦点控制
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Row() {
        Row() {
          if (this.showTitle){
            Text(this.label)
              .fontSize(16)
          }
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Stack(){
        Row({
          space:2
        }){
          Image(this.icon)
            .width(24)
            .height(24)
            .margin({left: PaddingConstants.PADDING_16})
          TextInput({text: this.value, placeholder: `请输入${this.label}`,})
            .maxLength(this.maxLength)
            .backgroundColor(Color.Transparent)
            .placeholderColor('#73000000')
            .placeholderFont({ size: 16, weight: 400 })
            .caretColor(this.theme.mainColor)
            .margin({ top: 10, bottom: 10 })
            .fontSize(16)
            .fontColor('#E0000000')
            .onChange((value: string) => {
              this.onChange(value)
            })
        }
        Row({
          space:12
        }){
          if (this.value.length > 0){
            Image($r('app.media.clear_input_icon')).width(16).height(16)
              .onClick(()=>{
                this.value = ''
              })
          }
          Text(`${this.value?.length ?? 0}/${this.maxLength}`)
            .fontSize(14)
            .fontColor('#73000000')
        }
        .margin({right:PaddingConstants.PADDING_16})
      }
      .alignContent(Alignment.End)
      .borderRadius(4)
      .backgroundColor($r('app.string.color_black_6'))
    }
    .margin({ top: 12 })
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

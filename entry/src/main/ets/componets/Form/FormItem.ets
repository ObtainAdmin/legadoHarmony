/**
 * @file FormItem.ets
 * @description 通用表单项组件
 * 
 * 功能概述：
 * 1. 提供通用的表单项组件，支持多种表单类型
 * 2. 支持自定义右侧区域构建器
 * 3. 支持必填项标记和字数统计
 * 4. 支持主题颜色配置
 * 
 * 使用场景：
 * - 表单页面中的通用表单项
 * - 需要自定义右侧区域的表单
 * - 需要必填标记的表单验证
 * - 需要字数统计的输入场景
 * 
 * 设计特点：
 * - 使用@BuilderParam支持自定义右侧区域
 * - 支持必填项红色星号标记
 * - 支持字数统计（条件显示）
 * - 支持主题颜色配置（光标颜色）
 * - 使用Stack布局实现输入框和字数统计的叠加
 * 
 * 组件结构：
 * 1. 标题区域：标签文本 + 必填标记（条件显示）
 * 2. 自定义右侧区域（条件显示）：通过@BuilderParam传入
 * 3. 输入区域（Stack布局）：
 *   - 输入框（当前只支持Input类型）
 *   - 字数统计（条件显示）
 * 
 * 技术特点：
 * - 使用@Prop装饰器实现双向数据绑定
 * - 使用@BuilderParam装饰器支持自定义构建器
 * - 使用@StorageProp装饰器获取主题配置
 * - 使用enum定义表单项类型
 * - 使用条件渲染优化性能
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"

/**
 * @enum FormItemType
 * @description 表单项类型枚举
 * 
 * 枚举值：
 * - Input: 输入框类型
 * 
 * 扩展说明：
 * 当前只定义了Input类型，未来可以扩展其他表单类型
 * 如：Select（下拉选择）、Switch（开关）、DatePicker（日期选择）等
 */
export enum FormItemType {
  Input
}

/**
 * @class FormItem
 * @description 通用表单项组件
 * 
 * 组件职责：
 * 1. 提供通用的表单项容器
 * 2. 支持自定义右侧区域
 * 3. 管理表单状态和验证
 * 4. 应用主题颜色配置
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export  default  struct FormItem {
  /** 
   * @builder rightBuilder - 默认右侧构建器
   * @description 默认的右侧区域构建器，空实现
   * @returns {void}
   */
  @Builder rightBuilder() {}
  
  /** 
   * @builderparam customRightBuilder - 自定义右侧构建器
   * @description 自定义的右侧区域构建器，支持传入外部构建器
   * @default this.rightBuilder - 默认使用空构建器
   * @type {() => void}
   */
  @BuilderParam customRightBuilder: () => void = this.rightBuilder
  
  /** 
   * @prop value - 输入值
   * @description 表单项的当前值，支持双向数据绑定
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
   * @description 表单项的标签文本，用于显示标题和占位符
   * @default '' - 默认空字符串
   * @type {string}
   */
  label: string = ''
  
  /** 
   * @prop required - 是否必填
   * @description 标识该表单项是否为必填项
   * @default false - 默认非必填
   * @type {boolean}
   */
  required: boolean = false
  
  /** 
   * @prop isLength - 是否显示字数统计
   * @description 控制是否显示输入字数统计
   * @default false - 默认不显示
   * @type {boolean}
   */
  isLength: boolean = false
  
  /** 
   * @prop maxLength - 最大长度
   * @description 输入框允许的最大字符长度
   * @default 10
   * @type {number}
   */
  maxLength: number = 10
  
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
   * @default true - 默认显示
   * @type {boolean}
   */
  showTitle: boolean = true

  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method build
   * @description 构建通用表单项组件UI
   * 
   * 布局结构：
   * 1. 外层Column：垂直布局容器
   * 2. 标题Row：标签文本 + 必填标记 + 自定义右侧区域
   * 3. 输入Stack：输入框 + 字数统计（条件显示）
   * 
   * 标题区域（Row布局）：
   * 1. 左侧Row（标签+必填标记）：
   *   - 标签Text（条件显示）：this.showTitle为true时显示this.label
   *   - 必填标记Text（条件显示）：this.required为true时显示红色"*"
   *   - 样式：16px字体，垂直居中对齐
   * 2. 自定义右侧区域（条件显示）：
   *   - 显示条件：this.customRightBuilder !== this.rightBuilder
   *   - 内容：调用this.customRightBuilder()渲染
   * 
   * 输入区域（Stack布局）：
   * 1. 输入框（条件显示）：
   *   - 显示条件：this.type === FormItemType.Input
   *   - 组件：TextInput
   *   - 文本：this.value ?? ''（处理undefined情况）
   *   - 占位符：`请输入${this.label}`
   *   - 占位符颜色：#73000000（45%黑色）
   *   - 占位符字体：14px，400字重
   *   - 光标颜色：主题主色
   *   - 高度：38px
   *   - 边距：上下10px
   *   - 字体：14px，颜色#E0000000（87%黑色）
   *   - 圆角：4px
   *   - 变化事件：调用this.onChange回调
   * 
   * 2. 字数统计（条件显示）：
   *   - 显示条件：this.isLength为true
   *   - 内容：`${当前长度}/${最大长度}`
   *   - 样式：14px字体，#73000000颜色（45%黑色）
   *   - 位置：绝对定位，顶部20px，右侧10px
   * 
   * 容器样式：
   * - Column：顶部边距12px，100%宽度，左对齐
   * - 标题Row：100%宽度，两端对齐
   * - 输入Stack：100%宽度
   * 
   * 交互逻辑：
   * 1. 输入变化：TextInput的onChange事件触发this.onChange回调
   * 2. 必填标记：当required为true时显示红色"*"号
   * 3. 字数统计：当isLength为true时显示当前字数/最大字数
   * 4. 自定义右侧区域：通过@BuilderParam传入自定义构建器
   * 
   * 设计理念：
   * - 灵活的布局：支持自定义右侧区域，适应不同业务需求
   * - 清晰的验证：必填标记明确标识必填项
   * - 实时的反馈：字数统计提供输入反馈
   * - 统一的样式：主题颜色配置保持界面一致性
   * 
   * 使用示例：
   * ```typescript
   * // 基本使用
   * FormItem({
   *   value: this.username,
   *   label: '用户名',
   *   required: true,
   *   onChange: (value: string) => {
   *     this.username = value
   *   }
   * })
   * 
   * // 使用自定义右侧区域
   * FormItem({
   *   value: this.phone,
   *   label: '手机号',
   *   customRightBuilder: () => {
   *     Button('发送验证码')
   *       .fontSize(12)
   *       .onClick(() => {
   *         // 发送验证码逻辑
   *       })
   *   },
   *   onChange: (value: string) => {
   *     this.phone = value
   *   }
   * })
   * ```
   * 
   * 颜色说明：
   * 1. #73000000: 45%黑色，用于占位符和辅助文字
   * 2. #E0000000: 87%黑色，用于主要文字
   * 3. Color.Red: 红色，用于必填标记
   * 4. theme.mainColor: 主题主色，用于光标
   * 
   * 注意事项：
   * - 当前只支持Input类型，type属性固定为FormItemType.Input
   * - 自定义右侧区域通过比较构建器引用判断是否使用默认构建器
   * - 使用??操作符处理value可能为undefined的情况
   * - 字数统计使用绝对定位，确保不遮挡输入内容
   * - 需要导入ThemeStorageKey、ThemeItem等依赖
   * 
   * 扩展建议：
   * - 可以扩展FormItemType枚举，支持更多表单类型
   * - 可以添加errorText属性显示错误提示
   * - 可以添加disabled属性控制表单项禁用状态
   * - 可以添加icon属性显示左侧图标
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

          if (this.required) {
            Text('*')
              .fontSize(16)
              .padding({ left: 10 })
              .fontColor(Color.Red)
          }
        }
        .alignItems(VerticalAlign.Center)

        if (this.customRightBuilder !== this.rightBuilder) {
          this.customRightBuilder()
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Stack() {
        if (this.type === FormItemType.Input) {
          TextInput({ text: this.value ?? '', placeholder: `请输入${this.label}` })
            .placeholderColor('#73000000')
            .placeholderFont({ size: 14, weight: 400 })
            .caretColor(this.theme.mainColor)
            .height(38)
            .margin({ top: 10, bottom: 10 })
            .fontSize(14)
            .fontColor('#E0000000')
            .borderRadius(4)
            .onChange((value: string) => {
              this.onChange(value)
            })
        }

        if (this.isLength) {
          Text(`${this.value?.length ?? 0}/${this.maxLength}`)
            .fontSize(14)
            .fontColor('#73000000')
            .position({ top: 20, right: 10 })
        }
      }.width('100%')
    }
    .margin({ top: 12 })
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

/**
 * @file help.ets
 * @description 帮助弹窗组件
 * 
 * 功能概述：
 * 1. 显示帮助信息的弹窗
 * 2. 支持自定义标题、内容和按钮
 * 3. 提供自定义内容构建器
 * 4. 适配底部安全区域
 * 5. 支持预览模式
 * 
 * 使用场景：
 * - 导出帮助提示
 * - 操作说明弹窗
 * - 需要显示帮助信息的场景
 * - 需要自定义内容的弹窗
 * 
 * 设计特点：
 * - 使用Flex布局实现上下分栏
 * - 支持自定义内容构建器（BuilderParam）
 * - 适配底部安全区域高度
 * - 使用项目常量统一样式
 * - 支持预览模式（@Preview）
 * 
 * 弹窗结构：
 * 1. 顶部区域：标题和内容
 *   - 标题：可自定义，默认"导出帮助"
 *   - 自定义内容：通过contentBuilder构建
 *   - 帮助内容：可自定义，默认HelpInfo.HELP_INFO_MESSAGE
 * 2. 底部区域：确认按钮
 *   - 按钮文本：可自定义，默认"我知道了"
 *   - 按钮颜色：主题主色
 * 
 * 自定义能力：
 * 1. 标题自定义：title属性
 * 2. 内容自定义：context属性
 * 3. 按钮文本自定义：btnText属性
 * 4. 按钮点击事件：btnClick回调
 * 5. 自定义内容构建器：contentBuilder
 * 6. 内容显示控制：isShowContent属性
 * 
 * 技术特点：
 * - 使用@BuilderParam支持动态内容构建
 * - 使用@StorageLink适配底部安全区域
 * - 使用@StorageProp获取主题配置
 * - 使用@Preview支持预览模式
 */

import CommonConstants from '../../common/constants/CommonConstants'
import FontConstants from '../../common/constants/FontConstants'
import PaddingConstants from '../../common/constants/PaddingConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'
import { HelpInfo } from '../../viewData/HelpInfo'

/**
 * @class Help
 * @description 帮助弹窗组件
 * 
 * 组件职责：
 * 1. 显示帮助信息弹窗
 * 2. 管理自定义内容构建
 * 3. 适配底部安全区域
 * 4. 应用主题颜色配置
 * 
 * @decorator @Component - 声明为ArkTS组件
 * @decorator @Preview - 支持预览模式
 */
@Component
@Preview
export default struct Help {
  /** 
   * @prop title - 弹窗标题
   * @description 弹窗显示的标题，为空时使用默认标题"导出帮助"
   * @default '' - 默认空字符串
   * @type {string}
   */
  title: string = ''
  
  /** 
   * @prop context - 弹窗内容
   * @description 弹窗显示的帮助内容，为空时使用默认帮助信息
   * @default '' - 默认空字符串
   * @type {string}
   */
  context: string = ''
  
  /** 
   * @prop btnText - 按钮文本
   * @description 确认按钮显示的文本，为空时使用默认文本"我知道了"
   * @default '' - 默认空字符串
   * @type {string}
   */
  btnText: string = ''
  
  /** 
   * @prop btnClick - 按钮点击回调
   * @description 确认按钮被点击时调用的回调函数
   * @type {Function}
   */
  btnClick: Function = () => {
  }
  
  /** 
   * @builder contentBuilders - 默认内容构建器
   * @description 默认的内容构建器，空实现
   * @returns {void}
   */
  @Builder contentBuilders() {}
  
  /** 
   * @builderParam contentBuilder - 自定义内容构建器
   * @description 自定义内容构建器，用于构建弹窗中的自定义内容区域
   * @default this.contentBuilders - 默认使用空构建器
   * @type {() => void}
   */
  @BuilderParam contentBuilder: () => void = this.contentBuilders
  
  /** 
   * @storageLink bottomRectHeight - 底部安全区域高度
   * @description 底部安全区域的高度，用于适配不同设备的底部区域
   * @default 0 - 默认0
   * @type {number}
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 
   * @prop isShowContent - 是否显示内容
   * @description 控制是否显示帮助内容区域
   * @default true - 默认显示内容
   * @type {boolean}
   */
  isShowContent:boolean = true
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * @method build
   * @description 构建帮助弹窗UI
   * 
   * 布局结构：
   * 1. 外层Flex：垂直分栏布局，上下两端对齐
   * 2. 内层Column：顶部内容区域
   * 3. Button：底部确认按钮
   * 
   * 顶部内容区域：
   * 1. 标题Text：
   *   - 内容：title不为空时使用title，否则使用"导出帮助"
   *   - 样式：16px，500字重，PingFANG字体
   *   - 颜色：color_black_88
   *   - 对齐：居中对齐
   *   - 行高：24px
   *   - 底部边距：12px
   * 
   * 2. 自定义内容区域（条件显示）：
   *   - 显示条件：contentBuilders !== contentBuilder（即使用了自定义构建器）
   *   - 容器：Column
   *   - 内容：调用contentBuilder()构建
   *   - 内边距：上下12px
   * 
   * 3. 帮助内容区域（条件显示）：
   *   - 显示条件：isShowContent为true
   *   - 容器：Flex
   *   - 内容：context不为空时使用context，否则使用HelpInfo.HELP_INFO_MESSAGE
   *   - 内边距：上下12px
   * 
   * 底部确认按钮：
   * - 文本：btnText不为空时使用btnText，否则使用"我知道了"
   * - 宽度：100%容器宽度
   * - 背景色：主题主色
   * - 内边距：左右32px，上下8px
   * - 点击事件：调用btnClick回调
   * 
   * 容器样式：
   * - 高度：100%父容器高度
   * - 内边距：左右20px，上下12px，底部额外加上bottomRectHeight
   * 
   * 设计理念：
   * - 灵活的布局：支持自定义内容构建器
   * - 智能的默认值：为空时使用合理的默认值
   * - 良好的适配：考虑底部安全区域
   * - 统一的样式：使用项目常量
   * 
   * 自定义内容构建器使用：
   * ```typescript
   * // 使用自定义构建器
   * Help({
   *   contentBuilder: () => {
   *     Text('自定义内容')
   *       .fontSize(14)
   *       .fontColor(Color.Black)
   *   }
   * })
   * ```
   * 
   * 默认值机制：
   * 1. 标题：空时使用$r('app.string.export_help')
   * 2. 内容：空时使用HelpInfo.HELP_INFO_MESSAGE
   * 3. 按钮文本：空时使用$r('app.string.i_know')
   * 
   * 底部安全区域适配：
   * - 通过bottomRectHeight获取底部安全区域高度
   * - 在底部内边距中加上该高度
   * - 确保内容不被底部区域遮挡
   * 
   * 注意事项：
   * - contentBuilder默认指向contentBuilders空方法
   * - 判断条件：contentBuilders !== contentBuilder 表示使用了自定义构建器
   * - 底部内边距需要加上bottomRectHeight
   * - 使用资源文件确保多语言支持
   * 
   * @returns {void}
   */
  build() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.SpaceBetween
    }) {
      Column() {
        Text(!this.title ? $r('app.string.export_help') : this.title)
          .font({
            size: FontConstants.FONT_SIZE_16,
            weight: FontConstants.FONT_WEIGHT_500,
            family: CommonConstants.FAMILY_PingFANG
          })
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .fontColor($r('app.string.color_black_88'))
          .padding({
            bottom: PaddingConstants.PADDING_12
          })
        if (this.contentBuilders !== this.contentBuilder) {
          Column(){
            this.contentBuilder()
          }
          .padding({
            top: PaddingConstants.PADDING_12,
            bottom: PaddingConstants.PADDING_12
          })
        }
        if (this.isShowContent){
          Flex() {
            Text(!this.context ? HelpInfo.HELP_INFO_MESSAGE : this.context)
          }.padding({
            top: PaddingConstants.PADDING_12,
            bottom: PaddingConstants.PADDING_12
          })
        }

      }

      Button(!this.btnText ? $r('app.string.i_know') : this.btnText)
        .width('100%')
        .backgroundColor(this.theme.mainColor)
        .padding({
          left: PaddingConstants.PADDING_32,
          right: PaddingConstants.PADDING_32,
          top: PaddingConstants.PADDING_8,
          bottom: PaddingConstants.PADDING_8
        })
        .onClick(() => {
          this.btnClick()
        })
    }
    .height('100%')
    .padding({
      left: PaddingConstants.PADDING_20,
      right: PaddingConstants.PADDING_20,
      top: PaddingConstants.PADDING_12,
      bottom: PaddingConstants.PADDING_12 + this.bottomRectHeight
    })
  }
}

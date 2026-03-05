/**
 * @file Dialog.ets
 * @description 通用对话框组件
 * 
 * 功能概述：
 * 1. 提供高度可定制的通用对话框框架
 * 2. 支持自定义标题、按钮文本和内容
 * 3. 使用BuilderParam支持任意子组件内容
 * 4. 提供取消和确认操作回调
 * 
 * 使用场景：
 * - 需要自定义内容的对话框
 * - 表单输入、选择等复杂对话框
 * - 需要统一对话框样式的场景
 * 
 * 设计特点：
 * - 使用CustomDialog实现模态对话框
 * - 支持主题颜色配置
 * - 使用BuilderParam实现内容可扩展性
 * - 统一的按钮样式和布局
 * 
 * 技术特点：
 * - 使用@BuilderParam支持动态内容
 * - 支持自定义回调函数
 * - 使用Flex布局实现按钮等分布局
 * 
 * 可定制项：
 * - 标题文本
 * - 取消按钮文本
 * - 确认按钮文本
 * - 子组件内容（通过BuilderParam）
 * - 回调函数
 */

import { ThemeStorageKey } from '../../common/constants/Theme';
import { ThemeItem } from '../../common/model/Theme';

/**
 * @class Dialog
 * @description 通用对话框组件
 * 
 * 组件职责：
 * 1. 提供对话框基础框架
 * 2. 管理标题、按钮文本和内容
 * 3. 处理用户操作回调
 * 4. 应用主题颜色配置
 * 
 * @decorator @CustomDialog - 声明为自定义对话框组件
 */
@CustomDialog
export default struct Dialog {
  /** 
   * @prop controller - 对话框控制器
   * @description 控制对话框的打开和关闭，可选参数
   * @type {CustomDialogController | undefined}
   */
  controller?: CustomDialogController;
  
  /** 
   * @prop title - 对话框标题
   * @description 对话框中显示的标题文本
   * @default '标题' - 默认标题
   * @type {string}
   */
  @Prop title: string = '标题'
  
  /** 
   * @prop CancelString - 取消按钮文本
   * @description 取消按钮显示的文字内容
   * @default "取消" - 默认取消文本
   * @type {string}
   */
  @Prop CancelString: string = "取消"
  
  /** 
   * @prop ConfirmString - 确认按钮文本
   * @description 确认按钮显示的文字内容
   * @default "确定" - 默认确认文本
   * @type {string}
   */
  @Prop ConfirmString: string = "确定"
  
  /** 
   * @builderParam child - 子组件构建器
   * @description 用于插入自定义内容的构建器参数
   * @type {() => void}
   * @note 通过BuilderParam实现内容可扩展性，可以插入任意ArkTS组件
   */
  @BuilderParam child: () => void // 通用组件
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /** 
   * @prop ConfirmCallback - 确认回调函数
   * @description 用户点击确认按钮时调用的回调函数
   * @type {Function}
   */
  ConfirmCallback: () => void = () => {
  }

  /** 
   * @prop CancelCallback - 取消回调函数
   * @description 用户点击取消按钮时调用的回调函数
   * @type {Function}
   */
  CancelCallback: () => void = () => {
  }

  /**
   * @method build
   * @description 构建通用对话框UI
   * 
   * 布局结构：
   * 1. 顶部：对话框标题
   * 2. 中部：自定义内容区域（通过child构建器）
   * 3. 底部：取消和确认按钮
   * 
   * 标题样式：
   * - 字体：18px，500字重
   * - 行高：26px
   * - 使用Row容器
   * 
   * 内容区域：
   * - 通过child构建器动态插入内容
   * - 支持任意ArkTS组件
   * - 注释中提供了TextInput示例（当前未使用）
   * 
   * 按钮样式：
   * - 使用Flex布局，等间距分布
   * - 按钮尺寸：112x38px
   * - 取消按钮：次色背景 + 主色文字
   * - 确认按钮：主色背景 + 白色文字
   * - 按钮文字：14px，500字重，22px行高
   * 
   * 容器样式：
   * - 内边距：上下24px，左右24px
   * 
   * 交互逻辑：
   * - 点击取消：调用CancelCallback并关闭对话框
   * - 点击确认：调用ConfirmCallback并关闭对话框
   * 
   * 注释代码：
   * - 包含TextInput示例代码（注释状态）
   * - 展示了如何添加输入框等表单元素
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Row() {
        Text(this.title)
          .lineHeight(26)
          .font({
            size: 18,
            weight: 500
          })
      }

      if (this.child) {
        this.child()
      }
      // Row() {
      //   TextInput({ placeholder: this.placeholder })
      //     .maxLength(this.maxlength)
      //     .showCounter(true)
      //     .cancelButton({
      //       icon: {
      //         src: $r('app.media.close')
      //       }
      //     })
      // }
      // .margin({
      //   top: 16,
      //   bottom: 16
      // })

      Flex({
        justifyContent: FlexAlign.SpaceEvenly,
        alignItems: ItemAlign.Center
      }) {
        Button() {
          Text(this.CancelString)
            .fontColor(this.theme.mainColor)
            .lineHeight(22)
            .font({
              size: 14,
              weight: 500
            })
        }
        .width(112)
        .height(38)
        .backgroundColor(this.theme.secondColor)
        .onClick(() => {
          this.CancelCallback?.()
          if (this.controller != undefined) {
            this.controller.close()
          }
        })

        Button() {
          Text(this.ConfirmString)
            .fontColor("#FFFFFF")
            .lineHeight(22)
            .font({
              size: 14,
              weight: 500
            })
        }
        .width(112)
        .height(38)
        .backgroundColor(this.theme.mainColor)
        .onClick(() => {
          this.ConfirmCallback?.()
          if (this.controller != undefined) {
            this.controller.close()
          }
        })
      }
    }
    .padding({
      top: 24,
      bottom: 24,
      left: 24,
      right: 24
    })
  }
}

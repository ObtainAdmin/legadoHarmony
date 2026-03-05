/**
 * @file hideDialog.ets
 * @description 隐藏/显示对话框组件
 * 
 * 功能概述：
 * 1. 提供隐藏或显示操作的确认对话框
 * 2. 根据操作类型动态显示标题和提示信息
 * 3. 隐藏操作时显示额外的操作指南
 * 4. 提供取消和确认操作
 * 
 * 使用场景：
 * - 隐藏分组或内容的确认操作
 * - 显示已隐藏内容的确认操作
 * - 需要动态提示信息的确认对话框
 * 
 * 设计特点：
 * - 使用CustomDialog实现模态对话框
 * - 支持主题颜色配置
 * - 标题文本自适应大小（12-20px）
 * - 根据isHide状态动态显示内容
 * 
 * 交互特点：
 * - 标题动态显示"确定隐藏吗？"或"确定显示吗？"
 * - 隐藏操作时显示操作指南提示
 * - 显示操作时无额外提示
 * - 支持取消和确认操作
 * 
 * 技术特点：
 * - 使用三元运算符动态生成标题
 * - 根据isHide状态条件渲染提示信息
 * - 支持多控制器场景（注释说明）
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"

/**
 * @class hideDialogExample
 * @description 隐藏/显示对话框示例组件
 * 
 * 组件职责：
 * 1. 根据操作类型显示相应的确认信息
 * 2. 管理对话框的打开和关闭
 * 3. 处理用户确认和取消操作
 * 4. 应用主题颜色配置
 * 
 * @decorator @CustomDialog - 声明为自定义对话框组件
 */
@CustomDialog
export default struct hideDialogExample {
  /** 
   * @prop controller - 对话框控制器
   * @description 控制对话框的打开和关闭，可选参数
   * @type {CustomDialogController | undefined}
   * @note 若尝试在CustomDialog中传入多个其他的Controller，以实现在CustomDialog中打开另一个或另一些CustomDialog，那么此处需要将指向自己的controller放在所有controller的后面
   */
  controller?: CustomDialogController
  
  /** 
   * @prop cancel - 取消回调函数
   * @description 用户点击取消按钮时调用的回调函数
   * @type {Function}
   */
  cancel: () => void = () => {
  }
  
  /** 
   * @prop confirm - 确认回调函数
   * @description 用户点击确认按钮时调用的回调函数
   * @type {Function}
   */
  confirm: () => void = () => {
  }
  
  /** 
   * @prop title - 操作标题
   * @description 对话框中显示的操作对象标题（如分组名称）
   * @type {string}
   */
  @Prop title:string
  
  /** 
   * @prop isHide - 是否为隐藏操作
   * @description 控制对话框显示隐藏操作还是显示操作
   * @default true - 默认为隐藏操作
   * @type {boolean}
   */
  @Prop isHide:boolean = true
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method build
   * @description 构建隐藏/显示对话框UI
   * 
   * 布局结构：
   * 1. 顶部：确认提示标题（动态显示操作类型）
   * 2. 中部：可选显示操作指南（仅隐藏操作时显示）
   * 3. 底部：取消和确认按钮
   * 
   * 标题动态生成：
   * - 使用三元运算符：`确定${this.isHide?'隐藏':'显示'}吗？`
   * - 根据isHide状态显示"确定隐藏吗？"或"确定显示吗？"
   * - 字体大小自适应：12-20px
   * - 最大1行显示
   * - 600字重
   * - 上下边距：20px和10px
   * 
   * 操作指南提示：
   * - 仅当isHide为true（隐藏操作）时显示
   * - 内容："隐藏后可点击分组标签栏右侧分组管理入口查看隐藏分组并进入"
   * - 宽度：70%容器宽度
   * - 文本对齐：居中对齐
   * - 字体：14px，400字重，22px行高
   * - 颜色：45%黑色（rgba(0, 0, 0, 0.45)）
   * 
   * 按钮样式：
   * - 取消按钮：次色背景 + 主色文字
   * - 确认按钮：主色背景 + 白色文字
   * - 按钮圆角：15px
   * - 按钮内边距：左右30px，上下10px
   * - 按钮间距：24px
   * 
   * 交互逻辑：
   * - 点击取消：关闭对话框并调用cancel回调
   * - 点击确认：关闭对话框并调用confirm回调
   * 
   * 设计理念：
   * - 根据操作类型提供不同的用户体验
   * - 隐藏操作时提供操作指南，减少用户困惑
   * - 显示操作时简洁明了
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Text(`确定${this.isHide?'隐藏':'显示'}吗？` ).fontWeight(600).maxLines(1).minFontSize(12).maxFontSize(20).margin({ top: 20, bottom: 10 })
      if (this.isHide){
        Text('隐藏后可点击分组标签栏右侧分组管理入口查看隐藏分组并进入').width('70%').textAlign(TextAlign.Center)
          .fontColor('rgba(0, 0, 0, 0.45)').fontSize(14).fontWeight(400).lineHeight(22)
      }
      Row({space:24}) {
        Text('取消')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
              this.cancel()
            }
          })
          .borderRadius(15)
          .padding({left:30,right:30,top:10,bottom:10})
          .fontColor(this.theme.mainColor)
          .backgroundColor(this.theme.secondColor)
        Text('确认')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
              this.confirm()
            }
          })
          .borderRadius(15)
          .padding({left:30,right:30,top:10,bottom:10})
          .fontColor(Color.White)
          .backgroundColor(this.theme.mainColor)
      }.padding({top:20,bottom:20})
    }
  }
}

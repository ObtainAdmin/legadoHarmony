/**
 * @file myCenterInputDialog.ets
 * @description 我的中心输入对话框组件
 * 
 * 功能概述：
 * 1. 提供通用的输入对话框
 * 2. 支持标题、输入框、取消/确定按钮
 * 3. 应用主题颜色系统
 * 4. 支持自定义对话框控制器
 * 
 * 使用场景：
 * - 设备名称编辑对话框
 * - 通用文本输入对话框
 * - 需要用户输入确认的场景
 * 
 * 设计特点：
 * - 简洁的对话框布局
 * - 统一的主题颜色应用
 * - 清晰的按钮视觉区分
 * - 支持输入清除功能
 * 
 * 组件结构：
 * 1. Column容器：垂直布局，内边距24px，宽度284px，高度190px，白色背景，圆角15px
 * 2. 内容区域：标题和输入框
 * 3. 按钮区域：取消和确定按钮
 * 
 * 技术特点：
 * - 使用@CustomDialog装饰器声明自定义对话框
 * - 使用@Prop装饰器接收对话框配置
 * - 使用@Link装饰器实现输入值双向绑定
 * - 使用@StorageProp装饰器获取主题配置
 * - 使用@Builder装饰器创建可复用的按钮构建器
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"

/**
 * @struct myCenterInputDialog
 * @description 我的中心输入对话框组件
 * 
 * 组件职责：
 * 1. 提供输入对话框界面
 * 2. 管理输入值状态
 * 3. 处理对话框按钮事件
 * 4. 应用主题颜色系统
 * 
 * @decorator @CustomDialog - 声明为自定义对话框组件
 */
@CustomDialog
export struct myCenterInputDialog{
  /** 
   * @property controller - 对话框控制器
   * @description 控制对话框的显示/隐藏，由系统自动注入
   * @type {CustomDialogController | undefined}
   */
  controller?: CustomDialogController

  /** 
   * @property cancel - 取消回调函数
   * @description 点击取消按钮时的回调函数
   * @default () => {} - 默认空函数
   * @type {() => void}
   */
  cancel: () => void = () => {
  }
  
  /** 
   * @property confirm - 确认回调函数
   * @description 点击确定按钮时的回调函数
   * @default () => {} - 默认空函数
   * @type {() => void}
   */
  confirm: () => void = () => {
  }

  /** 
   * @prop title - 对话框标题
   * @description 对话框的标题文本
   * @default '' - 默认空字符串
   * @type {string}
   */
  @Prop title:string = ''
  
  /** 
   * @link value - 输入值
   * @description 输入框的值，与父组件双向绑定
   * @type {string}
   */
  @Link value:string
  
  /** 
   * @prop placeholder - 占位符
   * @description 输入框的占位符文本
   * @default "" - 默认空字符串
   * @type {string}
   */
  @Prop placeholder:string=""
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  /**
   * @builder button
   * @description 按钮构建器
   * 
   * 功能说明：
   * 1. 创建对话框按钮
   * 2. 处理按钮点击事件
   * 3. 应用按钮样式
   * 
   * 布局结构：
   * 1. Text容器：按钮文本
   *    - 点击事件：关闭对话框并调用回调函数
   *    - 圆角：40px（胶囊形状）
   *    - 内边距：左右30px，上下10px
   *    - 文字颜色：color[0]
   *    - 背景颜色：color[1]
   * 
   * 点击事件逻辑：
   * 1. 检查controller是否存在
   * 2. 如果存在，调用controller.close()关闭对话框
   * 3. 调用传入的confirm回调函数
   * 
   * 设计理念：
   * - 统一的按钮样式：胶囊形状，适当的间距
   * - 清晰的视觉反馈：点击后立即关闭对话框
   * - 灵活的颜色配置：通过参数传递颜色
   * 
   * 参数说明：
   * @param {string} title - 按钮标题文本
   * @param {Array<ResourceStr|Color>} color - 颜色数组
   *   - color[0]: 文字颜色
   *   - color[1]: 背景颜色
   * @param {() => void} confirm - 点击回调函数
   * 
   * 使用场景：
   * - 对话框的取消按钮
   * - 对话框的确定按钮
   * - 其他需要统一样式的按钮
   * 
   * 注意事项：
   * - 需要确保controller已正确注入
   * - 颜色数组必须包含两个元素
   * - 回调函数会在对话框关闭后执行
   * 
   * 扩展建议：
   * - 可以添加按钮禁用状态
   * - 可以添加按钮加载状态
   * - 可以添加按钮图标支持
   * 
   * @returns {void}
   */
  @Builder button(title:string,color:Array<ResourceStr|Color>,confirm: () => void){
    Text(title)
      .onClick(() => {
        if (this.controller != undefined) {
          this.controller.close()
          confirm();
        }
      })
      .borderRadius(40)
      .padding({left:30,right:30,top:10,bottom:10})
      .fontColor(color[0])
      .backgroundColor(color[1])
  }

  /**
   * @method build
   * @description 构建我的中心输入对话框组件UI
   * 
   * 布局结构：
   * 1. Column容器：垂直布局，间距24px，内边距24px，宽度284px，高度190px，白色背景，圆角15px
   * 2. 内容区域Column：垂直布局，间距16px
   *    - Text标题：对话框标题，16px字体，600字重
   *    - TextInput输入框：文本输入框
   *      * 字体大小：14px，行高22px
   *      * 宽度：196px
   *      * 内边距：左右20px，上下8px
   *      * 值绑定：this.value
   *      * 占位符：this.placeholder
   *      * 变化事件：更新this.value
   *      * 清除按钮：常量显示，14px清除图标，45%黑色
   * 3. 按钮区域Row：水平布局，间距12px
   *    - 取消按钮：使用button构建器
   *      * 标题："取消"
   *      * 颜色：[主题主色文字，主题次色背景]
   *      * 回调：this.cancel
   *    - 确定按钮：使用button构建器
   *      * 标题："确定"
   *      * 颜色：[白色文字，主题主色背景]
   *      * 回调：this.confirm
   * 
   * 输入框配置：
   * - cancelButton: 清除按钮配置
   *   * style: CancelButtonStyle.CONSTANT（常量显示）
   *   * icon: 清除图标
   *     - size: 14px
   *     - src: $r("app.media.clear_input_icon")
   *     - color: rgba(0, 0, 0, 0.45)（45%黑色）
   * 
   * 按钮颜色方案：
   * 1. 取消按钮：
   *    - 文字颜色：theme.mainColor（主题主色）
   *    - 背景颜色：theme.secondColor（主题次色）
   * 2. 确定按钮：
   *    - 文字颜色：Color.White（白色）
   *    - 背景颜色：theme.mainColor（主题主色）
   * 
   * 设计理念：
   * - 清晰的视觉层次：标题->输入框->按钮
   * - 统一的主题应用：使用主题颜色系统
   * - 友好的交互体验：输入框带清除按钮
   * - 明确的按钮区分：取消按钮次要，确定按钮主要
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中创建对话框控制器
   * deviceNameInfo: CustomDialogController | null = new CustomDialogController({
   *   builder: myCenterInputDialog({
   *     title: "设备名称",
   *     value: this.deviceNameValue,
   *     placeholder: "请输入设备名称",
   *     cancel: () => { this.onCancel() },
   *     confirm: () => { this.onAccept() }
   *   }),
   *   // ...其他配置
   * })
   * ```
   * 
   * 颜色说明：
   * 1. theme.mainColor: 主题主色，用于确定按钮背景和取消按钮文字
   * 2. theme.secondColor: 主题次色，用于取消按钮背景
   * 3. Color.White: 白色，用于确定按钮文字
   * 4. rgba(255, 255, 255, 1): 白色，用于对话框背景
   * 5. rgba(0, 0, 0, 0.45): 45%黑色，用于清除按钮图标
   * 
   * 图标说明：
   * 1. $r("app.media.clear_input_icon"): 清除输入图标
   * 
   * 注意事项：
   * - 对话框尺寸固定为284x190px
   * - 输入框宽度固定为196px
   * - 使用@Link确保输入值与父组件双向绑定
   * - 清除按钮始终显示（CancelButtonStyle.CONSTANT）
   * 
   * 扩展建议：
   * - 可以添加输入验证功能
   * - 可以添加输入类型支持（如数字、密码等）
   * - 可以添加对话框动画效果
   * - 可以添加键盘自动聚焦
   * - 可以支持多行文本输入
   * 
   * @returns {void}
   */
  build() {
    Column({space:24}) {
      Column({space:16}){
        Text(this.title)
          .fontWeight(600)
          .fontSize(16)
        TextInput({text:this.value,placeholder:this.placeholder})
          .fontSize(14).lineHeight(22)
          .width(196).padding({left:20,right:20,top:8,bottom:8})
          .onChange((value:string)=>{
            this.value=value
          })
          .cancelButton({
            style : CancelButtonStyle.CONSTANT,
            icon:{
              size:14,
              src:$r("app.media.clear_input_icon"),
              color: "rgba(0, 0, 0, 0.45)"
            }
          })
      }


      Row({space:12}) {
        this.button("取消",[this.theme.mainColor,this.theme.secondColor],this.cancel)
        this.button("确定",[Color.White,this.theme.mainColor],this.confirm)
      }
    }.padding(24)
    .width(284)
    .height(190)
    .backgroundColor("rgba(255, 255, 255, 1)")
    .borderRadius(15)
  }
}

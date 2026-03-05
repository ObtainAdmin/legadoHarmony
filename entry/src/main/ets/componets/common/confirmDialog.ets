/**
 * @file confirmDialog.ets
 * @description 确认对话框组件
 * 
 * 功能概述：
 * 1. 提供通用的确认对话框界面
 * 2. 支持自定义操作标题（如删除、确认等）
 * 3. 可选显示删除本地缓存的复选框
 * 4. 提供取消和确认操作
 * 
 * 使用场景：
 * - 删除操作前的确认提示
 * - 重要操作前的二次确认
 * - 需要用户明确确认的任何操作
 * 
 * 设计特点：
 * - 使用CustomDialog实现模态对话框
 * - 支持主题颜色配置
 * - 标题文本自适应大小（12-20px）
 * - 可选显示复选框选项
 * 
 * 交互特点：
 * - 标题动态显示操作类型（如"确定删除吗？"）
 * - 可选显示"同时删除本地缓存"复选框
 * - 支持取消和确认操作
 * 
 * 技术特点：
 * - 使用@Link实现双向数据绑定
 * - 支持多控制器场景（注释说明）
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"

/**
 * @class confirmDialogExample
 * @description 确认对话框示例组件
 * 
 * 组件职责：
 * 1. 显示确认提示信息
 * 2. 管理复选框状态（如果显示）
 * 3. 处理用户确认和取消操作
 * 4. 应用主题颜色配置
 * 
 * @decorator @CustomDialog - 声明为自定义对话框组件
 */
@CustomDialog
export default struct confirmDialogExample {
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
   * @description 对话框中显示的操作类型，如"删除"、"确认"等
   * @default '删除' - 默认操作类型
   * @type {string}
   */
  @Prop title:string = '删除'
  
  /** 
   * @link delCache - 删除缓存标志
   * @description 双向绑定的删除本地缓存复选框状态
   * @type {boolean}
   */
  @Link delCache:boolean
  
  /** 
   * @prop isShowCache - 是否显示缓存选项
   * @description 控制是否显示"同时删除本地缓存"复选框
   * @default false - 默认不显示
   * @type {boolean}
   */
  @Prop isShowCache:boolean = false
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method build
   * @description 构建确认对话框UI
   * 
   * 布局结构：
   * 1. 顶部：确认提示标题（动态显示操作类型）
   * 2. 中部：可选显示删除缓存复选框
   * 3. 底部：取消和确认按钮
   * 
   * 标题样式：
   * - 字体大小自适应：12-20px
   * - 最大1行显示
   * - 600字重
   * - 上下边距：20px和10px
   * 
   * 复选框样式：
   * - 使用主题主色作为选中颜色
   * - 复选框和文字间距8px
   * - 文字：14px字体，400字重，45%黑色
   * 
   * 按钮样式：
   * - 取消按钮：次色背景 + 主色文字
   * - 确认按钮：主色背景 + 白色文字
   * - 按钮圆角：15px
   * - 按钮内边距：左右30px，上下10px
   * 
   * 交互逻辑：
   * - 点击取消：关闭对话框并调用cancel回调
   * - 点击确认：关闭对话框并调用confirm回调
   * - 复选框：控制delCache状态
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Text(`确定${this.title}吗？` ).fontWeight(600).maxLines(1).minFontSize(12).maxFontSize(20).margin({ top: 20, bottom: 10 })
      if (this.isShowCache){
        Row({
          space:8
        }){
          Checkbox().selectedColor(this.theme.mainColor).select(this.delCache)
          Text('同时删除本地缓存')
            .fontColor('rgba(0, 0, 0, 0.45)').fontSize(14).fontWeight(400).lineHeight(22)
        }
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

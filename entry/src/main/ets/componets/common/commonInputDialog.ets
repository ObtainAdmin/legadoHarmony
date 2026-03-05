/**
 * @file commonInputDialog.ets
 * @description 通用单窗口输入对话框组件
 * 
 * 功能概述：
 * 1. 提供通用的文本输入对话框界面
 * 2. 支持自定义标题、占位符和输入限制
 * 3. 实现输入字数统计和限制提示
 * 4. 提供取消和确认操作
 * 
 * 使用场景：
 * - 需要用户输入文本的对话框场景
 * - 新增、编辑等表单输入操作
 * - 需要输入限制和统计的文本输入
 * 
 * 设计特点：
 * - 使用CustomDialog实现模态对话框
 * - 支持主题颜色配置
 * - 包含输入字数实时统计
 * - 输入达到限制时显示提示消息
 * - 使用项目常量统一内边距
 * 
 * 交互特点：
 * - 输入框带清空按钮
 * - 实时显示剩余字数（可选）
 * - 达到字数限制时显示提示
 * - 支持取消和确认操作
 * 
 * 主要传值参数：
 * - title: 对话框标题
 * - textValue: 输入框值（双向绑定）
 * - cancel: 取消回调方法
 * - confirm: 确认回调方法
 */

import PaddingConstants from '../../common/constants/PaddingConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'
import { showMessage } from './promptShow'

/**
 * @class commonInputDialog
 * @description 通用输入对话框组件
 * 
 * 组件职责：
 * 1. 管理文本输入和字数统计
 * 2. 控制对话框的打开和关闭
 * 3. 处理输入限制和提示
 * 4. 提供用户操作回调
 * 
 * @decorator @CustomDialog - 声明为自定义对话框组件
 */
@CustomDialog
export default struct commonInputDialog {
  /** 
   * @prop controller - 对话框控制器
   * @description 控制对话框的打开和关闭，可选参数
   * @type {CustomDialogController | undefined}
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
   * @state ValueLength - 输入内容长度
   * @description 当前输入内容的字符长度，用于字数统计
   * @default 0 - 初始长度为0
   * @type {number}
   */
  @State ValueLength:number = 0
  
  /** 
   * @prop title - 对话框标题
   * @description 对话框顶部显示的标题文本
   * @default '新增' - 默认标题
   * @type {string}
   */
  @Prop title:string = '新增'
  
  // @Prop titleWidth:string = '80%' // 注释掉的标题宽度属性
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * @method build
   * @description 构建对话框主UI
   * 
   * 布局结构：
   * 1. 顶部：对话框标题
   * 2. 中部：文本输入区域（通过input构建器）
   * 3. 底部：取消和确认按钮
   * 
   * 样式特点：
   * - 对话框背景为白色
   * - 使用项目常量控制内边距（PADDING_20）
   * - 使用主题颜色配置按钮样式
   * - 取消按钮使用次要颜色，确认按钮使用主色
   * 
   * 交互逻辑：
   * - 点击取消：关闭对话框并调用cancel回调
   * - 点击确认：调用confirm回调并关闭对话框
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Text(`${this.title}` ).fontWeight(600).fontSize(20).margin({ top: 20, bottom: 10 })
      this.input()
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
              this.confirm()
              this.controller.close()
            }
          })
          .borderRadius(15)
          .padding({left:30,right:30,top:10,bottom:10})
          .fontColor(Color.White)
          .backgroundColor(this.theme.mainColor)
      }.padding({top:PaddingConstants.PADDING_20,bottom:PaddingConstants.PADDING_20})
    }
    .padding({left:PaddingConstants.PADDING_20,right:PaddingConstants.PADDING_20})
    .backgroundColor(Color.White)
  }
  
  /** 
   * @prop placeholder - 输入框提示文本
   * @description 输入框中显示的占位符文本
   * @default '请输入内容' - 默认提示文本
   * @type {string}
   */
  @Prop placeholder:string = '请输入内容'
  
  /** 
   * @link textValue - 输入框值
   * @description 双向绑定的输入框文本值，与父组件同步
   * @type {string}
   */
  @Link textValue:string
  
  /** 
   * @prop maxLength - 最大输入长度
   * @description 输入框允许的最大字符数
   * @default 20 - 默认最大20个字符
   * @type {number}
   */
  @Prop maxLength:number = 20
  
  /** 
   * @prop isShowCount - 是否显示字数统计
   * @description 控制是否显示剩余字数统计
   * @default false - 默认不显示
   * @type {boolean}
   */
  @Prop isShowCount:boolean = false
  
  /**
   * @builder input
   * @description 文本输入区域构建器
   * 
   * 功能特点：
   * 1. 提供文本输入框
   * 2. 支持清空按钮
   * 3. 实时字数统计和限制
   * 4. 可选显示剩余字数
   * 
   * 布局结构：
   * 1. 左侧：文本输入框
   * 2. 右侧：可选的字数统计显示
   * 
   * 交互逻辑：
   * - 文本变化：更新字数统计和textValue
   * - 达到最大长度：显示提示消息
   * - 清空按钮：点击可清空输入内容
   * 
   * 样式特点：
   * - 输入框高度40px
   * - 带清空按钮（使用clear图标）
   * - 字数统计：10px字体，600字重
   * - 达到限制时文字变为红色
   * - 动态偏移：根据输入内容长度调整位置
   * 
   * 动态偏移逻辑：
   * - 有输入内容：右偏移70px
   * - 无输入内容：右偏移40px
   * 
   * @returns {void}
   */
  @Builder input(){
    Row(){
      // 文本输入框
      TextInput({ placeholder: this.placeholder, text: this.textValue })
        .cancelButton({icon:{src:$r('app.media.clear')}}) // 清空按钮
        .height(40)
        .onChange((value: string) => {
          this.ValueLength = value.length; // 更新字数统计
          
          // 达到最大长度时显示提示
          if(this.maxLength === value.length){
            showMessage(`超出输入范围,最长可输入${this.maxLength}字符`)
          }
          this.textValue = value; // 更新双向绑定数据
        })
        .maxLength(this.maxLength) // 设置最大输入长度
        
      // 可选的字数统计显示
      if (this.isShowCount && this.maxLength - this.ValueLength !== 0){
        Row(){
          Text(JSON.stringify(this.maxLength - this.ValueLength)) // 剩余字数
            .fontSize(10).fontWeight(600)
            .fontColor(this.maxLength - this.ValueLength ===0?Color.Red:'') // 达到限制时变红
          Text('/') // 分隔符
            .fontSize(10).fontWeight(600)
            .fontColor(10 - this.ValueLength ===0?Color.Red:'') // 注意：这里应该是this.maxLength
          Text(JSON.stringify(this.maxLength)) // 总字数限制
            .fontSize(10).fontWeight(600)
            .fontColor(10 - this.ValueLength ===0?Color.Red:'') // 注意：这里应该是this.maxLength
        }.offset({x:this.ValueLength>0?-70:-40}) // 动态右偏移
      }

    }
    .alignItems(VerticalAlign.Center) // 垂直居中对齐
  }
}

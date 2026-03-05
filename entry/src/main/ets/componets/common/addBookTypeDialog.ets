/**
 * @file addBookTypeDialog.ets
 * @description 添加书籍分类对话框组件
 * 
 * 功能概述：
 * 1. 提供新建书籍分组的输入界面
 * 2. 实现输入字数统计和限制（最大10个字符）
 * 3. 提供输入达到限制时的抖动动画效果
 * 4. 支持清空输入内容
 * 5. 提供取消和确认操作
 * 
 * 使用场景：
 * - 添加新的书籍分类或分组
 * - 编辑现有分类名称
 * - 需要输入限制和动画反馈的表单场景
 * 
 * 设计特点：
 * - 使用CustomDialog实现模态对话框
 * - 支持主题颜色配置
 * - 包含输入字数实时统计
 * - 输入达到限制时触发抖动动画
 * - 动态显示剩余字数/清空按钮
 * 
 * 交互特点：
 * - 输入框实时显示剩余字数
 * - 达到字数限制时输入框抖动提示
 * - 达到字数限制时显示"清空"按钮
 * - 支持取消和确认操作
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"

/**
 * @class addBookTypeDialog
 * @description 添加书籍分类对话框组件
 * 
 * 组件职责：
 * 1. 管理书籍分类名称的输入
 * 2. 控制输入字数统计和限制
 * 3. 处理对话框的打开和关闭
 * 4. 提供动画反馈和用户交互
 * 
 * @decorator @CustomDialog - 声明为自定义对话框组件
 */
@CustomDialog
export default struct addBookTypeDialog {
  /** 
   * @link bookType - 书籍分类名称
   * @description 双向绑定的书籍分类名称，与父组件同步
   * @type {string}
   */
  @Link bookType:string

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
   * @state BookTypeValueLength - 输入内容长度
   * @description 当前输入内容的字符长度，用于字数统计
   * @default 0 - 初始长度为0
   * @type {number}
   */
  @State BookTypeValueLength:number = 0
  
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
   * 1. 顶部：对话框标题"新建分组"
   * 2. 中部：分类名称输入区域（通过inputBookType构建器）
   * 3. 底部：取消和确认按钮
   * 
   * 样式特点：
   * - 对话框宽度为80%屏幕宽度
   * - 使用主题颜色配置按钮样式
   * - 取消按钮使用次要颜色，确认按钮使用主色
   * 
   * 交互逻辑：
   * - 点击取消：关闭对话框并调用cancel回调
   * - 点击确认：关闭对话框并调用confirm回调
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Text(`新建分组` ).fontWeight(600).fontSize(20).margin({ top: 20, bottom: 10 })
      this.inputBookType()
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
    }.width('80%')
  }
  
  /** 
   * @state translateX - 水平平移距离
   * @description 控制输入框抖动动画的水平偏移量
   * @default 0 - 初始无偏移
   * @type {number}
   */
  @State translateX: number = 0;
  
  /**
   * @builder inputBookType
   * @description 书籍分类输入区域构建器
   * 
   * 功能特点：
   * 1. 提供文本输入框用于输入分类名称
   * 2. 实时显示剩余字数统计
   * 3. 输入达到限制时触发抖动动画
   * 4. 达到限制时显示"清空"按钮
   * 
   * 布局结构：
   * 1. 左侧：文本输入框
   * 2. 右侧：动态显示区域
   *   - 未达限制：显示剩余字数（如"3/10"）
   *   - 达到限制：显示"清空"按钮
   * 
   * 交互逻辑：
   * - 文本变化：更新bookType和字数统计
   * - 达到10字限制：触发抖动动画，显示红色边框
   * - 点击清空按钮：清空输入内容
   * 
   * 动画效果：
   * - 使用animateTo实现抖动动画
   * - 持续时间200ms，重复4次
   * - 通过translateX控制水平偏移
   * 
   * 样式特点：
   * - 输入框高度40px
   * - 达到限制时显示0.5px红色边框
   * - 剩余字数/清空按钮右偏移40px
   * - 达到限制时文字变为红色
   * 
   * @returns {void}
   */
  @Builder inputBookType(){
    Row(){
      // 文本输入框
      TextInput({ placeholder: '请输入分组名称', text: this.bookType }).height(40)
        .onChange((value: string) => {
          this.bookType = value; // 更新双向绑定数据
          this.BookTypeValueLength = value.length; // 更新字数统计
          
          // 达到字数限制时触发抖动动画
          if (10 - this.BookTypeValueLength === 0) {
            animateTo({
              duration: 200,
              // curve: curves.springCurve(100, 0, 50, 10), // 注释掉的弹簧曲线
              iterations: 4, // 重复4次
            },
              () => {
                // 抖动动画偏移量
                this.translateX = 10;
              })
            this.translateX = 0; // 动画结束后复位
          }
        })
        .translate({ x: this.translateX}) // 应用水平平移实现抖动效果
        .border({width:10 - this.BookTypeValueLength===0?0.5:0, color: Color.Red }) // 达到限制时显示红色边框
        .maxLength(10) // 最大输入10个字符
      
      // 右侧动态显示区域
      if (10 - this.BookTypeValueLength !== 0){
        // 未达限制：显示剩余字数（如"3/10"）
        Row(){
          Text(JSON.stringify(10 - this.BookTypeValueLength)) // 剩余字数
            .fontSize(10).fontWeight(600)
            .fontColor(10 - this.BookTypeValueLength ===0?Color.Red:'') // 达到限制时变红
          Text('/') // 分隔符
            .fontSize(10).fontWeight(600)
            .fontColor(10 - this.BookTypeValueLength ===0?Color.Red:'')
          Text('10') // 总字数限制
            .fontSize(10).fontWeight(600)
            .fontColor(10 - this.BookTypeValueLength ===0?Color.Red:'')
        }.offset({x:-40}) // 右偏移40px
      } else {
        // 达到限制：显示"清空"按钮
        Text('清空')
          .fontSize(12).fontWeight(500).fontColor(Color.Red)
          .onClick(()=>{
            this.bookType = ''; // 清空输入内容
          })
          .offset({x:-40}) // 右偏移40px
      }

    }
    .alignItems(VerticalAlign.Center) // 垂直居中对齐
  }
}

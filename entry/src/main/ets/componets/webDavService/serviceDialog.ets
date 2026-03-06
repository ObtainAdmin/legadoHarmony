/**
 * serviceDialog 组件 - WebDAV服务对话框组件
 * 
 * 功能概述：
 * 1. 提供通用的服务对话框，支持文本显示和操作确认
 * 2. 集成主题系统，支持动态主题颜色的按钮样式
 * 3. 实现自定义对话框控制器，支持打开和关闭管理
 * 4. 提供取消和确定按钮，支持自定义回调函数
 * 
 * 设计特点：
 * 1. 简洁布局：使用Column和Row构建对话框结构
 * 2. 主题集成：按钮使用主题主色和次色
 * 3. 自定义对话框：使用@CustomDialog装饰器实现对话框组件
 * 4. 按钮复用：使用@Builder构建可复用的按钮组件
 * 5. 视觉设计：270px宽度，15px圆角，白色背景
 * 
 * 使用场景：
 * 1. WebDAV服务相关的确认对话框
 * 2. 需要显示文本信息和操作确认的弹窗
 * 3. 需要集成主题系统的对话框组件
 * 
 * 组件结构：
 * - 标题区域：显示对话框标题
 * - 内容区域：显示文本内容（根据类型）
 * - 按钮区域：取消和确定按钮
 * 
 * 注意事项：
 * 1. 需要正确处理对话框控制器的关闭
 * 2. 主题颜色需要动态应用到按钮
 * 3. 回调函数需要正确绑定和调用
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"


@CustomDialog
export struct serviceDialog{

  /**
   * 对话框控制器
   * @type {CustomDialogController}
   * @description 控制对话框的打开和关闭
   * 若尝试在CustomDialog中传入多个其他的Controller，以实现在CustomDialog中打开另一个或另一些CustomDialog，那么此处需要将指向自己的controller放在所有controller的后面
   */
  controller?: CustomDialogController
  
  /**
   * 取消回调函数
   * @type {Function}
   * @default () => {}
   * @description 取消操作的回调函数
   */
  cancel: () => void = () => {
  }
  
  /**
   * 确认回调函数
   * @type {Function}
   * @default () => {}
   * @description 确认操作的回调函数
   */
  confirm: () => void = () => {
  }

  /**
   * 标题
   * @type {string}
   * @default ''
   * @description 对话框标题文本
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop title:string = ''
  
  /**
   * 值
   * @type {string}
   * @default ""
   * @description 对话框显示的文本内容
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop value:string=""
  
  /**
   * 类型
   * @type {string}
   * @default "text"
   * @description 对话框内容类型（当前仅支持text）
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop type:string="text"
  /**
   * 按钮构建器
   * @param {string} title - 按钮标题
   * @param {Array<ResourceStr|Color>} color - 颜色数组 [字体颜色, 背景颜色]
   * @param {Function} confirm - 确认回调函数
   * @returns {void}
   * @description 构建可复用的按钮组件
   * 40px圆角，30px左右内边距，10px上下内边距
   */
  @Builder button(title:string,color:Array<ResourceStr|Color>,confirm: () => void){
    Text(title) // 按钮文本
      .onClick(() => {
        /**
         * 按钮点击事件
         * @description 关闭对话框并调用确认回调
         */
        if (this.controller != undefined) {
          this.controller.close() // 关闭对话框
          confirm(); // 调用回调函数
        }
      })
      .borderRadius(40) // 40px圆角
      .padding({left:30,right:30,top:10,bottom:10}) // 内边距
      .fontColor(color[0]) // 字体颜色
      .backgroundColor(color[1]) // 背景颜色
  }
  
  /**
   * 主题配置
   * @type {ThemeItem}
   * @description 从存储中读取的主题配置
   * @storageprop 使用@StorageProp装饰器从存储中读取数据
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建服务对话框的完整UI结构
   * 包含标题、内容和按钮区域
   */
  build() {
    Column({space:15}) { // 15px间距
      /**
       * 标题区域
       * @description 显示对话框标题，16px字体，600字重
       */
      Text(this.title) // 标题文本
        .fontWeight(600) // 600字重
        .fontSize(16) // 16px字体
      
      /**
       * 内容区域
       * @description 根据类型显示内容，当前仅支持文本类型
       */
      if(this.type=="text"){
        Text(this.value) // 内容文本
          .fontWeight(600) // 600字重
          .fontSize(14) // 14px字体
          .size({width:"80%"}) // 80%宽度
          .fontColor("rgba(0, 0, 0, 0.45)") // 45%黑色字体
          .textAlign(TextAlign.Center) // 居中对齐
          .lineHeight(25) // 25px行高
      }
      
      /**
       * 按钮区域
       * @description 24px间距，包含取消和确定按钮
       */
      Row({space:24}) {
        /**
         * 取消按钮
         * @description 主题主色字体，主题次色背景
         */
        this.button("取消",[this.theme.mainColor, this.theme.secondColor],this.cancel)
        
        /**
         * 确定按钮
         * @description 白色字体，主题主色背景
         */
        this.button("确定",[Color.White,this.theme.mainColor],this.confirm)
      }.padding({top:10}) // 顶部10px内边距
    }
    .padding({top:20,bottom:20}) // 上下20px内边距
    .width(270) // 270px宽度
    .backgroundColor("rgba(255, 255, 255, 1)") // 白色背景
    .borderRadius(15) // 15px圆角
  }
}

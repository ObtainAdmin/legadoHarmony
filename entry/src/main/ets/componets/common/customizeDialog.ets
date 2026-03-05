/**
 * @file customizeDialog.ets
 * @description 自定义标题和内容对话框组件
 * 
 * 功能概述：
 * 1. 提供自定义标题和内容的对话框界面
 * 2. 支持显示较长的说明性文本内容
 * 3. 提供确认操作按钮
 * 
 * 使用场景：
 * - 功能说明和提示对话框
 * - 操作指南和帮助信息显示
 * - 需要展示较长文本内容的对话框
 * 
 * 设计特点：
 * - 使用CustomDialog实现模态对话框
 * - 支持主题颜色配置
 * - 标题文本自适应大小（12-20px）
 * - 内容区域宽度限制为70%
 * 
 * 交互特点：
 * - 标题动态显示
 * - 内容文本可显示较长说明
 * - 只有一个确认按钮（无取消按钮）
 * 
 * 示例内容：
 * - 标题："标签锁"
 * - 内容："长按底部tab栏书架图标可锁定分组标签栏，再次长按解锁，锁定后左右滑动将直接切换小说，漫画，有声书分组大类"
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"

/**
 * @class customizeDialogExample
 * @description 自定义对话框示例组件
 * 
 * 组件职责：
 * 1. 显示自定义标题和内容
 * 2. 管理对话框的打开和关闭
 * 3. 应用主题颜色配置
 * 
 * @decorator @CustomDialog - 声明为自定义对话框组件
 */
@CustomDialog
export default struct customizeDialogExample {
  /** 
   * @prop controller - 对话框控制器
   * @description 控制对话框的打开和关闭，可选参数
   * @type {CustomDialogController | undefined}
   */
  controller?: CustomDialogController
  
  /** 
   * @prop confirm - 确认回调函数
   * @description 用户点击确认按钮时调用的回调函数（当前未使用）
   * @type {Function}
   */
  confirm: () => void = () => {
  }
  
  /** 
   * @prop title - 对话框标题
   * @description 对话框中显示的标题文本
   * @default '标签锁' - 默认标题
   * @type {string}
   */
  @Prop title:string = '标签锁'
  
  /** 
   * @prop content - 对话框内容
   * @description 对话框中显示的详细说明文本
   * @default '长按底部tab栏书架图标可锁定分组标签栏，再次长按解锁，锁定后左右滑动将直接切换小说，漫画，有声书分组大类' - 默认内容
   * @type {string}
   */
  @Prop content:string = '长按底部tab栏书架图标可锁定分组标签栏，再次长按解锁，锁定后左右滑动将直接切换小说，漫画，有声书分组大类'
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method build
   * @description 构建自定义对话框UI
   * 
   * 布局结构：
   * 1. 顶部：自定义标题（自适应字体大小）
   * 2. 中部：自定义内容文本（宽度70%限制）
   * 3. 底部：确认按钮
   * 
   * 标题样式：
   * - 字体大小自适应：12-20px
   * - 最大1行显示
   * - 600字重
   * - 上下边距：20px和10px
   * 
   * 内容样式：
   * - 宽度：70%容器宽度
   * - 字体：14px，400字重，22px行高
   * - 颜色：45%黑色（rgba(0, 0, 0, 0.45)）
   * - 使用Row容器，间距8px
   * 
   * 按钮样式：
   * - 只有一个确认按钮
   * - 使用主题主色作为背景
   * - 白色文字
   * - 按钮圆角：15px
   * - 按钮内边距：左右30px，上下10px
   * 
   * 交互逻辑：
   * - 点击确认：关闭对话框
   * - 注意：confirm回调函数当前未调用（注释状态）
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Text(`${this.title}` ).fontWeight(600).maxLines(1).minFontSize(12).maxFontSize(20).margin({ top: 20, bottom: 10 })
      Row({
        space:8
      }){
        Text(this.content)
          .width('70%')
          .fontColor('rgba(0, 0, 0, 0.45)').fontSize(14).fontWeight(400).lineHeight(22)
      }
      Row({space:24}) {
        Text('确认')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
              // this.confirm()
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

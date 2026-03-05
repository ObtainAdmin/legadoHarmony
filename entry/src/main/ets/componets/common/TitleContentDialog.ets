/**
 * @file TitleContentDialog.ets
 * @description 自定义标题和内容弹窗组件
 * 
 * 功能概述：
 * 1. 提供自定义标题和内容的确认弹窗
 * 2. 支持确认和取消操作
 * 3. 根据内容长度条件显示内容区域
 * 4. 使用主题颜色配置按钮样式
 * 
 * 使用场景：
 * - 需要用户确认的操作弹窗
 * - 删除确认、操作确认等场景
 * - 需要显示详细内容的确认对话框
 * 
 * 设计特点：
 * - 使用@CustomDialog装饰器声明为自定义弹窗
 * - 支持自定义标题和内容
 * - 条件渲染内容区域（内容为空时不显示）
 * - 使用主题颜色配置按钮样式
 * 
 * 弹窗结构：
 * 1. 标题区域：显示确认标题（格式："确定{title}吗？"）
 * 2. 内容区域：条件显示详细内容
 * 3. 按钮区域：取消和确认按钮
 * 
 * 按钮样式：
 * 1. 取消按钮：
 *   - 文字："取消"
 *   - 文字颜色：主题主色
 *   - 背景色：主题次色
 *   - 圆角：15px
 *   - 内边距：左右30px，上下10px
 * 
 * 2. 确认按钮：
 *   - 文字："确认"
 *   - 文字颜色：白色
 *   - 背景色：主题主色
 *   - 圆角：15px
 *   - 内边距：左右30px，上下10px
 * 
 * 交互逻辑：
 * - 点击取消：关闭弹窗并调用cancel回调
 * - 点击确认：关闭弹窗并调用confirm回调
 * 
 * 技术特点：
 * - 使用CustomDialogController控制弹窗显示/关闭
 * - 支持主题颜色配置
 * - 条件渲染优化性能
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"

/**
 * @class TitleContentDialog
 * @description 自定义标题和内容弹窗组件
 * 
 * 组件职责：
 * 1. 显示自定义标题和内容的确认弹窗
 * 2. 管理弹窗的显示和关闭
 * 3. 处理用户确认和取消操作
 * 4. 应用主题颜色配置
 * 
 * @decorator @CustomDialog - 声明为自定义弹窗组件
 */
@CustomDialog
export default struct TitleContentDialog {
  /** 
   * @prop controller - 弹窗控制器
   * @description 控制弹窗显示和关闭的控制器，可选
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
   * @prop title - 弹窗标题
   * @description 弹窗显示的业务标题，会格式化为"确定{title}吗？"
   * @default '' - 默认空字符串
   * @type {string}
   */
  @Prop title:string = ''
  
  /** 
   * @prop content - 弹窗内容
   * @description 弹窗显示的详细内容，为空时不显示内容区域
   * @default '' - 默认空字符串
   * @type {string}
   */
  @Prop content:string = ''
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * @method build
   * @description 构建弹窗UI
   * 
   * 布局结构：
   * 1. 外层Column：垂直布局容器
   * 2. 标题Text：显示确认标题
   * 3. 条件Row：内容区域（当content长度>0时显示）
   * 4. 按钮Row：取消和确认按钮
   * 
   * 标题样式：
   * - 内容：`确定${this.title}吗？`（格式化标题）
   * - 字重：600（半粗体）
   * - 最大行数：1行
   * - 字体大小：12-20px自适应
   * - 边距：顶部20px，底部10px
   * 
   * 内容区域条件显示：
   * - 显示条件：this.content.length > 0
   * - 布局：Row水平布局，8px间距
   * - 文本样式：
   *   * 内容：this.content
   *   * 宽度：70%容器宽度
   *   * 颜色：rgba(0, 0, 0, 0.45)（45%黑色，半透明）
   *   * 字体：14px，400字重
   *   * 行高：22px
   *   * 对齐：居中对齐
   * 
   * 按钮区域样式：
   * - 布局：Row水平布局，24px间距
   * - 内边距：顶部20px，底部20px
   * 
   * 取消按钮交互：
   * - 点击事件：关闭弹窗并调用cancel回调
   * - 关闭条件：controller不为undefined
   * - 调用顺序：先关闭弹窗，后调用回调
   * 
   * 确认按钮交互：
   * - 点击事件：关闭弹窗并调用confirm回调
   * - 关闭条件：controller不为undefined
   * - 调用顺序：先关闭弹窗，后调用回调
   * 
   * 设计理念：
   * - 清晰的标题格式："确定{操作}吗？"
   * - 可选的内容区域，避免空内容占用空间
   * - 明显的按钮颜色区分（取消：次色，确认：主色）
   * - 统一的圆角和内边距
   * 
   * 使用示例：
   * ```typescript
   * // 显示删除确认弹窗
   * TitleContentDialog({
   *   title: '删除',
   *   content: '删除后无法恢复，请谨慎操作',
   *   cancel: () => console.log('取消删除'),
   *   confirm: () => console.log('确认删除')
   * })
   * ```
   * 
   * 注意事项：
   * - 标题会自动格式化为"确定{title}吗？"
   * - 内容为空时不显示内容区域
   * - 需要确保controller正确设置才能关闭弹窗
   * - 按钮颜色使用主题配置，确保一致性
   * 
   * 弹窗控制器使用：
   * - 通常由外部组件创建并传递controller
   * - 通过controller.open()显示弹窗
   * - 通过controller.close()关闭弹窗
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Text(`确定${this.title}吗？` ).fontWeight(600).maxLines(1).minFontSize(12).maxFontSize(20).margin({ top: 20, bottom: 10 })
      if (this.content.length > 0){
        Row({
          space:8
        }){
          Text(this.content)
            .width('70%')
            .fontColor('rgba(0, 0, 0, 0.45)').fontSize(14).fontWeight(400).lineHeight(22).textAlign(TextAlign.Center)
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

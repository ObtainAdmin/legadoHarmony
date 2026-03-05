/**
 * @file buttonCommon.ets
 * @description 通用确认取消按钮组件
 * 
 * 功能概述：
 * 1. 提供标准化的确认和取消按钮对
 * 2. 支持自定义按钮文本
 * 3. 使用主题颜色配置按钮样式
 * 4. 提供按钮点击回调函数
 * 
 * 使用场景：
 * - 对话框的底部操作按钮区域
 * - 表单提交和取消操作
 * - 需要标准按钮对的任何界面
 * 
 * 设计特点：
 * - 按钮使用圆角设计（borderRadius: 200）
 * - 确认按钮使用主题主色，取消按钮使用主题次色
 * - 按钮固定尺寸（150x40px）
 * - 按钮间有固定间距（20px）
 * 
 * 主题支持：
 * - 从本地存储获取主题配置
 * - 确认按钮背景使用theme.mainColor
 * - 取消按钮背景使用theme.secondColor
 * - 取消按钮文字使用theme.mainColor
 * 
 * @author 2008
 * @datetime 2024/6/23 1:02
 */

import CommonConstants from '../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'

/**
 * @class buttonCommon
 * @description 通用按钮组件
 * 
 * 组件职责：
 * 1. 提供标准化的确认和取消按钮
 * 2. 管理按钮点击事件回调
 * 3. 应用主题颜色配置
 * 4. 支持按钮文本自定义
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct buttonCommon {
  /** 
   * @prop sureTitle - 确认按钮文本
   * @description 确认按钮显示的文字内容
   * @default '确定' - 默认确认文本
   * @type {string}
   */
  @Prop sureTitle:string = '确定'
  
  /** 
   * @prop cancelTitle - 取消按钮文本
   * @description 取消按钮显示的文字内容
   * @default '取消' - 默认取消文本
   * @type {string}
   */
  @Prop cancelTitle:string = '取消'
  
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
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method build
   * @description 构建通用按钮UI
   * 
   * 布局结构：
   * 1. 外层Flex容器：居中布局
   * 2. 内层Row容器：水平排列两个按钮
   *   - 左侧：取消按钮
   *   - 右侧：确认按钮
   * 
   * 按钮样式：
   * - 尺寸：150x40px（固定大小）
   * - 圆角：200（完全圆角）
   * - 内边距：左右32px，上下8px
   * - 取消按钮：次色背景 + 主色文字
   * - 确认按钮：主色背景 + 白色文字
   * 
   * 容器样式：
   * - 宽度：100%屏幕宽度（FULL_WIDTH）
   * - 高度：64px
   * - 内边距：上下12px
   * - 水平居中布局
   * 
   * 交互逻辑：
   * - 点击取消按钮：调用cancel回调
   * - 点击确认按钮：调用confirm回调
   * 
   * @returns {void}
   */
  build() {
    Flex(){
      Row({space: 20}) {
        Button(this.cancelTitle)
          .padding({left: 32, right: 32, top: 8, bottom: 8})
          .width(150)
          .height(40)
          .borderRadius(200)
          .backgroundColor(this.theme.secondColor)
          .fontColor(this.theme.mainColor)
          .onClick(() => {
              this.cancel()
          })
        Button(this.sureTitle)
          .padding({left: 32, right: 32, top: 8, bottom: 8})
          .width(150)
          .height(40)
          .borderRadius(200)
          .backgroundColor(this.theme.mainColor)
          .fontColor('#FFFFFF')
          .onClick(()=>{
            this.confirm()
          })
      }
      .padding({top: 12, bottom: 12})
      .justifyContent(FlexAlign.Center)
      .width(CommonConstants.FULL_WIDTH)
      .height(64)
    }
  }
}

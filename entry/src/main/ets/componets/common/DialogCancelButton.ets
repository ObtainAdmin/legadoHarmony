/**
 * @file DialogCancelButton.ets
 * @description 弹窗底部取消按钮组件
 * 
 * 功能概述：
 * 1. 提供标准化的弹窗底部取消按钮
 * 2. 支持自定义按钮文本
 * 3. 可选显示顶部分隔线
 * 4. 提供按钮点击回调
 * 
 * 使用场景：
 * - 对话框底部的取消操作按钮
 * - 弹窗的底部操作区域
 * - 需要统一取消按钮样式的场景
 * 
 * 设计特点：
 * - 使用项目常量统一字体和内边距
 * - 可选显示顶部Divider分隔线
 * - 简洁的文本按钮设计
 * - 垂直排列布局
 * 
 * 样式特点：
 * - 字体：16px，400字重，24px行高
 * - 内边距：上下16px（使用项目常量）
 * - 分隔线：可选显示
 * 
 * @author 2008
 * @datetime 2024/7/19 21:15
 */

import FontConstants from '../../common/constants/FontConstants'
import PaddingConstants from '../../common/constants/PaddingConstants'

/**
 * @class DialogCancelButton
 * @description 弹窗底部取消按钮组件
 * 
 * 组件职责：
 * 1. 提供标准化的取消按钮样式
 * 2. 管理按钮点击事件
 * 3. 控制分隔线显示
 * 4. 支持文本自定义
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct DialogCancelButton{
  /** 
   * @prop btnClick - 按钮点击回调函数
   * @description 用户点击按钮时调用的回调函数
   * @type {Function}
   */
  btnClick: Function = () => {

  }
  
  /** 
   * @prop isShowDivider - 是否显示分隔线
   * @description 控制是否在按钮上方显示Divider分隔线
   * @default true - 默认显示分隔线
   * @type {boolean}
   */
  isShowDivider: boolean = true
  
  /** 
   * @prop title - 按钮文本
   * @description 按钮显示的文字内容
   * @default '取消' - 默认取消文本
   * @type {string}
   */
  @Prop title: string = '取消'
  
  /**
   * @method build
   * @description 构建取消按钮UI
   * 
   * 布局结构：
   * 1. 顶部：可选的分隔线（Divider）
   * 2. 底部：取消按钮文本
   * 
   * 条件渲染：
   * - 根据isShowDivider决定是否显示Divider
   * 
   * 文本样式：
   * - 字体大小：使用项目常量FONT_SIZE_16
   * - 字体字重：使用项目常量FONT_WEIGHT_400
   * - 行高：24px
   * - 内边距：上下16px（使用项目常量PADDING_16）
   * 
   * 交互逻辑：
   * - 点击文本：调用btnClick回调函数
   * 
   * 设计理念：
   * - 使用Column垂直布局
   * - 通过Text组件实现按钮效果
   * - 使用项目常量确保样式一致性
   * 
   * @returns {void}
   */
  build() {
    Column(){
      if (this.isShowDivider){
        Divider()
      }
      Text(this.title).fontSize(FontConstants.FONT_SIZE_16)
        .fontWeight(FontConstants.FONT_WEIGHT_400)
        .lineHeight(24)
        .padding({
          top:PaddingConstants.PADDING_16,
          bottom:PaddingConstants.PADDING_16
        })
        .onClick(()=>{
          this.btnClick()
        })
    }
  }
}

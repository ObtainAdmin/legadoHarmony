/**
 * @file noSourceFind.ets
 * @description 无发现功能提示组件
 * 
 * 功能概述：
 * 1. 提示用户当前书源没有发现功能
 * 2. 提供一键隐藏无发现功能书源的操作
 * 3. 支持自定义提示文本
 * 4. 控制按钮显示状态
 * 
 * 使用场景：
 * - 书源没有发现功能时的提示
 * - 需要引导用户切换书源的场景
 * - 提供一键隐藏无功能书源的便捷操作
 * 
 * 设计特点：
 * - 使用项目常量统一字体样式
 * - 支持主题颜色配置
 * - 根据isShowButton控制按钮显示
 * - 居中对齐布局
 * 
 * 交互特点：
 * - 默认显示较长的提示文本
 * - 提供"一键隐藏"按钮（默认显示）
 * - 可通过isShowButton控制按钮隐藏
 * - 按钮点击调用setOnclick回调
 * 
 * 样式特点：
 * - 图标：124x120px固定尺寸
 * - 文本：280px固定宽度，14px字体，400字重
 * - 颜色：使用资源文件中的color_black_45
 * - 对齐：居中对齐
 * - 间距：图标底部32px，文本底部24px
 * 
 * @author 2008
 * @datetime 2024/6/26 23:47
 */

import CommonConstants from '../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'

/**
 * @class noSourceFind
 * @description 无发现功能提示组件
 * 
 * 组件职责：
 * 1. 显示无发现功能的提示信息
 * 2. 管理"一键隐藏"按钮的显示和点击事件
 * 3. 应用主题颜色配置
 * 4. 使用项目常量确保样式一致性
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct noSourceFind {
  /** 
   * @prop title - 提示文本
   * @description 显示给用户的提示信息
   * @default '该书源暂无发现功能，请切换至其他书源吧，点击下方按钮一键隐藏所有暂无发现功能书源' - 默认提示文本
   * @type {string}
   */
  @Prop title:string = '该书源暂无发现功能，请切换至其他书源吧，点击下方按钮一键隐藏所有暂无发现功能书源'
  
  /** 
   * @prop isShowButton - 是否显示按钮
   * @description 控制是否显示"一键隐藏"按钮
   * @default false - 默认显示按钮（注意：逻辑中!this.isShowButton时显示按钮）
   * @type {boolean}
   */
  @Prop isShowButton:boolean = false
  
  /** 
   * @prop setOnclick - 按钮点击回调函数
   * @description "一键隐藏"按钮被点击时调用的回调函数
   * @type {Function}
   */
  setOnclick:() => void = () => {

  }
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * @method build
   * @description 构建无发现功能提示UI
   * 
   * 布局结构：
   * 1. 顶部：提示图标（icon_no_source_find）
   * 2. 中部：提示文本
   * 3. 底部：条件显示的"一键隐藏"按钮
   * 
   * 图标样式：
   * - 尺寸：124x120px固定尺寸
   * - 底部边距：32px
   * - 使用固定资源：app.media.icon_no_source_find
   * 
   * 文本样式：
   * - 宽度：280px固定宽度
   * - 字体：14px，400字重，PingFANG字体（使用项目常量）
   * - 颜色：使用资源文件中的color_black_45
   * - 对齐：居中对齐
   * - 底部边距：24px
   * - 内容：通过title属性传入，支持自定义
   * 
   * 按钮条件显示：
   * - 当isShowButton为false时显示按钮（注意：逻辑是!this.isShowButton）
   * - 按钮文字："一键隐藏"
   * - 背景色：使用主题主色
   * - 点击事件：调用setOnclick回调函数
   * 
   * 容器样式：
   * - 使用Column垂直布局
   * - 默认居中对齐
   * 
   * 设计理念：
   * - 提供清晰的错误提示和解决方案
   * - 通过按钮提供便捷的操作入口
   * - 使用条件渲染控制按钮显示
   * - 使用资源文件确保颜色一致性
   * 
   * 注意事项：
   * - isShowButton的逻辑是反的：为false时显示按钮，为true时隐藏按钮
   * - 这可能是因为组件设计时考虑了默认显示按钮的场景
   * 
   * @returns {void}
   */
  build() {
    Column(){
        Image($r('app.media.icon_no_source_find')).width(124).height(120)
          .margin({bottom:32})
        Text(this.title)
          .width(280)
          .font({
            size:14,
            weight:400,
            family:CommonConstants.FAMILY_PingFANG
          })
          .textAlign(TextAlign.Center)
          .fontColor($r('app.string.color_black_45'))
          .margin({bottom:24})
      if (!this.isShowButton){
        Button('一键隐藏').backgroundColor(this.theme.mainColor)
          .onClick(()=>{
            this.setOnclick()
          })
      }
    }
  }
}

/**
 * @file Header.ets
 * @description 公共头部组件
 * 
 * 功能概述：
 * 1. 提供标准化的应用头部导航栏
 * 2. 支持自定义左侧/中间/右侧内容
 * 3. 默认包含返回按钮、标题和右侧下拉菜单
 * 4. 自动处理顶部安全区适配
 * 
 * 使用场景：
 * - 应用页面的顶部导航栏
 * - 需要统一头部样式的页面
 * - 需要自定义头部内容的页面
 * 
 * 设计特点：
 * - 使用BuilderParam实现高度可定制性
 * - 自动适配顶部安全区
 * - 支持右侧下拉菜单功能
 * - 默认提供返回导航功能
 * 
 * 自定义能力：
 * 1. 自定义左侧区域：通过customLeftBuilder
 * 2. 自定义中间区域：通过customTitleBuilder
 * 3. 自定义右侧区域：通过customRightBuilder
 * 4. 右侧下拉菜单图标：通过rightIcon传入更改
 * 
 * 注意事项：
 * - 设置自定义区域后，相应的默认区域失效
 * - 内部已设置顶部安全区适配
 * - 右侧下拉菜单数据通过dialogRightData传入
 * 
 * @author Andy
 * @datetime 2024/7/6 01:36
 */

import { router } from '@kit.ArkUI'
import { IconTitleVo } from '../../componetsmodel/IconTitleVo'
import dialogTitleFuction from './dialogTitleFuction'

/**
 * @class Header
 * @description 公共头部组件
 * 
 * 组件职责：
 * 1. 提供标准化的头部导航栏
 * 2. 管理自定义内容区域
 * 3. 处理顶部安全区适配
 * 4. 管理右侧下拉菜单
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct Header {
  // 默认构建器 - 左侧区域
  @Builder leftBuilder() {}
  
  /** 
   * @builderParam customLeftBuilder - 自定义左侧区域构建器
   * @description 自定义头部左侧区域的内容构建器
   * @default this.leftBuilder - 默认使用leftBuilder
   * @type {() => void}
   */
  @BuilderParam customLeftBuilder: () => void = this.leftBuilder
  
  // 默认构建器 - 中间区域
  @Builder titleBuilder() {}
  
  /** 
   * @builderParam customTitleBuilder - 自定义中间区域构建器
   * @description 自定义头部中间区域的内容构建器
   * @default this.titleBuilder - 默认使用titleBuilder
   * @type {() => void}
   */
  @BuilderParam customTitleBuilder: () => void = this.titleBuilder
  
  // 默认构建器 - 右侧区域
  @Builder rightBuilder() {}
  
  /** 
   * @builderParam customRightBuilder - 自定义右侧区域构建器
   * @description 自定义头部右侧区域的内容构建器
   * @default this.rightBuilder - 默认使用rightBuilder
   * @type {() => void}
   */
  @BuilderParam customRightBuilder: () => void = this.rightBuilder
  
  /** 
   * @storage topRectHeight - 顶部安全区高度
   * @description 从本地存储获取的顶部安全区高度，用于适配刘海屏等
   * @default 0 - 默认高度为0
   * @type {number}
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0

  /** 
   * @prop paddingTop - 顶部额外内边距
   * @description 头部顶部的额外内边距，用于特殊布局需求
   * @default 0 - 默认无额外内边距
   * @type {number}
   */
  paddingTop: number = 0
  
  /** 
   * @prop title - 标题文本
   * @description 头部中间显示的标题文本
   * @default '' - 默认空字符串
   * @type {string}
   */
  @Prop title: string = ''
  
  /** 
   * @prop dialogRightData - 右侧下拉菜单数据
   * @description 右侧下拉菜单的数据数组，支持IconTitleVo对象或字符串
   * @default [] - 默认空数组
   * @type {IconTitleVo[] | string[]}
   */
  dialogRightData: IconTitleVo[] | string[] = []
  
  /** 
   * @prop dialogRightChange - 右侧下拉菜单选择回调
   * @description 右侧下拉菜单项被选择时的回调函数
   * @type {Function}
   * @param {number} index - 被选择项的索引
   */
  dialogRightChange: Function = (_index: number) => {}
  
  /** 
   * @state showFunction - 下拉菜单显示状态
   * @description 控制右侧下拉菜单的显示/隐藏状态
   * @default false - 默认不显示
   * @type {boolean}
   */
  @State showFunction: boolean = false
  
  /** 
   * @prop flexAlign - Flex对齐方式
   * @description 头部Row容器的Flex对齐方式
   * @default FlexAlign.SpaceBetween - 默认两端对齐
   * @type {FlexAlign | undefined}
   */
  flexAlign?: FlexAlign = FlexAlign.SpaceBetween
  
  /** 
   * @prop rightIcon - 右侧按钮图标
   * @description 右侧下拉菜单按钮的图标，支持多种图标类型
   * @type {PixelMap | ResourceStr | DrawableDescriptor | undefined}
   */
  rightIcon?: PixelMap | ResourceStr | DrawableDescriptor

  /**
   * @method build
   * @description 构建头部组件主UI
   * 
   * 布局结构：
   * 1. 外层Column：处理顶部安全区适配
   * 2. 内层Row：头部主要内容区域
   *   - 左侧：自定义左侧区域或默认返回按钮
   *   - 中间：自定义中间区域或默认标题
   *   - 右侧：自定义右侧区域或下拉菜单
   * 
   * 条件渲染逻辑：
   * 1. 左侧区域：
   *   - 如果customLeftBuilder !== leftBuilder：使用自定义构建器
   *   - 否则：显示默认返回按钮（点击返回上一页）
   * 
   * 2. 中间区域：
   *   - 如果customTitleBuilder !== titleBuilder：使用自定义构建器
   *   - 否则：显示默认标题文本
   * 
   * 3. 右侧区域：
   *   - 如果customRightBuilder !== rightBuilder：使用自定义构建器
   *   - 否则如果有dialogRightData：显示下拉菜单按钮
   *   - 否则：显示24px宽度的占位Row
   * 
   * 默认返回按钮：
   * - 图标：return_left资源
   * - 尺寸：24x24px
   * - 插值：中等质量（ImageInterpolation.Medium）
   * - 点击事件：router.back()返回上一页
   * 
   * 默认标题样式：
   * - 字体：16px，500字重，正常样式
   * - 行高：24px
   * 
   * 下拉菜单按钮：
   * - 图标：rightIcon或默认addSubscription图标
   * - 绑定菜单：通过bindMenu绑定dialogRightFuction构建器
   * - 点击事件：显示下拉菜单
   * 
   * 容器样式：
   * - 高度：50px
   * - 宽度：100%
   * - 内边距：左右12/20px，上下9px
   * - 对齐：垂直居中对齐，根据flexAlign水平对齐
   * 
   * 安全区适配：
   * - 外层Column顶部内边距：topRectHeight + paddingTop
   * 
   * @returns {void}
   */
  build() {
    Column() {
      // 顶部固定内容
      Row() {
        if (this.customLeftBuilder !== this.leftBuilder) {
          this.customLeftBuilder()
        } else {
          Column() {
            Image($r("app.media.return_left"))
              .size({ width: 24, height: 24 })
              .interpolation(ImageInterpolation.Medium)
              .onClick(() => {
                router.back()
              })
          }
          .alignItems(HorizontalAlign.Start)
        }

        if (this.customTitleBuilder !== this.titleBuilder) {
          this.customTitleBuilder()
        } else {
          Column() {
            Text(this.title)
              .lineHeight(24)
              .font({
                size: 16,
                weight: 500,
                style: FontStyle.Normal,
              })
          }
        }

        if (this.customRightBuilder !== this.rightBuilder) {
          this.customRightBuilder()
        }

        if (this.dialogRightData.length) {
          Image(this.rightIcon ? this.rightIcon : $r('app.media.addSubscription')).width(24)
            .bindMenu(
              this.showFunction,
              this.dialogRightFuction(),
              {
                onDisappear: () => {
                  this.showFunction = false
                }
              })
            .onClick(() => {
              this.showFunction = true
            })
        } else {
          if (this.customRightBuilder === this.rightBuilder && !this.dialogRightData.length) {
            Row()
              .size({ width: 24 })
          }
        }
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(this.flexAlign)
      .padding({
        left: 12,
        right: 20,
        top: 9,
        bottom: 9
      })
      .height(50)
      .width("100%")
    }
    .padding({
      top: this.topRectHeight + this.paddingTop
    })
  }

  /**
   * @builder dialogRightFuction
   * @description 右侧下拉菜单构建器
   * 
   * 功能特点：
   * 1. 构建右侧下拉菜单的内容
   * 2. 支持IconTitleVo对象和字符串两种数据格式
   * 3. 自动处理菜单项之间的边框显示
   * 4. 提供菜单项点击事件
   * 
   * 布局结构：
   * 1. 外层Column：下拉菜单容器
   * 2. 内层ForEach：遍历dialogRightData生成菜单项
   * 
   * 数据格式处理：
   * - 字符串类型：直接作为标题，无图标
   * - IconTitleVo类型：使用item.title作为标题，item.icon作为图标
   * 
   * 边框逻辑：
   * - 最后一项不显示底部边框
   * - 其他项显示底部边框
   * - 通过isBorder: this.dialogRightData.length !== index + 1控制
   * 
   * 交互逻辑：
   * - 点击菜单项：调用dialogRightChange回调，传入索引
   * 
   * 技术特点：
   * - 使用dialogTitleFuction组件构建菜单项
   * - 支持动态数据绑定
   * - 自动类型判断和处理
   * 
   * @returns {void}
   */
  @Builder
  dialogRightFuction() {
    Column() {
      ForEach(this.dialogRightData, (item: IconTitleVo | string, index) => {
        dialogTitleFuction({
          title: typeof item === 'string' ? item : item.title,
          icon: typeof item === 'string' ? undefined : item.icon,
          isBorder: this.dialogRightData.length !== index + 1
        })
          .onClick(() => {
            this.dialogRightChange(index)
          })
      })
    }
  }
}

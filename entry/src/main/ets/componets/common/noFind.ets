/**
 * @file noFind.ets
 * @description 无内容提示组件
 * 
 * 功能概述：
 * 1. 提供多种无内容状态的提示界面
 * 2. 支持三种提示类型：无内容、网络异常、内容加载失败
 * 3. 根据提示类型显示相应的图标和消息
 * 4. 网络异常和加载失败时显示重试按钮
 * 
 * 使用场景：
 * - 搜索结果为空时的提示
 * - 网络连接失败时的提示
 * - 内容加载失败时的提示
 * - 需要统一无内容提示样式的场景
 * 
 * 设计特点：
 * - 使用项目常量统一字体、图片、内边距等样式
 * - 支持主题颜色配置
 * - 根据提示类型动态显示内容和按钮
 * - 居中对齐布局
 * 
 * 提示类型：
 * 1. hintIndex=0: 暂无相关内容
 *   - 图标：icon_no_source_find
 *   - 消息："暂无相关内容"
 *   - 无重试按钮
 * 
 * 2. hintIndex=1: 网络异常
 *   - 图标：icon_no_source_net
 *   - 消息："网络异常，请检查后重试"
 *   - 显示重试按钮
 * 
 * 3. hintIndex=2: 内容加载失败
 *   - 图标：icon_no_source_content
 *   - 消息："内容加载失败，请刷新重试"
 *   - 显示重试按钮
 * 
 * @author 2008
 * @datetime 2024/6/26 23:47
 */

import CommonConstants from '../../common/constants/CommonConstants'
import FontConstants from '../../common/constants/FontConstants'
import ImageConstants from '../../common/constants/ImageConstants'
import PaddingConstants from '../../common/constants/PaddingConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'

/**
 * @class noFind
 * @description 无内容提示组件
 * 
 * 组件职责：
 * 1. 根据提示类型显示相应的图标和消息
 * 2. 管理重试按钮的显示和点击事件
 * 3. 应用主题颜色配置
 * 4. 使用项目常量确保样式一致性
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct noFind {
  /** 
   * @prop hintIndex - 提示类型索引
   * @description 控制显示哪种提示类型：
   * - 0: 暂无相关内容
   * - 1: 网络异常
   * - 2: 内容加载失败
   * @default 2 - 默认显示内容加载失败
   * @type {number}
   */
  @Prop hintIndex: number = 2
  
  /** 
   * @prop hintMessage - 提示消息数组
   * @description 三种提示类型对应的消息文本
   * @type {string[]}
   */
  hintMessage: string[] = ['暂无相关内容', '网络异常，请检查后重试', '内容加载失败，请刷新重试']
  
  /** 
   * @prop hintIcon - 提示图标数组
   * @description 三种提示类型对应的图标资源
   * @type {Resource[]}
   */
  hintIcon: Resource[] =
    [$r('app.media.icon_no_source_find'), $r('app.media.icon_no_source_net'), $r('app.media.icon_no_source_content')]
  
  /** 
   * @prop onclick - 点击回调函数
   * @description 重试按钮被点击时调用的回调函数
   * @type {Function}
   */
  onclick: () => void = () => {}
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * @method build
   * @description 构建无内容提示UI
   * 
   * 布局结构：
   * 1. 顶部：提示图标
   * 2. 中部：提示消息文本
   * 3. 底部：条件显示的重试按钮
   * 
   * 图标样式：
   * - 尺寸：124x120px（使用项目常量）
   * - 底部边距：32px（使用项目常量）
   * - 根据hintIndex从hintIcon数组获取对应图标
   * 
   * 消息文本样式：
   * - 宽度：280px固定宽度
   * - 字体：14px，400字重，PingFANG字体（使用项目常量）
   * - 颜色：使用资源文件中的color_black_45
   * - 对齐：居中对齐
   * - 底部边距：24px（使用项目常量）
   * - 根据hintIndex从hintMessage数组获取对应消息
   * 
   * 重试按钮条件显示：
   * - 仅当hintIndex不为0时显示（即网络异常或内容加载失败时）
   * - 使用主题主色作为背景
   * - 按钮文字："重试"（使用资源文件）
   * - 字体：14px，500字重，PingFANG字体（使用项目常量）
   * - 内边距：左右32px，上下8px
   * - 点击事件：调用onclick回调函数
   * 
   * 容器样式：
   * - 高度：100%父容器高度
   * - 对齐：水平居中对齐，垂直居中对齐
   * - 使用FlexAlign.Center实现垂直居中
   * 
   * 设计理念：
   * - 提供统一的错误/空状态提示体验
   * - 根据错误类型提供针对性的解决方案
   * - 使用项目常量确保样式一致性
   * - 通过条件渲染减少不必要的UI元素
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Image(this.hintIcon[this.hintIndex]).width(ImageConstants.IMG_WIDTH_124).height(ImageConstants.IMG_HEIGHT_120)
        .margin({
          bottom: PaddingConstants.PADDING_32
        })
      Text(this.hintMessage[this.hintIndex])
        .fontColor($r('app.string.color_black_45'))
        .width(280)
        .font({
          size: FontConstants.FONT_SIZE_14,
          weight: FontConstants.FONT_WEIGHT_400,
          family: CommonConstants.FAMILY_PingFANG
        })
        .textAlign(TextAlign.Center)
        .margin({ bottom: PaddingConstants.PADDING_24 })

      if (this.hintIndex !== 0) {
        Button($r('app.string.retry'))
          .padding({
            left: 32,
            right: 32,
            bottom: 8,
            top: 8
          })
          .fontSize(FontConstants.FONT_SIZE_14)
          .fontWeight(FontConstants.FONT_WEIGHT_500)
          .fontFamily(CommonConstants.FAMILY_PingFANG)
          .backgroundColor(this.theme.mainColor)
          .onClick(() => {
            this.onclick()
          })
      }
    }
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}

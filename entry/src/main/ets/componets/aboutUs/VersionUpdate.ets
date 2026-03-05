/**
 * @file VersionUpdate.ets
 * @description 版本更新对话框组件
 * 
 * 功能概述：
 * 1. 显示新版本信息（版本号、更新内容）
 * 2. 提供"立即更新"按钮触发更新流程
 * 3. 更新过程中显示进度条
 * 4. 提供"暂不更新"或"后台下载"选项
 * 
 * 使用场景：
 * - 应用检测到新版本时弹出此对话框
 * - 用户可以选择立即更新或暂不更新
 * 
 * 设计特点：
 * - 使用CustomDialog实现模态对话框
 * - 支持主题颜色配置
 * - 包含状态切换（更新前/更新中）
 */

import { ThemeStorageKey } from "../../common/constants/Theme"
import { ThemeItem } from "../../common/model/Theme"

/**
 * @class VersionUpdateCustomDialog
 * @description 版本更新自定义对话框组件
 * 
 * 组件职责：
 * 1. 展示新版本信息
 * 2. 处理用户更新操作
 * 3. 显示更新进度
 * 4. 管理对话框状态
 * 
 * @decorator @CustomDialog - 声明为自定义对话框组件
 */
@CustomDialog
export default struct VersionUpdateCustomDialog {
  /** @prop controller - 对话框控制器，用于管理对话框的打开和关闭 */
  controller: CustomDialogController
  
  /** 
   * @state clickUpdate - 是否点击了更新按钮
   * @description 控制UI状态切换：
   * - false: 显示"立即更新"按钮
   * - true: 显示进度条（更新中状态）
   */
  @State clickUpdate: boolean = false
  
  /** 
   * @state ProgressValue - 更新进度值
   * @description 表示更新进度的百分比（0-100）
   * @default 40 - 示例值，实际使用时应该动态更新
   */
  @State ProgressValue: number = 40
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置，用于保持应用主题一致性
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method build
   * @description 构建组件UI布局
   * 
   * 布局结构：
   * 1. 顶部标题区域：显示"发现新版本"和版本号
   * 2. 更新内容区域：列出新版本特性
   * 3. 操作按钮区域：
   *    - 更新前：显示"立即更新"按钮
   *    - 更新中：显示进度条
   * 4. 底部选项：显示"暂不更新"或"后台下载"
   * 
   * 状态切换逻辑：
   * - 点击"立即更新"按钮后，clickUpdate变为true，显示进度条
   * - 点击"暂不更新"会关闭对话框
   * - 更新中点击"后台下载"无操作（仅文本显示）
   * 
   * @returns {void}
   */
  build() {
    Column() {
      Row({ space: 12 }) {
        Text('发现新版本')
          .lineHeight(32)
          .fontColor("#000000")
          .font({
            family: "PingFang SC",
            size: 24,
            style: FontStyle.Normal,
            weight: 500,
          })
        Text('v4.1.14')
          .lineHeight(32)
          .fontColor("#000000")
          .font({
            family: "PingFang SC",
            size: 16,
            style: FontStyle.Normal,
            weight: 500,
          })
      }
      .padding({
        top: 32,
        left: 24,
        right: 24
      })
      .height(76)
      .width("100%")
      .backgroundImage($r('app.media.versionUpdateBackground'))
      .backgroundImageSize({ width: "100%", height: 76 })

      Column() {
        Row() {
          Text("首页风格改版，更全面的内容，恍然一新的视觉用户体验")
        }

        Row() {
          Text("优化了动画细节，让产品更流畅。")
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width("100%")
      .padding({
        top: 12,
        left: 24,
        right: 24
      })

      if (!this.clickUpdate) {
        Button("立即更新")
          .backgroundColor(this.theme.mainColor)
          .width("73%")
          .margin({
            top: 24,
            bottom: 16
          })
          .onClick(() => {
            this.clickUpdate = true
          })
      } else {
        Progress({
          value: this.ProgressValue,
          total: 100,
          type: ProgressType.Capsule,
        })
          .style({
            content: `正在更新（${this.ProgressValue}%）`,
            fontColor: "#FFFFFF",
            font: ({
              family: "PingFang SC",
              size: 14,
              style: FontStyle.Normal,
              weight: 400,
            })
          })
          .width("73%")
          .color(this.theme.mainColor)
          .backgroundColor("#FFAF7A")
          .margin({
            top: 24,
            bottom: 16
          })

      }

      Text(!this.clickUpdate ? "暂不更新" : "后台下载")
        .lineHeight(22)
        .fontColor("#000000")
        .opacity(0.45)
        .font({
          family: "PingFang SC",
          size: 14,
          style: FontStyle.Normal,
          weight: 400,
        })
        .margin({
          bottom: 24
        })
        .onClick(() => {
          if (!this.clickUpdate) {
            this.controller.close()
          }
        })
    }
  }
}

/**
 * @file battery.ets
 * @description 电池状态显示组件
 * 
 * 功能概述：
 * 1. 显示设备当前电池电量百分比
 * 2. 显示电池充电状态（充电中/放电中）
 * 3. 低电量时（<20%）显示红色警告
 * 4. 充电时显示充电图标
 * 
 * 使用场景：
 * - 应用状态栏的电池信息显示
 * - 需要展示设备电池状态的界面
 * - 低电量警告提示场景
 * 
 * 设计特点：
 * - 使用系统batteryInfo API获取电池信息
 * - 电池电量通过进度条形式可视化
 * - 充电状态通过图标区分
 * - 低电量时颜色变化提示
 * 
 * 技术特点：
 * - 使用@ohos.batteryInfo系统能力
 * - 实时监听电池状态变化
 * - 响应式更新UI
 */

import batteryInfo from '@ohos.batteryInfo';

/**
 * @class battery
 * @description 电池状态组件
 * 
 * 组件职责：
 * 1. 获取并显示设备电池电量
 * 2. 监控电池充电状态
 * 3. 提供低电量视觉警告
 * 4. 显示充电状态图标
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct battery {
  /** 
   * @state batterySOCInfo - 电池电量百分比
   * @description 表示当前设备剩余电池电量百分比（0-100）
   * @default batteryInfo.batterySOC - 从系统API获取初始值
   * @type {number}
   */
  @State batterySOCInfo: number = batteryInfo.batterySOC;
  
  /** 
   * @state chargingStatusInfo - 充电状态
   * @description 表示当前设备电池的充电状态：
   * - 0: 放电中
   * - 1: 充电中
   * - 2: 停止充电
   * - 3: 已充满
   * @default batteryInfo.chargingStatus - 从系统API获取初始值
   * @type {number}
   */
  @State chargingStatusInfo: number = batteryInfo.chargingStatus;

  /**
   * @method build
   * @description 构建电池状态显示UI
   * 
   * 布局结构：
   * 1. 左侧：电池电量进度条 + 电池外壳图标
   * 2. 右侧：充电状态图标（充电时显示）
   * 
   * 视觉设计：
   * - 电池电量：通过Flex宽度比例表示（20px为100%）
   * - 低电量警告：电量<20%时显示红色，否则显示黑色
   * - 电池外壳：使用Union图标作为电池轮廓
   * - 充电图标：使用Vector图标，充电状态≠0时显示
   * 
   * 交互逻辑：
   * - 电量变化时自动更新进度条宽度
   * - 充电状态变化时自动显示/隐藏充电图标
   * - 低电量时自动切换颜色警告
   * 
   * @returns {void}
   */
  build() {
    Flex() {
      Stack() {
        Flex()
          .height(7)
          .width(this.batterySOCInfo / 100 * 20)
          .backgroundColor(this.batterySOCInfo < 20 ? "red" : "rgba(0, 0, 0, 0.88)")
          .zIndex(2)
          .borderRadius(1.5)
          .margin({
            left: 2
          })

        Image($r("app.media.Union")).width(26)
      }
      .alignContent(Alignment.Start)

      if (this.chargingStatusInfo !== 0) {
        Image($r("app.media.Vector"))
          .height(12)
          .margin({
            left: 3
          })
          .opacity(0.88)
      }
    }
    .width(38)
  }
}

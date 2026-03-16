// ============ 导入模块 ============
import { router } from '@kit.ArkUI'; // 页面路由导航 API

/**
 * @Entry - 页面入口装饰器
 *   - 标识这是一个独立的页面组件
 * @Component - 组件装饰器
 *   - 定义 UI 组件结构，支持状态管理
 * @struct PrivacyAgreementPage - 用户隐私与协议页面组件类
 */
@Entry
@Component
struct PrivacyAgreementPage {
  // ============ 状态变量定义 ============
  
  /** @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
   * 底部安全区域高度适配（如 Home Indicator）
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** @StorageLink('topRectHeight') topRectHeight: number = 0
   * 顶部安全区域高度适配（如刘海屏、动态岛）
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** @State rowsData: Array<string> - 隐私政策内容数据数组
   * 存储隐私政策的关键条款文本
   * 
   * 数据结构说明：
   *   index 0: Google Firebase 使用声明（崩溃报告/性能监控）
   *   index 1: WebDav 同步机制说明（用户自建服务）
   *   index 2: 权限使用理由说明（存储权限/Google 依赖）
   *   index 3: 开源软件免责声明（JS 引擎风险自负）
   *   
   * 核心隐私要点：
   *   1. 无服务端设计：不收集任何用户个人信息
   *   2. 第三方工具限制：仅 Firebase 用于崩溃报告和性能分析
   *   3. 数据自主控制：网络同步采用 WebDav，用户自建服务器
   *   4. 开源特性：内置 JS 引擎导致的风险由用户承担
   */
  @State rowsData: Array<string> = [
    '本应用没有服务端，不收集任何用户信息，只采用了 Google Firebase 收集崩溃报告和性能报告。', // Firebase 集成说明
    '本应用网络同步和备份采用 webDav 协议，由用户自己提供同步服务.', // WebDav 同步机制
    '存储权限用来打开本地文件和本地备份恢复。其它一些权限是 Google Firebase 需要.', // 权限用途解释
    '本应用为开源软件，内置 js 引擎，因书源调用 js 发生的任何问题由用户自行承担.' // 开源及 JS 引擎免责
  ]

  // ============ UI 构建方法 - build() ============
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column (外层容器)
   * ├─ Flex (固定高度的导航栏)
   * └─ Column (隐私政策内容列表)
   *    └─ ForEach (遍历显示各段落)
   *       └─ Row (段落项：黑色圆点标记 + 文本)
   */
  build() {
    // ========== 外层垂直布局容器 ==========
    Column({ space: 16 }) { // 子组件间距 16 像素
      
      // ========== 标题部分（固定不动）==========
      Flex() { // 水平弹性布局
        // 左侧返回按钮
        Column() {
          Image($r("app.media.return_left")) // 返回图标资源
            .size({ width: 24, height: 24 }) // 尺寸 24x24 像素
            .interpolation(ImageInterpolation.Medium) // 图片插值算法（中等质量）
            .onClick(() => {
              router.back() // 点击返回上一页
            })
        }
        .alignItems(HorizontalAlign.Start) // 内部元素左对齐
        .width('30%') // 占父容器 30% 宽度

        // 中间标题
        Column() {
          Text(`用户隐私与协议`) // 页面标题
            .lineHeight(24) // 行高 24 像素
            .font({
              family: "PingFang SC", // 苹方字体
              size: 16, // 字号 16 像素
              weight: 500, // 字重 500（中等粗细）
              style: FontStyle.Normal, // 正常样式
            })
        }.width('40%') // 标题占 40% 宽度
      }
      .padding({
        top: 12, // 上内边距 12 像素
        bottom: 12, // 下内边距 12 像素
      })
      .height(48) // 导航栏固定高度 48 像素
      .width("100%") // 占满宽度

      // ========== 内容区域 ==========
      Column() {
        // ========== ForEach 遍历渲染隐私条款 ==========
        ForEach(this.rowsData, (item: string) => {
          Row() { // 水平布局容器
            
            // 黑色圆点标记
            Column()
              .width(4) // 宽度 4 像素
              .height(4) // 高度 4 像素
              .backgroundColor(0x000000) // 黑色背景（十六进制表示）
              .borderRadius(2) // 圆角半径 2 像素（形成圆形效果）
              .margin({ right: 8, top: -20 }) // 右外边距 8 像素，上负边距 -20（垂直居中调整）
            
            // 隐私条款文本
            Text(item)
              .lineHeight(22) // 行高 22 像素
              .font({
                family: "PingFang SC", // 苹方字体
                size: 14, // 字号 14 像素
                style: FontStyle.Normal, // 正常样式
                weight: 400, // 字重 400（常规粗细）
              })
          }.width("100%") // 占满宽度
          .margin({ top: 12 }) // 段落间距 12 像素
        })
      }
      .width("100%") // 内容区域宽度
      
    }
    // ========== 外层 Column 配置 ==========
    .height("100%") // 占满屏幕高度
    .padding({
      top: this.topRectHeight, // 顶部安全区域适配
      left: 20, // 左内边距 20 像素
      right: 20, // 右内边距 20 像素
    })
    .backgroundColor("rgb(245, 245, 245)") // 浅灰色背景色
  }
}

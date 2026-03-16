// ============ 导入模块 ============
import { router } from '@kit.ArkUI'; // 页面路由导航 API
import { ThemeStorageKey } from '../../../../common/constants/Theme'; // 主题配置常量导入
import { ThemeItem } from '../../../../common/model/Theme'; // 主题类型定义

/**
 * @Entry - 页面入口装饰器
 *   - 标识这是一个独立的页面组件
 * @Component - 组件装饰器
 *   - 定义 UI 组件结构，支持状态管理
 * @struct VersionLogPage - 版本更新日志页面组件类
 */
@Entry
@Component
struct VersionLogPage {
  // ============ 状态变量定义 ============
  
  /** @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
   * 底部安全区域高度适配（如 Home Indicator）
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** @StorageLink('topRectHeight') topRectHeight: number = 0
   * 顶部安全区域高度适配（如刘海屏、动态岛）
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** @State List: Array<string> - 当前版本更新内容列表
   * 存储 V1.0.0.1 版本的更新项
   * 
   * 数据结构说明：
   *   index 0: "更新 icon 图标" - UI 优化
   *   index 1: "关于我们-QQ 群增加 Beta 群" - 新增功能
   *   
   * TODO: 可在此处添加更多历史版本的更新记录（当前被注释）
   */
  @State List: Array<string> = [
    '更新 icon 图标', // UI 视觉优化
    '关于我们-QQ 群增加 Beta 群', // 新增 Beta 测试群入口
  ]
  
  // ============ 主题属性绑定 ============
  /**
   * @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
   * 响应式主题颜色绑定
   * 
   * StorageProp 特点：
   *   - 监听全局主题变化，自动更新应用配色
   *   - 实现浅色/深色模式切换
   *   - 保持品牌色一致性
   * 
   * 用途：versionCard 中 mainColor 用于侧边线高亮
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  // ============ UI 构建方法 - build() ============
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column (外层容器)
   * ├─ Flex (固定高度的导航栏)
   * └─ versionCardBuilder (版本卡片组件)
   *    └─ Row (版本号 + 日期)
   *       └─ ForEach (更新项列表)
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
        .width('33%') // 占父容器 33% 宽度

        // 中间标题
        Column() {
          Text(`版本更新日志`) // 页面标题
            .lineHeight(24) // 行高 24 像素
            .font({
              family: "PingFang SC", // 苹方字体
              size: 16, // 字号 16 像素
              weight: 500, // 字重 500（中等粗细）
              style: FontStyle.Normal, // 正常样式
            })
        }.width('33%') // 标题占 33% 宽度
      }
      .padding({
        top: 12, // 上内边距 12 像素
        bottom: 12, // 下内边距 12 像素
      })
      .height(48) // 导航栏固定高度 48 像素
      .width("100%") // 占满宽度

      // ========== 版本卡片渲染 ==========
      // 调用 versionCard 构建器创建版本信息卡片
      this.versionCard("V1.0.0.1", "2024/9/8", this.List)
      
      // TODO: 可取消注释以显示历史版本
      //this.versionCard("V5.1.1", "2024/5/9", this.List)
      
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

  // ============ 构建器：版本信息卡片 ============
  /**
   * @Builder versionCard - 版本卡片构建器
   * 创建单个版本的完整信息展示卡片
   * 
   * @param version - 版本号字符串
   *   格式："V{x.y.z.w}"，例如："V1.0.0.1"
   * @param date - 发布日期字符串
   *   格式："YYYY/M/D"，例如："2024/9/8"
   * @param updateInfo - 更新项数组
   *   Array<string>，每个字符串为一个更新点
   * 
   * @returns Column 组件，包含：
   *   - 版本号行：彩色竖线 + 版本号 + 空白填充 + 日期
   *   - ForEach 更新项列表
   */
  @Builder
  versionCard(version: string, date: string, updateInfo: Array<string>) {
    Column() {
      
      // ========== 版本号信息行 ==========
      Row() {
        // 彩色竖线装饰（品牌色）
        Line({ width: 4, height: 16 })
          .backgroundColor(this.theme.mainColor) // 主题主色（从全局主题获取）
          .margin({ right: 8 }) // 右侧外边距 8 像素，与版本号间隔
      
        // 版本号文本
        Text(version)
          .lineHeight(24) // 行高 24 像素
          .fontColor("#000000") // 字体颜色黑色
          .font({
            family: "PingFang SC", // 苹方字体
            size: 16, // 字号 16 像素
            weight: 500, // 字重 500（中等粗细，突出重要信息）
            style: FontStyle.Normal, // 正常样式
          })
        
        // Blank(20) - 空白占位符
        // 关键作用：占据剩余空间，将日期推到最右侧
        Blank(20) 
        
        // 发布日期文本
        Text(date)
          .fontColor("#000000") // 字体颜色黑色
          .opacity(0.45) // 半透明效果（视觉层级较低）
          .lineHeight(20) // 行高 20 像素
          .font({
            family: "PingFang SC", // 苹方字体
            size: 12, // 字号 12 像素（较小，次要信息）
            weight: 400, // 字重 400（常规粗细）
            style: FontStyle.Normal // 正常样式
          })
      }
      .margin({ bottom: 12 }) // 卡片底部外边距 12 像素
      
      // ========== 更新项列表 ==========
      ForEach(updateInfo, (item: string) => {
        Row() { // 水平布局容器
          // 更新项文本
          Text(item).lineHeight(20) // 行高 20 像素
            .font({
              family: "PingFang SC", // 苹方字体
              size: 12, // 字号 12 像素（正文大小）
              weight: 400, // 字重 400（常规粗细）
              style: FontStyle.Normal // 正常样式
            })
        }
        .width("100%") // 占满宽度
      })
      
    }
    // ========== 卡片整体样式 ==========
    .borderRadius(12) // 圆角 12 像素（柔和外观）
    .backgroundColor("#FFFFFF") // 白色背景（卡片效果）
    .padding(16) // 内边距 16 像素（内容呼吸空间）
    .width("100%") // 占满容器宽度
  }
}

// ============ 导入模块 ============
import { router } from '@kit.ArkUI'; // 页面路由导航 API

/**
 * @Entry - 页面入口装饰器
 *   - 标识这是一个独立的页面组件
 * @Component - 组件装饰器
 *   - 定义 UI 组件结构，支持状态管理
 * @struct OpenSourceLicensePage - 开源许可证页面组件类
 */
@Entry
@Component
struct OpenSourceLicensePage {
  // ============ 状态变量定义 ============
  
  /** @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
   * 底部安全区域高度适配（如 Home Indicator）
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** @StorageLink('topRectHeight') topRectHeight: number = 0
   * 顶部安全区域高度适配（如刘海屏、动态岛）
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** @State rowsData: Array<string> - GPL v3 许可证文本内容
   * 存储 GNU General Public License v3 的完整文本
   * 
   * 数据结构说明：
   *   index 0: 许可证标题和版本
   *   index 1: 版权信息
   *   index 2: Preamble（前言）
   *   index 3-11: 各段落正文内容
   *   
   * GPL v3 核心要点：
   *   - 自由软件定义：保障用户运行、复制、分发、学习、修改和改进软件的自由
   *   - Copyleft（著佐权）：衍生作品必须同样采用 GPL 发布
   *   - 责任免除：无 warranty（担保）
   *   - Tivoization 禁止：防止硬件设备阻止用户安装修改后的软件
   */
  @State rowsData: Array<string> = [
    'GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007', // 许可证名称和发布日期
    'Copyright (C) 2007 Free Software Foundation, Inc. https://fsf.org/ Everyone is permitted to copy and distribute verbatim copies of this license document, but changing it is not allowed.', // 版权所有信息和分发条款
    'Preamble', // 前言标题
    'The GNU General Public License is a free, copyleft license for software and other kinds of works.', // GPL 定义：免费且著佐权的许可证
    'The licenses for most software and other practical works are designed to take away your freedom to share and change the works. By contrast, the GNU General Public License is intended to guarantee your freedom to share and change all versions of a program--to make sure it remains free software for all its users. We, the Free Software Foundation, use the GNU General Public License for most of our software; it applies also to any other work released this way by its authors. You can apply it to your programs, too.', // GPL 目的阐述：保障用户自由的核心理念
    'When we speak of free software, we are referring to freedom, not price. Our General Public Licenses are designed to make sure that you have the freedom to distribute copies of free software (and charge for them if you wish), that you receive source code or can get it if you want it, that you can change the software or use pieces of it in new free programs, and that you know you can do these things.', // 免费软件的定义：freedom ≠ price，强调四大自由
    'To protect your rights, we need to prevent others from denying you these rights or asking you to surrender the rights. Therefore, you have certain responsibilities if you distribute copies of the software, or if you modify it: responsibilities to respect the freedom of others.', // 保护用户权利：需承担尊重他人自由的责任
    'For example, if you distribute copies of such a program, whether gratis or for a fee, you must pass on to the recipients the same freedoms that you received. You must make sure that they, too, receive or can get the source code. And you must show them these terms so they know their rights.', // 分发义务：传递相同自由、提供源码、展示许可条款
    'Developers that use the GNU GPL protect your rights with two steps: (1) assert copyright on the software, and (2) offer you this License giving you legal permission to copy, distribute and/or modify it.', // 开发者保护措施：两步法（声明版权 + 提供许可）
    'For the developers\' and authors\' protection, the GPL clearly explains that there is no warranty for this free software. For both users\' and authors\' sake, the GPL requires that modified versions be marked as changed, so that their problems will not be attributed erroneously to authors of previous versions.', // 免责声明：no warranty；修改版本需明确标注变更
    'Some devices are designed to deny users access to install or run modified versions of the software inside them, although the manufacturer can do so. This is fundamentally incompatible with the aim of protecting users\' freedom to change the software. The systematic pattern of such abuse occurs in the area of products for individuals to use, which is precisely where it is most unacceptable. Therefore, we have designed this version of the GPL to prohibit the practice for those products. If such problems arise substantially in other domains, we stand ready to extend this provision to those domains in future versions of the GPL, as needed to protect the freedom of users.', // 反 Tivoization 条款：禁止硬件设备阻止用户安装修改版软件
  ]

  // ============ UI 构建方法 - build() ============
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column (外层容器)
   * ├─ Flex (固定高度的导航栏)
   * └─ Scroll (可滚动的许可证文本区域)
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
            .interpolation(ImageInterpolation.Medium) // 图片插值算法
            .onClick(() => {
              router.back() // 点击返回上一页
            })
        }
        .alignItems(HorizontalAlign.Start) // 内部元素左对齐
        .width('33%') // 占父容器 33% 宽度

        // 中间标题
        Column() {
          Text(`开源许可`) // 页面标题
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

      // ========== 可滚动的内容区域 ==========
      Scroll() {
        Column() {
          // ========== ForEach 遍历渲染许可证文本 ==========
          ForEach(this.rowsData, (item: string) => {
            Row() { // 水平布局容器
              Text(item) // 许可证文本段落
                .lineHeight(22) // 行高 22 像素
                .font({
                  family: "PingFang SC", // 苹方字体
                  size: 14, // 字号 14 像素
                  style: FontStyle.Normal, // 正常样式
                  weight: 400, // 字重 400（常规粗细）
                })
            }.width("100%") // 占满宽度
            .margin({ top: 12, bottom: 20 }) // 段落间距：上 12 下 20 像素
          })
        }
        .width("100%") // 内容区域宽度
      }
      // ========== Scroll 组件配置 ==========
      .scrollable(ScrollDirection.Vertical) // 设置为垂直滚动方向
      .scrollBar(BarState.Off) // 隐藏滚动条（美化界面）
      .edgeEffect(EdgeEffect.None) // 禁用边缘回弹效果
      .height("100%") // 占满可用高度
      .margin({ bottom: 60 }) // 底部外边距 60 像素
      
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

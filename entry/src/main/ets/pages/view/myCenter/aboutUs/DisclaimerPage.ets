// ============ 导入模块 ============
import { router } from '@kit.ArkUI'; // 页面路由导航 API，用于返回上一页

/**
 * @Entry - 页面入口装饰器
 *   - 标识这是一个独立的页面组件
 * @Component - 组件装饰器
 *   - 定义 UI 组件结构，支持状态管理
 * @struct DisclaimerPage - 免责声明页面组件类
 */
@Entry
@Component
struct DisclaimerPage {
  // ============ 状态变量定义 ============
  
  /** @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
   * 底部安全区域高度适配
   * 用途：适配不同设备的底部 Home Indicator 等安全区域
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** @StorageLink('topRectHeight') topRectHeight: number = 0
   * 顶部安全区域高度适配
   * 用途：适配刘海屏、动态岛等异形屏顶部安全区域
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** @State rowsData: Array<string> - 免责声明内容数据数组
   * 存储所有文本段落，按顺序展示
   * 
   * 数据结构说明：
   *   index 0: 标题 "免责声明 (Disclaimer)"
   *   index 1-4: 各段落内容文本
   *   
   * 内容概要：
   *   - 第 1 段：应用定位和使用场景说明
   *   - 第 2 段：第三方网站搜索机制和责任声明
   *   - 第 3 段：搜索结果保证和法律责任划分
   *   - 第 4 段：隐私保护承诺和服务目的说明
   */
  @State rowsData: Array<string> = [
    '免责声明（Disclaimer）', // 页面标题
    '阅读是一款解析指定规则并获取内容的工具，为广大网络文学爱好者提供一种方便、快捷舒适的试读体验。', // 应用介绍
    '当您搜索一本书的时，阅读会您所使用的规则将该书的书名以关键词的形式提交到各个第三方网络文学网站。各第三方网站返回的内容与阅读无关，阅读对其概不负责，亦不承担任何法律责任。任何通过使用阅读而链接到的第三方网页均系他人制作或提供，您可能从第三方网页上获得其他服务，阅读对其合法性概不负责，亦不承担任何法律责任。第三方搜索引擎结果根据您提交的书名自动搜索获得并提供试读，不代表阅读赞成或被搜索链接到的第三方网页上的内容或立场。您应该对使用搜索引擎的结果自行承担风险。', // 第三方责任声明
    '阅读不做任何形式的保证：不保证第三方搜索引擎的搜索结果满足您的要求，不保证搜索服务不中断，不保证搜索结果的安全性、正确性、及时性、合法性。因网络状况、通讯线路、第三方网站等任何原因而导致您不能正常使用阅读，阅读不承担任何法律责任。阅读尊重并保护所有使用阅读用户的个人隐私权，您注册的用户名、电子邮件地址等个人资料，非经您亲自许可或根据相关法律、法规的强制性规定，阅读不会主动地泄露给第三方。', // 服务保证和隐私政策
    '阅读致力于最大程度地减少网络文学阅读者在自行搜寻过程中的无意义的时间浪费，通过专业搜索展示不同网站中网络文学的最新章节。阅读在为广大小说爱好者提供方便、快捷舒适的试读体验的同时，也使优秀网络文学得以迅速、更广泛的传播，从而达到了在一定程度促进网络文学充分繁荣发展之目的。阅读鼓励广大小说爱好者通过阅读发现优秀网络小说及其提供商，并建议阅读正版图书。任何单位或个人认为通过阅读搜索链接到的第三方网页内容可能涉嫌侵犯其信息网络传播权，应该及时向阅读提出书面权力通知，并提供身份证明、权属证明及详细侵权情况证明。阅读在收到上述法律文件后，将会依法尽快断开相关链接内容。' // 社会价值和侵权处理流程
  ]

  // ============ UI 构建方法 - build() ============
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column (外层容器)
   * ├─ Flex (固定高度的导航栏)
   * └─ Scroll (可滚动的免责声明内容区域)
   */
  build() {
    // ========== 外层垂直布局容器 ==========
    Column({ space: 16 }) { // 子组件间距 16 像素
      
      // ========== 标题部分（固定不动）==========
      // 注意：此区域不滚动，保持在顶部
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
          Text(`免责声明`) // 页面标题
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
          // ========== ForEach 遍历渲染文本段落 ==========
          ForEach(this.rowsData, (item: string) => {
            Row() { // 水平布局容器
              Text(item) // 段落文本
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
      .margin({ bottom: 60 }) // 底部外边距 60 像素（避免遮挡）
      
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

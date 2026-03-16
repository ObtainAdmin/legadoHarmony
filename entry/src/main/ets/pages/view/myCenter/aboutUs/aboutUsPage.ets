/**
 * @className: cyd
 * @description: 关于我们页面 - 应用信息展示与相关功能入口
 * @author: 
 * @date: 2026-03-16
 * 
 * 功能概述：
 * 1. 展示应用版本信息
 * 2. 提供检查更新、查看更新日志等功能入口
 * 3. 提供用户协议、开源许可、免责声明等法律文档入口
 * 4. 提供联系方式（官网、公众号、QQ 频道、QQ 群）
 * 5. 崩溃日志查看功能（预留）
 * 
 * 页面结构：
 * - 顶部导航栏：返回按钮 + 页面标题
 * - 中间功能列表：检查更新、更新日志、开发人员
 * - 联系方式网格：官网、公众号、QQ 频道、QQ 群
 * - 底部法律相关：用户隐私与协议、开源许可、免责声明、崩溃日志
 */

// ============ 数据模型导入 ============
import { dataItem } from 'ets/componets/dataList/dataItem'; // 列表项数据模型类，用于创建功能列表项
import VersionUpdateCustomDialog from 'ets/componets/aboutUs/VersionUpdate'; // 版本更新弹窗组件
import { router } from '@kit.ArkUI'; // 页面路由导航 API，用于页面跳转
import { common, Want } from '@kit.AbilityKit'; // 应用能力调用框架
import { BusinessError } from '@ohos.base'; // 错误处理类型定义
import hilog from '@ohos.hilog'; // HILOG 日志打印工具（鸿蒙系统日志框架）
import { productViewManager } from '@kit.StoreKit'; // 应用商店管理器，用于跳转到应用市场

// ============ 主组件：关于我们页面 ============
/**
 * @Entry - 页面入口装饰器
 *   - 标识这是一个独立的页面组件，HarmonyOS 应用入口
 * @Component - 组件装饰器
 *   - 定义 UI 组件结构，支持状态管理和自定义渲染
 * @struct AboutUsPage - 关于我们页面主组件类
 */
@Entry
@Component
struct AboutUsPage {
  // ============ 状态变量定义 ============
  
  /** @StorageLink('bottomRectHeight') bottomRectHeight: number = 0 
   * 底部安全区域高度适配
   * 用途：适配不同设备的底部安全区域（如 Home Indicator）
   * StorageLink 特点：自动同步到全局存储，页面间共享
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** @StorageLink('topRectHeight') topRectHeight: number = 0
   * 顶部安全区域高度适配
   * 用途：适配刘海屏、动态岛等顶部异形屏
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** @State isShowQQ: boolean = false
   * QQ 群半模态框显示状态控制
   * @State: 装饰器标记该字段为响应式状态，变化时自动触发 UI 刷新
   */
  @State isShowQQ: boolean = false
  
  /** @State version: string = "V1.0.0.1"
   * 当前应用版本号
   * 硬编码版本号，可能从配置文件或构建参数中获取
   */
  @State version: string = "V1.0.0.1"

  // ============ 主要功能列表数据 - 上部分功能区域 ============
  /**
   * @first_list: Array<dataItem> - 上部分功能列表
   * 结构：[功能名称，对应索引值]
   * 索引说明：
   *   0 - 检查更新
   *   1 - 更新日志
   *   2 - 开发人员（预留）
   */
  @State first_list: dataItem[] = [
    new dataItem("检查更新", 1), // 点击跳转到应用商店检查更新
    new dataItem("更新日志", 2), // 点击查看版本更新历史记录
    new dataItem("开发人员", 3), // 开发团队信息（暂未实现）
  ];
  
  // ============ 法律相关功能列表数据 - 下部分功能区域 ============
  /**
   * @end_list: Array<dataItem> - 下部分法律相关功能列表
   * 索引说明：
   *   0 - 用户隐私与协议
   *   1 - 开源许可
   *   2 - 免责声明
   *   3 - 崩溃日志（预留）
   */
  @State end_list: dataItem[] = [
    new dataItem("用户隐私与协议", 1), // 用户隐私政策和服务条款
    new dataItem("开源许可", 2), // Apache/MIT/GPL 等开源许可证
    new dataItem("免责声明", 3), // 应用责任免除声明
    new dataItem("崩溃日志", 4), // 应用异常日志查看（暂未实现）
  ]

  // ============ 版本更新弹窗控制器 ============
  /**
   * dialogController: CustomDialogController
   * 控制版本更新弹窗的显示和隐藏
   * 
   * 配置说明：
   *   builder: 弹窗内容组件
   *   cornerRadius: 圆角大小（像素）
   *   gridCount: 网格列数
   *   alignment: 弹窗对齐方式（居中/左/右）
   * 
   * 注：当前已注释未使用，保留为后续扩展
   */
  dialogController: CustomDialogController = new CustomDialogController({
    builder: VersionUpdateCustomDialog({}), // 弹窗内容构建函数
    cornerRadius: 16, // 弹窗四个角的圆角半径
    gridCount: 3, // 弹窗内部分为 3 列网格
    alignment: DialogAlignment.Center, // 弹窗在屏幕上居中对齐
  })
  
  // ============ QQ 群列表数据 ============
  /**
   * @qqList: Array<string> - QQ 群信息数组
   * 用于 QQ 群半模态框显示
   * 字符串格式："[群类型]:[群号]"
   */
  @State qqList: Array<string> = [
    'Beta 群:887615035' // Beta 测试群号
  ]

  // ============ 功能列表点击事件处理 ============
  
  /**
   * firstUrl_list - 处理上部分功能列表的点击事件
   * 
   * @param value - 点击的列表项索引 (number | string)
   *   HarmonyOS ArkTS 事件传递可能为 string 类型
   * 
   * 功能分支：
   *   case 0: 检查更新 -> 跳转到华为应用市场详情页
   *   case 1: 更新日志 -> 跳转到 versionLogPage.ts
   *   case 2: 开发人员 -> 预留待实现
   */
  firstUrl_list(value: number | string) {
    switch (value) {
      case 0:
        // ========== 检查更新功能 ==========
        // 逻辑说明：
        //   1. 构建 Want 对象，指定目标应用包名
        //   2. 调用 productViewManager.loadProduct 打开应用市场
        //   3. 成功则展示应用详情，失败则打印日志
        
        // 原升级弹窗功能已注释，改为直接跳转到应用市场
        try {
          // 构造能力调用参数
          const request: Want = {
            parameters: {
              bundleName: 'com.legadoX.app' // 应用包名标识符
            }
          };
          
          // 调用应用商店管理器加载应用详情页
          // 参数说明：
          //   getContext(this) as common.UIAbilityContext: 当前应用上下文
          //   request: 应用识别参数
          //   { onError: ... }: 错误处理回调
          productViewManager.loadProduct(getContext(this) as common.UIAbilityContext, request, {
            onError: (error: BusinessError) => {
              // 错误日志：code 为错误码，message 为错误描述
              hilog.info(0, 'TAG', `loadProduct onError. code is ${error.code}, message is ${error.message}`);
            }
          });
        } catch (err) {
          // 捕获异常并打印错误信息
          hilog.error(0, 'TAG', `loadProduct failed. code is ${err.code}, message is ${err.message}`);
        }
        break
        
      case 1:
        // ========== 更新日志功能 ==========
        // 逻辑：使用 router.pushUrl 跳转到版本日志页面
        router.pushUrl({
          url: "pages/view/myCenter/aboutUs/versionLogPage"
        })
        break
        
      case 2:
        // ========== 开发人员功能（预留）==========
        // TODO: 待实现开发团队信息展示界面
        break
    }
  }

  /**
   * endUrl_list - 处理下部分功能列表的点击事件
   * 
   * @param value - 点击的列表项索引
   * 
   * 功能分支：
   *   case 0: 用户隐私与协议 -> PrivacyAgreementPage
   *   case 1: 开源许可 -> OpenSourceLicensePage
   *   case 2: 免责声明 -> DisclaimerPage
   *   case 3: 崩溃日志（预留）
   */
  endUrl_list(value: number | string) {
    switch (value) {
      case 0:
        // 跳转到隐私协议页面
        router.pushUrl({
          url: "pages/view/myCenter/aboutUs/PrivacyAgreementPage"
        })
        break
      case 1:
        // 跳转到开源许可证页面
        router.pushUrl({
          url: "pages/view/myCenter/aboutUs/OpenSourceLicensePage"
        })
        break
      case 2:
        // 跳转到免责声明页面
        router.pushUrl({
          url: "pages/view/myCenter/aboutUs/DisclaimerPage"
        })
        break
      case 3:
        // 崩溃日志功能（预留待实现）
        // TODO: 实现崩溃日志查看和导出功能
        break
    }
  }

  // ============ UI 构建方法 - build() ============
  /**
   * build() - 页面 UI 构建入口
   * 此方法被 @Entry 和 @Component 装饰器调用，负责渲染整个页面
   * 
   * 布局层次：
   * Scroll (可滚动容器)
   * └─ Column (垂直布局，间距 16px)
   *    ├─ Flex (导航栏：返回按钮 + 标题)
   *    ├─ middleClickBuilder (上部分功能列表)
   *    ├─ Grid (联系方式网格布局)
   *    └─ middleClickBuilder (下部分法律功能列表)
   */
  build() {
    // ========== Scroll 容器 ==========
    // 作用：确保长内容可以滚动，适配不同屏幕尺寸
    Scroll() {
      // ========== Column 垂直布局 ==========
      // space: 16 - 子组件之间垂直间距 16 像素
      Column({ space: 16 }) {
        
        // ========== 顶部导航栏区域 ==========
        Flex() { // 水平弹性布局，允许子元素自适应宽度
          // 左侧返回按钮区域
          Column() {
            Image($r("app.media.return_left")) // 从资源文件中加载返回图标
              .size({ width: 24, height: 24 }) // 图标尺寸 24x24 像素
              .interpolation(ImageInterpolation.Medium) // 图片缩放插值算法（中质量）
              .onClick(() => {
                router.back() // 点击返回上一页
              })
          }
          .alignItems(HorizontalAlign.Start) // 内部元素左对齐
          .width('33%') // 占父容器 33% 宽度
      
          // 中间标题区域
          Column() {
            Text(`关于我们`) // 页面标题文本
              .lineHeight(24) // 行高设置为 24 像素
              .font({
                family: "PingFang SC", // 字体家族：苹方（ macOS/ iOS常用字体）
                size: 16, // 字号 16 像素
                weight: 500, // 字重 500（中等粗细，非加粗也非常规）
                style: FontStyle.Normal, // 字体样式：正常（非斜体）
              })
          }.width('33%') // 标题区域占 33% 宽度
        }
        .padding({
          top: 12, // 上内边距 12 像素
          bottom: 12, // 下内边距 12 像素
        })
        .height(48) // 导航栏总高度 48 像素
        .width("100%") // 占满整屏宽度

        // ========== 上部分功能列表 ==========
        // 调用 middleClick 构建器创建功能列表
        this.middleClick(this.first_list, "app.media.right", this.version, "first")

        // ========== 联系方式网格布局 ==========
        Grid() {
          // 第 1 格：官网
          GridItem() {
            this.middleBox(0, "app.media.official_website", "官网")
          }

          // 第 2 格：微信公众号
          GridItem() {
            this.middleBox(1, "app.media.wechat_public_account", "公众号")
          }

          // 第 3 格：QQ 频道
          GridItem() {
            this.middleBox(2, "app.media.channel", "QQ 频道")
          }

          // 第 4 格：QQ 群（带半模态框）
          GridItem() {
            this.middleBox(3, "app.media.QQ", "QQ 群")
          }
        }
        .columnsTemplate('1fr 1fr 1fr 1fr') // 4 列等宽布局（1fr 表示均分）
        .columnsGap(16) // 列间距 16 像素
        .height(80) // 网格容器高度 80 像素
        // ========== QQ 群半模态框绑定 ==========
        // 鸿蒙系统要求 Sheet 必须绑定到具体元素
        .bindSheet($$this.isShowQQ, this.QQDialog(), {
          height: 300, // 半模态框展开高度 300 像素
          showClose: false, // 不显示关闭按钮 X
          dragBar: false, // 不显示拖拽手柄条
          blurStyle: BlurStyle.COMPONENT_ULTRA_THIN, // 背景模糊效果（极细）
          onDisappear: () => {
            // 弹窗消失时的回调钩子（当前为空实现）
          }
        })

        // ========== 下部分法律功能列表 ==========
        this.middleClick(this.end_list, "app.media.right", null, "end")
      }
      .padding({
        left: 20, // 左内边距 20 像素
        right: 20, // 右内边距 20 像素
        top: this.topRectHeight, // 顶部安全区域适配（动态高度）
        bottom: this.bottomRectHeight // 底部安全区域适配
      })
      .height("100%") // 占满父容器高度
      .backgroundColor("rgb(245, 245, 245)") // 浅灰色背景色
    }
  }

  // ============ 构建器：联系方式网格项组件 ============
  /**
   * @Builder middleBox - 辅助 UI 构建方法
   * 用于创建联系方式网格中的单个项目
   * 
   * @param index - 网格项索引 (0-3)
   *   0: 官网，1: 公众号，2: QQ 频道，3: QQ 群
   * @param image - 图标资源路径（string 类型）
   *   例如："app.media.official_website"
   * @param text - 显示在图标下方的文本标签
   * 
   * @returns Column 组件，包含图片和文字
   */
  @Builder
  middleBox(index: number, image: string, text: string) {
    Column({ space: 2 }) { // 垂直布局，内部组件间距 2 像素
      // 联系方式图标
      Image($r(`${image}`)) // 从资源文件加载图标
        .size({ width: 24, height: 24 }) // 图标尺寸 24x24 像素
      
      // 联系方式文本标签
      Text(text) 
        .maxLines(1) // 超过 1 行则省略
        .lineHeight(20) // 行高 20 像素
        .font({
          size: 12, // 字号 12 像素
          weight: 400, // 字重 400（常规粗细）
          style: FontStyle.Normal, // 正常样式
        })
        .opacity(0.45) // 透明度 45%，营造次要/非重点视觉效果
    }
    .padding({
      top: 12, // 上内边距 12 像素
      bottom: 12 // 下内边距 12 像素
    })
    .width("100%") // 占满网格项宽度
    .height(70) // 固定高度 70 像素
    .borderRadius(12) // 圆角 12 像素
    .backgroundColor(Color.White) // 白色背景
    .onClick(() => {
      // ========== 点击事件分发 ==========
      switch (index) {
        case 0:
          // 官网 - 预留功能
          // TODO: 可浏览器跳转到官网 URL
          break
        case 1:
          // 公众号 - 预留功能
          // TODO: 引导用户扫描二维码关注公众号
          break
        case 2:
          // QQ 频道 - 预留功能
          break
        case 3:
          // QQ 群 - 显示半模态框
          this.isShowQQ = true // 切换显示状态
          break
      }
    })
  }

  // ============ 构建器：功能列表项组件 ============
  /**
   * @Builder middleClick - 功能列表构建器
   * 创建通用的功能列表，包含标题、版本号（可选）、右箭头
   * 
   * @param list - 功能列表数据数组 [dataItem]
   *   dataItem 包含 title(标题) 和对应的 identifier(标识)
   * @param image - 右侧箭头图标资源路径
   *   例如："app.media.right"
   * @param version - 版本号字符串，null 表示不显示版本信息
   * @param urlList - 列表类型标识
   *   'first': 上部分功能列表，调用 firstUrl_list 处理
   *   'end': 下部分功能列表，调用 endUrl_list 处理
   * 
   * @returns Column 组件，包含多个 Row 列表项
   */
  @Builder
  middleClick(list: Array<dataItem>, image: string, version: string | null, urlList: string) {
    Column() {
      // ========== ForEach 遍历渲染列表 ==========
      // 鸿蒙 ArkUI 列表渲染语法，类似 Vue 的 v-for
      ForEach(list, (item: dataItem, index) => {
        
        // 单行列表项布局
        Row() { // 水平布局
          
          // 功能标题
          Text(item.title) 
            .lineHeight(22) // 行高 22 像素
            .font({
              size: 16, // 字号 16 像素
              weight: 400, // 字重 400（常规）
              style: FontStyle.Normal,
            })
          
          // Blank(20) - 空白占位符
          // 关键作用：占据剩余空间，将后续元素推到右侧
          Blank(20) 
          
          // 版本号条件渲染
          // 仅在第一个列表项且传入版本号时显示
          if (version && index === 0) {
            Text(version) 
              .lineHeight(20) // 行高 20 像素
              .font({
                size: 12, // 字号 12 像素
                weight: 400, // 字重 400
                style: FontStyle.Normal,
              })
              .baselineOffset(4) // 基线向上偏移 4 像素（与标题垂直对齐调整）
              .opacity(0.45) // 半透明灰色，视觉层级较低
              .margin({
                right: 4 // 右侧外边距 4 像素，与箭头保持距离
              })
          }
          
          // 右侧箭头图标
          Image($r(`${image}`))
            .size({ width: 24, height: 24 }) // 24x24 像素
        }
        .width("100%") // 占满容器宽度
        .height(48) // 固定高度 48 像素
        .onClick(() => {
          // ========== 点击事件分发 ==========
          switch (urlList) {
            case 'first':
              this.firstUrl_list(index) // 处理上部分功能列表点击
              break
            case 'end':
              this.endUrl_list(index) // 处理下部分功能列表点击
              break
          }
        })
      })
    }
    .padding({
      top: 12,
      bottom: 12,
      left: 20,
      right: 20,
    })
    .backgroundColor(Color.White) // 白色背景
    .borderRadius(10) // 圆角 10 像素
  }

  // ============ 构建器：QQ 群对话框 ============
  /**
   * @Builder QQDialog - QQ 群信息半模态框构建器
   * 用于显示 QQ 群号码列表
   * 
   * @returns Column 组件，包含标题、列表、取消按钮
   */
  @Builder
  QQDialog() {
    Column() {
      // 标题区域
      Column() {
        Row() {
          Text("QQ 群")
            .lineHeight(24)
            .font({
              family: "PingFang SC",
              size: 16,
              style: FontStyle.Normal,
              weight: 500,
            })
        }
        .justifyContent(FlexAlign.Center) // 居中对齐
        .height(48)
        .width("100%")

        // 可滚动的 QQ 群列表
        Scroll() {
          Column() {
            // 遍历 QQ 群列表
            ForEach(this.qqList, (item: string) => {
              Row() {
                Text(item)
                  .lineHeight(22)
                  .fontColor("#000000")
                  .font({
                    family: "PingFang SC",
                    size: 14,
                    style: FontStyle.Normal,
                    weight: 400,
                  })
                Blank(20)
                Image($r('app.media.right'))
                  .width(24)
                  .height(24)
                  .margin({
                    right: 5
                  })
              }
              .margin({
                top: 12,
                bottom: 12
              })
              .width('100%')
            })
          }
        }
        .height('60%')
        .scrollBar(BarState.Off) // 隐藏滚动条
      }
      .padding({
        left: 20,
        right: 20
      })

      // 分割线
      Divider()

      // 取消按钮区域
      Column() {
        Text('取消').fontSize(16).fontWeight(400)
          .lineHeight(24)
      }
      .onClick(() => {
        this.isShowQQ = true // 注意：这里设置为 true 会再次显示，可能应为 false 关闭
      })
      .alignItems(HorizontalAlign.Center)
      .padding({
        left: 32,
        right: 32,
        top: 16
      })
    }
    // 注释掉的完整宽高设置
    // .width(CommonConstants.FULL_WIDTH)
    // .height(CommonConstants.FULL_HEIGHT)
  }
}

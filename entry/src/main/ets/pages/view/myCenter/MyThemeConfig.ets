// ============ 导入模块 ============
import { PromptAction, router } from '@kit.ArkUI' // UI 提示和路由 API
import { ThemeColor, ThemeStorageKey } from '../../../common/constants/Theme' // 主题常量
import { ThemeColorItem, ThemeItem } from '../../../common/model/Theme' // 主题类型定义
import { themeManager } from '../../../common/utils/ThemeManager' // 主题管理器工具类
import { JSON } from '@kit.ArkTS' // JSON 处理库（未使用）
import { MyThemeConfigComp } from './MyThemeConfigComp'

/**
 * 导航项接口定义
 * 
 * interface NavItem - 中间导航区元素数据结构
 *   text: 导航文本
 *   img: 图标资源路径
 */
interface NavItem {
  text: string
  img: ResourceStr
}

/**
 * @Entry - 页面入口装饰器
 * @Component - 组件装饰器
 * @struct MyThemeConfig - 主题配置页面组件类
 * 
 * 功能说明：
 *   - TabBar 导航切换：个性主题/桌面图标/启动页
 *   - 默认显示"个性主题"选项卡内容
 *   - 其他两个选项卡待实现
 */
@Entry
@Component
struct MyThemeConfig {
  
  // ============ 安全区域适配 ============
  
  /** @StorageLink('topRectHeight') topRectHeight: number = 0
   * 顶部安全区域高度
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0

  // ========== 导航列表数据 ============
  /**
   * navList: NavItem[] - 中间导航区需要渲染的元素列表
   * 包含三个选项卡：
   *   0: 个性主题（当前激活）
   *   1: 桌面图标（待实现）
   *   2: 启动页（待实现）
   */
  navList: NavItem[] = [
    {text: '个性主题', img: $r('app.media.my_theme_config_theme')},
    {text: '桌面图标', img: $r('app.media.my_theme_config_desktop')},
    {text: '启动页', img: $r('app.media.my_theme_config_welcome')},
  ]
  
  /** @State activeNavIndex: number = 0
   * 标记当前激活的导航元素索引
   * 0=个性主题 / 1=桌面图标 / 2=启动页
   */
  @State activeNavIndex: number = 0 

  // ============ 主题颜色绑定 ============
  
  /** @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
   * 响应式主题颜色绑定
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  // ============ 构建器：TabBar 导航元素 ============
  
  /**
   * @Builder tabBarBuilder - 中间导航区 TabBar 元素构建器
   * 
   * @param item - NavItem 对象
   *   text: 标题文字
   *   img: 图标资源
   * @param index - 索引位置
   * 
   * @returns Column 组件，包含：
   *   - 外层：左右边距容器
   *   - 中层：背景色块（选中深/未选中浅）
   *   - 内层：图标 + 文字 + 三角形指示器
   * 
   * 样式特点：
   *   - 选中状态：白色背景，白色文字，白色图标，主色三角形
   *   - 未选中状态：浅色背景，灰色文字，主色图标
   */
  @Builder
  tabBarBuilder(item: NavItem, index: number) {
    // 最外层包一层 Column(用于设置左右间距), 然后设置左右 padding
    // 如果不包这一层，直接用第二层的 Column 的左右 margin 设置左右间距好像无效
    Column() {
      Column() {
        // 图标
        Image(item.img)
          .width(24) // 图标宽度
          .aspectRatio(1) // 保持正方形比例
          .fillColor(this.activeNavIndex == index ? Color.White : this.theme.mainColor) // 选中标识：白色，否则用主题色
          .margin({bottom: 8}) // 底部外边距 8 像素
        
        // 标题文字
        Text(item.text)
          .lineHeight(20)
          .fontSize(12)
          .fontColor(this.activeNavIndex == index ? Color.White : '#978b83') // 选中白色，未选中灰褐色

        // 选中的 tab 底部会有三角形的效果
        if (this.activeNavIndex == index) {
          // 边缘光滑版三角形
          // Path()
          //   .width(vp2px(18))
          //   .height(vp2px(6))
          //   .commands('M0 0 L' + vp2px(18) + ' 0 S' + vp2px(9) + ' ' + vp2px(6) + ' 0 0 Z')
          //   .fill('#ff6600')
          //   .stroke('#ff6600')
          //   .position({left: '50%', bottom: 0})
          //   .translate({x: -9, y: '100%'})

          // 正常边缘三角形
          Polygon({ width: 18, height: 6 })
            .points([[0, 0], [9, 6], [18, 0]]) // 定义三点形成等腰三角形
            .fill(Color.Green) // 备用填充色
            .fill(this.theme.mainColor) // 实际使用主题色
            .position({left: '50%', bottom: 0}) // 定位：水平居中，底部对齐
            .translate({x: '-50%', y: '100%'}) // 偏移：向左移自身宽度的 50%，向下移自身高度的 100%（确保顶点在中心）
        }
      }
      .padding({left: 24, right: 24, top: 12}) // 内边距
      .backgroundColor(this.activeNavIndex == index ? this.theme.mainColor : this.theme.secondColor) // 选中主色，未选中次色
      .borderRadius(8) // 圆角 8 像素
      .width(96) // 固定宽度 96
      .height(78) // 固定高度 78
      .margin({bottom: 10}) // 下外边距 10 像素
      
    }
    .padding({
      left: index == 0 ? 20 : 0, // 第一项左侧留空 20
      right: index == this.navList.length - 1 ? 20 : 0 // 最后一项右侧留空 20
    })
  }

  // ============ UI 构建方法 - build() ============
  
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column (浅灰背景容器)
   * ├─ RelativeContainer (头部标题栏)
   * │  ├─ 返回按钮
   * │  └─ 标题"主题"
   * └─ Tabs (横向滑动标签页容器)
   *    ├─ TabContent(个性主题) -> MyThemeConfigComp
   *    ├─ TabContent(桌面图标) -> 占位
   *    └─ TabContent(启动页) -> 占位
   * 
   * 样式特点：
   *   - TabBar 固定在左侧
   *   - 内容区域随 Tab 滑动
   *   - 支持点击 Tab 切换内容
   */
  build() {
    Column() {
      
      // ========== 头部标题栏 ==========
      RelativeContainer() { // 相对定位容器
        
        // 左侧返回按钮
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .aspectRatio(1)
          .alignRules({
            center: {anchor: '__container__', align: VerticalAlign.Center},
            left: {anchor: '__container__', align: HorizontalAlign.Start}
          })
          .onClick(() => {
            router.back() // 返回上一页
          })
        
        // 居中标题
        Text('主题')
          .fontWeight(FontWeight.Bold) // 加粗
          .alignRules({
            center: {anchor: '__container__', align: VerticalAlign.Center},
            middle: {anchor: '__container__', align: HorizontalAlign.Center}
          })
      }
      .padding({left: 20, right: 20, top: 12, bottom: 12})
      .width('100%')
      .height(48) // 固定高度
      
      // ========== 中间导航区 ===========
      Tabs({barPosition: BarPosition.Start}) { // 标签页容器，TabBar 在左侧
       ForEach(this.navList, (item: NavItem, index) => {
         TabContent() {
            Column() {
              // 如果选中个性主题
              if (index == 0) {
                MyThemeConfigComp()
              }
              // 如果选中桌面图标
              else if (index == 1) {
                // TODO: 待实现桌面图标配置
              }
              // 如果选中启动页
              else {
                // TODO: 待实现启动页配置
              }
            }
            .padding({left: 20, right: 20, top: 24}) // 内边距
            .borderRadius({
              topLeft: 12,
              topRight: 12
            })
           .backgroundColor('#fff') // 白色背景
           .width('100%') // 占满宽度
         }
         .tabBar(this.tabBarBuilder(item, index)) // 关联 TabBar 构建器
       })
      }
      // 处理点击 tab 切换逻辑
      .onTabBarClick((index) => {
        this.activeNavIndex = index // 更新选中索引
      })
      .scrollable(false) // 禁止横向滚动（Tabs 自动处理）
      .width('100%')
      .barHeight(98) // TabBar 高度 98 像素
      .backgroundColor('#f5f5f5') // 背景色
      
    }
    .height('100%')
    .width('100%')
    .padding({top: this.topRectHeight})
    .backgroundColor('#f5f5f5')

  }
}

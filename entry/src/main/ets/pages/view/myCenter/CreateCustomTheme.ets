// ============ 导入模块 ============
import { componentSnapshot, promptAction, router } from '@kit.ArkUI' // 组件截图、提示、路由
import { image } from '@kit.ImageKit' // 图像处理库
import { emitter } from '@kit.BasicServicesKit' // 事件发射器
import { ThemeColor, ThemeStorageKey } from '../../../common/constants/Theme' // 主题常量
import { ThemeColorItem, ThemeItem } from '../../../common/model/Theme' // 主题类型定义
import { themeManager } from '../../../common/utils/ThemeManager' // 主题管理器
import { sleep } from '../../../common/utils/utils' // 睡眠辅助函数

/**
 * @Entry - 页面入口装饰器
 * @Component - 组件装饰器
 * @struct CreateCustomTheme - 创建自定义主题页面组件类
 */
@Entry
@Component
struct CreateCustomTheme {
  
  // ============ 安全区域适配 ============
  
  /** @StorageLink('topRectHeight') topRectHeight: number = 0
   * 顶部安全区域高度（刘海屏适配）
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
   * 底部安全区域高度（Home Indicator 适配）
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0

  // ============ 颜色列表 ============
  
  /**
   * colorList: ThemeColorItem[] - 预设主题色列表
   * 包含红橙黄绿蓝五种主色调选项
   */
  colorList: ThemeColorItem[] = [
    ThemeColor.RED,       // 红色主题
    ThemeColor.ORANGE,    // 橙色主题
    ThemeColor.BLUE,      // 蓝色主题
    ThemeColor.GREEN,     // 绿色主题
    ThemeColor.YELLOW,    // 黄色主题
  ]

  // ============ 预览截图绑定 ============
  
  /**
   * @StorageProp('screen_shot') previewIndexPage: PixelMap = {} as PixelMap
   * 首页截图预览，实时更新主题配色效果
   * StorageProp: 监听全局变化自动更新
   */
  @StorageProp('screen_shot') previewIndexPage: PixelMap = {} as PixelMap
  
  /** @State activeIndex: number = 0
   * 当前选中的主题色索引
   */
  @State activeIndex: number = 0
  
  // ============ 主题状态管理 ============
  
  /** @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
   * 响应式主题颜色绑定（全局共享）
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /** originTheme: ThemeItem - 原主题配置缓存
   * 用于用户取消操作时恢复原主题
   */
  originTheme: ThemeItem = {} as ThemeItem
  
  /** selectTheme: ThemeItem - 新主题配置
   * 存储用户正在编辑的新主题
   */
  selectTheme: ThemeItem = {} as ThemeItem
  
  /** @State themeName: string = '新建主题'
   * 主题名称输入框内容
   */
  @State themeName: string = '新建主题'

  // ============ 生命周期方法 ============
  
  /**
   * aboutToAppear - 组件即将出现时调用
   * 初始化主题配置副本
   */
  aboutToAppear(): void {
    this.originTheme = this.theme // 暂存原主题配置信息
    this.selectTheme = this.theme // 复制当前主题作为基础
  }

  /**
   * aboutToDisappear - 组件消失时调用
   * 如果用户取消编辑，恢复原主题
   */
  aboutToDisappear() {
    themeManager.setTheme(this.originTheme, AppStorage.get(ThemeStorageKey.THEMEINDEX) as number)
  }

  // ============ UI 构建方法 - build() ============
  
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column
   * ├─ RelativeContainer (头部标题栏)
   * │  ├─ 返回按钮
   * │  ├─ 主题名称输入框 + 编辑图标
   * │  └─ 保存按钮
   * ├─ Column (截图预览区)
   * └─ Row (底部选色区)
   *    ├─ 自定义主题按钮
   *    ├─ 分割线
   *    └─ Scroll (横向滚动选择预设颜色)
   */
  build() {
    Column() {
      
      // ========== 头部标题栏 ==========
      RelativeContainer() { // 相对定位容器
        
        // 左侧返回按钮
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .aspectRatio(1) // 保持正方形比例
          .alignRules({ // 位置规则
            center: { anchor: '__container__', align: VerticalAlign.Center },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          })
          .onClick(() => {
            // 取消编辑，恢复原主题
            themeManager.setTheme(this.originTheme, AppStorage.get(ThemeStorageKey.THEMEINDEX) as number)
            router.back()
          })
        
        // 中间标题输入区
        Row({space: 8}) {
          TextInput({text: $$this.themeName}) // 双绑模式文本输入
            .height(24)
            .lineHeight(24)
            .fontSize(16)
            .fontWeight(FontWeight.Bold) // 粗体显示
            .onSubmit(() => {
              this.selectTheme.text = this.themeName // 提交时更新主题名
            })
            .padding(0)
            .width(75) // 固定宽度
            .backgroundColor(Color.Transparent) // 透明背景
          
          Image($r('app.media.writing')) // 编辑图标
            .width(16)
            .aspectRatio(1)
            .fillColor(Color.Black)
        }
        .layoutWeight(1) // 占据剩余空间
        .alignItems(VerticalAlign.Center)
        .height(24)
        .alignRules({ // 居中对齐
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })

        // 右侧保存按钮
        Text('保存')
          .fontSize(14)
          .height(22)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .onClick(() => {
            // 保存新主题
            themeManager.setTheme(this.originTheme, AppStorage.get(ThemeStorageKey.THEMEINDEX) as number)
            this.selectTheme.text = this.themeName
            themeManager.addTheme(this.selectTheme) // 添加到主题列表
            router.back() // 返回上一页
          })

      }
      .padding({
        left: 20,
        right: 20,
        top: 12,
        bottom: 12
      })
      .width('100%')
      .height(48)
      .backgroundColor('#fff') // 白色背景

      // ========== 截图预览区 ==========
      Column() {
        Image(this.previewIndexPage) // 显示首页截图预览
          .width(240)
          .backgroundColor('#ffdfca') // 备用背景色
          .objectFit(ImageFit.Cover) // 裁剪填充
      }
      .width('100%')
      .layoutWeight(1) // 占满剩余空间
      .padding({left: 60, right: 60, top: 72, bottom: 88})
      .backgroundColor('#f5f5f5') // 浅灰背景

      // ========== 底部选色区 ==========
      Row({space: 12}) {
        // 自定义主题按钮
        Row() {
          Image($r('app.media.my_theme_config_custom')) // 铅笔图标
            .width(16)
            .aspectRatio(1)
            .fillColor('#858585')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width(40)
        .aspectRatio(1)
        .borderRadius(20) // 圆形
        .backgroundColor('#f0f0f0')

        // 垂直分割线
        Column() {

        }
        .height(40)
        .width(1)
        .backgroundColor('#f0f0f0')

        // 预设颜色滚动选择器
        Scroll() {
          Row({space: 12}) {
            ForEach(this.colorList, (item: ThemeItem, index) => {
              Row() {

              }
              .width(40)
              .aspectRatio(1)
              .borderRadius(20) // 圆形色块
              .backgroundColor(item.mainColor) // 主色填充
              .onClick(async () => {
                // 点击后逐步切换主题（模拟动画效果）
                let count = 10
                while (count--) {
                  themeManager.setTheme(item, AppStorage.get(ThemeStorageKey.THEMEINDEX) as number)
                  this.selectTheme = item
                  emitter.emit('screen_shot'); // 触发截图书刷新
                  this.previewIndexPage = AppStorage.get('screen_shot') as PixelMap
                  await sleep(100) // 每次切换延迟 100ms
                }
              })
            })
          }
          .height('100%')
        }
        .scrollable(ScrollDirection.Horizontal) // 横向滚动
        .scrollBar(BarState.Off) // 隐藏滚动条
        .height('100%')
      }
      .height(72)
      .width('100%')
      .backgroundColor('#fff')
      .padding({left: 20, right: 20, top: 16, bottom: 16})

    }
    .width('100%')
    .height('100%')
    .padding({top: this.topRectHeight, bottom: this.bottomRectHeight})
    .backgroundColor('#fff')
  }
}

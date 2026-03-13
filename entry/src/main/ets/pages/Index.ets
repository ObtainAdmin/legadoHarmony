/**
 * 应用主页面 - 包含底部导航栏的首页
 * 
 * 功能概述：
 * 1. 提供底部导航栏，包含四个主要功能模块：书架、发现、订阅源、我的
 * 2. 管理页面切换和状态栏显示
 * 3. 处理截图功能用于主题预览
 * 4. 管理应用主题和亮度设置
 * 
 * 主要组件：
 * - Tabs：底部导航栏容器
 * - TabContent：每个标签页的内容区域
 * - 各功能模块组件：BookShelf、Find、Subscription、MyCenter
 * 
 * 使用说明：
 * 此页面是应用的入口页面，用户启动应用后首先看到的界面。
 * 通过底部导航栏可以在四个主要功能模块之间切换。
 */

import { showMessage } from '../componets/common/promptShow'
import ReadShow from '../componets/common/ReadShow'
import { NavItem } from '../componets/dataList/type'
import { updateAppData } from '../storage/appData'
import BookShelf from './view/BookShelf'
import Find from './view/Find/Find'
import MyCenter from './view/myCenter/MyCenter'
import Subscription from './view/Subscription'
import { testGetColorFunction } from '@ohos/colorLibrary'
import { BusinessError, emitter } from '@kit.BasicServicesKit'
import { JSON } from '@kit.ArkTS'
import { image } from '@kit.ImageKit'
import { ThemeStorageKey } from '../common/constants/Theme'
import { ThemeItem } from '../common/model/Theme'
import { WindowAbility } from '../entryability/WindowAbility'
import BrightnessUtil from '../../common/utils/BrightnessUtil'

@Entry
@Component
struct Main {
  /**
   * 应用主页面结构体
   * 
   * 职责：
   * 1. 管理底部导航栏的状态和切换
   * 2. 控制各个功能页面的显示
   * 3. 处理页面生命周期事件
   * 4. 管理应用主题和系统交互
   */
  /** 是否显示阅读引导界面 */
  @State showReadShow: boolean = true
  
  /** 当前选中的标签页索引：0-书架，1-发现，2-订阅源，3-我的 */
  @State currentTabIndex: number = 0
  
  /** 是否显示界面元素（用于初始加载动画） */
  @State isShow: boolean = true
  
  /** 底部安全区域高度，用于适配不同设备 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 顶部安全区域高度，用于适配不同设备 */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 标签栏是否可滚动（锁定状态），存储在应用存储中 */
  @StorageProp('APP_INDEX_SCROLLABLE') APP_INDEX_SCROLLABLE: boolean = true
  
  /** 是否显示底部导航栏 */
  @State ShowBar: boolean = true
  
  /** 标签页控制器，用于管理标签页切换 */
  tabController: TabsController = new TabsController()
  
  /** 应用主题配置，从应用存储中读取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 页面显示时调用的生命周期方法
   * 
   * 功能：
   * 1. 恢复系统默认亮度（退出阅读模式后）
   * 2. 显示状态栏和导航栏
   * 3. 5秒后隐藏阅读引导界面
   * 4. 监听订阅源批量编辑事件
   */
  onPageShow(): void {
    // 退出阅读页面后恢复系统亮度
    BrightnessUtil.setBrightness('default', -1)
    // 退出阅读页面后显示状态栏
    WindowAbility.getInstance().toggleWindowSystemBar(['status', 'navigation'], this.getUIContext().getHostContext());
    // initBookListData()
    
    // 5秒后隐藏阅读引导界面和初始动画
    setTimeout(() => {
      this.showReadShow = false
      this.isShow = false
    }, 5000)

    // 监听订阅源批量编辑事件，控制底部导航栏显示
    getContext(this).eventHub.on('SubscriptionBatchEdit', (params: boolean) => {
      this.ShowBar = params
      this.APP_INDEX_SCROLLABLE = !this.APP_INDEX_SCROLLABLE
      console.log('SubscriptionBatchEdit:' + params)
    })
    
    console.debug('res1', this.bottomRectHeight)
  }

  /**
   * 截图功能 - 用于主题设置预览
   * 
   * 实现原理：
   * 1. 临时切换到首页（索引0）以确保截图内容一致
   * 2. 获取整个页面的组件截图
   * 3. 将截图保存到应用存储中
   * 4. 恢复用户原来的页面
   * 
   * 使用场景：
   * 在"我的"页面中设置主题时，需要预览主题效果
   */
  screenShot() {
    // 保存当前页面索引
    let index = this.currentTabIndex
    
    // 临时切换到首页（确保截图内容一致）
    this.tabController.changeIndex(0)
    
    // 获取页面截图
    this.getUIContext().getComponentSnapshot().get('main', ((err: Error, pixmap: image.PixelMap) => {
      if (err) {
        console.log("error: " + JSON.stringify(err))
        return
      }
      // 将截图保存到应用存储，供主题预览使用
      AppStorage.setOrCreate('screen_shot', pixmap)
    }))
    
    // 恢复用户原来的页面
    this.tabController.changeIndex(index)
  }

  /**
   * 组件即将出现时调用的生命周期方法
   * 
   * 功能：
   * 1. 显示状态栏和导航栏
   * 2. 注册截图事件监听器（用于主题预览）
   * 3. 测试颜色模块功能
   */
  aboutToAppear(): void {
    // 退出阅读页面后显示状态栏
    WindowAbility.getInstance().toggleWindowSystemBar(['status', 'navigation'], this.getUIContext().getHostContext());
    
    // 注册监听截图事件，用于我的页面下主题设置预览
    emitter.on('screen_shot', () => {
      this.screenShot()
    })
    
    // 测试颜色模块功能
    testGetColorFunction();
  }

  /**
   * 构建底部导航栏标签项的Builder函数
   * 
   * @param index 标签页索引
   * @param name 标签页显示名称
   * @param icon_select 选中状态图标资源
   * @param unselected 未选中状态图标资源
   * @returns 构建好的标签项组件
   * 
   * 功能特点：
   * 1. 根据当前选中状态显示不同图标和颜色
   * 2. 支持长按手势锁定/解锁标签栏
   * 3. 使用主题颜色高亮当前选中项
   */
  @Builder
  TabBuilder(index = 0, name: string, icon_select: Resource, unselected: Resource) {
    Column() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.Center
      }) {
        // 根据选中状态显示不同图标，并使用主题颜色
        Image(this.currentTabIndex === index ? icon_select : unselected).height(25)
          .draggable(false)
          .fillColor(this.currentTabIndex === index ? this.theme.mainColor : '#000000')
        
        // 标签文字，同样使用主题颜色
        Text(name).fontSize(11).margin(5).fontColor(this.currentTabIndex === index ? this.theme.mainColor : '#000000')
      }
    }
    // 长按手势：锁定/解锁标签栏
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction((event: GestureEvent) => {
          updateAppData(!this.APP_INDEX_SCROLLABLE)
          showMessage(this.APP_INDEX_SCROLLABLE ? '标签栏锁已开启' : '标签栏已解锁')
        }))
    .width('100%')
    .margin({ top: 4 })
    .height("100%")
  }

  /** 导航栏配置数组，定义四个主要功能模块 */
  nav: NavItem[] = [
    new NavItem(0, $r("app.media.HOME_theme"), $r('app.media.HOME_line'), '书架'),
    new NavItem(1, $r('app.media.FIND_theme'), $r('app.media.FIND_line'), '发现'),
    new NavItem(2, $r('app.media.SUB_theme'), $r('app.media.SUB_line'), '订阅源'),
    new NavItem(3, $r('app.media.MINE_theme'), $r('app.media.MINE_line'), '我的')
  ]

  /**
   * 构建页面UI的主要方法
   * 
   * 布局结构：
   * 1. 底部导航栏（Tabs组件）
   * 2. 四个功能页面根据选中状态显示
   * 3. 可选的阅读引导界面
   * 
   * 交互逻辑：
   * - 根据currentTabIndex显示对应的功能页面
   * - 根据ShowBar控制底部导航栏显示/隐藏
   * - 根据APP_INDEX_SCROLLABLE控制标签栏是否可滚动
   */
  build() {
    Column() {
      // 底部导航栏容器
      Tabs({
        index: this.currentTabIndex,
        barPosition: BarPosition.End,  // 底部位置
        controller: this.tabController
      }) {
        // 遍历导航项，创建对应的标签页
        ForEach(this.nav, (item: NavItem) => {
          TabContent() {
            Column() {
              // 根据索引显示对应的功能页面
              if (item.index === 0) {
                BookShelf()  // 书架页面
              } else if (item.index === 1) {
                Find()  // 发现页面
              } else if (item.index === 2) {
                // 订阅源页面，传递当前标签索引
                Subscription({
                  currentTabIndex: this.currentTabIndex
                })
              }
              if (item.index === 3) {
                MyCenter()  // 我的页面
              }
            }
          }.tabBar(
            // 使用TabBuilder构建标签项
            this.TabBuilder(item.index, item.title, item.selectImg, item.unselected)
          )
        })
      }
      // 控制底部导航栏高度（为0时隐藏）
      .barHeight(this.ShowBar ? null : 0)
      // 控制标签栏是否可滚动
      .scrollable(!this.APP_INDEX_SCROLLABLE)
      // 适配底部安全区域
      .padding({ bottom: this.bottomRectHeight })
      // 监听标签页切换动画开始事件，更新当前选中索引
      .onAnimationStart((index, targetIndex) => {
        this.currentTabIndex = targetIndex
      })

      // 显示阅读引导界面（初始加载时显示）
      if (this.showReadShow) {
        ReadShow({ showReadShow: this.showReadShow }).offset({ y: -150 - this.bottomRectHeight })
      }
    }
    .width("100%")
    .height("100%")
    .id('main')  // 为截图功能提供组件ID
  }
}

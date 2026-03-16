/**
 * @author 2008
 * @datetime 2024/7/14 19:57
 * @className: BodyContent
 * @description: 内容主体组件 - 负责展示小说/漫画/有声书的源列表及对应内容
 * 
 * 组件功能概述：
 * 1. 作为发现页面的核心内容展示组件，负责管理小说、漫画、有声书三个分类的内容
 * 2. 提供书籍源切换功能，用户可以在不同源之间切换查看内容
 * 3. 集成内容刷新机制，支持下拉刷新和手动刷新
 * 4. 提供源管理功能，用户可以通过底部弹窗进行源的相关操作
 * 
 * 组件生命周期：
 * - aboutToAppear(): 组件创建时初始化数据
 * - onPageShow(): 页面显示时重新加载数据，确保数据新鲜度
 * - getList(): 核心数据加载方法，根据条件查询数据库获取源列表
 * 
 * 数据管理：
 * - 使用@State管理组件内部状态（加载状态、源列表、选中索引等）
 * - 使用@Prop接收父组件传入的当前分类索引
 * - 使用@StorageLink/@StorageProp与全局状态进行同步
 * - 使用@Watch监听关键数据变化，自动触发数据重新加载
 */

// 导入必要的常量和工具类
import CommonConstants from '../../../../common/constants/CommonConstants'  // 应用通用常量
import { ThemeStorageKey } from '../../../../common/constants/Theme'  // 主题相关常量
import { ThemeItem } from '../../../../common/model/Theme'  // 主题数据模型
import sourceType from '../../../../componets/common/sourceType' // 源类型展示组件，用于渲染源选择标签
import SourceCommon from '../../../../componets/source/SourceCommon' // 源通用操作组件，提供源管理功能
import BookSourceDao from '../../../../database/dao/BookSourceDao' // 书籍源数据库操作类，负责数据查询
import { BookSource } from '../../../../database/entities/BookSource' // 书籍源实体类，定义数据结构
import ContentRefresh from './ContentRefresh' // 内容刷新组件，负责具体内容的展示和刷新

/**
 * 内容主体组件
 * @prop {number} currentIndex - 当前选中的分类索引（0-小说，1-漫画，2-有声书）
 * 
 * 状态管理：
 * - loading: 控制加载状态的显示
 * - sourceList: 存储查询到的书籍源列表
 * - currentSourceIndex: 记录当前选中的源索引
 * - isShowDialog: 控制底部弹窗的显示状态
 */
@Component
export default struct BodyContent {
  // 分类标题数组，对应底部Tab的三个分类
  titleArray: string[] = ['小说', '漫画', '有声书']
  
  // === 组件状态管理 ===
  
  // 加载状态标识 - true表示正在加载数据，false表示加载完成
  @State loading: boolean = true
  
  // 书籍源列表 - 存储从数据库查询到的可用书籍源数据
  @State sourceList: BookSource[] = []
  
  // 当前选中的源索引 - 用于标识用户当前选择的书籍源
  @State currentSourceIndex: number = 0
  
  // 是否显示底部弹窗 - 控制源通用操作弹窗的显示/隐藏
  @State isShowDialog: boolean = false

  // === 父组件传入属性 ===
  
  // 当前选中的分类索引，从父组件传入，带有@Watch监听
  // 当分类切换时，自动触发getList()重新加载对应分类的源
  @Prop @Watch('getList') currentIndex: number

  // === 全局状态同步 ===
  
  // 是否有探索URL的全局状态，带有@Watch监听
  // 当全局状态变化时，自动重新加载数据
  @StorageLink(CommonConstants.HAS_EXPLORE_URL) @Watch('getList') hasExploreUrl?: boolean = undefined
  
  // Tabs组件控制器 - 用于控制Tabs的切换和索引管理
  tabsBodyController: TabsController = new TabsController();
  
  // 刷新计数的全局状态，带有@Watch监听
  // 当用户触发刷新操作时，自动重新加载数据
  @StorageLink('refreshCount') @Watch('getList') refreshCount: number = 0
  
  // 主题颜色配置 - 从Storage中获取当前主题配置，用于UI样式
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 组件即将出现时的生命周期方法
   * 触发时机：组件被创建并即将渲染到界面前
   * 功能：初始化组件数据，确保组件首次渲染时有数据可显示
   */
  aboutToAppear() {
    this.getList()
  }

  /**
   * 页面显示时的生命周期方法
   * 触发时机：页面从后台切换到前台，或从其他页面返回时
   * 功能：重新加载数据源，确保显示的数据是最新的
   * 注意：这是页面级别的生命周期，可能会被多次调用
   */
  onPageShow() {
    this.getList()
  }

  /**
   * 获取书籍源列表的核心方法
   * 功能概述：根据当前分类和其他条件，从数据库查询可用的书籍源
   * 
   * 查询条件：
   * - type: 书籍类型（小说/漫画/有声书）
   * - enabled: 只查询启用状态的源
   * - hasExploreUrl: 根据是否有探索URL进行过滤
   * - showExplore: 只显示支持探索功能的源
   * 
   * 数据处理流程：
   * 1. 设置加载状态为true，显示加载动画
   * 2. 调用BookSourceDao.search()查询数据库
   * 3. 查询成功后更新sourceList并取消加载状态
   * 4. 查询失败时也要确保取消加载状态，避免界面卡死
   */
  getList() {
    // 开始加载，设置加载状态为true，UI会显示加载动画
    this.loading = true
    
    // 从数据库查询符合条件的书籍源
    BookSourceDao.search({
      // 类型映射：将currentIndex映射到对应的书籍类型
      // 0-小说，2-漫画，1-有声书（注意：这里是故意这样映射的）
      type: [0, 2, 1][this.currentIndex],
      enabled: true, // 只查询启用状态的源
      hasExploreUrl: this.hasExploreUrl, // 根据是否有探索URL进行过滤
      showExplore: true // 只显示支持探索功能的源
    }).then(bookSources => {
      // 调试日志：打印前3个源的信息，用于开发和调试
      console.info('TagInfo', JSON.stringify(bookSources.slice(0, 3)))
      
      // 将查询结果赋值给源列表，触发UI更新
      this.sourceList = bookSources
      
      // 加载完成，设置加载状态为false，隐藏加载动画
      this.loading = false
    }).catch(() => {
      // 异常处理：即使查询失败，也要将加载状态设为false
      // 避免界面一直处于加载状态，影响用户体验
      this.loading = false
    })
  }

  /**
   * 组件构建方法 - 定义组件的UI结构和交互逻辑
   */
  build() {
    // 垂直列布局，作为整个组件的根容器
    Column() {
      // 水平弹性布局 - 顶部源选择栏
      Flex(
        {
          alignContent: FlexAlign.Center, // 交叉轴内容居中
          alignItems: ItemAlign.Center, // 子元素在交叉轴居中
          justifyContent: FlexAlign.SpaceBetween // 主轴两端对齐
        }
      ) {
        // 加载中状态：显示加载进度条和提示文字
        if (this.loading) {
          Row() {
            LoadingProgress()
              .color(this.theme.mainColor) // 使用主题主色
              .width(30)
            Text('加载中...')
          }
        }
        // 有数据源：显示可横向滚动的源列表
        else if (this.sourceList.length) {
          Scroll() {
            Row({ space: 20 }) { // 源项之间间距20
              // 遍历源列表，渲染每个源选项
              ForEach(this.sourceList, (item: BookSource, index: number) => {
                sourceType({
                  title: item.bookSourceName, // 源名称
                  active: this.currentSourceIndex === index, // 是否为当前选中项
                })
                // 点击切换选中的源
                  .onClick(() => {
                    this.tabsBodyController.changeIndex(index) // 切换Tabs索引
                    this.currentSourceIndex = index // 更新当前选中索引
                  })
              })
            }
            .padding({ right: 12 }) // 右侧内边距12
            .margin({ top: 5, bottom: 5 }) // 上下外边距5
          }
          .scrollBar(BarState.Off) // 隐藏滚动条
          .scrollable(ScrollDirection.Horizontal) // 仅允许横向滚动
        }
        // 无数据源：显示空提示
        else {
          Text(`暂无${this.titleArray[this.currentIndex]}源`)
            .fontSize(18)
            .fontWeight(700)
        }

        // 更多操作按钮
        Row() {
          Image($r('app.media.more_search')).width(24).height(24) // 更多图标
        }
        .width(34)
        .onClick(() => {
          // 只有当源列表有数据时才显示弹窗
          if (this.sourceList.length) {
            this.isShowDialog = true
          }
        })
        // 绑定底部弹窗
        .bindSheet(this.isShowDialog, this.sourceCommon(), {
          detents: [SheetSize.FIT_CONTENT, SheetSize.LARGE, 200], // 弹窗高度选项
          dragBar: true, // 显示拖拽条
          showClose: false, // 不显示关闭按钮
          onDisappear: () => {
            this.isShowDialog = false // 弹窗消失时重置显示状态
          }
        })
      }
      .margin({ left: 20, right: 10 }) // 顶部栏左右外边距


      // 内容区域
      // 加载中状态：显示居中的加载进度条
      if (this.loading) {
        Column() {
          LoadingProgress()
            .color(this.theme.mainColor)
            .width('50%')
          Text('加载中...')
        }
        .justifyContent(FlexAlign.Center) // 垂直居中
        .layoutWeight(1) // 占满剩余空间
      }
      // 无数据源状态：显示空状态提示
      else if (!this.sourceList.length) {
        Column() {
          Image($r('app.media.find_empty')) // 空状态图片
            .width(124)
            .height(120)

          Text(`暂无${this.titleArray[this.currentIndex]}源，点击右上角加号添加吧~`)
            .fontSize(14)
            .fontColor('#73000000')
            .margin({ top: 32 })
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
      }
      // 有数据源状态：显示Tabs内容区域
      else {
        Tabs({
          controller: this.tabsBodyController // 绑定Tabs控制器
        }) {
          // 遍历源列表，为每个源创建一个TabContent
          ForEach(this.sourceList, (item: BookSource, index: number) => {
            TabContent() {
              // 内容刷新组件 - 展示对应源的具体内容
              ContentRefresh({
                currentIndex: this.currentIndex, // 当前分类索引
                bookSource: item, // 当前书籍源
                hasExploreUrl: this.hasExploreUrl, // 是否有探索URL
                refreshCount: this.refreshCount // 刷新计数
              })
            }
            .height('100%') // Tab内容高度100%
            .align(Alignment.Top) // 内容顶部对齐
          })
        }
        .scrollable(false) // 禁用Tabs自身滚动
        .barWidth(0) // 隐藏Tab指示器宽度
        .barHeight(0) // 隐藏Tab指示器高度
        .layoutWeight(1) // 占满剩余空间
        .onChange((index) => {
          // Tabs切换时更新选中索引
          this.tabsBodyController.changeIndex(index)
          this.currentSourceIndex = index
        })
      }
    }
    .layoutWeight(1) // 根容器占满父组件剩余空间
  }

  /**
   * 构建源通用操作弹窗内容
   * 这是一个自定义构建函数，用于创建底部弹窗的内容
   * 
   * 功能：
   * 1. 创建包含SourceCommon组件的容器
   * 2. 传递必要的参数给SourceCommon组件
   * 3. 设置弹窗内容的高度为100%，确保正确显示
   * 
   * @returns {void} 构建弹窗内容，但不返回具体值
   * 
   * 参数说明：
   * - showDialog: 控制弹窗显示状态，实现双向绑定
   * - currentIndex: 当前分类索引，用于确定操作哪个分类的源
   * - refreshCount: 刷新计数，用于触发刷新操作
   */
  @Builder
  sourceCommon() {
    Column() {
      SourceCommon({
        showDialog: this.isShowDialog, // 弹窗显示状态，用于控制弹窗行为
        currentIndex: this.currentIndex, // 当前分类索引，用于确定操作目标
        refreshCount: this.refreshCount // 刷新计数，用于触发刷新操作
      })
    }.height('100%') // 设置弹窗内容高度为100%，确保内容能够完全展示
  }
}
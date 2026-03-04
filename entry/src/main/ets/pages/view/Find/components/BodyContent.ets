/**
 * @author 2008
 * @datetime 2024/7/14 19:57
 * @className: BodyContent
 * @description: 内容主体组件 - 负责展示小说/漫画/有声书的源列表及对应内容
 */
import CommonConstants from '../../../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../../../common/constants/Theme'
import { ThemeItem } from '../../../../common/model/Theme'
import sourceType from '../../../../componets/common/sourceType' // 源类型展示组件
import SourceCommon from '../../../../componets/source/SourceCommon' // 源通用操作组件
import BookSourceDao from '../../../../database/dao/BookSourceDao' // 书籍源数据库操作类
import { BookSource } from '../../../../database/entities/BookSource' // 书籍源实体类
import ContentRefresh from './ContentRefresh' // 内容刷新组件

@Component // 声明这是一个ArkTS组件
export default struct BodyContent {
  // 顶部标题数组 - 对应小说/漫画/有声书三个分类
  titleArray: string[] = ['小说', '漫画', '有声书']
  // 加载状态标识 - true表示正在加载，false表示加载完成
  @State loading: boolean = true
  // 书籍源列表 - 存储从数据库查询到的可用书籍源
  @State sourceList: BookSource[] = []
  // 当前选中的源索引 - 用于标识用户当前选择的书籍源
  @State currentSourceIndex: number = 0
  // 是否显示底部弹窗标识 - 控制源通用操作弹窗的显示/隐藏
  @State isShowDialog: boolean = false
  // 当前选中的分类索引（小说/漫画/有声书），带有监听，值变化时触发getList方法
  @Prop @Watch('getList') currentIndex: number
  // 是否有探索URL的存储链接，带有监听，值变化时触发getList方法
  @StorageLink(CommonConstants.HAS_EXPLORE_URL) @Watch('getList') hasExploreUrl?: boolean = undefined
  // Tabs组件控制器 - 用于控制Tabs的切换等操作
  tabsBodyController: TabsController = new TabsController();
  // 刷新计数的存储链接，带有监听，值变化时触发getList方法
  @StorageLink('refreshCount') @Watch('getList') refreshCount: number = 0
  // 主题颜色配置 - 从Storage中获取当前主题配置
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 组件即将出现时的生命周期方法
   * 组件渲染前调用，初始化加载数据源
   */
  aboutToAppear() {
    this.getList()
  }

  /**
   * 页面显示时的生命周期方法
   * 页面每次显示时重新加载数据源，确保数据最新
   */
  onPageShow() {
    this.getList()
  }

  /**
   * 获取书籍源列表的核心方法
   * 根据当前选中的分类、是否有探索URL等条件从数据库查询可用的书籍源
   */
  getList() {
    // 开始加载，设置加载状态为true
    this.loading = true
    // 从数据库查询符合条件的书籍源
    BookSourceDao.search({
      // 类型映射：0-小说，2-漫画，1-有声书（对应currentIndex的0/1/2）
      type: [0, 2, 1][this.currentIndex],
      enabled: true, // 只查询启用状态的源
      hasExploreUrl: this.hasExploreUrl, // 根据是否有探索URL过滤
      showExplore: true // 只显示支持探索的源
    }).then(bookSources => {
      // 打印前3个源的信息用于调试
      console.info('TagInfo', JSON.stringify(bookSources.slice(0, 3)))
      // 将查询结果赋值给源列表
      this.sourceList = bookSources
      // 加载完成，设置加载状态为false
      this.loading = false
    }).catch(() => {
      // 异常处理：即使查询失败，也要将加载状态设为false
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
   * 自定义构建函数 - 构建源通用操作弹窗内容
   * @returns 包含SourceCommon组件的Column布局
   */
  @Builder
  sourceCommon() {
    Column() {
      SourceCommon({
        showDialog: this.isShowDialog, // 弹窗显示状态
        currentIndex: this.currentIndex, // 当前分类索引
        refreshCount: this.refreshCount // 刷新计数
      })
    }.height('100%') // 弹窗内容高度100%
  }
}
/**
 * 分类列表页面组件
 * 
 * 功能概述：
 * 1. 显示特定分类下的书籍列表（如小说、漫画、有声书等）
 * 2. 支持下拉刷新和上拉加载更多
 * 3. 根据路由参数获取并显示对应分类的书籍
 * 4. 支持主题颜色切换
 * 
 * 页面结构：
 * 1. 顶部Header：显示分类标题
 * 2. 中间内容区域：显示书籍卡片列表
 * 3. 刷新组件：支持下拉刷新
 */
import Header from '../../../../componets/common/Header'; // 公共头部组件
import { router } from '@kit.ArkUI'; // 路由管理器
import { ExploreItem, ExploreQuery } from '../../../../database/types/BookSourceType'; // 探索相关类型定义
import { ExploreRule } from '../../../../database/entities/rule'; // 探索规则实体
import RefreshComponent from '../../../../componets/common/RefreshComponent'; // 刷新组件
import { isNetworkUrl } from '../../../../common/utils/utils'; // URL验证工具
import axios, { AxiosResponse } from '@ohos/axios'; // HTTP请求库
import noFind from '../../../../componets/common/noFind'; // 无数据提示组件
import { CardItem } from '../components/CardItem'; // 书籍卡片组件
import CommonConstants from '../../../../common/constants/CommonConstants'; // 通用常量
import { ThemeColorItem, ThemeItem } from '../../../../common/model/Theme'; // 主题模型
import { ThemeStorageKey } from '../../../../common/constants/Theme'; // 主题存储键

/**
 * 路由参数接口定义
 * 从上级页面传递过来的参数
 */
interface RouteParams {
  bookSourceUrl: string, // 书源URL
  exploreItem: ExploreItem, // 探索项信息
  exploreRule: ExploreRule, // 探索规则
  currentIndex: number // 当前索引（用于区分小说、漫画、有声书等类型）
}

@Entry // 页面入口装饰器
@Component // 组件装饰器
struct CateGoryListPage {
  /** 书源URL */
  @State bookSourceUrl: string = ''
  
  /** 探索项信息，包含标题和URL */
  @State exploreItem: ExploreItem = {
    title: '',
    url: ''
  }
  
  /** 探索规则，用于解析书籍列表 */
  @State exploreRule: ExploreRule = {}
  
  /** 当前页码 */
  @State pageNum: number = 1
  
  /** 每页显示数量 */
  @State pageSize: number = 10
  
  /** 书籍列表数据 */
  @State bookList: ExploreRule[] = []
  
  /** 初始加载状态 */
  @State startLoading: boolean = false
  
  /** 加载更多状态 */
  @State loading: boolean = false
  
  /** 是否正在刷新 */
  @State isRefreshing: boolean = false
  
  /** 刷新标题文本 */
  @State RefreshingTitle: string = '松开刷新'
  
  /** 当前索引（0:小说, 1:漫画, 2:有声书） */
  @State currentIndex:number = 0

  /** 主题颜色配置，使用@StorageProp持久化存储 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  /**
   * 组件即将显示时调用的生命周期方法
   * 从路由参数中获取数据并初始化页面
   */
  async aboutToAppear() {
    this.startLoading = true // 开始加载
    const params = router.getParams() as RouteParams; // 获取路由参数
    this.currentIndex = params.currentIndex // 设置当前索引
    console.log('TagInfo', '路由参数：' + JSON.stringify(params))
    this.bookSourceUrl = params.bookSourceUrl // 设置书源URL
    this.exploreItem = params.exploreItem // 设置探索项信息
    this.exploreRule = params.exploreRule // 设置探索规则
    await this.getList() // 获取书籍列表
    this.startLoading = false // 结束加载
  }

  /**
   * 获取书籍列表数据
   * 根据当前页码和探索规则请求服务器解析书籍列表
   */
  async getList() {
    // 构建请求URL，替换页码占位符
    let url = this.exploreItem.url.replace('{{page}}', this.pageNum.toString())
    // 如果URL不是网络URL，则拼接书源URL
    if (!isNetworkUrl(url)) {
      url = this.bookSourceUrl + url
    }
    
    // 构建探索查询参数
    const exploreQuery: ExploreQuery = {
      url,
      bookList: this.exploreRule.bookList,
      pageSize: this.pageSize,
      name: this.exploreRule.name,
      author: this.exploreRule.author,
      intro: this.exploreRule.intro,
      kind: this.exploreRule.kind,
      lastChapter: this.exploreRule.lastChapter,
      bookUrl: this.exploreRule.bookUrl,
      coverUrl: this.exploreRule.coverUrl,
      wordCount: this.exploreRule.wordCount
    }
    
    // 防止重复加载：如果已经加载了很多数据且不是初始加载，则直接返回
    if (this.pageNum * this.pageSize - this.bookList.length >= this.pageSize * 2 && !this.startLoading) {
      return
    }
    
    this.loading = true // 开始加载
    try {
      // 发送POST请求解析规则
      const res: AxiosResponse = await axios.post(CommonConstants.BASE_URL + '/common/analysisRules', exploreQuery)
      console.info('TagInfo, 解析内容：', JSON.stringify(res.data))
      
      // 处理返回的书籍列表，修正封面URL
      const bookList = (res.data as ExploreRule[]).map(item => {
        if (item.coverUrl && !isNetworkUrl(item.coverUrl)) {
          item.coverUrl = this.bookSourceUrl + item.coverUrl // 拼接完整的封面URL
        }
        return item
      })
      
      // 根据页码更新书籍列表
      if (this.pageNum === 1) {
        this.bookList = bookList // 第一页直接替换
      } else {
        this.bookList = this.bookList.concat(bookList) // 后续页码追加
      }
      this.loading = false // 结束加载
    } catch (err) {
      console.log('TagInfo 请求失败：', JSON.stringify(err.message));
      this.loading = false // 结束加载
    }
  }

  /**
   * 组件构建方法
   * 构建页面的UI结构，包括头部、刷新组件和书籍列表
   */
  build() {
    Column() {
      // 顶部Header，显示分类标题
      Header({
        title: this.exploreItem.title
      })

      // 主要内容区域
      Column() {
        // 刷新组件，支持下拉刷新
        Refresh({ refreshing: $$this.isRefreshing, builder: this.refreshComponent }) {
          Scroll() {
            Column() {
              // 初始加载状态显示加载进度
              if (this.startLoading) {
                Row() {
                  LoadingProgress()
                    .color(this.theme.mainColor) // 使用主题颜色
                    .width(35)
                  Text('内容加载中...')
                }
                .height('100%')
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)
              } else if (this.bookList.length === 0) {
                // 无数据时显示提示
                noFind({
                  hintIndex: 0
                })
              } else {
                // 显示书籍卡片列表
                ForEach(this.bookList, (item: ExploreRule, index) => {
                  CardItem({ item: item , currentIndex:this.currentIndex })
                })
              }
            }
            .padding({ left: 16, right: 16 }) // 左右内边距
          }
          .padding({ bottom: 16 }) // 底部内边距
          .scrollBar(BarState.Off) // 关闭滚动条
          .onReachEnd(() => {
            // 滚动到底部时加载更多
            this.pageNum += 1
            this.getList()
          })
        }
        .onStateChange((refreshStatus: RefreshStatus) => {
          // 刷新状态变化时更新刷新标题
          if (refreshStatus === 1 || refreshStatus === 2) {
            this.RefreshingTitle = '松开刷新'
          } else {
            this.RefreshingTitle = '刷新中...'
          }
        })
        .height('100%')
        .onRefreshing(() => {
          // 触发刷新时的处理
          setTimeout(async () => {
            this.pageNum = 1 // 重置页码
            this.startLoading = true // 开始加载
            await this.getList() // 重新获取数据
            this.startLoading = false // 结束加载
            this.isRefreshing = false // 结束刷新状态
          }, 1000) // 延迟1秒执行，提供更好的用户体验
        })
      }
      .layoutWeight(1) // 占据剩余空间

    }
    .height('100%')
    .width('100%')
  }

  /**
   * 刷新组件构建器方法
   * 构建下拉刷新时显示的组件
   */
  @Builder
  refreshComponent() {
    RefreshComponent({
      RefreshingTitle: this.RefreshingTitle, // 传递刷新标题
    })
  }
}

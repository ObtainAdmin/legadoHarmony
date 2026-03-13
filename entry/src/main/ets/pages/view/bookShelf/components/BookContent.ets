/**
 * 书籍内容组件 - 管理书籍列表显示和分页加载的核心组件
 * 
 * 功能概述：
 * 1. 从数据库加载书籍数据，支持分页查询
 * 2. 根据展示模式（列表/宫格）渲染不同的书籍项组件
 * 3. 支持滚动到底部自动加载更多数据
 * 4. 响应书籍类型、分组方式、搜索值的变化，实时刷新数据
 * 5. 提供数据源供其他组件使用
 * 
 * 数据流：
 * - 通过booksDao与数据库交互，获取书籍数据
 * - 使用BasicDataSource提供数据源
 * - 响应@StorageLink状态变化，自动刷新数据
 * 
 * 显示模式：
 * - 列表模式：使用BookInfos组件显示单列书籍信息
 * - 宫格模式：使用BookInfoGrids组件显示3列网格布局
 */

import { ThemeStorageKey } from '../../../../common/constants/Theme'
import BasicDataSource from '../../../../common/LazyIDataSource/BasicDataSource'
import { ThemeItem } from '../../../../common/model/Theme'
import booksDao from '../../../../database/dao/BooksDao'
import { Books } from '../../../../database/entities/Books'
import BookInfoGrids from './BookInfoGrids'
import BookInfos from './BookInfos'

/**
 * 书籍内容组件结构体
 * 
 * 职责：
 * 1. 管理书籍数据的加载、分页和刷新
 * 2. 根据展示模式选择合适的子组件渲染书籍项
 * 3. 处理滚动到底部的自动加载逻辑
 * 4. 响应外部状态变化，实时更新书籍列表
 * 5. 提供书籍数据源供其他组件使用
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 使用@Provide提供数据源，支持依赖注入
 * - 支持异步数据加载和分页
 * - 集成主题颜色配置
 */
@Component
export default struct BookContent {
  /** 书籍数据列表，从数据库加载的Books对象数组 */
  @State bookList:Books[] = []
  
  /** 底部矩形高度，从应用存储中读取，用于适配不同设备 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 书籍数据源，使用@Provide装饰器提供，供其他组件使用 */
  @Provide('booksDataSource') booksDataSource: BasicDataSource<Books> = new BasicDataSource<Books>()

  /**
   * 组件即将出现时的生命周期方法
   * 功能：初始化书籍数据
   * 操作：
   * 1. 获取书籍总数
   * 2. 如果书籍列表为空，加载第一页数据
   */
  async aboutToAppear(): Promise<void> {
    this.getBookCount()
    if (this.bookList.length === 0) {
      this.getBookList()
    }
  }

  /**
   * 获取书籍总数
   * 功能：从数据库查询指定条件下的书籍总数
   * 条件：书籍类型、分组方式
   */
  async getBookCount(){
    this.bookCount =  await booksDao.getBookCount({
      type:this.currentIndex,
      bookGroup:this.bookTypeNumber,
    })
  }
  
  /** 书籍总数，用于分页控制和显示 */
  @State bookCount:number = 0
  
  /** 展示模式：'列表'或'宫格'，由父组件传递 */
  @Prop EXHIBIT:string
  
  /** 搜索值：'最近阅读'或'浏览历史'，变化时触发changeBookType方法 */
  @Prop @Watch('changeBookType')searchValue:string
  
  /** 当前书籍类型索引：0-小说，1-漫画，2-有声书，变化时触发changeBookType方法 */
  @Prop @Watch('changeBookType')currentIndex: number
  
  /** 书籍类型编号：1-文件夹分组，2-标签分组等，变化时触发changeBookType方法 */
  @Prop @Watch('changeBookType')bookTypeNumber:number
  
  /** 书籍刷新标记，存储在应用存储中，变化时触发isRefresh方法 */
  @StorageLink('BOOK_IS_BOOK_REFRESHING') @Watch("isRefresh")isBookRefreshing: number = 0
  
  /**
   * 刷新数据方法
   * 功能：响应isBookRefreshing变化，重新加载数据
   * 操作：
   * 1. 重置当前页码为1
   * 2. 重新加载书籍列表
   */
  isRefresh(){
    this.currentPage = 1
    // if (this.booksDataSource.totalCount() > 0){
    //   this.booksDataSource.clear()
    // }
    if (this.isBookRefreshing >= 0) {
      this.getBookList()
    }
  }

  /**
   * 书籍类型变化处理函数
   * 功能：响应searchValue、currentIndex、bookTypeNumber变化，重新加载数据
   * 逻辑：
   * 1. 重置当前页码为1
   * 2. 如果bookTypeNumber不是1或5（特殊分组），重新获取书籍总数和列表
   */
  changeBookType(){
    this.currentPage = 1
    if (this.bookTypeNumber !== 1 && this.bookTypeNumber !== 5) {
      if (this.bookCount === 0){
        this.getBookCount()
      }
      // if (this.booksDataSource.totalCount() > 0) {
      //   this.booksDataSource.clear()
      // }
      this.getBookList()
    }
  }

  /**
   * 获取书籍列表
   * 功能：从数据库分页查询书籍数据
   * 条件：书籍类型、分组方式、排序方式、当前页码
   */
  async getBookList(){
    this.bookList =  await booksDao.searchPage({
      type:this.currentIndex,
      bookGroup:this.bookTypeNumber,
      order:this.searchValue
    }, this.currentPage)
    if (this.booksDataSource.totalCount() < this.bookCount) {
      // this.booksDataSource.pushAllData(this.bookList)
    }
  }

  /** 加载中状态，防止重复加载 */
  @State isLoading: boolean = false
  
  /** 当前页码，用于分页查询 */
  @State currentPage:number = 1
  
  /** 应用主题配置，从应用存储中读取，用于UI元素颜色 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * 加载更多书籍
   * 功能：滚动到底部时加载下一页数据
   * 逻辑：
   * 1. 检查是否正在加载，防止重复请求
   * 2. 页码加1，查询下一页数据
   * 3. 将新数据追加到现有列表
   */
  async loadMoreBooks() {
    if (!this.isLoading) {
      this.isLoading = true;
      this.currentPage += 1;

      const moreBooks = await booksDao.searchPage({
        type:this.currentIndex,
        bookGroup:this.bookTypeNumber,
        order:this.searchValue,
      }, this.currentPage);
      if (moreBooks.length > 0) {
        this.bookList.push(...moreBooks);
      }
      this.isLoading = false;
    }
  }
  
  /** 滚动控制器，用于管理List组件的滚动行为 */
  scroller: Scroller = new Scroller()
  /**
   * 构建书籍内容组件UI的主要方法
   * 
   * 三种显示状态：
   * 1. 加载中状态：显示加载进度条
   * 2. 空列表状态：显示无记录提示
   * 3. 有数据状态：显示书籍列表，支持滚动加载
   * 
   * 列表布局：
   * - 宫格模式：3列网格布局，使用BookInfoGrids组件
   * - 列表模式：单列列表布局，使用BookInfos组件
   * 
   * 交互功能：
   * - 滚动到底部自动加载更多数据
   * - 根据展示模式动态切换子组件
   */
  build() {
    // 加载中状态
    if (this.isLoading) {
      Row(){
        LoadingProgress()
          .color(this.theme.mainColor)
          .width('50%')
        Text('加载中...')
      }
    } 
    // 空列表状态
    else if (this.bookList.length === 0){
      Column() {
        Image($r('app.media.no_record')).width(200).height(200)
        Text('暂无浏览记录')
          .fontSize(12)
          .fontColor('rgba(96, 96, 96, 0.6)')
          .fontWeight(500)
          .padding(5)
      }
      .margin({ top: 120 })
    } 
    // 有数据状态
    else {
      List({
        space:10,
        scroller:this.scroller
      }){
       ForEach(this.bookList, (item: Books,index:number) => {
          ListItem(){
            // 根据展示模式选择不同的子组件
            if (this.EXHIBIT === '宫格') {
              BookInfoGrids({
                book:item
              })
            } else {
              BookInfos({
                book:item
              })
            }
          }
        })
      }
      .alignListItem(ListItemAlign.Center)
      .layoutWeight(1)
      .lanes(this.EXHIBIT === '宫格' ? 3 : 1)  // 宫格模式3列，列表模式1列
      .scrollBar(BarState.Off)
      .onReachEnd(() => {
        // 滚动到底部时加载更多数据
        if (this.bookList.length < this.bookCount) {
          this.loadMoreBooks()
        }
      })
      .margin({
        bottom: 20
      })
    }
  }
}

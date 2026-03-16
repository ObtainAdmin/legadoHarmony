/**
 * @file SearchBook.ets
 * @description 搜索书籍页面组件，用于处理书籍搜索功能
 * @author 2008
 * @datetime 2026/3/4
 * 
 * @overview
 * 该组件是Legado Harmony应用中的搜索书籍页面，主要负责：
 * 1. 接收搜索参数并初始化搜索状态
 * 2. 提供搜索历史、搜索结果展示和刷新功能
 * 3. 处理返回事件（取消搜索任务）
 * 
 * @usage
 * 在路由中通过参数传递搜索关键词：
 * router.pushUrl({ url: 'pages/view/search/SearchBook', params: { searchValue: '关键词' } })
 */

// 导入依赖组件
import { SearchHead } from '../../../componets/search/SearchHead'           // 搜索头部组件（包含搜索框）
import { SearchHistory } from '../../../componets/search/SearchHistory'     // 搜索历史组件
import { SearchDetails } from '../../../componets/search/SearchDetails'     // 搜索结果详情组件
import { SearchRefresh } from '../../../componets/search/SearchRefresh'     // 搜索刷新组件
import taskSearchBooks from '../../../common/model/taskSearchBook'           // 搜索任务管理模块
import { router } from '@kit.ArkUI'                                         // 路由模块

/**
 * @interface routeParams
 * @description 路由参数接口，定义从路由传递的参数结构
 * @property {string} searchValue - 搜索关键词
 */
interface routeParams {
  searchValue: string,
}

/**
 * @class SearchBook
 * @description 搜索书籍主组件
 * @extends Component
 * @decorator @Entry - 标记为入口组件
 * @decorator @Component - 标记为ArkTS组件
 */
@Entry
@Component
struct SearchBook {
  /**
   * @property {string} SearchValue - 当前搜索关键词，提供给子组件使用
   * @decorator @Provide - 提供给子组件的响应式变量
   */
  @Provide SearchValue: string = ""
  
  /**
   * @property {number} SearchStatus - 搜索状态码（0:未搜索, 1:搜索中, 2:搜索完成等）
   * @decorator @Provide - 提供给子组件的响应式变量
   */
  @Provide SearchStatus: number = 0
  
  /**
   * @property {SearchBook[]} books - 搜索结果列表
   * @decorator @Provide - 提供给子组件的响应式变量，名称为'searchBookList'
   */
  @Provide('searchBookList') books: SearchBook[] = []
  
  /**
   * @property {number} bottomRectHeight - 底部区域高度，用于适配底部导航栏
   * @decorator @StorageLink - 从本地存储链接的变量
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /**
   * @property {boolean} isSearch - 是否处于搜索状态
   * @decorator @Provide - 提供给子组件的响应式变量，名称为'isSearch'
   */
  @Provide('isSearch') isSearch: boolean = false
  
  /**
   * @method aboutToAppear
   * @description 组件即将显示时调用，用于初始化搜索参数
   * @returns {void}
   */
  aboutToAppear(): void {
    // 从路由参数中获取搜索关键词
    let search = router.getParams() as routeParams
    if (search) {
      // 如果有搜索参数，设置到SearchValue中
      this.SearchValue = search.searchValue ?? ''
    }
  }
  
  /**
   * @method onBackPress
   * @description 处理返回按键事件
   * @returns {boolean | void} 返回false表示不拦截返回事件，true表示拦截
   */
  onBackPress(): boolean | void {
    // 如果当前处于搜索状态，取消所有搜索任务
    if (this.isSearch) {
      taskSearchBooks.cancelAllTasks()
    }
    // 返回false表示不拦截返回事件，让系统处理默认返回行为
    return false
  }
  
  /**
   * @method build
   * @description 构建UI界面
   * @returns {Column} 返回构建的UI组件
   */
  build() {
    // 主容器：垂直布局
    Column() {
      // 顶部搜索框组件
      SearchHead();
      
      // 根据搜索状态和结果数量显示不同内容
      if (!this.isSearch && this.books.length <= 0) {
        // 未搜索且无结果：显示搜索历史
        SearchHistory();
      } else if (this.isSearch && this.books.length <= 0) {
        // 正在搜索且无结果：显示搜索刷新组件
        SearchRefresh()
      } else {
        // 有搜索结果：显示搜索详情组件
        SearchDetails({ SearchValue: this.SearchValue }).layoutWeight(1)
      }
    }
    .layoutWeight(1)  // 占据剩余空间
    .padding({
      bottom: this.bottomRectHeight  // 底部内边距，适配底部导航栏
    })
  }
}

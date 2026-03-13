/**
 * 书籍内容刷新组件 - 管理下拉刷新和不同内容类型的显示
 * 
 * 功能概述：
 * 1. 提供下拉刷新功能，支持自定义刷新标题和状态
 * 2. 根据书籍类型编号和搜索值动态切换显示内容
 * 3. 管理多种刷新标记的状态同步
 * 4. 集成多种内容组件：BookContent、BookFolder、WorksBookLists、BookHistoryContent
 * 
 * 内容切换逻辑：
 * - bookTypeNumber=1：显示BookFolder（文件夹分组）
 * - bookTypeNumber=5：显示WorksBookLists（作品列表）
 * - searchValue='浏览历史'：显示BookHistoryContent（浏览历史）
 * - 其他情况：显示BookContent（普通书籍列表）
 * 
 * 刷新机制：
 * 使用Refresh组件实现下拉刷新，刷新时更新对应的刷新标记
 */

import { showMessage } from '../../../../componets/common/promptShow'
import RefreshComponent from '../../../../componets/common/RefreshComponent'
import BookFolder from '../BookFolder'
import WorksBookLists from '../Shelf/WorksBookLists'
import BookContent from './BookContent'
import BookHistoryContent from './BookHistoryContent'

/**
 * 书籍内容刷新组件结构体
 * 
 * 职责：
 * 1. 管理下拉刷新状态和交互
 * 2. 根据书籍类型和搜索值动态切换显示内容
 * 3. 同步多种刷新标记的状态
 * 4. 提供刷新成功反馈
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 使用@Watch装饰器监听状态变化
 * - 支持多种内容组件的动态切换
 * - 集成刷新状态管理
 */
@Component
export default struct BookContentRefresh {
  /** 刷新状态，true表示正在刷新，变化时触发changeRefreshing方法 */
  @State @Watch('changeRefreshing')isRefreshing: boolean = false
  
  /** 书籍刷新标记，存储在应用存储中，变化时触发书籍列表刷新 */
  @StorageLink('BOOK_IS_BOOK_REFRESHING') isBookRefreshing: number = 0
  
  /** 分组刷新标记，存储在应用存储中，变化时触发分组列表刷新 */
  @StorageLink('BOOK_IS_BOOK_GROUPS_REFRESHING') isGroupRefreshing: number = 0
  
  /** 作品列表刷新标记，存储在应用存储中，变化时触发作品列表刷新 */
  @StorageLink('BOOK_IS_BOOK_WORKS_BOOK_LIST') isWorksBookListRefreshing: number = 0
  
  /** 书籍历史刷新标记，存储在应用存储中，变化时触发历史列表刷新 */
  @StorageLink('BOOK_IS_BOOK_HISTORY_REFRESHING') isBookHistoryRefreshing: number = 0
  
  /** 刷新计数器，用于跟踪刷新次数 */
  @State counter: number = 0
  
  /** 刷新标题，根据刷新状态变化：'松开刷新'或'刷新中...' */
  @State RefreshingTitle: string = '松开刷新'
  
  /** 当前书籍类型索引：0-小说，1-漫画，2-有声书 */
  @Prop currentIndex: number = 0
  
  /** 展示模式：'列表'或'宫格'，与父组件双向绑定 */
  @Link EXHIBIT: string
  
  /** 分组方式：'标签'或'文件夹'，与父组件双向绑定 */
  @Link GROUP: string
  
  /** 搜索值：'最近阅读'或'浏览历史' */
  @Prop searchValue: string
  
  /** 书籍类型编号，与父组件双向绑定 */
  @Link bookTypeNumber:number
  
  /** 检查组状态记录，用于WorksBookLists组件 */
  @State checkGroup:Record<number, boolean> = {}
  
  /**
   * 刷新状态变化处理函数
   * 功能：根据bookTypeNumber和searchValue更新对应的刷新标记
   * 逻辑：
   * 1. bookTypeNumber=1：增加分组刷新标记
   * 2. bookTypeNumber=5：增加作品列表刷新标记
   * 3. 其他情况：增加书籍刷新标记
   * 4. 如果searchValue='浏览历史'：增加历史刷新标记
   */
  changeRefreshing(){
    if (this.isRefreshing) {
      switch (this.bookTypeNumber){
        case 1:
          this.isGroupRefreshing++
          break;
        case 5:
          this.isWorksBookListRefreshing++
          break;
        default:
          this.isBookRefreshing++
          break
      }
      if (this.searchValue === '浏览历史') {
        this.isBookHistoryRefreshing++
      }
    }
  }
  /**
   * 构建书籍内容刷新组件UI的主要方法
   * 
   * 布局结构：
   * 1. Refresh组件作为根容器，提供下拉刷新功能
   * 2. 根据bookTypeNumber和searchValue动态切换内容组件
   * 
   * 内容切换逻辑：
   * - 普通书籍列表：bookTypeNumber不是5或1，且searchValue不是'浏览历史'
   * - 作品列表：bookTypeNumber=5，且searchValue不是'浏览历史'
   * - 浏览历史：searchValue='浏览历史'
   * - 文件夹分组：bookTypeNumber=1，且searchValue不是'浏览历史'
   * 
   * 刷新交互：
   * - onStateChange：根据刷新状态更新标题
   * - onRefreshing：刷新完成后的回调，显示成功消息
   */
  build() {
    Refresh({ refreshing: $$this.isRefreshing, builder: this.refreshComponent }) {
      // 普通书籍列表：显示BookContent组件
      if (this.bookTypeNumber !== 5 && this.bookTypeNumber !== 1 && this.searchValue !== '浏览历史' ){
        BookContent({
          currentIndex:this.currentIndex,
          bookTypeNumber:this.bookTypeNumber,
          EXHIBIT: this.EXHIBIT,
          searchValue: this.searchValue
        })
      } 
      // 特殊内容：显示Scroll容器内的动态内容
      else {
        Scroll() {
          Column() {
            // 作品列表：bookTypeNumber=5
            if (this.bookTypeNumber === 5 && this.searchValue !== '浏览历史') {
              WorksBookLists({
                checkGroup: this.checkGroup,
                EXHIBIT: this.EXHIBIT,
                currentIndex:this.currentIndex,
                isShowCheck:false
              })
            } 
            // 其他情况
            else {
              // 浏览历史：searchValue='浏览历史'
              if (this.searchValue === '浏览历史') {
                BookHistoryContent({
                  currentIndex:this.currentIndex,
                  searchValue: this.searchValue
                })
              } 
              // 文件夹分组：bookTypeNumber=1
              else {
                BookFolder({
                  EXHIBIT: this.EXHIBIT,
                  currentIndex:this.currentIndex
                })
              }
            }
          }
          .padding({ left: 10, right: 10, bottom: 30 })
        }
        .scrollBar(BarState.Off)
      }
    }
    .height('100%')
    .margin({ top: this.searchValue === '浏览历史' ? 0 : 30 })  // 浏览历史模式无上边距
    .onStateChange((refreshStatus: RefreshStatus) => {
      // 根据刷新状态更新标题
      if (refreshStatus === 1 || refreshStatus === 2) {
        this.RefreshingTitle = '松开刷新'
      } else {
        this.RefreshingTitle = '刷新中...'
      }
    })
    .onRefreshing(() => {
      // 刷新完成后的回调
      setTimeout(() => {
        this.counter++
        this.isRefreshing = false
      }, 1000)
      showMessage('刷新成功')
    })
  }
  /**
   * 构建刷新组件的Builder函数
   * 
   * 功能：创建自定义刷新指示器
   * 使用RefreshComponent组件，传递当前刷新标题
   * 
   * @returns 刷新指示器组件
   */
  @Builder
  refreshComponent() {
    RefreshComponent({
      RefreshingTitle: this.RefreshingTitle,
    })
  }
}

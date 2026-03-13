/**
 * 书籍历史内容组件 - 显示浏览历史记录
 * 
 * 功能概述：
 * 1. 从数据库加载书籍浏览历史数据
 * 2. 根据书籍类型筛选历史记录
 * 3. 响应历史刷新标记的变化，实时更新数据
 * 4. 显示无记录提示或有历史记录列表
 * 
 * 数据源：
 * 通过bookHistoryDao与数据库交互，获取BookHistory实体数据
 * 支持按类型筛选和排序
 * 
 * 显示状态：
 * - 空列表状态：显示"暂无浏览记录"提示和图标
 * - 有数据状态：显示BookHistoryInfo组件列表，带浅黄色背景
 */

import bookHistoryDao from '../../../../database/dao/BookHistoryDao'
import { BookHistory } from '../../../../database/entities/BookHistory'
import BookHistoryInfo from './BookHistoryInfo'

/**
 * 书籍历史内容组件结构体
 * 
 * 职责：
 * 1. 管理书籍浏览历史数据的加载和显示
 * 2. 响应书籍类型变化，重新加载对应类型的历史记录
 * 3. 监听历史刷新标记，实时更新数据
 * 4. 提供无记录状态和有数据状态的UI显示
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 使用@Watch装饰器监听状态变化
 * - 支持异步数据加载
 * - 集成刷新状态管理
 */
@Component
export default struct BookHistoryContent {
  /** 书籍历史数据列表，从数据库加载的BookHistory对象数组 */
  @State bookHistory:BookHistory[] = []
  
  /** 底部矩形高度，从应用存储中读取，用于适配不同设备 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 搜索值：'最近阅读'或'浏览历史'，当前组件中主要用于标识上下文 */
  @Prop searchValue:string
  
  /** 当前书籍类型索引：0-小说，1-漫画，2-有声书，变化时触发changeBookType方法 */
  @Prop @Watch('changeBookType')currentIndex: number
  
  /** 书籍历史刷新标记，存储在应用存储中，变化时触发getBookHistoryList方法 */
  @StorageLink('BOOK_IS_BOOK_HISTORY_REFRESHING') @Watch('getBookHistoryList') isBookHistoryRefreshing: number = 0
  
  /**
   * 组件即将出现时的生命周期方法
   * 功能：初始化历史数据
   * 操作：调用getBookHistoryList加载历史记录
   */
  aboutToAppear(): void {
    this.getBookHistoryList()
  }
  
  /**
   * 书籍类型变化处理函数
   * 功能：响应currentIndex变化，重新加载历史数据
   * 操作：
   * 1. 重新加载历史记录
   * 2. 增加历史刷新标记，触发相关组件更新
   */
  changeBookType(){
    this.getBookHistoryList()
    this.isBookHistoryRefreshing++
  }
  
  /**
   * 获取书籍历史列表
   * 功能：从数据库查询指定类型的书籍历史记录
   * 条件：书籍类型、排序方式（当前固定为0）
   * 异步操作：数据库查询是异步操作，使用Promise处理结果
   */
  getBookHistoryList(){
    bookHistoryDao.search({
      type:this.currentIndex,
      sort:0
    }).then((val)=>{
      this.bookHistory = val
    })
  }

  /**
   * 构建书籍历史内容组件UI的主要方法
   * 
   * 两种显示状态：
   * 1. 空列表状态：显示无记录提示和图标
   * 2. 有数据状态：显示历史记录列表，使用BookHistoryInfo组件
   * 
   * 布局特点：
   * - 空列表状态：居中显示图标和文字提示
   * - 有数据状态：使用Column布局，带浅黄色半透明背景
   * - 每个历史记录项使用BookHistoryInfo组件渲染
   */
  build() {
    // 空列表状态
    if (this.bookHistory.length === 0){
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
      Column(
        {space:10}
      ){
        Column(
          { space: 10 }
        ) {
          ForEach(this.bookHistory, (item: BookHistory) => {
            BookHistoryInfo({
              bookHistory:item
            })
          })
        }
        .backgroundColor('rgba(255,250,247,0.8)')  // 浅黄色半透明背景
      }
    }
  }
}

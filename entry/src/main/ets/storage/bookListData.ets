/**
 * bookListData.ets - 书籍列表页面状态数据初始化模块
 * 
 * 功能说明：
 * 该模块用于初始化书籍相关页面（书库、阅读历史、订阅源）的状态标志位
 * 这些标志位主要用于控制加载动画、下拉刷新、上拉加载等UI交互状态
 * 
 * 数据存储说明：
 * - 使用 AppStorage 进行应用级内存存储
 * - 所有状态值均为 number 类型（0: 空闲, 1: 加载中/刷新中）
 * 
 * 状态值约定：
 * 0 - 空闲状态/加载完成
 * 1 - 正在加载/刷新中
 * 
 * 使用方式：
 * import { initBookListData } from '../storage/bookListData'
 * initBookListData()
 */
import CommonConstants from '../common/constants/CommonConstants'

/**
 * initBookListData 函数
 * 
 * 功能：初始化书籍列表页面相关的所有状态标志位
 * 
 * 初始化的状态标志：
 * 1. BOOK_IS_BOOK_REFRESHING - 书库页面下拉刷新状态
 * 2. BOOK_IS_BOOK_GROUPS_REFRESHING - 书籍分组列表刷新状态
 * 3. BOOK_IS_BOOK_WORKS_BOOK_LIST - 书城/作品列表加载状态
 * 4. BOOK_IS_BOOK_HISTORY_REFRESHING - 阅读历史刷新状态
 * 5. RSS_SOURCES_REFRESHING - RSS订阅源列表刷新状态
 * 
 * 调用场景：
 * - 应用程序首次启动时（通过 appData.ets 的 initAppData 调用）
 * - 需要重置所有加载状态时
 * - 用户执行下拉刷新操作后，状态由UI组件自动管理
 * 
 * @returns void 无返回值
 */
export const initBookListData = ()=>{
  // 设置书库页面刷新状态为0（空闲/刷新完成）
  // 用于控制下拉刷新组件的加载动画显示
  AppStorage.setOrCreate(CommonConstants.BOOK_IS_BOOK_REFRESHING, 0)
  
  // 设置书籍分组列表刷新状态为0（空闲）
  // 书籍分组指的是自定义分组、标签等分类
  AppStorage.setOrCreate(CommonConstants.BOOK_IS_BOOK_GROUPS_REFRESHING, 0)
  
  // 设置书城作品列表加载状态为0（空闲）
  // 这个状态用于书城页面或作品详情页的列表加载
  AppStorage.setOrCreate(CommonConstants.BOOK_IS_BOOK_WORKS_BOOK_LIST, 0)
  
  // 设置阅读历史刷新状态为0（空闲）
  // 用户访问历史记录页面时的刷新状态控制
  AppStorage.setOrCreate(CommonConstants.BOOK_IS_BOOK_HISTORY_REFRESHING,0)
  
  // 设置RSS订阅源列表刷新状态为0（空闲）
  // 控制订阅源管理页面的刷新状态
  AppStorage.setOrCreate(CommonConstants.RSS_SOURCES_REFRESHING, 0)
}
/**
 * 订阅源页面包装组件 - 主页面中订阅源标签页的容器组件
 * 
 * 功能概述：
 * 1. 作为订阅源功能模块的入口组件
 * 2. 提供订阅源页面的容器和背景样式
 * 3. 渲染实际的订阅源列表组件（SubscriptionIndex）
 * 4. 传递当前标签页索引给子组件
 * 
 * 设计模式：
 * 采用包装器模式，将复杂的订阅源逻辑委托给SubscriptionIndex组件处理
 * 本组件主要负责样式、容器管理和参数传递
 * 
 * 使用场景：
 * 在主页面（Index.ets）的底部导航栏中，点击"订阅源"标签时显示此组件
 */

import IndexSubscription from './Subscription/IndexSubscription'
import SubscriptionIndex from './Subscription/SubscriptionIndex'

/**
 * 订阅源页面结构体
 * 
 * 职责：
 * 1. 提供订阅源页面的容器布局
 * 2. 设置页面背景样式
 * 3. 传递当前标签页索引给子组件
 * 4. 加载并显示实际的订阅源列表组件
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 使用export default导出，供其他页面引用
 * - 采用简单的包装器设计，将具体功能委托给子组件
 * - 接收currentTabIndex属性，用于同步主页面状态
 */
@Component
export default struct Subscription {
  /** 订阅源页面标题，当前未在UI中使用，保留供未来扩展 */
  @State subscription: string = '订阅源'
  
  /** 当前选中的标签页索引，从主页面传递而来，用于同步状态 */
  @Prop currentTabIndex: number
  
  /**
   * 构建订阅源页面UI的主要方法
   * 
   * 布局结构：
   * 1. 使用Column作为根容器
   * 2. 内部渲染SubscriptionIndex组件（实际的订阅源列表）
   * 3. 传递currentTabIndex参数给子组件
   * 
   * 样式特点：
   * - 浅灰色背景（F3F4F8）
   * - 全屏布局（由父组件控制）
   * 
   * 设计考虑：
   * 将复杂的订阅源逻辑分离到SubscriptionIndex组件中，保持本组件的简洁性
   * 通过Prop传递currentTabIndex，确保子组件能响应主页面的标签切换
   */
  build(){
    Column(){
      // 渲染实际的订阅源列表组件，包含订阅源的增删改查等所有功能
      // 传递currentTabIndex参数，用于同步主页面状态
      SubscriptionIndex({
        currentTabIndex:this.currentTabIndex,
      })
    }
    // 设置浅灰色背景，提供舒适的视觉体验
    .backgroundColor('F3F4F8')
  }
}
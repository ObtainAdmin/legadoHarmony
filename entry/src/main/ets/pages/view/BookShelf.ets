/**
 * 书架页面包装组件 - 主页面中书架标签页的容器组件
 * 
 * 功能概述：
 * 1. 作为书架功能模块的入口组件
 * 2. 提供书架页面的容器和背景样式
 * 3. 渲染实际的书籍列表组件（IndexShelf）
 * 
 * 设计模式：
 * 采用包装器模式，将复杂的书架逻辑委托给IndexShelf组件处理
 * 本组件主要负责样式和容器管理
 * 
 * 使用场景：
 * 在主页面（Index.ets）的底部导航栏中，点击"书架"标签时显示此组件
 */

import ReadShow from '../../componets/common/ReadShow'
import IndexShelf from './bookShelf/IndexShelf'

/**
 * 书架页面结构体
 * 
 * 职责：
 * 1. 提供书架页面的容器布局
 * 2. 设置页面背景样式
 * 3. 加载并显示实际的书籍列表组件
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 使用export default导出，供其他页面引用
 * - 采用简单的包装器设计，将具体功能委托给子组件
 */
@Component
export default struct BookShelf {
  /** 书架页面标题，当前未在UI中使用，保留供未来扩展 */
  @State bookShelf: string = '书架'
  
  /**
   * 构建书架页面UI的主要方法
   * 
   * 布局结构：
   * 1. 使用Column作为根容器
   * 2. 内部渲染IndexShelf组件（实际的书籍列表）
   * 
   * 样式特点：
   * - 半透明白色背景（rgba(255, 255, 255, 0.8)）
   * - 全屏布局（由父组件控制）
   * 
   * 设计考虑：
   * 将复杂的书架逻辑分离到IndexShelf组件中，保持本组件的简洁性
   * 便于未来扩展其他书架相关功能
   */
  build(){
    Column(){
      // 渲染实际的书籍列表组件，包含书籍的增删改查等所有功能
      IndexShelf()
    }
    // 设置半透明白色背景，提供良好的视觉层次
    .backgroundColor('rgba(255, 255, 255, 0.8)')
  }
}

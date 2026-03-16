/**
 * @author 2008
 * @datetime 2024/6/27 0:34
 * @className: cartoonFind
 * @description: 漫画发现页面组件 - 专门用于展示漫画内容的发现页面
 * 
 * 组件功能：
 * 1. 展示漫画推荐内容，包含"猜你喜欢"模块
 * 2. 提供多个漫画分类区块，每个区块独立展示
 * 3. 当没有漫画数据时显示友好的空状态提示
 * 
 * 页面结构：
 * - 外层Column：垂直布局容器，设置16px间距
 * - 三个相同的漫画区块：每个区块包含猜你喜欢、标题和无数据提示
 * - 统一的样式：白色背景、圆角边框、固定高度
 * 
 * 数据状态：
 * - 使用noFind组件处理空状态，第一个区块使用hintIndex:1显示特定提示
 * - 其他区块使用默认的无数据提示
 * 
 * 样式特点：
 * - 每个区块高度436px，确保视觉一致性
 * - 12px圆角边框，现代化卡片设计
 * - 顶部75px内边距，提供合适的留白
 * - 整体居中对齐，提升视觉平衡感
 */

// 导入必要的组件
import noFind from '../../../componets/common/noFind'          // 无数据提示组件
import mayAlsoLike from './mayAlsoLike'                       // 猜你喜欢组件

/**
 * 漫画发现页面组件
 * 负责展示漫画推荐内容和分类信息
 */
@Component
export default struct cartoonFind {
  /**
   * 组件UI构建方法
   * 构建漫画发现页面的整体布局
   * 
   * 布局逻辑：
   * 1. 外层Column：垂直排列三个漫画区块，间距16px
   * 2. 每个区块：包含猜你喜欢、标题文本、无数据提示
   * 3. 统一的卡片样式：白色背景、圆角、固定高度
   * 
   * 交互说明：
   * - 当前为静态展示，暂无点击交互
   * - 无数据时显示noFind组件的友好提示
   * - 后续可扩展为动态加载真实漫画数据
   */
  build() {
    Column({
      space: 16  // 设置子组件间距为16px
    }) {
      // 第一个漫画推荐区块
      Column() {
        mayAlsoLike()                                             // 猜你喜欢标题栏
        Text('漫画')                                               // 漫画分类标题
        noFind({
          hintIndex: 1                                            // 使用特定的空状态提示
        }).padding({
          top: 75                                                // 顶部内边距75px
        })
      }
      .borderRadius(12)                                           // 12px圆角
      .backgroundColor(Color.White)                              // 白色背景
      .height(436)                                               // 固定高度436px

      // 第二个漫画推荐区块
      Column() {
        mayAlsoLike()                                             // 猜你喜欢标题栏
        Text('漫画')                                               // 漫画分类标题
        noFind().padding({
          top: 75                                                // 顶部内边距75px
        })
      }
      .borderRadius(12)                                           // 12px圆角
      .backgroundColor(Color.White)                              // 白色背景
      .height(436)                                               // 固定高度436px

      // 第三个漫画推荐区块
      Column() {
        mayAlsoLike()                                             // 猜你喜欢标题栏
        Text('漫画')                                               // 漫画分类标题
        noFind().padding({
          top: 75                                                // 顶部内边距75px
        })
      }
      .borderRadius(12)                                           // 12px圆角
      .backgroundColor(Color.White)                              // 白色背景
      .height(436)                                               // 固定高度436px
    }
    .alignItems(HorizontalAlign.Center)                         // 整体居中对齐
  }
}
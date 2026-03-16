/**
 * @author 2008
 * @datetime 2024/6/27 0:34
 * @className: novelFind
 * @description: 小说发现页面组件 - 专门用于展示小说内容的发现页面
 * 
 * 组件功能：
 * 1. 展示小说推荐内容，包含"畅销精选"和"猜你喜欢"模块
 * 2. 提供多个小说分类区块，每个区块独立展示
 * 3. 当没有小说数据时显示友好的空状态提示
 * 
 * 页面结构：
 * - 外层Column：垂直布局容器，设置16px间距
 * - 三个小说区块：第一个显示"畅销精选"，其他显示"猜你喜欢"
 * - 统一的样式：白色背景、圆角边框、固定高度
 * 
 * 数据状态：
 * - 第一个区块使用自定义标题"畅销精选"，突出热门内容
 * - 其他区块使用默认的"猜你喜欢"标题
 * - 所有区块在无数据时显示noFind组件的友好提示
 * 
 * 样式特点：
 * - 每个区块高度436px，确保视觉一致性
 * - 12px圆角边框，现代化卡片设计
 * - 顶部75px内边距，提供合适的留白
 * - 整体居中对齐，提升视觉平衡感
 * 
 * 与cartoonFind的区别：
 * - 标题文本不同：突出"畅销精选"概念
 * - 内容类型不同：专门针对小说内容优化
 * - 布局结构相同：保持统一的发现页面体验
 */

// 导入必要的组件
import noFind from '../../../componets/common/noFind'          // 无数据提示组件
import mayAlsoLike from './mayAlsoLike'                       // 猜你喜欢组件

/**
 * 小说发现页面组件
 * 负责展示小说推荐内容和分类信息
 */
@Component
export default struct novelFind {
  /**
   * 组件UI构建方法
   * 构建小说发现页面的整体布局
   * 
   * 布局逻辑：
   * 1. 外层Column：垂直排列三个小说区块，间距16px
   * 2. 第一个区块：特殊的"畅销精选"标题，突出热门小说
   * 3. 其他区块：使用默认的"猜你喜欢"标题
   * 4. 统一的卡片样式：白色背景、圆角、固定高度
   * 
   * 设计考量：
   * - "畅销精选"：吸引用户关注热门和高质量小说
   * - "猜你喜欢"：基于用户行为的个性化推荐
   * - 多区块布局：提供丰富的内容发现机会
   * - 统一的视觉样式：保持页面整体协调性
   * 
   * 扩展性：
   * - 可动态加载真实的小说数据
   * - 可扩展为支持不同的推荐算法
   * - 可添加更多的分类和筛选功能
   */
  build() {
    Column({
      space: 16  // 设置子组件间距为16px
    }) {
      // 第一个小说推荐区块 - 特殊处理：畅销精选
      Column() {
        mayAlsoLike({
          mayAlsoLike: '畅销精选'                                    // 自定义标题：突出热门内容
        })
        Text('小说')                                                // 小说分类标题
        noFind().padding({
          top: 75                                                 // 顶部内边距75px
        })
      }
      .borderRadius(12)                                            // 12px圆角
      .backgroundColor(Color.White)                               // 白色背景
      .height(436)                                                // 固定高度436px

      // 第二个小说推荐区块 - 默认猜你喜欢
      Column() {
        mayAlsoLike()                                              // 猜你喜欢标题栏（默认）
        Text('小说')                                                // 小说分类标题
        noFind().padding({
          top: 75                                                 // 顶部内边距75px
        })
      }
      .borderRadius(12)                                            // 12px圆角
      .backgroundColor(Color.White)                               // 白色背景
      .height(436)                                                // 固定高度436px

      // 第三个小说推荐区块 - 默认猜你喜欢
      Column() {
        mayAlsoLike()                                              // 猜你喜欢标题栏（默认）
        Text('小说')                                                // 小说分类标题
        noFind().padding({
          top: 75                                                 // 顶部内边距75px
        })
      }
      .borderRadius(12)                                            // 12px圆角
      .backgroundColor(Color.White)                               // 白色背景
      .height(436)                                                // 固定高度436px
    }
    .alignItems(HorizontalAlign.Center)                          // 整体居中对齐
  }
}
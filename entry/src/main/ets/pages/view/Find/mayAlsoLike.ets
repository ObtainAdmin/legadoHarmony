/**
 * @author 2008
 * @datetime 2024/6/27 0:34
 * @className: mayAlsoLike
 * @description: 猜你喜欢组件 - 通用的推荐内容标题栏组件
 * 
 * 组件功能：
 * 1. 作为发现页面内容区块的标题栏，提供统一的视觉识别
 * 2. 左侧显示推荐标题（默然为"猜你喜欢"，可自定义）
 * 3. 右侧提供"全部分类"入口，支持导航到完整分类页面
 * 4. 支持自定义点击事件，实现灵活的交互逻辑
 * 
 * 设计特点：
 * - 双行布局：左侧标题 + 右侧分类入口
 * - 字体层级：标题20px中粗体，分类14px常规体
 * - 颜色对比：标题深黑色突出，分类灰色次要
 * - 视觉引导：右侧箭头图标指示可点击性
 * 
 * 使用场景：
 * - 小说发现页面的"畅销精选"区块
 * - 漫画发现页面的"猜你喜欢"区块  
 * - 有声书发现页面的推荐区块
 * - 任何需要推荐标题栏的内容区域
 * 
 * 可配置性：
 * - 标题文本：通过@Prop属性自定义显示文字
 * - 点击事件：通过handleClick回调支持自定义行为
 * - 样式统一：确保所有发现页面的一致性体验
 * 
 * 技术特点：
 * - 使用@Prop装饰器支持父组件数据传递
 * - 提供默认点击回调，支持自定义交互逻辑
 * - 响应式设计，适应不同屏幕宽度
 * - 使用系统字体资源，保证跨平台一致性
 */

// 导入通用常量配置
import CommonConstants from '../../../common/constants/CommonConstants'

/**
 * 猜你喜欢标题栏组件
 * @prop {string} mayAlsoLike - 标题文本，默认为'猜你喜欢'
 * @prop {Function} handleClick - 右侧分类入口的点击回调函数
 */
@Component
export default struct mayAlsoLike {
  /** 
   * 推荐标题文本 
   * 支持父组件自定义，默认为'猜你喜欢'
   * 可设置为'畅销精选'、'热门推荐'等
   */
  @Prop mayAlsoLike: string = '猜你喜欢'
  
  /** 
   * 点击事件处理函数
   * 默认空实现，支持父组件自定义交互逻辑
   * 常用于导航到分类列表页面
   */
  handleClick: () => void = () => {}

  /**
   * 组件UI构建方法
   * 构建推荐内容的标题栏布局
   * 
   * 布局结构：
   * 1. 外层Row：水平布局，两端对齐，占满父容器宽度
   * 2. 左侧标题：大号字体突出显示推荐主题
   * 3. 右侧分类入口：小号字体+箭头图标，指示更多内容
   * 
   * 视觉层次：
   * - 标题：20px、500字重、深黑色 - 主要视觉焦点
   * - 分类：14px、400字重、灰色 - 次要操作入口
   * - 箭头：16px灰色图标 - 可点击性指示
   * 
   * 交互设计：
   * - 整个右侧区域可点击，提供更大的触控面积
   * - 鼠标悬停时应有视觉反馈（由系统处理）
   * - 支持父组件注入自定义点击逻辑
   * 
   * 样式一致性：
   * - 使用应用级颜色资源，支持主题切换
   * - 采用标准字体族，确保跨平台显示一致
   * - 固定高度28px，保持各页面统一的高度标准
   */
  build() {
    Row() {
      // 左侧推荐标题
      Text(`${this.mayAlsoLike}`)                                   // 动态显示推荐标题
        .font({
          size: 20,                                                 // 20px字体大小
          weight: 500,                                              // 500字重（中粗体）
          family: CommonConstants.FAMILY_PingFANG                  // 苹方字体族
        })
        .fontColor($r('app.string.color_black_88'))                // 深黑色字体
        .lineHeight(28)                                             // 28px行高

      // 右侧分类入口
      Row() {
        Text('全部分类').font({
          size: 14,                                                 // 14px字体大小
          weight: 400,                                              // 400字重（常规体）
          family: CommonConstants.FAMILY_PingFANG                  // 苹方字体族
        })
          .fontColor($r('app.string.color_black_45'))              // 灰色字体（次要信息）
          .lineHeight(22)                                           // 22px行高
        
        // 箭头图标
        Image($r('app.media.icon_right'))                           // 右箭头图标
          .width(16)                                                // 16px宽度
          .height(16)                                               // 16px高度
          .fillColor($r('app.string.color_black_45'))              // 灰色填充（与文字一致）
      }
      .height(28)                                                   // 固定高度28px
      .justifyContent(FlexAlign.Center)                            // 内容居中
      .alignItems(VerticalAlign.Center)                            // 垂直居中对齐
      .onClick(() => {
        // 点击事件处理，执行父组件传入的回调函数
        this.handleClick()
      })
    }
    .width('100%')                                                  // 占满父容器宽度
    .height(28)                                                     // 固定高度28px
    .justifyContent(FlexAlign.SpaceBetween)                        // 两端对齐（左右分布）
    .alignItems(VerticalAlign.Center)                              // 垂直居中对齐
  }
}
/**
 * @author 2008
 * @datetime 2024/7/14 19:54
 * @className: FindContent
 * @description: 发现页面内容组件 - 发现页面的顶层容器组件
 * 
 * 组件功能：
 * 1. 提供搜索入口：显示搜索框，点击后跳转到搜索页面
 * 2. 承载主要内容：包含BodyContent组件，展示书籍分类内容
 * 3. 作为发现页面的主要布局容器，负责整体结构安排
 * 
 * 组件结构：
 * - 顶部搜索栏：固定高度的搜索输入框
 * - 内容区域：BodyContent组件，展示小说/漫画/有声书内容
 * 
 * 交互说明：
 * - 搜索框点击：不直接进行搜索，而是导航到专门的搜索页面
 * - 搜索框不获取焦点：避免自动弹出键盘，提供更好的用户体验
 * 
 * 数据流：
 * - 接收父组件传入的currentIndex（当前分类索引）
 * - 将currentIndex传递给BodyContent组件
 * - 搜索功能独立于分类，点击后直接跳转到搜索页面
 */

// 导入必要的组件和工具
import { router } from '@kit.ArkUI';  // 路由导航
import BodyContent from './BodyContent';  // 内容主体组件

/**
 * 发现页面内容组件
 * @prop {number} currentIndex - 当前选中的分类索引（0-小说，1-漫画，2-有声书）
 */
@Component
export default struct FindContent{
  // 当前分类索引，由父组件（发现页面）传入
  @Prop currentIndex: number

  /**
   * 组件UI构建方法
   * 定义发现页面的整体布局和交互逻辑
   * 
   * 布局结构：
   * 1. 外层Column：垂直布局，作为根容器
   * 2. 搜索栏：顶部固定搜索框，提供搜索入口
   * 3. 内容区：BodyContent组件，展示当前分类的内容
   * 
   * 样式特点：
   * - 搜索栏：白色背景，圆角边框，有placeholder提示文字
   * - 搜索栏边距：上下8px，左右20px，确保与其他内容有合适间距
   * - 搜索框不获取焦点：避免自动弹出键盘，提升用户体验
   * 
   * 交互逻辑：
   * - 搜索框点击：导航到专门的搜索页面，不直接在当前页面搜索
   * - 内容展示：由BodyContent组件根据currentIndex展示对应分类内容
   */
  build() {
    Column(){
      // 搜索栏：提供搜索入口
      Search({
        placeholder: '搜索书名或作者'  // 搜索框提示文字
      })
        .focusOnTouch(false)  // 点击时不自动获取焦点，避免弹出键盘
        .margin({
          top: 8,     // 顶部外边距8px
          bottom: 8,  // 底部外边距8px
          left: 20,   // 左侧外边距20px
          right: 20   // 右侧外边距20px
        })
        .backgroundColor(Color.White)  // 白色背景
        .onClick(() => {
          // 点击搜索框时，导航到专门的搜索页面
          // 注意：这里不直接进行搜索，而是跳转到搜索页面
          router.pushUrl({
            url: 'pages/view/search/SearchBook'
          });
        })
      
      // 内容区域：展示当前分类的书籍内容
      BodyContent({
        currentIndex: this.currentIndex  // 传入当前分类索引
      })
    }
  }
}
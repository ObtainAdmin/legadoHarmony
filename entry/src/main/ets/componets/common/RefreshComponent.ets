/**
 * @file RefreshComponent.ets
 * @description 下拉刷新组件
 * 
 * 功能概述：
 * 1. 提供下拉刷新的提示信息显示
 * 2. 根据刷新状态显示不同的内容
 * 3. 支持自定义刷新提示文本
 * 
 * 使用场景：
 * - 列表下拉刷新时的提示区域
 * - 需要显示刷新状态和进度的场景
 * - 统一项目中的下拉刷新样式
 * 
 * 设计特点：
 * - 根据刷新状态条件显示加载进度条
 * - 支持自定义提示文本
 * - 简洁的水平布局
 * 
 * 状态显示逻辑：
 * 1. 默认状态（RefreshingTitle='松开刷新'）：
 *   - 只显示文本："松开刷新"
 *   - 不显示加载进度条
 * 
 * 2. 刷新中状态（RefreshingTitle≠'松开刷新'）：
 *   - 显示加载进度条（LoadingProgress）
 *   - 显示自定义提示文本
 *   - 进度条高度：30px
 * 
 * 样式特点：
 * - 文本：16px字体
 * - 布局：水平排列（Row）
 * - 间距：文本左侧20px边距
 * - 进度条：30px高度
 * 
 * 自定义能力：
 * - 通过RefreshingTitle属性自定义提示文本
 * - 默认文本："松开刷新"
 * - 刷新中时可显示如"正在刷新..."等文本
 * 
 * @author 2008
 * @datetime 2024/6/26 23:55
 */

/**
 * @class RefreshComponent
 * @description 下拉刷新组件
 * 
 * 组件职责：
 * 1. 根据刷新状态显示不同的UI
 * 2. 管理刷新提示文本
 * 3. 提供统一的刷新提示样式
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct RefreshComponent{
  /** 
   * @prop RefreshingTitle - 刷新提示文本
   * @description 下拉刷新时显示的提示文本
   * @default '松开刷新' - 默认提示文本
   * @type {string}
   * @note 当文本不为'松开刷新'时，会显示加载进度条
   */
  @Prop RefreshingTitle:string = '松开刷新'
  
  /**
   * @method build
   * @description 构建下拉刷新组件UI
   * 
   * 布局结构：
   * 1. 使用Row水平布局
   * 2. 条件显示加载进度条
   * 3. 显示刷新提示文本
   * 
   * 条件渲染逻辑：
   * - 如果RefreshingTitle !== '松开刷新'：显示LoadingProgress进度条
   * - 否则：不显示进度条
   * 
   * 进度条样式：
   * - 组件：LoadingProgress（系统加载进度组件）
   * - 高度：30px
   * - 显示时机：刷新中状态（即提示文本不是'松开刷新'时）
   * 
   * 文本样式：
   * - 内容：RefreshingTitle属性值
   * - 字体大小：16px
   * - 左边距：20px（与进度条的间距）
   * 
   * 设计理念：
   * - 通过文本内容判断刷新状态
   * - 刷新中时显示进度条提供视觉反馈
   * - 简洁的布局，不占用过多空间
   * - 易于集成到各种列表组件中
   * 
   * 状态判断机制：
   * - 使用文本内容作为状态标识
   * - '松开刷新'：准备刷新状态（用户下拉但未松手）
   * - 其他文本：刷新中状态（如'正在刷新...'）
   * 
   * 使用示例：
   * ```typescript
   * // 准备刷新状态
   * RefreshComponent({ RefreshingTitle: '松开刷新' })
   * 
   * // 刷新中状态
   * RefreshComponent({ RefreshingTitle: '正在刷新...' })
   * ```
   * 
   * 注意事项：
   * - 状态判断依赖于文本内容，需要确保文本约定的一致性
   * - 进度条使用系统默认样式
   * - 组件本身不处理刷新逻辑，只负责UI显示
   * 
   * @returns {void}
   */
  build() {
    Row() {
      if (this.RefreshingTitle !== '松开刷新') {
        LoadingProgress().height(30)
      }
      Text(this.RefreshingTitle).fontSize(16).margin({ left: 20 })
    }
  }
}

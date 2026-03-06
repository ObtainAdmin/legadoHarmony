/**
 * @file IndexSearchType.ets
 * @description 索引搜索类型组件
 * 
 * 功能概述：
 * 1. 显示搜索类型标签，支持下拉菜单选择
 * 2. 根据是否在BOOK_SEARCH_TYPE列表中决定是否显示下拉箭头
 * 3. 提供弹出式菜单选择不同的搜索类型
 * 4. 支持选中状态的视觉反馈
 * 
 * 使用场景：
 * - 搜索页面中的类型筛选
 * - 需要下拉选择的分类标签
 * - 多选项选择器
 * 
 * 设计特点：
 * - 智能显示：根据类型是否在预定义列表中决定是否显示下拉功能
 * - 弹出菜单：支持完整的下拉选择功能
 * - 视觉反馈：选中状态有明显标识（勾选图标）
 * - 统一设计：使用项目常量保持样式一致性
 * 
 * 组件结构：
 * 1. 条件渲染：根据BOOK_SEARCH_TYPE.includes(this.title)决定显示模式
 * 2. 可下拉模式：显示文本+下拉箭头，点击弹出菜单
 * 3. 普通模式：只显示文本，无交互功能
 * 4. 菜单构建器：创建下拉菜单选项
 * 
 * 技术特点：
 * - 使用@Prop装饰器接收父组件数据
 * - 使用@Link装饰器实现双向数据绑定
 * - 使用@State装饰器管理组件内部状态
 * - 使用@StorageProp装饰器获取主题配置
 * - 使用@Builder装饰器创建菜单构建器
 * - 使用bindPopup绑定弹出菜单
 */

import CommonConstants from '../../common/constants/CommonConstants'
import FontConstants from '../../common/constants/FontConstants'
import PaddingConstants from '../../common/constants/PaddingConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'
import { BOOK_SEARCH_TYPE } from '../../database/entities/Books'

/**
 * @class IndexSearchType
 * @description 索引搜索类型组件
 * 
 * 组件职责：
 * 1. 显示搜索类型标签
 * 2. 管理下拉菜单的显示/隐藏
 * 3. 处理类型选择逻辑
 * 4. 根据类型是否在预定义列表中决定交互方式
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct IndexSearchType {
  /** 
   * @prop title - 标题文本
   * @description 搜索类型显示的文本内容，从父组件传入
   * @type {string}
   */
  @Prop title:string
  
  /** 
   * @link searchValue - 搜索值
   * @description 当前选中的搜索类型值，与父组件双向绑定
   * @type {string}
   */
  @Link searchValue:string
  
  /** 
   * @state isShown - 是否显示菜单
   * @description 控制下拉菜单的显示/隐藏状态
   * @default false - 默认隐藏
   * @type {boolean}
   */
  @State isShown: boolean = false
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method build
   * @description 构建索引搜索类型组件UI
   * 
   * 核心逻辑：
   * 1. 判断当前title是否在BOOK_SEARCH_TYPE预定义列表中
   * 2. 如果在列表中，显示可下拉的交互式组件
   * 3. 如果不在列表中，显示只读的文本组件
   * 
   * 可下拉模式（BOOK_SEARCH_TYPE.includes(this.title)为true）：
   * 1. Row容器：包含文本和下拉箭头图标
   * 2. Text文本：显示标题，根据选中状态应用不同样式
   *    - 选中状态：100%黑色，15px字体，600字重
   *    - 未选中状态：50%黑色，15px字体，400字重
   * 3. Image图标：下拉箭头，根据isShown状态切换方向
   *    - isShown为true：显示向上箭头
   *    - isShown为false：显示向下箭头
   *    - 透明度：选中时1，未选中时0.3
   * 4. 点击事件：设置searchValue为当前title，切换isShown状态
   * 5. 弹出菜单绑定：使用bindPopup绑定MenuBuilder构建的菜单
   *    - 显示条件：isShown为true
   *    - 位置：底部弹出
   *    - 启用箭头：true
   *    - 圆角：12px
   *    - 状态变化回调：当菜单隐藏时，设置isShown为false
   * 
   * 普通模式（不在BOOK_SEARCH_TYPE列表中）：
   * 1. Row容器：只包含文本
   * 2. Text文本：显示标题，根据选中状态应用不同样式
   *    - 选中状态：100%黑色，15px字体，600字重
   *    - 未选中状态：50%黑色，15px字体，400字重
   * 
   * 设计理念：
   * - 智能交互：只有预定义的类型才支持下拉选择
   * - 清晰的视觉反馈：选中状态通过颜色、字重和图标明显区分
   * - 一致的用户体验：使用标准的弹出菜单组件
   * - 灵活的布局：根据内容动态调整显示方式
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中使用
   * IndexSearchType({
   *   title: '书名',
   *   searchValue: $searchType,
   * })
   * 
   * IndexSearchType({
   *   title: '作者',
   *   searchValue: $searchType,
   * })
   * ```
   * 
   * 颜色说明：
   * 1. rgba(0, 0, 0, 1.00): 100%黑色，用于选中状态的文字
   * 2. rgba(0, 0, 0, 0.50): 50%黑色，用于未选中状态的文字
   * 3. theme.mainColor: 主题主色，用于菜单中选中项的文字
   * 4. $r('app.string.color_black_88'): 资源引用，88%黑色，用于菜单中未选中项的文字
   * 
   * 字体说明：
   * 1. 主文本：15px字体，选中600字重，未选中400字重
   * 2. 菜单文本：14px字体，400字重，PingFANG字体族
   * 
   * 注意事项：
   * - BOOK_SEARCH_TYPE是预定义的搜索类型常量数组
   * - bindMenu功能被注释掉，当前使用bindPopup
   * - 需要导入多个常量文件（CommonConstants、FontConstants、PaddingConstants）
   * - 菜单宽度固定为150px
   * 
   * 扩展建议：
   * - 可以添加自定义菜单项
   * - 可以添加搜索功能到菜单中
   * - 可以添加多选支持
   * - 可以添加菜单最大高度和滚动支持
   * 
   * @returns {void}
   */
  build() {
    if (BOOK_SEARCH_TYPE.includes(this.title)){
      Row(
        {
          space:3
        }
      ) {
        Text(this.title)
          .fontColor(this.searchValue === this.title ? 'rgba(0, 0, 0, 1.00)' :  'rgba(0,0,0,0.5)')
          .fontSize(15)
          .fontWeight(this.searchValue === this.title ? 600 : 400)
        Image(this.isShown?$r('app.media.direction_upper'):$r('app.media.direction_down'))
          .width(15).height(15)
          .opacity(this.title === this.searchValue?1:0.3)
      }
      .onClick(()=>{
        this.searchValue = this.title
        this.isShown = !this.isShown
      })
      .bindPopup(this.isShown,{
        builder: this.MenuBuilder(),
        placement: Placement.Bottom,
        enableArrow:true,
        radius:12,
        onStateChange: (e) => {
          if (!e.isVisible) {
            this.isShown = false;
          }
        }
      })
      // .bindMenu(this.isShown, this.MenuBuilder,
      //   {
      //     onDisappear: ()=>{
      //       this.isShown = false;
      //     }
      //   })
    } else {
      Row(
        {
          space:3
        }
      ) {
        Text(this.title)
          .fontColor(this.searchValue === this.title ? 'rgba(0, 0, 0, 1.00)' :  'rgba(0,0,0,0.5)')
          .fontSize(15)
          .fontWeight(this.searchValue === this.title ? 600 : 400)
      }
    }

  }

  /**
   * @builder MenuBuilder
   * @description 菜单构建器
   * 
   * 功能说明：
   * 1. 创建下拉菜单选项列表
   * 2. 显示所有BOOK_SEARCH_TYPE中的选项
   * 3. 提供选中状态的视觉反馈（勾选图标）
   * 4. 处理选项点击事件
   * 
   * 布局结构：
   * 1. Column容器：包裹所有菜单项
   * 2. ForEach循环：遍历BOOK_SEARCH_TYPE数组
   * 3. 每个菜单项包含：
   *    - Row容器：文本和勾选图标
   *    - Text文本：选项名称
   *    - Image图标：选中时显示勾选图标
   *    - Divider分割线：除最后一项外都显示
   * 
   * 样式说明：
   * 1. 文本样式：
   *    - 字体大小：14px（FontConstants.FONT_SIZE_14）
   *    - 字体字重：400（FontConstants.FONT_WEIGHT_400）
   *    - 字体族：PingFANG（CommonConstants.FAMILY_PingFANG）
   *    - 文字颜色：选中时主题主色，未选中时88%黑色
   * 2. 容器样式：
   *    - 内边距：上下12px，左右20px
   *    - 宽度：100%
   *    - 高度：40px
   *    - 布局：两端对齐，居中对齐
   * 3. 分割线样式：
   *    - 高度：10px
   *    - 宽度：80%
   *    - 颜色：#ccc
   * 
   * 交互逻辑：
   * 1. 点击事件：设置title和searchValue为当前选项，隐藏菜单
   * 2. 选中状态：当前选项等于searchValue时显示勾选图标
   * 
   * 容器样式：
   * - 内边距：4px（PaddingConstants.PADDING_4）
   * - 宽度：150px
   * 
   * @returns {void}
   */
  @Builder MenuBuilder() {
    Column(){
      ForEach(BOOK_SEARCH_TYPE, (item:string, index) => {
        Column() {
          Row() {
            Text(item)
              .font({
                size: FontConstants.FONT_SIZE_14,
                weight: FontConstants.FONT_WEIGHT_400,
                family: CommonConstants.FAMILY_PingFANG
              })
              .fontColor(this.searchValue === item ? this.theme.mainColor : $r('app.string.color_black_88'))
            Image(item ===  this.searchValue?$r('app.media.hook'):'').width(20).height(20)
          }
          .padding({
            top: PaddingConstants.PADDING_12,
            bottom: PaddingConstants.PADDING_12,
            left:PaddingConstants.PADDING_20,
            right:PaddingConstants.PADDING_20
          })
          .width('100%')
          .height(40)
          .justifyContent(FlexAlign.SpaceBetween)
          .align(Alignment.Center)
          .onClick(() => {
            this.title = item
            this.searchValue = item
            this.isShown = false
          })
          if (index != BOOK_SEARCH_TYPE.length - 1) {
            Divider().height(10).width('80%').color('#ccc')
          }
        }
      })
    }
    .padding(PaddingConstants.PADDING_4)
    .width(150)
  }
}

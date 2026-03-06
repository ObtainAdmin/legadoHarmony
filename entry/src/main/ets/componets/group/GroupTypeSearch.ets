/**
 * @file GroupTypeSearch.ets
 * @description 分组类型搜索组件
 * 
 * 功能概述：
 * 1. 显示可搜索的分组列表
 * 2. 支持分组面板的显示/隐藏切换
 * 3. 提供水平滚动浏览分组
 * 4. 支持分组选择和数据刷新
 * 
 * 使用场景：
 * - 搜索页面中的分组筛选
 * - 需要排除特定分组的场景
 * - 分组搜索面板展示
 * 
 * 设计特点：
 * - 支持两种显示模式：搜索面板模式和水平滚动模式
 * - 排除特定分组（groupId为1和5）
 * - 支持更多按钮的显示/隐藏控制
 * - 使用Flex布局实现灵活的UI结构
 * 
 * 组件结构：
 * 1. 搜索面板模式（groupCoverShow为true）：
 *   - Stack布局：搜索面板 + 半透明遮罩
 *   - groupTypeSearchPanel组件：显示分组搜索详情
 *   - Rect遮罩：45%黑色半透明背景，y轴偏移100px
 * 
 * 2. 水平滚动模式（groupCoverShow为false）：
 *   - Flex布局：水平滚动区域 + 更多按钮
 *   - Scroll水平滚动：显示分组列表
 *   - ForEach循环：渲染每个分组项（排除特定分组）
 *   - BookType组件：显示单个分组
 *   - 更多按钮：点击切换到搜索面板模式
 * 
 * 技术特点：
 * - 使用@Prop装饰器接收父组件数据
 * - 使用@Link装饰器实现父子组件数据同步
 * - 使用@State装饰器管理组件内部状态
 * - 使用aboutToAppear生命周期方法初始化数据
 */

import BookGroupsDao from '../../database/dao/BookGroupsDao'
import { BookGroups } from '../../database/entities/BookGroups'
import BookType from '../head/BookType'
import groupTypeSearchPanel from './groupTypeSearchPanel'

/**
 * @class groupTypeSearch
 * @description 分组类型搜索组件
 * 
 * 组件职责：
 * 1. 管理可搜索的分组列表显示
 * 2. 处理搜索面板的显示/隐藏
 * 3. 排除特定分组（如系统分组）
 * 4. 处理分组选择逻辑
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct groupTypeSearch {
  /** 
   * @prop currentIndex - 当前索引
   * @description 当前选中的分组类型索引，从父组件传入
   * @type {number}
   */
  @Prop currentIndex: number
  
  /** 
   * @link groupCoverShow - 分组面板显示状态
   * @description 控制分组搜索面板的显示/隐藏，与父组件双向绑定
   * @type {boolean}
   */
  @Link groupCoverShow:boolean
  
  /** 
   * @state groupList - 分组列表
   * @description 分组数据列表，从数据库查询获取
   * @type {BookGroups[]}
   */
  @State groupList:BookGroups[] = []
  
  /** 
   * @link bookTypeNumber - 书籍类型编号
   * @description 当前选中的书籍类型编号，与父组件双向绑定
   * @type {number}
   */
  @Link bookTypeNumber:number
  
  /** 
   * @link searchBookList - 搜索书籍列表
   * @description 搜索到的书籍ID列表，与父组件双向绑定
   * @type {number[]}
   */
  @Link searchBookList:number[]
  
  /** 
   * @prop isShowMore - 是否显示更多
   * @description 控制是否显示更多按钮，从父组件传入
   * @default false - 默认显示更多按钮
   * @type {boolean}
   */
  @Prop isShowMore:boolean = false
  
  /**
   * @method aboutToAppear
   * @description 组件即将显示时的生命周期方法
   * 
   * 功能说明：
   * 1. 组件初始化时调用
   * 2. 获取分组列表数据
   * 
   * @returns {void}
   */
  aboutToAppear(): void {
    this.getGroupList()
  }
  
  /**
   * @method changeRefresh
   * @description 变化刷新方法
   * 
   * 功能说明：
   * 1. 重新获取分组列表数据
   * 
   * @returns {void}
   */
  changeRefresh(){
    this.getGroupList()
  }
  
  /**
   * @method getGroupList
   * @description 获取分组列表
   * 
   * 功能说明：
   * 1. 从数据库查询分组数据
   * 2. 根据currentIndex筛选分组类型
   * 3. 更新groupList状态
   * 
   * 查询条件：
   * - type: this.currentIndex（分组类型）
   * 
   * @returns {void}
   */
  getGroupList(){
    BookGroupsDao.search({
      type:this.currentIndex,
    }).then((val)=>{
      this.groupList = val
    })
  }

  /**
   * @method build
   * @description 构建分组类型搜索组件UI
   * 
   * 布局逻辑：
   * 1. 条件判断：根据this.groupCoverShow决定显示模式
   * 2. 搜索面板模式（this.groupCoverShow为true）：
   *   - Stack布局：搜索面板 + 遮罩层
   *   - groupTypeSearchPanel组件：显示分组搜索详情，zIndex为9999
   *   - Rect遮罩：45%黑色半透明背景，y轴偏移100px
   * 
   * 3. 水平滚动模式（this.groupCoverShow为false）：
   *   - Flex布局：水平居中，两端对齐
   *   - Scroll水平滚动：关闭滚动条，水平可滚动
   *   - Row布局：分组项水平排列，间距10px
   *   - ForEach循环：遍历this.groupList，只显示符合条件的分组
   *   - 显示条件：item.show为true且item.groupId不为1和5
   *   - BookType组件：显示单个分组
   *   - 点击事件：设置bookTypeNumber为分组的groupId
   *   - 更多按钮Row：宽度10%，显示更多图标
   *   - 更多按钮点击：将groupCoverShow设置为true
   *   - 更多按钮可见性：根据isShowMore控制显示/隐藏
   *   - 边距：左边距15px，底部边距10px
   * 
   * 交互逻辑：
   * 1. 分组项点击：设置bookTypeNumber为分组的groupId
   * 2. 更多按钮点击：将groupCoverShow设置为true，显示搜索面板
   * 3. 更多按钮可见性：当isShowMore为false时显示，为true时隐藏
   * 
   * 设计理念：
   * - 两种模式切换：简洁的水平列表 vs 详细的搜索面板
   * - 分组过滤：排除特定系统分组（groupId为1和5）
   * - 灵活控制：通过isShowMore控制更多按钮显示
   * - 数据驱动：所有UI状态由数据状态控制
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中使用
   * groupTypeSearch({
   *   currentIndex: this.currentIndex,
   *   groupCoverShow: $groupCoverShow,
   *   bookTypeNumber: $bookTypeNumber,
   *   searchBookList: $searchBookList,
   *   isShowMore: false
   * })
   * ```
   * 
   * 颜色说明：
   * 1. rgba(0, 0, 0, 0.45): 45%黑色半透明，用于遮罩层
   * 
   * 注意事项：
   * - 排除groupId为1和5的分组，可能是系统保留分组
   * - 遮罩层有100px的y轴偏移，与groupTypePanel不同
   * - 更多按钮的可见性由isShowMore属性控制
   * - 需要导入BookGroupsDao、BookGroups、BookType、groupTypeSearchPanel等依赖
   * 
   * 扩展建议：
   * - 可以添加分组搜索功能
   * - 可以添加自定义分组过滤规则
   * - 可以添加分组排序功能
   * - 可以添加分组收藏功能
   * 
   * @returns {void}
   */
  build() {
    if (this.groupCoverShow){
      Stack(){
        groupTypeSearchPanel({
          groupCoverShow:this.groupCoverShow,
          showGroupList:this.groupList,
          currentIndex:this.currentIndex,
          searchBookList:this.searchBookList
        })
          .zIndex(9999)
        Rect()
          .height('100%')
          .width('100%')
          .fill('rgba(0, 0, 0, 0.45)')
          .offset({y:100})

      }.alignContent(Alignment.TopStart)
    } else {
      Flex(
        {
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }
      ) {
        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.groupList,(item:BookGroups)=>{
              if (item.show && item.groupId != 1 && item.groupId != 5) {
                BookType({ title: item.groupName,
                  index:item.groupId,
                  bookTypeNumber:this.bookTypeNumber
                }).onClick(() => {
                  if (item.groupId){
                    this.bookTypeNumber = item.groupId
                  }
                })
              }
            })
          }
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
        Row(){
          Image($r('app.media.more_search')).width(25).height(25)
        }.width(
          '10%'
        ).onClick(()=>{
          this.groupCoverShow = true
        })
        .visibility(!this.isShowMore?Visibility.Visible:Visibility.Hidden)
      }.margin({ left: 15,bottom:10})
    }

  }
}
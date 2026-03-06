/**
 * @file GroupType.ets
 * @description 分组类型组件
 * 
 * 功能概述：
 * 1. 显示书籍分组列表（如标签、文件夹等）
 * 2. 支持分组面板的显示/隐藏切换
 * 3. 提供水平滚动浏览分组
 * 4. 支持分组选择和数据刷新
 * 
 * 使用场景：
 * - 书籍分类页面中的分组选择
 * - 标签管理页面
 * - 文件夹分组展示
 * - 需要分组筛选的场景
 * 
 * 设计特点：
 * - 支持两种显示模式：分组面板模式和水平滚动模式
 * - 使用@Watch装饰器监听数据变化自动刷新
 * - 支持本地存储数据同步
 * - 使用Flex布局实现灵活的UI结构
 * 
 * 组件结构：
 * 1. 分组面板模式（groupCoverShow为true）：
 *   - Stack布局：分组面板 + 半透明遮罩
 *   - groupTypePanel组件：显示分组详情
 *   - Rect遮罩：45%黑色半透明背景
 * 
 * 2. 水平滚动模式（groupCoverShow为false）：
 *   - Flex布局：水平滚动区域 + 更多按钮
 *   - Scroll水平滚动：显示分组列表
 *   - ForEach循环：渲染每个分组项
 *   - BookType组件：显示单个分组
 *   - 更多按钮：点击切换到分组面板模式
 * 
 * 技术特点：
 * - 使用@Link装饰器实现父子组件数据同步
 * - 使用@State装饰器管理组件内部状态
 * - 使用@StorageLink装饰器同步本地存储
 * - 使用@Watch装饰器监听数据变化
 * - 使用aboutToAppear生命周期方法初始化数据
 */

import BookGroupsDao from '../../database/dao/BookGroupsDao'
import { BookGroups } from '../../database/entities/BookGroups'
import BookType from '../head/BookType'
import groupTypePanel from './groupTypePanel'

/**
 * @class groupTypeComponent
 * @description 分组类型组件
 * 
 * 组件职责：
 * 1. 管理分组列表的显示和交互
 * 2. 处理分组面板的显示/隐藏
 * 3. 监听数据变化并自动刷新
 * 4. 处理分组选择逻辑
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct groupTypeComponent {
  /** 
   * @state globalPositionY - 全局Y轴位置
   * @description 全局Y轴位置，用于布局计算（当前未使用）
   * @type {Length}
   */
  @State globalPositionY: Length = 0
  
  /** 
   * @link currentIndex - 当前索引
   * @description 当前选中的分组索引，与父组件双向绑定
   * @watch changeRefresh - 监听变化，触发刷新
   * @type {number}
   */
  @Link @Watch('changeRefresh')currentIndex: number
  
  /** 
   * @link groupCoverShow - 分组面板显示状态
   * @description 控制分组面板的显示/隐藏，与父组件双向绑定
   * @type {boolean}
   */
  @Link groupCoverShow:boolean
  
  /** 
   * @link GROUP - 分组类型
   * @description 当前选中的分组类型（如'文件夹'、'标签'），与父组件双向绑定
   * @type {string}
   */
  @Link GROUP:string
  
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
   * @storagelink BOOK_IS_BOOK_GROUPS_REFRESHING - 分组刷新状态
   * @description 分组刷新状态，存储在本地，与父组件双向绑定
   * @watch changeRefresh - 监听变化，触发刷新
   * @default 0 - 默认未刷新
   * @type {number}
   */
  @StorageLink('BOOK_IS_BOOK_GROUPS_REFRESHING') @Watch('changeRefresh')BOOK_IS_BOOK_GROUPS_REFRESHING: number = 0
  
  /**
   * @method aboutToAppear
   * @description 组件即将显示时的生命周期方法
   * 
   * 功能说明：
   * 1. 组件初始化时调用
   * 2. 获取分组列表数据
   * 
   * 调用时机：
   * - 组件首次创建时
   * - 组件从后台切换到前台时
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
   * 1. 被@Watch装饰器监听的方法
   * 2. 当currentIndex或BOOK_IS_BOOK_GROUPS_REFRESHING变化时调用
   * 3. 重新获取分组列表数据
   * 
   * 触发条件：
   * - currentIndex变化时
   * - BOOK_IS_BOOK_GROUPS_REFRESHING变化时
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
   * 数据流程：
   * 1. 调用BookGroupsDao.search()查询数据库
   * 2. Promise.then()处理查询结果
   * 3. 将结果赋值给this.groupList
   * 
   * 注意事项：
   * - 使用异步查询，避免阻塞UI
   * - 查询条件根据currentIndex动态变化
   * - 需要导入BookGroupsDao和BookGroups
   * 
   * @returns {void}
   */
  getGroupList(){
    BookGroupsDao.search({
      type:this.currentIndex
    }).then((val)=>{
      this.groupList = val
    })
  }

  /**
   * @method build
   * @description 构建分组类型组件UI
   * 
   * 布局逻辑：
   * 1. 条件判断：根据this.groupCoverShow决定显示模式
   * 2. 分组面板模式（this.groupCoverShow为true）：
   *   - Stack布局：分组面板 + 遮罩层
   *   - groupTypePanel组件：显示分组详情，zIndex为9999确保在最上层
   *   - Rect遮罩：45%黑色半透明背景，y轴偏移20px
   *   - 对齐方式：顶部左对齐
   * 
   * 3. 水平滚动模式（this.groupCoverShow为false）：
   *   - Flex布局：水平居中，两端对齐
   *   - Scroll水平滚动：关闭滚动条，水平可滚动
   *   - Row布局：分组项水平排列，间距10px
   *   - ForEach循环：遍历this.groupList，只显示item.show为true的分组
   *   - BookType组件：显示单个分组，传递title、index、bookTypeNumber
   *   - 点击事件：设置GROUP类型和bookTypeNumber
   *   - 更多按钮Row：宽度10%，显示更多图标
   *   - 更多按钮点击：将groupCoverShow设置为true，切换到分组面板模式
   *   - 边距：左边距15px，底部边距10px
   * 
   * 交互逻辑：
   * 1. 分组项点击：
   *   - 判断分组名称：如果为'分组'则设置GROUP为'文件夹'，否则为'标签'
   *   - 设置bookTypeNumber为分组的groupId
   * 2. 更多按钮点击：
   *   - 将groupCoverShow设置为true，显示分组面板
   * 3. 数据刷新：
   *   - 当currentIndex或BOOK_IS_BOOK_GROUPS_REFRESHING变化时自动刷新分组列表
   * 
   * 设计理念：
   * - 两种模式切换：简洁的水平列表 vs 详细的分组面板
   * - 水平滚动：适应移动端小屏幕，方便浏览多个分组
   * - 条件渲染：根据item.show控制分组显示，实现灵活的数据过滤
   * - 数据驱动：所有UI状态由数据状态控制
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中使用
   * groupTypeComponent({
   *   currentIndex: $currentIndex,
   *   groupCoverShow: $groupCoverShow,
   *   GROUP: $GROUP,
   *   bookTypeNumber: $bookTypeNumber
   * })
   * ```
   * 
   * 颜色说明：
   * 1. rgba(0, 0, 0, 0.45): 45%黑色半透明，用于遮罩层
   * 
   * 注意事项：
   * - groupCoverShow控制两种显示模式的切换
   * - 分组面板的zIndex设置为9999，确保在最上层显示
   * - 遮罩层有20px的y轴偏移，可能需要调整
   * - 分组项只显示item.show为true的分组
   * - 需要导入BookGroupsDao、BookGroups、BookType、groupTypePanel等依赖
   * 
   * 扩展建议：
   * - 可以添加分组搜索功能
   * - 可以添加分组排序功能
   * - 可以添加分组编辑功能
   * - 可以添加分组拖拽排序
   * 
   * @returns {void}
   */
  build() {
    if (this.groupCoverShow){
      Stack(){
        groupTypePanel({
          groupCoverShow:this.groupCoverShow,
          showGroupList:this.groupList,
          currentIndex:this.currentIndex
        })
          .zIndex(9999)
        Rect()
          .height('100%')
          .width('100%')
          .fill('rgba(0, 0, 0, 0.45)')
          .offset({y:20})

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
              if (item.show) {
                BookType({ title: item.groupName,
                  index:item.groupId,
                  bookTypeNumber:this.bookTypeNumber
                }).onClick(() => {
                  if (item.groupName === '分组') {
                    this.GROUP = '文件夹'
                  } else {
                    this.GROUP = '标签'
                  }
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
      }.margin({ left: 15,bottom:10})
    }
  }
}

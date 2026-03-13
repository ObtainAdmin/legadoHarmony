/**
 * 书籍主体内容组件 - 管理书籍显示和交互的核心组件
 * 
 * 功能概述：
 * 1. 提供书籍展示模式切换：列表模式、宫格模式
 * 2. 支持分组方式切换：标签分组、文件夹分组
 * 3. 管理搜索功能：最近阅读、浏览历史
 * 4. 集成书籍内容刷新组件，实时更新书籍列表
 * 5. 提供管理功能入口，跳转到书籍管理页面
 * 6. 支持浏览历史清空功能
 * 
 * 组件结构：
 * - 顶部：搜索类型切换、展示模式切换、分组方式切换、管理按钮
 * - 主体：Tabs组件，显示书籍内容刷新组件
 * - 集成：分组类型组件，显示书籍分组信息
 * 
 * 数据流：
 * 通过@Link和@Prop与父组件进行双向数据绑定
 * 使用@StorageLink同步应用级状态
 */

import groupTypeComponent from '../../../../componets/group/GroupType'
import IndexSearchType from '../../../../componets/head/IndexSearchType'
import { router } from '@kit.ArkUI'
import confirmDialogExample from '../../../../componets/common/confirmDialog'
import BookContentRefresh from './BookContentRefresh'
import bookHistoryUtils from '../../../../common/utils/BookHistoryUtils'
import { showMessage } from '../../../../componets/common/promptShow'

/**
 * 书籍主体内容组件结构体
 * 
 * 职责：
 * 1. 管理书籍展示模式和分组方式的切换
 * 2. 处理搜索类型的选择和状态同步
 * 3. 控制分组封面显示和Tabs切换
 * 4. 提供浏览历史清空功能
 * 5. 集成书籍内容刷新组件，显示具体书籍列表
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 使用export default导出，供其他页面引用
 * - 支持双向数据绑定，与父组件保持状态同步
 * - 集成对话框组件，提供确认操作
 */
@Component
export default struct BookBodyContent {
  /** 组件索引，用于标识组件实例 */
  @Prop index:number
  
  /** 当前书籍类型索引：0-小说，1-漫画，2-有声书 */
  @Prop currentIndex: number = 0
  
  /** 展示模式名称数组：['列表', '宫格'] */
  @State EXHIBIT_NAMES: string[] = ['列表', '宫格']
  
  /** 分组方式名称数组：['标签', '文件夹'] */
  @State GROUP_NAMES: string[] = ['标签', '文件夹']
  
  /** 展示模式，与父组件双向绑定 */
  @Link EXHIBIT: string
  
  /** 分组方式，与父组件双向绑定 */
  @Link GROUP: string
  
  /** 搜索值：'最近阅读'或'浏览历史' */
  @State searchValue: string = '最近阅读'
  
  /** 书籍类型编号，与父组件双向绑定 */
  @Link bookTypeNumber:number
  
  /** 标题文本，当前未使用，保留供未来扩展 */
  @State title: string = '最近阅读'
  
  /** 分组封面显示状态，控制groupTypeComponent的显示 */
  @State groupCoverShow: boolean = false
  
  /** 书籍主体Tabs索引，用于控制Tabs切换 */
  @State bookBodyIndex: number = 0
  
  /** Tabs控制器，管理Tabs组件的切换 */
  tabsBookBodyController: TabsController = new TabsController();
  
  /** 书籍历史刷新标记，存储在应用存储中，变化时触发历史列表刷新 */
  @StorageLink('BOOK_IS_BOOK_HISTORY_REFRESHING') isBookHistoryRefreshing: number = 0
  /**
   * 构建书籍主体内容组件UI的主要方法
   * 
   * 布局结构：
   * 1. Column布局作为根容器
   * 2. 顶部Flex布局：水平滚动的功能按钮区域
   * 3. 主体Stack布局：分组类型组件 + Tabs组件
   * 
   * 顶部区域功能：
   * - 最近阅读：默认搜索类型
   * - 浏览历史：切换显示浏览历史记录
   * - 分组方式切换：标签/文件夹（仅在非浏览历史模式下显示）
   * - 展示模式切换：列表/宫格（仅在非浏览历史模式下显示）
   * - 管理按钮：跳转到书籍管理页面（仅在非浏览历史模式下显示）
   * - 清空按钮：清空浏览历史记录（仅在浏览历史模式下显示）
   * 
   * 主体区域：
   * - groupTypeComponent：显示书籍分组信息（仅在非浏览历史模式下显示）
   * - Tabs组件：包含BookContentRefresh组件，显示具体书籍内容
   */
  build() {
    Column() {
      // 顶部功能按钮区域
      Flex(
        {
          alignContent: FlexAlign.Center,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }
      ) {
        Scroll() {
          Flex({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Row({ space: 15 }) {
              // 最近阅读按钮
              IndexSearchType({ title: this.title, searchValue: this.searchValue })
              
              // 浏览历史按钮
              IndexSearchType({ title: '浏览历史', searchValue: this.searchValue })
                .onClick(() => {
                  this.GROUP = '标签'  // 切换到标签分组
                  this.searchValue = '浏览历史'  // 更新搜索值
                })
              
              // 非浏览历史模式下显示的功能按钮
              if (this.searchValue !== '浏览历史') {
                // 分组方式切换
                this.GroupBuilder()
                
                // 展示模式切换
                this.ExhibitBuilder()
                
                // 管理按钮：跳转到书籍管理页面
                Text('管理')
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/view/bookShelf/Manage/BookManagePage',
                      params: {
                        currentIndex: this.currentIndex,
                        EXHIBIT: this.EXHIBIT,
                        bookTypeNumber: this.bookTypeNumber
                      }
                    })
                  })
                  .fontColor('rgba(0,0,0,0.5)')
                  .fontSize(15)
                  .fontWeight(400)
              }
            }
          }
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)

        // 浏览历史模式下显示清空按钮
        if (this.searchValue === '浏览历史') {
          Row() {
            Text('清空')
              .onClick(() => {
                if (this.IndexShelf != null) {
                  this.IndexShelf.open()  // 打开确认对话框
                }
              })
          }
        }
      }
      .padding(15)

      // 主体内容区域
      Stack() {
        // 非浏览历史模式下显示分组类型组件
        if (this.searchValue !== '浏览历史') {
          groupTypeComponent({
            bookTypeNumber:this.bookTypeNumber,
            currentIndex: this.currentIndex,
            groupCoverShow: this.groupCoverShow,
            GROUP: this.GROUP
          }).zIndex(999)
        }
        
        // Tabs组件：显示书籍内容刷新组件
        Tabs({
          controller:this.tabsBookBodyController,
          index: this.bookBodyIndex
        }){
          TabContent(){
            BookContentRefresh({
              EXHIBIT: this.EXHIBIT,
              GROUP: this.GROUP,
              searchValue: this.searchValue,
              currentIndex: this.currentIndex,
              bookTypeNumber:this.bookTypeNumber
            })
          }
          .align(Alignment.Top)
        }
        .scrollable(false)
        .barWidth(0)
        .barHeight(0)
        .onChange((index) => {
          this.tabsBookBodyController.changeIndex(index)
          this.bookBodyIndex = index
        })
      }
      .layoutWeight(1)
      .alignContent(Alignment.Top)
    }
  }
  /** 删除缓存状态，用于确认对话框 */
  @State delCache: boolean = false
  
  /** 确认对话框控制器，管理清空历史记录的确认对话框 */
  IndexShelf: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      confirm: () => {
        this.onAccept()  // 确认回调函数
      },
      title: '清空',
      delCache: this.delCache
    }),
    autoCancel: true,  // 点击外部自动取消
    alignment: DialogAlignment.Center,  // 居中对齐
    // offset: { dx: 0, dy: '-40%' },  // 垂直偏移（注释状态）
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25  // 圆角半径
  })

  /**
   * 确认清空历史记录的处理函数
   * 功能：删除所有书籍历史记录，并更新状态
   * 操作：
   * 1. 调用bookHistoryUtils.deleteAllBookHistory()删除所有历史记录
   * 2. 延迟200ms后刷新历史列表
   * 3. 显示成功消息
   */
  onAccept() {
    bookHistoryUtils.deleteAllBookHistory()
    setTimeout(() => {
      this.isBookHistoryRefreshing++  // 触发历史列表刷新
      showMessage('清空成功!')
    },200)
  }


  /**
   * 构建分组方式切换按钮的Builder函数
   * 
   * 功能：创建分组方式切换按钮行
   * 逻辑：遍历GROUP_NAMES数组，为当前未选中的分组方式创建按钮
   * 设计：按钮之间使用垂直分隔线分隔
   * 
   * 交互：点击按钮时更新GROUP状态
   */
  @Builder
  GroupBuilder() {
    Row({ space: 10 }) {
      ForEach(this.GROUP_NAMES, (item: string) => {
        if (item !== this.GROUP) {  // 只显示未选中的分组方式
          IndexSearchType({ title: item, searchValue: this.searchValue })
            .onClick(() => {
              this.GROUP = item  // 更新分组方式
            })
          Divider()
            .vertical(true)
            .height(15)
            .color('#989797')
            .opacity(0.5)
            .strokeWidth(1)
        }
      })
    }
  }
  
  /**
   * 构建展示模式切换按钮的Builder函数
   * 
   * 功能：创建展示模式切换按钮行
   * 逻辑：遍历EXHIBIT_NAMES数组，为当前未选中的展示模式创建按钮
   * 设计：按钮之间使用垂直分隔线分隔
   * 
   * 交互：点击按钮时更新EXHIBIT状态
   */
  @Builder
  ExhibitBuilder() {
    Row({ space: 10 }) {
      ForEach(this.EXHIBIT_NAMES, (item: string) => {
        if (item !== this.EXHIBIT) {  // 只显示未选中的展示模式
          IndexSearchType({ title: item, searchValue: this.searchValue })
            .onClick(() => {
              this.EXHIBIT = item
            })
          Divider()
            .vertical(true)
            .height(15)
            .color('#989797')
            .opacity(0.5)
            .strokeWidth(1)
        }
      })
    }
  }
}
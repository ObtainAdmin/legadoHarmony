/**
 * 内容刷新组件 - 负责发现页面的内容展示、刷新和分类导航功能
 * 
 * 组件功能概述：
 * 1. 内容展示：根据书籍源展示对应的探索内容列表
 * 2. 下拉刷新：支持下拉手势刷新当前内容
 * 3. 分页加载：支持上滑加载更多内容
 * 4. 分类导航：提供完整的分类列表，支持快速导航
 * 5. 无数据提示：当书籍源没有探索URL时显示友好提示
 * 
 * 核心数据结构：
 * - exploreList: 存储从书籍源解析出的所有探索项
 * - showExploreList: 当前显示的部分探索项（分页）
 * - groupExploreList: 按分类分组的探索项，用于底部弹窗展示
 * 
 * 交互流程：
 * 1. 组件加载时解析书籍源的exploreUrl
 * 2. 根据解析结果渲染内容列表
 * 3. 用户下拉时触发刷新，重新加载数据
 * 4. 用户上滑时加载更多内容（分页）
 * 5. 点击分类按钮时显示底部弹窗，展示所有分类
 */

// 导入必要的组件和工具
import PaddingConstants from '../../../../common/constants/PaddingConstants'  // 内边距常量
import noSourceFind from '../../../../componets/common/noSourceFind'  // 无数据提示组件
import RefreshComponent from '../../../../componets/common/RefreshComponent'  // 刷新组件
import { BookSource } from '../../../../database/entities/BookSource'  // 书籍源实体
import BookFindContent from './BookFindContent'  // 书籍发现内容组件
import { JSON } from '@kit.ArkTS'  // JSON处理工具
import { ExploreRule } from '../../../../database/entities/rule'  // 探索规则实体
import { ExploreItem } from '../../../../database/types/BookSourceType'  // 探索项类型
import AllCategory, { GroupExploreList } from './AllCategory'  // 全部分类组件

/**
 * 内容刷新组件
 * @prop {BookSource} bookSource - 书籍源对象，包含exploreUrl等数据
 * @prop {number} currentIndex - 当前分类索引（小说/漫画/有声书）
 * @prop {boolean} hasExploreUrl - 是否有探索URL的全局状态
 * @prop {number} refreshCount - 刷新计数，触发数据重新加载
 */
@Component
export default struct ContentRefresh {
  // 底部安全区域高度，用于适配不同设备
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  // 刷新计数，带有@Watch监听，值变化时触发刷新
  @Link @Watch('onRefresh') refreshCount: number
  
  // 当前分类索引
  currentIndex: number = 0
  
  // 书籍源对象，由父组件传入
  @Prop bookSource: BookSource = {
    bookSourceUrl: '',
    bookSourceName: '',
    bookSourceType: 0,
    customOrder: 0,
    enabled: false,
    enabledExplore: false,
    lastUpdateTime: 0,
    respondTime: 0,
    weight: 0,
    isTop: false,
    showRecentIcon: false,
    showExplore: true
  }
  
  // 刷新状态 - true表示正在刷新
  @State isRefreshing: boolean = false
  
  // 刷新提示文字
  @State RefreshingTitle: string = '松开刷新'
  
  // 内部计数器，用于触发子组件刷新
  @State counter: number = 0
  
  // 是否有探索URL的状态，与全局状态同步
  @Link hasExploreUrl: boolean
  
  // 分页参数
  @State pageSize: number = 4      // 每页显示数量
  @State pageNum: number = 1       // 当前页码
  
  // 探索项数据
  @State groupExploreList: GroupExploreList[] = []  // 分组的探索项
  @State exploreList: ExploreItem[] = []            // 所有探索项
  @State showExploreList: ExploreItem[] = []        // 当前显示探索项
  
  // 探索规则
  @State exploreRule?: ExploreRule = {}
  
  // 底部弹窗显示状态
  @State showSheet: boolean = false

  /**
   * 组件即将出现时的生命周期方法
   * 触发时机：组件创建并即将渲染时
   * 功能：初始化组件数据，开始加载探索内容
   */
  aboutToAppear() {
    this.getList()
  }

  /**
   * 刷新事件处理函数
   * 触发时机：当refreshCount状态变化时（通过@Watch监听）
   * 功能：延迟500ms后重新加载数据，避免频繁刷新
   */
  onRefresh() {
    setTimeout(this.getList, 500)
  }

  /**
   * 获取探索内容列表的核心方法
   * 功能概述：解析书籍源的exploreUrl，获取探索项数据
   * 
   * 数据处理流程：
   * 1. 获取探索规则配置
   * 2. 解析书籍源的exploreUrl（JSON格式）
   * 3. 初始化分页参数
   * 4. 获取当前显示的探索项（分页）
   * 5. 对探索项进行分组，用于底部弹窗展示
   * 
   * 错误处理：
   * - 使用try-catch捕获JSON解析错误
   * - 记录错误日志，便于调试
   */
  getList () {
    try {
      this.exploreRule = this.bookSource.ruleExplore
      console.info('TagInfo: 书源地址：', this.bookSource.bookSourceUrl)
      console.info('TagInfo: 发现地址：', JSON.stringify(JSON.parse(this.bookSource.exploreUrl ?? '[]')))
      const exploreList = JSON.parse(this.bookSource.exploreUrl ?? '[]') as ExploreItem[]
      this.exploreList = exploreList
      this.pageNum = 1
      this.getShowExploreList()
      this.getGroupExploreList()
    } catch (err) {
      console.info('TagInfo', JSON.stringify(err))
    }
  }

  getGroupExploreList() {
    const groupMap: Record<string, GroupExploreList> = {};
    let currentTitle = ''
    this.exploreList.forEach((item: ExploreItem) => {
      if (!item.title.trim()) {
        return
      }
      if (item.style?.layout_flexBasisPercent === 1 || !currentTitle) {
        let keyTitle = item.title
        if (item.style?.layout_flexBasisPercent !== 1) {
          keyTitle = 'null'
        }
        groupMap[keyTitle] = {
          title: keyTitle,
          url: keyTitle === 'null' ? '' : item.url,
          columnsTemplate: '1fr',
          list: []
        };
        currentTitle = keyTitle
      }

      let columnsTemplate = '1fr'
      const flexBasis = item.style?.layout_flexBasisPercent ?? 0
      if (flexBasis > 0.33 && flexBasis <= 0.5) {
        columnsTemplate += ' 1fr'
      } else if (flexBasis >= 0.25 && flexBasis <= 0.33) {
        columnsTemplate += ' 1fr 1fr'
      } else if (flexBasis < 0.25) {
        columnsTemplate += ' 1fr 1fr 1fr'
      }
      if (groupMap[currentTitle].columnsTemplate !== columnsTemplate) {
        groupMap[currentTitle].columnsTemplate = columnsTemplate
      }
      groupMap[currentTitle].list.push(item);
    })
    this.groupExploreList = Object.values(groupMap);
    console.info('TagInfo:', JSON.stringify(this.groupExploreList))
  }

  getShowExploreList() {
    this.showExploreList = this.exploreList.filter(item =>!!item.url).slice(0, this.pageNum * this.pageSize)
  }

  /**
   * 组件UI构建方法
   * 根据是否有探索URL显示不同的内容
   * 
   * 两种状态：
   * 1. 无探索URL：显示noSourceFind组件，提供添加探索URL的入口
   * 2. 有探索URL：显示Refresh组件，支持下拉刷新和上滑加载更多
   * 
   * Refresh组件功能：
   * - 支持下拉刷新手势
   * - 支持上滑加载更多（分页）
   * - 显示刷新状态提示
   * - 绑定底部弹窗，显示全部分类
   */
  build() {
    // 判断是否有探索URL
    if (!this.bookSource.exploreUrl) {
      // 无探索URL状态：显示友好提示，引导用户添加
      noSourceFind({
        setOnclick: () => {
          // 点击时设置hasExploreUrl为true，触发相关操作
          this.hasExploreUrl = true
        }
      })
        .margin({
          top: PaddingConstants.PADDING_20  // 顶部内边距20px
        })
    } else {
      // 有探索URL状态：显示可刷新的内容列表
      Refresh({ 
        refreshing: $$this.isRefreshing,  // 双向绑定刷新状态
        builder: this.refreshComponent     // 自定义刷新组件
      }) {
        Scroll() {
          Column() {
            // 遍历当前显示的探索项，为每个项创建一个BookFindContent组件
            ForEach(this.showExploreList, (item: ExploreItem) => {
              BookFindContent({
                currentIndex: this.currentIndex,           // 当前分类索引
                bookSourceUrl: this.bookSource.bookSourceUrl,  // 书籍源URL
                exploreItem: item,                         // 当前探索项
                exploreRule: this.exploreRule,             // 探索规则
                counter: this.counter,                     // 刷新计数器
                handleClick: () => {
                  // 点击时显示底部弹窗（当前未实际使用）
                  this.showSheet = true
                }
              })
            })
          }
          .padding({ left: 16, right: 16 })  // 左右内边距16px
        }
        .padding({ bottom: 16 })  // 底部内边距16px
        .scrollBar(BarState.Off)  // 隐藏滚动条
        .onReachEnd(() => {
          // 上滑到底部时触发：加载下一页内容
          this.pageNum += 1
          this.getShowExploreList()
        })
      }
      .onStateChange((refreshStatus: RefreshStatus) => {
        // 刷新状态变化时更新提示文字
        if (refreshStatus === 1 || refreshStatus === 2) {
          this.RefreshingTitle = '松开刷新'
        } else {
          this.RefreshingTitle = '刷新中...'
        }
      })
      .height('100%')  // 高度占满父容器
      .onRefreshing(() => {
        // 下拉刷新触发时：重新加载数据
        setTimeout(() => {
          this.pageNum = 1  // 重置页码
          this.getShowExploreList()  // 重新获取显示列表
          this.counter++  // 增加计数器，触发子组件刷新
          this.isRefreshing = false  // 结束刷新状态
        }, 1000)  // 延迟1秒，提供更好的用户体验
      })
      .bindSheet(this.showSheet, this.bottomSheet(), {
        // 绑定底部弹窗配置
        detents: [SheetSize.FIT_CONTENT, SheetSize.LARGE, 200],  // 弹窗高度选项
        dragBar: true,     // 显示拖拽条
        showClose: false,  // 不显示关闭按钮
        onDisappear: () => {
          // 弹窗消失时重置状态
          this.showSheet = false
        }
      })
    }
  }

  /**
   * 构建自定义刷新组件
   * 用于在刷新时显示自定义的刷新UI
   * 
   * @returns {void} 构建刷新组件内容
   */
  @Builder
  refreshComponent() {
    RefreshComponent({
      RefreshingTitle: this.RefreshingTitle,  // 刷新提示文字
    })
  }

  /**
   * 构建底部弹窗内容
   * 显示全部分类，支持快速导航
   * 
   * @returns {void} 构建底部弹窗内容
   */
  @Builder
  bottomSheet() {
    Column() {
      AllCategory({
        showSheet: this.showSheet,                    // 弹窗显示状态
        bookSourceUrl: this.bookSource.bookSourceUrl,  // 书籍源URL
        exploreRule: this.exploreRule,                // 探索规则
        list: this.groupExploreList                   // 分组后的探索项列表
      })
    }
  }
}

/**
 * SearchDetails 组件 - 搜索详情页面组件
 * 
 * 功能概述：
 * 1. 显示搜索结果的完整页面，包含类型切换、筛选和书籍列表
 * 2. 提供下拉刷新功能，显示搜索结果统计信息
 * 3. 支持按书籍类型（小说、漫画、有声书）筛选结果
 * 4. 集成主题系统，支持动态主题颜色
 * 5. 监听搜索状态变化，动态更新UI
 * 
 * 设计特点：
 * 1. 分层布局：使用Column垂直排列类型切换、刷新指示器和书籍列表
 * 2. 状态管理：使用@Consume装饰器消费全局状态（搜索状态、书籍列表等）
 * 3. 响应式设计：根据底部矩形高度调整内边距
 * 4. 视觉反馈：搜索时显示顶部边框动画，刷新时显示进度指示器
 * 5. 类型切换：提供直观的类型切换界面，高亮当前选中类型
 * 
 * 使用场景：
 * 1. 搜索结果详情页面
 * 2. 需要按类型筛选搜索结果的场景
 * 3. 需要下拉刷新和状态指示的列表页面
 * 
 * 组件结构：
 * - 类型切换区域：小说、漫画、有声书类型切换和筛选按钮
 * - 刷新区域：下拉刷新组件，包含搜索结果统计
 * - 书籍列表区域：SearchBookList组件显示筛选后的书籍
 * 
 * 注意事项：
 * 1. 需要正确处理搜索状态的变化和刷新逻辑
 * 2. 类型切换需要与书籍列表筛选同步
 * 3. 主题颜色需要动态应用到各个UI元素
 */

import { SearchBookList } from './SearchBookList'
import { SearchBook } from '../../database/entities/SearchBook'
import { ThemeItem } from '../../common/model/Theme'
import { ThemeStorageKey } from '../../common/constants/Theme'

@Component
export struct SearchDetails{
  /**
   * 搜索关键词
   * @type {string}
   * @description 当前搜索的关键词
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop SearchValue:string
  
  /**
   * 刷新状态
   * @type {boolean}
   * @default false
   * @description 标识是否正在刷新中
   * @state 使用@State装饰器管理组件内部状态
   */
  @State isRefreshing: boolean = false
  
  /**
   * 计数器
   * @type {number}
   * @default 0
   * @description 通用计数器，用于各种计数需求
   * @state 使用@State装饰器管理组件内部状态
   */
  @State counter: number = 0
  
  /**
   * 类型列表
   * @type {string[]}
   * @default ["小说","漫画","有声书"]
   * @description 可选的书籍类型列表
   * @state 使用@State装饰器管理组件内部状态
   */
  @State typeList: string[] = ["小说","漫画","有声书"]
  
  /**
   * 当前类型索引
   * @type {number}
   * @default 0
   * @description 当前选中的类型索引（0:小说, 1:漫画, 2:有声书）
   * @state 使用@State装饰器管理组件内部状态
   */
  @State typeIndex:number=0
  
  /**
   * 搜索状态
   * @type {number}
   * @description 全局搜索状态，变化时触发refresh方法
   * @consume @watch 使用@Consume装饰器消费全局状态，@Watch监听变化
   */
  @Consume @Watch("refresh") SearchStatus:number
  
  /**
   * 搜索书籍列表
   * @type {SearchBook[]}
   * @description 全局搜索书籍列表数据
   * @consume 使用@Consume装饰器消费全局状态
   */
  @Consume('searchBookList') books:SearchBook[]
  
  /**
   * 搜索状态标识
   * @type {boolean}
   * @description 全局搜索进行中标识
   * @consume 使用@Consume装饰器消费全局状态
   */
  @Consume('isSearch') isSearch:boolean
  
  /**
   * 底部矩形高度
   * @type {number}
   * @default 0
   * @description 从存储中读取的底部矩形高度，用于布局计算
   * @storagelink 使用@StorageLink装饰器实现与存储的双向绑定
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /**
   * 主题配置
   * @type {ThemeItem}
   * @description 从存储中读取的主题配置
   * @storageprop 使用@StorageProp装饰器从存储中读取数据
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  /**
   * 刷新回调方法
   * @returns {void}
   * @description 监听SearchStatus变化，当状态大于2时触发刷新
   * 用于根据全局搜索状态更新本地刷新状态
   */
  refresh(){
    if(this.SearchStatus>2){
      this.isRefreshing=true // 触发刷新
    }
  }
  
  /**
   * 刷新组件构建器
   * @returns {void}
   * @description 构建下拉刷新时显示的组件
   * 包含加载进度条和搜索结果统计信息
   */
  @Builder RefreshComponent(){
    Stack(){
      Row(){
        LoadingProgress().color(this.theme.mainColor).height(26) // 主题色加载进度条
        Text("共搜索到"+this.books.length+"个相关结果") // 搜索结果统计
          .fontSize(14)
          .margin({left:20})
          .fontColor($r('app.string.color_black_45')) // 45%黑色
      }.alignItems(VerticalAlign.Center) // 垂直居中对齐
    }.width("100%").align(Alignment.Center) // 100%宽度，居中对齐
  }
  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建搜索详情页面的完整UI结构
   * 包含类型切换区域、刷新区域和书籍列表区域
   */
  build() {
    Column(){
      /**
       * 类型切换区域
       * @description 40px高度，包含类型切换和筛选按钮
       * 60%宽度用于类型切换，40%宽度用于筛选按钮
       */
      Row(){
        /**
         * 类型切换行
         * @description 显示小说、漫画、有声书三种类型，30px间距
         * 点击切换类型，当前选中类型显示黑色，其他显示45%黑色
         */
        Row({space:30}){
          ForEach(this.typeList,(item:string,index:number)=>{
              Text(item) // 类型文本
                .fontSize(16) // 16px字体
                .fontColor(this.typeIndex==index?"#000000":$r('app.string.color_black_45')) // 选中黑色，未选中45%黑色
                .onClick(()=>{
                  this.typeIndex=index // 点击切换类型
                })
          })
        }.width("60%").height("100%") // 60%宽度，100%高度
        
        /**
         * 筛选按钮行
         * @description 显示筛选图标和文本，5px间距
         * 右对齐，45%黑色
         */
        Row({space:5}){
          Image($r("app.media.screen")) // 筛选图标
            .width(20).height(20)
            .fillColor($r('app.string.color_black_45')) // 45%黑色
          Text("筛选") // 筛选文本
            .fontColor($r('app.string.color_black_45')) // 45%黑色
        }.width("40%").height("100%").justifyContent(FlexAlign.End) // 40%宽度，右对齐
      }.size({width:"100%",height:40}) // 100%宽度，40px高度
      .padding({left:20,right:20}) // 左右20px内边距
      .margin(10) // 10px外边距
      
      /**
       * 书籍列表区域
       * @description 下拉刷新组件包裹书籍列表
       * 120px偏移，100摩擦力，白色背景
       */
      Refresh({ 
        refreshing: $$this.isRefreshing, // 刷新状态绑定
        offset: 120, // 120px偏移
        friction: 100, // 100摩擦力
        builder:this.RefreshComponent // 刷新组件构建器
      }) {
        /**
         * 书籍列表组件
         * @description 显示筛选后的书籍列表
         * 传递搜索关键词、书籍列表、类型索引和搜索状态
         */
        SearchBookList({
          SearchValue:this.SearchValue,
          booksList:this.books,
          typeIndex:this.typeIndex,
          isSearch:this.isSearch
        }).backgroundColor("#ffffff") // 白色背景
      }
      /**
       * 顶部边框动画
       * @description 搜索时显示2px主题色顶部边框，作为加载动画
       * 使用主题主色，实线样式
       */
      .border({
        width: { top:this.isSearch?2:0 }, // 搜索时2px，否则0
        color:this.theme.mainColor // 主题主色
      })
      .borderStyle({
        top:BorderStyle.Solid, // 实线样式
      })
      .onStateChange((refreshStatus: RefreshStatus) => {
        // 刷新状态变化回调（预留）
      })
      .onRefreshing(() => {
        /**
         * 刷新回调
         * @description 刷新时触发，5秒后自动结束刷新
         * 模拟网络请求延迟
         */
        setTimeout(() => {
          this.isRefreshing = false // 5秒后结束刷新
        }, 5000)
      })
      .backgroundColor("rgba(0, 0, 0, 0.06)") // 6%黑色背景
    }
    .padding({
      bottom:this.bottomRectHeight // 底部内边距，适配底部导航
    })
    .layoutWeight(1) // 占用剩余空间
  }
  
  /**
   * 组件即将显示时的生命周期回调
   * @returns {void}
   * @description 组件初始化逻辑，当前为空实现
   */
  aboutToAppear(): void {
    // 初始化逻辑预留
  }
}

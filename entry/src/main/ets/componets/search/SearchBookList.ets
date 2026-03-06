
/**
 * SearchBookList 组件 - 搜索书籍列表组件
 * 
 * 功能概述：
 * 1. 显示搜索结果书籍列表，支持按类型筛选
 * 2. 实现列表懒加载和滚动控制，优化性能
 * 3. 提供搜索状态指示器（加载中、停止搜索按钮）
 * 4. 实现智能滚动按钮（返回浏览处/跳转到顶部）
 * 5. 集成主题系统，支持动态主题颜色
 * 
 * 设计特点：
 * 1. 列表优化：使用cachedCount实现懒加载，chainAnimation实现流畅动画
 * 2. 滚动控制：记录浏览位置，提供智能返回按钮
 * 3. 状态管理：管理搜索状态、滚动位置、列表偏移等
 * 4. 视觉反馈：提供搜索中指示器和停止搜索按钮
 * 5. 响应式布局：根据滚动位置动态显示/隐藏控制按钮
 * 
 * 使用场景：
 * 1. 搜索结果页面显示书籍列表
 * 2. 需要支持滚动浏览和位置记忆的列表
 * 3. 需要显示搜索状态和控制搜索过程的场景
 * 
 * 组件结构：
 * - 主列表：显示筛选后的书籍列表
 * - 搜索指示器：显示"搜索中..."状态
 * - 停止按钮：停止搜索任务
 * - 滚动控制按钮：返回浏览处或跳转到顶部
 * 
 * 注意事项：
 * 1. 需要正确处理列表滚动和位置记忆
 * 2. 搜索状态需要与任务管理同步
 * 3. 主题颜色需要动态应用到各个UI元素
 */

import { common } from '@kit.AbilityKit'
import { util } from '@kit.ArkTS'
import CommonConstants from '../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import taskSearchBooks from '../../common/model/taskSearchBook'
import { ThemeItem } from '../../common/model/Theme'
import { SearchBook } from '../../database/entities/SearchBook'
import { SearchBookItem } from './SearchBookItem'

@Component
export struct SearchBookList {
  /**
   * 搜索状态
   * @type {boolean}
   * @description 标识是否正在搜索中
   * @link 使用@Link装饰器实现与父组件的双向绑定
   */
  @Link isSearch:boolean
  
  /**
   * 懒加载缓存数
   * @type {number}
   * @default 5
   * @description 列表懒加载的缓存数量，优化性能
   * @state 使用@State装饰器管理组件内部状态
   */
  @State cachedCountNumber: number = 5;
  
  /**
   * 当前显示的首个索引
   * @type {number}
   * @default 0
   * @description 当前显示在屏幕上的第一个子组件索引，用于控制滚动按钮
   * @state 使用@State装饰器管理组件内部状态
   */
  @State firstIndex: number = 0;
  
  /**
   * 搜索关键词
   * @type {string}
   * @description 当前搜索的关键词
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop SearchValue:string
  
  /**
   * 标题列表
   * @type {string[]}
   * @default []
   * @description 预留的标题列表，用于未来功能扩展
   * @state 使用@State装饰器管理组件内部状态
   */
  @State titleLists:string[]=[]
  
  /**
   * 刷新状态
   * @type {boolean}
   * @default false
   * @description 标识列表是否正在刷新
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
   * 类型索引
   * @type {number}
   * @description 当前筛选的书籍类型索引
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop typeIndex:number
  
  /**
   * 书籍列表数据
   * @type {SearchBook[]}
   * @description 完整的书籍列表数据
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop booksList:SearchBook[]
  
  /**
   * 列表滚动控制器
   * @type {ListScroller}
   * @description 控制列表滚动的控制器实例
   */
  listScroller: ListScroller = new ListScroller();
  
  /**
   * 历史偏移量
   * @type {number}
   * @default 0
   * @description 上次浏览时列表距离顶端的偏移量
   */
  historyOffset: number = 0;
  
  /**
   * 默认偏移量
   * @type {number}
   * @default 0
   * @description 默认跳转位置，用于第一次进入页面
   * @readonly 只读常量
   */
  readonly DEFAULT_OFFSET: number = 0;
  
  /**
   * 动画持续时间
   * @type {number}
   * @default 500
   * @description 滚动动画的持续时间（毫秒）
   * @readonly 只读常量
   */
  readonly ANIMATION_DURATION: number = 500;
  
  /**
   * 按钮切换阈值
   * @type {number}
   * @default 5
   * @description 当前显示索引达到此阈值时，按钮从"返回浏览处"切换为"跳转到顶部"
   * @readonly 只读常量
   */
  readonly SWITCH_BUTTON: number = 5;
  
  /**
   * 列表偏移量Y
   * @type {number}
   * @default 0
   * @description 列表区域的Y轴偏移量
   * @state 使用@State装饰器管理组件内部状态
   */
  @State listOffsetY:number=0
  
  /**
   * 列表滚动器Y位置
   * @type {number}
   * @default 0
   * @description 列表滚动器的当前Y轴位置
   * @state 使用@State装饰器管理组件内部状态
   */
  @State listScrollerY:number = 0
  
  /**
   * 主题配置
   * @type {ThemeItem}
   * @description 从存储中读取的主题配置
   * @storageprop 使用@StorageProp装饰器从存储中读取数据
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建搜索书籍列表的完整UI结构
   * 包含主列表、搜索指示器、停止按钮和滚动控制按钮
   */
  build() {
    Column(){
      /**
       * 主书籍列表
       * @description 显示筛选后的书籍列表，8px间距
       * 使用ForEach渲染，按类型筛选
       */
      List({space:8,scroller:this.listScroller}){
        ForEach(this.booksList,(item:SearchBook,index)=>{
          if (item.bookType === this.typeIndex){ // 按类型筛选
            ListItem(){
              SearchBookItem({book:item,SearchValue:this.SearchValue,index:index}) // 渲染单个书籍项
            }
          }
        })
      }
      .onAreaChange((oldNumber,newNumber)=>{
        this.listOffsetY = newNumber.height as number // 监听区域变化，更新列表高度
      })
      .cachedCount(this.cachedCountNumber) // 设置懒加载缓存数
      .layoutWeight(1) // 占用剩余空间
      .chainAnimation(true) // 启用链式动画
      .scrollBar(BarState.Off) // 关闭滚动条
      .onScrollIndex((first: number) => {
        this.firstIndex = first; // 监听滚动索引变化
      })
      .onWillScroll(()=>{
        this.listScrollerY = this.listScroller.currentOffset().yOffset // 监听即将滚动，更新滚动位置
      })

      /**
       * 搜索中指示器
       * @description 显示"搜索中..."状态，右上角定位
       * 使用主题主色，搜索时显示
       */
      Row(){
        LoadingProgress() // 加载进度指示器
          .color(this.theme.mainColor) // 主题主色
          .width(30)
          .height(30)
        Text('搜索中...')
          .font({
            size:14,
            weight:500
          })
          .fontColor(this.theme.mainColor) // 主题主色
      }
      .visibility(this.isSearch?Visibility.Visible:Visibility.None) // 搜索时显示
      .position({ x: '95%', y: '0%'}) // 右上角定位
      .markAnchor({ x:'95%'}) // 锚点标记

      /**
       * 停止搜索按钮
       * @description 点击停止所有搜索任务，右下角定位
       * 使用主题主色，搜索时显示
       */
      Column({
        space:5
      }){
        Image($r('app.media.icon_search_stop')) // 停止图标
          .width(24).height(24)
          .fillColor(this.theme.mainColor) // 主题主色
        Text('停止')
          .font({
            size:14,
            weight:500
          })
          .fontColor(this.theme.mainColor) // 主题主色
      }
      .onClick(()=>{
        this.isSearch = false // 更新搜索状态
        taskSearchBooks.cancelAllTasks() // 取消所有搜索任务
      })
      .visibility(this.isSearch?Visibility.Visible:Visibility.None) // 搜索时显示
      .padding(10) // 内边距
      .position({ x: '95%', y: '80%'}) // 右下角定位
      .markAnchor({ x:'90%'}) // 锚点标记
      .opacity(0.8) // 80%透明度
      .borderRadius(8) // 8px圆角

      /**
       * 滚动控制按钮
       * @description 智能按钮：返回浏览处或跳转到顶部
       * 根据滚动位置和索引动态切换功能和显示
       */
      Column({
        space:CommonConstants.SPACE_6 // 使用常量定义的间距
      }){
        Image(this.firstIndex < this.SWITCH_BUTTON ?$r('app.media.icon_back') :$r('app.media.pip_to_top')) // 动态图标
          .width(12)
          .height(12)
          .fillColor('#FFF') // 白色填充
        Text(this.firstIndex < this.SWITCH_BUTTON ? '返回浏览处': '顶部') // 动态文本
          .font({
            size:14,
            weight:500
          })
          .fontColor('#fff') // 白色文字
      }
      .visibility(this.listScrollerY  > this.listOffsetY || this.historyOffset > 0 ?Visibility.Visible:Visibility.None) // 滚动时显示
      .padding(10) // 内边距
      .position({ x: '95%', y: '90%'}) // 右下角定位
      .markAnchor({ x:'90%'}) // 锚点标记
      .opacity(0.8) // 80%透明度
      .backgroundColor(this.theme.mainColor) // 主题主色背景
      .borderRadius(8) // 8px圆角
      .onClick(() => {
        /**
         * 按钮点击事件
         * @description 根据当前索引决定功能：
         * - 索引小于阈值：跳转到历史浏览位置
         * - 索引大于等于阈值：跳转到顶部，并记录当前位置
         */
        if (this.firstIndex < this.SWITCH_BUTTON) {
          // 跳转到历史浏览位置
          this.listScroller.scrollTo({
            xOffset: 0,
            yOffset: this.historyOffset === 0 ? this.DEFAULT_OFFSET : this.historyOffset, // 使用历史位置或默认位置
            animation: { duration: this.ANIMATION_DURATION, curve: Curve.LinearOutSlowIn } // 500ms动画，缓出缓入曲线
          });
        } else {
          this.historyOffset = this.listScroller.currentOffset().yOffset; // 记录当前位置
          this.listScroller.scrollTo({
            xOffset: 0,
            yOffset: 0, // 跳转到顶部
            animation: { duration: this.ANIMATION_DURATION, curve: Curve.LinearOutSlowIn } // 500ms动画，缓出缓入曲线
          });
        }
      })
    }
  }

  /**
   * 关键词分割方法
   * @param {string} key - 关键词
   * @param {string} str - 原始字符串
   * @returns {string[]} 分割后的字符串数组
   * @description 将字符串按关键词分割为三部分：关键词前、关键词、关键词后
   * 用于高亮显示搜索关键词
   */
  subKeyword(key:string,str:string):string[]{
    let start=str.indexOf(key) // 查找关键词起始位置
    if(start<0){
      return [str] // 未找到关键词，返回原字符串
    }
    let end=start+key.length // 计算关键词结束位置
    let key_start=str.substring(0,start) // 关键词前的部分
    let key_end=str.substring(end,str.length) // 关键词后的部分
    console.log(key_start+"---"+key_end); // 调试日志
    return [key_start,key,key_end] // 返回三部分数组
  }
  
  /**
   * 获取书籍列表数据
   * @returns {void}
   * @description 从rawfile目录读取book.json文件内容
   * 使用资源管理器获取原始文件，解码为字符串
   * 预留功能，当前为注释状态
   */
  getBookList(){
    let context=getContext() as common.UIAbilityContext; // 获取上下文
    let resourceManager=context.resourceManager // 获取资源管理器
    let values:string="" // 存储文件内容
    resourceManager.getRawFileContent("book.json", (error, value) => {
      if (error != null) {
        console.log("error is " + error); // 错误处理
      } else {
        let decoder = util.TextDecoder.create('utf-8',{ignoreBOM : true }) // 创建UTF-8解码器
        values = decoder.decodeWithStream(value,{stream:false}); // 解码文件内容
        // this.bookList=JSON.parse(values) // 预留：解析JSON数据
      }
    });
  }
}


/**
 * SearchBookItem 组件 - 搜索书籍列表项组件
 * 
 * 功能概述：
 * 1. 显示单个搜索结果的书籍信息，包括封面、书名、作者、简介等
 * 2. 支持点击跳转到书籍详情页面
 * 3. 根据搜索关键词高亮匹配的书名
 * 4. 显示书籍标签信息，如分类、字数等
 * 5. 集成主题系统，支持动态主题颜色
 * 
 * 设计特点：
 * 1. 水平布局：使用Row布局水平排列封面和书籍信息
 * 2. 响应式设计：固定高度120px，适配不同屏幕尺寸
 * 3. 视觉层次：清晰的视觉层次，突出书名和重要信息
 * 4. 交互反馈：点击跳转功能，使用防抖点击工具
 * 5. 主题集成：支持动态主题颜色，根据主题变化调整UI
 * 
 * 使用场景：
 * 1. 搜索结果列表中的单个书籍项
 * 2. 书籍推荐列表中的单个书籍项
 * 3. 需要显示书籍基本信息并支持跳转的场景
 * 
 * 组件结构：
 * - 封面图片：70x100px的书籍封面
 * - 书籍信息列：包含书名、作者、简介、标签等
 * - 标签构建器：可复用的标签显示组件
 * 
 * 注意事项：
 * 1. 需要正确处理书籍数据的空值情况
 * 2. 点击跳转需要传递完整的书籍信息
 * 3. 主题颜色需要动态更新
 */

import { SearchBook } from '../../database/entities/SearchBook'
import { router } from '@kit.ArkUI'
import clickUtil from '../../common/utils/ClickUtils'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'

@Component
export struct SearchBookItem {
  /**
   * 搜索关键词
   * @type {string}
   * @description 当前搜索的关键词，用于高亮匹配的书名
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop SearchValue:string
  
  /**
   * 书籍数据
   * @type {SearchBook}
   * @description 搜索到的书籍数据对象
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop book:SearchBook
  
  /**
   * 字体颜色
   * @type {string}
   * @default "rgba(0, 0, 0, 0.45)"
   * @description 次要信息的字体颜色，45%黑色
   * @state 使用@State装饰器管理组件内部状态
   */
  @State fontColor:string="rgba(0, 0, 0, 0.45)"
  
  /**
   * 索引位置
   * @type {number}
   * @description 在列表中的索引位置
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop index:number
  
  /**
   * 标签构建器
   * @param {string} item - 标签文本
   * @returns {void}
   * @description 构建书籍标签的UI组件
   * 10px字体，浅灰色背景，5px圆角
   */
  @Builder label(item:string){
    Text(item)
      .fontSize(10) // 10px字体
      .fontColor(this.fontColor) // 使用次要字体颜色
      .padding({left:7,right:7,top:3,bottom:3}) // 内边距
      .backgroundColor("rgba(0, 0, 0, 0.06)") // 6%黑色背景
      .borderRadius(5) // 5px圆角
  }
  
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
   * @description 构建搜索书籍列表项的完整UI结构
   * 包含封面、书籍信息和点击跳转功能
   */
  build() {
    Row({space:20}){ // 20px间距的水平布局
      /**
       * 书籍封面
       * @description 70x100px的书籍封面图片
       * 使用默认封面作为备用图片
       */
      Image(this.book.coverUrl).size({
        width:70, // 70px宽度
        height:100 // 100px高度
      })
        .alt($r('app.media.icon_book_default_cover_five')) // 备用图片
      
      /**
       * 书籍信息列
       * @description 垂直排列的书籍详细信息
       * 5px间距，左对齐
       */
      Column({space:5}){
        /**
         * 书名行
         * @description 显示书籍名称，根据搜索关键词高亮
         * 如果书名与搜索词匹配，使用主题主色，否则使用黑色
         */
        Row(){
          Text(this.book.name)
            .fontColor(this.SearchValue=== this.book.name ? this.theme.mainColor :"#000000")
        }
        
        /**
         * 作者及书源数量行
         * @description 显示作者和书源数量，2px间距
         * 14px字体，次要字体颜色
         */
        Row({space:2}){
          Text(this.book.author) // 作者名称
            .fontSize(14)
            .fontColor(this.fontColor)
          Text("·") // 分隔符
            .fontSize(14)
            .fontColor(this.fontColor)
          Text("共"+this.book.belongCount+"个源") // 书源数量
            .fontSize(14)
            .fontColor(this.fontColor)
        }

        /**
         * 书籍描述
         * @description 显示书籍简介，限制2行，省略号处理溢出
         * 200x40px固定尺寸，14px字体
         */
        Text(this.book.intro)
          .size({width:200,height:40}) // 固定尺寸
          .fontSize(14) // 14px字体
          .maxLines(2) // 最多2行
          .fontColor(this.fontColor) // 次要字体颜色
          .textOverflow({overflow:TextOverflow.Ellipsis}) // 溢出显示省略号
        
        /**
         * 标签行
         * @description 显示书籍分类和字数标签
         * 5px间距，100%宽度，20px高度
         */
        Row({space:5}){
          // ForEach(this.book.label,(item:string)=>{
          //   this.label(item) // 预留的标签循环（注释状态）
          // })
          this.label(this.book.kind??'') // 书籍分类标签
          this.label(this.book.wordCount??'') // 字数标签
        }.width("100%").height(20) // 100%宽度，20px高度
      }.alignItems(HorizontalAlign.Start) // 左对齐
    }
    /**
     * 点击事件
     * @description 点击跳转到书籍详情页面
     * 使用防抖点击工具防止快速重复点击
     */
    .onClick(()=>{
      clickUtil.preventClick(()=>{ // 防抖点击
        router.pushUrl({ // 路由跳转
          url: 'pages/view/BookDetailPage', // 目标页面
          params: { // 传递参数
            bookName: this.book.name, // 书名
            coverUrl: this.book.coverUrl, // 封面URL
            author: this.book.author, // 作者
            intro: this.book.intro, // 简介
            kind:this.book.kind, // 分类
            bookUrl:this.book.bookUrl, // 书籍URL
            wordCount:this.book.wordCount, // 字数
            bookType:this.book.bookType, // 书籍类型
            toUrl:this.book.tocUrl, // 目录URL
            source:this.book.source, // 书源
            sourceList:this.book.sourceList, // 书源列表
            origin:this.book.source?.bookSourceUrl, // 原始书源URL
            originName:this.book.source?.bookSourceName // 原始书源名称
          }
        })
      })
    })

    .size({
      width:"100%", // 100%宽度
      height:120 // 固定120px高度
    }).margin({left:20,right:20}) // 左右20px外边距
  }

}

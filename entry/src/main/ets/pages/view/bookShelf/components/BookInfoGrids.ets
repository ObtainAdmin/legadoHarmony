/**
 * 书籍信息宫格组件 - 在宫格模式下显示书籍信息
 * 
 * 功能概述：
 * 1. 以宫格形式显示书籍信息，包括封面、书名、简介、最近阅读章节
 * 2. 支持本地书籍和置顶书籍的标签显示
 * 3. 提供长按手势打开书籍信息对话框
 * 4. 支持点击跳转到书籍详情页面
 * 5. 集成删除确认对话框（当前为占位实现）
 * 
 * 显示特点：
 * - 封面图片：100x120尺寸，支持默认图片
 * - 本地书籍标签：右上角显示"本地"标签，棕色背景
 * - 置顶书籍标签：左下角显示"置顶"标签，半透明黑色背景
 * - 书籍信息：书名（最多2行）、自定义简介、最近阅读章节
 * 
 * 交互功能：
 * - 点击书籍：跳转到书籍详情页面，使用防抖处理
 * - 长按书籍：打开书籍信息对话框
 * - 删除功能：预留对话框（当前为占位实现）
 */

import confirmDialogExample from '../../../../componets/common/confirmDialog'
import { Books } from '../../../../database/entities/Books'
import { router } from '@kit.ArkUI'
import BookInfoDialogs from './dialog/BookInfoDialogs'
import CommonConstants from '../../../../common/constants/CommonConstants'
import FontConstants from '../../../../common/constants/FontConstants'
import clickUtil from '../../../../common/utils/ClickUtils'

/**
 * 书籍信息宫格组件结构体
 * 
 * 职责：
 * 1. 在宫格模式下显示单个书籍的详细信息
 * 2. 管理本地书籍和置顶书籍的标签显示
 * 3. 处理点击和长按手势交互
 * 4. 管理书籍信息对话框的显示
 * 5. 提供删除功能（当前为占位实现）
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 专为宫格模式设计，宽度固定为100px
 * - 支持多种交互方式
 * - 集成对话框组件
 */
@Component
export default struct BookInfoGrids{
  /** 书籍数据对象，由父组件传递 */
  @Prop book:Books

  /** 删除回调函数，当前为空实现，供未来扩展 */
  onDelete: () => void = () => {

  }
  
  /** 删除缓存状态，用于确认对话框 */
  @State delCache:boolean = false
  
  /** 删除确认对话框控制器，管理删除书籍的确认对话框（当前为占位实现） */
  bookInfoDel: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
      delCache:this.delCache,
      isShowCache:true
    }),
    cancel: this.exitApp,
    autoCancel: true,  // 点击外部自动取消
    alignment: DialogAlignment.Center,  // 居中对齐
    // offset: { dx: 0, dy: '-40%' },  // 垂直偏移（注释状态）
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25,  // 圆角半径
  })

  /** 取消删除操作的处理函数 */
  onCancel() {
    console.info('取消')
  }

  /** 确认删除操作的处理函数，调用onDelete回调 */
  onAccept() {
    this.onDelete()
  }

  /** 点击对话框外围取消的处理函数 */
  exitApp() {
    console.info('点外围取消')
  }


  /**
   * 构建书籍信息宫格组件UI的主要方法
   * 
   * 布局结构：
   * 1. Column布局作为根容器，垂直排列
   * 2. 顶部：Stack容器，包含封面图片和标签
   * 3. 底部：Column容器，包含书籍文字信息
   * 
   * 标签系统：
   * - 本地书籍标签：显示在封面右上角，棕色背景，浅黄色文字
   * - 置顶书籍标签：显示在封面左下角，半透明黑色背景，白色文字
   * 
   * 书籍信息：
   * - 书名：粗体显示，最多2行，超出显示省略号
   * - 自定义简介：灰色小字，单行省略
   * - 最近阅读章节：灰色小字，单行省略
   * 
   * 交互功能：
   * - 点击整个组件：跳转到书籍详情页面，使用防抖处理
   * - 长按整个组件：打开书籍信息对话框
   */
  build() {
    Column({
      space:8  // 子组件间距
    }) {
      // 顶部：封面和标签区域
      Stack(){
        // 本地书籍标签
        if (this.book.isLocalBook){
          Text('本地')
            .fontColor('#FFEDD4')  // 浅黄色文字
            .fontWeight(FontConstants.FONT_WEIGHT_400)
            .fontSize(9)
            .padding(3)
            .backgroundColor('#523000')  // 棕色背景
            .zIndex(1)  // 确保标签在图片上方
            .borderRadius({
              topRight: 6,
              bottomLeft: 6,  // 右上角和左下角圆角
            })
        }
        
        // 封面图片和置顶标签
        Stack(){
          // 置顶书籍标签
          if (this.book.isTop){
            Text('置顶')
              .fontColor(Color.White)
              .fontWeight(FontConstants.FONT_WEIGHT_400)
              .fontSize(9)
              .padding(3)
              .borderRadius(5)
              .backgroundColor('rgba(0, 0, 0, 0.45)')  // 半透明黑色背景
              .zIndex(1)  // 确保标签在图片上方
          }
          
          // 封面图片
          Image(this.book.coverUrl)
            .draggable(false)  // 禁止拖拽
            .alt($r('app.media.icon_book_default_cover_one'))  // 加载失败时的默认图片
            .width(100)
            .height(120)
        }
        .alignContent(Alignment.BottomStart)  // 置顶标签对齐到左下角
      }
      .alignContent(Alignment.TopEnd)  // 本地标签对齐到右上角
      .backgroundColor($r('app.string.color_black_45'))  // 浅灰色背景
      .borderRadius(10)  // 圆角
      
      // 底部：书籍文字信息
      Column({
        space:CommonConstants.SPACE_2  // 使用公共间距常量
      }){
        // 书名
        Text(this.book.bookName)
          .fontSize(15)
          .fontWeight(700)
          .textOverflow({
            overflow:TextOverflow.Ellipsis  // 超出显示省略号
          })
          .maxLines(2)  // 最多显示2行
        
        // 自定义简介
        Text(this.book.customIntro).fontSize(12).fontColor('rgb(174,174,174)')
          .textOverflow({
            overflow:TextOverflow.Ellipsis
          })
          .ellipsisMode(EllipsisMode.END)
          .fontWeight(500)
          .maxLines(1)  // 单行显示
        
        // 最近阅读章节
        Text(this.book.durChapterTitle).fontSize(12).fontColor('rgb(174,174,174)')
          .textOverflow({
            overflow:TextOverflow.Ellipsis
          })
          .ellipsisMode(EllipsisMode.END)
          .fontWeight(500)
          .maxLines(1)  // 单行显示
      }
      .width(100)  // 固定宽度，与封面图片对齐
      .alignItems(HorizontalAlign.Start)  // 左对齐
    }
    .alignItems(HorizontalAlign.Start)  // 整体左对齐
    .padding({ left:8,right:8,bottom:5,top:5 })  // 内边距
    .onClick(()=>{
      // 点击跳转到书籍详情页面，使用防抖处理
      clickUtil.preventClick(()=>{
        router.pushUrl({
          url: 'pages/view/BookDetailPage',
          params: this.book
        })
      })
    })
    .gesture(
      LongPressGesture({ repeat: false,duration:500 })  // 长按手势，持续500ms
        .onAction((event: GestureEvent) => {
            this.bookInfoDialog?.open()  // 打开书籍信息对话框
        }))
  }
  /** 书籍信息对话框控制器，管理长按时打开的书籍信息对话框 */
  bookInfoDialog: CustomDialogController | null = new CustomDialogController({
    builder: BookInfoDialogs({
      bookData:this.book,
      cancel: () => {
        this.exitDialog()  // 取消回调函数
      }
    }),
    cancel: this.exitDialog,  // 点击外围取消回调
    autoCancel: true,  // 点击外部自动取消
    width:'100%',  // 宽度100%
    alignment: DialogAlignment.Bottom,  // 底部对齐
    customStyle:true  // 使用自定义样式

  })
  
  /** 退出对话框方法，关闭书籍信息对话框 */
  exitDialog(){
    this.bookInfoDialog?.close()
  }
}

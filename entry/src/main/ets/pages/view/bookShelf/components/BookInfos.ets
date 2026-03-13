/**
 * 书籍信息列表组件 - 在列表模式下显示书籍信息
 * 
 * 功能概述：
 * 1. 以列表形式显示书籍信息，包括封面、书名、简介、最近阅读章节
 * 2. 支持本地书籍和置顶书籍的标签显示
 * 3. 提供长按手势打开书籍信息对话框
 * 4. 支持点击跳转到阅读页面（当前跳转到ReaderPage3）
 * 
 * 显示特点：
 * - 封面图片：60x80尺寸，支持默认图片
 * - 本地书籍标签：右上角显示"本地"标签，棕色背景
 * - 置顶书籍标签：左下角显示"置顶"标签，半透明黑色背景
 * - 书籍信息：书名（粗体）、简介（最多2行）、最近阅读章节（单行省略）
 * 
 * 交互功能：
 * - 点击书籍：跳转到阅读页面（ReaderPage3），当前屏蔽了书籍详情页跳转
 * - 长按书籍：打开书籍信息对话框
 * 
 * 注意：当前点击跳转暂时屏蔽了书籍详情页，直接跳转到阅读页面
 */

import { Books } from '../../../../database/entities/Books'
import { router } from '@kit.ArkUI'
import BookInfoDialogs from './dialog/BookInfoDialogs'
import FontConstants from '../../../../common/constants/FontConstants'

/**
 * 书籍信息列表组件结构体
 * 
 * 职责：
 * 1. 在列表模式下显示单个书籍的详细信息
 * 2. 管理本地书籍和置顶书籍的标签显示
 * 3. 处理点击和长按手势交互
 * 4. 管理书籍信息对话框的显示
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 专为列表模式设计，水平布局
 * - 支持多种交互方式
 * - 集成对话框组件
 */
@Component
export default struct BookInfos {
  /** 当前书籍类型索引：0-小说，1-漫画，2-有声书，由父组件传递 */
  @Prop currentIndex: number
  
  /** 书籍数据对象，由父组件传递 */
  @Prop book: Books
  
  /** 删除缓存状态，当前未使用，保留供未来扩展 */
  @State delCache: boolean = false
  
  /** 书籍信息对话框控制器，管理长按时打开的书籍信息对话框 */
  bookInfoDialog: CustomDialogController | null = new CustomDialogController({
    builder: BookInfoDialogs({
      bookData: this.book, 
      cancel: () => {
        this.exitDialog()  // 取消回调函数
      }
    }),
    cancel: this.exitDialog,  // 点击外围取消回调
    autoCancel: true,  // 点击外部自动取消
    width: '100%',  // 宽度100%
    alignment: DialogAlignment.Bottom,  // 底部对齐
    customStyle: true  // 使用自定义样式
  })

  /**
   * 构建书籍信息列表组件UI的主要方法
   * 
   * 布局结构：
   * 1. Flex布局作为根容器，两端对齐
   * 2. Row布局：水平排列封面和文字信息
   * 3. 左侧：Stack容器，包含封面图片和标签
   * 4. 右侧：Column容器，包含书籍文字信息
   * 
   * 标签系统：
   * - 本地书籍标签：显示在封面右上角，棕色背景，浅黄色文字
   * - 置顶书籍标签：显示在封面左下角，半透明黑色背景，白色文字
   * 
   * 书籍信息：
   * - 书名：粗体显示
   * - 简介：灰色小字，最多2行，超出显示省略号，宽度80%
   * - 最近阅读章节：灰色小字，单行省略
   * 
   * 交互功能：
   * - 点击整个组件：跳转到阅读页面（ReaderPage3）
   * - 长按整个组件：打开书籍信息对话框
   * 
   * 注意：当前点击跳转暂时屏蔽了书籍详情页，直接跳转到阅读页面
   */
  build() {
    Flex({
      alignItems: ItemAlign.Center, 
      justifyContent: FlexAlign.SpaceBetween  // 两端对齐
    }) {
      Row({
        space: 20  // 子组件间距
      }) {
        // 左侧：封面和标签区域
        Stack() {
          // 本地书籍标签
          if (this.book.isLocalBook) {
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
          Stack() {
            // 置顶书籍标签
            if (this.book.isTop) {
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
              .width(60)
              .height(80)
          }.alignContent(Alignment.BottomStart)  // 置顶标签对齐到左下角
        }.alignContent(Alignment.TopEnd)  // 本地标签对齐到右上角

        // 右侧：书籍文字信息
        Column({
          space: 12  // 子组件间距
        }) {
          // 书名
          Text(this.book.bookName).fontWeight(700)
          
          Column() {
            // 书籍简介
            Text(this.book.intro)
              .fontSize(12)
              .fontColor('rgb(174,174,174)')  // 灰色文字
              .textOverflow({
                overflow: TextOverflow.Ellipsis  // 超出显示省略号
              })
              .maxLines(2)  // 最多显示2行
              .fontWeight(500)
              .width('80%')  // 宽度80%，留出空间
            
            // 最近阅读章节
            Text(this.book.durChapterTitle)
              .fontSize(12)
              .fontColor('rgb(174,174,174)')  // 灰色文字
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
              .ellipsisMode(EllipsisMode.END)
              .fontWeight(500)
              .maxLines(1)  // 单行显示
          }.alignItems(HorizontalAlign.Start)  // 左对齐
        }.alignItems(HorizontalAlign.Start)  // 整体左对齐
      }
    }
    .onClick(() => { 
      // todo: 暂时屏蔽书籍详情页，直接跳转到阅读页面
      router.pushUrl({
        url: 'pages/view/Reader/ReaderPage3', 
        params: { bookData: this.book }
      })

      // 原书籍详情页跳转逻辑（注释状态）
      // clickUtil.preventClick(()=>{
      //   router.pushUrl({
      //     url: 'pages/view/BookDetailPage',
      //     params: this.book
      //   })
      // })
    })
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })  // 长按手势，持续500ms
        .onAction((event: GestureEvent) => {
          this.bookInfoDialog?.open()  // 打开书籍信息对话框
        }))
    .padding(10)  // 内边距
    .borderRadius(10)  // 圆角
  }

  /**
   * 退出对话框方法
   * 功能：关闭书籍信息对话框
   */
  exitDialog() {
    this.bookInfoDialog?.close()
  }
}

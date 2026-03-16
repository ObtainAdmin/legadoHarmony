/**
 * 书籍历史信息组件 - 显示单个浏览历史记录项
 * 
 * 功能概述：
 * 1. 显示单个书籍的浏览历史信息，包括封面、书名、简介、最近阅读章节
 * 2. 提供删除历史记录功能，支持确认对话框
 * 3. 支持加入/移出书架操作
 * 4. 点击书籍信息跳转到书籍详情页面
 * 5. 支持长按手势（当前注释状态，供未来扩展）
 * 
 * 数据转换：
 * 将BookHistory对象转换为Books对象，用于统一显示格式
 * 如果书籍已存在于书架，显示已加入状态
 * 
 * 交互功能：
 * - 点击书籍信息：跳转到书籍详情页面
 * - 点击删除按钮：打开确认对话框删除历史记录
 * - 点击书架按钮：加入或移出书架
 * - 长按手势：预留功能（当前注释状态）
 */

import confirmDialogExample from '../../../../componets/common/confirmDialog'
import { Books } from '../../../../database/entities/Books'
import { router } from '@kit.ArkUI'
import { showMessage } from '../../../../componets/common/promptShow'
import BookInfoDialogs from './dialog/BookInfoDialogs'
import booksUtil from '../../../../common/utils/booksUtils'
import { BookHistory } from '../../../../database/entities/BookHistory'
import bookHistoryUtils from '../../../../common/utils/BookHistoryUtils'
import clickUtil from '../../../../common/utils/ClickUtils'

/**
 * 书籍历史信息组件结构体
 * 
 * 职责：
 * 1. 显示单个书籍历史记录的详细信息
 * 2. 管理书籍数据的加载和转换
 * 3. 处理删除历史记录的交互
 * 4. 管理加入/移出书架的操作
 * 5. 提供跳转到书籍详情页面的功能
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 支持异步数据加载和转换
 * - 集成多种交互功能
 * - 使用对话框进行确认操作
 */
@Component
export default struct BookHistoryInfo {
  /** 书籍数据对象，用于显示书籍信息 */
  @State book: Books = new Books()
  
  /** 书籍历史记录数据，由父组件传递 */
  @Prop bookHistory: BookHistory
  
  /** 删除缓存状态，用于确认对话框 */
  @State delCache: boolean = false
  
  /** 书籍历史刷新标记，存储在应用存储中，删除历史记录后触发刷新 */
  @StorageLink('BOOK_IS_BOOK_HISTORY_REFRESHING') isBookHistoryRefreshing: number = 0

  /**
   * 组件即将出现时的生命周期方法
   * 功能：加载书籍数据
   * 逻辑：
   * 1. 如果bookHistory.id存在，尝试从数据库获取完整书籍信息
   * 2. 如果获取成功，使用数据库中的书籍数据
   * 3. 如果获取失败，将BookHistory转换为Books对象，并标记为未加入书架
   */
  async aboutToAppear(): Promise<void> {
    if (this.bookHistory.id) {
      let bookInfo = await booksUtil.getBookByIds(this.bookHistory.id)
      if (bookInfo && bookInfo[0]) {
        this.book = bookInfo[0]
      } else {
        this.book = this.mergeBookHistoryToBooks(this.bookHistory)
        this.book.isJoin = false
      }
    }
  }

  /**
   * 将BookHistory对象转换为Books对象
   * 功能：通过JSON序列化和反序列化实现对象转换
   * @param history BookHistory对象
   * @returns 转换后的Books对象
   * 
   * 注意：这种方法会丢失Books特有的方法，只保留数据属性
   */
  mergeBookHistoryToBooks(history: BookHistory): Books {
    // 将 `BookHistory` 和 `Books` 对象转换为 JSON
    return JSON.parse(JSON.stringify(history)) as Books;
  }

  /**
   * 构建书籍历史信息组件UI的主要方法
   * 
   * 布局结构：
   * 1. Flex布局作为根容器，两端对齐
   * 2. 左侧：书籍信息区域（封面、书名、简介、最近阅读章节）
   * 3. 右侧：操作按钮区域（删除按钮、书架按钮）
   * 
   * 左侧区域：
   * - 封面图片：60x80尺寸，支持默认图片
   * - 书籍名称：粗体显示
   * - 书籍简介：灰色小字，单行省略
   * - 最近阅读章节：灰色小字，单行省略
   * 
   * 右侧区域：
   * - 删除按钮：垃圾桶图标，点击打开确认对话框
   * - 书架按钮：根据isJoin状态显示不同图标和样式
   * 
   * 交互功能：
   * - 点击书籍信息：跳转到书籍详情页面
   * - 点击删除按钮：打开确认对话框
   * - 点击书架按钮：加入或移出书架
   * - 长按手势：预留功能（当前注释状态）
   */
  build() {
    Flex(
      {
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.SpaceBetween
      }
    ) {
      // 左侧：书籍信息区域
      Row({
        space: 20
      }) {
        // 封面图片
        Stack() {
          Image(this.book.coverUrl ?? '')
            .draggable(false)
            .alt($r('app.media.icon_book_default_cover_one'))  // 加载失败时的默认图片
            .width(60)
            .height(80)
        }.alignContent(Alignment.BottomStart)

        // 书籍文字信息
        Column({
          space: 24
        }) {
          // 书籍名称
          Text(this.book.bookName)
            .fontWeight(700)
          
          Column() {
            // 书籍简介
            Text(this.book.intro)
              .fontSize(12)
              .fontColor('rgb(174,174,174)')
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
              .ellipsisMode(EllipsisMode.END)
              .fontWeight(500)
              .maxLines(1)
            
            // 最近阅读章节
            Text(`最近阅读章节:${this.book.durChapterTitle}`)
              .fontSize(12)
              .fontColor('rgb(174,174,174)')
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
              .ellipsisMode(EllipsisMode.END)
              .fontWeight(500)
              .maxLines(1)
          }
          .width('40%')
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .onClick(() => {
          // 点击书籍信息跳转到详情页面，使用防抖处理
          clickUtil.preventClick(() => {
            router.pushUrl({
              url: 'pages/view/BookDetailPage',
              params: this.book
            })
          })
        })
      }

      // 右侧：操作按钮区域
      Column({ space: 15 }) {
        // 删除按钮
        Row() {
          Image($r('app.media.delete_svg')).width(17).fillColor('rgba(0, 0, 0, 0.6)')
        }
        .onClick(() => {
          if (this.bookInfoDel != null) {
            this.bookInfoDel.open()  // 打开删除确认对话框
          }
        })
        .padding({ right: 5 })

        // 书架按钮
        Row() {
          Row({ space: 5 }) {
            // 根据isJoin状态显示不同图标
            Image(this.book.isJoin ? $r("app.media.add_check") : $r("app.media.add_shelf"))
              .width(this.book.isJoin ? 15 : 10)
              .height(this.book.isJoin ? 15 : 10)
              .fillColor('rgba(0, 0, 0, 0.9)')
            Text('书架').fontSize(10).fontColor('rgba(0, 0, 0, 0.45)')
          }
          .padding({
            left: 15,
            right: 15,
            bottom: 5,
            top: 5
          })
        }
        .backgroundColor(this.book.isJoin ? 'rgba(174,174,174,0.2)' : '')  // 已加入书架显示灰色背景
        .borderColor('rgb(174,174,174)')
        .borderWidth(this.book.isJoin ? 0 : 1)  // 未加入书架显示边框
        .borderRadius(50)
        .onClick(() => {
          // 加入/移出书架逻辑
          if (!this.book.isJoin) {
            this.book.id = undefined
            booksUtil.addBooks(this.book)
            showMessage('加入书架成功')
            this.book.isJoin = true
            return
          }
          this.bookHistory.originBookId ? booksUtil.delBooksById(this.bookHistory.originBookId) : ''
          this.book.isJoin = false
          showMessage('移出书架成功')
        })
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.End)
    }
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction((event: GestureEvent) => {
          // this.bookInfoDialog?.open()  // 预留长按功能（当前注释状态）
        }))
    .padding(10)
    .borderRadius(10)
  }

  // 书籍信息对话框（当前注释状态，供未来扩展）
  // bookInfoDialog: CustomDialogController | null = new CustomDialogController({
  //   builder: BookInfoDialogs({
  //     bookData:this.book,
  //     cancel: () => {
  //       this.exitDialog()
  //     }
  //   }),
  //   cancel: this.exitDialog,
  //   autoCancel: true,
  //   width:'100%',
  //   alignment: DialogAlignment.Bottom,
  //   customStyle:true
  // })
  
  // 退出对话框方法（当前注释状态，供未来扩展）
  // exitDialog(){
  //   this.bookInfoDialog?.close()
  // }

  /** 删除确认对话框控制器，管理删除历史记录的确认对话框 */
  bookInfoDel: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      confirm: () => {
        this.onAccept()  // 确认回调函数
      },
      delCache: this.delCache,
      isShowCache: true
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    gridCount: 4,
    customStyle: false,
    cornerRadius: 25,
  })

  async onAccept() {
    if (this.bookHistory.id) {
      let result = await bookHistoryUtils.deleteBookHistory(this.bookHistory.id)
      this.isBookHistoryRefreshing++
      showMessage(result ? '删除成功' : '删除失败')
    }
  }
}
/**
 * @file ReadShow.ets
 * @description 上次阅读弹窗组件
 * 
 * 功能概述：
 * 1. 显示用户上次阅读的书籍信息
 * 2. 提供快速继续阅读的功能
 * 3. 从数据库获取阅读历史记录
 * 4. 支持关闭弹窗操作
 * 
 * 使用场景：
 * - 应用启动时显示上次阅读记录
 * - 用户返回首页时提示继续阅读
 * - 需要快速跳转到上次阅读位置的场景
 * 
 * 设计特点：
 * - 使用Flex布局实现复杂对齐
 * - 从数据库异步加载阅读历史
 * - 支持主题颜色配置
 * - 使用防抖点击工具防止重复点击
 * 
 * 数据流程：
 * 1. 组件初始化时调用aboutToAppear
 * 2. 异步获取阅读历史记录（最近一条）
 * 3. 根据书籍ID获取完整的书籍信息
 * 4. 渲染书籍封面、名称和章节信息
 * 
 * 交互特点：
 * - 点击"继续阅读"：跳转到书籍详情页
 * - 点击关闭图标：隐藏弹窗
 * - 使用防抖点击防止快速重复操作
 * 
 * 样式特点：
 * - 背景色：固定的棕色（rgb(182,134,102)）
 * - 圆角：10px
 * - 宽度：95%父容器宽度
 * - 内边距：10px
 * 
 * @note 这是一个条件渲染组件，只在有阅读历史时显示
 */

import booksUtil from '../../common/utils/booksUtils'
import bookHistoryDao from '../../database/dao/BookHistoryDao'
import { BookHistory } from '../../database/entities/BookHistory'
import { Books } from '../../database/entities/Books'
import { router } from '@kit.ArkUI'
import clickUtil from '../../common/utils/ClickUtils'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'

/**
 * @class ReadShow
 * @description 上次阅读弹窗组件
 * 
 * 组件职责：
 * 1. 管理阅读历史数据的获取和显示
 * 2. 处理用户继续阅读和关闭弹窗的操作
 * 3. 应用主题颜色配置
 * 4. 条件渲染（只在有数据时显示）
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct ReadShow {
  /** 
   * @link showReadShow - 弹窗显示状态
   * @description 控制弹窗显示/隐藏的双向绑定状态
   * @type {boolean}
   */
  @Link showReadShow:boolean
  
  /** 
   * @state bookHistory - 阅读历史记录
   * @description 存储从数据库获取的阅读历史记录数组
   * @default [] - 默认空数组
   * @type {BookHistory[]}
   */
  @State bookHistory:BookHistory[] = []
  
  /** 
   * @state book - 书籍信息
   * @description 存储完整的书籍信息对象
   * @default new Books() - 默认新的Books对象
   * @type {Books}
   */
  @State book:Books = new Books()

  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method aboutToAppear
   * @description 组件即将显示时的生命周期方法
   * 
   * 功能说明：
   * 1. 在组件显示前调用
   * 2. 初始化数据：获取阅读历史记录
   * 
   * 调用时机：
   * - 组件首次渲染前
   * - 组件从隐藏变为显示时
   * 
   * @returns {void}
   */
  aboutToAppear(): void {
    this.getBookHistoryList()
  }
  
  /**
   * @method getBookHistoryList
   * @description 获取阅读历史记录列表
   * 
   * 功能说明：
   * 1. 从数据库获取最近的阅读历史记录
   * 2. 如果有记录，根据书籍ID获取完整的书籍信息
   * 3. 更新组件状态：bookHistory和book
   * 
   * 数据流程：
   * 1. 调用bookHistoryDao.searchLimit()获取最近记录
   * 2. 检查是否有有效记录（长度>=1且有id）
   * 3. 调用booksUtil.getBookByIds()获取书籍详情
   * 4. 更新this.book状态
   * 
   * 异步操作：
   * - 使用async/await处理数据库异步查询
   * - 错误处理：通过条件判断防止空指针
   * 
   * 数据库查询：
   * - searchLimit(): 获取限制数量的历史记录（可能是最近一条）
   * - getBookByIds(): 根据ID获取书籍信息
   * 
   * @returns {Promise<void>}
   */
  async getBookHistoryList(){
   this.bookHistory =  await bookHistoryDao.searchLimit()
    if (this.bookHistory.length >= 1 && this.bookHistory[0].id) {
      let bookInfo = await booksUtil.getBookByIds(this.bookHistory[0].id)
      if (bookInfo && bookInfo[0]) {
        this.book = bookInfo[0]
      }
    }
  }
  
  /**
   * @method build
   * @description 构建上次阅读弹窗UI
   * 
   * 条件渲染：
   * - 只在this.bookHistory[0]和this.book都存在时渲染
   * - 否则不显示任何内容
   * 
   * 布局结构：
   * 1. 外层Column：整体容器，设置背景色、圆角、内边距
   * 2. 内层Flex：主要内容区域，使用Flex布局
   *   - 左侧：书籍封面图片
   *   - 中间：书籍信息区域（Column）
   *     * 书籍名称
   *     * 当前阅读章节
   *   - 右侧：操作区域（Column）
   *     * 继续阅读按钮
   *     * 关闭图标
   * 
   * 书籍封面样式：
   * - 尺寸：40x52px
   * - 默认图片：icon_book_default_cover_one
   * - 不可拖动：draggable(false)
   * 
   * 书籍信息样式：
   * - 书籍名称：12px白色字体
   * - 章节标题：12px白色字体，500字重
   * - 文本溢出：省略号显示，最大1行
   * - 间距：24px垂直间距
   * - 对齐：左对齐
   * 
   * 继续阅读按钮样式：
   * - 文字："继续阅读"，12px字体，600字重
   * - 颜色：主题主色文字，白色背景
   * - 内边距：10px
   * - 圆角：20px（胶囊按钮）
   * - 点击事件：跳转到书籍详情页
   * 
   * 关闭图标样式：
   * - 图标：outlined资源
   * - 尺寸：15x15px
   * - 点击事件：切换showReadShow状态
   * 
   * 交互逻辑：
   * 1. 继续阅读按钮：
   *   - 使用clickUtil.preventClick防抖
   *   - 跳转到BookDetailPage页面
   *   - 传递book对象作为参数
   * 
   * 2. 关闭图标：
   *   - 切换showReadShow状态
   *   - 输出状态到控制台（调试用）
   * 
   * 容器样式：
   * - 背景色：固定的棕色（rgb(182,134,102)）
   * - 圆角：10px
   * - 宽度：95%父容器宽度
   * - 内边距：10px
   * - 对齐：左对齐
   * 
   * Flex布局配置：
   * - alignItems: ItemAlign.Center - 垂直居中对齐
   * - alignContent: FlexAlign.SpaceBetween - 内容两端对齐
   * - layoutWeight: 1 - 中间区域占据剩余空间
   * 
   * 设计理念：
   * - 提供快速继续阅读的便捷入口
   * - 使用醒目的颜色吸引用户注意
   * - 简洁的信息展示：封面、书名、章节
   * - 提供关闭选项，不强制用户操作
   * 
   * @returns {void}
   */
  build() {
    if (this.bookHistory[0] && this.book){
      Column(){
        Flex(
          {
            alignItems:ItemAlign.Center,
            alignContent:FlexAlign.SpaceBetween
          }
        ) {
          Image(this.bookHistory[0].coverUrl??'')
            .draggable(false)
            .alt($r('app.media.icon_book_default_cover_one')).width(40).height(52)
          Column({
            space:24
          })
          {
            Text(this.bookHistory[0].bookName)
              .fontSize(12)
              .fontColor(Color.White)
            Column(){
              Text(this.bookHistory[0].durChapterTitle).fontSize(12).fontColor(Color.White)
                .textOverflow({
                  overflow:TextOverflow.Ellipsis
                })
                .ellipsisMode(EllipsisMode.END)
                .fontWeight(500)
                .maxLines(1)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .padding({left:15})
          Column(){
            Text('继续阅读')
              .fontSize(12)
              .fontWeight(600)
              .padding(10)
              .borderRadius(20)
              .fontColor(this.theme.mainColor)
              .backgroundColor(Color.White)
          }
          .padding({left:55,right:30})
          .onClick(()=>{
            clickUtil.preventClick(()=>{
              router.pushUrl({
                url: 'pages/view/BookDetailPage',
                params: this.book
              })
            })
          })

          Image($r("app.media.outlined")).width(15).height(15)
            .onClick(() => {
              this.showReadShow = !this.showReadShow
              console.log(this.showReadShow + '')
            })
        }
        .borderRadius(10)
      }
      .alignItems(HorizontalAlign.Start)
      .borderRadius(10)
      .padding(10)
      .width('95%')
      .backgroundColor('rgb(182,134,102)')
    }
  }
}

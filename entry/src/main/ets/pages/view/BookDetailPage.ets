/**
 * 书籍详情页面 - 显示书籍详细信息、目录、笔记和阅读记录
 * 
 * 功能概述：
 * 1. 展示书籍封面、标题、作者、标签等基本信息
 * 2. 显示阅读记录（阅读进度、天数、重读次数）
 * 3. 提供目录浏览和搜索功能
 * 4. 显示书籍简介和笔记
 * 5. 支持加入书架和立即阅读操作
 * 6. 管理书籍目录数据的加载和显示
 * 
 * 页面结构：
 * - 顶部导航栏：返回按钮、页面标题、编辑/分享/更多功能
 * - 书籍信息区：封面、标题、作者、标签
 * - 阅读记录区：阅读进度、天数、重读次数
 * - 书籍简介区：书籍描述文字
 * - 底部面板：目录/书源/笔记标签页，加入书架/立即阅读按钮
 * 
 * 数据流：
 * 通过路由参数接收Books对象 → 初始化书籍数据 → 加载目录信息 → 渲染页面
 */

import CommonConstants from '../../common/constants/CommonConstants'
import ReadRecordItem from '../../componets/bookDetail/ReadRecordItem'
import TagIndex from '../../componets/bookDetail/TagIndex'
import { router, SwipeRefresher } from '@kit.ArkUI'
import NoteIndex from '../../componets/bookDetail/note/NoteIndex'
import { FileHandler } from '../../common/utils/FileHandler'
import { Books } from '../../database/entities/Books'
import { BookHistory } from '../../database/entities/BookHistory'
import bookHistoryUtils from '../../common/utils/BookHistoryUtils'
import booksUtil from '../../common/utils/booksUtils'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'
import { bookParser } from '@kit.ReaderKit'

/**
 * 标题图片样式扩展函数
 * 
 * 功能：为导航栏中的图标提供统一的样式
 * 样式特点：
 * - 白色填充颜色
 * - 使用常量定义的统一尺寸
 * - 应用于返回、编辑、分享、更多等导航图标
 * 
 * 使用场景：页面顶部导航栏中的所有图标
 */
@Extend(Image)
function titleImageStyle() {
  .fillColor(Color.White).width(CommonConstants.TITLE_IMG_SIZE).height(CommonConstants.TITLE_IMG_SIZE)
}

/**
 * 分割线样式扩展函数
 * 
 * 功能：为阅读记录区域的分割线提供统一样式
 * 样式特点：
 * - 垂直方向
 * - 0.5像素宽度，24像素高度
 * - 半透明白色（#40ffffff）
 * 
 * 使用场景：阅读记录项之间的分隔线
 */
@Extend(Divider)
function recordDividerStyle() {
  .vertical(true).width(0.5).height(24).color('#40ffffff')
}

/**
 * 加入书架成功提示对话框
 * 
 * 功能：在用户成功将书籍加入书架时显示提示信息
 * 显示内容：
 * - 成功图标
 * - "加入书架成功"文字提示
 * - "移入分组"操作按钮（橙色文字）
 * 
 * 设计特点：
 * - 深色背景（#333333）
 * - 固定高度56像素
 * - 全屏宽度
 * - 圆角8像素（在控制器中设置）
 * 
 * 触发时机：用户点击"加入书架"按钮后
 */
@CustomDialog
struct AddBookShelfDialog {
  /** 对话框控制器，用于控制对话框的显示和隐藏 */
  controller?: CustomDialogController;

  build() {
    Row() {
      // 成功图标
      Image($r('app.media.ic_public_confirm')).width(24).height(24).fillColor('#FFFFFF')
      
      // 成功提示文字
      Text('加入书架成功').fontSize(14).fontWeight(400).lineHeight(22).fontColor('#FFFFFF')
      
      // 空白区域，用于分隔左右内容
      Blank()
      
      // 移入分组操作按钮
      Text('移入分组').fontSize(14).fontWeight(400).lineHeight(22).fontColor('#FF9500')
    }
    .height(56)
    .width(CommonConstants.FULL_WIDTH)
    .padding({
      left: 20,
      right: 20,
      top: 16,
      bottom: 16
    })
    .backgroundColor('#333333')
  }
}

@Entry
@Component
struct BookDetailPage {
  /**
   * 书籍详情页面结构体
   * 
   * 职责：
   * 1. 展示书籍的完整信息
   * 2. 管理书籍目录数据的加载和显示
   * 3. 处理加入书架和立即阅读操作
   * 4. 管理底部面板的显示和交互
   * 5. 记录阅读历史
   * 
   * 数据来源：
   * - 通过路由参数传递的Books对象
   * - 从书籍文件解析的目录数据
   * - 用户阅读记录
   */
  /** 控制底部面板的显示状态 */
  @State isShow: boolean = true;
  
  /** 当前选中的标签页索引：0-目录，1-书源，2-笔记 */
  @State currentIndex: number = 0;
  
  /** 标记是否已加入书架，用于控制对话框显示 */
  @State isAddBookShelf: boolean = false;
  
  /** 书籍数据，从路由参数获取 */
  @State bookData: Books = router.getParams() as Books
  
  /** 加入书架成功对话框控制器 */
  dialogController: CustomDialogController = new CustomDialogController({
    builder: AddBookShelfDialog(),  // 使用自定义对话框结构体
    cornerRadius: 8,                // 圆角8像素
    offset: { dx: 0, dy: -100 },    // 垂直向上偏移100像素
    gridCount: 4,                   // 网格数量
    customStyle: false,             // 不使用自定义样式
  })
  
  /** 书籍目录列表，从书籍文件解析得到 */
  @State CatalogList: bookParser.CatalogItem[] = [];
  
  /** 应用主题配置，从应用存储中读取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /** 书架刷新标记，用于触发书架页面刷新 */
  @StorageLink('BOOK_IS_BOOK_REFRESHING') isBookRefreshing: number = 0

  /**
   * 页面显示时调用的生命周期方法
   * 
   * 功能：显示底部面板，准备页面交互
   */
  onPageShow() {
    this.isShow = true
  }

  /**
   * 组件即将出现时调用的生命周期方法
   * 
   * 功能：
   * 1. 从路由参数获取书籍数据
   * 2. 检查书籍是否已加入书架
   * 3. 初始化书籍目录数据
   * 
   * 异步操作：检查书架存在性和加载目录都是异步操作
   */
  async aboutToAppear() {
    if (router.getParams() as Books) {
      // 从路由参数获取书籍数据
      this.bookData = router.getParams() as Books
      
      // 检查书籍是否已加入书架（如果未标记则进行查询）
      if (!this.bookData.isJoin) {
        this.bookData.isJoin = await booksUtil.isExistBooks(this.bookData.bookUrl, this.bookData.bookName)
      }
      
      // 初始化书籍目录数据
      this.initUrlBook()
    }
  }

  /**
   * 初始化书籍目录数据
   * 
   * 功能：根据书籍URL获取书籍解析器，并加载目录列表
   * 
   * 实现步骤：
   * 1. 获取书籍文件路径
   * 2. 创建书籍解析器处理器
   * 3. 从处理器获取目录列表
   * 
   * 异步操作：书籍解析可能需要时间，特别是对于大型文件
   */
  async initUrlBook() {
    let path = this.bookData.bookUrl
    // 获取书籍解析器处理器
    let bookParserHandler: bookParser.BookParserHandler = await bookParser.getDefaultHandler(path);
    // 获取目录列表并更新状态
    this.CatalogList = bookParserHandler.getCatalogList();
  }

  /**
   * 加入书架功能
   * 
   * 功能：将当前书籍添加到用户书架中
   * 
   * 操作流程：
   * 1. 调用工具函数将书籍添加到数据库
   * 2. 打开成功提示对话框
   * 3. 1秒后自动关闭对话框
   * 4. 触发书架刷新标记更新
   * 
   * 设计考虑：对话框显示1秒后自动关闭，避免干扰用户操作
   */
  addBookShelf() {
    // 将书籍添加到书架数据库
    booksUtil.addBooks(this.bookData)
    
    // 打开成功提示对话框
    this.dialogController.open();
    this.isAddBookShelf = true;
    
    // 1秒后自动关闭对话框并触发书架刷新
    setTimeout(() => {
      this.isBookRefreshing++  // 触发书架页面刷新
      this.dialogController.close();
    }, 1000);
  }

  /**
   * 构建底部面板的Builder函数
   * 
   * 功能：创建包含目录、书源、笔记三个标签页的底部面板
   * 
   * 面板结构：
   * 1. 顶部：目录搜索框
   * 2. 中部：标签页内容区域（目录列表/书源加载/笔记组件）
   * 3. 底部：加入书架和立即阅读按钮
   * 
   * 交互功能：
   * - 目录点击跳转到阅读器
   * - 标签页切换
   * - 加入书架/立即阅读操作
   */
  @Builder
  catalogPanel() {
    Column() {
      Search({ placeholder: '搜索目录' }).height(34).padding({ top: 8, bottom: 8 })
      Tabs({ index: this.currentIndex, barPosition: BarPosition.Start }) {
        TabContent() {
          Column() {
            List() {
              ForEach(this.CatalogList, (item: bookParser.CatalogItem, index: number) => {
                ListItem() {
                  Button({ type: ButtonType.Normal }) {
                    Row() {
                      Text(`${item.catalogName}`.replace(new RegExp('\\s{1,}', 'g'), ' ').replaceAll('=', ''))
                        .layoutWeight(1)
                    }.width('100%').padding({
                      left: 20,
                      right: 20,
                      top: 12,
                      bottom: 12
                    })
                  }.borderRadius(10).width('100%').backgroundColor(Color.White).onClick(() => { // 跳转到阅读器
                    // this.jumpReadPage(`${item.catalogName}`, index)
                    router.pushUrl({
                      url: 'pages/view/Reader/ReaderPage3',
                      params: { bookData: this.bookData, clickBookCatalogId: item.catalogId }
                    })
                  })
                }
              })
            }.chainAnimation(true).edgeEffect(EdgeEffect.Fade).divider({
              strokeWidth: 0.8,
              color: '#cccccc',
              startMargin: 12,
              endMargin: 12
            })
          }
        }.tabBar(this.catalogTab(0, '目录', this.CatalogList.length))

        TabContent() {
          Column() {
            SwipeRefresher({
              content: '书源加载中...', isLoading: true
            })
          }
        }.tabBar(this.catalogTab(1, '书源', 24))

        TabContent() {
          NoteIndex()
        }.tabBar(this.catalogTab(2, '笔记', 7))
      }.layoutWeight(1).onChange((index: number) => {
        this.currentIndex = index;
      })

      Row({ space: 20 }) {
        Button(this.bookData.isJoin ? '已加书架' : '加入书架')
          .padding({
            left: 32,
            right: 32,
            top: 8,
            bottom: 8
          })
          .width(150)
          .height(40)
          .borderRadius(200)
          .backgroundColor(this.theme.secondColor)
          .fontColor(this.theme.mainColor)
          .onClick(() => {
            !this.bookData.isJoin ? this.addBookShelf() : ''
          })
        Button('立即阅读')
          .padding({
            left: 32,
            right: 32,
            top: 8,
            bottom: 8
          })
          .width(150)
          .height(40)
          .borderRadius(200)
          .backgroundColor(this.theme.mainColor)
          .fontColor('#FFFFFF')
          .onClick(() => { // 跳转到阅读器
            router.pushUrl({
              url: 'pages/view/Reader/ReaderPage3', params: {
                bookData: this.bookData,
              }
            }) // this.jumpReadPage(``, 0)
          })
      }.padding({ top: 12, bottom: 12 }).justifyContent(FlexAlign.Center).width(CommonConstants.FULL_WIDTH).height(64)
    }
    .padding({ left: 20, right: 20, bottom: 12 })
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .borderRadius(16)
  }

  /**
   * 构建标签页签的Builder函数
   * 
   * 功能：创建底部面板的标签页签，显示标签名称和数量
   * 
   * @param index 标签页索引，用于判断当前选中状态
   * @param name 标签页显示名称
   * @param count 标签页相关数量（如目录数量、笔记数量等）
   * 
   * 设计特点：
   * - 选中状态时文字颜色更深，未选中时半透明
   * - 选中状态时显示主题颜色的指示线
   * - 显示数量标签
   */
  @Builder
  catalogTab(index: number, name: string, count: number) {
    Column() {
      Row() {
        Text(name)
          .fontSize(16)
          .fontColor(this.currentIndex === index ? '#e0000000' : '#73000000')
          .fontWeight(500)
          .lineHeight(24)
        Text(count.toString())
          .fontSize(12)
          .lineHeight(20)
          .fontColor(this.currentIndex === index ? '#e0000000' : '#73000000')
          .fontWeight(500)
      }

      Divider()
        .width(10)
        .strokeWidth(3)
        .lineCap(LineCapStyle.Round)
        .color(this.theme.mainColor)
        .opacity(this.currentIndex === index ? 1 : 0)
    }.padding({ top: 8, bottom: 8 }).width(59).height(40)
  }

  /**
   * 构建书籍详情页面UI的主要方法
   * 
   * 页面布局从上到下：
   * 1. 状态栏占位区域
   * 2. 标题栏（返回按钮、页面标题、编辑/分享/更多功能）
   * 3. 书籍信息区（封面、标题、作者、标签）
   * 4. 阅读记录区（阅读进度、天数、重读次数）
   * 5. 书籍简介区（可绑定底部面板）
   * 
   * 交互特性：
   * - 书籍简介区域绑定底部面板，上滑可展开
   * - 点击目录项跳转到阅读器
   * - 支持加入书架和立即阅读操作
   * - 编辑按钮跳转到书籍编辑页面
   */
  build() {
    Column() {
      // 状态栏占位区域，用于适配不同设备的系统状态栏
      Row() {

      }.width(CommonConstants.FULL_WIDTH).height(40)

      // 标题栏：包含返回按钮、页面标题和右侧功能按钮
      Row() {
        // 左侧：返回按钮和页面标题
        Row({ space: 12 }) {
          // 返回按钮，点击返回上一页面
          Image($r("app.media.ic_public_return_left")).titleImageStyle().onClick(() => {
            router.back()
          })
          // 页面标题
          Text('书籍详情').fontColor(Color.White).fontSize(16)
        }.height(24)

        // 中间空白区域，用于分隔左右内容
        Blank()
        
        // 右侧功能按钮：编辑、分享、更多
        Row({ space: 24 }) {
          // 编辑按钮：跳转到书籍编辑页面
          Image($r('app.media.ic_public_edit')).titleImageStyle().onClick(() => {
            router.pushUrl({
              url: '/pages/view/BookEditor/BookEditorPage'
            })
          })
          // 分享按钮
          Image($r('app.media.ic_public_share')).titleImageStyle()
          // 更多功能按钮
          Image($r('app.media.more')).titleImageStyle()
        }.height(24)
      }
      .padding({
        left: 20,
        right: 20,
        top: 12,
        bottom: 12
      })
      .height(36)
      .width(CommonConstants.FULL_WIDTH)

      // 小说标题区域：显示书籍封面、标题、作者和标签
      Row({ space: CommonConstants.SPACE_20 }) {
        // 书籍封面图片
        Image(this.bookData.coverUrl)
          .alt($r('app.media.icon_book_default_cover_ten'))  // 加载失败时的默认图片
          .width(CommonConstants.NOVEL_IMG_WIDTH)
          .height(CommonConstants.NOVEL_IMG_HEIGHT)
          .borderRadius(5)
        
        // 书籍信息列
        Column({ space: 8 }) {
          // 书籍标题，移除文件扩展名，限制2行显示
          Text(this.bookData.bookName.replace(new RegExp('\\..*', 'g'), ''))
            .width('75%')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor(Color.White)
            .fontSize(20)
          
          Blank()  // 空白区域，用于垂直居中布局
          
          // 作者信息行
          Row() {
            Text(this.bookData.author ?? '卖报小郎君')  // 默认作者名
              .fontSize(CommonConstants.FONT_NOVEL_DETAIL_AUTHOR_SIZE)
              .fontColor('#FFF')
              .opacity(0.45)
            // 作者信息右侧箭头图标
            Image($r('app.media.ic_public_right'))
              .width(CommonConstants.NOVEL_DETAIL_AUTHOR_IMG_SIZE)
              .height(CommonConstants.FONT_NOVEL_DETAIL_AUTHOR_SIZE)
              .fillColor('#FFF')
              .opacity(0.45)
          }

          // 标签区域：显示书籍类型、状态、字数等信息
          Row({ space: 8 }) {
            TagIndex({ tag: '幻想修仙' })
            TagIndex({ tag: '完本' })
            TagIndex({ tag: '300万字' })
          }
        }
        .height(CommonConstants.NOVEL_IMG_HEIGHT)
        .alignItems(HorizontalAlign.Start)  // 左对齐
      }
      .padding({
        left: 20,
        right: 20,
        top: 12,
        bottom: 12
      })
      .width(CommonConstants.FULL_WIDTH)
      .height(116)

      // 阅读记录区域：显示阅读进度、阅读天数、重读次数
      Row() {
        Row() {
          // 阅读进度组件
          ReadRecordItem()
          Divider().recordDividerStyle()  // 分隔线
          // 阅读天数组件
          ReadRecordItem({ count: 16, unit: '天', placeText: '阅读天数' })
          Divider().recordDividerStyle()  // 分隔线
          // 重读次数组件
          ReadRecordItem({ count: 3, unit: '次', placeText: 'N刷次数' })
        }
        .borderRadius(12)
        .padding({ top: 16, bottom: 16 })
        .height(60)
        .width(CommonConstants.FULL_WIDTH)
        .backgroundColor('#14ffffff')  // 半透明白色背景
      }
      .padding({
        left: 20,
        right: 20,
        top: 12,
        bottom: 12
      })
      .width(CommonConstants.FULL_WIDTH)
      .height(88)

      // 书籍简介区域：显示书籍描述，绑定底部面板
      Flex() {
        Text(this.bookData.intro ??
          '《大奉打更人》（第一卷）实体书已在天猫、当当、京东等全平台，以及各个实体书店发售。 这个世界，有儒；有道；有佛；有妖；有术士。 警校毕业的许七安幽幽醒来，发现自己身处牢狱之中，三日后流放边陲..... ' +
            '\n他起初的目的只是自保，顺便在这个没有人权的社会里当个富家翁悠闲度日。 ...... 多年后，许七安回首前尘，身后是早已逝去的敌人，以及累累白骨。 ' +
            '\n滚滚长江东逝水，浪花淘尽英雄，是非成败转头空。 ' + '\n青山依旧在，几度夕阳红。')
          .fontColor('#FFFFFF')
          .fontSize(14)
          .fontWeight(400)
          .lineHeight(22)
      }
      .padding({
        left: 20,
        right: 20,
        top: 12,
        bottom: 12
      })
      .width(CommonConstants.FULL_WIDTH)
      // 绑定底部面板：上滑展开目录/书源/笔记面板
      .bindSheet($$this.isShow, this.catalogPanel(), {
        detents: [SheetSize.MEDIUM, SheetSize.LARGE, 200],  // 面板停靠位置
        backgroundColor: '#FFFFFF',  // 面板背景色
        showClose: false,  // 不显示关闭按钮
        dragBar: true,  // 显示拖拽条
        enableOutsideInteractive: true,  // 允许面板外交互
      })

      // 注释掉的章节目录Panel（备用实现方案）
      /*Panel(this.isValue) {
        Column() {

        }
      }
      .width(CommonConstants.FULL_WIDTH)
      .type(PanelType.Foldable)
      .halfHeight('50%')
      .backgroundColor('#FFFFFF')*/
    }
    .height(CommonConstants.FULL_HEIGHT)
    .width(CommonConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.book_detail_background'))  // 使用资源文件定义的背景色
  }

  // 注释掉的阅读历史刷新标记（备用功能）
  // @StorageLink('BOOK_IS_BOOK_HISTORY_REFRESHING') isBookHistoryRefreshing: number = 0
  
  /**
   * 跳转到阅读界面时更新或添加阅读历史记录
   * 
   * 功能：当用户点击目录项跳转到阅读器时，记录阅读历史
   * 
   * @param durChapterTitle 当前阅读的章节标题
   * @param durChapterIndex 当前阅读的章节索引
   * 
   * 记录信息：
   * - 书籍基本信息（ID、名称、作者、类型等）
   * - 阅读进度（章节标题、章节索引）
   * - 阅读时间（当前时间戳）
   * - 书籍来源信息（URL、封面等）
   * 
   * 使用场景：用户从目录列表点击章节开始阅读时调用
   */
  async jumpReadPage(durChapterTitle: string, durChapterIndex: number) {
    // 创建阅读历史记录对象
    let bookHistory = new BookHistory()
    
    // 设置书籍基本信息
    bookHistory.id = this.bookData.id
    bookHistory.bookName = this.bookData.bookName
    bookHistory.author = this.bookData.author
    bookHistory.durChapterTime = Date.now()  // 当前时间戳
    bookHistory.bookType = this.bookData.bookType
    bookHistory.bookUrl = this.bookData.bookUrl ?? ''
    bookHistory.coverUrl = this.bookData.coverUrl ?? ''
    bookHistory.originBookId = this.bookData.id  // 原始书籍ID
    
    // 设置阅读进度信息
    bookHistory.durChapterTitle = durChapterTitle
    bookHistory.durChapterIndex = durChapterIndex
    
    // 将阅读历史记录保存到数据库
    bookHistoryUtils.addBooks(bookHistory)
  }
}

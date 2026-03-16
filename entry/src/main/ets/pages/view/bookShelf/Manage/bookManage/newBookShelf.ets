/**
 * 新建/修改书单组件
 * 
 * 功能概述：
 * 1. 提供完整的书单创建、编辑和预览功能
 * 2. 支持三种状态：新增(0)、预览(1)、修改(2)
 * 3. 管理书单基本信息：名称、描述、封面
 * 4. 管理书单中的书籍列表，支持添加、移除书籍
 * 5. 为每本书籍提供推荐理由编辑功能
 * 6. 集成分享功能，支持书单分享
 * 7. 响应主题颜色变化，保持UI一致性
 * 
 * 使用场景：
 * - 新建书单：从零开始创建新书单
 * - 预览书单：查看已创建书单的详细信息
 * - 修改书单：编辑现有书单的内容
 * - 从其他页面跳转添加书籍到书单
 * 
 * 组件特点：
 * - 支持三种状态切换，UI动态变化
 * - 集成添加书籍弹窗（newAddShelf组件）
 * - 提供书籍推荐理由编辑功能
 * - 支持书单分享功能
 * - 适配屏幕安全区域（topRectHeight和bottomRectHeight）
 * - 使用动画效果增强用户体验
 */
import CommonConstants from '../../../../../common/constants/CommonConstants'
import PaddingConstants from '../../../../../common/constants/PaddingConstants'
import { ThemeStorageKey } from '../../../../../common/constants/Theme'
import { ThemeItem } from '../../../../../common/model/Theme'
import worksListsUtils from '../../../../../common/utils/WorksListsUtils'
import confirmDialogExample from '../../../../../componets/common/confirmDialog'
import { showMessage } from '../../../../../componets/common/promptShow'
import BooksDao from '../../../../../database/dao/BooksDao'
import { Books } from '../../../../../database/entities/Books'
import { WorksBookList } from '../../../../../database/entities/WorksBookList'
import { WorksLists, WORK_BOOK_LIST_STATUS } from '../../../../../database/entities/WorksLists'
import shareWorksBook from '../../../dialog/shareWorksBook'
import newAddShelf from './newAddShelf'

@Component
export default struct newBookShelf{
  /** 
   * 顶部矩形高度，用于适配不同屏幕的安全区域
   * 通过@StorageLink与AppStorage同步，自动响应屏幕变化
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 
   * 底部矩形高度，用于适配不同屏幕的安全区域
   * 通过@StorageLink与AppStorage同步，自动响应屏幕变化
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 
   * 当前索引，用于区分不同的书籍类型或分类
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop currentIndex:number
  
  /** 
   * 书籍推荐理由记录，键为书籍ID，值为推荐理由文本
   * 通过@State装饰器管理组件内部状态
   */
  @State TextRecommend:Record<number, string> = {}
  
  /** 
   * 删除缓存状态标识
   * 用于控制删除操作的相关状态
   */
  @State delCache:boolean = false
  
  /** 
   * 书单中的书籍列表数据
   * 通过@State装饰器管理组件内部状态
   */
  @State addBooksList:Books[] = []
  
  /** 
   * 书籍ID数组，从父组件传递的初始书籍ID列表
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop bookIds:number[] = []
  
  /** 
   * 当前书单中的书籍ID数组
   * 通过@State装饰器管理组件内部状态
   * 使用@Watch装饰器监听变化，变化时触发changeBookIds方法
   */
  @State  @Watch('changeBookIds')newBookIds:number[] = []
  
  /** 
   * 是否显示添加书籍弹窗
   * true: 显示添加书籍弹窗
   * false: 隐藏添加书籍弹窗
   */
  @State isShowAddBook:boolean = false
  
  /** 
   * 显示数字变化回调函数，用于控制页面显示状态
   * 默认为空函数，父组件可以覆盖此函数
   */
  changeShowNumber:Function = (_index:number)=>{

  }
  
  /** 
   * 提交回调函数，当书单创建/修改完成时触发
   * 默认为空函数，父组件可以覆盖此函数以处理提交逻辑
   */
  submit:Function = ()=>{
  }
  
  /** 
   * 上次的书单数据，用于编辑或预览现有书单
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop lastWorkBookList:WorksLists
  
  /**
   * 书单状态管理
   * 0: 新增 - 创建新书单
   * 1: 预览 - 查看书单详细信息
   * 2: 修改 - 编辑现有书单
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop workBookListStatus:number = 0
  
  /**
   * 书籍ID变化处理函数
   * 当newBookIds变化时触发，调用getBookIds方法加载书籍数据
   */
  changeBookIds(){
    this.getBookIds()
  }
  
  /** 
   * 返回时是否关闭页面
   * true: 返回时关闭页面，返回到上一级
   * false: 返回时仅切换状态，不关闭页面
   */
  @Prop returnClose:boolean = false

  /**
   * 组件显示时初始化数据
   * 
   * 功能：根据书单状态初始化数据
   * 逻辑：
   * 1. 新增状态(0)：使用传入的bookIds作为初始书籍ID
   * 2. 预览/修改状态(1/2)：加载现有书单数据
   *    - 初始化推荐理由记录
   *    - 获取书单中的书籍ID
   *    - 如果是修改状态，合并传入的bookIds
   */
  async aboutToAppear(): Promise<void> {
    if (this.workBookListStatus === 0) {
      // 新增状态：使用传入的书籍ID
      this.newBookIds = this.bookIds
    } else {
      // 预览/修改状态：加载现有书单数据
      this.workBookList = this.lastWorkBookList
      if (this.workBookList.worksBookList) {
        // 初始推荐理由：从现有书单中加载推荐理由
        this.workBookList.worksBookList.forEach((item: WorksBookList) => {
          if (item.bookId) {
            this.TextRecommend[item.bookId] = item.recommend ?? '';
          }
        })
        // 初始书籍：获取书单中的书籍ID
        let bookIds = worksListsUtils.getBookIds(this.workBookList.worksBookList)
        // 修改状态：合并传入的书籍ID
        if (this.bookIds && this.bookIds.length && this.workBookListStatus === 2) {
          this.bookIds.forEach((id: number) => {
            if (!bookIds.includes(id)) {
              bookIds.push(id);
            }
          });
        }
        if (bookIds.length) {
          this.newBookIds = bookIds;
        }
      }
    }
  }
  
  /**
   * 根据书籍ID获取书籍数据
   * 
   * 功能：根据newBookIds从数据库查询书籍信息
   * 逻辑：
   * 1. 清空现有书单书籍列表
   * 2. 调用BooksDao.getBookByIds查询书籍数据
   * 3. 遍历查询结果，初始化推荐理由记录
   * 4. 构建书单书籍列表（WorksBookList对象）
   */
  getBookIds(){
    this.workBookList.worksBookList = []  // 清空现有书单书籍列表
    BooksDao.getBookByIds(this.newBookIds).then((val)=>{
      this.addBooksList = val  // 更新书籍列表数据
      this.addBooksList.forEach((item: Books) => {
        const exists = this.workBookList.worksBookList?.some(book => book.bookId === item.id);
        // 初始化推荐理由记录
        if (item.id && !exists) {
          this.TextRecommend[item.id] = this.TextRecommend[item.id] ?? '';
        }

        // 构建书单书籍列表
        if (!exists) {
          let books = new WorksBookList();
          books.bookId = item.id;
          books.recommend = '';
          this.workBookList.worksBookList?.push(books);
        }
      });
    })
  }

  /** 
   * 要删除的书籍ID
   * 用于记录用户选择要移除的书籍
   */
  @State delBookIds:number = 0
  
  /** 
   * 书籍删除确认对话框控制器
   * 用于显示删除确认对话框，防止误操作
   */
  bookInfoDel: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      confirm: ()=> {
        this.moveWorksBook()  // 确认删除回调
      },
      delCache:this.delCache  // 是否删除缓存
    }),
    autoCancel: true,        // 点击背景自动关闭
    alignment: DialogAlignment.Center,  // 对话框居中显示
    gridCount: 4,            // 网格数量为4
    customStyle: false,      // 不使用自定义样式
    cornerRadius: 25,        // 圆角半径为25
  })
  
  /**
   * 移除书单中的书籍（仅移除，不删除书籍本身）
   * 
   * 功能：从书单中移除指定的书籍
   * 逻辑：
   * 1. 从workBookList.worksBookList中过滤掉指定书籍
   * 2. 从addBooksList中过滤掉指定书籍
   * 3. 从newBookIds中过滤掉指定书籍ID
   * 4. 重置delBookIds为0
   * 5. 显示操作成功提示
   */
  moveWorksBook() {
    // 过滤出要保留的书籍
    this.workBookList.worksBookList = this.workBookList.worksBookList?.filter(item => item.bookId !== this.delBookIds);
    this.addBooksList = this.addBooksList.filter(item => item.id !== this.delBookIds);
    this.newBookIds = this.newBookIds.filter(item => item !== this.delBookIds);
    // 重置 delBookIds
    this.delBookIds = 0;
    showMessage('移除书单成功,提交生效!', 1000)  // 显示操作成功提示
  }

  /** 
   * 书单数据对象，包含书单的所有信息
   * 通过@State装饰器管理组件内部状态
   * 初始化为空书单对象
   */
  @State workBookList:WorksLists = {
    worksName: '',          // 书单名称
    worksDescribe: '',      // 书单描述
    worksRemark: '',        // 书单备注
    worksCoverUrl: '',      // 书单封面URL
    createTime: 0,          // 创建时间
    updateTime: 0,          // 更新时间
    worksType: 0,           // 书单类型
    worksBookNum: 0,        // 书籍数量
    isTop: false,           // 是否置顶
    worksBookList:[]        // 书单中的书籍列表
  }
  
  /** 
   * 主题颜色配置
   * 通过@StorageProp从AppStorage获取，自动响应主题变化
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  build() {
    Flex({
      justifyContent:FlexAlign.SpaceBetween,
      direction:FlexDirection.Column
    }
    ){
      Column({
        space:24
      }) {
        Flex({
          alignItems:ItemAlign.Center,
          justifyContent:this.workBookListStatus !== 1 ? FlexAlign.Center : FlexAlign.SpaceBetween
        }){
          Image($r('app.media.return_left'))
            .width(25)
            .height(25)
            .fillColor('rgba(0, 0, 0, 0.88)')
            .onClick(()=>{
              if (this.workBookListStatus !== 2) {
                this.changeShowNumber(0)
              } else {
                if (this.returnClose) {
                  this.workBookListStatus = 1
                } else {
                  this.submit()
                }
              }
            })

          Row({
            space:24
          }){
            Image($r('app.media.edit_black')).width(25)
              .onClick(()=>{
                this.workBookListStatus = 2
              })
            Image($r('app.media.edit_share')).width(25)
              .onClick(()=>{
                this.shareShelfBookDialog?.open()
              })
          }
          .visibility(this.workBookListStatus === 1?Visibility.Visible:Visibility.None)
          .opacity(this.workBookListStatus === 1?1:0)
          .translate({ y: this.workBookListStatus === 1 ? 0 : -50})
          .animation({
            duration: 500,
            curve: CommonConstants.UniCurve
          })
          .justifyContent(FlexAlign.Center)

          Column(){
            Text(WORK_BOOK_LIST_STATUS[this.workBookListStatus])
              .fontSize(16)
              .lineHeight(24)
              .fontWeight(500)
              .textAlign(TextAlign.Center)
              .fontColor($r('app.string.color_black_88'))
          }
          .visibility(this.workBookListStatus !== 1?Visibility.Visible:Visibility.None)
          .opacity(this.workBookListStatus !== 1?1:0)
          .translate({ y: this.workBookListStatus !== 1 ? 0 : -50})
          .animation({
            duration: 500,
            curve: CommonConstants.UniCurve
          })
          .justifyContent(FlexAlign.Center)
          .margin({right:20})
          .width('100%')
        }
        Column(){
          if (this.workBookListStatus !== 1){
            Stack() {
              TextInput({ text: this.workBookList.worksName ?? '', placeholder: `请输入书单名称` })
                .placeholderColor('#73000000')
                .maxLength(20)
                .placeholderFont({ size: 14, weight: 400 })
                .caretColor(this.theme.mainColor)
                .height(38)
                .margin({ top: 10, bottom: 10 })
                .fontSize(14)
                .fontColor('#E0000000')
                .borderRadius(4)
                .onChange((value: string) => {
                  this.workBookList.worksName = value
                })

              Text(`${this.workBookList.worksName?.length ?? 0}/20`)
                .fontSize(14)
                .fontColor('#73000000')
                .position({ top: 20, right: 10 })
            }.width('80%')

            TextArea({
              text:this.workBookList.worksDescribe,
              placeholder:'书单描述'
            })
              .borderRadius(4)
              .fontColor('#E0000000')
              .caretColor(this.theme.mainColor)
              .placeholderColor('#73000000')
              .width('80%')
              .fontSize(14)
              .fontWeight(500)
              .lineHeight(26)
              .fontColor($r('app.string.color_black_88'))
              .margin({
                top: PaddingConstants.PADDING_12
              })
              .onChange((value: string) => {
                this.workBookList.worksDescribe = value
              })
          } else {
            Text(this.workBookList.worksName).fontSize(16).fontWeight(500).lineHeight(26).fontColor('rgba(0, 0, 0, 0.88)')
            Text(this.workBookList.worksDescribe)
              .fontSize(14).fontWeight(500).lineHeight(26).fontColor('rgba(0, 0, 0, 0.88)')
              .margin({top:12})
          }

          Scroll(){
            Column(){
              ForEach(this.addBooksList,(item:Books,index:number)=>{
                this.BookShelfInfo(item,index)
              })
            }
          }
          .align(Alignment.TopStart)
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .padding({left:20,right:20,top:12,bottom:12})
      .alignItems(HorizontalAlign.Start)

      if (this.workBookListStatus !== 1){
        Divider().strokeWidth(0.5)
        Flex({
          justifyContent:FlexAlign.Center
        }){
          this.newFooter()
        }
        .backgroundColor(Color.White)
      }
      Flex()
        .bindContentCover($$this.isShowAddBook, this.newAddBook(), {
          modalTransition: ModalTransition.DEFAULT,
          onDisappear: () => {
            this.isShowAddBook = false;
          }
        })
    }
    .padding({
      top:this.topRectHeight,
      bottom:this.bottomRectHeight
    })
  }

  /**
   * 添加书籍弹窗构建器
   * 
   * 功能：构建添加书籍的全屏覆盖弹窗
   * 使用newAddShelf组件，支持搜索和选择书籍添加到书单
   * 
   * @returns 添加书籍弹窗的UI内容
   */
  @Builder newAddBook(){
    Column(){
      newAddShelf({
        currentIndex:this.currentIndex,  // 当前索引
        addBookList:(selectBookId:number[])=>{
          this.newBookIds = selectBookId  // 更新书单中的书籍ID
          this.isShowAddBook = false;     // 关闭弹窗
          showMessage('加入书单成功,提交生效!')  // 显示成功提示
        },
        close:() => {
          this.isShowAddBook = false;  // 关闭弹窗
        },
        lastBookIds:this.newBookIds  // 当前书单中的书籍ID（用于初始化选中状态）
      })
    }
    .backgroundColor(Color.White)  // 白色背景
  }

  /**
   * 底部操作栏构建器
   * 
   * 功能：构建底部操作栏，包含添加书籍和确定按钮
   * 布局结构：
   * 1. 左侧：添加书籍按钮（40%宽度）
   * 2. 右侧：确定按钮（50%宽度）
   * 
   * 交互功能：
   * - 点击添加书籍按钮：显示添加书籍弹窗
   * - 点击确定按钮：提交书单数据（创建或修改）
   * 
   * 设计特点：
   * - 添加书籍按钮使用灰色文字和浅灰色背景
   * - 确定按钮使用白色文字和主题主色背景
   * - 按钮高度38px，圆角20px
   * - 按钮之间有20px间距
   */
  @Builder newFooter(){
    Row({
      space:20  // 按钮间距20px
    }) {
      // 左侧：添加书籍按钮
      Flex({
        justifyContent:FlexAlign.Center,  // 水平居中对齐
        alignItems:ItemAlign.Center       // 垂直居中对齐
      }){
       Row({
         space:5  // 图标和文字间距5px
       }){
         Image($r('app.media.add_new_fill')).width(20).height(20)  // 添加图标
         Text('添加书籍').fontSize(16).fontWeight(500).fontColor('rgba(0, 0, 0, 0.45)').textAlign(TextAlign.Center)
       }
      }
      .width('40%')  // 宽度40%
      .height(38)    // 高度38px
      .borderRadius(20)  // 圆角20px
      .backgroundColor('rgba(0, 0, 0, 0.04)')  // 浅灰色背景
      .onClick(()=>{
        this.isShowAddBook = true  // 显示添加书籍弹窗
      })
      
      // 右侧：确定按钮
      Flex({
        justifyContent:FlexAlign.Center,  // 水平居中对齐
        alignItems:ItemAlign.Center       // 垂直居中对齐
      }){
        Text('确定').fontSize(16).fontWeight(500).fontColor(Color.White)  // 白色文字
      }
      .onClick(async ()=>{
        // 验证书单名称是否为空
        if (!this.workBookList.worksName) {
          showMessage('书单名称不能为空!')
          return
        }
        // 默认取书籍的第一个封面为书单封面
        if(this.addBooksList.length > 0){
          this.workBookList.worksCoverUrl = this.addBooksList[0].coverUrl ?? ''
        }
        // 保存书单数据到数据库
        await worksListsUtils.addWorksLists(this.workBookList)
        // 显示成功提示
        showMessage(this.workBookListStatus === 0?'创建书单成功':'修改书单成功')
        // 初始化页面数据
        this.initWorkData()
        // 切换显示状态
        this.changeShowNumber(0)
        // 触发提交回调
        this.submit()
      })
      .borderRadius(20)  // 圆角20px
      .width('50%')      // 宽度50%
      .height(38)        // 高度38px
      .backgroundColor(this.workBookList.worksName.length >=1?this.theme.mainColor: this.theme.mainColor)  // 主题主色背景
    }.padding({top:12,bottom:12,left:20,right:20})  // 内边距
  }

  /**
   * 书单书籍信息构建器
   * 
   * 功能：构建单个书籍在书单中的展示项
   * 布局结构：
   * 1. 顶部：书籍基本信息（封面、名称、简介、标签）
   * 2. 中部：推荐理由编辑区域（预览状态只显示，编辑状态可编辑）
   * 3. 底部：清空推荐理由按钮（仅编辑状态且推荐理由不为空时显示）
   * 
   * 交互功能：
   * - 点击删除按钮：打开删除确认对话框
   * - 点击加入书架按钮：显示加入书架提示
   * - 编辑推荐理由：实时更新书单数据
   * - 点击清空按钮：清空当前书籍的推荐理由
   * 
   * @param book 书籍数据对象
   * @param index 书籍在列表中的索引
   * @returns 书籍信息展示项的UI内容
   */
  @Builder BookShelfInfo(book:Books,index:number){
    Column() {
      // 顶部：书籍基本信息
      Row({
        space: 12  // 元素间距12px
      }) {
        // 书籍封面和置顶标识
        Stack(){
          if (book.isTop){
            Text('置顶').fontColor(Color.White).fontWeight(300).fontSize(8).padding(3).borderRadius(5)
              .backgroundColor('rgba(0, 0, 0, 0.45)').zIndex(1)  // 半透明黑色背景
          }
          Image(book.coverUrl)
            .draggable(false)  // 禁止拖拽
            .alt($r('app.media.icon_book_default_cover_one'))  // 默认封面
            .width(69)  // 宽度69px
            .height(92) // 高度92px
        }.alignContent(Alignment.BottomStart)  // 底部起始对齐

        // 书籍详细信息
        Column({
          space:5  // 子元素间距5px
        }) {
          // 书籍名称和操作按钮
          Row(){
            Text(book.bookName).fontSize(16).fontWeight(500).lineHeight(24)
              .textOverflow({
                overflow:TextOverflow.Ellipsis  // 文本溢出显示省略号
              })
              .ellipsisMode(EllipsisMode.END)   // 省略号在末尾
              .maxLines(1).width('65%')         // 最多1行，宽度65%

            // 根据书单状态显示不同的操作按钮
            if (this.workBookListStatus !== 1){
              // 编辑状态：显示删除按钮
              Image($r('app.media.close')).width(12).onClick(()=>{
                this.bookInfoDel?.open()  // 打开删除确认对话框
                this.delBookIds = book.id ?? 0  // 记录要删除的书籍ID
              })
            } else {
              // 预览状态：显示加入书架按钮
              Image(book.isJoin?$r('app.media.unadd_book_shelf'):$r('app.media.add_book_shelf'))
                .width(20)
                .height(20)
                .onClick(()=>{
                if (!book.isJoin) {
                  showMessage('已加入书架')  // 显示加入书架提示
                }
              })
            }
          }
          // 书籍简介
          Text(book.intro)
            .fontSize(12)
            .lineHeight(20)
            .fontColor('rgba(0, 0, 0, 0.45)')  // 灰色文字
            .textOverflow({
              overflow:TextOverflow.Ellipsis  // 文本溢出显示省略号
            })
            .height(50)                       // 固定高度50px
            .ellipsisMode(EllipsisMode.END)   // 省略号在末尾
            .maxLines(2).width('75%')         // 最多2行，宽度75%
          
          // 书籍标签区域
          Row({
            space:6  // 标签间距6px
          }){
            // 作者标签（使用主题主色）
            Row(){
              Text('卖报小郎君').fontSize(10).fontWeight(400).fontColor(this.theme.mainColor)
            }
            .padding({left:6,right:6,top:5,bottom:5}).backgroundColor(this.theme.secondColor).borderRadius(10)
            
            // 类型标签
            Row(){
              Text('玄幻').fontSize(10).fontWeight(400).fontColor('rgba(0, 0, 0, 0.45)')
            }
            .fontStyles()  // 应用字体样式
            
            // 状态标签
            Row(){
              Text('完本').fontSize(10).fontWeight(400).fontColor('rgba(0, 0, 0, 0.45)')
            }
            .fontStyles()  // 应用字体样式
            
            // 字数标签
            Row(){
              Text('380万字').fontSize(10).fontWeight(400).fontColor('rgba(0, 0, 0, 0.45)')
            }.fontStyles()  // 应用字体样式
          }
        }
        .alignItems(HorizontalAlign.Start)  // 水平起始对齐
      }
      
      // 中部：推荐理由编辑区域
      Column(){
        if (this.workBookListStatus ===0 || this.workBookListStatus === 2){
          // 编辑状态：可编辑的文本区域
          TextArea({placeholder:'添加推荐理由', text:this.TextRecommend[book.id ?? 0]}).padding(10).borderRadius(8)
            .onChange((value:string)=>{
              this.TextRecommend[book.id ?? 0] = value
              let books = new WorksBookList()
              books.bookId = book.id
              books.recommend = value
              let existingBook = this.workBookList.worksBookList?.find(item => item.bookId === books.bookId);
              if (existingBook) {
                existingBook.recommend = books.recommend;
              } else {
                this.workBookList.worksBookList?.push(books);
              }
            })
        } else {
          Text(this.TextRecommend[book.id ?? 0] ?? '')
            .padding(10)
        }
      }
      .padding({top:12,bottom:5})
      if (this.TextRecommend[book.id ?? 0] && this.TextRecommend[book.id ?? 0].length >= 1 && this.workBookListStatus !== 1){
        Flex({
          justifyContent:FlexAlign.End
        }){
          Text('清空').textAlign(TextAlign.End).fontColor(this.theme.mainColor)
        }.onClick(()=>{
          this.TextRecommend[book.id ?? 0] = ''
        })
      }
    }
    .alignItems(HorizontalAlign.Start)  // 水平起始对齐
    .padding({top:16})  // 顶部内边距16px
  }
  
  /**
   * 初始化页面数据
   * 
   * 功能：重置所有页面数据到初始状态
   * 使用场景：
   * - 书单创建/修改成功后，清空表单数据
   * - 页面需要重新开始时，重置所有状态
   * 
   * 重置内容：
   * 1. addBooksList: 清空书单中的书籍列表
   * 2. TextRecommend: 清空所有书籍的推荐理由记录
   * 3. workBookList: 重置书单数据对象到初始状态
   *    - worksName: 空字符串
   *    - worksDescribe: 空字符串
   *    - worksRemark: 空字符串
   *    - worksCoverUrl: 空字符串
   *    - createTime: 0
   *    - updateTime: 0
   *    - worksType: 0
   *    - worksBookNum: 0
   *    - isTop: false
   *    - worksBookList: 空数组
   */
  initWorkData(){
    this.addBooksList = []  // 清空书单中的书籍列表
    this.TextRecommend = {}  // 清空推荐理由记录
    this.workBookList = {
      worksName: '',          // 书单名称：空字符串
      worksDescribe: '',      // 书单描述：空字符串
      worksRemark: '',        // 书单备注：空字符串
      worksCoverUrl: '',      // 书单封面URL：空字符串
      createTime: 0,          // 创建时间：0
      updateTime: 0,          // 更新时间：0
      worksType: 0,           // 书单类型：0
      worksBookNum: 0,        // 书籍数量：0
      isTop: false,           // 是否置顶：false
      worksBookList:[]        // 书单中的书籍列表：空数组
    }
  }

  /** 
   * 书单分享对话框控制器
   * 
   * 功能：控制书单分享对话框的显示和隐藏
   * 配置参数：
   * - builder: 使用shareWorksBook组件构建分享对话框
   * - autoCancel: true - 点击背景自动关闭对话框
   * - width: '100%' - 对话框宽度为全屏
   * - height: '100%' - 对话框高度为全屏
   * - alignment: DialogAlignment.Bottom - 对话框底部对齐
   * - customStyle: true - 使用自定义样式
   * 
   * shareWorksBook组件参数：
   * - works: 当前书单数据对象，包含书单的所有信息
   */
  shareShelfBookDialog: CustomDialogController | null = new CustomDialogController({
    builder: shareWorksBook({
      works:this.workBookList  // 当前书单数据
    }),
    autoCancel: true,        // 点击背景自动关闭
    width:'100%',            // 全屏宽度
    height:'100%',           // 全屏高度
    alignment: DialogAlignment.Bottom,  // 底部对齐
    customStyle:true         // 使用自定义样式
  })
}

@Styles function fontStyles() {
  .padding({left:6,right:6,top:5,bottom:5})
  .backgroundColor('rgba(0, 0, 0, 0.06)')
  .borderRadius(10)
}

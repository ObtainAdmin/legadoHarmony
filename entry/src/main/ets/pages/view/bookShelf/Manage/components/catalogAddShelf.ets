/**
 * 加入书单弹窗组件
 * 
 * 功能概述：
 * 1. 提供书单选择界面，允许用户将书籍/分组添加到现有书单
 * 2. 支持新建书单功能，快速创建新书单
 * 3. 显示所有可用书单列表，并标识书籍是否已在书单中
 * 4. 集成书单编辑功能，可跳转到书单编辑页面
 * 5. 支持从分组中提取书籍ID，批量添加到书单
 * 
 * 使用场景：
 * - 从书籍管理页面选择"加入书单"操作时
 * - 从分组管理页面选择"加入书单"操作时
 * - 在其他需要批量添加内容到书单的场景中使用
 * 
 * 组件特点：
 * - 使用底部弹窗形式显示，不占用全屏
 * - 顶部显示标题，底部显示取消按钮
 * - 中部显示书单列表，支持滚动浏览
 * - 集成新建书单功能，使用主题颜色突出显示
 * - 自动检查书籍是否已在书单中，避免重复添加
 */
import CommonConstants from '../../../../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../../../../common/constants/Theme'
import { ThemeItem } from '../../../../../common/model/Theme'
import bookGroupUtil from '../../../../../common/utils/bookGroupUtils'
import worksListsUtils from '../../../../../common/utils/WorksListsUtils'
import { showMessage } from '../../../../../componets/common/promptShow'
import worksListsDao from '../../../../../database/dao/WorksListsDao'
import { WorksBookList } from '../../../../../database/entities/WorksBookList'
import { WorksLists } from '../../../../../database/entities/WorksLists'
import newBookShelf from '../bookManage/newBookShelf'

@Component
export default struct catalogAddShelf{
  /** 
   * 书单选择回调函数，当用户选择书单或取消时触发
   * 参数：是否选择了书单（true-选择了书单，false-取消）
   * 默认为空函数，父组件需要覆盖此函数以处理选择结果
   */
  onClickShelf:Function = (_isCatalogAddShelf:boolean)=>{
  }
  
  /** 
   * 要添加的ID数组，可以是书籍ID或分组ID
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop ids:number[]
  
  /** 
   * 操作类型：0-书籍，1-文件夹/分组
   * 用于区分是添加书籍还是添加分组中的书籍
   * 默认值：0（书籍）
   */
  @Prop bookOrFolder:number = 0
  
  /** 
   * 当前索引，用于区分不同的书籍类型或分类
   * 通过@Prop装饰器从父组件传递，单向绑定
   * 默认值：0
   */
  @Prop currentIndex:number = 0
  
  /** 
   * 显示数字（暂未使用）
   * 可能用于控制页面显示状态
   */
  @Prop showNumber:number = 0
  
  /** 
   * 当前选中的书单数据
   * 通过@State装饰器管理组件内部状态
   * 初始化为空书单对象
   */
  @State worksBook:WorksLists = new WorksLists()
  
  /** 
   * 书单列表数据，包含所有可用的书单
   * 通过@State装饰器管理组件内部状态
   */
  @State worksLists:WorksLists[] =[]
  
  /** 
   * 要添加的书籍ID数组
   * 通过@State装饰器管理组件内部状态
   */
  @State newBookIds:number[] = []
  
  /** 
   * 主题颜色配置
   * 通过@StorageProp从AppStorage获取，自动响应主题变化
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * 获取书单列表
   * 
   * 功能：从数据库查询当前类型的书单数据
   * 使用worksListsDao.search方法，根据currentIndex（类型）查询
   */
  getWorkLists() {
    worksListsDao.search({
      type:this.currentIndex  // 书籍类型
    }).then((val)=>{
      this.worksLists = val  // 更新书单列表
    })
  }

  /**
   * 组件显示时初始化数据
   * 
   * 功能：根据操作类型初始化要添加的书籍ID
   * 逻辑：
   * 1. 如果是分组操作（bookOrFolder=1）：从分组中查询书籍ID
   * 2. 如果是书籍操作（bookOrFolder=0）：直接使用传入的ID
   * 3. 调用getWorkLists方法加载书单列表
   */
  async aboutToAppear(): Promise<void> {
    if (this.bookOrFolder === 1){
      // 分组操作：从分组中查询书籍ID
      let bookId =  await bookGroupUtil.queryBookByGroupId(this.ids)
      if (bookId.length) {
        this.newBookIds = bookId  // 使用分组中的书籍ID
      }
    } else {
      // 书籍操作：直接使用传入的ID
      this.newBookIds = this.ids
    }
    this.getWorkLists()  // 加载书单列表
  }

  /**
   * 校验书籍是否已在书单中
   * 
   * 功能：检查要添加的书籍是否已经存在于指定书单中
   * 逻辑：
   * 1. 检查参数是否有效（书单列表、书籍ID列表）
   * 2. 从书单中提取已有的书籍ID
   * 3. 检查newBookIds中的所有书籍ID是否都已在书单中
   * 
   * @param worksBookList 书单中的书籍列表
   * @returns 如果所有书籍都已存在返回true，否则返回false
   */
  isExistBook(worksBookList: WorksBookList[]): boolean {
    if (!worksBookList || worksBookList.length === 0 || this.newBookIds.length === 0) {
      return false;  // 参数无效，返回false
    }
    const bookIds = worksListsUtils.getBookIds(worksBookList);  // 提取书单中的书籍ID
    return this.newBookIds.every(item => bookIds.includes(item));  // 检查所有书籍是否都已存在
  }


  /**
   * 构建组件UI
   * 
   * 布局结构：
   * 1. 使用Flex布局，垂直方向，两端对齐，居中对齐
   * 2. 顶部：标题区域（"加入书单"标题）
   * 3. 中部：书单列表区域（包含新建书单项和现有书单列表）
   * 4. 底部：取消按钮区域
   * 5. 集成书单编辑弹窗（全屏覆盖）
   * 
   * 设计特点：
   * - 使用全屏宽度和高度
   * - 顶部和底部使用分割线分隔
   * - 书单列表支持滚动浏览
   * - 集成书单编辑功能，支持新建和修改书单
   */
  build() {
    Flex({
      justifyContent:FlexAlign.SpaceBetween,  // 两端对齐
      alignContent:FlexAlign.Center,          // 居中对齐
      direction:FlexDirection.Column          // 垂直方向
    }) {
      // 顶部：标题区域
      Column(){
        Column(){
          Text('加入书单')
            .fontSize(16)
            .fontWeight(700)
            .lineHeight(24)
        }
        .padding({right:20,left:20,top:12,bottom:12})  // 内边距
        
        Divider().strokeWidth(0.5)  // 分割线
        
        // 新建书单项
        Flex(){
          this.ColumnTitle()  // 新建书单构建器
        }
        
        // 书单列表滚动区域
        Scroll(){
          Column(){
            // 遍历书单列表，渲染每个书单项
            ForEach(this.worksLists,(item:WorksLists)=>{
              this.ColumnTitle(item)  // 书单项构建器
            })
          }
        }
        .align(Alignment.TopStart)  // 顶部对齐
        .layoutWeight(1)            // 占据剩余空间
        .scrollBar(BarState.Off)    // 关闭滚动条
      }
      
      // 底部：取消按钮区域
      Column(){
        Divider().strokeWidth(0.5)  // 分割线

        Text('取消')
          .onClick(() => {
            this.onClickShelf(false)  // 触发取消回调
          })
          .margin({
            top:12,bottom:12  // 上下边距
          })

      }
      .padding(20)  // 内边距

      // 书单编辑弹窗（全屏覆盖）
      Flex()
        .bindContentCover($$this.isShowEditBook, this.showEditBook(), {
          modalTransition: ModalTransition.DEFAULT,  // 默认过渡动画
          onDisappear: () => {
            this.isShowEditBook = false;  // 弹窗消失时重置状态
          }
        })
    }
    .width(CommonConstants.FULL_WIDTH)   // 全屏宽度
    .height(CommonConstants.FULL_HEIGHT) // 全屏高度
  }
  
  /** 
   * 书单状态：1-预览（默认）
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop workBookListStatus:number = 1
  
  /** 
   * 是否显示书单编辑弹窗
   * true: 显示书单编辑界面
   * false: 隐藏书单编辑界面
   */
  @State isShowEditBook:boolean = false
  
  /**
   * 书单编辑弹窗构建器
   * 
   * 功能：构建书单编辑界面的全屏覆盖弹窗
   * 使用newBookShelf组件，支持书单的新建和修改
   * 
   * @returns 书单编辑弹窗的UI内容
   */
  @Builder showEditBook(){
    Column(){
      newBookShelf({
        currentIndex:this.currentIndex,  // 当前索引
        changeShowNumber:()=>{
          this.isShowEditBook = false  // 关闭弹窗
          setTimeout(()=>{
            this.getWorkLists()  // 延迟刷新书单列表
          },200)
        },
        submit:()=>{
          this.isShowEditBook = false      // 关闭弹窗
          this.onClickShelf(false)         // 触发选择回调
        },
        workBookListStatus:this.workBookListStatus,  // 书单状态
        lastWorkBookList:this.worksBook,             // 当前书单数据
        bookIds: this.newBookIds                     // 要添加的书籍ID
      })
    }
    .backgroundColor(Color.White)  // 白色背景
  }

  /**
   * 书单项构建器
   * 
   * 功能：构建单个书单项的UI
   * 支持两种类型：
   * 1. 新建书单项：显示"新建书单"按钮，使用主题颜色
   * 2. 现有书单项：显示书单名称和状态标识
   * 
   * @param work 书单数据对象，如果为undefined则表示新建书单项
   * @returns 书单项的UI内容
   */
  @Builder ColumnTitle(work?:WorksLists) {
    Column() {
      if (!work){
        Flex({
          justifyContent:FlexAlign.SpaceBetween,
          alignItems:ItemAlign.Center
        }){
          Row({
            space:12
          }){
            Image($r('app.media.add')).width(24).fillColor(this.theme.mainColor)
            Text('新建书单').fontSize(14).fontColor(this.theme.mainColor).fontWeight(400).lineHeight(22)
          }.onClick(()=>{
            this.workBookListStatus = 0
            this.isShowEditBook = true
          })
        }
      } else {
        Flex({
          justifyContent:FlexAlign.SpaceBetween,
          alignItems:ItemAlign.Center
        }){
          Row({
            space:12
          }){
            Image($r('app.media.shelf')).width(24)
            Text(work.worksName)
              .fontSize(14)
              .fontWeight(400)
              .lineHeight(22)
              .textOverflow({
              overflow:TextOverflow.Ellipsis
              })
              .ellipsisMode(EllipsisMode.END)
              .maxLines(1)
          }

          if (this.isExistBook(work.worksBookList ?? [])) {
            Text('已在书单').fontSize(12).fontWeight(400).lineHeight(20).fontColor('rgba(0, 0, 0, 0.45)')
          } else {
            Image($r('app.media.ic_public_return_right')).width(24).height(24)
          }
        }
        .onClick(() => {
          if (this.newBookIds.length === 0){
            showMessage('暂无相关内容可加入')
            return
          }
          if (!this.isExistBook(work.worksBookList ?? [])) {
            if (work) {
              this.worksBook = work
            }
            this.workBookListStatus = 2
            this.isShowEditBook = true
          }
        })
      }
    }
    .padding({
      left:20,
      right:20,
      top:12,
      bottom:12
    })
  }
}
import PaddingConstants from '../../../../../common/constants/PaddingConstants';
import bookGroupUtil from '../../../../../common/utils/bookGroupUtils';
import booksUtil from '../../../../../common/utils/booksUtils';
import confirmDialogExample from '../../../../../componets/common/confirmDialog';
import Header from '../../../../../componets/common/Header';
import hideDialogExample from '../../../../../componets/common/hideDialog';
import { showMessage } from '../../../../../componets/common/promptShow';
import { buttonList } from '../../../../../componets/dataList/buttonList';
import IndexSearchType from '../../../../../componets/head/IndexSearchType';
import BookGroupsDao from '../../../../../database/dao/BookGroupsDao';
import booksDao from '../../../../../database/dao/BooksDao';
import { BookGroups } from '../../../../../database/entities/BookGroups';
import { Books } from '../../../../../database/entities/Books';
import BookSelectGroupDialog from './BookSelectGroupDialog';
import BookFolderManages from '../../Manage/bookManage/BookFolderManages';
import bookListManage from '../../Manage/bookManage/bookListManage';
import catalogAddShelf from '../../Manage/components/catalogAddShelf';
import CommonConstants from '../../../../../common/constants/CommonConstants';
import WorksBookLists from '../../Shelf/WorksBookLists';
import { WorksLists } from '../../../../../database/entities/WorksLists';
import worksListsDao from '../../../../../database/dao/WorksListsDao';
import worksListsUtils from '../../../../../common/utils/WorksListsUtils';
import { ThemeItem } from '../../../../../common/model/Theme';
import { ThemeStorageKey } from '../../../../../common/constants/Theme';


/**
 * 书籍管理对话框组件
 * 
 * 功能概述：
 * 1. 提供批量管理功能：支持书籍、分组、书单的批量操作
 * 2. 支持多种操作：置顶/取消置顶、移动至分组、加入书单、隐藏分组、删除等
 * 3. 提供列表/宫格两种展示模式切换
 * 4. 支持全选/取消全选功能
 * 5. 集成搜索和筛选功能
 * 
 * 使用场景：
 * - 在分组页面单击进入批量管理模式
 * - 支持对书籍、分组、书单进行批量操作
 * 
 * 组件特点：
 * - 支持三种数据类型管理：书籍(bookTypeNumber≠1,5)、分组(bookTypeNumber=1)、书单(bookTypeNumber=5)
 * - 动态底部操作栏：根据数据类型显示不同的操作按钮
 * - 动画过渡效果：管理模式的进入和退出有平滑动画
 * - 状态同步：通过@StorageLink与AppStorage同步刷新状态
 */
@Component
export default  struct BookManageDialog {
  /** 当前索引，用于区分不同的书籍类型或分类 */
  @Prop currentIndex: number
  
  /** 展示模式：'标签'、'列表'或'宫格'，控制UI的展示方式 */
  @State EXHIBIT: string = '标签'
  
  /** 对话框标题，显示在顶部中央位置 */
  @Prop title:string
  
  /** 
   * 书籍类型编号，用于区分管理的数据类型：
   * - 1: 分组管理
   * - 5: 书单管理
   * - 其他: 书籍管理
   */
  @Prop bookTypeNumber:number
  
  /** 顶部矩形高度，通过@StorageLink与AppStorage同步，用于适配不同屏幕 */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 底部矩形高度，通过@StorageLink与AppStorage同步，用于适配不同屏幕 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 是否显示添加书单弹窗 */
  @State isAddShelfShow:boolean = false
  
  /** 是否处于管理模式，控制UI的显示/隐藏状态 */
  @Prop isManage:boolean = false
  
  /** 是否为管理搜索模式，影响完成按钮的行为 */
  @Prop isManageSearch:boolean = false
  
  /** 置顶按钮标题，根据选中项的置顶状态动态变化：'置顶'或'取消置顶' */
  @State topTitle:string = '置顶'
  
  /** 书籍列表数据，用于书籍管理 */
  @State bookList:Books[] = []
  
  /** 
   * 复选框状态记录，键为项目ID，值为是否选中
   * 使用@Watch装饰器监听变化，变化时触发listenCheckList方法
   */
  @State @Watch('listenCheckList')checkLists: Record<number, boolean> = {}
  
  /** 选中的项目ID数组，从checkLists中提取的选中项 */
  @State checkListNumber:number[] = []
  
  /** 分组列表数据，用于分组管理 */
  @State bookGroups:BookGroups[] = []
  
  /** 书单列表数据，用于书单管理 */
  @State worksLists:WorksLists[] =[] //书单
  
  /** 书籍刷新状态标识，通过@StorageLink与AppStorage同步，触发书籍数据刷新 */
  @StorageLink('BOOK_IS_BOOK_REFRESHING') isBookRefreshing: number = 0
  
  /** 
   * 分组刷新状态标识，通过@StorageLink与AppStorage同步，触发分组数据刷新
   * 使用@Watch装饰器监听变化，变化时触发getGroupList方法
   */
  @StorageLink('BOOK_IS_BOOK_GROUPS_REFRESHING') @Watch('getGroupList')BOOK_IS_BOOK_GROUPS_REFRESHING: number = 0
  
  /** 搜索检查回调函数，用于管理搜索模式下的选中项传递 */
  searchCheck:Function = (_checkListNumber?:number[])=>{

  }
  /**
   * 判断是否全部置顶或取消置顶
   * 
   * 功能：根据选中项的置顶状态，动态更新置顶按钮的标题
   * 逻辑：
   * 1. 如果没有选中项，按钮标题设为'置顶'
   * 2. 遍历所有选中项，统计已置顶的数量
   * 3. 根据数据类型（书籍、分组、书单）查询对应的置顶状态
   * 4. 如果全部选中项都已置顶，按钮标题设为'取消置顶'，否则设为'置顶'
   */
  selectIsAllTop(){
    let allTopNumber = 0
    if (this.checkListNumber.length <= 0){
      this.topTitle = '置顶'
      return
    }
    this.checkListNumber.forEach((index)=>{
      //从bookList更具id查询是否都isTop
      if (this.bookTypeNumber === 5){
        this.worksLists.filter((item)=>{
          if (item.isTop && Number(index) === item.worksId){
            allTopNumber++
          }
        })
      } else if (this.bookTypeNumber === 1){
        this.bookGroups.filter((item)=>{
          if (item.isTop && Number(index) === item.groupId && !item.isSystem){
            allTopNumber++
          }
        })
      } else {
        this.bookList.filter((item)=>{
          if (item.isTop && Number(index) === item.id){
            allTopNumber++
          }
        })
      }
   
    })
    if (allTopNumber === this.checkListNumber.length) {
      this.topTitle = '取消置顶'
    } else {
      this.topTitle = '置顶'
    }
  }
  
  /**
   * 获取书籍列表
   * 
   * 功能：从数据库查询当前类型和分组的书籍数据
   * 查询条件：
   * - type: 当前索引（书籍类型）
   * - bookGroup: 书籍类型编号（分组ID）
   * - order: 排序方式（searchValue）
   * 分页：第1页，每页100条
   */
  getBookList(){
    booksDao.searchPage({
      type:this.currentIndex,
      bookGroup:this.bookTypeNumber,
      order:this.searchValue
    },1,100).then((val)=>{
      this.bookList = val
    })
  }
  
  /**
   * 获取书单列表
   * 
   * 功能：从数据库查询当前类型的书单数据
   * 查询条件：type - 当前索引（书单类型）
   */
  getWorkLists() {
    worksListsDao.search({
      type:this.currentIndex
    }).then((val)=>{
      this.worksLists = val
    })
  }
  
  /**
   * 获取分组列表
   * 
   * 功能：从数据库查询当前类型的分组数据
   * 查询条件：type - 当前索引（分组类型）
   * 注意：此方法被@Watch('getGroupList')装饰器监听，当BOOK_IS_BOOK_GROUPS_REFRESHING变化时自动调用
   */
  getGroupList(){
    BookGroupsDao.search({
      type:this.currentIndex
    }).then((val)=>{
      this.bookGroups = val
    })
  }
  
  /**
   * 组件初始化方法
   * 
   * 功能：在组件即将显示时调用，根据bookTypeNumber加载对应的数据
   * 逻辑：
   * - bookTypeNumber=1: 加载分组数据，设置isMoveStatus=1
   * - bookTypeNumber=5: 加载书单数据，设置isMoveStatus=2
   * - 其他: 加载书籍数据，设置isMoveStatus=0
   */
  aboutToAppear(): void {
    if (this.bookTypeNumber === 1) {
      this.getGroupList()
      this.isMoveStatus = 1
    } else if (this.bookTypeNumber === 5){
      this.getWorkLists()
      this.isMoveStatus = 2
    } else {
      this.getBookList()
      this.isMoveStatus = 0
    }
  }

  /** 是否显示书单添加弹窗 */
  @State isCatalogAddShelf:boolean = false
  
  /** 操作类型：0-书籍，1-文件夹（分组） */
  @State bookOrFolder:number = 0
  
  /**
   * 构建组件UI布局
   * 
   * 布局结构：
   * 1. 顶部标题栏（非管理模式时显示）
   * 2. 管理头部（管理模式时显示，包含全选、选中数量、完成按钮）
   * 3. 主要内容区域（bookManage构建器）
   * 4. 书单添加弹窗绑定
   * 
   * 动画效果：
   * - 顶部标题栏：管理模式时淡出、缩放、隐藏
   * - 管理头部：管理模式时淡入、从上方滑入
   * - 使用CommonConstants.UniCurve动画曲线，500ms持续时间
   */
  build() {
    Column(){
      // 顶部标题栏（非管理模式）
      Column(){
        this.headTitleManage()
      }
      .visibility(!this.isManage?Visibility.Visible:Visibility.None)
      .opacity(!this.isManage?1:0)
      .scale({
        y: !this.isManage? 1 : 0,  // 垂直缩放
      })
      .animation({
        duration: 500,
        curve: CommonConstants.UniCurve
      })
      
      // 管理头部（管理模式）
      Header({
        customLeftBuilder: () => {
          this.selectAll()  // 左侧：全选按钮
        },
        title:`已选${this.checkListNumber.length}项`,  // 标题：显示选中数量
        customRightBuilder: () => {
          this.complete()  // 右侧：完成按钮
        },
        paddingTop:-30  // 顶部内边距调整
      })
        .visibility(this.isManage?Visibility.Visible:Visibility.None)
        .opacity(this.isManage?1:0)
        .translate({ y: this.isManage ? 0 : -50})  // 垂直平移
        .animation({
          duration: 500,
          curve: CommonConstants.UniCurve
        })

      // 主要内容区域
      Column(){
        this.bookManage()
      }
      .layoutWeight(1)  // 占据剩余空间

      // 绑定书单添加弹窗（底部弹窗）
      Flex()
        .bindSheet($$this.isCatalogAddShelf, this.dialogCatalogAddShelf(), {
          height:400,  // 弹窗高度
          dragBar: true,  // 显示拖拽条
          showClose: false,  // 不显示关闭按钮
          onDisappear: () => {
            this.isCatalogAddShelf = false  // 弹窗消失时重置状态
          }
        })
    }
    .padding({
      bottom:this.bottomRectHeight  // 底部内边距，适配屏幕
    })
  }

  /**
   * 主要操作页面构建器
   * 
   * 功能：构建管理页面的主要内容区域，包含数据列表和底部操作栏
   * 布局：Flex布局，垂直方向，内容居中
   * 
   * 内容结构：
   * 1. 数据列表区域（Scroll组件）
   *    - bookTypeNumber=5: 书单列表（WorksBookLists）
   *    - bookTypeNumber=1: 分组列表（BookFolderManages）
   *    - 其他: 书籍列表（bookListManage）
   * 2. 底部操作栏区域
   *    - bookTypeNumber=5: 删除按钮（footerDel）
   *    - 其他: 完整操作按钮（footerTitle）
   * 
   * 动画效果：底部操作栏在管理模式时淡入、从下方滑入
   */
  @Builder bookManage(){
    Flex({
      justifyContent:FlexAlign.SpaceBetween,
      alignContent:FlexAlign.Center,
      alignItems:ItemAlign.Center,
      direction:FlexDirection.Column,
      wrap:FlexWrap.NoWrap
    }) {
      Column(){
        Scroll(){
          if (this.bookTypeNumber === 5){
            // 书单列表
            WorksBookLists({
              worksLists:this.worksLists,
              checkGroup:this.checkLists,
              EXHIBIT:this.EXHIBIT,
              isShowCheck:true
            })
          } else {
            if (this.bookTypeNumber === 1){
              // 分组列表
              BookFolderManages({
                checkGroup:this.checkLists,
                EXHIBIT:this.EXHIBIT,
                bookGroups:this.bookGroups,
                isManage:this.isManage
              })
            } else {
              // 书籍列表
              bookListManage({
                checkGroup:this.checkLists,
                EXHIBIT:this.EXHIBIT,
                bookList:this.bookList,
                isManage:this.isManage,
                onSelect:()=>{
                  this.listenCheckList()  // 选择变化时监听
                }
              })
            }
          }
        }
        .layoutWeight(1)  // 占据剩余空间
        .align(Alignment.TopStart)  // 顶部对齐
        .scrollBar(BarState.Off)  // 关闭滚动条
      }
      Column(){
        Divider()  // 分割线
        if (this.bookTypeNumber === 5){
          this.footerDel()  // 书单：删除按钮
        } else {
          this.footerTitle()  // 书籍/分组：完整操作按钮
        }
      }
      .visibility(this.isManage && !this.isManageSearch?Visibility.Visible:Visibility.None)
      .opacity(this.isManage?1:0)
      .translate({ y: this.isManage ? 0 : 50})  // 垂直平移
      .animation({
        duration: 500,
        curve: CommonConstants.UniCurve
      })
    }
  }
  
  /** 标题管理文本 */
  @State titleManage:string = '最近阅读'
  
  /** 搜索值，用于排序和筛选 */
  @State searchValue: string = '最近阅读'
  
  /** 主题颜色，通过@StorageProp从AppStorage获取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * 头部标题管理构建器
   * 
   * 功能：构建非管理模式下的顶部标题栏
   * 布局：Flex布局，三等分水平分布
   * 
   * 左侧（33%）：搜索类型组件（IndexSearchType）
   * 中间（33%）：对话框标题，居中显示
   * 右侧（33%）：操作按钮区域
   *    - 列表/宫格切换按钮
   *    - 分隔线
   *    - 管理按钮（切换管理模式）
   */
  @Builder headTitleManage(){
    Flex(
      {
        alignItems:ItemAlign.Center,
        justifyContent:FlexAlign.SpaceBetween
      }
    ){
      // 左侧：搜索类型
      Column(){
        IndexSearchType({ title: this.titleManage, searchValue: this.searchValue })
      }
      .alignItems(HorizontalAlign.Start)
      .width('33%')
      
      // 中间：标题
      Column(){
        Text(`${this.title}`)
          .textAlign(TextAlign.Center)
          .fontSize(16).fontWeight(500).fontColor($r('app.string.color_black_88'))
      }
      .width('33%')
      .onClick(()=>{
        // 标题点击事件（暂未实现）
      })
      
      // 右侧：操作按钮
      Row(
        {
          space:12
        }
      ){
        // 列表/宫格切换按钮
        Text(this.EXHIBIT === '列表'?'宫格':'列表')
          .textAlign(TextAlign.Center)
          .fontSize(14).fontWeight(400).fontColor($r('app.string.color_black_88'))
          .onClick(()=>{
            if (this.EXHIBIT === '列表') {
              this.EXHIBIT = '宫格'
            } else {
              this.EXHIBIT = '列表'
            }
          })

        // 分隔线
        Divider()
          .vertical(true)
          .height(15)
          .color('#989797')
          .opacity(0.3)
          .strokeWidth(1)

        // 管理按钮
        Text('管理')
          .textAlign(TextAlign.Center)
          .fontSize(14).fontWeight(400).fontColor($r('app.string.color_black_88'))
          .onClick(()=>{
            this.isManage = !this.isManage  // 切换管理模式
          })
      }
      .justifyContent(FlexAlign.End)
      .width('33%')
    }
    .padding(PaddingConstants.PADDING_20)  // 内边距
  }


  /**
   * 书单添加弹窗构建器
   * 
   * 功能：构建书单添加弹窗的UI内容
   * 使用catalogAddShelf组件，传递选中项和回调函数
   * 
   * 参数：
   * - onClickShelf: 书单选择回调，更新弹窗状态并刷新数据
   * - currentIndex: 当前索引，用于筛选合适的书单
   * - ids: 选中的项目ID数组
   * - bookOrFolder: 操作类型（0-书籍，1-文件夹）
   */
  @Builder dialogCatalogAddShelf(){
    Column(){
      catalogAddShelf({
        onClickShelf:(val:boolean)=>{
          this.isCatalogAddShelf = val  // 更新弹窗显示状态
          this.refreshData()  // 刷新数据
        },
        currentIndex:this.currentIndex,  // 当前索引
        ids:this.checkListNumber,  // 选中项ID数组
        bookOrFolder:this.bookOrFolder  // 操作类型
      })
    }
  }
  
  /** 全选状态 */
  @State allCheck:boolean = false
  
  /**
   * 全选按钮构建器
   * 
   * 功能：构建全选复选框，点击时切换全选状态
   * 逻辑：
   * 1. 点击前验证页面是否有数据
   * 2. 切换全选状态
   * 3. 调用dataMoveCheckList更新所有复选框状态
   * 
   * 样式：使用主题主色作为选中颜色
   */
  @Builder
  selectAll() {
    Row({
      space:5
    }) {
      Checkbox()
        .select(this.allCheck)
        .selectedColor(this.theme.mainColor)  // 使用主题色
        .onClick(() => {
          if (this.verificationDate()) {
            return  // 无数据时返回
          }
          this.allCheck = !this.allCheck  // 切换全选状态
          this.dataMoveCheckList(this.allCheck)  // 更新所有复选框
        })
      // Text(!this.allCheck?'全选':'取消全选')  // 文本标签（注释状态）
    }
    .alignItems(VerticalAlign.Center)
  }
  
  /**
   * 校验页面数据内容
   * 
   * 功能：检查当前页面是否有可操作的数据
   * 逻辑：根据bookTypeNumber检查对应的数据数组是否为空
   * 
   * @returns true-无数据，false-有数据
   */
  verificationDate() {
    switch (this.bookTypeNumber){
      case 1:
        if (this.bookGroups.length === 0){
          showMessage('页面暂无操作数据')
          return true
        }
        break
      case 5:
        if (this.worksLists.length === 0){
          showMessage('页面暂无操作数据')
          return true
        }
        break
      default:
        if (this.bookList.length === 0){
          showMessage('页面暂无操作数据')
          return true
        }
        break
    }
    return false
  }

  /**
   * 遍历列表数据设置复选框状态
   * 
   * 功能：根据传入的value值设置所有复选框的选中状态
   * 逻辑：
   * 1. 清空checkLists
   * 2. 根据bookTypeNumber遍历对应的数据数组
   * 3. 为每个有效项目设置复选框状态
   * 4. 如果value为false，重置全选状态
   * 
   * @param value 要设置的复选框状态（true-全选，false-全不选）
   */
  dataMoveCheckList(value:boolean){
    this.checkLists = {};
    if (this.bookTypeNumber === 1){
      // 分组数据：只处理非系统分组且显示的分组
      this.bookGroups.forEach((item)=>{
        item.groupId && !item.isSystem && item.show ?this.checkLists[item.groupId] = value:''
      })
    } else if (this.bookTypeNumber === 5){
      // 书单数据：处理所有书单
      this.worksLists.forEach((item)=>{
        item.worksId?this.checkLists[item.worksId] = value:''
      })
    } else {
      // 书籍数据：处理所有书籍
      this.bookList.forEach((item)=>{
        item.id?this.checkLists[item.id] = value:''
      })
    }
    if(!value){
      this.allCheck = false;  // 全不选时重置全选状态
    }
  }

  /**
   * 完成按钮构建器
   * 
   * 功能：构建完成按钮，点击时退出管理模式或执行搜索回调
   * 逻辑：
   * - 管理搜索模式：调用searchCheck回调传递选中项
   * - 普通管理模式：切换管理模式并延迟刷新数据
   */
  @Builder
  complete() {
    Column() {
      Text('完成')
    }
    .onClick(async () => {
      if (this.isManageSearch) {
        this.searchCheck(this.checkListNumber)  // 搜索模式回调
      } else {
        this.isManage = !this.isManage  // 切换管理模式
        setTimeout(()=>{
          this.refreshData()  // 延迟刷新数据
        },100)
      }
    })
  }
  
  /**
   * 书单底部操作栏构建器
   * 
   * 功能：构建书单管理的底部操作栏（仅删除按钮）
   * 样式：红色删除按钮，居中显示
   * 逻辑：点击时验证是否有选中项，有则打开删除确认对话框
   */
  @Builder footerDel(){
    Column(){
      Text('删除').fontSize(16).fontWeight(500).lineHeight(24).fontColor('#EF4444')
    }.onClick(()=>{
      if (this.checkListNumber.length <= 0) {
        showMessage('请选择要操作的内容');
        return
      }
      this.delDialog?.open();  // 打开删除确认对话框
    })
    .margin({
      top:PaddingConstants.PADDING_10
    })
    .alignItems(HorizontalAlign.Center)
  }
  
  /** 分组管理操作按钮列表（5个按钮：置顶、移动至、加入书单、隐藏分组、删除） */
  @State buttonListInfo5:buttonList[] = [
    new buttonList(1,'置顶',$r('app.media.top')),
    new buttonList(2,'移动至',$r('app.media.folder')),
    new buttonList(3,'加入书单',$r('app.media.shelf')),
    new buttonList(4,'隐藏分组',$r('app.media.hide')),
    new buttonList(5,'删除',$r('app.media.ic_public_delete'))
  ]

  /** 书籍/书单管理操作按钮列表（4个按钮：置顶、移动至、加入书单、删除） */
  @State buttonListInfo4:buttonList[] = [
    new buttonList(1,'置顶',$r('app.media.top')),
    new buttonList(2,'移动至',$r('app.media.folder')),
    new buttonList(3,'加入书单',$r('app.media.shelf')),
    new buttonList(5,'删除',$r('app.media.ic_public_delete'))
  ]
  
  /**
   * 底部操作栏构建器（书籍/分组管理）
   * 
   * 功能：构建完整的底部操作栏，使用网格布局显示操作按钮
   * 布局：GridRow网格布局，分组管理5列，其他4列
   * 特殊处理：第一个按钮（置顶）显示动态标题（topTitle）
   */
  @Builder footerTitle(){
      GridRow({
        columns:this.bookTypeNumber===1?5:4  // 分组管理5列，其他4列
      }){
        ForEach(this.bookTypeNumber===1?this.buttonListInfo5:this.buttonListInfo4,(item:buttonList)=>{
          GridCol(){
            if (item.id === 1) {
              // 置顶按钮：显示动态标题（置顶/取消置顶）
              Column({
                space:5
              }){
                Image(item.icon).width(25)
                Text(this.topTitle).fontSize(14).fontWeight(500)
              }
              .onClick(()=>{
                this.bookInfoButton(item.id)  // 按钮点击事件
              })
            } else {
              // 其他按钮：显示固定标题
              Column({
                space:5
              }){
                Image(item.icon).width(25)
                Text(item.title).fontSize(14).fontWeight(500)
              }
              .onClick(()=>{
                this.bookInfoButton(item.id)  // 按钮点击事件
              })
            }
          }
        })
      }
      .padding({
        top:10,
        bottom:10
      })
    }
  
  /**
   * 底部操作栏功能处理
   * 
   * 功能：根据按钮ID执行相应的操作
   * 逻辑：
   * 1. 验证是否有选中项
   * 2. 更新选中项列表（dataCheckList）
   * 3. 根据按钮ID执行对应操作
   * 
   * @param index 按钮ID（1-置顶，2-移动至，3-加入书单，4-隐藏分组，5-删除）
   */
  bookInfoButton(index:number){
    if (this.checkListNumber.length <= 0) {
      showMessage('请选择要操作的内容');
      return
    }
    this.dataCheckList()  // 更新选中项列表
    switch (index){
      case 1 :
       this.manageTop(); break;  // 置顶/取消置顶
      case 2 :
        this.bookMoveGroup?.open(); break;  // 打开移动分组对话框
      case 3 :
        this.isCatalogAddShelf = true  // 显示书单添加弹窗
        if (this.bookTypeNumber === 1) {
          this.bookOrFolder = 1  // 分组操作
        } else {
          this.bookOrFolder = 0  // 书籍操作
        }
        this.dataCheckList();  // 更新选中项列表
        break;
      case 4 :
        this.clickHideDialog?.open()  // 打开隐藏分组对话框
        break
      case 5 :
        this.delDialog?.open(); break;  // 打开删除确认对话框
    }
  }
  /**
   * 置顶功能
   * 
   * 功能：批量置顶或取消置顶选中项
   * 逻辑：
   * 1. 根据bookTypeNumber调用不同的工具方法
   *    - bookTypeNumber=5: 书单置顶（暂未实现）
   *    - bookTypeNumber=1: 分组置顶（bookGroupUtil.isTopGroup）
   *    - 其他: 书籍置顶（booksUtil.isTopBook）
   * 2. 延迟500ms后刷新数据、清空选中项、重置置顶按钮标题
   * 3. 显示操作成功提示
   */
  manageTop(){
    if (this.bookTypeNumber === 5) {
      // 书单置顶功能（暂未实现）
    } else if(this.bookTypeNumber === 1){
      bookGroupUtil.isTopGroup(this.checkListNumber, this.topTitle==='置顶'?true:false)
    } else {
      booksUtil.isTopBook(this.checkListNumber, this.topTitle==='置顶'?true:false)
    }
    setTimeout(()=>{
      this.refreshData()  // 刷新数据
      this.checkListNumber = []  // 清空选中项
      this.checkLists = {}  // 清空复选框状态
      this.topTitle = '置顶'  // 重置置顶按钮标题
    },500)
    showMessage('操作成功')  // 显示成功提示
  }
  
  /** 是否删除缓存 */
  @State delCache:boolean = false
  
  /** 
   * 删除确认对话框控制器
   * 
   * 配置参数：
   * - builder: 使用confirmDialogExample组件构建删除确认对话框
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4（响应式布局）
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * confirmDialogExample参数：
   * - confirm: 确认删除回调，调用manageDelete方法
   * - delCache: 是否删除缓存
   */
  delDialog: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      confirm: ()=> { this.manageDelete() },  // 确认删除回调
      delCache:this.delCache  // 是否删除缓存
    }),
    autoCancel: true,  // 自动取消
    alignment: DialogAlignment.Center,  // 居中显示
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25,  // 圆角半径
  })
  
  /**
   * 删除功能
   * 
   * 功能：批量删除选中项
   * 逻辑：
   * 1. 遍历所有选中项
   * 2. 根据bookTypeNumber调用不同的删除方法
   *    - bookTypeNumber=1: 删除分组（bookGroupUtil.delGroupById）
   *    - bookTypeNumber=5: 删除书单（worksListsUtils.delWorksByIds）
   *    - 其他: 删除书籍（booksUtil.delBooksById）
   * 3. 延迟500ms后刷新数据并显示删除成功提示
   * 4. 关闭删除确认对话框
   */
  manageDelete(){
    this.checkListNumber.forEach((item:number)=>{
      switch (this.bookTypeNumber){
        case 1:
          bookGroupUtil.delGroupById(item); break;  // 删除分组
        case 5:
          worksListsUtils.delWorksByIds(item);break;  // 删除书单
        default:
          booksUtil.delBooksById(item);break;  // 删除书籍
      }
    })
    setTimeout(()=>{
      this.refreshData()  // 刷新数据
      showMessage('已删除')  // 显示删除成功提示
    },500)
    this.delDialog?.close()  // 关闭删除确认对话框
  }
  
  /** 
   * 隐藏分组对话框控制器
   * 
   * 配置参数：
   * - builder: 使用hideDialogExample组件构建隐藏分组对话框
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * hideDialogExample参数：
   * - confirm: 确认隐藏回调，调用clickHideAccept方法
   */
  clickHideDialog: CustomDialogController | null = new CustomDialogController({
    builder: hideDialogExample({
      confirm: ()=> { this.clickHideAccept() }  // 确认隐藏回调
    }),
    autoCancel: true,  // 自动取消
    alignment: DialogAlignment.Center,  // 居中显示
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25,  // 圆角半径
  })
  
  /**
   * 隐藏操作
   * 
   * 功能：批量隐藏选中分组
   * 逻辑：
   * 1. 调用bookGroupUtil.updateGroupShow更新分组显示状态
   * 2. 延迟500ms后刷新数据并显示隐藏成功提示
   */
  clickHideAccept() {
   bookGroupUtil.updateGroupShow(this.checkListNumber)  // 更新分组显示状态
    setTimeout(()=>{
      this.refreshData()  // 刷新数据
      showMessage('已隐藏')  // 显示隐藏成功提示
    },500)
  }

  /** 操作状态：0-书籍，1-分组，2-书单 */
  @State isMoveStatus:number = 0
  
  /** 
   * 移动分组对话框控制器
   * 
   * 功能：构建书籍移动分组对话框，使用BookSelectGroupDialog组件
   * 
   * 配置参数：
   * - builder: 使用BookSelectGroupDialog组件构建对话框内容
   * - height: 对话框高度400
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * BookSelectGroupDialog参数：
   * - moveGroup: 分组移动完成回调，延迟刷新数据并关闭对话框
   * - oldGroupId: 原始分组ID（当前bookTypeNumber）
   * - currentIndex: 当前索引
   * - Ids: 要移动的项目ID数组
   * - isMoveStatus: 操作状态（0-书籍，1-分组，2-书单）
   */
  bookMoveGroup: CustomDialogController | null = new CustomDialogController({
    builder: BookSelectGroupDialog({
      moveGroup: ()=> {
        setTimeout(()=>{
          this.refreshData()  // 延迟刷新数据
        },500)
        this.bookMoveGroup?.close()  // 关闭移动分组对话框
      },
      oldGroupId:this.bookTypeNumber,  // 原始分组ID
      currentIndex:this.currentIndex,  // 当前索引
      Ids:this.checkListNumber,  // 要移动的项目ID数组
      isMoveStatus:this.isMoveStatus  // 操作状态
    }),
    height: 400,  // 对话框高度
    autoCancel: true,  // 自动取消
    alignment: DialogAlignment.Center,  // 居中显示
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25,  // 圆角半径
  })

  /**
   * 刷新数据方法
   * 
   * 功能：根据bookTypeNumber刷新对应的数据
   * 逻辑：
   * - bookTypeNumber=1: 刷新分组数据，递增分组刷新标识
   * - bookTypeNumber=5: 刷新书单数据
   * - 其他: 刷新书籍数据，递增书籍刷新标识
   * 最后重置所有复选框为未选中状态
   */
  refreshData(){
   switch (this.bookTypeNumber){
     case 1:
       this.getGroupList();  // 刷新分组数据
       this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 递增分组刷新标识
       break;
     case 5:
       this.getWorkLists();  // 刷新书单数据
       break;
       default:
         this.getBookList();  // 刷新书籍数据
         this.isBookRefreshing++  // 递增书籍刷新标识
         break;
   }
   this.dataMoveCheckList(false)  // 重置所有复选框为未选中状态
  }

  /**
   * 将checkLists转换为选中项ID数组
   * 
   * 功能：从checkLists对象中提取所有值为true的键，转换为数字数组
   * 逻辑：
   * 1. 获取checkLists的所有键
   * 2. 过滤出值为true的键
   * 3. 将字符串键转换为数字
   * 4. 赋值给checkListNumber
   */
  dataCheckList(){
    const keys = Object.keys(this.checkLists)
      .filter(key => this.checkLists[Number(key)])  // 过滤出选中项
      .map(key => Number(key));  // 转换为数字
    this.checkListNumber = keys  // 更新选中项数组
  }
  
  /**
   * 监听复选框状态变化
   * 
   * 功能：当checkLists变化时自动调用（通过@Watch装饰器）
   * 逻辑：
   * 1. 更新选中项列表（dataCheckList）
   * 2. 更新置顶按钮标题（selectIsAllTop）
   * 3. 更新全选状态：有选中项时不全选，无选中项时取消全选
   */
  listenCheckList() {
    this.dataCheckList()  // 更新选中项列表
    this.selectIsAllTop()  // 更新置顶按钮标题
    this.allCheck = this.checkListNumber.length !== 0  // 更新全选状态
  }
}

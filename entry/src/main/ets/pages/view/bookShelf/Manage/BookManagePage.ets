import router from '@ohos.router';
import bookListManage from './bookManage/bookListManage';
import {showMessage} from '../../../../componets/common/promptShow'
import confirmDialogExample from '../../../../componets/common/confirmDialog';
import BookFolderManages from './bookManage/BookFolderManages';
import hideDialogExample from '../../../../componets/common/hideDialog';
import booksDao from '../../../../database/dao/BooksDao';
import { Books } from '../../../../database/entities/Books';
import { buttonList } from '../../../../componets/dataList/buttonList';
import booksUtil from '../../../../common/utils/booksUtils';
import BookSelectGroupDialog from '../components/dialog/BookSelectGroupDialog';
import BookGroupsDao from '../../../../database/dao/BookGroupsDao';
import { BookGroups } from '../../../../database/entities/BookGroups';
import bookGroupUtil from '../../../../common/utils/bookGroupUtils';
import catalogAddShelf from './components/catalogAddShelf';
import Header from '../../../../componets/common/Header';
import WorksBookLists from '../Shelf/WorksBookLists';
import worksListsDao from '../../../../database/dao/WorksListsDao';
import { WorksLists } from '../../../../database/entities/WorksLists';
import worksListsUtils from '../../../../common/utils/WorksListsUtils';
import { ThemeItem } from '../../../../common/model/Theme';
import { ThemeStorageKey } from '../../../../common/constants/Theme';

/**
 * 路由参数类
 * 用于接收从路由传递过来的参数
 */
class routerParams {
  currentIndex:number  // 当前索引（书籍类型）
  EXHIBIT:string  // 展示模式：'标签'、'列表'或'宫格'
  bookTypeNumber:number  // 书籍类型编号：1-分组，5-书单，其他-书籍
  constructor(param:routerParams) {
    this.currentIndex = param.currentIndex
    this.EXHIBIT = param.EXHIBIT
    this.bookTypeNumber = param.bookTypeNumber
  }
}

/**
 * 书籍管理页面组件
 * 
 * 功能概述：
 * 1. 提供独立的书籍管理页面，支持书籍、分组、书单的批量操作
 * 2. 支持多种操作：置顶/取消置顶、移动至分组、加入书单、隐藏分组、删除等
 * 3. 提供列表/宫格两种展示模式切换
 * 4. 支持全选/取消全选功能
 * 5. 集成路由参数传递，从书架页面跳转而来
 * 
 * 使用场景：
 * - 从书架页面点击"管理"按钮跳转到此页面
 * - 提供完整的批量管理功能，作为独立页面使用
 * 
 * 组件特点：
 * - 使用@Entry装饰器，作为页面入口组件
 * - 支持三种数据类型管理：书籍(bookTypeNumber≠1,5)、分组(bookTypeNumber=1)、书单(bookTypeNumber=5)
 * - 动态底部操作栏：根据数据类型显示不同的操作按钮
 * - 渐变背景：使用主题颜色创建渐变背景效果
 * - 状态同步：通过@StorageLink与AppStorage同步刷新状态
 */
@Entry
@Component
struct BookManagePage {
  /** 当前索引，从路由参数获取，用于区分不同的书籍类型或分类 */
  @State currentIndex: number = (router.getParams() as routerParams).currentIndex
  
  /** 展示模式，从路由参数获取：'标签'、'列表'或'宫格'，控制UI的展示方式 */
  @State EXHIBIT: string = (router.getParams() as routerParams).EXHIBIT
  
  /** 
   * 书籍类型编号，从路由参数获取，用于区分管理的数据类型：
   * - 1: 分组管理
   * - 5: 书单管理
   * - 其他: 书籍管理
   */
  @State bookTypeNumber:number = (router.getParams() as routerParams).bookTypeNumber
  
  /** 顶部矩形高度，通过@StorageLink与AppStorage同步，用于适配不同屏幕 */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 底部矩形高度，通过@StorageLink与AppStorage同步，用于适配不同屏幕 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 是否显示添加书单弹窗（暂未使用） */
  @State isAddShelfShow:boolean = false
  
  /** 置顶按钮标题，根据选中项的置顶状态动态变化：'置顶'或'取消置顶' */
  @State topTitle:string = '置顶'
  
  /** 书籍列表数据，用于书籍管理 */
  @State bookList:Books[] = []
  
  /** 
   * 复选框状态记录，键为项目ID，值为是否选中
   * 用于记录用户选择的项目
   */
  @State checkLists: Record<number, boolean> = {}
  
  /** 选中的项目ID数组，从checkLists中提取的选中项 */
  @State checkListNumber:number[] = []
  
  /** 分组列表数据，用于分组管理 */
  @State bookGroups:BookGroups[] = [] // 分组
  
  /** 书单列表数据，用于书单管理 */
  @State worksLists:WorksLists[] =[] //书单
  
  /** 书籍刷新状态标识，通过@StorageLink与AppStorage同步，触发书籍数据刷新 */
  @StorageLink('BOOK_IS_BOOK_REFRESHING') isBookRefreshing: number = 0
  
  /** 
   * 分组刷新状态标识，通过@StorageLink与AppStorage同步，触发分组数据刷新
   * 使用@Watch装饰器监听变化，变化时触发getGroupList方法
   */
  @StorageLink('BOOK_IS_BOOK_GROUPS_REFRESHING') @Watch('getGroupList')BOOK_IS_BOOK_GROUPS_REFRESHING: number = 0
  
  /** 主题颜色，通过@StorageProp从AppStorage获取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  /**
   * 判断是否全部置顶或取消置顶
   * 
   * 功能：根据选中项的置顶状态，动态更新置顶按钮标题
   * 逻辑：
   * 1. 如果没有选中项，置顶按钮标题为'置顶'
   * 2. 遍历选中项，统计已置顶的数量
   * 3. 根据数据类型（书籍/分组/书单）查询对应的置顶状态
   * 4. 如果所有选中项都已置顶，按钮标题为'取消置顶'，否则为'置顶'
   */
  selectIsAllTop(){
    let allTopNumber = 0
    if (this.checkListNumber.length <= 0){
      this.topTitle = '置顶'
      return
    }
    this.checkListNumber.forEach((index)=>{
      // 根据id查询是否都isTop
      if (this.bookTypeNumber === 5){
        // 书单管理：查询worksLists中的置顶状态
        this.worksLists.filter((item)=>{
          if (item.isTop && Number(index) === item.worksId){
            allTopNumber++
          }
        })
      } else if (this.bookTypeNumber === 1){
        // 分组管理：查询bookGroups中的置顶状态（排除系统分组）
        this.bookGroups.filter((item)=>{
          if (item.isTop && Number(index) === item.groupId && !item.isSystem){
            allTopNumber++
          }

        })
      } else {
        // 书籍管理：查询bookList中的置顶状态
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
   * 获取书单列表
   * 
   * 功能：从数据库查询当前类型的书单数据
   * 使用worksListsDao.search方法，根据currentIndex（类型）查询
   */
  getWorkLists() {
    worksListsDao.search({
      type:this.currentIndex
    }).then((val)=>{
      this.worksLists = val
    })
  }
  
  /**
   * 获取书籍列表
   * 
   * 功能：从数据库查询当前类型的书籍数据
   * 使用booksDao.searchPage方法，分页查询（第1页，每页100条）
   * 参数：type-类型，bookGroup-分组类型
   */
  getBookList(){
    booksDao.searchPage({
      type:this.currentIndex,
      bookGroup:this.bookTypeNumber
    },1,100).then((val)=>{
      this.bookList = val
    })
  }
  
  /**
   * 获取分组列表
   * 
   * 功能：从数据库查询当前类型的分组数据
   * 使用BookGroupsDao.search方法，根据currentIndex（类型）查询
   * 使用@Watch装饰器监听BOOK_IS_BOOK_GROUPS_REFRESHING变化，自动触发
   */
  getGroupList(){
    BookGroupsDao.search({
      type:this.currentIndex
    }).then((val)=>{
      this.bookGroups = val
    })
  }
  
  /**
   * 页面显示时初始化数据
   * 
   * 功能：根据bookTypeNumber初始化对应的数据
   * 逻辑：
   * - bookTypeNumber=1（分组管理）：获取分组列表，设置isMoveStatus=1
   * - bookTypeNumber=5（书单管理）：获取书单列表，设置isMoveStatus=2
   * - 其他（书籍管理）：获取书籍列表，设置isMoveStatus=0
   */
  onPageShow(): void {
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
  
  /** 显示数量（暂未使用） */
  @State showNumber:number = 0
  
  /** 操作类型：0-书籍，1-文件夹/分组 */
  @State bookOrFolder:number = 0
  
  /**
   * 构建页面UI布局
   * 
   * 布局结构：
   * 1. 顶部：自定义Header组件，包含全选按钮、选中数量显示、完成按钮
   * 2. 中部：主要操作区域（bookManage构建器）
   * 3. 底部：绑定书单添加弹窗（底部弹窗）
   * 
   * 设计特点：
   * - 使用渐变背景：从主题主颜色到次要颜色的渐变
   * - 底部边距适配底部矩形高度
   * - 白色背景的主要操作区域
   * - 圆角底部边框
   */
  build() {
    Column(){
      // 顶部：自定义Header组件
      Header({
        customLeftBuilder: () => {
          this.selectAll()  // 全选按钮构建器
        },
        title:`已选${this.checkListNumber.length}项`,  // 显示选中数量
        customRightBuilder: () => {
          this.complete()  // 完成按钮构建器
        }
      })
      
      // 中部：主要操作区域
      Column(){
        this.bookManage()  // 主要操作页面构建器
      }
      .layoutWeight(1)  // 占据剩余空间
      .backgroundColor(Color.White)  // 白色背景
      
      // 底部：绑定书单添加弹窗（底部弹窗）
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
    .margin({
      bottom:this.bottomRectHeight  // 底部边距适配
    })
    .linearGradient({
      direction: GradientDirection.Bottom, // 渐变方向：从下到上
      colors: [[this.theme.mainColor, 0.1],[this.theme.secondColor, 0.2]] // 渐变颜色：主题主颜色和次要颜色
    })
    .borderRadius({ bottomRight: 5, bottomLeft: 5 })  // 底部圆角

  }
  
  /**
   * 主要操作页面构建器
   * 
   * 功能：构建书籍/分组/书单的管理页面
   * 布局结构：
   * 1. 顶部：滚动区域，根据数据类型显示不同的列表组件
   * 2. 底部：操作栏区域，根据数据类型显示不同的操作按钮
   * 
   * 数据类型判断：
   * - bookTypeNumber=5（书单管理）：使用WorksBookLists组件
   * - bookTypeNumber=1（分组管理）：使用BookFolderManages组件
   * - 其他（书籍管理）：使用bookListManage组件
   */
  @Builder bookManage(){
    Flex({
      justifyContent:FlexAlign.SpaceBetween,
      alignContent:FlexAlign.Center,
      alignItems:ItemAlign.Center,
      direction:FlexDirection.Column,
      wrap:FlexWrap.NoWrap
    }) {
      // 顶部：滚动列表区域
      Column(){
        Scroll(){
          if (this.bookTypeNumber === 5){
            // 书单管理：使用WorksBookLists组件
            WorksBookLists({
              worksLists:this.worksLists,
              checkGroup:this.checkLists,
              EXHIBIT:this.EXHIBIT,
              isShowCheck:true,
              onSelect:()=>{
                this.listenCheckList()  // 选择状态变化监听
              }
            })
          } else {
            if (this.bookTypeNumber === 1){
              // 分组管理：使用BookFolderManages组件
              BookFolderManages({
                checkGroup:this.checkLists,
                EXHIBIT:this.EXHIBIT,
                bookGroups:this.bookGroups,
                onSelect:()=>{
                  this.listenCheckList()  // 选择状态变化监听
                }
              })
            } else {
              // 书籍管理：使用bookListManage组件
              bookListManage({
                checkGroup:this.checkLists,
                EXHIBIT:this.EXHIBIT,
                bookList:this.bookList,
                onSelect:()=>{
                  this.listenCheckList()  // 选择状态变化监听
                }
              })
            }
          }
        }
        .layoutWeight(1)  // 占据剩余空间
        .align(Alignment.TopStart)  // 顶部对齐
        .scrollBar(BarState.Off)  // 关闭滚动条
      }
      
      // 底部：操作栏区域
      Column(){
        Divider()  // 分割线
        if (this.bookTypeNumber === 5){
          this.footerDel()  // 书单管理：删除按钮
        } else {
          this.footerTitle()  // 书籍/分组管理：多功能操作栏
        }
      }.backgroundColor(Color.White)  // 白色背景
    }
  }
  
  /**
   * 书单添加弹窗构建器
   * 
   * 功能：构建书单添加弹窗的UI内容
   * 使用catalogAddShelf组件，传递当前选中项信息
   * 
   * 参数：
   * - onClickShelf: 书单选择回调，更新弹窗显示状态并刷新数据
   * - currentIndex: 当前索引（书籍类型）
   * - ids: 选中的项目ID数组
   * - bookOrFolder: 操作类型（0-书籍，1-文件夹/分组）
   */
  @Builder dialogCatalogAddShelf(){
    Column(){
      catalogAddShelf({
        onClickShelf:(val:boolean)=>{
          this.isCatalogAddShelf = val  // 更新弹窗显示状态
          this.refreshData()  // 刷新数据
        },
        currentIndex:this.currentIndex,  // 当前索引
        ids:this.checkListNumber,  // 选中的项目ID数组
        bookOrFolder:this.bookOrFolder  // 操作类型
      })
    }
  }
  /** 全选状态标识 */
  @State allCheck:boolean = false
  
  /**
   * 全选按钮构建器
   * 
   * 功能：构建全选/取消全选按钮
   * 逻辑：
   * 1. 点击复选框时，先验证页面是否有数据
   * 2. 切换全选状态（allCheck）
   * 3. 调用dataMoveCheckList更新所有项目的选中状态
   * 4. 调用listenCheckList更新选中列表和全选状态
   * 
   * 设计特点：
   * - 使用主题主颜色作为复选框选中颜色
   * - 垂直居中对齐
   */
  @Builder
  selectAll() {
    Row({
      space:5
    }) {
      Checkbox()
        .select(this.allCheck)  // 绑定全选状态
        .selectedColor(this.theme.mainColor)  // 使用主题主颜色
        .onClick(() => {
          if (this.verificationDate()) {  // 验证页面是否有数据
            return
          }
          this.allCheck = !this.allCheck  // 切换全选状态
          this.dataMoveCheckList(this.allCheck)  // 更新所有项目的选中状态
          this.listenCheckList()  // 更新选中列表和全选状态
        })
      // Text(!this.allCheck?'全选':'取消全选')  // 注释掉的文本显示
    }

    .alignItems(VerticalAlign.Center)  // 垂直居中对齐
  }
  
  /**
   * 校验页面数据内容
   * 
   * 功能：验证当前页面是否有可操作的数据
   * 逻辑：
   * - bookTypeNumber=1（分组管理）：检查bookGroups是否为空
   * - bookTypeNumber=5（书单管理）：检查worksLists是否为空
   * - 其他（书籍管理）：检查bookList是否为空
   * 
   * @returns 如果页面没有数据返回true，否则返回false
   */
  verificationDate() {
    switch (this.bookTypeNumber){
      case 1:
        if (this.bookGroups.length === 0){
          showMessage('页面暂无操作数据')  // 分组管理无数据提示
          return true
        }
        break
      case 5:
        if (this.worksLists.length === 0){
          showMessage('页面暂无操作数据')  // 书单管理无数据提示
          return true
        }
        break
      default:
        if (this.bookList.length === 0){
          showMessage('页面暂无操作数据')  // 书籍管理无数据提示
          return true
        }
        break
    }
    return false
  }

  /**
   * 遍历列表数据更新选中状态
   * 
   * 功能：根据全选状态更新所有项目的选中状态
   * 逻辑：
   * 1. 清空checkLists
   * 2. 根据数据类型遍历对应的列表，设置每个项目的选中状态
   * 3. 如果value为false，重置全选状态（allCheck）
   * 
   * 注意：
   * - 分组管理：排除系统分组（!item.isSystem）和隐藏分组（item.show）
   * - 书单管理：只处理有worksId的项目
   * - 书籍管理：只处理有id的项目
   * 
   * @param value 是否选中（true-全选，false-取消全选）
   */
  dataMoveCheckList(value:boolean){
    this.checkLists = {};  // 清空选中状态记录
    if (this.bookTypeNumber === 1){
      // 分组管理：遍历bookGroups，排除系统分组和隐藏分组
      this.bookGroups.forEach((item)=>{
        item.groupId && !item.isSystem && item.show ?this.checkLists[item.groupId] = value:''
      })
    } else if (this.bookTypeNumber === 5){
      // 书单管理：遍历worksLists，只处理有worksId的项目
      this.worksLists.forEach((item)=>{
        item.worksId?this.checkLists[item.worksId] = value:''
      })
    } else {
      // 书籍管理：遍历bookList，只处理有id的项目
      this.bookList.forEach((item)=>{
        item.id?this.checkLists[item.id] = value:''
      })
    }
    if(!value){
      this.allCheck = false;  // 取消全选时重置全选状态
    }
  }

  /**
   * 完成按钮构建器
   * 
   * 功能：构建完成按钮，点击后返回上一页并刷新数据
   * 逻辑：
   * 1. 点击后调用router.back()返回上一页
   * 2. 延迟100ms后刷新数据并触发书籍刷新
   */
  @Builder
  complete() {
    Column() {
      Text('完成')
    }
    .onClick(async () => {
      router.back()  // 返回上一页
      setTimeout(()=>{
        this.refreshData()  // 刷新数据
        this.isBookRefreshing++  // 触发书籍刷新
      },100)
    })
  }
  
  /**
   * 书单底部操作栏构建器
   * 
   * 功能：构建书单管理的底部操作栏（只有删除按钮）
   * 设计特点：
   * - 红色文字（#EF4444）表示危险操作
   * - 水平居中对齐
   * - 20px内边距
   */
  @Builder footerDel(){
    Column(){
      Text('删除').fontSize(16).fontWeight(500).lineHeight(24).fontColor('#EF4444')
    }.onClick(()=>{
      if (this.checkListNumber.length <= 0) {
        showMessage('请选择要操作的内容');  // 未选择内容提示
        return
      }
      this.delDialog?.open();  // 打开删除确认对话框
    })
    .alignItems(HorizontalAlign.Center)  // 水平居中对齐
    .padding(20)  // 内边距
  }
  /** 
   * 分组管理操作按钮列表（5个按钮）
   * 按钮ID对应功能：
   * 1-置顶，2-移动至，3-加入书单，4-隐藏分组，5-删除
   */
  @State buttonListInfo5:buttonList[] = [
    new buttonList(1,'置顶',$r('app.media.top')),
    new buttonList(2,'移动至',$r('app.media.folder')),
    new buttonList(3,'加入书单',$r('app.media.shelf')),
    new buttonList(4,'隐藏分组',$r('app.media.hide')),
    new buttonList(5,'删除',$r('app.media.ic_public_delete'))
  ]

  /** 
   * 书籍管理操作按钮列表（4个按钮）
   * 按钮ID对应功能：
   * 1-置顶，2-移动至，3-加入书单，5-删除
   * 注意：缺少第4个按钮（隐藏分组），因为书籍没有分组隐藏功能
   */
  @State buttonListInfo4:buttonList[] = [
    new buttonList(1,'置顶',$r('app.media.top')),
    new buttonList(2,'移动至',$r('app.media.folder')),
    new buttonList(3,'加入书单',$r('app.media.shelf')),
    new buttonList(5,'删除',$r('app.media.ic_public_delete'))
  ]
  
  /**
   * 底部操作栏构建器
   * 
   * 功能：构建书籍/分组管理的多功能操作栏
   * 布局特点：
   * - 分组管理（bookTypeNumber=1）：5列网格，包含隐藏分组按钮
   * - 书籍管理（其他）：4列网格，不包含隐藏分组按钮
   * - 第1个按钮（置顶）显示动态标题（topTitle）
   * - 其他按钮显示固定标题
   * 
   * 设计特点：
   * - 白色背景
   * - 上下内边距10px
   * - 图标宽度25px
   * - 文字大小14px，字体粗细500
   */
  @Builder footerTitle(){
      GridRow({
        columns:this.bookTypeNumber===1?5:4  // 动态列数：分组管理5列，书籍管理4列
      }){
        ForEach(this.bookTypeNumber===1?this.buttonListInfo5:this.buttonListInfo4,(item:buttonList)=>{
          GridCol(){
            if (item.id === 1) {
              // 第1个按钮（置顶）：显示动态标题
              Column({
                space:5  // 图标和文字间距
              }){
                Image(item.icon).width(25)  // 图标
                Text(this.topTitle).fontSize(14).fontWeight(500)  // 动态标题
              }
              .onClick(()=>{
                this.bookInfoButton(item.id)  // 按钮点击事件
              })
            } else {
              // 其他按钮：显示固定标题
              Column({
                space:5  // 图标和文字间距
              }){
                Image(item.icon).width(25)  // 图标
                Text(item.title).fontSize(14).fontWeight(500)  // 固定标题
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
      .backgroundColor(Color.White)  // 白色背景
    }
  
  /**
   * 底部操作栏功能处理
   * 
   * 功能：根据按钮ID执行相应的操作
   * 逻辑：
   * 1. 验证是否有选中项，没有则提示
   * 2. 更新选中列表（dataCheckList）
   * 3. 根据按钮ID执行对应操作：
   *    - 1（置顶）：执行manageTop方法
   *    - 2（移动至）：打开移动分组对话框
   *    - 3（加入书单）：显示书单添加弹窗，根据数据类型设置bookOrFolder
   *    - 4（隐藏分组）：打开隐藏分组确认对话框（仅分组管理）
   *    - 5（删除）：打开删除确认对话框
   * 
   * @param index 按钮ID（1-5）
   */
  bookInfoButton(index:number){
    if (this.checkListNumber.length <= 0) {
      showMessage('请选择要操作的内容');  // 未选择内容提示
      return
    }
    this.dataCheckList()  // 更新选中列表
    switch (index){
      case 1 :
       this.manageTop(); break;  // 置顶功能
      case 2 :
        this.bookMoveGroup?.open(); break;  // 移动至分组
      case 3 :
        this.isCatalogAddShelf = true  // 显示书单添加弹窗
        if (this.bookTypeNumber === 1) {
          this.bookOrFolder = 1  // 分组管理：操作类型为文件夹/分组
        } else {
          this.bookOrFolder = 0  // 书籍管理：操作类型为书籍
        }
        break;
      case 4 :
        this.clickHideDialog?.open()  // 隐藏分组（仅分组管理）
        break
      case 5 :
        this.delDialog?.open(); break;  // 删除
    }
  }
  
  /**
   * 置顶功能
   * 
   * 功能：批量置顶或取消置顶选中项
   * 逻辑：
   * 1. 根据数据类型调用不同的工具方法：
   *    - 分组管理：调用bookGroupUtil.isTopGroup
   *    - 书籍管理：调用booksUtil.isTopBook
   * 2. 根据topTitle判断是置顶还是取消置顶
   * 3. 延迟500ms后刷新数据，清空选中状态，重置置顶按钮标题，显示操作成功提示
   */
  manageTop(){
    if(this.bookTypeNumber === 1){
      // 分组管理：批量置顶/取消置顶分组
      bookGroupUtil.isTopGroup(this.checkListNumber, this.topTitle==='置顶'?true:false)
    } else {
      // 书籍管理：批量置顶/取消置顶书籍
      booksUtil.isTopBook(this.checkListNumber, this.topTitle==='置顶'?true:false)
    }
    setTimeout(()=>{
      this.refreshData()  // 刷新数据
      this.checkListNumber = []  // 清空选中列表
      this.checkLists = {}  // 清空选中状态记录
      this.topTitle = '置顶'  // 重置置顶按钮标题
      showMessage('操作成功')  // 显示操作成功提示
    },500)
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
   * - gridCount: 网格数量为4
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
   * 1. 遍历选中项列表（checkListNumber）
   * 2. 根据数据类型调用不同的删除方法：
   *    - 分组管理（bookTypeNumber=1）：调用bookGroupUtil.delGroupById
   *    - 书单管理（bookTypeNumber=5）：调用worksListsUtils.delWorksByIds
   *    - 书籍管理（其他）：调用booksUtil.delBooksById
   * 3. 延迟500ms后刷新数据，显示删除成功提示，关闭删除对话框
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
    this.delDialog?.close()  // 关闭删除对话框
  }
  
  /** 
   * 隐藏分组确认对话框控制器
   * 
   * 配置参数：
   * - builder: 使用hideDialogExample组件构建隐藏确认对话框
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
   * 2. 延迟500ms后刷新数据，显示隐藏成功提示
   * 
   * 注意：此功能仅用于分组管理（bookTypeNumber=1）
   */
  clickHideAccept() {
   bookGroupUtil.updateGroupShow(this.checkListNumber)  // 更新分组显示状态
    setTimeout(()=>{
      this.refreshData()  // 刷新数据
      showMessage('已隐藏')  // 显示隐藏成功提示
    },500)
  }

  /** 操作状态：0-书籍移动，1-分组移动，2-书单移动 */
  @State isMoveStatus:number = 0
  
  /** 
   * 移动分组对话框控制器
   * 
   * 配置参数：
   * - builder: 使用BookSelectGroupDialog组件构建移动分组对话框
   * - height: 对话框高度400
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * BookSelectGroupDialog参数：
   * - moveGroup: 分组移动完成回调，延迟刷新数据，关闭对话框
   * - oldGroupId: 原始分组类型（bookTypeNumber）
   * - currentIndex: 当前索引（书籍类型）
   * - Ids: 选中的项目ID数组
   * - isMoveStatus: 操作状态（0-书籍，1-分组，2-书单）
   */
  bookMoveGroup: CustomDialogController | null = new CustomDialogController({
    builder: BookSelectGroupDialog({
      moveGroup: ()=> {
        setTimeout(()=>{
          this.refreshData()  // 刷新数据
        },500)
        this.bookMoveGroup?.close()  // 关闭移动分组对话框
      },
      oldGroupId:this.bookTypeNumber,  // 原始分组类型
      currentIndex:this.currentIndex,  // 当前索引
      Ids:this.checkListNumber,  // 选中的项目ID数组
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
   * 功能：根据数据类型刷新对应的数据
   * 逻辑：
   * - bookTypeNumber=1（分组管理）：刷新分组列表，触发分组刷新
   * - bookTypeNumber=5（书单管理）：刷新书单列表
   * - 其他（书籍管理）：刷新书籍列表
   * 
   * 注意：刷新后重置选中状态
   */
  refreshData(){
   switch (this.bookTypeNumber){
     case 1:
       this.getGroupList();  // 刷新分组列表
       this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 触发分组刷新
       break;
     case 5:
       this.getWorkLists();  // 刷新书单列表
       break;
       default:
         this.getBookList();  // 刷新书籍列表
         // this.isBookRefreshing++  // 注释掉的书籍刷新触发
         break;
   }
   this.dataMoveCheckList(false)  // 重置选中状态（取消全选）
   this.dataCheckList()  // 更新选中列表
  }

  /**
   * 将checkLists转换为选中项目ID数组
   * 
   * 功能：从checkLists对象中提取选中的项目ID
   * 逻辑：
   * 1. 获取checkLists的所有键（项目ID）
   * 2. 过滤出值为true（选中）的键
   * 3. 将字符串键转换为数字ID
   * 4. 更新checkListNumber数组
   */
  dataCheckList(){
    const keys = Object.keys(this.checkLists)
      .filter(key => this.checkLists[Number(key)])  // 过滤选中的项目
      .map(key => Number(key));  // 转换为数字ID
    this.checkListNumber = keys  // 更新选中项目ID数组
  }
  
  /**
   * 监听选中状态变化
   * 
   * 功能：当选中状态变化时更新相关数据
   * 逻辑：
   * 1. 更新选中列表（dataCheckList）
   * 2. 更新置顶按钮标题（selectIsAllTop）
   * 3. 更新全选状态（allCheck）：如果有选中项则为true，否则为false
   */
  listenCheckList() {
    this.dataCheckList()  // 更新选中列表
    this.selectIsAllTop()  // 更新置顶按钮标题
    this.allCheck = this.checkListNumber.length !== 0  // 更新全选状态
  }
}

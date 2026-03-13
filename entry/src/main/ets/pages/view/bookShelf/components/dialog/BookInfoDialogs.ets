import { buttonList } from '../../../../../componets/dataList/buttonList'
import { Books } from '../../../../../database/entities/Books'
import { router } from '@kit.ArkUI'
import InsideCircleIcon from '../../../../../componets/common/InsideCircleIcon'
import { showMessage } from '../../../../../componets/common/promptShow'
import confirmDialogExample from '../../../../../componets/common/confirmDialog'
import booksUtil from '../../../../../common/utils/booksUtils'
import BookSelectGroupDialog from './BookSelectGroupDialog'
import catalogAddShelf from '../../Manage/components/catalogAddShelf'
import PaddingConstants from '../../../../../common/constants/PaddingConstants'
import CommonConstants from '../../../../../common/constants/CommonConstants'
import BasicDataSource from '../../../../../common/LazyIDataSource/BasicDataSource'

@CustomDialog
/**
 * 书籍长按对话框组件
 * 
 * 功能概述：
 * 1. 显示书籍长按操作对话框，提供置顶/取消置顶、移动至分组、加入书单、删除等操作
 * 2. 支持跳转到书籍详情页面
 * 3. 集成书单添加功能（catalogAddShelf）
 * 4. 管理书籍的置顶状态、分组移动、删除等操作
 * 
 * 使用场景：
 * - 在书架页面长按书籍时弹出此对话框
 * - 提供快捷操作菜单，避免用户进入复杂设置页面
 * 
 * 组件特点：
 * - 使用CustomDialog装饰器，作为自定义对话框组件
 * - 支持数据源更新和状态同步
 * - 集成多个子对话框（删除确认、分组选择、书单添加）
 */
export default struct BookInfoDialogs{
  /** 对话框控制器，用于控制对话框的显示和隐藏 */
  controller?: CustomDialogController
  
  /** 
   * 书籍数据，通过@Prop装饰器从父组件传入
   * 包含书籍的基本信息：id、书名、作者、封面URL、分组ID、类型、置顶状态等
   */
  @Prop bookData:Books
  
  /** 推送提醒状态，暂未使用 */
  @State pushReminder:boolean = false
  
  /** 
   * 操作按钮列表，根据书籍的置顶状态动态生成
   * 包含4个操作按钮：置顶/取消置顶、移动至分组、加入书单、删除
   * 每个按钮包含id、标题、图标三个属性
   */
  @State buttonListInfo:buttonList[] = [
    new buttonList(1,this.bookData.isTop?'取消置顶':'置顶',$r('app.media.top')),
    new buttonList(2,'移动至',$r('app.media.folder')),
    new buttonList(3,'加入书单',$r('app.media.shelf')),
    new buttonList(4,'删除',$r('app.media.ic_public_delete'))
  ]
  
  /** 
   * 书籍数据源，通过@Consume装饰器从祖先组件消费
   * 用于在删除或更新书籍后刷新数据源
   */
  @Consume('booksDataSource')  booksDataSource: BasicDataSource<Books>
  
  /** 取消回调函数，对话框关闭时调用 */
  cancel: () => void = () => {
  }
  
  /** 顶部矩形高度，通过@StorageLink与AppStorage同步 */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 底部矩形高度，通过@StorageLink与AppStorage同步 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 是否显示书单添加弹窗 */
  @State isCatalogAddShelf:boolean = false

  /**
   * 构建对话框UI布局
   * 
   * 布局结构：
   * 1. 顶部：书籍信息展示区（封面、书名、作者）和"书籍详情"跳转按钮
   * 2. 中部：操作按钮网格（4列布局，使用GridRow和GridCol）
   * 3. 底部：取消按钮
   * 4. 绑定书单添加弹窗（通过bindSheet）
   * 
   * 设计特点：
   * - 使用圆角顶部边框（topLeft:20, topRight:20）
   * - 白色背景，符合HarmonyOS设计规范
   * - 响应式布局，适应不同屏幕尺寸
   */
  build() {
    Column(){
      // 书籍信息展示行
      Row(){
        // 左侧：书籍封面和基本信息
        Row({
          space:CommonConstants.SPACE_12
        }){
          // 书籍封面图片
          Image(this.bookData.coverUrl)
            .alt($r('app.media.icon_book_default_cover_one'))  // 加载失败时显示默认封面
            .width(45).height(65)  // 固定尺寸
          // 书籍文字信息列
          Column({
            space:PaddingConstants.PADDING_20
          }){
            // 书籍名称，单行显示，超出部分显示省略号
            Text(this.bookData.bookName).fontSize(16).fontWeight(500).fontColor($r('app.string.color_black_88'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('75%')  // 限制宽度，为右侧按钮留出空间
            // 作者信息
            Text(this.bookData.author).fontSize(12).fontWeight(400).fontColor($r('app.string.color_black_45'))
          }
          .alignItems(HorizontalAlign.Start)  // 左对齐
        }
        .width('80%')  // 占据80%宽度

        // 右侧："书籍详情"跳转按钮
        Row({
          space:8
        }){
          Text('书籍详情').fontSize(12).fontWeight(400).fontColor($r('app.string.color_black_45'))
          Image($r('app.media.icon_right')).width(20).height(20).fillColor($r('app.string.color_black_45'))
        } .onClick(()=>{
          // 跳转到书籍详情页面，传递当前书籍数据作为参数
          router.pushUrl({
            url: 'pages/view/BookDetailPage',
            params: this.bookData
          })
          this.controller?.close()  // 关闭当前对话框
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)  // 左右两端对齐
      .margin(20)  // 外边距
      
      // 分割线
      Divider().strokeWidth(0.5).padding({bottom:16})
      
      // 操作按钮网格（4列布局）
      GridRow({
        columns:4  // 4列网格
      }){
        // 遍历按钮列表，为每个按钮创建网格列
        ForEach(this.buttonListInfo,(item:buttonList)=>{
          GridCol(){
            // 使用InsideCircleIcon组件显示圆形图标按钮
            InsideCircleIcon({
              icon:item.icon,
              title:item.title
            })
              .onClick(()=>{
                // 按钮点击事件，根据按钮ID执行相应操作
                this.bookInfoButton(item.id)
              })
          }
        })
      }
      
      // 分割线
      Divider().strokeWidth(0.5).padding({bottom:16})
      
      // 取消按钮区域
      Column(){
        Text('取消').fontColor('rgba(0, 0, 0, 0.88)').fontSize(16).fontWeight(400).lineHeight(24).textAlign(TextAlign.Center)
      }
      .onClick(()=>{
        // 点击取消按钮，执行取消回调并关闭对话框
        this.cancel()
        this.controller?.close()
      })
      .alignItems(HorizontalAlign.Center)  // 水平居中
      .padding({bottom:16})  // 底部内边距

      // 绑定书单添加弹窗（底部弹窗）
      Flex()
        .bindSheet($$this.isCatalogAddShelf, this.dialogCatalogAddShelf(), {
          height:400,  // 弹窗高度
          dragBar: true,  // 显示拖拽条
          showClose: false,  // 不显示关闭按钮
          onDisappear: () => {
            // 弹窗消失时重置状态
            this.isCatalogAddShelf = false
          }
        })
    }
    .borderRadius({topLeft:20,topRight:20})  // 顶部圆角
    .backgroundColor(Color.White)  // 白色背景
    .width('100%')  // 全宽
  }

  /**
   * 书单添加弹窗构建器
   * 
   * 功能：构建书单添加弹窗的UI内容
   * 使用@Builder装饰器，创建可复用的UI片段
   * 
   * 参数传递：
   * - onClickShelf: 书单选择回调，控制弹窗显示状态
   * - currentIndex: 当前书籍类型，用于筛选合适的书单
   * - ids: 书籍ID数组，当前只包含当前书籍的ID
   * 
   * @returns 包含catalogAddShelf组件的Column容器
   */
  @Builder dialogCatalogAddShelf(){
    Column(){
      // 使用catalogAddShelf组件，传递必要的参数
      catalogAddShelf({
        onClickShelf:(val:boolean)=>{
          this.isCatalogAddShelf = val  // 更新弹窗显示状态
        },
        currentIndex:this.bookData.bookType,  // 当前书籍类型
        ids:this.bookData.id ? [this.bookData.id]:[]  // 书籍ID数组
      })
    }
  }

  /**
   * 操作按钮点击事件处理
   * 
   * 根据按钮ID执行相应的操作：
   * - ID 1: 置顶/取消置顶书籍
   * - ID 2: 打开移动分组对话框
   * - ID 3: 显示书单添加弹窗
   * - ID 4: 打开删除确认对话框
   * 
   * @param id 按钮ID，对应buttonList中的id属性
   */
  bookInfoButton(id:number){
    switch (id){
      case 1 :
        this.isTopBook(); break;  // 置顶/取消置顶
      case 2 :
        this.bookMoveGroup?.open(); break;  // 打开移动分组对话框
      case 3 :
        this.isCatalogAddShelf = true;break;  // 显示书单添加弹窗
      case 4 :
        this.bookDelDialog?.open(); break;  // 打开删除确认对话框
    }
  }

  /** 是否删除缓存，用于删除确认对话框 */
  @State delCache:boolean = false
  
  /** 
   * 删除确认对话框控制器
   * 使用confirmDialogExample组件构建删除确认对话框
   * 
   * 配置参数：
   * - builder: 对话框内容构建器，使用confirmDialogExample组件
   * - cancel: 取消回调函数，调用exitApp方法
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4（响应式布局）
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   */
  bookDelDialog: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      confirm: ()=> { this.deleteGroup() },  // 确认删除回调
      delCache:this.delCache  // 是否删除缓存
    }),
    cancel: this.exitApp,  // 取消回调
    autoCancel: true,  // 自动取消
    alignment: DialogAlignment.Center,  // 居中显示
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25,  // 圆角半径
  })

  /**
   * 删除分组操作
   * 执行删除书籍操作并调用取消回调
   */
  deleteGroup() {
    this.deleteBook()
    this.cancel()
  }

  /**
   * 退出应用（关闭删除确认对话框）
   */
  exitApp() {
    this.bookDelDialog?.close()
  }
  
  /** 
   * 书籍刷新状态标识，通过@StorageLink与AppStorage同步
   * 当书籍数据发生变化时递增此值，触发相关组件重新加载数据
   */
  @StorageLink('BOOK_IS_BOOK_REFRESHING') isBookRefreshing: number = 0

  /**
   * 删除书籍
   * 
   * 功能：
   * 1. 调用booksUtil.delBooksById删除数据库中的书籍记录
   * 2. 延迟200ms后刷新书籍数据并关闭对话框
   * 3. 显示删除成功提示
   * 
   * 注意：注释掉的代码展示了从数据源删除数据的替代方案
   */
  async deleteBook(){
    if (this.bookData.id){
      booksUtil.delBooksById(this.bookData.id)  // 从数据库删除书籍
    }
    // let index = this.booksDataSource.getIndex(this.bookData)
    // this.booksDataSource.deleteData(index)  // 从数据源删除数据（注释方案）
    setTimeout(()=>{
      this.isBookRefreshing++  // 触发数据刷新
      this.controller?.close()  // 关闭对话框
    },200)
    showMessage('删除成功')  // 显示成功提示
  }

  /**
   * 置顶/取消置顶书籍
   * 
   * 功能：
   * 1. 调用booksUtil.isTopBook更新数据库中的置顶状态
   * 2. 根据操作结果显示相应的成功/失败提示
   * 3. 延迟200ms后刷新数据并关闭对话框
   * 
   * 注意：注释掉的代码展示了通过数据源更新置顶状态的替代方案
   * 包括数据重排序逻辑（置顶时移到首位，取消置顶时移到第一个非置顶项之前）
   */
  async isTopBook(){
    if (this.bookData.id){
      booksUtil.isTopBook(this.bookData.id, !this.bookData.isTop).then((val)=>{
        val?showMessage(!this.bookData.isTop?'置顶成功':'取消置顶成功'):showMessage('数据更新失败')
      })
    }
    // let index = this.booksDataSource.getIndex(this.bookData)
    // this.bookData.isTop = !this.bookData.isTop
    // if (this.bookData.isTop){
    //   this.booksDataSource.deleteData(index)
    //   this.booksDataSource.unshiftData(this.bookData)  // 置顶时移到首位
    // } else {
    //   let newIndex = this.getIndexByIsTopFalse()
    //   if (newIndex > 1) {
    //     this.booksDataSource.moveDataUpdate(index, newIndex-1,this.bookData)
    //   }
    //   this.booksDataSource.changeData(newIndex > 1?newIndex - 1:index,this.bookData)
    // }
    setTimeout(()=>{
      this.isBookRefreshing++  // 触发数据刷新
      this.controller?.close()  // 关闭对话框
    },200)

  }
  
  /**
   * 从booksDataSource数据中查询第一个isTop为false的下标
   * 
   * 功能：在数据源数组中查找第一个非置顶的书籍索引
   * 用于取消置顶时确定书籍应该移动到的位置
   * 
   * @returns 第一个isTop为false的书籍索引，如果全部置顶则返回-1
   */
  getIndexByIsTopFalse() {
    const dataArray = this.booksDataSource.getOriginDataArray();
    const index = dataArray.findIndex(item => !item.isTop);
    return index;
  }

  /**
   * 移动分组对话框控制器
   * 
   * 功能：构建书籍移动分组对话框，使用BookSelectGroupDialog组件
   * 
   * 配置参数：
   * - builder: 使用BookSelectGroupDialog组件构建对话框内容
   * - height: 对话框高度400
   * - cancel: 取消回调函数，调用exitApp方法
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * BookSelectGroupDialog参数：
   * - moveGroup: 分组移动完成回调，关闭对话框并刷新数据
   * - oldGroupId: 原始分组ID
   * - currentIndex: 当前书籍类型
   * - Ids: 要移动的书籍ID（当前书籍ID）
   */
  bookMoveGroup: CustomDialogController | null = new CustomDialogController({
    builder: BookSelectGroupDialog({
      moveGroup: ()=> {
        // setTimeout(()=>{
        //   // this.booksDataSource.deleteData(this.bookData)  // 从数据源删除数据（注释方案）
        // },500)
        setTimeout(()=>{
          this.bookMoveGroup?.close()  // 关闭移动分组对话框
          this.controller?.close()  // 关闭主对话框
          this.isBookRefreshing++  // 触发数据刷新
        },200)
      },
      oldGroupId:this.bookData.bookGroup,  // 原始分组ID
      currentIndex:this.bookData.bookType,  // 当前书籍类型
      Ids:this.bookData.id  // 书籍ID
    }),
    height: 400,  // 对话框高度
    cancel: this.exitApp,  // 取消回调
    autoCancel: true,  // 自动取消
    alignment: DialogAlignment.Center,  // 居中显示
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25,  // 圆角半径
  })

  /**
   * 刷新懒加载数据
   * 
   * 功能：重新加载数据源中的数据
   * 当前为注释状态，可根据需要启用
   * 
   * 使用场景：当书籍数据发生变化时，调用此方法刷新数据源
   */
  async refreshLazyData(){
    // this.booksDataSource.reloadNewData([this.bookData])  // 重新加载数据（注释方案）
  }

}
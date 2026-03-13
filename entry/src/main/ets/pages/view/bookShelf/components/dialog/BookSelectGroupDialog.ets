/**
 * 移动分组选择对话框组件
 * 
 * 功能概述：
 * 1. 提供分组选择界面，用于将书籍或分组移动到其他分组
 * 2. 支持添加新分组功能
 * 3. 显示当前类型下的所有非系统分组
 * 4. 支持两种移动类型：书籍移动（isMoveStatus=0）和分组移动（isMoveStatus=1）
 * 
 * 使用场景：
 * - 在书籍管理或分组管理中选择"移动至"操作时弹出此对话框
 * - 用户可以选择现有分组或创建新分组进行移动操作
 * 
 * 组件特点：
 * - 使用@CustomDialog装饰器，作为自定义对话框组件
 * - 网格布局显示分组（3列网格）
 * - 集成添加分组功能
 * - 移动前显示确认对话框
 * 
 * @author 2008
 * @datetime 2024/7/25 13:44
 * @className: BookSelectGroupDialog
 */
import CommonConstants from '../../../../../common/constants/CommonConstants'
import PaddingConstants from '../../../../../common/constants/PaddingConstants'
import bookGroupUtils from '../../../../../common/utils/bookGroupUtils'
import booksUtils from '../../../../../common/utils/booksUtils'
import addBookTypeDialog from '../../../../../componets/common/addBookTypeDialog'
import { showMessage } from '../../../../../componets/common/promptShow'
import TitleContentDialog from '../../../../../componets/common/TitleContentDialog'
import BookGroupsDao from '../../../../../database/dao/BookGroupsDao'
import { BookGroups } from '../../../../../database/entities/BookGroups'

@Component
@CustomDialog
export default struct BookSelectGroupDialog{
  /** 原始分组ID，移动时不显示当前所在分组 */
  oldGroupId?:number
  
  /** 对话框控制器，用于控制对话框的显示和隐藏 */
  controller?: CustomDialogController
  
  /** 当前索引，用于筛选对应类型的分组 */
  currentIndex:number = 0
  
  /** 
   * 要移动的项目ID，可以是单个ID或ID数组
   * - 书籍移动：书籍ID数组
   * - 分组移动：分组ID
   */
  Ids:number|number[] = 0
  
  /** 
   * 移动状态标识：
   * - 0: 书籍移动
   * - 1: 分组移动
   */
  isMoveStatus:number = 0
  
  /** 移动完成回调函数，移动操作完成后调用 */
  moveGroup:Function = ()=>{

  }
  
  /** 分组刷新状态标识，通过@StorageLink与AppStorage同步，触发分组数据刷新 */
  @StorageLink('BOOK_IS_BOOK_GROUPS_REFRESHING') BOOK_IS_BOOK_GROUPS_REFRESHING: number = 0
  
  /**
   * 组件初始化方法
   * 功能：在组件即将显示时调用，加载分组列表数据
   */
  aboutToAppear(): void {
    this.getGroupList()
  }

  /** 分组列表数据，存储当前类型下的所有分组 */
  @State groupList:BookGroups[] = []
  
  /**
   * 获取分组列表
   * 功能：从数据库查询当前类型的分组数据
   * 查询条件：type - 当前索引（分组类型）
   */
  getGroupList(){
    BookGroupsDao.search({
      type:this.currentIndex
    }).then((val)=>{
      this.groupList = val
    })
  }

  /**
   * 构建对话框UI布局
   * 
   * 布局结构：
   * 1. 顶部：标题栏（"移动分组"）
   * 2. 中部：分组选择区域（3列网格布局，包含添加按钮和现有分组）
   * 3. 底部：取消按钮
   * 
   * 设计特点：
   * - 使用Scroll组件实现可滚动内容区域
   * - 网格布局：3列，每个分组显示为矩形按钮
   * - 过滤条件：只显示非系统分组、显示状态为true、且不是当前所在分组
   * - 关闭滚动条，保持界面简洁
   */
  build() {
    Column() {
      // 顶部标题栏
      Column(){
        Text('移动分组')
          .fontSize(16)
          .fontWeight(700)
          .lineHeight(24)

      }.padding({right:20,left:20,top:12,bottom:12})

      // 分割线
      Divider().strokeWidth(0.5)
      
      // 分组选择区域（可滚动）
      Scroll(){
        GridRow({
          columns:3  // 3列网格布局
        }){
          // 第一列：添加分组按钮（无参数调用title构建器）
          GridCol(){
            this.title()
          }
          // 遍历分组列表，为每个符合条件的分组创建网格列
          ForEach(this.groupList,(item:BookGroups)=>{
            if (item.groupId && !item.isSystem && item.show && this.oldGroupId !== item.groupId) {
              GridCol(){
                this.title(item)  // 有参数调用title构建器
              }
            }
          })
        }.padding(PaddingConstants.PADDING_20)
      }
      .align(Alignment.Top)  // 顶部对齐
      .height('65%')  // 固定高度
      .scrollBar(BarState.Off)  // 关闭滚动条
      
      // 分割线
      Divider().strokeWidth(0.5)
      
      // 底部取消按钮
      Column() {
        Text('取消').fontSize(16).fontWeight(400)
          .lineHeight(24)
      }
      .onClick(()=>{
        this.controller?.close()  // 点击取消关闭对话框
      })
      .alignItems(HorizontalAlign.Center)  // 水平居中
      .padding({
        left: 32,
        right:32,
        top: 16
      })
    }
    .width(CommonConstants.FULL_WIDTH)  // 全宽
    .height(CommonConstants.FULL_HEIGHT)  // 全高
  }
  
  /** 选中的目标分组ID */
  @State moveGroupId:number = 0
  
  /** 选中的目标分组名称 */
  @State moveTitle:string = ''
  
  /**
   * 分组标题构建器
   * 
   * 功能：构建单个分组项的UI，可以是现有分组或添加按钮
   * 
   * @param item 分组数据（可选），如果为空则显示添加按钮
   * 
   * 布局：
   * - 现有分组：显示分组名称，单行显示，超出部分显示省略号
   * - 添加按钮：显示加号图标
   * 
   * 点击事件：
   * - 添加按钮：打开添加分组对话框
   * - 现有分组：记录选中分组信息，打开移动确认对话框
   */
  @Builder title(item?:BookGroups) {
    Column() {
      if (item){
        // 现有分组：显示分组名称
        Text(item.groupName).fontSize(14).textOverflow({
          overflow:TextOverflow.Ellipsis
        }).ellipsisMode(EllipsisMode.END).maxLines(1)
      } else {
        // 添加按钮：显示加号图标
        Image($r('app.media.add')).width(24)
      }
    }
    .onClick(()=>{
      if(!item){
        this.addBookType?.open()  // 打开添加分组对话框
        return
      }
      if (item.groupId) {
        this.moveGroupId = item.groupId  // 记录选中分组ID
        this.moveTitle = item.groupName  // 记录选中分组名称
        this.clickBookTypeDialog?.open()  // 打开移动确认对话框
      }
    })
    .margin({
      bottom:PaddingConstants.PADDING_16  // 底部外边距
    })
    .width(85).height(36)  // 固定尺寸
    .backgroundColor('rgba(0, 0, 0,0.06)')  // 浅灰色背景
    .padding({
      left:16,
      right:16,
      top:8,
      bottom:8
    })
  }
  /** 新分组名称输入框的值 */
  @State bookType:string = ''
  
  /** 
   * 添加分组对话框控制器
   * 
   * 配置参数：
   * - builder: 使用addBookTypeDialog组件构建添加分组对话框
   * - cancel: 取消回调函数，调用onCancel方法
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4（响应式布局）
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * addBookTypeDialog参数：
   * - cancel: 取消回调，调用onCancel方法
   * - confirm: 确认回调，调用onAccept方法
   * - bookType: 分组名称输入框的绑定值
   */
  addBookType: CustomDialogController | null = new CustomDialogController({
    builder: addBookTypeDialog({
      cancel: ()=> { this.onCancel() },  // 取消回调
      confirm: ()=> { this.onAccept() },  // 确认回调
      bookType: this.bookType  // 分组名称绑定值
    }),
    cancel: this.onCancel,  // 取消回调
    autoCancel: true,  // 自动取消
    alignment: DialogAlignment.Center,  // 居中显示
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25  // 圆角半径
  })
  
  /**
   * 取消添加分组
   * 功能：清空分组名称输入框的值
   */
  onCancel(){
    this.bookType = ''  // 清空输入框
  }
  
  /**
   * 确认添加分组
   * 
   * 功能：验证并添加新分组
   * 逻辑：
   * 1. 验证分组名称是否为空
   * 2. 检查分组名称是否已存在（避免重复）
   * 3. 创建新的BookGroups对象并插入数据库
   * 4. 清空输入框并显示成功提示
   * 5. 延迟500ms后刷新分组列表
   * 
   * 注意：代码中存在一个显示提示的bug，this.bookType在显示提示前已被清空
   */
  onAccept(){
    if (this.bookType.length === 0) {
      showMessage('分组名称不能为空')  // 验证非空
      return
    }
    let isInsert = true
    // 对比bookType看是否在groupList数组中已存在
    this.groupList.forEach((element:BookGroups) => {
      if (element.groupName === this.bookType) {
        showMessage(`已存${this.bookType}分组`)  // 显示重复提示
        this.bookType= ''  // 清空输入框
        isInsert = false  // 标记为不插入
      }
    })
    if(isInsert){
      let bookGroups = new BookGroups()
      bookGroups.groupName = this.bookType  // 设置分组名称
      bookGroups.groupType = this.currentIndex  // 设置分组类型
      BookGroupsDao.insert(bookGroups)  // 插入数据库
      this.bookType= ''  // 清空输入框
      showMessage(`已添加${this.bookType}分组`)  // 注意：此时this.bookType已为空，提示信息有误
      setTimeout(()=>{
        this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 触发分组刷新
        this.getGroupList()  // 重新获取分组列表
      },500)
    }
  }

  /** 
   * 移动分组确认对话框控制器
   * 
   * 配置参数：
   * - builder: 使用TitleContentDialog组件构建确认对话框
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * TitleContentDialog参数：
   * - confirm: 确认回调，异步执行clickBookAccept方法，延迟500ms后调用moveGroup回调
   * - title: 对话框标题，显示"移动分组至{分组名称}"
   */
  clickBookTypeDialog: CustomDialogController | null = new CustomDialogController({
    builder: TitleContentDialog({
      confirm: async ()=> {
        await this.clickBookAccept()  // 执行移动操作
        setTimeout(()=>{
          this.moveGroup()  // 延迟调用移动完成回调
        },500)
      },
      title:`移动分组至${this.moveTitle}`  // 动态标题
    }),
    autoCancel: true,  // 自动取消
    alignment: DialogAlignment.Center,  // 居中显示
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25,  // 圆角半径
  })

  /**
   * 确认移动分组操作
   * 
   * 功能：根据移动状态执行相应的移动操作
   * 逻辑：
   * - isMoveStatus=0（书籍移动）：调用booksUtils.updateBooks更新书籍分组
   * - isMoveStatus=1（分组移动）：调用bookGroupUtils.moveBookByGroupId移动分组内的书籍
   * 
   * 注意：此方法为异步方法，确保移动操作完成后再执行后续回调
   */
  async clickBookAccept() {
    switch (this.isMoveStatus){
      case 0:  // 书籍移动
        booksUtils.updateBooks(this.Ids,this.moveGroupId);  // 更新书籍分组
        break
      case 1:  // 分组移动
        bookGroupUtils.moveBookByGroupId(this.Ids,this.moveGroupId)  // 移动分组内的书籍
        break
    }
    showMessage(`已移动到${this.moveTitle}`)  // 显示移动成功提示
  }

}

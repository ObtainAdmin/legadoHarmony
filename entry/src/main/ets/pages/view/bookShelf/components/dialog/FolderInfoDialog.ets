import bookGroupUtil from '../../../../../common/utils/bookGroupUtils'
import commonInputDialog from '../../../../../componets/common/commonInputDialog'
import confirmDialogExample from '../../../../../componets/common/confirmDialog'
import InsideCircleIcon from '../../../../../componets/common/InsideCircleIcon'
import { showMessage } from '../../../../../componets/common/promptShow'
import TitleContentDialog from '../../../../../componets/common/TitleContentDialog'
import { buttonList } from '../../../../../componets/dataList/buttonList'
import { BookGroups } from '../../../../../database/entities/BookGroups'
import catalogAddShelf from '../../Manage/components/catalogAddShelf'
import BookSelectGroupDialog from './BookSelectGroupDialog'
import coverInfoDialog from './coverInfoDialog'

@CustomDialog
/**
 * 文件夹信息对话框组件
 * 
 * 功能概述：
 * 1. 提供文件夹（分组）长按操作菜单，包含8个功能按钮
 * 2. 支持重命名、置顶/取消置顶、移动至其他分组、加入书单、封面样式设置、显示/隐藏、解散分组、删除等操作
 * 3. 集成更新提醒开关，实时更新分组设置
 * 4. 管理分组显示状态和书籍数量统计
 * 
 * 使用场景：
 * - 在书架页面长按文件夹（分组）时弹出此对话框
 * - 提供完整的文件夹管理功能，避免用户进入复杂设置页面
 * 
 * 组件特点：
 * - 使用@CustomDialog装饰器，作为自定义对话框组件
 * - 8个操作按钮的网格布局（4列×2行）
 * - 集成多个子对话框（重命名、移动分组、封面设置、删除确认等）
 * - 支持实时状态更新和数据库同步
 */
export default struct FolderInfoDialog{
  /** 对话框控制器，用于控制对话框的显示和隐藏 */
  controller?: CustomDialogController
  
  /** 
   * 分组数据，通过@Prop装饰器从父组件传入
   * 包含分组的基本信息：分组ID、分组名称、分组类型、显示状态、置顶状态、封面URL、书籍ID列表等
   */
  @Prop itemData:BookGroups
  
  /** 推送提醒状态，暂未使用 */
  @State pushReminder:boolean = false
  
  /** 
   * 操作按钮列表，包含8个功能按钮
   * 根据分组的显示状态动态生成第6个按钮的标题和图标（显示分组/隐藏分组）
   * 按钮ID对应功能：
   * 1-重命名，2-置顶/取消置顶，3-移动至，4-加入书单，5-封面样式，6-显示/隐藏分组，7-解散分组，8-删除
   */
  @State buttonListInfo:buttonList[] = [
    new buttonList(1,'重命名',$r('app.media.edit')),
    new buttonList(2,'置顶',$r('app.media.top')),
    new buttonList(3,'移动至',$r('app.media.folder')),
    new buttonList(4,'加入书单',$r('app.media.shelf')),
    new buttonList(5,'封面样式',$r('app.media.style_icon')),
    new buttonList(6, this.itemData.show?'隐藏分组':'显示分组',this.itemData.show?$r('app.media.hide'):$r('app.media.show')),
    new buttonList(7,'解散分组',$r('app.media.disband')),
    new buttonList(8,'删除',$r('app.media.ic_public_delete'))
  ]
  
  /** 顶部矩形高度，通过@StorageLink与AppStorage同步，用于适配不同屏幕 */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 底部矩形高度，通过@StorageLink与AppStorage同步，用于适配不同屏幕 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 取消回调函数，对话框关闭时调用 */
  cancel: () => void = () => {

  }

  /** 是否显示书单添加弹窗 */
  @State isCatalogAddShelf:boolean = false

  /** 书籍刷新状态标识，通过@StorageLink与AppStorage同步，触发书籍数据刷新 */
  @StorageLink('BOOK_IS_BOOK_REFRESHING') isBookRefreshing: number = 0
  
  /** 分组刷新状态标识，通过@StorageLink与AppStorage同步，触发分组数据刷新 */
  @StorageLink('BOOK_IS_BOOK_GROUPS_REFRESHING') BOOK_IS_BOOK_GROUPS_REFRESHING: number = 0
  
  /** 置顶按钮标题，根据分组的置顶状态动态变化：'置顶'或'取消置顶' */
  @State topTitle:string = this.itemData.isTop?'取消置顶':'置顶'
  /**
   * 构建对话框UI布局
   * 
   * 布局结构：
   * 1. 顶部：分组信息区域（分组名称、书籍数量）和"更新提醒"开关
   * 2. 中部：操作按钮网格（4列×2行，8个功能按钮）
   * 3. 底部：取消按钮
   * 4. 绑定书单添加弹窗（底部弹窗）
   * 
   * 设计特点：
   * - 使用圆角顶部边框（topLeft:20, topRight:20）
   * - 白色背景，符合HarmonyOS设计规范
   * - 响应式布局，适应不同屏幕尺寸
   * - 第2个按钮（置顶）显示动态标题（topTitle）
   */
  build() {
    Column(){
      // 顶部：分组信息和设置区域
      Flex({
        justifyContent:FlexAlign.SpaceBetween,
        alignItems:ItemAlign.Center
      }){
        // 左侧：分组信息（名称和书籍数量）
        Column(){
          Text(this.itemData.groupName).fontColor('rgba(0, 0, 0, 0.88)').fontSize(16).fontWeight(500).lineHeight(24)
          Text(`共${this.itemData.bookIds?.length||0}本`).fontColor('rgba(0, 0, 0, 0.45)').fontWeight(400).lineHeight(20).fontSize(12)
        }
        // 右侧："更新提醒"开关
        Row(){
          Text('更新提醒')
          Toggle({ type: ToggleType.Switch, isOn: this.itemData.canUpdate})
            .selectedColor("#F60").hoverEffect(HoverEffect.None)  // 橙色选中状态
            .onChange((val)=>{
              this.itemData.canUpdate = val  // 更新分组更新提醒状态
              bookGroupUtil.updatePartialGroup(this.itemData)  // 更新数据库
              setTimeout(()=>{
                this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 触发分组刷新
                showMessage('修改成功!')  // 显示成功提示
              },100)
            })
        }
      }.padding(20)
      
      // 分割线
      Divider().strokeWidth(0.5).padding({bottom:16})
      
      // 中部：操作按钮网格（4列布局）
      GridRow({
        columns:4  // 4列网格
      }){
        // 遍历按钮列表，为每个按钮创建网格列
        ForEach(this.buttonListInfo,(item:buttonList)=>{
          GridCol(){
            if (item.id === 2){
              // 第2个按钮（置顶）：显示动态标题（topTitle）
              InsideCircleIcon({
                icon:item.icon,
                title:this.topTitle  // 动态标题：置顶/取消置顶
              })
                .onClick(()=>{
                  this.folderInfo(item.id)  // 按钮点击事件
                })
            } else {
              // 其他按钮：显示固定标题
              InsideCircleIcon({
                icon:item.icon,
                title:item.title
              })
                .onClick(()=>{
                  this.folderInfo(item.id)  // 按钮点击事件
                })
            }
          }
        })

      }
      
      // 分割线
      Divider().strokeWidth(0.5).padding({bottom:16})
      
      // 底部：取消按钮
      Column(){
        Text('取消').fontColor('rgba(0, 0, 0, 0.88)').fontSize(16).fontWeight(400).lineHeight(24).textAlign(TextAlign.Center)
      }
      .onClick(()=>{
        this.cancel()  // 执行取消回调
        this.controller?.close()  // 关闭对话框
      })
      .alignItems(HorizontalAlign.Center)  // 水平居中
      .padding({bottom:16})
      
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
    .borderRadius({topLeft:20,topRight:20})  // 顶部圆角
    .backgroundColor(Color.White)  // 白色背景
    .width('100%')  // 全宽
  }

  /**
   * 书单添加弹窗构建器
   * 
   * 功能：构建书单添加弹窗的UI内容
   * 使用catalogAddShelf组件，传递当前分组信息
   * 
   * 参数：
   * - onClickShelf: 书单选择回调，更新弹窗显示状态
   * - currentIndex: 当前分组类型（groupType）
   * - ids: 分组ID数组（当前分组ID）
   * - bookOrFolder: 操作类型为1（文件夹/分组）
   */
  @Builder dialogCatalogAddShelf(){
    Column(){
      catalogAddShelf({
        onClickShelf:(val:boolean)=>{
          this.isCatalogAddShelf = val  // 更新弹窗显示状态
        },
        currentIndex:this.itemData.groupType,  // 分组类型
        ids:this.itemData.groupId?[this.itemData.groupId]:[],  // 分组ID数组
        bookOrFolder:1  // 操作类型：文件夹/分组
      })
    }
  }

  /**
   * 文件夹操作功能处理
   * 
   * 功能：根据按钮ID执行相应的操作
   * 逻辑：
   * 1. 重命名（id=1）：打开重命名对话框
   * 2. 置顶/取消置顶（id=2）：执行置顶操作
   * 3. 移动至（id=3）：打开移动分组对话框
   * 4. 加入书单（id=4）：显示书单添加弹窗
   * 5. 封面样式（id=5）：打开封面设置对话框
   * 6. 显示/隐藏分组（id=6）：设置对话框标题和内容，打开隐藏/显示确认对话框
   * 7. 解散分组（id=7）：设置对话框标题和内容，打开解散确认对话框
   * 8. 删除（id=8）：打开删除确认对话框
   * 
   * @param id 按钮ID（1-8）
   */
  folderInfo(id:number){
    switch (id){
      case 1 :
        this.restTitle(); break;  // 重命名
      case 2 :
        this.isFolderTop(); break;  // 置顶/取消置顶
      case 3 :
        this.bookMoveGroup?.open(); break;  // 移动至其他分组
      case 4 :
        this.isCatalogAddShelf = true;break;  // 加入书单
      case 5 :
        this.coverDialog?.open();  // 封面样式设置
        break;
      case 6 :
        showMessage('隐藏分组');  // 显示提示
        if (this.itemData.show) {
          this.dialogTitle = this.dialogHideTitle;  // 隐藏分组标题
          this.dialogContent = this.dialogHideContent;  // 隐藏分组内容
        } else {
          this.dialogTitle = '显示分组'  // 显示分组标题
          this.dialogContent = ''  // 显示分组内容（空）
        }
        this.hideDisbandDelDialog?.open();  // 打开隐藏/显示确认对话框
        break;
      case 7 :
        showMessage('解散分组');  // 显示提示
        this.dialogTitle = this.dialogDisbandTitle;  // 解散分组标题
        this.dialogContent = this.dialogDisbandContent;  // 解散分组内容
        this.hideDisbandDelDialog?.open();  // 打开解散确认对话框
        break;
      case 8 :
       this.groupDelDialog?.open(); break;  // 打开删除确认对话框
    }
  }
  
  /**
   * 打开重命名弹窗
   * 
   * 功能：打开重命名对话框，并初始化输入框值为当前分组名称
   */
  restTitle(){
    this.restTitleDialog?.open()  // 打开重命名对话框
    this.inputValue = this.itemData.groupName  // 初始化输入框值为分组名称
  }
  
  /**
   * 置顶/取消置顶功能
   * 
   * 功能：切换分组的置顶状态
   * 逻辑：
   * 1. 调用bookGroupUtil.isTopGroup更新分组置顶状态
   * 2. 更新itemData.isTop状态
   * 3. 延迟500ms后显示成功提示，更新置顶按钮标题，触发分组刷新
   */
  isFolderTop(){
    if (this.itemData.groupId) {
      bookGroupUtil.isTopGroup(this.itemData.groupId, !this.itemData.isTop)  // 更新置顶状态
      this.itemData.isTop = !this.itemData.isTop  // 更新本地状态
    }

    setTimeout(() => {
      showMessage(this.itemData.isTop? '置顶成功' : '取消置顶成功')  // 显示成功提示
      this.topTitle = this.itemData.isTop?'取消置顶':'置顶'  // 更新置顶按钮标题
      this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 触发分组刷新
    },500)
  }
  /** 重命名输入框的值 */
  @State inputValue:string = ''
  
  /** 
   * 重命名对话框控制器
   * 
   * 配置参数：
   * - builder: 使用commonInputDialog组件构建重命名对话框
   * - gridCount: 网格数量为4（响应式布局）
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * commonInputDialog参数：
   * - textValue: 输入框的绑定值（inputValue）
   * - cancel: 取消回调，调用restTitleCancel方法
   * - confirm: 确认回调，调用restTitleConfirm方法
   * - placeholder: 输入框占位符文本
   * - title: 对话框标题
   */
  restTitleDialog: CustomDialogController | null = new CustomDialogController({
    builder: commonInputDialog({
      textValue:this.inputValue,  // 输入框绑定值
      cancel: () => {
        this.restTitleCancel()  // 取消回调
      },
      confirm: () => {
        this.restTitleConfirm()  // 确认回调
      },
      placeholder:'请输入分组名称',  // 占位符
      title:'重命名'  // 对话框标题
    }),
    gridCount: 4,  // 网格数量
    autoCancel: true,  // 自动取消
    alignment: DialogAlignment.Center,  // 居中显示
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25  // 圆角半径
  })

  /**
   * 取消重命名
   * 功能：关闭重命名对话框并清空输入框
   */
  restTitleCancel(){
    this.restTitleDialog?.close()  // 关闭对话框
    this.inputValue = ''  // 清空输入框
  }

  /**
   * 确认重命名
   * 
   * 功能：验证并更新分组名称
   * 逻辑：
   * 1. 调用bookGroupUtil.onlyGroupUpdateName验证并更新分组名称
   * 2. 如果成功：更新itemData.groupName，显示成功提示，延迟触发分组刷新
   * 3. 如果失败：显示分组名已存在提示
   * 4. 清空输入框并关闭对话框
   * 
   * 注意：此方法为异步方法，需要等待数据库操作完成
   */
  async restTitleConfirm(){
    let result = await bookGroupUtil.onlyGroupUpdateName(this.inputValue, this.itemData.groupId ?? 0)  // 验证并更新分组名称
    if (result) {
      this.itemData.groupName = this.inputValue  // 更新本地分组名称
      showMessage('重命名成功')  // 显示成功提示
      setTimeout(() => {
        this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 触发分组刷新
      },500)
    } else {
      showMessage('已存在其它相同分组名')  // 显示失败提示
    }
    this.inputValue = ''  // 清空输入框
    this.restTitleDialog?.close()  // 关闭对话框
  }

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
   * - moveGroup: 分组移动完成回调，延迟刷新书籍和分组数据，关闭对话框
   * - oldGroupId: 原始分组ID（当前分组ID）
   * - currentIndex: 当前分组类型（groupType）
   * - Ids: 要移动的分组ID（当前分组ID）
   * - isMoveStatus: 操作状态为1（分组移动）
   */
  bookMoveGroup: CustomDialogController | null = new CustomDialogController({
    builder: BookSelectGroupDialog({
      moveGroup: ()=> {
        setTimeout(()=>{
          this.isBookRefreshing++  // 触发书籍刷新
          this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 触发分组刷新
        },500)
        this.bookMoveGroup?.close()  // 关闭移动分组对话框
      },
      oldGroupId:this.itemData.groupId,  // 原始分组ID
      currentIndex:this.itemData.groupType,  // 当前分组类型
      Ids:this.itemData.groupId,  // 要移动的分组ID
      isMoveStatus: 1  // 操作状态：分组移动
    }),
    height: 400,  // 对话框高度
    autoCancel: true,  // 自动取消
    alignment: DialogAlignment.Center,  // 居中显示
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25,  // 圆角半径
  })

  /** 是否删除缓存 */
  @State delCache:boolean = false
  
  /** 
   * 删除分组对话框控制器
   * 
   * 配置参数：
   * - builder: 使用confirmDialogExample组件构建删除确认对话框
   * - cancel: 取消回调函数，调用exitApp方法
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * confirmDialogExample参数：
   * - confirm: 确认删除回调，调用deleteGroup方法
   * - delCache: 是否删除缓存
   */
  groupDelDialog: CustomDialogController | null = new CustomDialogController({
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
   * 删除分组
   * 
   * 功能：删除当前分组
   * 逻辑：
   * 1. 调用bookGroupUtil.delGroupById删除分组
   * 2. 执行取消回调（关闭主对话框）
   * 3. 延迟500ms后触发分组刷新并显示删除成功提示
   */
  deleteGroup() {
    if (this.itemData.groupId) {
      bookGroupUtil.delGroupById(this.itemData.groupId)  // 删除分组
    }
    this.cancel()  // 执行取消回调（关闭主对话框）
    setTimeout(()=>{
      this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 触发分组刷新
      showMessage('删除成功')  // 显示删除成功提示
    },500)
  }

  /**
   * 退出应用（关闭删除对话框）
   * 功能：关闭删除确认对话框
   */
  exitApp() {
    this.groupDelDialog?.close()  // 关闭删除确认对话框
  }
  
  /** 对话框标题（动态设置：隐藏分组/显示分组/解散分组） */
  @State dialogTitle:string = ''
  
  /** 对话框内容（动态设置：隐藏分组说明/解散分组说明） */
  @State dialogContent:string = ''

  /** 隐藏分组对话框标题 */
  @State dialogHideTitle:string = '隐藏分组'
  
  /** 隐藏分组对话框内容 */
  @State dialogHideContent:string = '隐藏后可点击分组标签栏右侧分组管理入口查看隐藏分组并进入'
  
  /** 解散分组对话框标题 */
  @State dialogDisbandTitle:string = '解散分组'
  
  /** 解散分组对话框内容 */
  @State dialogDisbandContent:string = '解散分组后，原组内书籍不会被删除，将自动移动至未分组'

  /** 
   * 隐藏/解散分组对话框控制器
   * 
   * 配置参数：
   * - builder: 使用TitleContentDialog组件构建确认对话框
   * - cancel: 取消回调函数，调用exitApp方法
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * TitleContentDialog参数：
   * - confirm: 确认回调，调用hideOrDisband方法
   * - title: 对话框标题（动态设置）
   * - content: 对话框内容（动态设置）
   */
  hideDisbandDelDialog: CustomDialogController | null = new CustomDialogController({
    builder: TitleContentDialog({
      confirm: ()=> { this.hideOrDisband() },  // 确认回调
      title:this.dialogTitle,  // 动态标题
      content:this.dialogContent  // 动态内容
    }),
    cancel: this.exitApp,  // 取消回调
    autoCancel: true,  // 自动取消
    alignment: DialogAlignment.Center,  // 居中显示
    gridCount: 4,  // 网格数量
    customStyle: false,  // 不使用自定义样式
    cornerRadius: 25,  // 圆角半径
  })
  
  /**
   * 显示/隐藏或解散分组
   * 
   * 功能：根据对话框标题判断执行隐藏/显示操作还是解散操作
   * 逻辑：
   * - 标题为'隐藏分组'或'显示分组'：执行hideGroup方法
   * - 其他标题（解散分组）：执行disbandGroup方法
   */
  hideOrDisband(){
    if (this.dialogTitle === '隐藏分组' || this.dialogTitle === '显示分组') {
      this.hideGroup()  // 隐藏/显示分组
    } else {
      this.disbandGroup()  // 解散分组
    }
  }
  
  /**
   * 解散分组
   * 
   * 功能：解散当前分组，将组内书籍移动到未分组
   * 逻辑：
   * 1. 调用bookGroupUtil.delGroupById解散分组
   * 2. 延迟500ms后触发分组刷新，执行取消回调，显示解散成功提示
   */
  disbandGroup(){
    bookGroupUtil.delGroupById(this.itemData.groupId ?? [])  // 解散分组
    setTimeout(()=>{
      this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 触发分组刷新
      this.cancel()  // 执行取消回调（关闭主对话框）
      showMessage('解散分组成功')  // 显示解散成功提示
    },500)
  }

  /**
   * 隐藏分组
   * 
   * 功能：切换分组的显示状态（显示/隐藏）
   * 逻辑：
   * 1. 切换itemData.show状态
   * 2. 调用bookGroupUtil.updateGroupShow更新分组显示状态
   * 3. 延迟500ms后触发分组刷新，执行取消回调，显示隐藏/显示成功提示
   */
  hideGroup(){
    this.itemData.show = this.itemData.show ? false : true  // 切换显示状态
    if (this.itemData.groupId) {
      bookGroupUtil.updateGroupShow(this.itemData.groupId)  // 更新分组显示状态
    }
    setTimeout(()=>{
      this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 触发分组刷新
      this.cancel()  // 执行取消回调（关闭主对话框）
      showMessage(this.itemData.show ? '隐藏成功' : '显示成功')  // 显示操作成功提示
    },500)
  }

  coverDialog: CustomDialogController | null = new CustomDialogController({
    builder: coverInfoDialog({
      itemData:this.itemData,
      cancel:()=>{
        this.coverCancel()
      }
    }),
    cancel: this.coverCancel,
    autoCancel: true,
    width:'100%',
    alignment: DialogAlignment.Bottom,
    customStyle:true
  })

  coverCancel(){
    this.coverDialog?.close()
  }

}
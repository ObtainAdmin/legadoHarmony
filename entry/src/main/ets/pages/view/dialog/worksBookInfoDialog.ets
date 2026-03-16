// 工具类导入：书单工具函数，提供书单相关操作（如删除书单）
import worksListsUtils from '../../../common/utils/WorksListsUtils'
// 组件导入：确认对话框组件，用于删除确认
import confirmDialogExample from '../../../componets/common/confirmDialog'
// 组件导入：圆形图标组件，用于操作按钮的图标显示
import InsideCircleIcon from '../../../componets/common/InsideCircleIcon'
// 数据模型导入：按钮列表数据模型，定义操作按钮的数据结构
import { buttonList } from '../../../componets/dataList/buttonList'
// 数据库实体导入：书单数据实体，定义书单的数据结构
import { WorksLists } from '../../../database/entities/WorksLists'
// 组件导入：新建/编辑书单组件，用于编辑书单功能
import newBookShelf from '../bookShelf/Manage/bookManage/newBookShelf'
// 组件导入：书单分享对话框组件，用于分享书单功能
import shareWorksBook from './shareWorksBook'

// @CustomDialog装饰器：声明此组件为自定义对话框组件，可通过CustomDialogController控制显示/隐藏
@CustomDialog
/**
 * 书单长按弹窗组件
 * 
 * 功能说明：
 * 1. 提供书单的快捷操作菜单（编辑、分享、删除）
 * 2. 通过长按书单触发显示此对话框
 * 3. 集成编辑书单功能（打开编辑页面）
 * 4. 集成分享书单功能（打开分享对话框）
 * 5. 集成删除书单功能（显示确认对话框）
 * 
 * 使用方法：
 * 1. 通过CustomDialogController打开此对话框
 * 2. 传入works参数作为要操作的书单数据
 * 3. 用户点击操作按钮后执行相应功能
 * 
 * 参数说明：
 * @controller - 自定义对话框控制器，用于控制对话框的显示和隐藏
 * @works - 书单数据，包含书单ID、名称、类型等信息
 * @buttonListInfo - 操作按钮列表，包含3种操作：编辑、分享、删除
 * @isShowEditBook - 编辑书单对话框显示状态
 * @isWorksBookListRefreshing - 书单列表刷新状态（通过@StorageLink实现跨组件状态同步）
 * @shareShelfBookDialog - 分享书单对话框控制器
 * @delDialog - 删除确认对话框控制器
 * @delCache - 删除缓存状态（传递给确认对话框）
 * 
 * 技术实现说明：
 * 1. 使用GridRow实现3个操作按钮的网格布局
 * 2. 使用bindContentCover实现编辑书单页面的全屏覆盖
 * 3. 使用CustomDialogController管理嵌套对话框（分享和删除确认）
 * 4. 使用@StorageLink实现跨组件的状态同步（书单列表刷新）
 * 
 * 注意事项：
 * 1. 删除操作需要用户二次确认
 * 2. 编辑书单后会自动刷新书单列表
 * 3. 分享功能调用独立的分享对话框组件
 */
export default struct worksBookInfoDialog{
  // 对话框控制器：可选参数，用于控制对话框的显示和隐藏
  // 当通过CustomDialogController打开对话框时，系统会自动注入此控制器
  controller?: CustomDialogController
  
  // 书单数据：通过@Prop装饰器声明为组件的输入属性
  // 类型为WorksLists，包含书单的完整信息
  // @Prop装饰器表示此属性由父组件传入，组件内部不能修改
  @Prop works:WorksLists
  
  // 操作按钮列表：通过@State装饰器声明为组件的状态变量
  // @State装饰器表示此变量是响应式的，当其值变化时会触发UI更新
  // 包含3种操作：编辑、分享、删除，每个按钮包含id、标题和图标资源
  @State buttonListInfo:buttonList[] = [
    new buttonList(1,'编辑',$r('app.media.edit')),
    new buttonList(2,'分享',$r('app.media.icon_share')),
    new buttonList(3,'删除',$r('app.media.ic_public_delete'))
  ]

  // 取消回调函数：当用户点击取消按钮时调用的函数
  // 初始为空函数，可由父组件传入具体的取消逻辑
  cancel: () => void = () => {
  }

  // build方法：ArkUI组件的核心构建方法，定义组件的UI结构和布局
  // 返回值为组件树，系统会根据此方法构建用户界面
  // 整体布局：从上到下的垂直布局，包含分隔线、操作按钮、取消按钮
  build() {
    Column(){
      // 顶部装饰性分隔线：0.5像素宽度，底部间距16
      Divider().strokeWidth(0.5).padding({bottom:16})
      
      // 操作按钮区域：使用GridRow实现4列网格布局（实际显示3个按钮）
      GridRow({
        columns:4  // 4列网格，最后一个位置为空
      }){
        ForEach(this.buttonListInfo,(item:buttonList)=>{
          GridCol(){
            // 圆形图标按钮组件，显示操作图标和标题
            InsideCircleIcon({
              icon:item.icon,
              title:item.title
            })
              .onClick(()=>{
                // 根据按钮ID执行不同的操作
                switch (item.id){
                  case 1:  // 编辑按钮
                    this.isShowEditBook = true  // 显示编辑书单页面
                    break
                  case 2:  // 分享按钮
                    this.shareShelfBookDialog?.open()  // 打开分享对话框
                    break
                  case 3:  // 删除按钮
                    this.delDialog?.open()  // 打开删除确认对话框
                    break;
                }
              })
          }
        })
      }
      
      // 中间装饰性分隔线：0.5像素宽度，底部间距16
      Divider().strokeWidth(0.5).padding({bottom:16})
      
      // 取消按钮区域
      Column(){
        Text('取消')
          .fontColor('rgba(0, 0, 0, 0.88)')  // 88%黑色
          .fontSize(16)
          .fontWeight(400)
          .lineHeight(24)
          .textAlign(TextAlign.Center)
      }
      .onClick(()=>{
        this.cancel()  // 调用取消回调函数
        this.controller?.close()  // 关闭当前对话框
      })
      .alignItems(HorizontalAlign.Center)  // 水平居中对齐
      .padding({bottom:16})  // 底部间距16
      
      // 绑定编辑书单页面的全屏覆盖
      // 当isShowEditBook为true时，显示showEditBook构建的内容
      Flex()
        .bindContentCover($$this.isShowEditBook, this.showEditBook(), {
          modalTransition: ModalTransition.DEFAULT,  // 默认模态过渡动画
          onDisappear: () => {  // 页面消失时的回调
            this.isShowEditBook = false;  // 重置显示状态
          }
        })
    }
    .borderRadius({topLeft:20,topRight:20})  // 顶部圆角，实现从底部弹出的对话框效果
    .backgroundColor(Color.White)  // 白色背景
    .width('100%')  // 宽度100%
  }
  // 编辑书单对话框显示状态：控制编辑书单页面的显示/隐藏
  // true：显示编辑页面（全屏覆盖），false：隐藏编辑页面
  @State isShowEditBook:boolean = false
  
  // 书单列表刷新状态：通过@StorageLink装饰器声明为跨组件共享的状态
  // 键名：'BOOK_IS_BOOK_WORKS_BOOK_LIST'，用于在应用存储中标识此状态
  // 功能：当编辑书单完成后，递增此值可以触发书单列表的刷新
  // 类型为number，初始值为0，每次递增都会触发依赖此状态的组件更新
  @StorageLink('BOOK_IS_BOOK_WORKS_BOOK_LIST') isWorksBookListRefreshing: number = 0
  
  // showEditBook构建器：构建编辑书单页面
  // @Builder装饰器声明这是一个UI构建器方法，可在bindContentCover中调用
  // 功能：创建全屏覆盖的编辑页面，包含newBookShelf组件
  @Builder showEditBook(){
    Column(){
      // 新建/编辑书单组件，传入当前书单的编辑参数
      newBookShelf({
        currentIndex:this.works.worksType,  // 当前书单类型，作为编辑的初始值
        changeShowNumber:()=>{  // 编辑完成后的回调函数
          this.isShowEditBook = false  // 关闭编辑页面
          // 延迟100ms后刷新书单列表，确保编辑操作已完成
          setTimeout(()=>{
            this.isWorksBookListRefreshing++  // 递增刷新状态，触发列表更新
          },100)
        },
        returnClose:true,  // 允许返回关闭
        workBookListStatus: 2,  // 书单状态：2表示编辑模式
        lastWorkBookList:this.works  // 要编辑的书单数据
      })
    }
    .backgroundColor(Color.White)  // 白色背景
  }

  // 分享书单对话框控制器：管理分享书单对话框的显示和隐藏
  // 类型为CustomDialogController | null，初始时创建控制器实例
  // 配置说明：
  //   builder - 使用shareWorksBook组件构建对话框内容，传入当前书单数据
  //   autoCancel - true：点击对话框外部自动关闭
  //   width/height - '100%'：全屏显示
  //   alignment - DialogAlignment.Bottom：底部对齐，从底部弹出
  //   customStyle - true：使用自定义样式
  shareShelfBookDialog: CustomDialogController | null = new CustomDialogController({
    builder: shareWorksBook({
      works:this.works  // 传入当前书单数据
    }),
    autoCancel: true,
    width:'100%',
    height:'100%',
    alignment: DialogAlignment.Bottom,
    customStyle:true
  })

  // 删除缓存状态：控制是否删除缓存的选项状态
  // 传递给确认对话框，用户可以选择是否同时删除缓存
  @State delCache:boolean = false
  
  // 删除确认对话框控制器：管理删除确认对话框的显示和隐藏
  // 类型为CustomDialogController | null，初始时创建控制器实例
  // 配置说明：
  //   builder - 使用confirmDialogExample组件构建确认对话框
  //     confirm - 确认删除的回调函数，执行实际删除操作
  //     delCache - 是否删除缓存的选项状态
  //   autoCancel - true：点击对话框外部自动关闭
  //   alignment - DialogAlignment.Center：居中对齐
  //   gridCount - 4：网格数量（影响对话框宽度）
  //   customStyle - false：使用系统默认样式
  //   cornerRadius - 25：圆角半径
  delDialog: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      confirm: ()=> {  // 确认删除的回调函数
        if (this.works.worksId) {
          // 调用工具函数删除书单
          worksListsUtils.delWorksByIds(this.works.worksId);
          // 关闭当前操作对话框
          this.controller?.close()
          // 调用取消回调函数
          this.cancel()
        }
      },
      delCache:this.delCache  // 传递删除缓存选项
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    gridCount: 4,
    customStyle: false,
    cornerRadius: 25,
  })
}

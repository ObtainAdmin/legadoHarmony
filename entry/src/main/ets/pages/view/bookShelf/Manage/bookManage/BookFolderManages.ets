import confirmDialogExample from '../../../../../componets/common/confirmDialog'
import { showMessage } from '../../../../../componets/common/promptShow'
import { BookGroups } from '../../../../../database/entities/BookGroups'
import BookFolderGridManage from './BookFolderGridManage'
import BookFolderInfoManage from './BookFolderInfoManage'

/**
 * 文件夹管理容器组件
 * 
 * 功能概述：
 * 1. 根据展示模式（列表/宫格）渲染不同的文件夹管理组件
 * 2. 提供空状态显示：当没有分组数据时显示提示
 * 3. 集成删除确认对话框（暂未完全实现）
 * 4. 过滤系统分组和隐藏分组
 * 
 * 使用场景：
 * - 在书籍管理页面中作为分组列表的容器
 * - 根据用户选择的展示模式动态切换UI
 * 
 * 组件特点：
 * - 使用@Component装饰器，作为可复用组件
 * - 条件渲染：根据EXHIBIT参数选择列表或宫格布局
 * - 数据过滤：排除系统分组（isSystem）和隐藏分组（!show）
 * - 空状态处理：显示无数据提示图片和文字
 * - 对话框集成：包含删除确认对话框（功能待完善）
 */
@Component
export default struct BookFolderManages {
  /** 分组数据数组，通过@Prop装饰器从父组件传入 */
  @Prop bookGroups:BookGroups[] = []
  
  /** 
   * 复选框状态记录，通过@Link装饰器与父组件双向绑定
   * 键为分组ID，值为是否选中
   */
  @Link checkGroup:Record<number, boolean>
  
  /** 展示模式，通过@Prop装饰器从父组件传入：'列表'或'宫格' */
  @Prop EXHIBIT:string
  
  /** 是否删除缓存，暂未使用 */
  @State delCache:boolean = false
  
  /** 是否处于管理模式，通过@Prop装饰器从父组件传入，默认为true */
  @Prop isManage:boolean = true
  
  /** 选择状态变化回调函数 */
  onSelect:Function = () => {}
  
  /** 
   * 删除确认对话框控制器
   * 
   * 配置参数：
   * - builder: 使用confirmDialogExample组件构建删除确认对话框
   * - cancel: 取消回调，调用exitApp方法
   * - autoCancel: 点击背景自动关闭
   * - alignment: 对话框居中显示
   * - gridCount: 网格数量为4
   * - customStyle: 不使用自定义样式
   * - cornerRadius: 圆角半径为25
   * 
   * confirmDialogExample参数：
   * - cancel: 取消回调，调用onCancel方法
   * - confirm: 确认回调，调用onAccept方法
   * - delCache: 是否删除缓存
   */
  bookInfoDel: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      cancel: ()=> { this.onCancel() },  // 取消回调
      confirm: ()=> { this.onAccept() },  // 确认回调
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
   * 取消删除操作
   * 功能：对话框取消回调，暂未实现具体逻辑
   */
  onCancel() {
    // this.isClear = false  // 注释掉的代码
  }

  /**
   * 确认删除操作
   * 功能：对话框确认回调，调用deleteFolder方法
   */
  onAccept() {
    this.deleteFolder()  // 调用删除方法
  }

  /**
   * 退出应用（关闭对话框）
   * 功能：对话框取消回调，暂未实现具体逻辑
   */
  exitApp() {
    // this.isClear = false  // 注释掉的代码
  }

  /**
   * 删除文件夹
   * 功能：执行删除操作，显示删除成功提示
   * 注意：此方法目前只显示提示，实际删除逻辑待实现
   */
  deleteFolder() {
    showMessage('删除成功')  // 显示删除成功提示
  }

  /**
   * 构建组件UI布局
   * 
   * 逻辑：
   * 1. 空状态处理：如果bookGroups为空或null，显示无数据提示
   * 2. 数据渲染：根据EXHIBIT参数选择布局方式
   *    - '列表'模式：使用BookFolderInfoManage组件，垂直排列
   *    - 其他模式（宫格）：使用BookFolderGridManage组件，3列网格布局
   * 3. 数据过滤：排除系统分组（isSystem）和隐藏分组（!show）
   * 
   * 设计特点：
   * - 空状态：居中显示图片和文字，顶部边距120px
   * - 列表模式：垂直排列，无网格
   * - 宫格模式：3列网格布局
   * - 布局权重：占据剩余空间（layoutWeight:1）
   */
 build() {
   // 空状态处理：没有分组数据时显示提示
   if (this.bookGroups === null || this.bookGroups.length === 0) {
     Column() {
       Image($r('app.media.no_record')).width(200).height(200)  // 无数据图片
       Text('暂无浏览记录').fontSize(12).fontColor('rgba(96, 96, 96, 0.6)').fontWeight(500).padding(5)  // 提示文字
     }
     .margin({ top: 120 })  // 顶部边距
   } else {
     // 有数据时根据展示模式渲染
     Column(){
       if (this.EXHIBIT === '列表') {
         // 列表模式：使用BookFolderInfoManage组件
         ForEach(this.bookGroups, (item: BookGroups) => {
           // 过滤：只显示非系统分组且显示的分组
           if (item.show && !item.isSystem) {
             BookFolderInfoManage({
               group:item,  // 分组数据
               checkGroup:this.checkGroup,  // 选中状态
               isManage:this.isManage,  // 管理模式
               onSelect:()=>{
                 this.onSelect()  // 选择回调
               }
             })
           }
         })
       } else {
         // 宫格模式：使用BookFolderGridManage组件，3列网格
         GridRow({
           columns:3  // 3列网格
         }){
           ForEach(this.bookGroups, (item: BookGroups) => {
             // 过滤：只显示非系统分组且显示的分组
             if (item.show && !item.isSystem) {
               GridCol(){
                 BookFolderGridManage({
                   group:item,  // 分组数据
                   checkGroup:this.checkGroup,  // 选中状态
                   isManage:this.isManage,  // 管理模式
                   onSelect:()=>{
                     this.onSelect()  // 选择回调
                   }
                 })
               }
             }
           })
         }
       }
     }.layoutWeight(1)  // 占据剩余空间
   }
 }
}
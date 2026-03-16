// ============ 导入模块 ============
import { PublicConstants } from '../../../common/constants/PublicConstants' // 公共常量配置（颜色、字体等）
import { ColumnModifier } from '../../../common/utils/ComponetModifier' // 列修饰器工具类
import { dataItem } from '../../../componets/dataList/dataItem' // 列表项数据模型类
import { MyCenterTitle } from '../../../componets/myCenter/MyCenterTitle' // 我的页面标题栏组件
import { serviceDialog } from '../../../componets/webDavService/serviceDialog' // WebDAV 服务对话框组件

/**
 * @Entry - 页面入口装饰器
 *   - 标识这是一个独立的页面组件
 * @Component - 组件装饰器
 *   - 定义 UI 组件结构，支持状态管理
 * @struct clearCache - 清理缓存页面组件类
 */
@Entry
@Component
struct clearCache{
  // ============ 状态变量定义 ============
  
  /** @State clearList:dataItem[] - 缓存类型列表
   * 存储各类缓存及其占用大小
   * 
   * 数据结构说明：
   *   index 0: 系统缓存 - 34.35MB
   *   index 1: 小说缓存 - 34.35MB
   *   index 2: 漫画缓存 - 34.35MB
   *   index 3: 听书缓存 - 34.35MB
   *   index 4: 字体缓存 - 34.35MB
   */
  @State clearList:dataItem[]=[
    new dataItem("系统缓存",34.35),
    new dataItem("小说缓存",34.35),
    new dataItem("漫画缓存",34.35),
    new dataItem("听书缓存",34.35),
    new dataItem("字体缓存",34.35),
  ]
  
  /** @State @Watch("ClearChange") clearDialogStatus:boolean=false
   * 清除确认弹窗显示状态
   * @Watch: 当状态变化时自动触发 ClearChange 方法
   */
  @State @Watch("ClearChange") clearDialogStatus:boolean=false
  
  /** @State index:number=0
   * 当前选中的缓存项索引，用于确定要清除的缓存类型
   */
  @State index:number=0
  
  // ColumnModifier 自定义设置
  Column = new ColumnModifier().setCustom({left:20,right:20})

  // ============ UI 构建方法 - build() ============
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column (外层容器)
   * ├─ MyCenterTitle (标题栏：清理缓存)
   * └─ Column (缓存列表容器)
   *    └─ ForEach (遍历渲染各缓存项)
   */
  build() {
    Column({space:12}){ // 子组件间距 12 像素
      
      // ========== 标题栏 ===========
      MyCenterTitle({title:"清理缓存"}) // 使用公共组件展示标题
      
      // ========== 缓存列表 ===========
      Column(){
        ForEach(this.clearList,(item:dataItem,index:number)=>{
          Row({space:10}){ // 水平布局
            
            // 缓存名称文本 - 占 65% 宽度
            Text(item.title).width("65%").fontSize(14).lineHeight(22)
            
            // 缓存大小文本 - 半透明灰色
            Text(item.value+"MB").fontSize(12).lineHeight(20).fontColor("rgba(0, 0, 0, 0.45)")
            
            // 右箭头图标
            Image($r("app.media.right"))
              .size({width:24,height:24})
              .clickEffect({level:ClickEffectLevel.LIGHT, scale: 0.5}) // 点击特效：轻微缩放
          }.width("100%").padding({top:12,bottom:12})
          .justifyContent(FlexAlign.End) // 右对齐
          .onClick(()=>{
            this.index=index // 记录选中的索引
            this.clearDialogStatus=true // 显示确认弹窗
          })

        })
      }
      .backgroundColor(PublicConstants.THEME_COLOR_WHITE) // 白色背景
      .padding({ left:20,right:20 }) // 左右内边距 20 像素
      .borderRadius(15) // 圆角 15 像素

    }.width("100%") // 占满宽度
    .height("100%") // 占满高度
    .attributeModifier(this.Column) // 应用自定义修饰器
  }

  // ============ 事件处理方法 ============
  
  /**
   * exitApp - 弹窗关闭处理
   * 关闭清除确认对话框
   */
  exitApp() {
    this.clearDialogStatus = false
  }
  
  /**
   * onCancel - 取消按钮点击处理
   * 用户选择取消清除操作
   */
  onCancel() {
    this.clearDialogStatus = false
  }

  /**
   * onAccept - 确认按钮点击处理
   * 
   * @param index - 确认操作的缓存项索引
   *   调用 clear 方法执行实际清除操作
   */
  onAccept(index:number) {
    console.log(index.toString());
    this.clear(index) // 执行清除逻辑
    this.clearDialogStatus = false // 关闭弹窗
  }
  
  /**
   * ClearChange - 状态监听回调
   * 当 clearDialogStatus 变为 true 时自动触发
   * 打开确认清除弹窗
   */
  ClearChange(){
    if (this.clearDialogStatus) {
      this.clearInfoDel?.open() // 打开 CustomDialog
    }
  }
  
  /**
   * clearInfoDel - 清除确认对话框控制器
   * 配置弹窗样式和内容
   */
  clearInfoDel: CustomDialogController | null = new CustomDialogController({
    builder: serviceDialog({
      title:"确认清除小说缓存吗？", // 弹窗标题
      value:"", // 额外参数
      cancel: ()=> { this.onCancel() }, // 取消回调
      confirm: ()=> { this.onAccept(this.index) } // 确认回调
    }),
    cancel: this.exitApp, // 弹窗外点击关闭回调
    autoCancel: true, // 允许自动取消
    alignment: DialogAlignment.Center, // 居中对齐
    offset:{dx:0,dy:20}, // 偏移位置
    customStyle: true // 启用自定义样式
  })
  
  /**
   * clear - 缓存清除方法
   * 
   * @param index - 缓存类型索引
   * 
   * 功能分支：
   *   case 0: 系统缓存
   *   case 1: 小说缓存
   *   case 2: 漫画缓存
   *   case 3: 听书缓存
   *   case 4: 字体缓存
   */
  clear(index:number){
    switch (index){
      case 0:
        // 系统缓存清除逻辑
        console.log("系统缓存");
        break;
      case 1:
        // 小说缓存清除逻辑
        console.log("小说缓存");
        break;
      case 2:
        // 漫画缓存清除逻辑
        console.log("漫画缓存");
        break;
      case 3:
        // 听书缓存清除逻辑
        console.log("听书缓存");
        break;
      case 4:
        // 字体缓存清除逻辑
        console.log("字体缓存");
        break;
    }


  }
}

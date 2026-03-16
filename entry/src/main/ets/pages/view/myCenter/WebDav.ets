// ============ 导入模块 ============
import font from '@ohos.font'; // 字体管理 API
import web_webview from '@ohos.web.webview'; // WebView 组件 API
import { promptAction, router } from '@kit.ArkUI'; // UI 提示和路由导航
import { ColumnModifier } from '../../../common/utils/ComponetModifier'; // 列修饰器工具类
import { ThemeItem } from '../../../common/model/Theme'; // 主题类型定义
import { ThemeStorageKey } from '../../../common/constants/Theme'; // 主题存储键常量

/**
 * 输入项数据结构类
 * 
 * class Input_items - WebDAV 输入框数据模型
 *   text: 当前输入内容
 *   placeholder: 占位符文本
 *   type: 输入框类型（普通/邮箱/手机号/密码）
 */
class Input_items{
  text:string // 输入内容
  placeholder:string // 占位符
  type:InputType // 输入类型枚举

  constructor(text:string,placeholder:string,type:InputType){
    this.text=text;
    this.placeholder=placeholder;
    this.type=type;
  }
}

/**
 * @Entry - 页面入口装饰器
 * @Component - 组件装饰器
 * @struct WebDav - WebDAV 云盘登录页面组件类
 * 
 * 功能说明：
 *   - WebDAV 服务配置表单（服务器地址、账号、密码）
 *   - 字体注册（金步体）
   *   - WebView 帮助文档查看
   *   - 提交授权并跳转
 */
@Entry
@Component
struct  WebDav{
  
  // ========== 表单输入状态 =========
  
  /** @State host: string = ''
   * 服务器地址输入内容
   */
  @State host: string = ''
  
  /** @State account: string = ''
   * 账号输入内容
   */
  @State account: string = ''
  
  /** @State password: string = ''
   * 密码输入内容
   */
  @State password: string = ''
  
  // ========== 输入框列表数据 ==========
  /** @State inputs : Input_items[] - 输入框配置列表
   * 三项：服务器地址（普通输入）、账号（邮箱/手机）、密码（密码掩码）
   */
  @State inputs : Input_items[]=[
    new Input_items("","服务器地址",InputType.Normal),
    new Input_items("","账号",InputType.Email||InputType.PhoneNumber),
    new Input_items("","密码",InputType.Password)
  ]
  // 主题颜色
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /** @State helper_status:boolean=false
   * 帮助弹窗显示状态
   * true=显示帮助 WebView，false=隐藏
   */
  @State helper_status:boolean=false
  
  /** controller: web_webview.WebviewController - WebView 控制器
   * 控制 WebView 的行为和内容
   */
  controller: web_webview.WebviewController = new web_webview.WebviewController()
  
  // ColumnModifier 自定义设置
  Column = new ColumnModifier().setPadding(0,0)

  // ========== 构建器：输入框 ==========
  
  /**
   * @Builder input_type - 输入框构建器
   * 
   * @param item - Input_items 对象
   *   text: 当前值（双向绑定）
   *   placeholder: 占位符
   *   type: 输入类型
   * 
   * @returns Column 组件，包含一个 TextInput
   * 
   * 样式特点：
   *   - 圆角 10 像素
   -   左侧内边距 20 像素
   *   - 蓝色光标颜色
   *   - 灰色占位符
   */
  @Builder input_type(item:Input_items){
    Column(){
      TextInput({ text:item.text, placeholder: item.placeholder }) // 双绑模式输入框
        .placeholderColor(Color.Grey) // 占位符颜色：灰色
        .type(item.type) // 输入类型（普通/邮箱/手机号/密码）
        .caretColor(Color.Blue) // 光标颜色：蓝色
        .height(50) // 固定高度 50 像素
        .fontSize(14) // 字号 14
        .fontColor(Color.Black) // 字体颜色：黑色
        .borderRadius(10) // 圆角 10 像素
        .padding({left:20}) // 左侧内边距 20
        
        // 输入内容变化时更新 state
        .onChange((value: string) => {
          item.text= value
        })
        
        // 获得焦点时的回调（空实现）
        .onFocus(() => {
        
        })
    }
  }
  
  // ========== 构建器：帮助 WebView ==========
  
  /**
   * @Builder helper - 帮助文档构建器
   * 
   * 功能：显示 webDavHelp.html 作为 WebView 嵌入
   *   - 从 rawfile 资源加载 HTML 文件
   *   - 使用已创建的 WebviewController 控制
   */
  @Builder helper(){
    Blank(20) // 顶部间距 20
    Web({ src: $rawfile("webDavHelp.html"), controller: this.controller }) // 加载 HTML 资源
  }
  
  // ========== 生命周期方法 ==========
  
  /**
   * aboutToAppear - 组件即将出现时调用
   * 注册自定义字体"金步体"
   *   - 字体文件位置：与 pages 目录同级
   *   - 家族名：JinBuTi
   */
  aboutToAppear() {
    font.registerFont({
      familyName: 'JinBuTi',
      familySrc: $rawfile("DingTalkJinBuTi.ttf") // font 文件与 pages 目录同级
    })
  }

  // ========== UI 构建方法 - build() ==========
  
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column (垂直布局)
   * ├─ Column (表单区域)
   * │  ├─ Text("WebDAV 云盘登录") 大标题（金步体）
   * │  ├─ Column(三个输入框)
   * │  │  └─ ForEach(inputs) -> input_type
   * │  └─ Button("授权并登录") 提交按钮
   * └─ Column(帮助链接)
   *    └─ Text("不会填写？查看帮助") -> bindSheet(WebView)
   * 
   * 样式特点：
   *   - 大标题使用特殊字体（金步体）
   *   - 表单居中显示
   *   - 帮助链接半模态框展示 WebView
   */
  build() {
    Column(){
      // ========== 输入框区域 ==========
      Column(){
        Column({space:30}){ // 上下间距 30
            
          // 大标题（金步体）
          Text("WebDav 云盘登录")
            .fontSize(30) // 大号字体
            .fontWeight(700) // 加粗
            .fontFamily("JinBuTi") // 使用注册的定制字体
          
          // 三个输入框
          Column({space:30}){
            ForEach(this.inputs,(item:Input_items)=>{
              this.input_type(item) // 渲染每个输入框
            })
          }.width("80%") // 输入框组占 80% 宽度
          
          // 提交按钮
          Button("授权并登录")
            .width("80%").height(50) // 按钮尺寸
            .backgroundColor("rgb(128, 128, 128)") // 灰色背景
            .borderRadius(10) // 圆角 10
            .onClick(()=>{
              // 点击触发逻辑
              promptAction.showToast({
                message: '登录成功',
                duration: 1000,
              })
              
              // 2 秒后跳转到文件管理页面
              setTimeout(()=>{
                router.pushUrl({
                  url: "pages/view/myCenter/FileManagement",
                  params:{
                    webDavStatus:1 // 传递登录成功标识
                  }
                })
              },2000)
            })

        }.width("100%").height("95%") // 容器尺寸
        .justifyContent(FlexAlign.Center) // 垂直居中
        .alignItems(HorizontalAlign.Center) // 水平居中
      }
      
      // ========== 查看帮助链接 ==========
      Column(){
        Text("不会填写？查看帮助")
          .fontColor(this.theme.mainColor) // 主题色高亮
          .fontSize(14)
      }.bindSheet($$this.helper_status,this.helper,{ // 绑定半模态框
        height:600, // 高度 600 像素
        enableOutsideInteractive:false, // 禁止外部交互
        dragBar:false // 不显示拖拽条
      }).onClick(()=>{
        this.helper_status=true; // 显示帮助弹窗
      }).width("100%").height(20)
    }.justifyContent(FlexAlign.Start) // 顶对齐
    .attributeModifier(this.Column) // 应用自定义修饰器
  }
}

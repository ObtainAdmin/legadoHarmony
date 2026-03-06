/**
 * WebdavService 组件 - WebDAV服务组件
 * 
 * 功能概述：
 * 1. 提供WebDAV服务管理界面，支持开关控制
 * 2. 显示WiFi传书、电脑阅读、电脑写源三个服务选项
 * 3. 集成复制功能，支持复制服务地址到剪贴板
 * 4. 实现动画效果，开关状态变化时平滑显示/隐藏地址区域
 * 5. 集成帮助说明对话框，提供使用指导
 * 6. 支持自定义字体（金步提字体）和Canvas装饰元素
 * 
 * 设计特点：
 * 1. 分层布局：使用Column、Row和Flex构建服务界面
 * 2. 动画效果：600ms动画实现地址区域的平滑显示/隐藏
 * 3. 视觉设计：彩色服务卡片，Canvas装饰元素，圆角设计
 * 4. 主题集成：开关使用主题主色，复制按钮使用主题色
 * 5. 字体集成：支持自定义金步提字体
 * 6. 交互设计：直观的开关、复制和帮助操作
 * 
 * 使用场景：
 * 1. WebDAV服务管理页面
 * 2. 需要显示和复制服务地址的场景
 * 3. 需要开关控制的服务管理界面
 * 
 * 组件结构：
 * - 服务开关：Web服务开关控制
 * - 服务卡片：三个服务选项的彩色卡片
 * - 地址区域：显示和复制服务地址
 * - 帮助对话框：提供使用说明
 * 
 * 注意事项：
 * 1. 需要正确处理开关状态和动画效果
 * 2. 复制功能需要剪贴板权限
 * 3. 自定义字体需要正确注册和加载
 */

import { serviceList } from '../dataList/serviceList'
import { font, promptAction } from '@kit.ArkUI'
import { pasteboard } from '@kit.BasicServicesKit'
import { serviceDialog } from './serviceDialog'
import CommonConstants from '../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'


@Component
export struct WebdavService {
  /**
   * WebDAV状态
   * @type {boolean}
   * @default false
   * @description WebDAV服务开关状态
   * @state 使用@State装饰器管理组件内部状态
   */
  @State webDavStatus:boolean=false
  
  /**
   * 服务列表
   * @type {serviceList[]}
   * @default [wifi传书, 电脑阅读, 电脑写源]
   * @description 服务选项列表，包含名称、ID、图标和颜色
   * @state 使用@State装饰器管理组件内部状态
   */
  @State List:serviceList[]=[
    new serviceList("wifi传书","1",$r("app.media.wifi_line"),["#188BFF","#D8ECFF","#B5DAFF"]), // 蓝色系
    new serviceList("电脑阅读","1",$r("app.media.computer"),["#FF9500","#FFEDD4","#FFDDAD"]), // 橙色系
    new serviceList("电脑写源","1",$r("app.media.writing"),["#24B277","#DAF2E8","#B9E6D3"]), // 绿色系
  ]
  
  /**
   * 服务地址
   * @type {string}
   * @default "http://192.168.41.12:1122"
   * @description WebDAV服务地址
   * @state 使用@State装饰器管理组件内部状态
   */
  @State address:string="http://192.168.41.12:1122"

  /**
   * Canvas渲染设置
   * @type {RenderingContextSettings}
   * @description Canvas渲染上下文设置，启用抗锯齿
   */
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  
  /**
   * Canvas渲染上下文
   * @type {CanvasRenderingContext2D}
   * @description 用于绘制Canvas元素的2D渲染上下文
   */
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  
  /**
   * 服务对话框状态
   * @type {boolean}
   * @default false
   * @description 控制服务对话框的显示状态
   * @state 使用@State装饰器管理组件内部状态
   */
  @State serviceDialogStatus:boolean=false

  /**
   * 主题配置
   * @type {ThemeItem}
   * @description 从存储中读取的主题配置
   * @storageprop 使用@StorageProp装饰器从存储中读取数据
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * Canvas构建器
   * @param {ResourceColor} color - 颜色
   * @param {number} X - X轴偏移
   * @param {number} Y - Y轴偏移
   * @returns {void}
   * @description 构建Canvas装饰元素，14x10px，70%透明度
   */
  @Builder canvas(color:ResourceColor,X:number,Y:number){
    Canvas(this.context) // Canvas组件
      .width(14) // 14px宽度
      .height(10) // 10px高度
      .backgroundColor(color) // 背景颜色
      .opacity(0.7) // 70%透明度
      .onReady(() => {
        this.context.fillRect(0, 30, 100, 100) // 绘制矩形
      }).offset({x:X,y:Y}) // 偏移位置
  }
  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建WebDAV服务组件的完整UI结构
   * 包含服务开关、服务卡片和地址区域
   */
  build() {
    Column({space:15}){ // 15px间距
      /**
       * Web服务开关区域
       * @description 包含图标、标题、帮助按钮和开关
       */
      Row(){
        Row({space:10}){ // 10px间距
          Image($r("app.media.pc_icon")) // PC图标
            .size({width:20,height:20}) // 20x20px
          Text("Web服务") // 标题文本
            .fontWeight(600) // 600字重
          Image($r("app.media.doubt")) // 疑问图标
            .size({width:20,height:20}) // 20x20px
            .onClick(()=>{
              this.bookInfoDel?.open() // 打开帮助对话框
            })
        }
        Row(){
          Toggle({type:ToggleType.Switch,isOn:$$this.webDavStatus}) // 开关组件
            .onChange((isOn: boolean) => {
              this.webDavStatus=isOn // 更新开关状态
            })
            .selectedColor(this.theme.mainColor) // 主题主色
            .hoverEffect(HoverEffect.None) // 禁用悬停效果
        }
      }
      .width("100%") // 100%宽度
      .justifyContent(FlexAlign.SpaceBetween) // 两端对齐
      
      /**
       * 服务卡片区域
       * @description Flex布局，显示三个服务选项
       */
      Flex({
        direction:FlexDirection.Row, // 行方向
        justifyContent:FlexAlign.Center, // 居中对齐
        alignContent:FlexAlign.Center, // 内容居中对齐
        alignItems:ItemAlign.Center // 项目居中对齐
      }){
        ForEach(this.List,(item:serviceList,index: number)=> {
          /**
           * 服务卡片之间的分隔列
           * @description 非第一个卡片前添加10px宽度的分隔
           */
          if (index != 0) {
            Column()
              .width(10) // 10px宽度
              .flexBasis('auto') // 自动基础大小
              .flexGrow(0) // 不增长
              .flexShrink(0) // 不收缩
          }

          /**
           * 服务卡片
           * @description 包含服务名称、图标和Canvas装饰
           */
          Column({space:5}){ // 5px间距
            Text(item.name) // 服务名称
              .fontSize(12) // 12px字体
              .fontColor("rgba(121, 119, 119, 1.00)") // 灰色字体
              .width("100%") // 100%宽度
              .fontWeight(500) // 500字重
              .fontColor(item.background[0]) // 主色字体
              .fontFamily("JinBuTi") // 金步提字体
            Image(item.img) // 服务图标
              .size({width:28,height:28}) // 28x28px
            this.canvas(item.background[2],-18,-25) // Canvas装饰1
            this.canvas(item.background[2],5,-30) // Canvas装饰2
          }
          .backgroundColor(item.background[1]) // 次色背景
          .alignItems(HorizontalAlign.End) // 右对齐
          .width(95) // 95px宽度
          .height(70) // 70px高度
          .padding({top:10,bottom:10,left:10,right:12}) // 内边距
          .borderRadius(12) // 12px圆角
          .flexBasis('auto') // 自动基础大小
          .flexGrow(1) // 等比例增长
          .flexShrink(1) // 等比例收缩
        })
      }
      .width("100%") // 100%宽度

      /**
       * 复制地址区域
       * @description 显示服务地址和复制按钮，根据开关状态显示/隐藏
       */
      Row({space:20}){ // 20px间距
        Text(this.address) // 地址文本
          .fontColor("rgba(0, 0, 0, 0.45)") // 45%黑色字体
          .fontSize(14) // 14px字体
          .width("70%") // 70%宽度
        Text("|") // 分隔符
          .fontColor("rgba(0, 0, 0, 0.45)") // 45%黑色字体
          .fontSize(14) // 14px字体
        Text("复制") // 复制按钮
          .fontColor(this.theme.mainColor) // 主题主色
          .fontSize(14) // 14px字体
          .fontWeight(600) // 600字重
          .onClick(()=>{this.copy(this.address)}) // 点击复制
      }
      .width("100%") // 100%宽度
      .height(40) // 40px高度
      .backgroundColor("rgba(0, 0, 0, 0.04)") // 4%黑色背景
      .borderRadius(8) // 8px圆角
      .padding({left:20,right:20}) // 左右20px内边距
      .visibility(this.webDavStatus?Visibility.Visible:Visibility.None) // 根据开关状态显示/隐藏
      .opacity(this.webDavStatus?1:0) // 根据开关状态设置透明度
      .scale({ // 缩放动画
        centerX: "50%", // 中心点X
        centerY: "50%", // 中心点Y
        x: this.webDavStatus ? 1 : 0, // X轴缩放
        y: this.webDavStatus? 1 : 0, // Y轴缩放
      })
      .animation({ // 动画效果
        duration: 600, // 600ms持续时间
        curve: CommonConstants.UniCurve // 统一曲线
      })
    }
    .width("100%") // 100%宽度
    .backgroundColor("#FFF") // 白色背景
    .padding({top:16,bottom:16,left:20,right:20}) // 内边距
    .borderRadius(10) // 10px圆角
  }

  /**
   * 组件即将显示时的生命周期回调
   * @returns {void}
   * @description 注册自定义字体（金步提字体）
   */
  aboutToAppear() {
    font.registerFont({
      familyName: 'JinBuTi', // 字体家族名称
      familySrc: $rawfile("DingTalkJinBuTi.ttf") // 字体文件路径，与pages目录同级
    })
  }
  
  /**
   * 复制方法
   * @param {string} value - 要复制的文本
   * @returns {void}
   * @description 将文本复制到系统剪贴板，显示成功提示
   */
  copy(value:string){
    let pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN,value); // 创建剪贴板数据
    const systemPasteboard = pasteboard.getSystemPasteboard() // 获取系统剪贴板
    systemPasteboard.setData(pasteData) // 设置数据到剪贴板
    promptAction.showToast({ // 显示提示
      message: '复制成功', // 成功消息
      duration: 1000, // 1000ms持续时间
    })
  }
  
  /**
   * 弹窗关闭方法
   * @returns {void}
   * @description 关闭服务对话框
   */
  exitApp() {
    this.serviceDialogStatus = false // 更新对话框状态
  }

  /**
   * 帮助说明弹窗控制器
   * @type {CustomDialogController}
   * @description 控制帮助说明对话框的显示
   */
  bookInfoDel: CustomDialogController | null = new CustomDialogController({
    builder: serviceDialog({ // 使用serviceDialog组件
      title:"帮助说明", // 对话框标题
      value:"打开后请复制下方链接，用电脑浏览器访问，并确认手机和电脑连接在同一WiFi下" // 对话框内容
    }),
    cancel: this.exitApp, // 取消回调
    autoCancel: true, // 自动取消
    alignment: DialogAlignment.Center, // 居中对齐
    offset:{dx:0,dy:20}, // 偏移量
    customStyle: true // 自定义样式
  })

}

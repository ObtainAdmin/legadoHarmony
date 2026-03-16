// ============ 导入模块 ============
import { promptAction, router } from '@kit.ArkUI'; // UI 提示和路由导航 API
import { dataItem } from '../../../componets/dataList/dataItem'; // 列表项数据模型
import { MyCenterTitle } from '../../../componets/myCenter/MyCenterTitle'; // 我的页面标题栏组件
import { cloudDisKBindSheetComponet } from '../../../componets/myCenter/cloudDisKBindSheetComponet'; // 云盘绑定表格组件
import { ColumnModifier } from '../../../common/utils/ComponetModifier'; // 列修饰器工具类
import { PublicConstants, TextConstants } from '../../../common/constants/PublicConstants'; // 公共常量和文本常量
import { ThemeItem } from '../../../common/model/Theme'; // 主题类型定义
import { ThemeStorageKey } from '../../../common/constants/Theme'; // 主题存储键常量

/**
 * @Entry - 页面入口装饰器
 *   - 标识这是一个独立的页面组件
 * @Component - 组件装饰器
 *   - 定义 UI 组件结构，支持状态管理
 * @struct CloudDisk - 云备份页面组件类
 */
@Entry
@Component
struct CloudDisk {
  // ============ 动画状态变量 ============
  
  /** @State refresh: number = 0
   * 旋转角度值，用于云端图标旋转动画效果
   * 每次点击备份按钮时增加 720 度（两圈）
   */
  @State refresh: number = 0;

  // ============ 备份状态变量 ============
  
  /** @State backups_time:string="2023/8/12 20:34:12"
   * 上次备份时间显示字符串
   * 格式："YYYY/M/D HH:mm:ss"
   */
  @State backups_time:string="2023/8/12 20:34:12"
  
  /** @State backups_status:boolean=false
   * 备份进行中状态
   * true=正在备份，false=待机
   */
  @State backups_status:boolean=false
  
  /** @State auto_backups_status:boolean=true
   * 自动备份开关状态
   * true=开启自动备份，false=关闭
   */
  @State auto_backups_status:boolean=true

  // ColumnModifier 自定义设置
  Columns = new ColumnModifier().setCustom({left:20,right:20})

  // ============ 备份设置列表 ============
  
  /**
   * @backups_list - 备份功能列表
   * 每项数据结构：[标题，索引，子值，类型]
   * 
   * 类型说明：
   *   type=0: 带开关的功能项（自动备份）
   *   type=1: 带箭头的导航项（进入二级页）
   */
  @State backups_list:dataItem[]=[
    new dataItem("自动备份",1,"",0),      // 开关项
    new dataItem("备份设置",2,"",1),       // 跳转至备份配置页
    new dataItem("备份帮助",3,"",1),       // 查看帮助文档
  ]

  // ============ 数据恢复相关变量 ============
  
  /** @State dataRecoveryStatus:boolean=false
   * 数据恢复弹窗显示状态
   * true=显示，false=隐藏
   */
  @State dataRecoveryStatus:boolean=false
  
  /** @State dataRecovery_list - 设备恢复源列表
   * 展示可用设备的名称
   * 示例：本地、手机、iPhone 14 Pro、iPhone 15 Pro
   */
  @State dataRecovery_list:dataItem[]=[
    new dataItem("本地",1,"",0),
    new dataItem("手机",2,"",1),
    new dataItem("iPhone 14 Pro ",3,"",1),
    new dataItem("iPhone 15 Pro ",3,"",1),
    new dataItem("iPhone 15 Pro ",3,"",1),
    new dataItem("iPhone 15 Pro ",3,"",1),
    new dataItem("iPhone 15 Pro ",3,"",1),
    new dataItem("iPhone 15 Pro ",3,"",1),
  ]
  
  /** @State historyRecovery_list - 历史备份文件列表
   * 展示可恢复的备份 ZIP 文件名
   * 格式："backup YYYY/M/D .zip"
   */
  @State historyRecovery_list:dataItem[]=[
    new dataItem("backup 2023/8/11 .zip",1,"",0),
    new dataItem("backup 2023/8/12 .zip",2,"",1),
    new dataItem("backup 2023/8/13 .zip",3,"",1),
    new dataItem("backup 2023/8/14 .zip",3,"",1),
    new dataItem("backup 2023/8/15 .zip",4,"",1),
    new dataItem("iPhone 15 Pro ",3,"",1),
    new dataItem("iPhone 15 Pro ",3,"",1),
    new dataItem("iPhone 15 Pro ",3,"",1),
  ]

  // ============ 滚动控制器 ============
  
  /** scroller: Scroller - 页面滚动控制器
   * 用于控制 Scroll 组件的滚动位置
   */
  scroller: Scroller = new Scroller()

  // ============ 索引状态变量 ============
  
  /** @State zipIndex:number=0
   * 历史备份列表中当前选中项的索引
   */
  @State zipIndex:number=0
  
  /** @State deviceIndex:number=0
   * 设备列表中当前选中项的索引
   */
  @State deviceIndex:number=0
  
  /** @State zipDataIndex:number=0
   * 保存的历史备份最终选中索引
   */
  @State zipDataIndex:number=0
  
  /** @State deviceDataIndex:number=0
   * 保存的设备最终选中索引
   */
  @State deviceDataIndex:number=0
  
  /** @State isShow:boolean=false
   * 弹窗切换模式标识
   * false=选择恢复来源（设备），true=选择历史备份
   */
  @State isShow:boolean=false

  // ============ 主题颜色绑定 ============
  
  /** @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
   * 响应式主题颜色绑定
   * 用于获取主色、次色等主题配置
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  // ============ 构建器：备份项渲染 ============
  
  /**
   * @Builder backups_item - 备份设置项构建器
   * 
   * @param item - dataItem 列表项对象
   *   title: 标题文字
   *   value: 关联值
   *   type: 类型（0=开关项，1=箭头导航项）
   * 
   * @returns Row 组件，包含左侧标题 + 右侧开关或箭头
   */
  @Builder backups_item(item:dataItem){
    Row(){
      // 左侧标题文本
      Text(item.title).fontSize(16)
      
      // 根据类型显示不同右侧控件
      if(item.type==0){
        // 类型 0: 显示 Toggle 开关（自动备份）
        Toggle({type:ToggleType.Switch,isOn:$$this.auto_backups_status})
          .onChange((isOn: boolean) => {
            this.auto_backups_onClick(isOn) // 调用开关事件
          }).selectedColor("#F60") // 选中时主色为橙红色
          .hoverEffect(HoverEffect.None) // 禁用悬停效果
      
      }else{
        // 类型 1: 显示右箭头图标（进入二级页）
        Image($r("app.media.right"))
          .size({width:30,height:30})
          .onClick(()=>{this.backup_set(parseInt(item.value.toString()))})
          // 点击根据 value 跳转到对应页面
      }
    }
    .width("100%") // 占满宽度
    .justifyContent(FlexAlign.SpaceBetween) // 两端对齐
    .padding({top:5,bottom:5}) // 上下内边距
  }

  // ============ 构建器：备份按钮内容 ============
  
  /**
   * @Builder backups_botton - 备份按钮文字构建器
   * 
   * @returns Text 组件，根据备份状态显示不同文字
   *   备份中 -> "备份中"
   *   待机 -> "立刻备份"
   */
  @Builder backups_botton(){
    Row() {
      Text(this.backups_status?"备份中":'立刻备份') // 动态文字
        .fontSize(12) // 字号 12
        .fontColor(0xffffff) // 白色字体
    }
    .alignItems(VerticalAlign.Center) // 垂直居中
    .justifyContent(FlexAlign.Center) // 水平居中
    .width(110) // 固定宽度
    .height(40) // 固定高度
  }
  
  /**
   * @Builder bindSheetText - 半模态框标题文本构建器
   * 
   * @param text - 显示文本
   *   isShow=true 时显示"请选择历史备份"
   *   isShow=false 时显示"请选择恢复来源"
   */
  @Builder bindSheetText(text:string){
    Text(text).fontSize(16).lineHeight(24).fontWeight(500)
  }

  // ============ 构建器：数据恢复弹窗 ============
  
  /**
   * @Builder dataRecoveryBindSheet - 数据恢复弹窗构建器
   * 
   * 功能：
   *   - 顶部标题根据状态动态切换
   *   - 中部列表根据状态切换（设备列表/历史备份列表）
   *   - 底部操作按钮（取消/确定）
   * 
   * 布局层次：
   * Column
   * ├─ 标题区域
   * ├─ Scroll (滚动列表)
   * │  ├─ cloudDisKBindSheetComponet (设备或历史备份列表组件)
   * └─ Row (按钮行)
   */
  @Builder dataRecoveryBindSheet(){
      Column(){
        // ========== 标题区域 ==========
        Column(){
          // 动态标题：根据 isShow 状态切换文字
          this.bindSheetText(this.isShow?"请选择历史备份":"请选择恢复来源")
        }.stateStyles({
          normal: this.bindSheetStyle, // 应用样式
        })
        
        // ========== 滚动列表区域 ==========
        Scroll(this.scroller) {
          if(!this.isShow){
            // 选择恢复来源：显示设备列表
            cloudDisKBindSheetComponet({
              items:this.dataRecovery_list,
              bindSheetIndex:this.deviceIndex
            }).stateStyles({
              normal: this.transitionsStyles,
            })
          }else{
            // 选择历史备份：显示备份文件列表
            cloudDisKBindSheetComponet({
              items:this.historyRecovery_list,
              bindSheetIndex:this.zipIndex
            }).stateStyles({
              normal: this.transitionStyles,
            })

          }
        }
        .scrollable(ScrollDirection.Vertical) // 垂直滚动
        .scrollBar(BarState.Off) // 隐藏滚动条
        .friction(0.6) // 摩擦系数 0.6
        .edgeEffect(EdgeEffect.None) // 禁用边缘回弹
        .size({width:320,height:200}) // 固定尺寸

        // ========== 按钮区域 ==========
        Row({space:20}) {
          // 取消按钮（使用主题色渐变）
          this.button("取消",[this.theme.mainColor,this.theme.secondColor],()=>{this.bindSheetCancel(this.isShow)})
          
          // 确定按钮（白底主色字）
          this.button("确定",[PublicConstants.THEME_COLOR_WHITE,this.theme.mainColor],()=>{this.bindSheetConfirm(this.isShow)})

        }.height(40) // 行高 40
        .width("100%") // 占满宽度
        .borderWidth({top:1}) // 上边框 1 像素
        .borderColor("rgba(0, 0, 0, 0.06)") // 浅灰色边框
        .justifyContent(FlexAlign.Center) // 居中对齐
        .padding({top:25}) // 上内边距 25
      }
  }
  
  /**
   * @Builder button - 通用按钮构建器
   * 
   * @param title - 按钮文本
   * @param color - 颜色数组 [文本颜色，背景颜色]
   * @param confirm - 点击回调函数
   * 
   * @returns Button 组件，圆角胶囊形状
   */
  @Builder button(title:string,color:Array<ResourceStr|Color>,confirm: () => void){
    Button({type: ButtonType.Normal, stateEffect: true}){
      Text(title)
        .fontSize(16)
        .fontColor(color[0]) // 使用传入的文本颜色
    }
    .borderRadius(40) // 大圆角（胶囊形）
    .backgroundColor(color[1]) // 使用传入的背景色
    .width(140) // 固定宽度
    .height(40) // 固定高度
    .onClick(() => {
        confirm() // 执行回调
    })

  }

  // ============ UI 构建方法 - build() ============
  
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column
   * ├─ MyCenterTitle (标题栏：云备份)
   * ├─ Column (云端图标及备份按钮区)
   * │  ├─ 旋转的云端图片
   * │  ├─ 上次备份时间文本
   * │  └─ 立即备份按钮
   * ├─ Column (备份设置列表)
   * └─ Column (数据恢复入口)
   */
  build() {
      Column() {
        // ========== 标题栏 ==========
        MyCenterTitle({title:"云备份"}) // 使用公共组件
        
        // ========== 云端图标及按钮区域 ==========
        Column(){
          Column(){
            // 云端刷新图标（带旋转动画）
            Image($r("app.media.cloud_refresh"))
              .size({width:68,height:68})
              .margin({bottom:60}) // 底部外边距 60 像素
              .rotate({angle:this.refresh}) // 动态旋转角度
              .onClick(()=>{
                // this.cloud_refresh() // 原实现已注释
              })
          }
          .margin({top:42,bottom:42}) // 上下外边距
          .backgroundImage($r("app.media.cloud")) // 云背景图
          .size({width:264,height:206}) // 固定尺寸
          .backgroundImageSize({width:"100%",height:"100%"}) // 填满容器
          .justifyContent(FlexAlign.Center) // 内部居中
          
          // 上次备份时间文本
          Text("上次备份时间："+this.backups_time).fontSize(14).fontColor(TextConstants.TEXT_FONT_COLOR)

          // ========== 立即备份按钮 ==========
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            this.backups_botton() // 调用按钮构建器
          }
          .margin({top:32,bottom:42}) // 上下外边距
          .backgroundColor(this.theme.mainColor) // 主题主色背景
          .onClick(()=>{this.backups_onClick()}) // 点击触发备份
        }
        
        // ========== 备份设置列表 ==========
        Column({space:10}){ // 子组件间距 10
          ForEach(this.backups_list,(item:dataItem)=>{
            this.backups_item(item) // 调用列表项构建器
          })
        }.stateStyles({
          normal: this.setStyle, // 应用样式
        })


        // ========== 数据恢复入口 ==========
        Column(){
          this.backups_item(new dataItem("数据恢复",4,"",1)) // 动态创建数据恢复项
        }.backgroundColor(0xffffff) // 白色背景
        .size({width:"100%"}) // 占满宽度
        .borderRadius(15) // 圆角 15
        .margin({top:16}) // 上外边距 16
        .padding({ left:20,right:20,top:10,bottom:10 }) // 内边距
        // ========== 绑定半模态框 ==========
        .bindSheet($$this.dataRecoveryStatus, this.dataRecoveryBindSheet(), {
          height: 320, // 半模态框高度
          showClose:false, // 不显示关闭按钮
          backgroundColor: PublicConstants.THEME_COLOR_WHITE, // 白色背景
          shouldDismiss:((sheetDismiss: SheetDismiss)=> {
            // 弹窗消失时的清理逻辑
            this.dataRecoveryStatus=false
            this.zipIndex=this.zipDataIndex // 恢复索引
            this.deviceIndex=this.deviceDataIndex
            this.isShow=false // 重置模式
          })
        })

      }.stateStyles({
        normal: this.pageStyle, // 页面整体样式
      })
      .blur(this.dataRecoveryStatus?40:0) // 弹窗显示时模糊背景 40
      .attributeModifier(this.Columns) // 应用自定义修饰器

  }

  // ============ 事件处理方法 ============
  
  /**
   * backups_onClick - 备份按钮点击事件
   * 调用 cloud_refresh 方法执行备份动画
   */
  backups_onClick(){
    this.cloud_refresh()
  }
  
  /**
   * auto_backups_onClick - 自动备份开关点击事件
   * 
   * @param isOn - 开关状态
   *   true=开启，false=关闭
   */
  auto_backups_onClick(isOn:boolean){
    this.auto_backups_status=isOn
  }
  
  /**
   * backup_set - 备份设置菜单点击事件
   * 
   * @param index - 点击项的 value 值
   *   case 2: 备份设置 -> diskSet
   *   case 3: 备份帮助 -> 待实现
   *   case 4: 数据恢复 -> 显示弹窗
   */
  backup_set(index:number){
    switch (index){
      case 2:
        router.pushUrl({
          url:"pages/view/myCenter/diskSet"
        })
        break;
      case 3:
        // TODO: 实现备份帮助页面跳转
        break;
      case 4:
        // 显示数据恢复弹窗
        this.dataRecoveryStatus=true
        break;
    }
  }

  // ============ 动画方法 ============
  
  /**
   * cloud_refresh - 云端刷新/备份动画
   * 
   * 功能：
   *   1. 开始备份状态
   *   2. 启动图标旋转动画（720 度，两圈）
   *   3. 动画结束后恢复待机状态并显示成功提示
   */
  cloud_refresh(){
    if(!this.backups_status){ // 避免重复点击
      this.backups_status=true // 标记为备份中
      
      // 启动动画
      animateTo({
        duration: 1000, // 每段动画 1 秒
        curve: Curve.Linear, // 线性曲线
        iterations: 2, // 循环 2 次（共 720 度）
        playMode: PlayMode.Normal, // 正常播放模式
        //动画结束方法
        onFinish: () => {
          this.backups_status=false // 恢复待机状态
          promptAction.showToast({
            message: '备份成功',
            duration: 1000,
          })
        }
      }, () => {
        // 旋转角度更新函数
        this.refresh+=720 // 增加 720 度
      })
    }
  }

  // ============ 生命周期方法 ============
  
  /**
   * aboutToAppear - 组件即将出现时调用
   * 初始化索引变量
   */
  aboutToAppear(): void {
    this.zipIndex=this.zipDataIndex
    this.deviceIndex=this.deviceDataIndex
  }
  
  /**
   * bindSheetCancel - 半模态框取消按钮处理
   * 
   * @param status - 是否切换到另一模式
   *   true: 确认并关闭
   *   false: 切换模式（从设备列表切换到备份列表）
   */
  bindSheetCancel=(status:boolean)=>{
    this.zipIndex=this.zipDataIndex
    this.deviceIndex=this.deviceDataIndex
    this.isShow=false
    this.dataRecoveryStatus=false
  }
  
  /**
   * bindSheetConfirm - 半模态框确定按钮处理
   * 
   * @param status - 内部状态标识
   *   true: 确认选择并关闭弹窗
   *   false: 切换显示模式
   */
  bindSheetConfirm=(status:boolean)=>{
    if(status){
      this.zipDataIndex=this.zipIndex // 保存选中索引
      this.deviceDataIndex=this.deviceIndex
      this.isShow=false
      this.dataRecoveryStatus=false
    }else{
      this.isShow=true // 切换到另一列表
    }

  }

  // ============ 样式定义 ============
  
  /** @Styles setStyle - 设置列表样式
   * 白色背景、圆角、内边距
   */
  @Styles setStyle():void{
    .backgroundColor(0xffffff)
    .size({width:"100%"})
    .borderRadius(15)
    .padding(20)
  }
  
  /** @Styles pageStyle - 页面样式
   * 占满宽高
   */
  @Styles pageStyle():void{
    .width("100%")
    .height("100%")
  }
  
  /** @Styles bindSheetStyle - 半模态框标题样式
   */
  @Styles bindSheetStyle():void{
    .padding({top:16,bottom:16,left:20,right:20})
  }
  
  /** @Styles transitionStyles - 过渡动画样式（历史备份）
   * 透明度渐变 + Y 轴平移组合动画
   */
  @Styles transitionStyles():void{
    .transition(TransitionEffect.opacity(1).animation({ duration: 1000, curve: Curve.Ease }).combine(
      TransitionEffect.translate({ y: 500  })
    ))
  }
  
  /** @Styles transitionsStyles - 过渡动画样式（设备列表）
   */
  @Styles transitionsStyles():void{
    .transition(TransitionEffect.opacity(1).animation({ duration: 1000, curve: Curve.Ease }).combine(
      TransitionEffect.translate({ y: 500  })
    ))
  }
}

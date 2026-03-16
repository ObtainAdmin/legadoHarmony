// ============ 导入模块 ============
import { ColumnModifier } from '../../../common/utils/ComponetModifier' // 列修饰器工具类
import { dataItem } from '../../../componets/dataList/dataItem' // 列表项数据模型
import { MyCenterTitle } from '../../../componets/myCenter/MyCenterTitle' // 我的页面标题栏组件
import { diskComponet } from '../../../componets/myCenter/diskComponet' // 设备信息组件
import { PublicConstants, TextConstants } from '../../../common/constants/PublicConstants' // 公共常量
import { ThemeItem } from '../../../common/model/Theme' // 主题类型定义
import { ThemeStorageKey } from '../../../common/constants/Theme' // 主题存储键常量

/**
 * @Entry - 页面入口装饰器
 * @Component - 组件装饰器
 * @struct DiskSet - 备份设置页面组件类
 */
@Entry
@Component
struct DiskSet {
  
  // ============ 自定义修饰器 ============
  
  /** Column: ColumnModifier - 基础列修饰器
   * 用于整体布局修饰
   */
  Column= new ColumnModifier()
  
  /** modifier: ColumnModifier - 内容区域修饰器
   * 设置左右内边距为 20 像素
   */
  modifier = new ColumnModifier().setCustom({left:20,right:20,top:0,bottom:0})

  // ============ 开关列表数据 ============
  
  /**
   * toggleList - 备份数据选择列表
   * 每项数据结构：[标题，值，图标，子值，状态]
   * 
   * 可选项：
   *   阅读器、主题、网络书籍、本地书籍、书架、书源、订阅
   */
  @State toggleList:dataItem[]=[
    new dataItem("阅读器","","","",false),
    new dataItem("主题","","","",false),
    new dataItem("网络书籍","","","",false),
    new dataItem("本地书籍","","","",false),
    new dataItem("书架","","","",false),
    new dataItem("书源","","","",false),
    new dataItem("订阅","","","",false),
  ]

  // ============ 高级设置数据 ============
  
  /** readingProgress: dataItem - 同步阅读进度设置
   * 标题 + 说明："进入退出阅读器时同步阅读进度"
   */
  @State readingProgress:dataItem= new dataItem("同步阅读进度","进入退出阅读器时同步阅读进度","","",false)
  
  /** localBackup: dataItem - 本地备份设置
   */
  @State localBackup:dataItem= new dataItem("本地备份","","","",false)
  
  /** deviceName: dataItem - 设备名称设置
   * 当前值："Meta 40 Pro"
   */
  @State deviceName:dataItem= new dataItem("设备名称","Meta 40 Pro","","",false)
  
  /** localBackupPath: dataItem - 本地备份路径设置
   * 当前值："emulated/emulated/阅读/备份"
   * type=true 表示可编辑输入框
   */
  @State localBackupPath:dataItem= new dataItem("本地备份路径","emulated/emulated/阅读/备份","","",true)

  // ============ 主题颜色绑定 ============
  
  /** @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
   * 响应式主题颜色绑定
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  // ============ 构建器：开关控件 ============
  
  /**
   * @Builder toggleComponets - 开关项构建器
   * 
   * @param item - dataItem 对象
   *   title: 标题文本
   *   value: 副标题/说明文本（可选）
   *   status: 开关状态
   * 
   * @returns Row 组件，包含左侧标题 + 右侧开关
   */
  @Builder toggleComponets(item:dataItem){
    Row(){
      // 左侧标题和副标题
      Column(){
        Text(item.title).fontSize(14).lineHeight(22) // 主标题
        Text(item.value.toString()).fontSize(12).lineHeight(20) // 副标题（可选显示）
          .visibility(item.value!=""?Visibility.Visible:Visibility.None) // 有值才显示
      }.alignItems(HorizontalAlign.Start)
      
      // 右侧 Toggle 开关
      Toggle({type:ToggleType.Switch,isOn:item.status})
        .onChange((isOn: boolean) => {
          item.status=isOn; // 双向绑定更新
        }).selectedColor(this.theme.mainColor) // 选中时使用主题色
        .hoverEffect(HoverEffect.None) // 禁用悬停效果
    }.justifyContent(FlexAlign.SpaceBetween) // 两端对齐
    .stateStyles({normal: this.componetStyles}) // 应用样式
  }

  // ============ 构建器：图片选择项 ============
  
  /**
   * @Builder ImageComponets - 图片选择项构建器
   * 
   * @param item - dataItem 对象
   * @param onClick - 点击回调函数
   * 
   * @returns Row 组件，包含左侧标题 + 右侧显示值 + 箭头
   *   布局示例：
   *   [标题 + 图标] [显示值] [箭头图标]
   */
  @Builder ImageComponets(item:dataItem,onClick: () => void ){
    Row(){
      // 左侧标题区（占 40% 宽度）
      Row({space:12}){
        Text(item.title).fontSize(14).lineHeight(22) // 标题文本
        Image(item.icon).size({width:20,height:20}) // 小图标（可选显示）
          .visibility(item.icon!=""?Visibility.Visible:Visibility.None)
      }.width("40%")
      
      // 右侧值显示区（占 60% 宽度）
      Row({space:5}){
        Flex({direction:item.status?FlexDirection.RowReverse:FlexDirection.Row}){
          // 根据状态调整文字方向
          Text(item.value.toString())
            .fontSize(12)
            .lineHeight(20)
            .fontColor(TextConstants.TEXT_FONT_COLOR)
            .textOverflow({overflow:TextOverflow.Ellipsis}) // 溢出省略
            .maxLines(1) // 最多一行
            .ellipsisMode(item.status?EllipsisMode.START:EllipsisMode.END) // 省略位置
        }.width(124).margin({bottom:3})
        
        // 右侧箭头图标
        Text(){
          ImageSpan($r("app.media.right")) // 内联图片作为文本元素
            .size({width:24,height:24})
            .verticalAlign(ImageSpanAlignment.BOTTOM) // 底部对齐
            .onClick(()=>{
              onClick(); // 触发点击事件
            })
        }
      }.width("60%")
      .padding({top:12,bottom:12})
      .justifyContent(FlexAlign.End)
    }.width(280) // 固定宽度
  }

  // ============ 构建器：通用文本 ============
  
  /**
   * @Builder Text - 通用文本构建器
   * 
   * @param value - 文本内容
   * @param fontSize - 字号
   * @param lineHeight - 行高
   * @param fontColor - 字体颜色（默认白色）
   */
  @Builder Text(value:string,fontSize:number,lineHeight:number,fontColor:ResourceColor=PublicConstants.THEME_COLOR_WHITE){
    Text(value).fontSize(fontSize).lineHeight(lineHeight).fontColor(fontColor)
  }

  // ============ 构建器：分组标题 ============
  
  /**
   * @Builder title - 分组标题构建器
   * 
   * @param title - 标题文本
   * 
   * 用途：展示"基础设置"、"选择要备份数据"等分组标题
   */
  @Builder title(title:string){
    Row(){
      this.Text(title,12,20,TextConstants.TEXT_FONT_COLOR) // 小字号灰色标题
    }.width("100%").justifyContent(FlexAlign.Start).padding({top:16,bottom:8,left:20,right:20})
  }

  // ============ UI 构建方法 - build() ============
  
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column
   * ├─ MyCenterTitle (标题栏：备份设置)
   * ├─ Column (设备信息卡片)
   * │  └─ diskComponet 组件
   * ├─ title ("基础设置")
   * ├─ Column (基础设置开关)
   * │  ├─ readingProgress
   * │  ├─ localBackup
   * │  └─ localBackupPath (可编辑输入)
   * └─ title ("选择要备份数据")
   *    └─ Column (备份选项列表)
   *       └─ ForEach(toggleList)
   */
  build() {
    Column() {
      // ========== 标题栏 ==========
      MyCenterTitle({title:"备份设置"})

      // ========== 设备信息卡片 ==========
      Column(){
        diskComponet({
          deviceName:this.deviceName,
          deviceNameValue:this.deviceName.value.toString()
        })
      }.attributeModifier(this.modifier) // 应用修饰器
      .stateStyles({normal: this.columnStyles}) // 应用样式
      .margin({top:12}) // 上外边距 12

      // ========== 基础设置分组 ==========
      this.title("基础设置")
      Column(){
        this.toggleComponets(this.readingProgress) // 同步阅读进度开关
        this.toggleComponets(this.localBackup) // 本地备份开关
        this.ImageComponets(this.localBackupPath,()=>{}) // 备份路径选择
      }.attributeModifier(this.modifier)
      .stateStyles({normal: this.columnStyles})

      // ========== 备份数据选择分组 ==========
      this.title("选择要备份数据")
      Column(){
        ForEach(this.toggleList,(item:dataItem,index:number)=>{
          this.toggleComponets(item) // 渲染每个选项的开关
        })
      }.attributeModifier(this.modifier)
      .backgroundColor(PublicConstants.THEME_COLOR_WHITE) // 白色背景
      .borderRadius(12) // 圆角 12
      
    }
    .height('100%')
    .attributeModifier(this.Column) // 应用整体修饰器
  }

  // ============ 样式定义 ============
  
  /** @Styles componetStyles - 组件样式
   * 内边距 12，宽度 280
   */
  @Styles componetStyles():void{
    .padding({top:12,bottom:12})
    .width(280)
  }
  
  /** @Styles columnStyles - 列样式
   * 白色背景、圆角 12
   */
  @Styles columnStyles():void{
    .backgroundColor(PublicConstants.THEME_COLOR_WHITE)
    .borderRadius(12)
  }
}

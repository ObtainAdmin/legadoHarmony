// ============ 导入模块 ============
import { ColumnModifier } from '../../../common/utils/ComponetModifier' // 列修饰器工具类
import { router } from '@kit.ArkUI'; // 页面路由导航 API
import CommonConstants from '../../../common/constants/CommonConstants' // 通用常量定义
import { dataItem } from '../../../componets/dataList/dataItem'; // 列表项数据模型
import { readStatisticsDataList } from '../../../componets/myCenter/readStatisticsDataList'; // 阅读统计列表组件
import { readBookList } from '../../../componets/dataList/readBookList'; // 书籍列表数据结构
import { readTabs } from '../../../componets/myCenter/readTabs'; // 阅读分类 Tab 组件
import { serviceDialog } from '../../../componets/webDavService/serviceDialog'; // WebDAV 服务对话框组件
import { PublicConstants } from '../../../common/constants/PublicConstants'; // 公共常量

/**
 * @Entry - 页面入口装饰器
 * @Component - 组件装饰器
 * @struct readStatistics - 阅读统计页面组件类
 */
@Entry
@Component
struct readStatistics {

  // ========== 自定义修饰器 ==========
  Column = new ColumnModifier()
  
  // ========== 从路由获取的参数 ==========
  /** @State type:number|string=(router.getParams() as dataItem).value
   * 接收上一页面传递的统计类型索引
   * value=0: 读过，1: 读完，2: 书签，3: 勋章
   */
  @State type:number|string=(router.getParams() as dataItem).value
  
  // ========== 书籍分类列表 ==========
  /** @State read_list:dataItem[] - 书籍类型分类
   * 每项：[分类名称，索引]
   */
  @State read_list:dataItem[]=[
    new dataItem("小说",12),
    new dataItem("漫画",12),
    new dataItem("有声书",12),
  ]
  
  // ========== 统计类型标签（已读/读完/书签） ==========
  /** @State title_list:dataItem[] - 统计类型列表
   * 用于顶部三个 Tab 切换
   */
  @State title_list:dataItem[]=[
    new dataItem("读过",12),
    new dataItem("读完",12),
    new dataItem("书签",12),
  ]
  
  // ========== 内部状态变量 ==========
  /** @State read_index:number=0
   * 当前选中的书籍分类索引（小说/漫画/有声书）
   */
  @State read_index:number=0
  
  /** @State translateNum:number=0
   * 滚动位移计数（暂未使用）
   */
  @State translateNum:number=0
  
  /** @State translateX:number=120
   * X 轴位移值（暂未使用）
   */
  @State translateX:number=120
  
  /** @State dateValue:number[]=[2023,36]
   * 日期相关数据（年份、天数？），具体用途待确认
   */
  @State dateValue:number[]=[2023,36]
  
  /** @Provide delStatus:boolean=false
   * 删除模式开关状态
   * Provide: 向下共享给子组件
   */
  @Provide delStatus:boolean=false

  // ========== 删除弹窗状态 ==========
  /** @State delDialog:boolean=false
   * 删除确认弹窗显示状态
   */
  @State delDialog:boolean=false
  
  // ========== 书籍列表数据（模拟数据） ==========
  /**
   * bookList:readBookList[] - 书籍列表
   * 每项数据结构：[书名，封面图，作者，月份数组，出版日期，阅读进度，选中状态]
   * 
   * 说明：
   *   - 月份数组：[开始月，结束月]
   *   - 阅读进度：0-100 的数字
   *   - status: 删除模式下的选中标记
   */
  @State bookList:readBookList[]=[
    new readBookList("夜的命名术",$r("app.media.book_cover"),"会说话的肘子",[20,23],new Date(),20,0),
    new readBookList("夜的命名术",$r("app.media.book_cover"),"会说话的肘子",[21,23],new Date(),30,1),
    new readBookList("夜的命名术",$r("app.media.book_cover"),"会说话的肘子",[22,23],new Date(),40,2),
    new readBookList("夜的命名术",$r("app.media.book_cover"),"会说话的肘子",[23,23],new Date(),70,3),
    new readBookList("夜的命名术",$r("app.media.book_cover"),"会说话的肘子",[23,23],new Date(),70,3),
    new readBookList("夜的命名术",$r("app.media.book_cover"),"会说话的肘子",[23,23],new Date(),70,3),
    new readBookList("夜的命名术",$r("app.media.book_cover"),"会说话的肘子",[23,23],new Date(),70,3),
    new readBookList("夜的命名术",$r("app.media.book_cover"),"会说话的肘子",[23,23],new Date(),70,3),

  ]
  
  // ========== 构建器：头部栏 ==========
  
  /**
   * @Builder head - 页面头部构建器
   * 
   * 布局层次：
   * Row (两端对齐)
   * ├─ Row(左侧返回按钮)
   * ├─ Row(中间标题)
   * └─ Row(右侧管理按钮)
   * 
   * 功能：
   *   - 返回按钮：点击返回上一页
   *   - 标题：根据 type 动态显示"读过/读完/书签"
   *   - 管理按钮：切换删除模式
   */
  @Builder head(){
    Row(){
      // ========== 左侧返回按钮 ==========
      Row(){
        Image($r("app.media.return_left"))
          .size({width:CommonConstants.TITLE_IMG_SIZE,height:CommonConstants.TITLE_IMG_SIZE})
          .onClick(()=>{
            router.back() // 返回上一页
          })
      }.width("33%") // 占 33% 宽度
      
      // ========== 中间标题 ==========
      Row(){
        Text(this.title_list[this.type].title).fontSize(16).fontWeight(600).lineHeight(24) // 标题文字
      }.width("33%")
      .justifyContent(FlexAlign.Center) // 居中对齐
      
      // ========== 右侧管理按钮 ==========
      Row(){
        Text(this.delStatus?"完成":"管理")
          .fontSize(14)
          .fontWeight(500)
          .lineHeight(22)
          .fontColor("rgba(0, 0, 0, 0.45)") // 半透明灰色
          .onClick(()=>{
            this.delStatus=!this.delStatus // 翻转删除模式状态
          })
      }.width("33%").justifyContent(FlexAlign.End) // 右对齐
    }.width("100%")
    .justifyContent(FlexAlign.SpaceBetween) // 两端对齐
    .padding({top:12,bottom:12}) // 上下内边距
  }

  // ========== 构建器：底部删除按钮 ==========
  
  /**
   * @Builder delBottom - 底部删除按钮覆盖层构建器
   * 
   * 功能：
   *   - 删除模式下显示在屏幕底部
   *   - 通过 overlay 覆盖在主内容之上
   *   - 带有渐入渐出动画效果
   * 
   * 样式特点：
   *   - 白底红字
   *   - 上边框
   *   - 透明度 + Y 轴平移组合动画
   */
  @Builder delBottom(){
      Button({ type: ButtonType.Normal, stateEffect: true }){
        Row(){
          Text("删除").fontColor(Color.Red) // 红色文字
        }.height("100%")
      }.backgroundColor(PublicConstants.THEME_COLOR_WHITE) // 白色背景
      .width("100%") // 占满宽度
      .height(50) // 固定高度
      .borderColor("rgba(0, 0, 0, 0.06)") // 浅灰边框
      .borderWidth({
        top:1 // 上边框 1 像素
      })
      .visibility(this.delStatus?Visibility.Visible:Visibility.None) // 根据状态显示/隐藏
      .transition( // 过渡动画
        TransitionEffect.asymmetric(
          TransitionEffect.OPACITY.animation({ duration: 500 }).combine( // 淡入/淡出
            TransitionEffect.translate({ y: 50 }).animation({  duration: 500 })) // 向上/向下平移
          ,
          TransitionEffect.OPACITY.animation({ duration: 500 }).combine( // 淡入/淡出
            TransitionEffect.translate({ y: 0}).animation({ duration: 500 })) // 回到原位
        )
      )
    .onClick(()=>{
      this.deleteList() // 点击触发删除逻辑
    })
  }
  
  // ========== UI 构建方法 - build() ==========
  
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column
   * ├─ Column (主内容区)
   * │  ├─ head() - 头部栏（返回/标题/管理）
   * │  ├─ readTabs - 书籍分类 Tab 条（小说/漫画/有声书）
   * │  └─ readStatisticsDataList - 阅读统计列表组件
   * └─ delBottom overlay - 底部删除按钮覆盖层
   * 
   * 布局特性：
   *   - 主内容区高度 FULL_HEIGHT（全屏）
   *   - 删除按钮通过 overlay 固定在底部
   */
  build() {
    Column(){
      Column(){
        this.head() // 渲染头部栏
        
        readTabs({
          read_list:this.read_list // 传递分类数据
        })
        
        // 书籍组件
        readStatisticsDataList({
          dateValue:this.dateValue, // 传递日期数据
          bookList:this.bookList // 传递书籍列表
        })
      }.attributeModifier(this.Column) // 应用自定义修饰器
      .height(CommonConstants.FULL_HEIGHT) // 占满全屏高度
      .width(CommonConstants.FULL_WIDTH) // 占满全屏宽度
    }.overlay( this.delBottom(), { // 添加底部覆盖层
      align: Alignment.Bottom, // 底部对齐
      offset: { x: 0, y: 0 } // 无偏移
    })

  }

  // ========== 事件处理方法 ==========
  
  /**
   * deleteList - 删除列表处理
   * 打开删除确认弹窗
   */
  deleteList(){
    this.clearInfoDel?.open()
  }
  
  /**
   * onCancel - 删除取消回调（空实现）
   */
  onCancel(){
    
  }
  
  /**
   * onAccept - 删除确认回调
   * 过滤掉被选中的书籍（status=true）
   */
  onAccept(){
    this.bookList=this.bookList.filter(item=>item.status!=true) // 保留未选中的书籍
    this.bookList.forEach(item=>console.log(item.status+"--")) // 调试输出
    this.delStatus=!this.delStatus // 退出删除模式
  }
  
  /**
   * exitApp - 弹窗关闭处理
   */
  exitApp() {
    this.delDialog = false
  }
  
  /**
   * clearInfoDel - 删除确认对话框控制器
   * 配置清除弹窗样式和内容
   */
  clearInfoDel: CustomDialogController | null = new CustomDialogController({
    builder: serviceDialog({
      title:"确认删除吗？",
      value:"",
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() }
    }),
    cancel: this.exitApp,
    autoCancel: true,
    alignment: DialogAlignment.Center,
    offset:{dx:0,dy:20},
    customStyle: true
  })
  
  /**
   * aboutToAppear - 组件即将出现时调用
   * 初始化日志输出，便于调试
   */
  aboutToAppear(): void {
      console.log(this.type+"------")
  }

}

/**
 * readStatisticsDataList 组件 - 阅读统计数据显示列表
 * 
 * 功能概述：
 * 1. 显示用户的年度阅读统计数据和阅读记录列表
 * 2. 支持滑动删除操作，通过左右滑动显示删除按钮
 * 3. 提供批量删除模式，可多选阅读记录进行批量操作
 * 4. 显示每本书的阅读进度、阅读时长和最后阅读时间
 * 5. 支持触摸手势识别，实现流畅的交互体验
 * 
 * 设计特点：
 * 1. 响应式布局：适配不同屏幕尺寸，使用百分比和固定值混合布局
 * 2. 手势交互：支持左右滑动显示删除功能，触摸事件处理
 * 3. 动画效果：使用过渡动画实现平滑的状态切换
 * 4. 批量操作：提供复选框选择模式进行批量删除
 * 5. 数据可视化：直观展示阅读进度和时长统计
 * 
 * 使用场景：
 * 1. 我的中心页面中的阅读统计模块
 * 2. 用户查看年度阅读总结
 * 3. 管理个人阅读记录（删除、查看详情）
 * 
 * 组件结构：
 * - 统计头部：显示年度阅读总结（年份和阅读数量）
 * - 书籍列表：每本书显示封面、书名、作者、阅读时长
 * - 进度区域：显示阅读进度百分比和最后阅读时间
 * - 删除功能：滑动显示删除按钮或复选框选择
 * 
 * 注意事项：
 * 1. 需要正确处理触摸事件和手势识别
 * 2. 批量删除模式与滑动删除模式互斥
 * 3. 动画效果需要确保性能优化
 * 4. 数据绑定需要保持响应式更新
 */

import CommonConstants from '../../common/constants/CommonConstants'
import { PublicConstants } from '../../common/constants/PublicConstants'
import { readBookList } from '../dataList/readBookList'


@Component
export struct readStatisticsDataList{
  /**
   * 日期统计值数组
   * @type {number[]}
   * @description [年份, 阅读数量] 格式的数组，用于显示年度阅读统计
   * @example [2024, 25] 表示2024年阅读了25本书
   */
  @Prop dateValue:number[]
  
  /**
   * 阅读书籍列表数据
   * @type {readBookList[]}
   * @description 双向绑定的阅读记录列表，包含每本书的详细信息
   * @link 使用@Link装饰器实现父子组件双向数据绑定
   */
  @Link bookList:readBookList[]
  
  /**
   * 平移距离
   * @type {number}
   * @default 0
   * @description 控制书籍项左右滑动的平移距离，负值表示向左滑动
   */
  @State translateX:number=0
  
  /**
   * 当前操作的书籍索引
   * @type {number}
   * @default 0
   * @description 记录当前正在滑动或操作的书籍在列表中的索引位置
   */
  @State bookIndex:number=0
  
  /**
   * 触摸起始点X坐标
   * @type {number}
   * @default 0
   * @description 记录触摸开始时的屏幕X坐标，用于计算滑动方向
   */
  @State screenStartX: number = 0
  
  /**
   * 触摸起始点Y坐标
   * @type {number}
   * @default 0
   * @description 记录触摸开始时的屏幕Y坐标，用于区分水平和垂直滑动
   */
  @State screenStartY: number = 0
  
  /**
   * 触摸结束点X坐标
   * @type {number}
   * @default 0
   * @description 记录触摸结束时的屏幕X坐标，用于计算滑动距离
   */
  @State lastScreenX: number = 0
  
  /**
   * 触摸结束点Y坐标
   * @type {number}
   * @default 0
   * @description 记录触摸结束时的屏幕Y坐标，用于计算滑动方向
   */
  @State lastScreenY: number = 0
  
  /**
   * 删除状态标志
   * @type {boolean}
   * @description 是否处于批量删除模式，true表示显示复选框进行多选
   * @consume 使用@Consume装饰器从祖先组件消费共享状态
   */
  @Consume delStatus:boolean
  /**
   * 文本构建器 - 通用文本样式
   * @param {string} value - 文本内容
   * @param {ResourceColor} back - 文本颜色，默认rgba(0, 0, 0, 0.45)
   * @returns {void}
   * @description 创建统一风格的文本组件，减少样式重复代码
   * 使用12px字体大小，400字重，20px行高
   */
  @Builder text(value:string,back:ResourceColor="rgba(0, 0, 0, 0.45)"){
    Text(value)
      .fontSize(12)
      .fontWeight(400)
      .lineHeight(20)
      .fontColor(back)
  }
  
  /**
   * 滚动控制器
   * @type {Scroller}
   * @description 控制列表滚动行为的Scroller实例
   */
  scroller: Scroller = new Scroller()
  /**
   * 阅读统计头部构建器
   * @param {number[]} dateValue - 日期统计值数组 [年份, 阅读数量]
   * @returns {void}
   * @description 构建阅读统计的头部区域，显示年度阅读总结
   * 格式："XXXX年读过XX本"，使用16px字体，500字重
   * 上下各12px内边距，100%宽度，左对齐
   */
  @Builder readHeader(dateValue:number[]){
    Row(){
      Text(`${dateValue[0]}年读过${dateValue[1]}本`)
        .fontSize(16)
        .lineHeight(24)
        .fontWeight(500)
    }.padding({top:12,bottom:12})
    .width("100%")
    .justifyContent(FlexAlign.Start)
  }
  /**
   * 书籍作者信息构建器
   * @param {readBookList} book - 书籍数据对象
   * @returns {void}
   * @description 构建书籍的作者和阅读时长信息区域
   * 包含书名、作者和累计阅读时长
   * 使用50%宽度，80px固定高度，左侧12px外边距
   * 垂直方向12px间距，左对齐布局
   */
  @Builder bookAuthor(book:readBookList){
    Column({space:12}){
      Text(book.bookName).fontSize(16).lineHeight(24)
      Column(){
        this.text(book.author)
        this.text(`累计阅读${book.readingDuration[0]}小时${book.readingDuration[1]}分钟`)
      }.alignItems(HorizontalAlign.Start)
    }.alignItems(HorizontalAlign.Start)
    .width("50%")
    .height(80)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({left:12})
  }
  /**
   * 书籍时间和进度构建器
   * @param {boolean} status - 复选框选中状态
   * @param {Date} dateTime - 最后阅读时间
   * @param {number} schedule - 阅读进度百分比
   * @param {number} index - 书籍在列表中的索引
   * @returns {void}
   * @description 构建书籍的阅读时间和进度区域
   * 根据删除状态显示不同的内容：
   * 1. 批量删除模式：显示复选框用于多选
   * 2. 正常模式：显示最后阅读时间和阅读进度
   * 
   * 设计特点：
   * - 使用不对称过渡动画实现平滑的状态切换
   * - 复选框使用橙色选中颜色(0xed6f21)
   * - 阅读进度使用24px大字体突出显示
   * - 右对齐布局，25%宽度，80px固定高度
   */
  @Builder bookTime(status:boolean,dateTime:Date,schedule:number,index:number){
    Column({space:30}){
      if(this.delStatus){
        /**
         * 批量删除模式：显示复选框
         * @description 使用圆形复选框，橙色选中状态
         * 选中状态变化时更新书籍列表的status字段
         * 应用不对称过渡动画实现平滑显示效果
         */
        Checkbox({ name: 'checkbox1'+index, group: 'checkboxGroup' })
          .select(status)
          .selectedColor(0xed6f21)
          .shape(CheckBoxShape.CIRCLE)
          .onChange((value: boolean) => {
            this.bookList[index].status=value
          })
          .transition(
            TransitionEffect.asymmetric(
              TransitionEffect.OPACITY.animation({ duration: 500 }).combine(
                TransitionEffect.translate({ x: 100 }).animation({ duration: 500 }))
              ,
              TransitionEffect.OPACITY.animation({ delay: 500, duration: 1000 }).combine(
                TransitionEffect.translate({ x: 100 }).animation({ duration: 500 }))
            )
          )
      }else{
        /**
         * 正常模式：显示最后阅读时间
         * @description 将Date对象格式化为"年/月/日"字符串显示
         * 使用灰色文字颜色(rgba(0, 0, 0, 0.45))
         * 应用不对称过渡动画
         */
        Text(this.dateTimeToString(dateTime))
          .fontSize(12)
          .fontWeight(400)
          .lineHeight(20)
          .fontColor("rgba(0, 0, 0, 0.45)")
          .transition(
            TransitionEffect.asymmetric(
              TransitionEffect.OPACITY.animation({ duration: 500 }).combine(
                TransitionEffect.translate({ x: 0 }).animation({ duration: 0 }))
              ,
              TransitionEffect.OPACITY.animation({ delay: 500, duration: 1000 }).combine(
                TransitionEffect.translate({ x: 100 }).animation({ duration: 500 }))
            )
          )
      }
      /**
       * 阅读进度显示
       * @description 显示"读到XX%"格式的阅读进度
       * 进度数字使用24px大字体，600字重突出显示
       */
      Row(){
        this.text("读到",Color.Black)
        Text(schedule.toString()).fontSize(24).lineHeight(24).fontWeight(600)
        this.text("%",Color.Black)
      }
    }.alignItems(HorizontalAlign.End)
    .justifyContent(FlexAlign.SpaceBetween)
    .width("25%")
    .padding(0)
    .height(80)
  }
  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建阅读统计列表的主要UI结构
   * 包含统计头部和可滚动的书籍列表
   * 每本书籍项支持滑动删除和触摸交互
   */
  build() {
     Column(){
       // 阅读统计头部
       this.readHeader(this.dateValue)
       
       // 书籍列表滚动区域
       Scroll(){
         Column(){
           // 遍历书籍列表，为每本书创建列表项
           ForEach(this.bookList,(book:readBookList,index:number)=>{
             Row(){
               Row(){
                 /**
                  * 书籍内容区域
                  * @description 包含封面、作者信息和时间进度
                  * 使用100%宽度，16px内边距
                  */
                 Row(){
                   // 书籍封面图片，固定60x80尺寸
                   Image(book.coverImage)
                     .size({width:60,height:80})
                   
                   // 书名、作者及阅读时长信息
                   this.bookAuthor(book)
                   
                   // 时间和进度信息
                   this.bookTime(book.status,book.dateTime,book.schedule,index)
                 }.padding(16).width("100%")
                 
                 /**
                  * 删除按钮区域
                  * @description 红色背景的删除按钮，宽度70px，高度110px
                  * 仅在滑动时显示，点击执行删除操作
                  */
                 Row(){
                   Text("删除").fontColor(PublicConstants.THEME_COLOR_WHITE)
                 }.width(70).height(110).backgroundColor(Color.Red)
                 .justifyContent(FlexAlign.Center)
               }.justifyContent(FlexAlign.End) // 右对齐，确保删除按钮在右侧
               .translate({x:this.bookIndex==index?this.translateX:0}) // 根据索引应用平移
               .animation({
                 duration: 500,
                 curve: Curve.FastOutSlowIn // 使用快速出慢入动画曲线
               })
               .onTouch((e) => {
                 this.ouTouch(e) // 处理触摸事件
               })
               .gesture(
                 SwipeGesture({ direction: SwipeDirection.All })
                   .onAction(() => {
                     if(!this.delStatus){ // 非批量删除模式下才响应滑动
                       console.log(index+"")
                       this.bookIndex=index
                       let direction =this.directionIf()
                       if(direction==="Left"){
                         this.translateX=-70 // 向左滑动显示删除按钮
                       }else{
                         this.translateX=0 // 向右滑动隐藏删除按钮
                       }
                     }
                   })
               )
             }.width(CommonConstants.FULL_WIDTH) // 使用全宽常量
             .backgroundColor(PublicConstants.THEME_COLOR_WHITE) // 白色背景
             .borderRadius(12) // 12px圆角
             .margin({bottom:16}) // 底部16px外边距
             .clip(true) // 裁剪超出部分
           })
         }
       }.scrollable(ScrollDirection.Vertical) // 垂直滚动
       .scrollBar(BarState.Off) // 关闭滚动条
       .friction(0.6) // 设置滚动摩擦系数
       .edgeEffect(EdgeEffect.None) // 禁用边缘效果
       .size({width:320,height:"80%"}) // 固定宽度320px，高度80%
       .padding({bottom:50}) // 底部50px内边距
       .align(Alignment.TopStart) // 顶部左对齐
     }
  }

  /**
   * 触摸事件处理函数
   * @param {TouchEvent} e - 触摸事件对象
   * @returns {void}
   * @description 处理触摸开始和结束事件，记录触摸点的坐标
   * 用于计算滑动方向和距离，实现滑动删除功能
   * 
   * 事件处理逻辑：
   * 1. TouchType.Down: 记录触摸起始点坐标
   * 2. TouchType.Up: 记录触摸结束点坐标
   */
  ouTouch(e:TouchEvent){
    if (e.type === TouchType.Down && e.touches.length > 0) { // 触摸开始，记录初始位置
      this.screenStartX = e.touches[0].screenX;
      this.screenStartY = e.touches[0].screenY;
    } else if (e.type === TouchType.Up && e.changedTouches.length > 0) { // 当手指抬起时，更新最后的位置
      this.lastScreenX = e.changedTouches[0].screenX;
      this.lastScreenY = e.changedTouches[0].screenY;
    }
  }


  /**
   * 判断滑动方向
   * @returns {string} 滑动方向字符串：'Left'、'Right' 或空字符串
   * @description 根据触摸起始点和结束点的坐标计算滑动方向
   * 只识别水平滑动（左右方向），忽略垂直滑动
   * 
   * 判断逻辑：
   * 1. 计算X轴和Y轴的滑动距离
   * 2. 比较绝对值，确定主要滑动方向
   * 3. 只有水平滑动距离大于垂直滑动距离时才返回方向
   */
  directionIf():string{
    const swipeX = this.lastScreenX - this.screenStartX;
    const swipeY = this.lastScreenY - this.screenStartY;
    // 判断滑动方向
    let directionText = '';
    if (Math.abs(swipeX) > Math.abs(swipeY)) {
      if (swipeX > 0) {
        directionText = 'Right'; // 向右滑动
      } else {
        directionText = 'Left'; // 向左滑动
      }
    }
    return directionText
  }
  /**
   * 日期格式化函数
   * @param {Date} date - 日期对象
   * @returns {string} 格式化后的日期字符串，格式：年/月/日
   * @description 将Date对象格式化为"YYYY/MM/DD"格式的字符串
   * 用于显示最后阅读时间
   * 
   * 注意：月份需要+1，因为JavaScript的Date对象月份从0开始
   */
  dateTimeToString(date:Date){
    let year=date.getFullYear()
    let month=date.getMonth()+1
    let day=date.getDate()
    return `${year}/${month}/${day}`
  }


}

/**
 * 书籍编辑页面 - 用于编辑书籍信息的完整页面
 * 
 * 功能概述：
 * 1. 编辑书籍基本信息：书名、作者、封面地址、书籍简介
 * 2. 提供封面图片选择功能（本地图片和封面换源）
 * 3. 支持书源搜索和选择
 * 4. 提供重置和保存功能
 * 5. 显示封面选择弹窗，支持多封面预览和选择
 * 
 * 页面结构：
 * - 顶部导航栏：返回按钮和页面标题
 * - 书籍基本信息区：封面、书名、作者
 * - 封面地址和操作区：封面URL输入、本地图片选择、封面换源
 * - 书籍简介编辑区：多行文本输入
 * - 底部操作区：重置和保存按钮
 * - 封面选择弹窗：多封面预览和选择
 * 
 * 数据模型：
 * 使用BookEditorType类管理书籍编辑数据
 * 支持实时编辑和状态管理
 */

import { router, SwipeRefresher } from '@kit.ArkUI'
import { ThemeStorageKey } from '../../../common/constants/Theme'
import { ThemeItem } from '../../../common/model/Theme'
import { BookEditorType } from './BookEditorType/BookEditorType'
import inputComponent from './InputComponet/inputComponet'

/**
 * 书籍封面图片样式扩展函数
 * 
 * 功能：为书籍封面图片提供统一的样式
 * 样式特点：
 * - 固定宽度90像素，高度120像素
 * - 圆角5像素
 * - 应用于页面中的所有书籍封面图片
 * 
 * 使用场景：书籍编辑页面中的封面显示和选择
 */
@Extend(Image) function BookIconSize(){
  .width(90)
  .height(120)
  .borderRadius(5)
}

/**
 * 书籍编辑页面结构体
 * 
 * 职责：
 * 1. 管理书籍编辑的完整流程
 * 2. 提供书籍信息的编辑界面
 * 3. 处理封面图片的选择和更换
 * 4. 管理书源搜索和选择
 * 5. 提供重置和保存功能
 * 
 * 设计特点：
 * - 使用@Entry装饰器，表示这是一个页面级组件
 * - 使用@Component装饰器，表示这是一个UI组件
 * - 采用模块化设计，将功能分解为多个Builder函数
 * - 支持主题颜色配置
 */
@Entry
@Component
struct BookEditorPage {
  /** 默认书籍封面图标资源 */
  BookIcon:Resource = $r('app.media.cover_list')
  
  /** 默认书籍名称 */
  BookName:string = '大奉打更人'
  
  /** 默认作者名称 */
  Author:string = '卖报小郎君'
  
  /** 默认封面图片URL地址 */
  BookIconUrl:string = 'https://www.qidian.com/book/1031940621'
  
  /** 默认书籍简介文本 */
  BookSynopsis:string = "《大奉打更人》（第一卷）实体书已在天猫、当当、京东等全平台，以及各个实体书店发售。这个世界，有儒；有道；有佛；有妖；有术士。\n" +
    "警校毕业的许七安幽幽醒来，发现自己身处牢狱之中，三日后流放边陲.....他起初的目的只是自保，顺便在这个没有人权的社会里当个富家翁悠闲度日。\n" +
    "多年后，许七安回首前尘，身后是早已逝去的敌人，以及累累白骨。\n" +
    "滚滚长江东逝水，浪花淘尽英雄，是非成败转头空。青山依旧在，几度夕阳红。"

  /** 书籍编辑数据模型，封装书籍的所有编辑信息 */
  private BookEditor:BookEditorType = new BookEditorType(
    this.BookName,
    this.Author,
    this.BookIcon,
    this.BookIconUrl,
    this.BookSynopsis
  );
  
  /** 应用主题配置，从应用存储中读取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /** 标题文本颜色 - 用于标签文字（如"书名"、"作者"等） */
  TitleTextColor:Color = Color.Grey
  
  /** 正文文本颜色 - 用于用户输入的文本内容 */
  TextColor:string = "#e0000000"
  
  /** 更换书籍封面图按钮颜色 - 用于"选择本地图片"和"封面换源"按钮 */
  ButtonColor:string = '#0f000000'
  
  /** 编辑书籍确认按钮颜色 - 用于"保存"按钮 */
  BtnConfirmColor:string = '#F60'
  
  /** 编辑书籍取消按钮颜色 - 用于"重置"按钮，使用主题的次要颜色 */
  BtnCancelColor:string = this.theme.secondColor

  /**
   * 电池显示占位组件
   * 
   * 功能：为系统状态栏（电池、信号等）预留空间
   * 设计考虑：不同设备的系统状态栏高度不同，使用固定高度占位
   * 当前实现：空文本占位，高度40像素
   */
  @Builder BufComponent () {
    Column(){
      Text('')
        .fontSize(16)
    }
    .height(40)
  }

  /**
   * 顶部导航栏组件
   * 
   * 功能：提供页面导航和标题显示
   * 包含元素：
   * - 返回按钮：点击返回上一页面
   * - 页面标题："书籍信息编辑"
   * 
   * 交互功能：返回按钮使用router.back()进行页面导航
   */
  @Builder TopComponent() {
    Flex({justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center})
    {
      // 返回按钮
      Image($r('app.media.return_left'))
        .width(20)
        .height(20)
        .onClick(()=>{
          router.back()  // 返回上一页面
        })
      
      // 页面标题
      Text('书籍信息编辑')
        .margin({left: 12})
        .fontColor(this.TextColor)
    }
    .padding({left: 20, right: 20, top: 12, bottom: 12})
    .height(48)
  }

  /**
   * 保存或重置书籍编辑内容组件
   * 
   * 功能：提供编辑操作的最终确认和取消功能
   * 包含按钮：
   * - 重置按钮：橙色文字，使用主题次要颜色背景
   * - 保存按钮：白色文字，使用确认颜色背景，圆角7像素
   * 
   * 设计特点：两个按钮等宽分布，提供清晰的视觉对比
   * 当前状态：按钮点击事件待实现
   */
  @Builder SelectComponent() {
    Flex({justifyContent: FlexAlign.SpaceBetween}){
      // 重置按钮
      Button(){
        Text('重置')
          .fontSize(16)
          .fontColor(this.BtnConfirmColor)
      }
      .backgroundColor(this.BtnCancelColor)
      .width(152)
      .height(38)
      .onClick(()=>{
        // 重置功能待实现
      })
      
      // 保存按钮
      Button(){
        Text('保存')
          .fontSize(16)
          .fontColor(Color.White)
      }
      .borderRadius(7)
      .backgroundColor(this.BtnConfirmColor)
      .width(152)
      .height(38)
      .onClick(()=>{
        // 保存功能待实现
      })
    }
    .height(64)
    .padding({left: 20, right: 20, top: 12, bottom: 12})
  }

  @State BookIconArr2:BookEditorType [] = [
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
    new BookEditorType(),
  ]
  @State BookIconArr:Resource [] = [
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
    this.BookIcon,
  ]
  @State selectIcon:boolean = false
  @State BookSource:number = 24
  @State FindBook:string = '已搜索到' + this.BookSource + '个书源,'
  @State FindBookOver:string = '共搜索到' + this.BookSource + '个书源,'
  @State Loading:boolean = true
  //弹窗组件
  @State isWindowShow:boolean = false
  @Builder WindowBuilder() {
    Column(){
      Flex(){
        if (this.Loading){
          SwipeRefresher({ isLoading: true })
            .width(30)
            .height(24)
            .colorBlend(this.BtnConfirmColor)
        }
        // Image($r('app.media.right'))
        //   .objectFit(ImageFit.Contain)
        //   .aspectRatio(1)
        //   .rotate({ x: 0, y: 0, z: 1, angle: this.rotateAngle })
        //   .height(24)
        //   .width(24)
        Flex({justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center})
        {
          Text(this.Loading ? this.FindBook:this.FindBookOver)
            .fontSize(14)
            .fontColor(Color.Grey)
          Text(this.Loading ? '点击暂停':'点击刷新')
            .fontSize(14)
            .fontColor(this.BtnConfirmColor)
            .margin({left:10})
            .onClick(()=>{
            this.Loading ? this.Loading = false: this.Loading = true;
          })
        }
        .height(24)
      }
      .onAppear(()=>{
        // this.startRotate()
        this.Loading = true
      })
      .height(54)
      .padding({top: 16, bottom: 16, left:20, right:20})

      List(){
        ListItem(){
          Flex({wrap:FlexWrap.Wrap}){
            ForEach(this.BookIconArr2, (Item:BookEditorType,Index:number)=>{
              Image(Item.getBookIcon())
                .BookIconSize()
                .borderRadius(10)
                .margin({left:22, bottom:24})
                .borderWidth(Item.getBookSelect() ? 2 : 0)
                .borderColor(Color.Black)
                .onClick(()=>{
                    this.BookIconArr2[Index].setBookSelect(true)
                    this.BookIconArr2.push(new BookEditorType())
                    this.BookIconArr2.pop()
                })

            })
          }.width('100%')
        }
      }.height('100%').width("100%")

    }
    .width('100%')
  }


  // //刷新动画
  // @State rotateAngle:number=0
  // @State timeoutID:number = 1
  // startRotate() {
  //   this.timeoutID = setInterval(() => {
  //     this.rotateAngle = 0
  //     animateTo({ duration: 800 }, () => {
  //       this.rotateAngle = 360
  //     })
  //   }, 800);
  // }
  // clearAnimation(){
  //   clearTimeout(this.timeoutID);
  // }

  build() {
    Column() {
      this.BufComponent()//留给电池显示

      this.TopComponent()
      Flex({direction:FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center})
      {
        Image(this.BookIcon).BookIconSize()
        Flex({direction:FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center})
        {
          Column({space:4})
          {
            Text('书名').fontColor(this.TitleTextColor).fontSize(12)
            Flex({justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center})
            {
              inputComponent({
                TEXT:this.BookEditor.getBookName(),
                Height:32,
                FontSize:12,
                FontColor:this.TextColor
              })
              // Text(this.BookEditor.getBookName()).fontSize(12).fontColor(this.TextColor).margin({left:16})
            }
            .borderRadius(5)
            .backgroundColor('#0a000000')
            .height(32)
          }
          .alignItems(HorizontalAlign.Start)
          .height(58)
          Column({space:4})
          {
            Text('作者').fontColor(this.TitleTextColor).fontSize(12)
            Flex({justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center})
            {
              inputComponent({
                TEXT:this.BookEditor.getBookAuthor(),
                Height:32,
                FontSize:12,
                FontColor:this.TextColor
              })
              // Text(this.BookEditor.getBookAuthor()).fontSize(12).fontColor(this.TextColor).margin({left:16})
            }
            .borderRadius(5)
            .backgroundColor('#0a000000')
            .height(32)
          }
          .alignItems(HorizontalAlign.Start)
          .height(58)
        }
        .width(212)
        .height(120)
      }
      .height(144)
      .padding({left: 20, right: 20, top: 12, bottom: 12})
      Flex({direction:FlexDirection.Column, justifyContent:FlexAlign.SpaceBetween}){
        Text('封面地址').fontSize(12)
        Flex({justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center}){
          inputComponent({
            TEXT:this.BookEditor.getBookIconUrl(),
            Height:32,
            FontSize:14,
            FontColor:this.TextColor
          })
        }
        .height(38)
        .borderRadius(5)
        .backgroundColor('#0a000000')
        Flex({justifyContent: FlexAlign.SpaceBetween}){
          Flex({justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center}){
            Text('选择本地图片')
              .fontSize(14)
          }
          .borderRadius(7)
          .backgroundColor(this.ButtonColor)
          .width(152)
          .height(38)
          Flex({justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center}){
            Text('封面换源')
              .fontSize(14)
          }
          .borderRadius(7)
          .backgroundColor(this.ButtonColor)
          .width(152)
          .height(38)
          .onClick(()=>{
            this.isWindowShow = true
          })
          .bindSheet(this.isWindowShow, this.WindowBuilder(),{
            detents:[688,300,100],
            maskColor: '#99000000',
            backgroundColor:Color.White,
            blurStyle:BlurStyle.Thick,
            showClose:false,
            preferType: SheetType.CENTER,
            shouldDismiss:((sheetDismiss: SheetDismiss)=> {
              console.log("bind sheet shouldDismiss")
              sheetDismiss.dismiss()
              this.isWindowShow = false
            })
          })
        }
      }
      .width('100%')
      .height(140)
      .padding({left: 20, right: 20, top: 12, bottom: 12})
      Flex({direction:FlexDirection.Column}){

        Text('书籍简介')
          .fontSize(12)
          .fontColor(this.TitleTextColor)

        List(){
          ListItem(){
            inputComponent({
              TEXT:this.BookEditor.getBookSynopsis(),
              textAlign:Alignment.TopStart,
              Height:296,
              FontSize:14,
              FontColor:this.TextColor
            })
            // Text(this.BookSynopsis)
            //   .fontSize(14)
            //   .fontColor(this.TextColor)
            //   .lineHeight(22)
            //   .textAlign(TextAlign.JUSTIFY)
            //   .fontWeight(400)
          }
        }
        .width(320)
        .height(296)
        .borderRadius(10)
        .backgroundColor('#0a000000')
        .margin({top:4})

      }
      .height(344)
      .padding({left: 20, right: 20, top: 12, bottom: 12})

      this.SelectComponent()
    }
    .onAppear(()=>{
      this.BookIconArr2.forEach((item:BookEditorType) => {
        item.setBookIcon(this.BookIcon)
        item.setBookSelect(false)
      });
    })
    .direction(Direction.Rtl)
    .width('100%')
  }

}

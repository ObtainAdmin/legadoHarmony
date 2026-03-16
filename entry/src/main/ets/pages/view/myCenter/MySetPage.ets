// ============ 导入模块 ============
import MySetConstants from '../../../common/constants/MySetConstants' // 设置常量定义（键名）
import { Attribute } from '../../../common/utils/Attribute' // 属性工具类
import { SetList, SetGroupList } from '../../../componets/dataList/SetListGroup' // 设置列表和分组数据结构
import { SetHead } from '../../../componets/myset/SetHead' // 设置页头部组件
import { SetListView } from '../../../componets/myset/SetListView' // 设置列表项视图组件

/**
 * @Entry - 页面入口装饰器
 * @Component - 组件装饰器
 * @struct MySetPage - 我的设置页面组件类
 */
@Entry
@Component
struct MySetPage{
  
  // ============ 半模态框状态变量 ============
  
  /** @State private isShowPreDon: boolean = false
   * 预下载数量选择器弹窗显示状态
   */
  @State private isShowPreDon: boolean = false
  
  /** @State private isShowLanguage: boolean = false
   * 语言选择器弹窗显示状态
   */
  @State private isShowLanguage: boolean = false

  // ============ 持久化绑定状态变量 ============
  
  /** @StorageLink(MySetConstants.SET_REFRESH) setRefresh: boolean = true
   * 自动刷新开关状态
   * StorageLink: 跨页面共享并持久化
   */
  @StorageLink(MySetConstants.SET_REFRESH) setRefresh: boolean = true
  
  /** @StorageLink(MySetConstants.SET_JUMP) setJump: boolean = true
   * 自动跳转最近阅读开关
   */
  @StorageLink(MySetConstants.SET_JUMP) setJump: boolean = true
  
  /** @StorageLink(MySetConstants.SET_REPLACE) setReplace: boolean = true
   * 默认启用替换净化开关
   */
  @StorageLink(MySetConstants.SET_REPLACE) setReplace: boolean = true
  
  /** @StorageLink(MySetConstants.SET_TIP) setTip: boolean = true
   * 返回时提示放入书架开关
   */
  @StorageLink(MySetConstants.SET_TIP) setTip: boolean = true
  
  /** @StorageLink(MySetConstants.SET_IMG_ANTI) setImgAnti: boolean = true
   * 图片抗锯齿开关
   */
  @StorageLink(MySetConstants.SET_IMG_ANTI) setImgAnti: boolean = true
  
  /** @StorageLink(MySetConstants.SET_AWAKEN) setAwaken: boolean = true
   * Webservice 唤醒锁开关
   */
  @StorageLink(MySetConstants.SET_AWAKEN) setAwaken: boolean = true
  
  /** @StorageLink(MySetConstants.SET_HEAD) setHead: boolean = true
   * 全程响应耳机按键开关
   */
  @StorageLink(MySetConstants.SET_HEAD) setHead: boolean = true
  
  /** @StorageLink(MySetConstants.SET_SEARCH) setSearch: boolean = true
   * 文字操作显示搜索开关
   */
  @StorageLink(MySetConstants.SET_SEARCH) setSearch: boolean = true
  
  /** @StorageLink(MySetConstants.SET_PRE_DOWNLOAD) select: number = 10
   * 预下载章节数量（默认 10 章）
   */
  @StorageLink(MySetConstants.SET_PRE_DOWNLOAD) select: number = 10
  
  /** @StorageLink(MySetConstants.SET_LANGUAGE) selectLanguage: string = '跟随系统'
   * 应用语言设置（默认跟随系统）
   */
  @StorageLink(MySetConstants.SET_LANGUAGE) selectLanguage: string = '跟随系统'

  // ============ 临时状态变量 ============
  
  /** private tempNum: number = 10
   * 预下载选择的临时数值（弹窗中使用）
   */
  private tempNum: number = 10
  
  /** private preDow: string = '预先下载'+this.select+'章正文'
   * 预下载显示的文本（动态更新）
   */
  private preDow: string = '预先下载'+this.select+'章正文'
  
  /** private fruits: string[] = getRandomStringArray()
   * 预下载数字列表（1-100）
   */
  private fruits: string[] = getRandomStringArray()

  // ============ 语言列表 ============
  
  /** @State languageList: string[] - 可选语言列表
   */
  @State languageList: string[] = ['跟随系统','简体中文','繁体中文','英文']

  // ============ 安全区域适配 ============
  
  /** @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
   * 底部安全区域高度
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** @StorageLink('topRectHeight') topRectHeight: number = 0
   * 顶部安全区域高度
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0


  // ========== 书架设置组 ============
  /**
   * bookSetList - 书架相关设置列表
   * 每项数据结构：[是否展开，标题，开关状态，副标题，说明，存储键]
   */
  @State bookSetList: SetList[]=[
    new SetList(false,'自动刷新',this.setRefresh,'','打开软件时自动更新书籍书籍',MySetConstants.SET_REFRESH),
    new SetList(false,'自动跳转最近阅读',this.setJump,'','关闭将以底部弹窗形式提示',MySetConstants.SET_JUMP),
    new SetList(false,'默认启用替换净化',this.setReplace,'','新加入书架的书是否启用替换净化',MySetConstants.SET_REPLACE),
    new SetList(false,'返回时提示放入书架',this.setTip,'','',MySetConstants.SET_TIP)
  ]

  // ========== 缓存下载设置组 ============
  /**
   * cacheSetList - 缓存下载相关设置列表
   * 每项数据结构：[是否展开，标题，值/开关，副标题，说明，存储键]
   */
  @State cacheSetList: SetList[]=[
    new SetList(true,'书籍保存位置',true,'','打开软件时自动更新书籍书籍',MySetConstants.SET_BOOK_SAVE),
    new SetList(true,'预下载',true,this.preDow,'',MySetConstants.SET_PRE_DOWNLOAD),
    new SetList(true,'图片缓存',true,'当前最大缓存 50MB','',MySetConstants.SET_IMG_CACHE),
    new SetList(false,'图片抗锯齿',this.setImgAnti,'','',MySetConstants.SET_IMG_ANTI)
  ]

  // ========== 网络设置组 ============
  /**
   * netWorkSetList - 网络相关设置列表
   */
  @State netWorkSetList: SetList[]=[
    new SetList(false,'Webservice 唤醒锁',this.setAwaken,'','如遇杀后台可开启',MySetConstants.SET_AWAKEN),
    new SetList(true,'Web 端口',true,'','当前端口 1122',MySetConstants.SET_WEB_PORT),
    new SetList(true,'清除 webview 数据',true,'','清除内置浏览器所有数据',MySetConstants.SET_CLEAR_WEB),
    new SetList(true,'用户代理',true,'','',MySetConstants.SET_USER_AGENT)
  ]

  // ========== 其他设置组 ============
  /**
   * otherSetList - 其他功能设置列表
   */
  @State otherSetList: SetList[]=[
    new SetList(false,'全程响应耳机按键',this.setHead,'','即使退出也响应耳机按键',MySetConstants.SET_HEAD),
    new SetList(false,'文字操作显示搜索',this.setSearch,'','长按文字在操作菜单中显示阅读搜索',MySetConstants.SET_SEARCH),
    new SetList(true,'语言',true,'跟随系统','',MySetConstants.SET_LANGUAGE),
  ]

  // ========== 分组列表 ============
  /**
   * setGroupList - 设置分组列表
   * 将各设置组打包成分组对象，用于 List 渲染
   */
  @State setGroupList: SetGroupList[] = [
    new SetGroupList('书架',this.bookSetList),
    new SetGroupList('缓存下载',this.cacheSetList),
    new SetGroupList('网络',this.netWorkSetList),
    new SetGroupList('其他',this.otherSetList)
  ]

  // ============ 构建器：分组头部 ============
  
  /**
   * @Builder itemHead - 设置分组头部构建器
   * 
   * @param text - 分组名称（书架/缓存下载/网络/其他）
   * 
   * @returns Text 组件，灰色小字，浅灰背景
   */
  @Builder itemHead(text: string) {
    // 分组设置头部组件
    Text(text)
      .fontSize(12) // 小字号
      .fontColor('#8C8C8C') // 深灰色文本
      .backgroundColor('#F5F5F5') // 浅灰背景
      .width('100%') // 占满宽度
      .padding({left:40,right:40,top:16,bottom:8}) // 左右大内边距营造缩进效果
  }


  // ============ UI 构建方法 - build() ============
  
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column (浅灰背景容器)
   * ├─ SetHead (设置页头部：我的设置)
   * └─ List (可滚动列表)
   *    ├─ ListItemGroup(书架分组)
   *    │  ├─ 分组头部（itemHead 构建）
   *    │  └─ ForEach(bookSetList) -> SetListView
   *    ├─ ListItemGroup(缓存下载分组)
   *    ├─ ListItemGroup(网络分组)
   *    └─ ListItemGroup(其他分组)
   * 
   * 绑定两个半模态框：
   *   - isShowLanguage -> languageSheet（语言选择）
   *   - isShowPreDon -> preDowSheet（预下载数量选择）
   */
  build() {
    Column(){
      // ========== 设置页头部 ==========
      SetHead({titleName:'我的设置'}).height(48).padding({left:20})

      // ========== 设置列表 ==========
      List(){

        ForEach(this.setGroupList,(group:SetGroupList)=>{
          // ========== 分组容器 ==========
          ListItemGroup({header:this.itemHead(group.groupValue)}){

            if(group.setList){
              ForEach(group.setList,(item:SetList)=>{
                ListItem(){//设置内容，首尾裁剪
                
                  // 处理首尾圆角：首项上圆角，末项下圆角
                  if (group.setList.indexOf(item) == 0){
                    SetListView({setList:item,topLeft:20,topRight:20})
                      .onClick(()=>{this.itemOnclick(item.storageName)})

                  }else if (group.setList.indexOf(item) == group.setList.length - 1){
                    SetListView({setList:item,bottomLeft:20,bottomRight:20})
                      .onClick(()=>{this.itemOnclick(item.storageName)})
                  }else {
                    SetListView({setList:item}) // 中间项无圆角
                      .onClick(()=>{this.itemOnclick(item.storageName)})
                  }
                }.padding({left:20,right:20}) // 左右内边距 20
              })
            }

          }
        })

      }.width('100%') // 占满宽度
      .height('100%') // 占满高度
      .layoutWeight(1) // 占据剩余空间
      .scrollBar(BarState.Off) // 隐藏滚动条
    }
    .padding({
      top:this.topRectHeight, // 顶部安全区域
      bottom: this.bottomRectHeight, // 底部安全区域
    })
    .backgroundColor('#F5F5F5') // 浅灰背景
      
    // ========== 绑定半模态框：语言选择 ==========
    .bindSheet($$this.isShowLanguage, this.languageSheet(), {
      height: 288,
      dragBar: false, // 不显示拖拽条
      showClose: false, // 不显示关闭按钮
    })
    
    // ========== 绑定半模态框：预下载数量 ==========
    // 通过选定的半模态接口，绑定模态展示界面，style 中包含两个参数，一个是设置半模态的高度，不设置时默认高度是 Large，一个是是否显示控制条 DragBar，默认是 true 显示控制条
    .bindSheet($$this.isShowPreDon, this.preDowSheet(), {
      height: 288,
      dragBar: false,
      showClose: false,
    })


  }



  // ========== 构建器：预下载数量选择器 ==========
  
  /**
   * @Builder preDowSheet - 预下载半模态展示界面
   * 
   * 布局层次：
   * Column
   * ├─ Row (标题栏：取消 + 预下载 + 确定)
   * └─ Column (Picker 选择器)
   *    └─ TextPicker(数字列表 1-100)
   * 
   * 功能：选择预下载的章节数量（1-100）
   */
  @Builder preDowSheet() {
    Column() {
      // 标题栏
      Row(){
        // 取消按钮
        Text('取消')
          .fontSize(14)
          .padding({left:20})
          .onClick(()=>{this.isShowPreDon = false}) // 关闭弹窗

        // 标题文本
        Text('预下载')
          .fontSize(16)

        // 确定按钮
        Text('确定')
          .fontSize(14)
          .padding({right:20})
          .onClick(()=>{
            this.isShowPreDon = false // 关闭弹窗
            this.select = this.tempNum // 更新选中值
            this.preDow = '预先下载'+this.select+'章正文' // 更新显示文本
            this.cacheSetList[1].rightText = this.preDow // 同步到列表项
          })
      }.width('100%').height(56).justifyContent(FlexAlign.SpaceBetween) // 两端对齐
      
      // Picker 选择器
      Column() {
        TextPicker({ range: this.fruits, selected: this.select }) // 范围：1-100，默认选中值
          .onChange((value: string | string[], index: number | number[]) => {
            if (typeof index === "number") {
              this.tempNum = index // 更新临时值
            }
          })
          .disappearTextStyle({color: Color.Black, font: {size: 14, weight: FontWeight.Normal}}) // 未选中样式
          .textStyle({color: Color.Black, font: {size: 14, weight: FontWeight.Normal}}) // 普通样式
          .selectedTextStyle({color: Color.Red, font: {size: 16, weight: FontWeight.Bolder}}) // 选中样式（红色粗体）
      }.width('100%').height('100%')
    }
    .width('100%') // 占满宽度
    .height(288) // 固定高度
    .backgroundColor(Color.White) // 白色背景
  }

  // ========== 构建器：语言选择器 ==========
  
  /**
   * @Builder languageSheet - 语言选择半模态展示界面
   * 
   * 布局层次：
   * Column
   * ├─ Text("语言") 标题
   * └─ ForEach(languageList) -> Text(选项)
   * 
   * 功能：选择应用显示语言
   */
  @Builder languageSheet() {
    Column() {
      Text('预下载') // TODO: 应该改为"语言"
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .width('100%').height(56)
      
      ForEach(this.languageList,(value:string)=>{
        Text(value)
          .fontSize(16)
          .textAlign(TextAlign.Start)
          .width('100%').height(56) // 每个选项固定高度 56
      })

    }
    .width('100%')
    .height(288)
    .backgroundColor(Color.White)
  }

  // ============ 事件处理方法 ============
  
  /**
   * itemOnclick - 设置列表项点击事件
   * 
   * @param value - 设置项的 storageName（存储键）
   * 
   * 功能分支：
   *   case SET_REFRESH: 自动刷新开关（翻转）
   *   case SET_JUMP: 自动跳转最近阅读开关（翻转）
   *   case SET_REPLACE: 替换净化开关（翻转）
   *   case SET_TIP: 返回提示开关（翻转）
   *   case SET_IMG_ANTI: 图片抗锯齿开关（翻转）
   *   case SET_AWAKEN: Webservice 唤醒锁开关（翻转）
   *   case SET_HEAD: 耳机按键开关（翻转）
   *   case SET_SEARCH: 文字操作搜索开关（翻转）
   *   case SET_BOOK_SAVE: 书籍保存位置（待实现）
   *   case SET_PRE_DOWNLOAD: 预下载数量 -> 显示选择器
   *   case SET_IMG_CACHE: 图片缓存（待实现）
   *   case SET_WEB_PORT: Web 端口（待实现）
   *   case SET_CLEAR_WEB: 清除 webview 数据（待实现）
   *   case SET_USER_AGENT: 用户代理（待实现）
   *   case SET_LANGUAGE: 语言选择 -> 显示选择器
   */
  itemOnclick(value:string){
    switch (value){
      case MySetConstants.SET_REFRESH:
        this.setRefresh = !this.setRefresh // 翻转状态
        this.bookSetList[0].toggleStatus = this.setRefresh; // 同步到列表项
        break;
      case MySetConstants.SET_JUMP:
        this.setJump = !this.setJump
        this.bookSetList[1].toggleStatus = this.setJump;
        break;
      case MySetConstants.SET_REPLACE:
        this.setReplace = !this.setReplace
        this.bookSetList[2].toggleStatus = this.setReplace;
        break;
      case MySetConstants.SET_TIP:
        this.setTip = !this.setTip
        this.bookSetList[3].toggleStatus = this.setTip;
        break;
      case MySetConstants.SET_IMG_ANTI:
        this.setImgAnti = !this.setImgAnti
        this.cacheSetList[3].toggleStatus = this.setImgAnti;
        break;
      case MySetConstants.SET_AWAKEN:
        this.setAwaken = !this.setAwaken
        this.netWorkSetList[0].toggleStatus = this.setAwaken;
        break;
      case MySetConstants.SET_HEAD:
        this.setHead = !this.setHead
        this.otherSetList[0].toggleStatus = this.setHead;
        break;
      case MySetConstants.SET_SEARCH:
        this.setSearch = !this.setSearch
        this.otherSetList[1].toggleStatus = this.setSearch;
        break;
      case MySetConstants.SET_BOOK_SAVE:
        // TODO: 书籍保存位置选择（文件夹选择）
        break;
      case MySetConstants.SET_PRE_DOWNLOAD:
        this.isShowPreDon = !this.isShowPreDon; // 显示预下载选择器
        break;
      case MySetConstants.SET_IMG_CACHE:
        // TODO: 图片缓存管理
        break;
      case MySetConstants.SET_WEB_PORT:
        // TODO: Web 端口配置
        break;
      case MySetConstants.SET_CLEAR_WEB:
        // TODO: 清除 webview 数据
        break;
      case MySetConstants.SET_USER_AGENT:
        // TODO: 用户代理设置
        break;
      case MySetConstants.SET_LANGUAGE:
        this.isShowLanguage = !this.isShowLanguage; // 显示语言选择器
        break;
    }
  }
}

// ============ 辅助函数：生成数字列表 ============

/**
 * getRandomStringArray - 生成 1-100 的数字字符串数组
 * 
 * @returns string[] - 包含 100 个数字字符串的数组
 */
function getRandomStringArray():string[]{
  let list: string[] = []
  for (let i = 0; i < 100; i++) {
    list.push(i.toString()) // 注意：这里实际是 0-99，可能需要调整为 1-100
  }
  return list;
}

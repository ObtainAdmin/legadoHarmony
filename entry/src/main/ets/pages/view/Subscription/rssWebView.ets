/**
 * =====================================================
 * rssWebView.ets - RSS订阅源网页浏览页面
 * 
 * 功能说明：
 * 1. 在应用内WebView中加载RSS订阅源/书籍搜索页面
 * 2. 自动识别页面中的书源/订阅源链接并导入
 * 3. 支持收藏/取消收藏订阅源
 * 4. 提供搜索、分页、前进后退等浏览器基础功能
 * =====================================================
 */

import { webview } from '@kit.ArkWeb';           // 鸿蒙WebView组件，用于内嵌网页
import { router } from '@kit.ArkUI';              // 路由导航，用于页面跳转
import { showMessage } from '../../../componets/common/promptShow';  // 提示消息组件
import ImportCommon from '../../../componets/import/ImportCommon';    // 书源导入通用组件
import { BookSource } from '../../../database/entities/BookSource';    // 书源实体类
import { isNetworkUrl, sleep } from '../../../common/utils/utils';    // 工具函数：URL校验、sleep延迟
import axios, { AxiosResponse } from '@ohos/axios';  // HTTP请求库
import SubscriptionImport from '../../../componets/import/SubscriptionImport';  // RSS订阅导入组件
import { rssSources, SUBSCRIPTION_GROUP_TYPE, WEB_USER_AGENT } from '../../../database/entities/rssSources';  // RSS订阅实体类
import CommonConstants from '../../../common/constants/CommonConstants';  // 通用常量
import PaddingConstants from '../../../common/constants/PaddingConstants';  // 内边距常量
import SubscriptionDao from '../../../database/dao/SubscriptionDao';        // 订阅源DAO
import subscriptionDao from '../../../database/dao/SubscriptionDao';        // 订阅源DAO实例
import WebSetup from './components/WebSetup';          // 网页底部设置弹窗组件
import FontConstants from '../../../common/constants/FontConstants';        // 字体样式常量
import { pasteboard } from '@kit.BasicServicesKit';    // 系统剪贴板
import { common } from '@kit.AbilityKit';              // 通用Ability上下文
import systemUtil from '../../../common/utils/SystemUtils'; // 系统工具（如外部浏览器打开）

/**
 * 路由参数接口
 * 从其他页面跳转到此页面时传递的参数
 * 
 * @property url - 要加载的网页URL（必传）
 * @property id - 订阅源ID（可选，用于删除操作时定位具体的订阅源）
 */
interface RouteParams {
  url: string, //id不传默认用url校验是否存在订阅源有存
  id:number //id是订阅源页面跳转用来传递的用于删除的其它页面可不传
}


/**
 * 收藏弹窗
 */
@CustomDialog
struct addCollectionDialog {
  controller?: CustomDialogController;
  isCollection:boolean = false
  build() {
    Row() {
      Image($r('app.media.ic_public_confirm'))
        .width(24)
        .height(24)
        .fillColor('#FFFFFF')
      Text(this.isCollection?'收藏成功':'取消收藏')
        .fontSize(14)
        .fontWeight(400)
        .lineHeight(22)
        .fontColor('#FFFFFF')
      Blank()
      Text('移入分组')
        .fontSize(14)
        .fontWeight(400)
        .lineHeight(22)
        .fontColor('#FF9500')
        .visibility(this.isCollection?Visibility.Visible:Visibility.None)
    }
    .height(56)
    .width(CommonConstants.FULL_WIDTH)
    .padding({
      left: 20,
      right: 20,
      top: 16,
      bottom: 16
    })
    .backgroundColor('#333333')
  }
}

@Entry
@Component
@Preview
/**
 * RssWebView 主组件 - RSS/书源网页浏览页面
 * 
 * 主要功能：
 * - 在WebView中加载RSS订阅源网页
 * - 监听网页内容，自动检测并导入书源/订阅源
 * - 支持收藏当前页面为订阅源
 * - 底部工具栏提供前进、后退、刷新、设置等操作
 */
struct RssWebView {
  // ==================== 页面参数 ====================
  @State sourcesUrl:string = ''  // 要加载的网页URL
  @State sourcesId:number = 0    // 订阅源ID（用于更新/删除操作）
  
  // ==================== 系统存储属性 ====================
  // 顶部/底部安全区域高度（适配异形屏）
  @StorageLink('topRectHeight') topRectHeight: number = 0
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  // WebView控制器，用于控制网页加载、导航等
  controller: webview.WebviewController = new webview.WebviewController();
  
  // ==================== URL正则匹配规则 ====================
  // 用于从网页中提取书源链接的正则表达式
  // 匹配模式: /booksource/importonline?src=实际URL
  regex:string = `/booksource/importonline\\?src=(http[s]?://[^/]+/[^\"']+)`;
  
  // 用于从网页中提取RSS订阅源链接的正则表达式
  regexRss:string = `/rsssource/importonline\\?src=(http[s]?://[^/]+/[^\"']+)`;
  
  // Le书架通用的自动导入正则表达式
  legadoRegex:string = `/import/auto\\?src=(http[s]?://[^/]+/[^\"']+)`
  // ==================== 状态变量 ====================
  // 当前页面是否已被收藏（收藏到订阅源中）
  @State isCollection:boolean = false
  
  // RSS订阅源刷新状态（联动CommonConstants.RSS_SOURCES_REFRESHING）
  @StorageLink(CommonConstants.RSS_SOURCES_REFRESHING) refreshing: number = 0
  
  // 系统User-Agent配置变化监听，当变化时更新WebView的UA
  @StorageLink(CommonConstants.SYSTEM_UA) @Watch('upUserUA')SYSTEM_UA: number = 0

  /**
   * 生命周期：组件即将显示
   * 
   * 执行流程：
   * 1. 从路由参数中获取URL和ID
   * 2. 检查该URL是否已被收藏（用于显示收藏状态）
   * 3. 更新User-Agent配置
   */
  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as RouteParams;
    this.sourcesUrl = params.url
    this.sourcesId = params.id??0
    this.isCollection = await subscriptionDao.queryByUrl(this.sourcesUrl) //是否收藏
    this.controller.setCustomUserAgent(WEB_USER_AGENT[this.SYSTEM_UA])
  }

  /**
   * 更新User-Agent
   * 当系统UA设置变化时自动调用，更新WebView的User-Agent头
   */
  upUserUA(){
    this.controller.setCustomUserAgent(WEB_USER_AGENT[this.SYSTEM_UA])
  }

  /**
   * 系统返回键按下时的回调
   * 优先尝试后退网页，如果不能后退则由系统处理返回
   */
  onBackPress(){
    this.webOnBackPress()
    return true
  }

  /**
   * 网页后退处理
   * 1. 检查是否可以后退（网页有历史记录）
   * 2. 如果可以后退则执行后退
   * 3. 否则不执行任何操作
   */
  //是否后退网页
  webOnBackPress(){
    let canGoForward = this.controller.accessForward()//是否可前进
    let canGoBackward =this.controller.accessBackward() //是否可以后退
    if (canGoBackward) {
      this.controller.backward() // 后退一个页面
    }
    if (!canGoBackward) {
      router.back()
      setTimeout(() => {
        this.refreshing++
      }, 200)
    }
  }


  @State webTitle:string = ''
  @State formModel: rssSources = {
    sourceName: '',
    sourceUrl: '',
    sourceIcon: '',
    sourceType: 0,
    sourceIconIsUrl: false,
    enabledCookieJar: false,
    lastUpdateTime: new Date().getTime(),
    customOrder: 0,
    autoComplete: false,
    sourceGroup: SUBSCRIPTION_GROUP_TYPE[4],
    enabled: true,
    singleUrl: true,
    showRecentIcon: true,
    customizeTitle: ''
  }

  build() {
    Column(){
      Column(){
        Web({ src: this.sourcesUrl||'www.baidu.com', controller: this.controller })
          .onPageBegin((event) => {
            //设置setCustomUserAgent为手机

          })
          .layoutWeight(1)
          .onPageEnd((event) => {
            // this.controller.setCustomUserAgent(WEB_USER_AGENT[this.SYSTEM_UA])
            this.getOnclickUrl(event?.url || '')
            this.formModel.sourceUrl = event.url ?? ''
            this.formModel.sourceName = this.controller.getTitle().slice(0, 19)
            this.webTitle = this.controller.getTitle()
          })
          // .onScroll((event) => {
          //   showMessage("x = " + event.xOffset)
          //   showMessage("y = " + event.yOffset)
          //   console.info("x = " + event.xOffset);
          //   console.info("y = " + event.yOffset);
          // })
        this.webFooter()
      }
      Flex()
        .bindSheet($$this.isShowImportBookSource, this.dialogImportBookFunction(), {
          detents: [SheetSize.FIT_CONTENT, SheetSize.LARGE, 200],
          dragBar: true,
          showClose: false,
          onDisappear: () => {
            this.isShowImportBookSource = false
          }
        })

      Flex()
        .bindSheet($$this.isShowImportRssSources, this.dialogImportRssFunction(), {
          detents: [SheetSize.FIT_CONTENT, SheetSize.LARGE, 200],
          dragBar: true,
          showClose: false,
          onDisappear: () => {
            this.isShowImportRssSources = false
          }
        })
    }
    .padding({ top: this.topRectHeight, bottom: this.bottomRectHeight})
  }

  /**
   * webFooter - 底部工具栏构建器
   * 
   * 包含以下功能区域：
   * 1. 返回按钮：返回上一页并触发刷新
   * 2. 搜索栏：显示当前页面标题，支持手动输入书名进行搜索
   * 3. 收藏按钮：收藏/取消收藏当前页面为订阅源
   * 4. 更多设置：打开网页设置弹窗（刷新率、JavaScript开关等）
   */
  @Builder
  webFooter() {
    Row({
      space:PaddingConstants.PADDING_16
    }) {
      // 返回按钮 - 点击后返回上一页并触发订阅源刷新
      Image($r('app.media.return_left'))
        .width(25)
        .height(25)
        .onClick(()=>{
          router.back()
          setTimeout(() => {
            this.refreshing++
          }, 10)
        })
      // 搜索区域 - 显示当前页面标题，可输入书名跳转搜索
      Row(){
        Row({
          space:PaddingConstants.PADDING_12
        }){
          TextInput({text:this.webTitle??''})
            .height(30)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow(TextOverflow.Ellipsis)
            .fontSize(14)
            .fontWeight(FontConstants.FONT_WEIGHT_500)
            .fontFamily(CommonConstants.FAMILY_PingFANG)
            .onChange((val)=>{
              this.webTitle = val
            })
            .onBlur(() => {
              this.webTitle = this.controller.getTitle()
            })
          Row(){
            Text('搜书')
              .font({
                size:12,
                weight:400,
                family: CommonConstants.FAMILY_PingFANG
              })
              .fontColor(Color.White)
              .padding({
                left:PaddingConstants.PADDING_12,
                right:PaddingConstants.PADDING_12
              })
              .textAlign(TextAlign.Center)
              .onClick(()=>{
                router.pushUrl({
                  url: 'pages/view/search/SearchBook',
                  params:{
                    searchValue:this.webTitle
                  }
                });
              })
          }
          .padding(5)
          .backgroundColor($r('app.string.color_black_88'))
          .borderRadius(4)
        }
        .padding(5)
      }
      .layoutWeight(1)
      .border({
        width:2,
        color:$r('app.string.color_black_88')
      })
      .borderRadius(8)

      Image(this.isCollection?$r('app.media.icon_collect_selected'):$r('app.media.icon_collect_unselected'))
        .width(24)
        .height(24)
        .onClick(async ()=>{
          if (this.isCollection) {
            subscriptionDao.deleteRssSourcesById({
              id:this.sourcesId,
              url:this.sourcesUrl
            })
            this.isCollection = false
          } else {
            SubscriptionDao.insert(this.formModel)
            this.isCollection = true
          }
          this.addCollection()
          // showMessage(this.isCollection?'收藏成功':'取消收藏')
        })

      Image($r('app.media.icon_browser_more'))
        .width(24)
        .height(24)
        .onClick(()=>{
         this.webSetupDialog?.open()
        })
    }
    .padding({left:20,right:20,top:14})
  }

  addCollection() {
    this.addCollectionController.open();
    // 1s后关闭dialog
    setTimeout(() => {
      this.addCollectionController.close();
    }, 1000);
  }

  addCollectionController: CustomDialogController = new CustomDialogController({
    builder: addCollectionDialog({
      isCollection:this.isCollection
    }),
    backgroundColor: Color.Transparent,
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -100 },
    gridCount: 4,
    customStyle: false,
    cornerRadius: 8
  })

  webSetupDialog: CustomDialogController | null = new CustomDialogController({
    builder: WebSetup({
      refreshing:()=>{
        this.controller.refresh()
      },
      copyUrl:()=>{
       this.copyText(this.controller.getUrl())
      },
      startBrowsable:()=>{
        const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
        systemUtil.startBrowsableAbility(context,this.controller.getUrl())
      }
    }),
    cancel: this.exitDialog,
    autoCancel: true,
    width:'100%',
    alignment: DialogAlignment.Bottom,
    customStyle:true
  })
  //网站链接复制到剪切板
  copyText(text: string) {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪切板
    systemPasteboard.getData().then((data) => {
      if (data) {
        showMessage('链接已经复制在剪切板中.')
      } else {
        showMessage('复制失败')
      }
    })
  }


  //退出弹框 - 关闭设置对话框
  exitDialog(){
    this.webSetupDialog?.close()
  }

  // ==================== 书源导入相关 ====================
  // 书源导入弹窗显示状态
  @State isShowImportBookSource: boolean = false
  @State sourceList: BookSource[] = []
  @Builder
  dialogImportBookFunction() {
    Flex() {
      ImportCommon({ sourceList: this.sourceList, show: this.isShowImportBookSource })
    }
  }
  @State subscriptionList:rssSources[] = []
  @State isShowImportRssSources:boolean = false
  @Builder dialogImportRssFunction() {
    Flex() {
      SubscriptionImport({ subscriptionList:this.subscriptionList,show: this.isShowImportRssSources})
    }
  }

  /**
   * getOnclickUrl - URL点击事件处理/自动检测导入
   * 
   * 核心功能：在网页加载或用户点击时，检测URL是否符合导入规则
   * 
   * 支持的三种导入模式：
   * 1. 书源导入：检测 /booksource/importonline?src= 格式的URL
   * 2. RSS订阅源导入：检测 /rsssource/importonline?src= 格式的URL  
   * 3. Le书架通用导入：检测 /import/auto?src= 格式的URL
   * 
   * @param postUrl 待检测的URL字符串
   * @returns 如果检测到导入链接返回false，否则返回true（允许继续跳转）
   */
  getOnclickUrl(postUrl:string) {
    let url = decodeURIComponent(postUrl);
    //如果url存在匹配返回false
    // if (url.match(this.regex) || url.match(this.regexRss) || url.match(this.legadoRegex)) {
    //   return false
    // }
    const match = url.match(this.regex);
    if (match  && match[1]) {
      let urlBook = decodeURIComponent(match[1]);
      this.pasteAnalyzeBookSource(urlBook)
      this.controller.backward()
      this.controller.scrollTo(0, 0)
      return false
    }
    const matchRss = url.match(this.regexRss);
    if (matchRss  && matchRss[1]) {
      let urlRss = decodeURIComponent(matchRss[1]);
      this.pasteAnalyzeRssSource(urlRss)
      this.controller.backward()
      return false
    }
    const legadoMatch = url.match(this.legadoRegex);
    if (legadoMatch  && legadoMatch[1]) {
      let urlLegado= decodeURIComponent(legadoMatch[1]);
      showMessage(urlLegado) //todo 替换规则导入
      this.controller.backward()
      return false
    }
    return true
  }

  /**
   * pasteAnalyzeBookSource - 书源分析导入
   * 
   * 功能：获取URL指向的书源JSON数据并显示导入弹窗
   * 
   * 处理流程：
   * 1. 参数校验，如果URL为空则使用默认书源地址
   * 2. 验证URL格式是否正确（必须为网络URL）
   * 3. 发起HTTP GET请求获取书源JSON数据
   * 4. 解析响应数据，填充sourceList并显示导入弹窗
   * 5. 异常处理：显示错误提示信息
   * 
   * @param url 书源JSON文件的网络地址
   */
  // 发现 - 书源解析导入
  async pasteAnalyzeBookSource(url:string) {
    try {
      if (!url) {
        showMessage('未获取到相关Url，请求默认数据')
        url = 'https://node.wisdoms.xin/static/file/20240704/sy.json'
        await sleep()
      }
      if (!isNetworkUrl(url ?? '')) {
        showMessage('链接不正确')
        return
      }
      const res: AxiosResponse = await axios.get(url ?? 'https://node.wisdoms.xin/static/file/20240704/sy.json');
      if (res) {
        console.log('res', JSON.stringify(res))
        this.sourceList = res.data;
        this.isShowImportBookSource = true;
      } else {
        showMessage('订阅源解析失败')
      }
    } catch (err) {
      showMessage('订阅源解析失败')
      console.error('错误 ' + err);
    }
  }

  /**
   * pasteAnalyzeRssSource - RSS订阅源分析导入
   * 
   * 功能：获取URL指向的RSS订阅源JSON数据并显示导入弹窗
   * 
   * 处理流程：
   * 1. 参数校验，如果URL为空则使用默认订阅源地址
   * 2. 验证URL格式是否正确（必须为网络URL）
   * 3. 发起HTTP GET请求获取订阅源JSON数据
   * 4. 解析响应数据，填充subscriptionList并显示导入弹窗
   * 5. 异常处理：显示错误提示信息
   * 
   * @param url RSS订阅源JSON文件的网络地址
   */
  // 订阅 - RSS订阅源解析导入
  async pasteAnalyzeRssSource(url:string) {
    try {
      if (!url) {
        showMessage('未获取到相关Url，请求默认数据')
        url = 'http://yuedu.miaogongzi.net/shuyuan/miaogongziDY.json'
        await sleep()
      }
      if (!isNetworkUrl(url ?? '')) {
        showMessage('链接不正确')
        return
      }
      const res: AxiosResponse = await axios.get(url ?? 'http://yuedu.miaogongzi.net/shuyuan/miaogongziDY.json');
      if (res) {
        console.log('res', JSON.stringify(res))
        this.subscriptionList = res.data;
        this.isShowImportRssSources = true;
      } else {
        showMessage('订阅源解析失败')
      }

    } catch (err) {
      showMessage('订阅源解析失败')
      console.error('错误 ' + err);
    }
  }
}
/**
 * @file newSources.ets
 * @description 新建/编辑RSS订阅源页面组件
 * 
 * 功能说明：
 * 1. 提供创建新的RSS订阅源或编辑现有订阅源的界面
 * 2. 支持三栏Tab切换：基本信息、列表规则、WebView规则
 * 3. 提供源调试功能
 * 4. 支持CookieJar、图标选择、分组管理等高级功能
 * 
 * @author 2008
 * @datetime 2024/7/16 18:13
 * @className: newSources
 */

// ==================== 常量导入 ====================
// 通用常量定义
import CommonConstants from '../../../../common/constants/CommonConstants'
// 字体大小和样式常量
import FontConstants from '../../../../common/constants/FontConstants'
// 图片尺寸常量
import ImageConstants from '../../../../common/constants/ImageConstants'
// 间距和边距常量
import PaddingConstants from '../../../../common/constants/PaddingConstants'
// 文本相关常量
import TextConstants from '../../../../common/constants/TextConstants'

// ==================== 主题相关导入 ====================
// 主题存储键值常量
import { ThemeStorageKey } from '../../../../common/constants/Theme'
// 主题数据模型
import { ThemeItem } from '../../../../common/model/Theme'

// ==================== 工具函数导入 ====================
// URL验证工具函数，用于判断字符串是否为网络URL
import { isNetworkUrl } from '../../../../common/utils/utils'

// ==================== 公共组件导入 ====================
// 通用按钮组件，用于底部取消/确认按钮
import buttonCommon from '../../../../componets/common/buttonCommon'
// 对话框标题组件，用于右侧菜单
import dialogTitleFuction from '../../../../componets/common/dialogTitleFuction'
// 消息提示组件，用于显示操作反馈
import { showMessage } from '../../../../componets/common/promptShow'

// ==================== 业务组件导入 ====================
// 帮助对话框组件
import Help from '../../../../componets/dialog/help'
// 表单输入项组件，封装了标签+输入框的组合
import FormItem from '../../../../componets/Form/FormItem'

// ==================== 数据访问层(DAO)导入 ====================
// RSS订阅源分组数据访问对象
import rssSourceGroupDao from '../../../../database/dao/rssSourceGroupDao'
// 订阅数据访问对象，用于保存订阅源
import SubscriptionDao from '../../../../database/dao/SubscriptionDao'

// ==================== 数据实体导入 ====================
// RSS订阅源实体类和分组类型常量
import { rssSources, SUBSCRIPTION_GROUP_TYPE } from '../../../../database/entities/rssSources'
// RSS列表规则实体类
import { rssListRule } from '../../../../database/entities/rule/rssListRule'
// RSS WebView规则实体类
import { rssWebViewRule } from '../../../../database/entities/rule/rssWebViewRule'

// ==================== 偏好设置导入 ====================
// 程序数据偏好设置
import programDataPreferences from '../../../../preferences/programDataPreferences'

// ==================== 子组件导入 ====================
// 源调试组件（待实现：需要写一个订阅源页面）
import SourceDebug from '../../Find/BookSource/components/SourceDebug'
// 图标预览效果组件
import PreviewEffectImage from '../components/PreviewEffectImage'
// RSS订阅源图标选择组件
import RssSourceCheckImage from '../components/RssSourceCheckImage'
// RSS订阅源帮助内容组件
import rssSourcesHelp from '../components/rssSourcesHelp'

// ==================== 组件定义 ====================

/**
 * @Component newSources
 * @description 新建/编辑RSS订阅源页面组件
 * 
 * 核心功能：
 * - 表单数据绑定：通过 @Prop formModel 与父组件双向绑定
 * - Tab切换：支持基本信息/列表规则/WebView规则三栏切换
 * - 调试模式：切换到调试页面进行源测试
 * - 图标选择：支持网络链接或预设图标
 * - 分组管理：从数据库加载分组列表
 */
@Component
export default struct newSources {
  // ==================== 状态变量 ====================
  
  /**
   * @state isShowHelp
   * @type boolean
   * @default false
   * @description 控制帮助对话框的显示/隐藏状态
   */
  @State isShowHelp: boolean = false
  
  /**
   * @state isShowMenu
   * @type boolean
   * @default false
   * @description 控制右上角更多菜单弹窗的显示/隐藏状态
   */
  @State isShowMenu: boolean = false
  
  /**
   * @prop hideNewSources
   * @type Function
   * @description 父组件传入的回调函数，用于关闭当前页面/对话框
   */
  hideNewSources: Function = () => {}
  
  /**
   * @state currentIndex
   * @type number
   * @default 0
   * @description 内层Tabs（基本/列表/WEB VIEW）的当前选中索引
   */
  @State currentIndex: number = 0
  
  /**
   * @prop isEdit
   * @type boolean
   * @default false
   * @description 标识当前是编辑模式(true)还是新建模式(false)，影响页面标题
   */
  @Prop isEdit: boolean = false
  
  /**
   * @private controller
   * @type TabsController
   * @description 内层Tabs控制器，用于程序控制Tab切换（基本/列表/WEB VIEW）
   */
  private controller: TabsController = new TabsController()
  
  /**
   * @private headController
   * @type TabsController
   * @description 外层Tabs控制器，用于切换"订阅源编辑"和"调试源"页面
   */
  private headController: TabsController = new TabsController()
  
  /**
   * @state readIndex
   * @type number
   * @default 0
   * @description 外层Tabs的当前选中索引：0=订阅源编辑，1=调试源
   */
  @State readIndex: number = 0

  /**
   * @build
   * @description 主构建方法，定义页面整体布局结构
   * 
   * 布局结构：
   * 1. 外层Column - 整体垂直布局容器
   * 2. 内层Column - 内容区域（占满剩余空间）
   * 3. 标题栏Flex - 包含返回按钮、标题、操作按钮
   * 4. 双层Tabs - 外层切换编辑/调试，内层切换基本/列表/WEBVIEW
   * 5. Divider - 分隔线
   * 6. 底部按钮 - 取消/确认操作
   * 7. bindSheet - 预设图标选择面板
   * 8. bindSheet - 帮助对话框面板
   */
  build() {
    Column() {
      // 内容区域容器
      Column() {
        // 标题栏：左右分布的弹性布局
        Flex({
          justifyContent: FlexAlign.SpaceBetween,
          alignItems: ItemAlign.Center
        }) {
          // 当处于调试页面(readIndex=1)时显示返回按钮
          if (this.readIndex === 1) {
            Image($r('app.media.return_left'))
              .width(25)
              .height(25)
              .onClick(() => {
                // 点击返回按钮，切换回订阅源编辑页面
                this.headController.changeIndex(0)
              })
          }
          
          /**
           * 页面标题：
           * - 编辑模式且readIndex=0：显示"编辑订阅源"
           * - 新建模式且readIndex=0：显示"新建订阅源"
           * - readIndex=1：显示"调试源"
           */
          Text(this.readIndex === 0 ? `${this.isEdit ? '编辑' : '新建'}订阅源` : '调试源')
            .fontSize(FontConstants.FONT_SIZE_18)
            .fontWeight(FontConstants.FONT_WEIGHT_500)
            .lineHeight(26)
            .fontColor($r('app.string.color_black_88'))
            .textAlign(TextAlign.Center)

          // 右侧操作按钮区域
          Row({ space: 20 }) {
            // 调试入口按钮（仅在编辑页面显示）
            Row({ space: 4 }) {
              if (this.readIndex === 0) {
                Image($r('app.media.icon_dubug'))
                  .fillColor($r('app.string.color_black_88'))
                  .width(ImageConstants.IMG_WIDTH_20)
                  .height(ImageConstants.IMG_HEIGHT_20)
                Text('调试')
                  .font({
                    size: FontConstants.FONT_SIZE_14,
                    weight: FontConstants.FONT_WEIGHT_400,
                    family: CommonConstants.FAMILY_PingFANG
                  })
                  .fontColor($r('app.string.color_black_88'))
                  .lineHeight(22)
              }
            }
            .onClick(() => {
              // 点击进入调试页面
              this.headController.changeIndex(1)
            })
            
            /**
             * 更多菜单按钮：
             * - readIndex=0（编辑页面）：显示标准更多图标
             * - readIndex=1（调试页面）：显示翻译图标（源码相关操作）
             * 
             * bindPopup绑定弹窗菜单，包含：
             * - 清除Cookie、自动补全、拷贝源、粘贴源、设置原变量、字符串分享、帮助
             * - 或（调试页面）：列表源码、正文源码
             */
            Image(this.readIndex === 0 ? $r('app.media.more') : $r('app.media.more_translate'))
              .fillColor($r('app.string.color_black_88'))
              .width(ImageConstants.IMG_WIDTH_24)
              .height(ImageConstants.IMG_HEIGHT_24)
              .bindPopup(
                this.isShowMenu, {
                  builder: this.rightMoreDialogBuilder(),
                  placement: Placement.Bottom,
                  radius: 10,
                  enableArrow: false,
                  popupColor: Color.Transparent,
                  onStateChange: (e) => {
                    // 弹窗关闭时更新状态
                    if (!e.isVisible) {
                      this.isShowMenu = false
                    }
                  },
                  // 弹窗显示/隐藏时的过渡动画效果
                  transition: !this.isShowMenu
                    ? TransitionEffect.asymmetric(
                        TransitionEffect.OPACITY.animation({ duration: 1000, curve: Curve.Ease })
                          .combine(TransitionEffect.translate({ x: 0, y: 1 })),
                        TransitionEffect.IDENTITY
                      )
                    : TransitionEffect.scale({ x: 1, y: 0 }).animation({ duration: 500, curve: Curve.Ease })
                }
              )
              .onClick(() => {
                this.isShowMenu = !this.isShowMenu
              })
          }
        }
        
        /**
         * 外层Tabs容器：
         * - TabContent[0]：订阅源编辑页面（包含内层Tabs）
         * - TabContent[1]：调试源页面（SourceDebug组件）
         * 
         * barWidth/Height设为0隐藏TabBar，通过程序控制切换
         */
        Tabs({ barPosition: BarPosition.Start, index: this.readIndex, controller: this.headController }) {
          // 订阅源编辑Tab
          TabContent() {
            Column() {
              /**
               * 内层Tabs容器：
               * - TabContent[0]：基本信息表单（baseForm）
               * - TabContent[1]：列表规则表单（rssListForm）
               * - TabContent[2]：WebView规则表单（rssWebViewForm）
               */
              Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
                TabContent() {
                  this.baseForm()
                }
                .tabBar(this.tabBuilder(0, '基本'))

                TabContent() {
                  this.rssListForm()
                }.tabBar(this.tabBuilder(1, '列表'))

                TabContent() {
                  this.rssWebViewForm()
                }.tabBar(this.tabBuilder(2, 'WEB VIEW'))
              }
              .vertical(false)           // 水平TabBar
              .barMode(BarMode.Fixed)    // 固定宽度模式
              .barHeight(48)             // TabBar高度
              .animationDuration(400)    // 切换动画时长400ms
              .onChange((index: number) => {
                this.currentIndex = index
              })
            }
            .layoutWeight(1)
          }.layoutWeight(1)

          // 调试源Tab
          TabContent() {
            SourceDebug() // TODO: 需要完善订阅源调试页面功能
          }.layoutWeight(1)
        }
        .barWidth(0)
        .barHeight(0)
        .layoutWeight(1)
        .scrollable(false)  // 禁止手势滑动切换，只能通过程序控制
        .onChange((index: number) => {
          this.readIndex = index
        })
      }
      .layoutWeight(1)
      .padding(PaddingConstants.PADDING_20)
      
      // 分隔线
      Divider()
      
      /**
       * 底部操作按钮：
       * - 取消按钮：调用hideNewSources关闭页面
       * - 确认按钮：
       *   1. 验证必填字段（sourceName、sourceUrl）
       *   2. 验证图标URL格式（如果是网络图标）
       *   3. 调用SubscriptionDao.insert保存数据
       *   4. 显示操作结果提示，1秒后关闭页面
       */
      buttonCommon({
        cancel: () => {
          this.hideNewSources()
        },
        confirm: async () => {
          // 验证必填字段
          if (!this.formModel.sourceName || !this.formModel.sourceUrl) {
            this.scroller.scrollEdge(Edge.Top)  // 滚动到顶部显示错误
            this.readIndex = 0
            this.currentIndex = 0
            this.controller.changeIndex(0)
            showMessage('红星标记的内容不能为空')
            return
          }
          // 验证图标URL
          if (this.formModel.sourceIconIsUrl) {
            if (!isNetworkUrl(this.formModel.sourceIcon ?? '')) {
              showMessage('复制的链接不正确')
              return
            }
          }
          // 保存数据
          let isInsert = await SubscriptionDao.insert(this.formModel)
          if (isInsert) {
            showMessage('保存成功')
          } else {
            showMessage('保存失败')
          }
          // 延迟关闭页面
          setTimeout(() => {
            this.hideNewSources()
          }, 1000)
        },
      })

      // 预设图标选择面板（底部弹窗）
      Flex()
        .bindSheet(this.isShowPresetIcon, this.showPresetIcon(), {
          height: 400,
          dragBar: true,
          showClose: false,
          onDisappear: () => {
            this.isShowPresetIcon = false
          }
        })
      
      // 帮助对话框面板（底部弹窗，高度65%）
      Flex()
        .bindSheet($$this.isShowHelp, this.dialogHelpFuction(), {
          height: '65%',
          showClose: false,
          dragBar: false,
          onDisappear: () => {
            this.isShowHelp = false
          }
        })
    }
  }
  
  // ==================== 私有成员 ====================
  
  /**
   * @private scroller
   * @type Scroller
   * @description 滚动控制器，用于表单区域滚动到顶部
   */
  private scroller: Scroller = new Scroller()
  
  /**
   * @prop formModel
   * @type rssSources
   * @description 表单数据模型，与父组件双向绑定
   * 
   * 默认值包含：
   * - sourceName: 源名称（必填）
   * - sourceUrl: 源URL（必填）
   * - sourceIcon: 图标地址
   * - sourceType: 源类型（1=RSS订阅源）
   * - sourceIconIsUrl: 是否使用网络图标
   * - enabledCookieJar: 是否启用Cookie管理
   * - sourceGroup: 分组（默认"订阅"）
   * - rssListRule: 列表解析规则对象
   * - rssWebViewRule: WebView规则对象
   */
  @Prop formModel: rssSources = {
    sourceName: '',
    sourceUrl: '',
    sourceIcon: '',
    sourceType: 1,
    sourceIconIsUrl: false,
    enabledCookieJar: false,
    lastUpdateTime: new Date().getTime(),
    customOrder: 0,
    autoComplete: false,
    sourceGroup: SUBSCRIPTION_GROUP_TYPE[4],  // 默认分组：订阅
    enabled: true,
    singleUrl: true,
    showRecentIcon: true,
    customizeTitle: '',
    rssListRule: new rssListRule(),
    rssWebViewRule: new rssWebViewRule(),
  }

  // ==================== 分组列表数据 ====================
  
  /**
   * @state sourceGroupList
   * @type SelectOption[]
   * @default []
   * @description 订阅源分组列表，用于Select组件选择分组
   * 数据从rssSourceGroupDao.search()加载
   */
  @State sourceGroupList: SelectOption[] = []

  /**
   * @method getRssSourceList
   * @description 异步获取RSS订阅源分组列表
   * 
   * 流程：
   * 1. 调用rssSourceGroupDao.search()查询数据库
   * 2. 遍历结果，将分组名称转换为SelectOption格式
   * 3. 添加到sourceGroupList状态变量
   */
  async getRssSourceList() {
    let group = await rssSourceGroupDao.search()
    group.forEach(item => {
      this.sourceGroupList.push({
        value: item.rssGroupName
      })
    })
    // let list = programDataPreferences.getRssSourcesListData()
    // //将list存放到sourceGroupList
    // list.forEach((item) => {
    //   this.sourceGroupList.push({
    //     value: item
    //   })
    // })
  }

  /**
   * @lifecycle aboutToAppear
   * @description 组件即将显示时的生命周期回调
   * 
   * 初始化逻辑：
   * 1. 加载订阅源分组列表
   * 2. 初始化rssListRule（如果为空）
   * 3. 初始化rssWebViewRule（如果为空）
   * 4. 重置readIndex为0（显示编辑页面）
   */
  aboutToAppear(): void {
    this.getRssSourceList()
    if (!this.formModel.rssListRule) {
      this.formModel.rssListRule = new rssListRule()
    }
    if (!this.formModel.rssWebViewRule) {
      this.formModel.rssWebViewRule = new rssWebViewRule()
    }
    this.readIndex = 0
  }
  
  // ==================== 主题相关 ====================
  
  /**
   * @storageProp theme
   * @type ThemeItem
   * @description 从AppStorage同步的主题数据
   * 使用@StorageProp装饰器实现全局状态同步
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  // ==================== 表单构建器方法 ====================

  /**
   * @builder baseForm
   * @description 基本信息表单构建器
   * 
   * 包含字段：
   * - 名称：订阅源显示名称（必填，最多5字符）
   * - 源URL：RSS订阅地址（必填，支持CookieJar开关）
   * - 分组：选择订阅源所属分组
   * - 图标：支持网络链接或预设图标选择
   * - 源注释：额外说明文字
   * - 分类URL：分类页面地址
   * - 登录URL/UI/检查JS：登录相关配置
   * - 封面解密JS：封面图片解密脚本
   * - 请求头：自定义HTTP请求头
   * - 变量说明：源变量说明文档
   * - 并发率：请求频率限制
   * - jsLib：自定义JS库引用
   */
  @Builder
  baseForm() {
    Scroll(this.scroller) {
      Column() {
        // 名称输入项：必填，限制长度5字符
        FormItem({
          value: this.formModel.sourceName,
          label: '名称',
          isLength: true,
          maxLength: 5,
          required: true,
          onChange: (value: string) => {
            // 限制输入长度，超过6字符自动截断
            if (value?.length >= 6) {
              this.formModel.sourceName = value.slice(0, -1)
              return
            }
            this.formModel.sourceName = value
          }
        })

        // 源URL输入项：必填，右侧有CookieJar开关
        FormItem({
          value: this.formModel.sourceUrl,
          label: '源URL',
          required: true,
          onChange: (value: string) => {
            this.formModel.sourceUrl = value
          },
          customRightBuilder: () => {
            this.cookieJar(
              this.formModel.enabledCookieJar ?? false,
              (val: boolean) => {
                this.formModel.enabledCookieJar = val
              }
            )
          }
        })

        // 分组选择器
        Column() {
          Row() {
            Row() {
              Text('分组')
                .fontSize(16)
            }
            .alignItems(VerticalAlign.Center)
          }
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Select(this.sourceGroupList)
              // 设置选中项索引，根据当前sourceGroup匹配
              .selected(this.sourceGroupList.findIndex((item) => {
                return item.value === this.formModel.sourceGroup
              }))
              .value(this.formModel.sourceGroup ? this.formModel.sourceGroup : SUBSCRIPTION_GROUP_TYPE[4])
              .borderRadius(4)
              // 根据是否有值设置不同透明度颜色
              .fontColor(this.formModel.sourceGroup !== undefined ? '#E0000000' : '#73000000')
              .onSelect((index: number, text?: string | undefined) => {
                if (text) {
                  this.formModel.sourceGroup = text
                }
              })
              .backgroundColor($r('app.string.color_black_6'))
              .layoutWeight(1)
          }
          .margin({ top: 10, bottom: 10 })
        }
        .margin({ top: 12 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 图标设置区域
        Column() {
          Flex({
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Row() {
              Text('图标')
                .fontSize(16)
            }
            .alignItems(VerticalAlign.Center)

            Row() {
              this.sourceIconIsUrl(
                this.formModel.sourceIconIsUrl ?? false,
                (val: boolean) => {
                  this.formModel.sourceIconIsUrl = val
                }
              )
            }
          }
          
          // 根据sourceIconIsUrl切换显示：网络链接输入 或 本地/预设选择
          if (this.formModel.sourceIconIsUrl) {
            FormItem({
              value: this.formModel.sourceIcon,
              label: '图标链接',
              showTitle: false,
              onChange: (value: string) => {
                this.formModel.sourceIcon = value
              }
            })
          } else {
            // 本地图片选择和预设图标按钮
            Flex({
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Row() {
                Text('选择本地图片')
                  .textAlign(TextAlign.Center)
                  .fontSize(16)
                  .padding({ top: 8, bottom: 8, right: 12, left: 12 })
              }
              .justifyContent(FlexAlign.Center)
              .width('48%')
              .backgroundColor($r('app.string.color_black_6'))

              Row() {
                Text('预设图标')
                  .textAlign(TextAlign.Center)
                  .fontSize(16)
                  .padding({ top: 8, bottom: 8, right: 12, left: 12 })
              }
              .justifyContent(FlexAlign.Center)
              .width('48%')
              .backgroundColor($r('app.string.color_black_6'))
              .onClick(() => {
                this.isShowPresetIcon = true  // 打开预设图标选择面板
              })
            }
            .margin({ top: 12 })
          }
          
          // 显示图标预览效果（仅在使用预设图标时）
          if (!this.formModel.sourceIconIsUrl && this.formModel.customizeTitle) {
            PreviewEffectImage({
              customizeTitle: this.formModel.customizeTitle,
              sourceIcon: this.formModel.sourceIcon
            })
          }
        }
        .margin({ top: 12, left: 20, right: 20 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 以下为基础表单的其他字段
        FormItem({
          value: this.formModel.sourceComment,
          label: '源注释',
          onChange: (value: string) => {
            this.formModel.sourceComment = value
          }
        })

        FormItem({
          value: this.formModel.sortUrl,
          label: '分类URL',
          onChange: (value: string) => {
            this.formModel.sortUrl = value
          }
        })

        FormItem({
          value: this.formModel.loginUrl,
          label: '登录URL',
          onChange: (value: string) => {
            this.formModel.loginUrl = value
          }
        })

        FormItem({
          value: this.formModel.loginUi,
          label: '登录UI',
          onChange: (value: string) => {
            this.formModel.loginUi = value
          }
        })

        FormItem({
          value: this.formModel.loginCheckJs,
          label: '登录检查JS',
          onChange: (value: string) => {
            this.formModel.loginCheckJs = value
          }
        })

        FormItem({
          value: this.formModel.coverDecodeJs,
          label: '封面解密',
          onChange: (value: string) => {
            this.formModel.coverDecodeJs = value
          }
        })

        FormItem({
          value: this.formModel.header,
          label: '请求头',
          onChange: (value: string) => {
            this.formModel.header = value
          }
        })

        FormItem({
          value: this.formModel.variableComment,
          label: '变量说明',
          onChange: (value: string) => {
            this.formModel.variableComment = value
          }
        })

        FormItem({
          value: this.formModel.concurrentRate,
          label: '并发率',
          onChange: (value: string) => {
            this.formModel.concurrentRate = value
          }
        })

        FormItem({
          value: this.formModel.jsLib,
          label: 'jsLib',
          onChange: (value: string) => {
            this.formModel.jsLib = value
          }
        })
      }
    }
    .align(Alignment.Top)
    .layoutWeight(1)
    .scrollBar(BarState.Off)  // 隐藏滚动条
    .padding({ left: 20, right: 20 })
  }

  /**
   * @builder rssListForm
   * @description RSS列表规则表单构建器
   * 
   * 列表规则用于定义如何从网页/feed中提取文章列表信息：
   * - ruleArticles: 文章列表选择器规则
   * - ruleNextPage: 下一页链接规则
   * - ruleTitle: 标题提取规则
   * - rulePubDate: 发布时间提取规则
   * - ruleDescription: 描述/摘要提取规则
   * - ruleImage: 封面图提取规则
   * - ruleLink: 文章链接提取规则
   */
  @Builder
  rssListForm() {
    Scroll() {
      Column() {
        FormItem({
          value: this.formModel.rssListRule?.ruleArticles,
          label: '列表规则',
          onChange: (value: string) => {
            if (this.formModel.rssListRule) {
              this.formModel.rssListRule.ruleArticles = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssListRule?.ruleNextPage,
          label: '列表下一页规则',
          onChange: (value: string) => {
            if (this.formModel.rssListRule) {
              this.formModel.rssListRule.ruleNextPage = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssListRule?.ruleTitle,
          label: '标题规则',
          onChange: (value: string) => {
            if (this.formModel.rssListRule) {
              this.formModel.rssListRule.ruleTitle = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssListRule?.rulePubDate,
          label: '时间规则',
          onChange: (value: string) => {
            if (this.formModel.rssListRule) {
              this.formModel.rssListRule.rulePubDate = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssListRule?.ruleDescription,
          label: '描述规则',
          onChange: (value: string) => {
            if (this.formModel.rssListRule) {
              this.formModel.rssListRule.ruleDescription = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssListRule?.ruleImage,
          label: '图片规则',
          onChange: (value: string) => {
            if (this.formModel.rssListRule) {
              this.formModel.rssListRule.ruleImage = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssListRule?.ruleLink,
          label: '链接规则',
          onChange: (value: string) => {
            if (this.formModel.rssListRule) {
              this.formModel.rssListRule.ruleLink = value
            }
          }
        })
      }
    }
    .align(Alignment.Top)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .padding({ left: 20, right: 20 })
  }

  /**
   * @builder rssWebViewForm
   * @description RSS WebView规则表单构建器
   * 
   * WebView规则用于配置文章详情页的显示方式：
   * - enableJs: 是否启用JavaScript执行
   * - loadWithBaseUrl: 是否使用BaseUrl加载
   * - ruleContent: 正文内容提取规则
   * - style: 自定义CSS样式
   * - injectJs: 注入的JavaScript代码
   * - contentWhitelist: 内容白名单（允许加载的URL）
   * - contentBlacklist: 内容黑名单（禁止加载的URL）
   * - shouldOverrideUrlLoading: URL拦截规则
   */
  @Builder
  rssWebViewForm() {
    Scroll() {
      Column() {
        // JavaScript开关
        Flex({
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('启用JavaScript')
            .fontColor(16)
          Toggle({ type: ToggleType.Switch, isOn: this.formModel.rssWebViewRule?.enableJs })
            .selectedColor(this.theme.mainColor)
            .margin({ left: 8 })
            .onChange((val: boolean) => {
              if (this.formModel.rssWebViewRule) {
                this.formModel.rssWebViewRule.enableJs = val
                showMessage(JSON.stringify(this.formModel.rssWebViewRule.enableJs))
              }
            })
        }

        // BaseUrl加载开关
        Flex({
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('加载 BaseUrl')
            .fontColor(16)
          Toggle({ type: ToggleType.Switch, isOn: this.formModel.rssWebViewRule?.loadWithBaseUrl })
            .selectedColor(this.theme.mainColor)
            .margin({ left: 8 })
            .onChange((val: boolean) => {
              if (this.formModel.rssWebViewRule) {
                this.formModel.rssWebViewRule.loadWithBaseUrl = val
              }
            })
        }

        FormItem({
          value: this.formModel.rssWebViewRule?.ruleContent,
          label: '内容规则',
          onChange: (value: string) => {
            if (this.formModel.rssWebViewRule) {
              this.formModel.rssWebViewRule.ruleContent = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssWebViewRule?.style,
          label: '样式规则',
          onChange: (value: string) => {
            if (this.formModel.rssWebViewRule) {
              this.formModel.rssWebViewRule.style = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssWebViewRule?.injectJs,
          label: '注入规则',
          onChange: (value: string) => {
            if (this.formModel.rssWebViewRule) {
              this.formModel.rssWebViewRule.injectJs = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssWebViewRule?.contentWhitelist,
          label: '白名单',
          onChange: (value: string) => {
            if (this.formModel.rssWebViewRule) {
              this.formModel.rssWebViewRule.contentWhitelist = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssWebViewRule?.contentBlacklist,
          label: '黑名单',
          onChange: (value: string) => {
            if (this.formModel.rssWebViewRule) {
              this.formModel.rssWebViewRule.contentBlacklist = value
            }
          }
        })
        FormItem({
          value: this.formModel.rssWebViewRule?.shouldOverrideUrlLoading,
          label: '链接拦截',
          onChange: (value: string) => {
            if (this.formModel.rssWebViewRule) {
              this.formModel.rssWebViewRule.shouldOverrideUrlLoading = value
            }
          }
        })
      }
    }
    .align(Alignment.Top)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .padding({ left: 20, right: 20 })
  }

  /**
   * @builder tabBuilder
   * @param index Tab索引
   * @param name Tab显示名称
   * @description TabBar项构建器
   * 
   * 根据currentIndex高亮显示当前选中Tab：
   * - 选中时：fontWeight=700（粗体）
   * - 未选中：fontWeight=400（常规）
   */
  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 700 : 400)
        .lineHeight(24)
    }
  }

  /**
   * @builder cookieJar
   * @param enabledCookieJar 当前CookieJar启用状态
   * @param onChange 状态变更回调函数
   * @description CookieJar开关构建器
   * 
   * 用于在源URL输入框右侧显示CookieJar开关
   */
  @Builder
  cookieJar(enabledCookieJar: boolean, onChange: (_val: boolean) => void) {
    Row() {
      Text('CookieJar')

      Toggle({ type: ToggleType.Switch, isOn: enabledCookieJar })
        .selectedColor(this.theme.mainColor)
        .margin({ left: 8 })
        .onChange((val: boolean) => {
          onChange(val)
        })
    }
  }

  /**
   * @builder sourceIconIsUrl
   * @param sourceIconIsUrl 当前是否使用网络图标
   * @param onChange 状态变更回调函数
   * @description 图标来源切换开关构建器
   * 
   * 用于在图标设置区域显示"使用链接"开关
   */
  @Builder
  sourceIconIsUrl(sourceIconIsUrl: boolean, onChange: (_val: boolean) => void) {
    Row() {
      Text('使用链接')

      Toggle({ type: ToggleType.Switch, isOn: sourceIconIsUrl })
        .selectedColor(this.theme.mainColor)
        .margin({ left: 8 })
        .onChange((val: boolean) => {
          onChange(val)
        })
    }
  }
  
  /**
   * @state isShowPresetIcon
   * @type boolean
   * @default false
   * @description 控制预设图标选择面板的显示状态
   */
  @State isShowPresetIcon: boolean = false
  
  /**
   * @builder showPresetIcon
   * @description 预设图标选择面板构建器
   * 
   * 使用Grid布局包裹RssSourceCheckImage组件
   * 回调处理：
   * - onCancel：关闭面板
   * - onSubmit：设置选中的图标标题和图标字符串
   */
  @Builder
  showPresetIcon() {
    Grid() {
      GridItem() {
        RssSourceCheckImage({
          onCancel: () => {
            this.isShowPresetIcon = false
          },
          onSubmit: (value: string, imageString: string) => {
            this.formModel.customizeTitle = value
            this.formModel.sourceIcon = imageString
            this.isShowPresetIcon = false
          }
        })
      }
    }
  }

  // ==================== 菜单数据定义 ====================
  
  /**
   * 订阅源编辑页面的右侧菜单项
   * 索引对应功能：
   * 0-清除Cookie, 1-自动补全, 2-拷贝源, 3-粘贴源, 4-设置原变量, 5-字符串分享, 6-帮助
   */
  Item_Right_MORE_Dialog_Data: string[] = ['清除Cookie', '自动补全', '拷贝源', '粘贴源', '设置原变量', '字符串分享', '帮助']
  
  /**
   * 调试页面的右侧菜单项
   * 索引对应功能：0-列表源码, 1-正文源码
   */
  Item_Right_Debug_MORE_Dialog_Data: string[] = ['列表源码', '正文源码']

  /**
   * @method dialogMoreRightChange
   * @param index 菜单项索引
   * @description 右侧菜单项点击事件处理
   * 
   * 根据当前页面(readIndex)和点击索引执行对应操作：
   * - readIndex=0（编辑页面）：处理订阅源相关操作
   * - readIndex=1（调试页面）：处理源码查看操作
   * - 索引6（帮助）：打开帮助对话框
   */
  dialogMoreRightChange(index: number) {
    if (this.readIndex === 0) {
      // 订阅源编辑页面菜单处理
      switch (index) {
        case 0:
          showMessage('清除Cookie')
          break
        case 2:
          showMessage('拷贝源')
          break
        case 3:
          showMessage('粘贴源')
          break
        case 4:
          showMessage('设置原变量')
          break
        case 5:
          showMessage('字符串分享')
          break
        case 6:
          this.isShowHelp = true  // 打开帮助对话框
          showMessage('帮助')
          break
      }
    } else {
      // 调试页面菜单处理
      switch (index) {
        case 0:
          showMessage('列表源码')
          break
        case 1:
          showMessage('正文源码')
          break
      }
    }
  }

  /**
   * @builder rightMoreDialogBuilder
   * @description 右侧更多菜单弹窗构建器
   * 
   * 根据当前页面动态渲染不同菜单项：
   * - 编辑页面：显示Item_Right_MORE_Dialog_Data（含特殊处理索引1的toggleBuilder）
   * - 调试页面：显示Item_Right_Debug_MORE_Dialog_Data
   * 
   * 使用dialogTitleFuction组件渲染每个菜单项
   */
  @Builder
  rightMoreDialogBuilder() {
    Column() {
      if (this.readIndex === 0) {
        // 订阅源编辑页面菜单
        ForEach(this.Item_Right_MORE_Dialog_Data, (item: string, index) => {
          if (index === 1) {
            // 索引1是"自动补全"，需要显示Toggle开关
            this.toggleBuilder(item)
          } else {
            dialogTitleFuction({
              title: item,
              isBorder: this.Item_Right_MORE_Dialog_Data.length !== index + 1  // 最后一项不显示底部边框
            })
              .onClick(() => {
                this.dialogMoreRightChange(index)
              })
          }
        })
      } else {
        // 调试源页面菜单
        ForEach(this.Item_Right_Debug_MORE_Dialog_Data, (item: string, index) => {
          dialogTitleFuction({
            title: item,
            isBorder: this.Item_Right_Debug_MORE_Dialog_Data.length !== index + 1
          })
            .onClick(() => {
              this.dialogMoreRightChange(index)
            })
        })
      }
    }
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * @builder toggleBuilder
   * @param title 菜单项标题
   * @description 带Toggle开关的菜单项构建器
   * 
   * 用于"自动补全"菜单项，绑定formModel.autoComplete状态
   */
  @Builder
  toggleBuilder(title: string) {
    Column() {
      Row({ space: 5 }) {
        Text(title)
          .font({
            size: FontConstants.FONT_SIZE_14,
            weight: FontConstants.FONT_WEIGHT_400,
            family: CommonConstants.FAMILY_PingFANG
          })
          .fontColor($r('app.string.color_black_88'))
          .lineHeight(TextConstants.TEXT_LINE_HEIGHT_22)
        Toggle({ type: ToggleType.Switch, isOn: this.formModel.autoComplete })
          .selectedColor(this.theme.mainColor)
          .margin({ left: 8 })
          .onChange((val: boolean) => {
            this.formModel.autoComplete = val
          })
      }
      .border({
        style: BorderStyle.Solid,
        width: 1,
        color: '#f5f5f5'
      })
      .padding({
        top: PaddingConstants.PADDING_12,
        bottom: PaddingConstants.PADDING_12
      })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .padding({
      left: PaddingConstants.PADDING_20,
      right: PaddingConstants.PADDING_20
    })
  }

  /**
   * @builder dialogHelpFuction
   * @description 帮助对话框构建器
   * 
   * 使用Help组件封装，包含：
   * - 标题：源规则帮助
   * - 关闭按钮回调
   * - 内容区域：由helpContent构建器提供
   */
  @Builder
  dialogHelpFuction() {
    Column() {
      Help({
        title: '源规则帮助',
        btnClick: () => {
          this.isShowHelp = false
        },
        contentBuilder: this.helpContent,
        isShowContent: false
      })
    }
  }
  
  /**
   * @builder helpContent
   * @description 帮助对话框内容构建器
   * 
   * 包含rssSourcesHelp组件，显示订阅源规则的帮助文档
   */
  @Builder
  helpContent() {
    Column() {
      rssSourcesHelp()
    }
  }
}

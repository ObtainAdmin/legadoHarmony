/**
 * @file newSourcesNetWork.ets
 * @description 新建/编辑常规网站订阅源页面组件
 * 
 * 功能说明：
 * 1. 提供创建新的常规网站订阅源或编辑现有网站源的界面
 * 2. 简化版的订阅源表单，专注于网站基本信息
 * 3. 支持图标选择（网络链接或预设图标）
 * 4. 支持分组管理
 * 
 * 与newSources.ets的区别：
 * - newSources：完整的RSS订阅源编辑器，支持列表规则、WebView规则
 * - newSourcesNetWork：简化的网站源编辑器，仅支持基本信息配置
 * 
 * @author 2008
 * @datetime 2024/7/16 18:13
 * @className: newSources
 * @description 新建/修改常规网站
 */

// ==================== 常量导入 ====================
// 字体大小和样式常量
import FontConstants from '../../../../common/constants/FontConstants'
// 间距和边距常量
import PaddingConstants from '../../../../common/constants/PaddingConstants'

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
// 消息提示组件，用于显示操作反馈
import { showMessage } from '../../../../componets/common/promptShow'

// ==================== 业务组件导入 ====================
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

// ==================== 偏好设置导入 ====================
// 程序数据偏好设置
import programDataPreferences from '../../../../preferences/programDataPreferences'

// ==================== 子组件导入 ====================
// 图标预览效果组件
import PreviewEffectImage from '../components/PreviewEffectImage'
// RSS订阅源图标选择组件
import RssSourceCheckImage from '../components/RssSourceCheckImage'

// ==================== 组件定义 ====================

/**
 * @Component newSourcesNetWork
 * @description 新建/编辑常规网站订阅源页面组件
 * 
 * 核心功能：
 * - 表单数据绑定：通过 @State formModel 管理表单状态
 * - 简化的表单：仅包含网站基本信息（名称、URL、分组、图标）
 * - 图标选择：支持网络链接或预设图标
 * - 分组管理：从数据库加载分组列表
 * 
 * 适用场景：
 * - 添加简单的网站订阅源（如新闻网站、博客等）
 * - 不需要复杂的列表规则和WebView规则配置
 */
@Component
export default struct newSourcesNetWork {
  
  // ==================== 回调与属性 ====================
  
  /**
   * @prop hideNewWork
   * @type Function
   * @description 父组件传入的回调函数，用于关闭当前页面/对话框
   */
  hideNewWork: Function = () => {}
  
  /**
   * @prop isEdit
   * @type boolean
   * @default false
   * @description 标识当前是编辑模式(true)还是新建模式(false)，影响页面标题
   */
  @Prop isEdit: boolean = false
  
  // ==================== 主题相关 ====================
  
  /**
   * @storageProp theme
   * @type ThemeItem
   * @description 从AppStorage同步的主题数据
   * 使用@StorageProp装饰器实现全局状态同步
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @build
   * @description 主构建方法，定义页面整体布局结构
   * 
   * 布局结构：
   * 1. 外层Column - 整体垂直布局容器
   * 2. 内层Column - 内容区域（占满剩余空间）
   * 3. 标题Text - 显示"添加网站"或"编辑网站"
   * 4. 表单区域 - 由baseForm构建器提供
   * 5. Divider - 分隔线
   * 6. 底部按钮 - 取消/确认操作
   * 7. bindSheet - 预设图标选择面板
   */
  build() {
    Column() {
      // 内容区域容器
      Column() {
        /**
         * 页面标题：
         * - 编辑模式：显示"编辑网站"
         * - 新建模式：显示"添加网站"
         */
        Text(`${this.isEdit ? '编辑' : '添加'}网站`)
          .fontSize(FontConstants.FONT_SIZE_16)
          .fontWeight(FontConstants.FONT_WEIGHT_500)
          .lineHeight(24)
          .fontColor($r('app.string.color_black_88'))
          .textAlign(TextAlign.Center)
        
        // 基础表单区域
        this.baseForm()
      }
      .layoutWeight(1)
      .padding(PaddingConstants.PADDING_20)
      
      // 分隔线
      Divider()
      
      /**
       * 底部操作按钮：
       * - 取消按钮：调用hideNewWork关闭页面
       * - 确认按钮：
       *   1. 验证必填字段（sourceName、sourceUrl）
       *   2. 验证图标URL格式（如果是网络图标）
       *   3. 调用SubscriptionDao.insert保存数据
       *   4. 显示操作结果提示，1秒后关闭页面
       */
      buttonCommon({
        cancel: () => {
          this.hideNewWork()
        },
        confirm: async () => {
          // 验证必填字段
          if (!this.formModel.sourceName || !this.formModel.sourceUrl) {
            this.scroller.scrollEdge(Edge.Top)  // 滚动到顶部显示错误
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
            this.hideNewWork()
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
   * @state formModel
   * @type rssSources
   * @description 表单数据模型
   * 
   * 默认值包含：
   * - sourceName: 网站名称（必填）
   * - sourceUrl: 网站URL（必填）
   * - sourceIcon: 图标地址
   * - sourceType: 源类型（0=常规网站，与newSources的1=RSS不同）
   * - sourceIconIsUrl: 是否使用网络图标
   * - enabledCookieJar: 是否启用Cookie管理
   * - sourceGroup: 分组（默认"订阅"）
   * 
   * 注意：与newSources不同，此组件不管理rssListRule和rssWebViewRule
   */
  @State formModel: rssSources = {
    sourceName: '',
    sourceUrl: '',
    sourceIcon: '',
    sourceType: 0,  // 0=常规网站，区别于newSources的1=RSS
    sourceIconIsUrl: false,
    enabledCookieJar: false,
    lastUpdateTime: new Date().getTime(),
    customOrder: 0,
    autoComplete: false,
    sourceGroup: SUBSCRIPTION_GROUP_TYPE[4],  // 默认分组：订阅
    enabled: true,
    singleUrl: true,
    showRecentIcon: true,
    customizeTitle: ''
  }

  /**
   * @lifecycle aboutToAppear
   * @description 组件即将显示时的生命周期回调
   * 
   * 初始化逻辑：加载订阅源分组列表
   */
  aboutToAppear(): void {
    this.getRssSourceList()
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

  // ==================== 表单构建器方法 ====================

  /**
   * @builder baseForm
   * @description 基础信息表单构建器
   * 
   * 包含字段（简化版，比newSources少很多）：
   * - 名称：网站显示名称（必填，最多5字符）
   * - 网址：网站URL（必填）
   * - 分组：选择网站所属分组
   * - 图标：支持网络链接或预设图标选择
   * 
   * 注意：相比newSources，此表单不包含：
   * - 源注释、分类URL、登录相关配置
   * - CookieJar开关（虽然formModel中有字段，但UI未暴露）
   * - 列表规则和WebView规则（这是核心区别）
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

        // 网址输入项：必填
        FormItem({
          value: this.formModel.sourceUrl,
          label: '网址',
          required: true,
          onChange: (value: string) => {
            this.formModel.sourceUrl = value
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
              sourceIcon: this.formModel.sourceIcon,
              sourceIconIsUrl: this.formModel.sourceIconIsUrl
            })
          }
        }
        .margin({ top: 12, left: 20, right: 20 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .align(Alignment.Top)
    .layoutWeight(1)
    .scrollBar(BarState.Off)  // 隐藏滚动条
    .padding({ left: 20, right: 20 })
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

  // ==================== 预设图标选择 ====================
  
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
}

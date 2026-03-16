/**
 * @author 2008
 * @datetime 2024/6/26 23:55
 * @className: IndexFind
 * @description: 发现页面主组件 - 整个发现模块的核心容器和业务逻辑处理中心
 * 
 * 组件功能：
 * 1. 提供三大内容类型切换：小说、漫画、有声书
 * 2. 集成书源管理功能：粘贴导入、本地导入、书源管理、导入帮助
 * 3. 支持主题渐变色背景，提供视觉美感
 * 4. 使用底部弹窗展示帮助和导入对话框
 * 5. 响应式布局，适配不同屏幕尺寸和系统状态栏
 * 
 * 页面结构：
 * - 顶部导航栏：三大类型切换按钮 + 右侧功能菜单
 * - 中间内容区：Tabs容器承载对应类型的发现内容
 * - 底部弹窗区：帮助对话框和导入对话框
 * - 背景渐变：使用主题主色和辅色创建渐变效果
 * 
 * 核心特性：
 * - 类型切换：通过Tabs组件实现平滑的内容切换
 * - 书源导入：支持剪贴板URL解析和本地文件选择
 * - 主题适配：使用StorageLink和StorageProp实现主题切换
 * - 响应式布局：根据系统状态栏高度动态调整顶部间距
 * 
 * 数据管理：
 * - currentIndex：当前选中的内容类型索引
 * - sourceList：导入的书源数据列表
 * - topRectHeight：系统状态栏高度（响应式适配）
 * - theme：主题颜色配置（渐变色背景）
 * 
 * 交互逻辑：
 * - 类型切换：点击顶部标签切换Tabs内容
 * - 功能菜单：右上角菜单提供书源相关功能
 * - 粘贴导入：自动解析剪贴板中的书源URL
 * - 本地导入：通过文件选择器导入书源文件
 * 
 * 技术亮点：
 * - 使用@StorageLink和@StorageProp实现状态同步
 * - 集成axios进行网络请求获取书源数据
 * - 使用bindSheet实现底部弹窗对话框
 * - 线性渐变背景提升视觉体验
 */

// ==================== 组件导入 ====================
// UI组件
import BookMark from '../../../componets/head/BookMark';                                    // 顶部书签式标签组件
import dialogTitleFuction from '../../../componets/common/dialogTitleFuction';              // 对话框功能项组件
import ImportCommon from '../../../componets/import/ImportCommon';                          // 通用导入组件
import Help from '../../../componets/dialog/help';                                          // 帮助对话框组件
import FindContent from './components/FindContent';                                         // 发现页面内容组件

// 工具类和功能模块
import { router } from '@kit.ArkUI';                                                        // 路由导航
import { IconTitleVo } from '../../../componetsmodel/IconTitleVo';                          // 图标标题数据模型
import { FileHandler } from '../../../common/utils/FileHandler';                            // 文件处理工具类
import axios, { AxiosResponse } from '@ohos/axios';                                           // HTTP网络请求
import { common } from '@kit.AbilityKit';                                                    // 系统能力接口
import { getPasteDataSync, isNetworkUrl, sleep } from '../../../common/utils/utils';        // 工具函数
import { showMessage } from '../../../componets/common/promptShow';                         // 消息提示

// 数据模型和配置
import { BookSource } from '../../../database/entities/BookSource';                          // 书源实体类
import { ThemeItem } from '../../../common/model/Theme';                                     // 主题配置模型
import { ThemeStorageKey } from '../../../common/constants/Theme';                           // 主题存储键常量

/**
 * 发现页面主组件
 * 作为发现模块的核心容器，负责整体布局和业务逻辑处理
 * 使用@Entry装饰器标识为页面入口，@Preview支持预览功能
 */
@Component
@Entry
@Preview
export default struct IndexFind {
  // ==================== 控制器和基础配置 ====================
  /** 滚动控制器，用于List组件的滚动管理 */
  private scrollController: Scroller = new Scroller();
  
  /** 三大内容类型标题数组：小说、漫画、有声书 */
  titleArray: Array<string> = ['小说', '漫画', '有声书']
  
  /** Tabs控制器，用于控制标签页切换 */
  tabsController: TabsController = new TabsController();

  // ==================== 状态管理 ====================
  /** 当前选中的内容类型索引，0-小说，1-漫画，2-有声书 */
  @State currentIndex: number = 0
  
  /** 系统状态栏高度，用于响应式布局适配 */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 发现页面是否可滚动，由应用配置决定 */
  @StorageProp('APP_INDEX_SCROLLABLE') APP_INDEX_SCROLLABLE: boolean = false
  
  /** 分组封面显示状态（预留功能） */
  @State groupCoverShow: boolean = false
  
  /** 书籍类型筛选（预留功能） */
  @State bookType: string = '全部'
  
  /** 分组类型（预留功能） */
  @State GROUP: string = '标签'
  
  /** 是否显示帮助对话框 */
  @State isShowHelp: boolean = false
  
  /** 是否显示导入对话框 */
  @State isShowImport: boolean = false
  
  /** 导入的书源数据列表 */
  @State sourceList: BookSource[] = []
  
  /** 主题颜色配置，用于渐变背景 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 组件UI构建方法
   * 构建发现页面的完整布局结构
   * 
   * 布局层次：
   * 1. 外层Column：垂直布局的根容器，设置渐变背景
   * 2. 顶部导航区：水平排列的类型切换 + 右侧功能菜单
   * 3. 内容Tabs区：承载三大类型的发现内容
   * 4. 底部弹窗区：帮助和导入对话框（条件渲染）
   * 
   * 设计特点：
   * - 渐变背景：使用主题主色和辅色创建底部渐变效果
   * - 响应式顶部：根据系统状态栏高度动态调整上间距
   * - 隐藏式Tabs：设置barWidth和barHeight为0，使用自定义导航
   * - 底部弹窗：使用bindSheet实现优雅的对话框展示
   */
  build() {
    Column() {
      // ==================== 顶部导航区域 ====================
      Flex({
        justifyContent: FlexAlign.SpaceBetween  // 两端对齐：左侧标签 + 右侧菜单
      }) {
        // 左侧三大类型切换标签
        Row() {
          List({ scroller: this.scrollController }) {
            // 小说标签
            ListItem() {
              BookMark({ 
                title: '小说', 
                index: 0, 
                currentIndex: this.currentIndex 
              }).onClick(() => {
                this.currentIndex = 0
                this.tabsController.changeIndex(0)
                console.log('切换到小说标签页，当前索引：' + this.currentIndex)
              })
            }

            // 漫画标签
            ListItem() {
              BookMark({ 
                title: '漫画', 
                index: 1, 
                currentIndex: this.currentIndex 
              }).onClick(() => {
                this.currentIndex = 1
                this.tabsController.changeIndex(1)
                console.log('切换到漫画标签页，当前索引：' + this.currentIndex)
              })
            }

            // 有声书标签
            ListItem() {
              BookMark({ 
                title: '有声书', 
                index: 2, 
                currentIndex: this.currentIndex 
              }).onClick(() => {
                this.currentIndex = 2
                this.tabsController.changeIndex(2)
                console.log('切换到有声书标签页，当前索引：' + this.currentIndex)
              })
            }
          }
          .height(40)                    // 固定高度40px
          .scrollBar(BarState.Off)       // 关闭滚动条
          .listDirection(Axis.Horizontal) // 水平排列
        }

        // 右侧功能菜单按钮
        Image($r('app.media.addSubscription'))
          .width(24)                     // 24px宽度
          .bindMenu(this.dialogRightFuction()) // 绑定右键菜单
      }
      // 响应式顶部间距：根据系统状态栏高度调整
      .padding({ 
        top: this.topRectHeight === 0 ? 30 : this.topRectHeight, 
        left: 20, 
        right: 20 
      })

      // ==================== 内容区域 ====================
      Tabs({
        barPosition: BarPosition.Start,    // 标签栏在顶部（但会被隐藏）
        controller: this.tabsController     // Tabs控制器
      }) {
        // 遍历三大类型，创建对应的TabContent
        ForEach(this.titleArray, (item: string) => {
          TabContent() {
            FindContent({
              currentIndex: this.currentIndex  // 传递当前类型索引
            })
          }
          .align(Alignment.Top)               // 顶部对齐
        })
      }
      .layoutWeight(1)                        // 占据剩余空间
      .barWidth(0)                            // 隐藏默认标签栏宽度
      .barHeight(0)                           // 隐藏默认标签栏高度
      .onChange((index) => {
        // Tabs切换事件处理
        this.tabsController.changeIndex(index)
        this.currentIndex = index
      })
      .scrollable(this.APP_INDEX_SCROLLABLE) // 根据配置决定是否可滚动

      // ==================== 底部弹窗区域 ====================
      // 帮助对话框 - 底部弹窗形式
      Flex()
        .bindSheet(this.isShowHelp, this.dialogHelpFuction(), {
          height: '50%',                    // 弹窗高度50%
          showClose: false,                 // 不显示关闭按钮
          dragBar: false,                   // 不显示拖拽条
          onDisappear: () => {
            this.isShowHelp = false        // 弹窗关闭时重置状态
          }
        })
      
      // 导入对话框 - 底部弹窗形式  
      Flex()
        .bindSheet(this.isShowImport, this.dialogImportFunction(), {
          detents: [SheetSize.FIT_CONTENT, SheetSize.LARGE, 200], // 多档高度可选
          dragBar: true,                    // 显示拖拽条
          showClose: false,                 // 不显示关闭按钮
          onDisappear: () => {
            this.isShowImport = false      // 弹窗关闭时重置状态
          }
        })
    }
    // 设置渐变背景色：从主题主色到辅色的底部渐变
    .linearGradient({
      direction: GradientDirection.Bottom,    // 渐变方向：从上到下的底部渐变
      colors: [
        [this.theme.mainColor, 0],           // 起始颜色：主题主色
        [this.theme.secondColor, 0.2]        // 结束颜色：主题辅色（20%位置）
      ]
    })
  }

  // ==================== 功能菜单配置 ====================
  /** 
   * 右侧功能菜单项配置
   * 包含：粘贴导入、本地导入、书源管理、导入帮助
   */
  FIND_Dialog_Right_Fuction: IconTitleVo[] = [
    new IconTitleVo($r('app.media.icon_rule_paste'), '粘贴导入'),
    new IconTitleVo($r('app.media.icon_rule_export'), '本地导入'),
    new IconTitleVo($r('app.media.icon_find_shelf'), '书源管理'),
    new IconTitleVo($r('app.media.icon_rule_help'), '导入帮助')
  ]

  /**
   * 右侧功能菜单构建器
   * 构建包含四个功能项的垂直菜单
   */
  @Builder
  dialogRightFuction() {
    Column() {
      ForEach(this.FIND_Dialog_Right_Fuction, (item: IconTitleVo, index) => {
        dialogTitleFuction({
          title: item.title,
          icon: item.icon,
          isBorder: this.FIND_Dialog_Right_Fuction.length !== index + 1  // 最后一项不显示边框
        })
          .onClick(() => {
            this.findBindMenuFunction(index)  // 点击事件委托给统一处理函数
          })
      })
    }
  }

  /**
   * 粘贴板解析功能
   * 从剪贴板获取URL，请求书源数据并显示导入对话框
   * 
   * 处理逻辑：
   * 1. 同步获取剪贴板数据
   * 2. 验证URL格式（注释掉的逻辑）
   * 3. 发送HTTP请求获取书源数据
   * 4. 显示导入对话框
   * 
   * 容错处理：
   * - 剪贴板为空时显示提示信息
   * - URL格式错误时显示提示信息
   * - 网络请求失败时捕获异常
   */
  async pasteAnalyze() {
    try {
      // 从剪贴板同步获取URL数据
      let url = getPasteDataSync()
      if (!url) {
        showMessage('未获取到粘贴信息')
        await sleep()  // 等待一段时间让用户看到提示
        // 注：即使没有URL也继续执行，使用默认URL
      }
      
      // URL格式验证（当前被注释掉）
      // if (!isNetworkUrl(url ?? '')) {
      //   showMessage('复制的链接不正确')
      //   await sleep()
      //   url = undefined
      // }
      
      // 发送HTTP请求获取书源数据
      // 如果URL为空则使用默认的书源URL
      const res: AxiosResponse = await axios
        .get(url ?? 'https://node.wisdoms.xin/static/file/20240704/sy.json');
      
      this.sourceList = res.data;    // 保存获取的书源列表
      this.isShowImport = true;      // 显示导入对话框
    } catch (err) {
      console.error('粘贴解析错误：' + err);
    }
  }

  /**
   * 功能菜单项点击事件统一处理函数
   * 根据点击的菜单索引执行对应的业务逻辑
   * 
   * @param index - 菜单项索引
   * 0: 粘贴导入 - 解析剪贴板URL获取书源
   * 1: 本地导入 - 打开文件选择器导入书源文件  
   * 2: 书源管理 - 跳转到书源管理页面
   * 3: 导入帮助 - 显示导入帮助对话框
   */
  findBindMenuFunction(index: number) {
    switch (index) {
      case 0:  // 粘贴导入
        this.pasteAnalyze();
        break;
        
      case 1:  // 本地导入
        let context = getContext(this) as common.Context;
        FileHandler.pickerFile(context).then((res: BookSource[]) => {
          this.sourceList = res;      // 保存选择的文件内容
          this.isShowImport = true    // 显示导入对话框
        })
        break;
        
      case 2:  // 书源管理
        router.pushUrl({
          url: 'pages/view/Find/BookSource/Index'
        })
        break;
        
      case 3:  // 导入帮助
        this.isShowHelp = true;
        break;
    }
  }

  /**
   * 帮助对话框构建器
   * 构建底部弹窗形式的帮助对话框
   */
  @Builder
  dialogHelpFuction() {
    Flex() {
      Help({
        btnClick: () => {
          this.isShowHelp = false  // 点击按钮关闭帮助对话框
        }
      })
    }
  }

  /**
   * 导入对话框构建器
   * 构建底部弹窗形式的导入对话框
   */
  @Builder
  dialogImportFunction() {
    Flex() {
      ImportCommon({ 
        sourceList: this.sourceList,    // 传递书源列表数据
        show: this.isShowImport         // 控制对话框显示状态
      })
    }
  }
}
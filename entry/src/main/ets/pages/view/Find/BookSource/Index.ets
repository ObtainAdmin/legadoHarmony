/**
 * 书源管理主页面组件
 * 
 * 功能概述：
 * 1. 提供小说、漫画、有声书三种类型的书源管理
 * 2. 支持粘贴导入、本地导入、新建书源、批量管理等功能
 * 3. 使用Tabs组件切换不同类型书源视图
 * 4. 集成导入帮助和批量导入功能
 * 
 * 页面结构：
 * 1. 顶部Header：包含标题和功能按钮
 * 2. 中间Tabs：切换不同类型书源
 * 3. 底部Sheet：显示帮助和导入对话框
 */
import { common } from '@kit.AbilityKit' // HarmonyOS AbilityKit，提供上下文等能力
import axios, { AxiosResponse } from '@ohos/axios' // HTTP请求库
import Header from '../../../../componets/common/Header' // 公共头部组件
import Help from '../../../../componets/dialog/help' // 帮助对话框组件
import { IconTitleVo } from '../../../../componetsmodel/IconTitleVo' // 图标标题数据模型
import { FileHandler } from '../../../../common/utils/FileHandler' // 文件处理工具
import ImportCommon from '../../../../componets/import/ImportCommon' // 通用导入组件
import { showMessage } from '../../../../componets/common/promptShow'; // 消息提示工具
import SourceView from './components/SourceView' // 书源视图组件
import BookMark from '../../../../componets/head/BookMark' // 书签头部组件
import { getPasteDataSync, isNetworkUrl, sleep } from '../../../../common/utils/utils' // 工具函数
import { router } from '@kit.ArkUI' // 路由管理器
import { BookSource } from '../../../../database/entities/BookSource' // 书源实体类

@Entry // 页面入口装饰器
@Component // 组件装饰器
@Preview // 预览装饰器
struct BookSourcePage {
  /** 标签页标题数组，对应小说、漫画、有声书三种类型 */
  titleArray: Array<string> = ['小说', '漫画', '有声书']
  
  /** 头部右侧对话框功能按钮数据 */
  dialogRightData: IconTitleVo[] = [
    new IconTitleVo($r('app.media.icon_rule_paste'), '粘贴导入'),
    new IconTitleVo($r('app.media.icon_rule_export'), '本地导入'),
    new IconTitleVo($r('app.media.icon_find_shelf'), '新建书源'),
    new IconTitleVo($r('app.media.icon_find_shelf'), '批量管理'),
    new IconTitleVo($r('app.media.icon_rule_help'), '导入帮助')
  ]
  
  /** 当前选中的标签页索引 */
  @State currentIndex: number = 0
  
  /** Tabs控制器，用于控制标签页切换 */
  tabsController: TabsController = new TabsController();
  
  /** 是否显示帮助对话框 */
  @State isShowHelp: boolean = false
  
  /** 是否显示导入对话框，使用@Watch监听变化 */
  @State @Watch('onChange')isShowImport: boolean = false
  
  /** 导入的书源列表 */
  @State sourceList: BookSource[] = []
  
  /** 是否处于批量管理模式 */
  @State isBatch: boolean = false
  
  /** 刷新计数器，用于触发子组件重新渲染 */
  @State refresh: number = 0

  /**
   * 组件即将显示时调用的生命周期方法
   * 可以在此方法中初始化数据或执行页面显示前的准备工作
   */
  aboutToAppear() {
  }

  /**
   * 页面显示时调用的生命周期方法
   * 每次页面显示时增加刷新计数器，触发子组件重新加载数据
   */
  onPageShow() {
    this.refresh += 1
  }

  /**
   * @Watch监听器回调方法
   * 当isShowImport状态变化时触发
   * 如果导入对话框关闭，则增加刷新计数器以更新书源列表
   */
  onChange() {
    if (!this.isShowImport) {
      console.log('TagInfo', '导入对话框关闭，刷新书源列表')
      this.refresh += 1
    }
  }

  /**
   * 粘贴分析功能
   * 从剪贴板获取URL，请求书源数据并显示导入对话框
   * 如果剪贴板为空，则使用默认URL获取书源数据
   */
  async pasteAnalyze() {
    try {
      // 从剪贴板同步获取粘贴的URL
      const url = getPasteDataSync()
      if (!url) {
        showMessage('未获取到粘贴信息，请求默认数据')
        await sleep() // 等待一小段时间
        // 即使没有URL也继续执行，使用默认URL
      }
      // 注释掉的URL验证逻辑
      // if (!isNetworkUrl(url ?? '')) {
      //   showMessage('复制的链接不正确')
      //   return
      // }
      
      // 请求书源数据，如果url为空则使用默认URL
      const res: AxiosResponse = await axios
        .get(url ?? 'https://node.wisdoms.xin/static/file/20240704/sy.json');
      this.sourceList = res.data; // 保存获取的书源列表
      this.isShowImport = true; // 显示导入对话框
    } catch (err) {
      console.error('错误 ' + err);
    }
  }

  /**
   * 组件构建方法
   * 构建页面的UI结构，包括头部、标签页和对话框
   */
  build() {
    Column() {
      // 公共头部、搜索框区域
      Column() {
        // 非批量管理模式下显示Header
        if (!this.isBatch) {
          Header({
            customTitleBuilder: () => {
              // 自定义标题构建器，显示标签页切换按钮
              this.titleBuilder(this.tabsController)
            },
            dialogRightData: this.dialogRightData, // 右侧功能按钮数据
            dialogRightChange: (index: number) => {
              // 右侧功能按钮点击事件处理
              switch (index) {
                case 0: // 粘贴导入
                  this.pasteAnalyze()
                  break;
                case 1: // 本地导入
                  let context = getContext(this) as common.Context;
                  FileHandler.pickerFile(context)
                    .then((res: BookSource[]) => {
                      this.sourceList = res; // 保存选择的文件内容
                      this.isShowImport = true // 显示导入对话框
                    })
                  break;
                case 2: // 新建书源
                  router.pushUrl({ url: 'pages/view/Find/BookSource/AddSourcePage' })
                  break;
                case 3: // 批量管理
                  this.isBatch = true // 进入批量管理模式
                  break;
                case 4: // 导入帮助
                  this.isShowHelp = true; // 显示帮助对话框
                  break;
              }
            }
          })
        }
      }

      // 头部卡片下方的主视图区域 - 标签页
      Tabs({
        barPosition: BarPosition.Start, // 标签栏位置在顶部
        controller: this.tabsController // 标签页控制器
      }) {
        // 遍历标题数组，为每个类型创建标签页
        ForEach(this.titleArray, (item: string, index: number) => {
          TabContent() {
            // 每个标签页内嵌SourceView组件，传递相关参数
            SourceView({ index, isBatch: this.isBatch, refresh: this.refresh })
          }
          .align(Alignment.Top) // 顶部对齐
        })
      }
      .layoutWeight(1) // 占据剩余空间
      .barWidth(0) // 隐藏标签栏宽度
      .barHeight(0) // 隐藏标签栏高度
      .onChange((index) => {
        // 标签页切换事件
        this.tabsController.changeIndex(index) // 更新控制器索引
        this.currentIndex = index // 更新当前索引
      })
      .scrollable(this.isBatch ? false : true) // 批量管理时禁用滚动

      // 帮助对话框 - 使用底部弹窗形式
      Flex()
        .bindSheet(this.isShowHelp, this.dialogHelpFuction(), {
          height: '50%', // 对话框高度为50%
          showClose: false, // 不显示关闭按钮
          dragBar: false, // 不显示拖拽条
          onDisappear: () => {
            this.isShowHelp = false // 对话框消失时重置状态
          }
        })
      
      // 导入对话框 - 使用底部弹窗形式
      Flex()
        .bindSheet(this.isShowImport, this.dialogImportFunction(), {
          detents: [SheetSize.FIT_CONTENT, SheetSize.LARGE, 200], // 可停靠的高度
          dragBar: true, // 显示拖拽条
          showClose: false, // 不显示关闭按钮
          onDisappear: () => {
            this.isShowImport = false // 对话框消失时重置状态
          }
        })
    }
    .backgroundColor('#f5f5f5')
  }

  /**
   * 标题构建器方法
   * 构建Header中的标签页切换按钮
   * @param tabsController - Tabs控制器，用于切换标签页
   */
  @Builder
  titleBuilder(tabsController: TabsController) {
    List() {
      // 小说标签按钮
      ListItem() {
        BookMark({
          title: '小说',
          index: 0,
          currentIndex: this.currentIndex,
          isBackground: false
        }).onClick(() => {
          this.currentIndex = 0
          tabsController.changeIndex(0) // 切换到第一个标签页
          console.log('切换到小说标签页，当前索引：' + this.currentIndex)
        })
      }

      // 漫画标签按钮
      ListItem() {
        BookMark({
          title: '漫画',
          index: 1,
          currentIndex: this.currentIndex,
          isBackground: false
        }).onClick(() => {
          this.currentIndex = 1
          tabsController.changeIndex(1) // 切换到第二个标签页
          console.log('切换到漫画标签页，当前索引：' + this.currentIndex)
        })
      }

      // 有声书标签按钮
      ListItem() {
        BookMark({
          title: '有声书',
          index: 2,
          currentIndex: this.currentIndex,
          isBackground: false
        }).onClick(() => {
          this.currentIndex = 2
          tabsController.changeIndex(2) // 切换到第三个标签页
          console.log('切换到有声书标签页，当前索引：' + this.currentIndex)
        })
      }
    }
    .height(40) // 列表高度
    .scrollBar(BarState.Off) // 关闭滚动条
    .listDirection(Axis.Horizontal) // 水平方向排列
  }

  /**
   * 帮助对话框构建器方法
   * 构建帮助对话框的内容
   */
  @Builder
  dialogHelpFuction() {
    Flex() {
      Help({
        btnClick: () => {
          this.isShowHelp = false // 点击按钮关闭帮助对话框
        }
      })
    }
  }

  /**
   * 导入对话框构建器方法
   * 构建导入对话框的内容
   */
  @Builder
  dialogImportFunction() {
    Flex() {
      ImportCommon({
        sourceList: this.sourceList, // 传递书源列表数据
        show: this.isShowImport // 控制对话框显示状态
      })
    }
  }
}

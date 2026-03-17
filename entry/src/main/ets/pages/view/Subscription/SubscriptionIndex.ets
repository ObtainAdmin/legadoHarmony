/**
 * @author 2008
 * @datetime 2024/7/11 21:33
 * @className: Subscription
 * 新版订阅页面
 * 
 * =====================================================
 * 模块功能说明：
 * 本文件是RSS订阅管理的主页面，负责显示订阅源列表、分组管理、批量编辑等功能。
 * 支持从剪贴板导入、本地JSON文件导入、新建订阅、批量删除等操作。
 * =====================================================
 */

import CommonConstants from '../../../common/constants/CommonConstants'
import ImageConstants from '../../../common/constants/ImageConstants'
import PaddingConstants from '../../../common/constants/PaddingConstants'
import { IconTitleVo } from '../../../componetsmodel/IconTitleVo'
import { router } from '@kit.ArkUI'
import SubscriptionContent from './components/SubscriptionContent'
import { showMessage } from '../../../componets/common/promptShow'
import { getPasteDataSync, isNetworkUrl, sleep } from '../../../common/utils/utils'
import axios, { AxiosResponse } from '@ohos/axios'
import { rssGroupList, rssSources } from '../../../database/entities/rssSources'
import SubscriptionImport from '../../../componets/import/SubscriptionImport'
import subscriptionDao from '../../../database/dao/SubscriptionDao'
import dialogNewSources from './RssSources/dialogNewSources'
import RssSourcesHistory from './components/RssSourcesHistory'
import rssSourcesHistoryDao from '../../../database/dao/RssSourcesHistoryDao'
import { rssSourcesHistory } from '../../../database/entities/rssSourcesHistory'
import { FileHandler } from 'ets/common/utils/FileHandler'
import { ThemeItem } from '../../../common/model/Theme'
import { ThemeStorageKey } from '../../../common/constants/Theme'
import addBookTypeDialog from '../../../componets/common/addBookTypeDialog'
import rssSourcesUtils from '../../../common/utils/rssSourcesUtils'
import dialogTitleFuction from '../../../componets/common/dialogTitleFuction'

/**
 * SubscriptionIndex 主组件
 * 功能：RSS订阅主页面的核心组件，管理订阅源列表、分组、批量编辑等交互
 */
@Component
export default struct SubscriptionIndex {
  
  // ==================== 状态变量 (State) ====================
  // 控制导入对话框的显示/隐藏
  @State isShowImport: boolean = false
  @State isShowNewSources: boolean = false
  // 当前Tab页索引，监听变化时触发刷新
  @Prop @Watch('currentTabIndexChange') currentTabIndex: number
  
  // 顶部安全区域高度，用于适配异形屏
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  // RSS订阅源刷新状态，存储键值联动，刷新时自动调用getList
  @StorageLink(CommonConstants.RSS_SOURCES_REFRESHING) @Watch('getList') refreshing: number = 0
  
  // 更多菜单选项列表，包含：粘贴导入、本地导入、新建订阅、批量管理
  private moreList: IconTitleVo[] = [
    new IconTitleVo($r('app.media.icon_rule_paste'), '粘贴导入'),
    new IconTitleVo($r('app.media.icon_rule_export'), '本地导入'),
    new IconTitleVo($r('app.media.icon_rule_add'), '新建订阅'),
    new IconTitleVo($r('app.media.icon_rule_batch'), '批量管理'),
  ]
  
  // 批量管理选中状态存储，key为订阅源ID，value为是否选中
  // 使用@Provide让子组件可以访问批量选择状态
  @Provide('batchList') batchList: Record<number, boolean> = {}
  
  // 最近使用的订阅源历史记录
  @State RecentlyUsed: rssSourcesHistory[] = []
  // 加载状态标志
  @State loading: boolean = false
  
  // 导入对话框中显示的订阅源列表（用于选择要导入的订阅）
  @State subscriptionList: rssSources[] = []
  
  // 原始订阅源列表（从数据库查询得到的全部订阅）
  @State rssSourcesList: rssSources[] = []
  
  // 分组后的订阅源列表，按sourceGroup字段分组
  @State groupList: rssGroupList[] = []
  
  // 是否处于批量编辑模式
  @State batchEdit: boolean = false
  
  // 新建分组时的分组类型/名称
  @State newGroupType: string = ''
  
  // 批量编辑模式下的全选状态
  @Provide('batchAll') batchAll: boolean = false
  
  // 主题颜色配置（从主题存储中获取）
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  // ==================== 公共方法 ====================
  /**
   * 刷新方法：重置状态并重新加载数据
   * 1. 清空当前列表数据
   * 2. 重新获取订阅源列表
   * 3. 延迟获取最近使用历史
   */
  refresh = () => {
    this.resetState()
    this.getList()
    setTimeout(() => {
      rssSourcesHistoryDao.search().then((rssSourcesHistoryList: rssSourcesHistory[]) => {
        this.RecentlyUsed = rssSourcesHistoryList
      })
    }, 100)
  }

  /**
   * Tab切换时的回调方法
   * 当用户切换到当前Tab时，自动刷新数据
   */
  currentTabIndexChange() {
    this.refresh()
  }

  /**
   * 重置状态方法
   * 清空订阅源列表和分组列表，为重新加载做准备
   */
  resetState() {
    this.subscriptionList = []
    this.groupList = []
  }

  /**
   * 获取订阅源列表
   * 1. 从数据库查询所有订阅源
   * 2. 构建批量选择状态映射（每个订阅源ID默认未选中）
   * 3. 根据分组获取分组后的列表
   */
  getList() {
    subscriptionDao.search().then(data => {
      const rssSources = data ?? []
      console.info('TagInfo', JSON.stringify(rssSources.slice(0, 3)))
      this.rssSourcesList = rssSources
      //将rssSources的id存放进batchList值默认为false
      rssSources.forEach((item: rssSources) => {
        if (item.id) {
          this.batchList[item.id] = false
        }
      })
      this.getGroupList()
    }).catch(() => {

    })
  }

  /**
   * 获取分组列表
   * 将订阅源按sourceGroup字段进行分组，生成Map结构后转为数组
   * 相同group的订阅源会被归到同一个组中
   */
  /**
   * 获取分组列表 - 将订阅源按sourceGroup分组
   * 1. 遍历所有订阅源，提取sourceGroup字段作为分组依据
   * 2. 创建groupMap字典，每个分组维护一个list数组
   * 3. 最后将字典转换为数组赋值给groupList
   */
  getGroupList() {
    const groupMap: Record<string, rssGroupList> = {};
    this.rssSourcesList.forEach((item: rssSources) => {
      const title = item.sourceGroup;
      if (title) {
        // 如果groupMap中还没有这个group，则创建一个新的GroupList对象
        if (!groupMap[title]) {
          groupMap[title] = { title: title, list: [] };
        }
        // 向当前group的list中添加rssSources对象
        groupMap[title].list.push(item);
      }

    })
    this.groupList = Object.values(groupMap)
  }

  // ==================== 界面构建方法 ====================
  /**
   * build() - 主界面构建
   * 
   * 包含以下主要区域：
   * 1. 顶部搜索栏：支持搜索订阅源、批量编辑、全选/取消全选
   * 2. 分组列表区：显示按分组排列的订阅源
   * 3. 底部导入按钮：提供导入新订阅的入口
   * 
   * 条件渲染逻辑：
   * - batchEdit为true时显示批量编辑界面（全选、完成按钮）
   * - batchEdit为false时显示普通搜索界面
   */
  build() {
    Column() {
      Column() {
        //搜索Start
        Flex(
          {
            direction: FlexDirection.Row,
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceBetween
          }
        ) {
          Row({
            space: CommonConstants.SPACE_16
          }) {
            if (this.batchEdit === false) {
              Image($r('app.media.icon_subscription_index'))
                .width(CommonConstants.COMMON_WIDTH_45_36)
                .height(CommonConstants.COMMON_HEIGHT_21_6)
              Search({ placeholder: '搜索订阅', icon: "/common/images/search.svg" })
                .layoutWeight(1)
                .height(CommonConstants.COMMON_HEIGHT_40)
                .backgroundColor(Color.White)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/view/Subscription/components/SubscriptionSearch'
                  })
                })
                .focusOnTouch(false) //不可获取焦点

              Image($r('app.media.addSubscription'))
                .width(ImageConstants.IMG_WIDTH_24)
                .height(ImageConstants.IMG_HEIGHT_24)
                .bindMenu(this.MenuBuilder)
            } else {
              Text(`${this.batchAll ? '取消全选' : '全选'}`)
                .width('33%')
                .onClick(() => {
                  this.batchAll = !this.batchAll
                  Object.keys(this.batchList).forEach((key: string) => {
                    this.batchList[key] = this.batchAll
                  })
                })
              Blank(1)
              //获取选中项数量
              Text(`已选${Object.values(this.batchList).filter(value => value === true).length}项`).width('33%')
              Blank(1)
              Text('完成')
                .width('33%')
                .onClick(() => {
                  this.batchAll = false
                  this.batchEdit = false
                  Object.keys(this.batchList).forEach((key: string) => {
                    this.batchList[key] = false
                  })
                  getContext(this).eventHub.emit('SubscriptionBatchEdit', true);
                })
            }
          }
          .width('100%')
        }
        .height('8%')

        //搜索End
        //最近使用Start
        if (this.batchEdit === false) {
          RssSourcesHistory({
            RecentlyUsed: this.RecentlyUsed
          })
        }

        if (this.loading) {
          Column() {
            LoadingProgress()
              .color(this.theme.mainColor)
              .width('50%')
            Text('加载中...')
          }
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
        } else if (!this.groupList.length) {
          SubscriptionContent({
            subscriptionTitle: '收藏',
            batchEdit: this.batchEdit,
            showAddDialog: () => {
              this.isShowNewSources = true
            }
          })
        } else {
          Scroll() {
            Column() {
              ForEach(this.groupList, (item: rssGroupList) => {
                SubscriptionContent({
                  subscriptionTitle: item.title,
                  contentList: item.list,
                  batchEdit: this.batchEdit,
                  refresh: this.refresh
                })
              })
            }
          }
          .align(Alignment.Top)
          .padding({ bottom: 20 })
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Vertical)
        }
        Blank(1)
      }
      .padding({
        top: this.topRectHeight,
        left: PaddingConstants.PADDING_20,
        right: PaddingConstants.PADDING_20
      })
      .layoutWeight(1)

      if (this.batchEdit) {
        Grid() {
          GridItem() {
            Column({ space: 4 }) {
              Image($r('app.media.folder'))
                .height(24)
                .fillColor(Color.Black) // 黑色好像渲染不上去

              Text("移动至")
                .fontSize(10)
                .lineHeight(18)
                .fontColor('rgba(0, 0, 0, 0.88)')
            }
            .onClick(() => {
              showMessage('功能开发中,暂未开放')
            })
          }

          GridItem() {
            Column({ space: 4 }) {
              Image($r('app.media.edit_share'))
                .height(24)

              Text("分享")
                .fontSize(10)
                .lineHeight(18)
                .fontColor('rgba(0, 0, 0, 0.88)')
            }
            .onClick(() => {
              showMessage('功能开发中,暂未开放')
            })
          }

          GridItem() {
            Column({ space: 4 }) {
              Image($r('app.media.export_1'))
                .height(24)

              Text("导出")
                .fontSize(10)
                .lineHeight(18)
                .fontColor('rgba(0, 0, 0, 0.88)')
            }
            .onClick(() => {
              showMessage('功能开发中,暂未开放')
            })
          }

          GridItem() {
            Column({ space: 4 }) {
              Image($r('app.media.delete'))
                .height(24)

              Text("删除")
                .fontSize(10)
                .lineHeight(18)
                .fontColor('rgba(0, 0, 0, 0.88)')
            }
            .onClick(() => {
              let checkRssSources = Object.values(this.batchList).filter(value => value === true).length
              if (checkRssSources <= 0) {
                showMessage('请选择要删除的订阅源');
                return;
              }

              Object.keys(this.batchList).forEach((key: string) => {
                if (this.batchList[key]) {
                  subscriptionDao.deleteRssSourcesById({
                    id: Number(key)
                  })
                  this.batchList[key] = false
                }
              })
              setTimeout(() => {
                this.refresh()
              }, 200)
              showMessage('删除成功!')
            })
          }
        }
        .height(68)
        .width("100%")
        .columnsTemplate("1fr 1fr 1fr 1fr")
        .backgroundColor('white')
        .padding({
          top: 12,
          bottom: 10
        })
      }

      Flex()
        .bindSheet($$this.isShowImport, this.dialogImportFunction(), {
          detents: [SheetSize.FIT_CONTENT, SheetSize.LARGE, 200],
          dragBar: true,
          showClose: false,
          onDisappear: () => {
            this.isShowImport = false
          }
        })

      Flex()
        .bindSheet($$this.isShowNewSources, this.dialogNewSourcesFunction(), {
          height: 200,
          dragBar: true,
          showClose: false,
          onDisappear: () => {
            this.isShowNewSources = false
          }
        })
    }
    .linearGradient({
      direction: GradientDirection.Bottom, // 渐变方向
      colors: [[this.theme.mainColor, 0], [this.theme.secondColor, 0.2]] // 数组末尾元素占比小于1时满足重复着色效果
    })
    .height('100%')
  }

  @Builder
  dialogImportFunction() {
    Flex() {
      SubscriptionImport({
        subscriptionList: this.subscriptionList
      , show: this.isShowImport
      }).onDisAppear(() => {
        this.refresh()
      })
    }
  }

  @Builder
  dialogNewSourcesFunction() {
    Column() {
      dialogNewSources({
        btnClick: () => {
          this.isShowNewSources = false
        }
      }).onDisAppear(() => {
        this.refresh()
      })

    }
  }

  @Builder
  MenuBuilder() {
    Column() {
      ForEach(this.moreList, (item: IconTitleVo, index) => {
        dialogTitleFuction({
          title: item.title,
          icon: item.icon,
          isBorder: this.moreList.length !== index + 1
        })
          .onClick(() => {
            this.MenuOnclick(index)
          })
      })
    }
  }

  async MenuOnclick(value: number | string) {
    switch (value) {
      case 0:
        // 粘贴导入
        this.pasteAnalyze();
        break;
      case 1:
        // 本地导入
        showMessage('请选择本地json文件导入')
        this.localImport()
        break
      case 2:
        this.isShowNewSources = true
        break;
      case 3:
        this.batchEdit = true
        getContext(this).eventHub.emit('SubscriptionBatchEdit', false);
        break
    }
  }

  async localImport() {
    let FileResult = await FileHandler.documentPickerFile(1, ['.json'])
    FileHandler.ReadJSONFile(FileResult[0]).then(result => {
      // console.log('result:' + result)
      this.subscriptionList = JSON.parse(result) as rssSources[]
      this.isShowImport = true;
    })
  }

  async pasteAnalyze() {
    try {
      let url = getPasteDataSync()
      if (!url) {
        showMessage('未获取到粘贴信息，请求默认数据')
        await sleep()
        // return
      }
      if (!isNetworkUrl(url ?? '')) {
        showMessage('复制的链接不正确')
        await sleep()
        url = undefined
        // return
      }
      const res: AxiosResponse = await axios
        .get(url ?? 'http://yuedu.miaogongzi.net/shuyuan/miaogongziDY.json');
      console.log('res', JSON.stringify(res))
      this.subscriptionList = res.data;
      this.isShowImport = true;
    } catch (err) {
      console.error('错误 ' + err);
    }
  }
}
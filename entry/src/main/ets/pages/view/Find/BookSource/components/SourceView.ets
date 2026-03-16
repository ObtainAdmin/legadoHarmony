/**
 * 书源视图组件
 * 
 * 书源管理页面的主视图组件，负责显示和管理所有书源
 * 主要功能：
 * 1. 显示书源列表，支持按分组分类显示
 * 2. 提供搜索、筛选、排序功能
 * 3. 支持批量操作（启用/禁用、删除、移动分组、评分等）
 * 4. 支持长按进入批量管理模式
 * 5. 显示书源详细信息（名称、评分、更新时间、状态等）
 * 
 * @Component 声明为ArkUI组件
 * @default 默认导出
 */

// 网络请求库，用于调试功能
import axios, { AxiosError, AxiosResponse } from '@ohos/axios'
// 日期处理库
import dayjs from 'dayjs'
// 侧边栏组件，用于显示分组导航
import SideBar from '../../../../../componets/common/SideBar'
// 对话框标题功能组件
import dialogTitleFuction from '../../../../../componets/common/dialogTitleFuction'
// 头部组件
import Header from '../../../../../componets/common/Header'
// 消息提示工具函数
import { showMessage } from '../../../../../componets/common/promptShow'
// 评分显示组件
import Score from '../../../../../componets/common/Score'
// 标签组件
import Tag from '../../../../../componets/common/Tag'
// 图标标题数据模型
import { IconTitleVo } from '../../../../../componetsmodel/IconTitleVo'
// ArkUI框架组件
import { CustomContentDialog, router } from '@kit.ArkUI'
// 书源数据访问对象
import BookSourceDao from '../../../../../database/dao/BookSourceDao'
// 书源分组相关类型和常量
import { GroupPartList, SOURCE_GROUP_MAP } from '../../../../../database/entities/BookSource'
// 书源部分数据实体
import { BookSourcePart } from '../../../../../database/entities/BookSourcePart'
// JSON处理工具
import { JSON } from '@kit.ArkTS'
// 源分组组件
import SourceGroup from '../../../../../componets/ui/SourceGroup'
// 书源搜索参数类型
import { BookSourceSearchParams } from '../../../../../database/types/BookSourceType'
// 筛选选项组件
import FiltrateOption from './FiltrateOption'
// 筛选文本组件
import FilterText from './FilterText'
// 主题相关类型和常量
import { ThemeItem } from '../../../../../common/model/Theme'
import { ThemeStorageKey } from '../../../../../common/constants/Theme'

@Component
export default struct SourceView {
  /** 书源类型标题数组：小说、漫画、有声书 */
  titleArray: Array<string> = ['小说', '漫画', '有声书']
  
  /** 当前选中的书源类型索引 */
  index: number = 0
  
  /** 书源文件路径，从应用存储中获取 */
  @StorageProp('pathBookSource') pathBookSource: string = ''
  
  /** 顶部安全区域高度，跨组件共享 */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 底部安全区域高度，跨组件共享 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 当前选中的分组索引 */
  @State currentIndex: number = 0
  
  /** 批量选择映射表：书源URL -> 是否选中 */
  @State activeNameMap: Record<string, boolean> = {}
  
  /** 是否全选状态（已弃用，保留兼容性） */
  @State fullActive: boolean = false
  
  /** 分组后的书源列表 */
  @State groupList: GroupPartList[] = []
  
  /** 原始书源列表数据 */
  @State sourceList: BookSourcePart[] = []
  
  /** 搜索关键词 */
  @State searchValue: string = ''
  
  /** 书源详情展开状态映射表：书源URL -> 是否展开详情 */
  @State clickNameMap: Record<string, boolean> = {}
  
  /** 书源启用状态映射表（已弃用，保留兼容性） */
  @State enabledMap: Record<string, boolean> = {}
  
  /** 是否处于批量管理模式，从父组件传入 */
  @Link isBatch: boolean
  
  /** 数据加载状态 */
  @State loading: boolean = true
  
  /** 错误提示文本 */
  @State errorText: string = ''
  
  /** 右侧菜单显示状态映射表：书源URL -> 是否显示菜单 */
  @State showRightDialogMap: Record<string, boolean> = {}
  
  /** 更多菜单显示状态 */
  @State showMoreDialog: boolean = false
  
  /** 批量操作中启用/禁用开关状态 */
  @State toggleAll: boolean = true
  
  /** 刷新触发器，变化时自动调用getList方法 */
  @Link @Watch('getList') refresh: number
  
  /** 侧边栏滚动控制器 */
  private scroll: Scroller = new Scroller()
  
  /** 主内容区滚动控制器 */
  private secondScroll = new Scroller()
  
  /** 对话框中的书源数据（用于评分等操作） */
  @State dialogItem: Partial<BookSourcePart> = {}
  
  /** 刷新计数器，用于触发重新渲染 */
  @StorageLink('refreshCount') refreshCount: number = 0
  
  /** 是否显示分组选择弹窗 */
  @State isShowGroup: boolean = false
  
  /** 当前展开的筛选条件标题索引（-1表示无展开） */
  @State currentTitle: number = -1
  
  /** 筛选查询参数 */
  @State query: BookSourceSearchParams = {
    enabled: undefined,        // 启用状态筛选
    bookSourceGrade: undefined, // 书源等级筛选
    order: undefined,          // 排序方式
    hasLoginUrl: undefined     // 是否有登录URL
  }
  
  /** 主题颜色配置，从应用存储中获取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /** 书源评分对话框控制器，用于显示和操作评分对话框 */
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '书源评分',  // 对话框主标题
      contentAreaPadding: {      // 内容区域内边距
        left: 10,
        top: 10,
        right: 10,
        bottom: 10
      },
      contentBuilder: () => {    // 对话框内容构建器
        this.buildContent();
      },
      buttons: [                 // 对话框按钮配置
        {
          value: '取消',         // 取消按钮
          background: this.theme.secondColor,
          fontColor: this.theme.mainColor,
          action: () => {        // 取消按钮点击动作
            this.dialogItem = {}
            this.dialogController.close()
          }
        },
        {
          value: '确认',         // 确认按钮
          background: 'this.theme.mainColor',
          fontColor: '#FFFFFF',
          action: async () => {  // 确认按钮点击动作
            if (this.isBatch) {
              // 批量操作：更新所有选中的书源
              const sourceList: BookSourcePart[] = []
              this.sourceList.forEach((item, i) => {
                if (this.activeNameMap[item.bookSourceUrl]) {
                  item.bookSourceGrade = this.dialogItem.bookSourceGrade
                  item.bookSourceScore = this.dialogItem.bookSourceScore
                  sourceList.push(item)
                }
              })
              await BookSourceDao.batchUpdateFlow(sourceList)
              this.getList()
              this.activeNameMap = {}
              this.dialogController.close()
              this.dialogItem = {}
              return
            }
            // 单个操作：更新当前书源
            await BookSourceDao.updateFlow(this.dialogItem as BookSourcePart)
            this.getList()
            this.dialogItem = {}
            this.dialogController.close()
          }
        }
      ],
      theme: {                   // 对话框主题配置
        colors: {
          confirm: this.theme.mainColor
        }
      }
    }),
  });

  /**
   * 组件即将显示时调用的生命周期方法
   * 
   * 功能：
   * 1. 设置加载状态为true
   * 2. 调用getList()方法加载书源数据
   */
  aboutToAppear() {
    console.info('TagInfo', '当前下标： ' + this.index)
    this.loading = true
    this.getList()
  }

  /**
   * 组件即将消失时调用的生命周期方法
   * 
   * 功能：
   * 1. 清空搜索关键词
   */
  aboutToDisappear(): void {
    this.searchValue = ''
  }

  /**
   * 获取书源列表数据
   * 
   * 功能：
   * 1. 增加刷新计数器，触发重新渲染
   * 2. 调用BookSourceDao.flowSearch()查询书源数据
   * 3. 处理查询结果，更新sourceList和groupList
   * 4. 设置加载状态和错误提示
   */
  getList() {
    this.refreshCount += 1
    BookSourceDao.flowSearch({
      type: [0, 2, 1][this.index],  // 书源类型映射：0=小说，2=漫画，1=有声书
      searchKey: this.searchValue,   // 搜索关键词
      enabled: this.query.enabled,   // 启用状态筛选
      bookSourceGrade: this.query.bookSourceGrade, // 书源等级筛选
      order: this.query.order,       // 排序方式
      hasLoginUrl: this.query.hasLoginUrl // 是否有登录URL
    }).then(data => {
      const bookSource = data ?? []
      console.info('TagInfo', JSON.stringify(bookSource.slice(0, 3)))
      this.sourceList = bookSource
      this.getGroupList()  // 重新分组
      this.loading = false
      console.info('TagInfo', '数量 ' + this.sourceList.length)
      if (!this.sourceList.length) {
        this.errorText = `当前${this.titleArray[this.index]}还没有添加源`
      }
    })
  }

  /**
   * 将书源列表按分组进行归类
   * 
   * 功能：
   * 1. 遍历所有书源，按bookSourceGroup字段进行分组
   * 2. 过滤掉不包含搜索关键词的书源
   * 3. 构建groupMap对象，key为分组名称，value为分组数据
   * 4. 将groupMap转换为数组赋值给groupList
   */
  getGroupList() {
    const groupMap: Record<string, GroupPartList> = {};
    this.sourceList.forEach((item: BookSourcePart) => {
      const title = item.bookSourceGroup;
      const bookSourceName = item.bookSourceName;
      if (bookSourceName.indexOf(this.searchValue) === -1) {
        return
      }
      if (!title) {
        return
      }
      // 如果groupMap中还没有这个group，则创建一个新的GroupList对象
      if (!groupMap[title]) {
        groupMap[title] = { title: title, list: [] };
      }
      // 向当前group的list中添加BookSource对象
      groupMap[title].list.push(item);
    })
    this.groupList = Object.values(groupMap);
  }

  /**
   * 处理滚动位置变化事件
   * 
   * @param start 新的分组索引
   * @param flg 滚动来源标志：false表示侧边栏滚动，true表示主内容区滚动
   * 
   * 功能：
   * 1. 如果当前索引与新的索引不同，更新currentIndex
   * 2. 根据flg标志决定滚动哪个滚动控制器
   */
  scrollChangeAction(start: number, flg: Boolean) {
    if (this.currentIndex !== start) {
      this.currentIndex = start;
      if (!flg) {
        this.scroll.scrollToIndex(start);  // 滚动侧边栏
      } else {
        this.secondScroll.scrollToIndex(start);  // 滚动主内容区
      }
    }
  }

  build() {
    Stack() {
      // 头部区域
      Column() {
        // 搜索框
        Column() {
          Search({
            value: this.searchValue,
            placeholder: `搜索${this.titleArray[this.index]}`,
            icon: "/common/images/search.svg"
          })
            .width("100%")
            .height(40)
            .backgroundColor(Color.White)
            .onChange((value: string) => {
              this.searchValue = value
              this.getList()
            })
        }
        .padding({
          left: 20,
          right: 20,
          top: 8,
        })

        // 筛选器
        Row() {
          FilterText({
            index: 0,
            title: this.query.enabled === undefined ? '全部' : (this.query.enabled ? '启用' : '禁用'),
            hasActive: this.query.enabled !== undefined,
            onChange: (index) => {
              if (this.currentTitle === index) {
                this.currentTitle = -1
                return
              }
              this.currentTitle = index
            }
          })

          Row().width(12)
          FilterText({
            index: 1,
            title: this.query.order === undefined ? '排序' : ['按评分', '按时间'][this.query.order],
            hasActive: this.query.order !== undefined,
            onChange: (index) => {
              if (this.currentTitle === index) {
                this.currentTitle = -1
                return
              }
              this.currentTitle = index
            }
          })

          Row().width(12)
          FilterText({
            index: 2,
            title: '校验',
            hasActive: this.query.verify !== undefined,
            onChange: (index) => {
              showMessage('校验，开发中')
            }
          })

          Row().width(12)
          FilterText({
            index: 3,
            title: this.query.bookSourceGrade === undefined ? '等级' :
            ['常规', '优质', '精品'][this.query.bookSourceGrade],
            hasActive: this.query.bookSourceGrade !== undefined,
            onChange: (index) => {
              if (this.currentTitle === index) {
                this.currentTitle = -1
                return
              }
              this.currentTitle = index
            }
          })

          Row().width(12)
          FilterText({
            index: 4,
            title: '登录',
            hasActive: this.query.hasLoginUrl !== undefined,
            isIcon: false,
            onChange: () => {
              if (this.query.hasLoginUrl) {
                this.query.hasLoginUrl = undefined
              } else {
                this.query.hasLoginUrl = true
              }
              this.getList()
            }
          })
        }
        .padding({
          left: 20,
          right: 20,
          top: 12,
          bottom: 12
        })
        .width('100%')
        .height(50)
      }
      .backgroundColor('#f5f5f5')
      .height(122)
      .translate({ y: !this.isBatch ? 0 : -122 - this.topRectHeight })
      .zIndex(99)
      .animation({
        duration: 700
      })

      // 批量操作头部内容
      Header({
        customLeftBuilder: () => {
          this.selectAll()
        },
        title: `已选${Object.values(this.activeNameMap).filter(o => o).length}项`,
        customRightBuilder: () => {
          this.complete()
        }
      })
        .backgroundColor('#f5f5f5')
        .translate({ y: this.isBatch ? 0 : -50 - this.topRectHeight })
        .zIndex(99)
        .animation({
          duration: this.isBatch ? 300 : 0,
          delay: this.isBatch ? 300 : 0
        })

      Stack() {
        Column() {
          Stack() {
            Column() {
            }
            .backgroundColor('#99000000')
            .width('100%')
            .height('100%')
            .opacity(this.currentTitle !== -1 ? 1 : 0)
            .animation({
              duration: this.currentTitle !== -1 ? 300 : 0
            })

            Row() {
              if (this.currentTitle === 0) {
                FiltrateOption({
                  options: [
                    {
                      label: '全部',
                      value: undefined
                    },
                    {
                      label: '启用',
                      value: true
                    },
                    {
                      label: '禁用',
                      value: false
                    }
                  ],
                  value: this.query.enabled,
                  onChange: (value) => {
                    this.query.enabled = value as boolean
                    this.getList()
                    setTimeout(() => {
                      this.currentTitle = -1
                    }, 200)
                  }
                })
              }
              if (this.currentTitle === 1) {
                FiltrateOption({
                  options: [
                    {
                      label: '按评分排序',
                      value: 0
                    },
                    {
                      label: '按时间排序',
                      value: 1
                    }
                  ],
                  columns: 2,
                  isAgain: true,
                  value: this.query.order,
                  onChange: (value) => {
                    this.query.order = value as number
                    this.getList()
                    setTimeout(() => {
                      this.currentTitle = -1
                    }, 200)
                  }
                })
              }
              if (this.currentTitle === 3) {
                FiltrateOption({
                  options: [
                    {
                      label: '全部',
                      value: undefined
                    },
                    {
                      label: '精选',
                      value: 2
                    },
                    {
                      label: '优质',
                      value: 1
                    },
                    {
                      label: '常规',
                      value: 0
                    }
                  ],
                  columns: 4,
                  value: this.query.bookSourceGrade,
                  onChange: (value) => {
                    this.query.bookSourceGrade = value as number
                    this.getList()
                    setTimeout(() => {
                      this.currentTitle = -1
                    }, 200)
                  }
                })
              }
            }
            .height([0, 1, 3].includes(this.currentTitle) ? 64 : 0)
            .backgroundColor('#f5f5f5')
            .padding({ left: 20, right: 20, bottom: 8 })
            .borderRadius({
              bottomLeft: 8,
              bottomRight: 8
            })
            .translate({ y: this.currentTitle !== -1 ? 0 : -64 })
            .width('100%')
            .animation({
              duration: this.currentTitle !== -1 ? 300 : 0
            })
          }
          .width('100%')
          .height('100%')
          .alignContent(Alignment.Top)
        }
        .width('100%')
        .height('100%')
        .padding({ top: 122 })
        .zIndex(this.currentTitle !== -1 ? 99 : -1)
        .onClick(() => {
          this.currentTitle = -1
        })

        Column() {
          // 内容主体
          Row({ space: 12 }) {
            SideBar({
              currentIndex: this.currentIndex,
              sideBarList: this.groupList,
              scroller: this.scroll,
              clickAction: (index: number) => {
                this.scrollChangeAction(index, true)
              },
              isBadge: !this.isBatch,
              isDrag: this.isBatch,
              onDragChange: async (list) => {
                this.groupList = list as GroupPartList[]
                const bookSourcePartList =
                  this.groupList.reduce((acc: BookSourcePart[], item) => acc.concat(item.list), [])
                const sortBookSourcePartList = bookSourcePartList.map((item, index) => {
                  if (index !== 0) {
                    item.customOrder = bookSourcePartList[index - 1].customOrder + 1
                  }
                  return item
                })
                console.info('TagInfo bookSourcePartList:', JSON.stringify(bookSourcePartList))
                await BookSourceDao.batchUpdateFlow(sortBookSourcePartList)
                this.refreshCount += 1
              }
            })
              .width(88)

            List({ scroller: this.secondScroll }) {
              ForEach(this.groupList, (item: GroupPartList, index: number) => {
                ListItemGroup({
                  header: this.classifyHeader(`${item.title} (${item.list.length})`, index),
                  space: 0
                }) {
                  ForEach(item.list, (bookSource: BookSourcePart, j: number) => {
                    this.CourseItem(bookSource, index, j)
                  })
                }
              })
            }
            .padding({ right: 20 })
            .sticky(StickyStyle.Header)
            .onScrollIndex((start) => {
              this.scrollChangeAction(start, false)
            })
            .height('100%')
            .layoutWeight(1)
            .gesture(
              LongPressGesture({ repeat: false, duration: 500 })
                .onAction((event: GestureEvent) => {
                  this.isBatch = true
                })
            )
          }
          .layoutWeight(1)
          .animation({
            duration: 300
          })
        }
        .height('100%')
        .padding({
          top: this.isBatch ? 50 + this.topRectHeight : 122,
          bottom: this.isBatch ? 68 + this.bottomRectHeight : this.bottomRectHeight
        })

        Column() {
          if (this.errorText && !this.sourceList.length) {
            Text(this.errorText)
          } else {
            LoadingProgress()
              .color(this.theme.mainColor)
              .width('50%')
            Text('加载中...')
          }
        }
        .justifyContent(FlexAlign.Center)
        .zIndex(this.loading || (this.errorText && !this.sourceList.length) ? 9 : -1)
        .opacity(this.loading || (this.errorText && !this.sourceList.length) ? 1 : 0)
        .width('100%')
        .height('100%')
        .backgroundColor('#f5f5f5')
        .animation({
          duration: 300
        })
      }
      .height('100%')


      Row() {
        Row() {
          Column() {
            Image($r('app.media.verify'))
              .width(24)
              .margin({ bottom: 4 })
            Text('校验')
              .fontSize(12)
          }
          .layoutWeight(1)
          .onClick(() => {
            showMessage('校验')
          })

          Row().width(12)
          Column() {
            Toggle({ type: ToggleType.Switch, isOn: this.toggleAll })
              .selectedColor(this.theme.mainColor)
              .margin({ bottom: 4 })
              .onChange(async (val: boolean) => {
                this.toggleAll = val
                this.sourceList.forEach((item, i) => {
                  if (this.activeNameMap[item.bookSourceUrl]) {
                    item.enabled = val
                    this.sourceList[i] = item
                  }
                })
                await BookSourceDao.batchUpdateFlow(this.sourceList)
                this.getList()
              })

            Text(this.toggleAll ? '禁用' : '启用')
              .fontSize(12)
          }
          .layoutWeight(1)

          Row().width(12)
          Column() {
            Image($r('app.media.export_1'))
              .width(24)
              .margin({ bottom: 4 })
            Text('导出')
              .fontSize(12)
          }
          .layoutWeight(1)
          .onClick(() => {
            showMessage('导出')
          })

          Row().width(12)
          Column() {
            Image($r('app.media.delete'))
              .width(24)
              .margin({ bottom: 4 })
            Text('删除')
              .fontSize(12)
          }
          .layoutWeight(1)
          .onClick(async () => {
            if (!Object.values(this.activeNameMap).filter(o => o).length) {
              return showMessage('请至少选择一个')
            }
            await BookSourceDao.batchDelete(Object.keys(this.activeNameMap))
            showMessage('删除成功')
            this.activeNameMap = {}
            this.getList()
          })

          Row().width(12)
          Column() {
            Image($r('app.media.more'))
              .width(24)
              .margin({ bottom: 4 })
            Text('更多')
              .fontSize(12)
          }
          .layoutWeight(1).bindMenu(
            this.showMoreDialog,
            this.rightDialogBuilder(this.More_Right_Dialog_Data, async (index: number) => {
              switch (index) {
                case 0:
                  if (!Object.values(this.activeNameMap).filter(o => o).length) {
                    showMessage('请至少选择一个')
                    return
                  }
                  this.isShowGroup = true;
                  break;
                case 1:
                  if (!Object.values(this.activeNameMap).filter(o => o).length) {
                    showMessage('请至少选择一个')
                    return
                  }
                  this.dialogItem = this.sourceList.filter(item => this.activeNameMap[item.bookSourceUrl])[0]
                  this.dialogController.open()
                  break;
                case 2:
                  showMessage(this.More_Right_Dialog_Data[index].title)
                  break;
              }
            }),
            {
              onDisappear: () => {
                this.showMoreDialog = false
              }
            })
          .onClick(() => {
            this.showMoreDialog = true
          })
        }
        .padding({
          left: 20,
          right: 20,
        })
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .height(68)
      }
      .backgroundColor(Color.White)
      .position({ bottom: 0 })
      .zIndex(99)
      .translate({ y: this.isBatch ? 0 : 68 + this.bottomRectHeight })
      .animation({
        duration: 500
      })
      .padding({ bottom: this.bottomRectHeight })


      //分组
      Flex()
        .bindSheet($$this.isShowGroup, this.showCheckGroup(), {
          height: 320,
          dragBar: true,
          showClose: false,
          onDisappear: () => {
            this.isShowGroup = false
          }
        })
    }
    .alignContent(Alignment.Top)
  }

  @Builder
  selectAll() {
    Column() {
      Text('全选')
    }
    .onClick(() => {
      this.sourceList.forEach((item: BookSourcePart) => {
        this.activeNameMap[item.bookSourceUrl] = true
      })
    })
  }

  @Builder
  complete() {
    Column() {
      Text('完成')
    }
    .onClick(async () => {
      this.isBatch = false
      this.activeNameMap = {}
      this.getList()
    })
  }

  @Builder
  buildContent() {
    Column() {
      Rating({ rating: parseInt(this.dialogItem?.bookSourceScore?.replace('分', '') ?? '0') })
        .size({
          width: 192,
          height: 32
        })
        .stars(5)
        .stepSize(1)
        .margin({ bottom: 16 })
        .onChange((value: number) => {
          this.dialogItem.bookSourceScore = value.toFixed(1) + '分'
        })

      Row() {
        Row() {
          Radio({ value: '2', group: 'radioGroup' })
            .checked(this.dialogItem?.bookSourceGrade === 2)
            .radioStyle({
              checkedBackgroundColor: this.theme.mainColor
            })
            .height(20)
            .width(20)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.dialogItem.bookSourceGrade = 2
              }
            })
          Text('精品')
            .padding({ left: 6 })
        }

        Row() {
          Radio({ value: '1', group: 'radioGroup' })
            .checked(this.dialogItem?.bookSourceGrade === 1)
            .radioStyle({
              checkedBackgroundColor: this.theme.mainColor
            })
            .height(20)
            .width(20)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.dialogItem.bookSourceGrade = 1
              }
            })
          Text('优质')
            .padding({ left: 6 })
        }
        .padding({ left: 10 })

        Row() {
          Radio({ value: '0', group: 'radioGroup' })
            .checked(this.dialogItem?.bookSourceGrade === 0)
            .radioStyle({
              checkedBackgroundColor: this.theme.mainColor
            })
            .height(20)
            .width(20)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.dialogItem.bookSourceGrade = 0
              }
            })
          Text('普通')
            .padding({ left: 6 })
        }
        .padding({ left: 10 })
      }
      .justifyContent(FlexAlign.SpaceAround)
    }
  }

  // 分类标题
  @Builder
  classifyHeader(title: string, index: number) {
    Row() {
      Text(title)
        .textAlign(TextAlign.Start)
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })
        .maxLines(1)

      if (this.isBatch) {
        Blank()
        CheckboxGroup({ group: 'checkboxGroup' + index })
          .checkboxShape(CheckBoxShape.CIRCLE)
          .selectedColor(this.theme.mainColor)
      } else {
        Text('长按批量管理')
          .fontSize(12)
          .fontWeight(400)
          .lineHeight(20)
          .padding({ left: 8 })
        Blank()
      }
    }
    .width('100%')
    .padding({ right: 16 })
    .backgroundColor('#f5f5f5')
    .justifyContent(FlexAlign.Start)
  }

  // 每个分类的内容主体
  @Builder
  CourseItem(item: BookSourcePart, i: number, j: number) {
    Column() {
      Row() {
        Text(item.bookSourceName)
          .fontSize(16)
          .lineHeight(24)
          .fontWeight(FontWeight.Medium)
          .textOverflow({
            overflow: TextOverflow.Ellipsis,
          })
          .maxLines(1)

        if (item.hasLoginUrl) {
          Tag({ text: '登录', color: '#188BFF', bgColor: '#1F188BFF' })
        }

        if (item.hasExploreUrl) {
          Tag({ text: '发现', color: this.theme.mainColor, bgColor: this.theme.secondColor })
        }

        Blank()

        if (this.isBatch) {
          Checkbox({ name: 'checkbox' + j, group: 'checkboxGroup' + i })
            .select(this.activeNameMap[item.bookSourceUrl] ?? false)
            .selectedColor(this.theme.mainColor)
            .onChange((val: boolean) => {
              this.activeNameMap[item.bookSourceUrl] = val
            })
        } else {
          Image($r('app.media.more_vertical'))
            .width(24).fillColor('#73000000')
            .bindMenu(
              this.showRightDialogMap[item.bookSourceUrl],
              this.rightDialogBuilder(this.Item_Right_Dialog_Data, async (index: number) => {
                switch (index) {
                  case 0:
                    router.pushUrl({
                      url: 'pages/view/Find/BookSource/AddSourcePage', params: {
                        id: item.bookSourceUrl
                      }
                    })
                    break;
                  case 1:
                    this.dialogItem = JSON.parse(JSON.stringify(item)) as BookSourcePart
                    this.dialogController.open()
                    break;
                  case 2:
                  case 3:
                    showMessage(this.Item_Right_Dialog_Data[index].title)
                    break;
                  case 4:
                    router.pushUrl({
                      url: 'pages/view/Find/BookSource/AddSourcePage', params: {
                        id: item.bookSourceUrl, type: 1
                      }
                    })
                    break;
                  case 5:
                    await BookSourceDao.delete(item.bookSourceUrl)
                    showMessage('删除成功')
                    this.getList()
                    break;
                }
              }),
              {
                onDisappear: () => {
                  this.showRightDialogMap[item.bookSourceUrl] = false
                }
              })
            .onClick(() => {
              this.showRightDialogMap[item.bookSourceUrl] = true
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Score({ grade: item.bookSourceGrade, score: item.bookSourceScore })
      }
      .width('100%')
      .margin({ top: 10 })
      .justifyContent(FlexAlign.Start)

      Row() {
        Text(dayjs(item.lastUpdateTime).format('YYYY-MM-DD HH:mm'))
          .fontSize(12)
          .lineHeight(20)
          .fontColor('rgba(0, 0, 0, 0.45)')
        Text('导入')
          .padding({ left: 4 })
          .fontSize(12)
          .lineHeight(20)
          .fontColor('rgba(0, 0, 0, 0.45)')
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: item.enabled })
          .selectedColor(this.theme.mainColor)
          .onChange(async (val: boolean) => {
            item.enabled = val
            await BookSourceDao.updateFlow(item)
          })
      }
      .width('100%')
      .margin({ top: 3 })
      .justifyContent(FlexAlign.SpaceBetween)

      if (j === 1) {
        Row() {
          Text('搜索不到时可以尝试以下格式搜索 ##完整书名 每隔八小时访问一遍签到（搜索的时候访问） 登录注意事项： 1、如果app有重新登录过，就要重新抓token 2、每次重新登录，那么书籍就要更新目录，刷新正文')
            .fontSize(12)
            .fontColor('#73000000')
            .textOverflow({
              overflow: TextOverflow.Ellipsis
            })
            .maxLines(this.clickNameMap[item.bookSourceUrl] ? 99 : 1)
            .layoutWeight(1)
            .animation({
              duration: 300
            })
            .onClick(() => {
              this.clickNameMap[item.bookSourceUrl] = !this.clickNameMap[item.bookSourceUrl]
            })

          Image($r('app.media.down_arrow'))
            .margin({ top: 4 })
            .width(8)
        }
        .margin({ top: 10 })
        .padding({
          left: 8,
          right: 8,
          top: 4,
          bottom: 4
        })
        .alignItems(VerticalAlign.Top)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor('rgba(0, 0, 0, 0.04)')
      }
    }
    .width('100%')
    .margin({
      bottom: 12
    })
    .borderRadius(12)
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12
    })
    .backgroundColor(Color.White)
  }

  Item_Right_Dialog_Data: IconTitleVo[] = [
    new IconTitleVo($r('app.media.edit'), '编辑'),
    new IconTitleVo($r('app.media.icon_no_source_find'), '评分'),
    new IconTitleVo($r('app.media.search'), '搜索'),
    new IconTitleVo($r('app.media.ic_logout'), '登录'),
    new IconTitleVo($r('app.media.icon_rule_help'), '调试'),
    new IconTitleVo($r('app.media.delete'), '删除')
  ]
  More_Right_Dialog_Data: IconTitleVo[] = [
    new IconTitleVo($r('app.media.ic_folder'), '移动至'),
    new IconTitleVo($r('app.media.icon_no_source_find'), '评分'),
    new IconTitleVo($r('app.media.icon_share'), '分享'),
  ]

  @Builder
  rightDialogBuilder(list: IconTitleVo[], dialogRightChange: (_index: number) => void) {
    Column() {
      ForEach(list, (item: IconTitleVo, index) => {
        dialogTitleFuction({
          title: item.title,
          icon: item.icon,
          isBorder: list.length !== index + 1
        })
          .onClick(() => {
            dialogRightChange(index)
          })
      })
    }
  }

  //移动分组
  @Builder
  showCheckGroup() {
    Flex() {
      SourceGroup({
        groupList: SOURCE_GROUP_MAP[[0, 2, 1][this.index]],
        confirm: async (groupName) => {
          this.sourceList.forEach((item, i) => {
            if (this.activeNameMap[item.bookSourceUrl]) {
              item.bookSourceGroup = groupName
              this.sourceList[i] = item
            }
          })
          await BookSourceDao.batchUpdateFlow(this.sourceList)
          this.getList()
          this.activeNameMap = {}
          this.isShowGroup = false
        },
        cancel: () => {
          this.isShowGroup = false
        }
      })
    }
    .padding({ bottom: this.bottomRectHeight })
  }
}

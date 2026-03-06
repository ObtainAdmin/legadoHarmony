/**
 * SourceView 组件 - 书源视图组件
 * 
 * 功能概述：
 * 1. 显示书源列表，支持按分组分类显示
 * 2. 提供搜索功能，支持按书源名称筛选
 * 3. 实现批量管理模式，支持全选、置顶、显示/隐藏等操作
 * 4. 集成侧边栏导航，支持分组间的快速跳转
 * 5. 提供书源编辑、置顶、搜索、显示/隐藏等右键菜单功能
 * 6. 支持长按进入批量管理模式，拖拽排序分组
 * 
 * 设计特点：
 * 1. 分层布局：使用Stack实现批量工具栏、内容区域和底部操作栏的叠加
 * 2. 状态管理：管理选中状态、加载状态、错误状态等复杂状态
 * 3. 动画效果：批量模式切换时的平滑动画效果
 * 4. 数据分组：将书源按分组分类，提高浏览效率
 * 5. 主题集成：支持动态主题颜色，应用于选中状态和UI元素
 * 
 * 使用场景：
 * 1. 书源管理页面的主要内容区域
 * 2. 需要批量操作书源的场景
 * 3. 需要分组浏览和搜索书源的界面
 * 
 * 组件结构：
 * - 批量工具栏：全选、计数、完成按钮
 * - 侧边栏：分组导航，支持拖拽排序
 * - 主列表：分组显示书源，支持右键菜单
 * - 底部操作栏：置顶、显示/隐藏批量操作
 * - 加载/错误状态：显示加载中、无数据等状态
 * 
 * 注意事项：
 * 1. 需要正确处理批量模式的切换和状态同步
 * 2. 分组拖拽排序需要更新数据库
 * 3. 主题颜色需要动态应用到各个UI元素
 */

import dayjs from 'dayjs'
import PaddingConstants from '../../common/constants/PaddingConstants'
import { IconTitleVo } from '../../componetsmodel/IconTitleVo'
import BookSourceDao from '../../database/dao/BookSourceDao'
import { GroupPartList } from '../../database/entities/BookSource'
import { BookSourcePart } from '../../database/entities/BookSourcePart'
import dialogTitleFuction from '../common/dialogTitleFuction'
import { showMessage } from '../common/promptShow'
import Score from '../common/Score'
import SideBar from '../common/SideBar'
import Tag from '../common/Tag'
import { router } from '@kit.ArkUI'
import noFind from '../common/noFind'
import { ThemeItem } from '../../common/model/Theme'
import { ThemeStorageKey } from '../../common/constants/Theme'

@Component
export default struct SourceView {
  /**
   * 顶部矩形高度
   * @type {number}
   * @default 0
   * @description 从存储中读取的顶部矩形高度，用于布局计算
   * @storagelink 使用@StorageLink装饰器实现与存储的双向绑定
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /**
   * 底部矩形高度
   * @type {number}
   * @default 0
   * @description 从存储中读取的底部矩形高度，用于布局计算
   * @storagelink 使用@StorageLink装饰器实现与存储的双向绑定
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /**
   * 标题数组
   * @type {Array<string>}
   * @default ['小说', '漫画', '有声书']
   * @description 书源类型标题数组
   */
  titleArray: Array<string> = ['小说', '漫画', '有声书']
  
  /**
   * 索引
   * @type {number}
   * @default 0
   * @description 当前视图索引（0:默认显示, 1:隐藏书源）
   */
  index: number = 0
  
  /**
   * 类型
   * @type {number}
   * @default 0
   * @description 书源类型（0:小说, 1:漫画, 2:有声书）
   */
  type: number = 0
  
  /**
   * 搜索值
   * @type {string}
   * @description 搜索关键词，变化时触发getList方法
   * @link @watch 使用@Link装饰器实现双向绑定，@Watch监听变化
   */
  @Link @Watch('getList') searchValue: string
  
  /**
   * 激活名称映射
   * @type {Record<string, boolean>}
   * @default {}
   * @description 记录选中书源的状态映射
   * @state 使用@State装饰器管理组件内部状态
   */
  @State activeNameMap: Record<string, boolean> = {}
  
  /**
   * 全选状态
   * @type {boolean}
   * @default false
   * @description 标识是否全选
   * @state 使用@State装饰器管理组件内部状态
   */
  @State fullActive: boolean = false
  
  /**
   * 分组列表
   * @type {GroupPartList[]}
   * @default []
   * @description 按分组分类的书源列表
   * @state 使用@State装饰器管理组件内部状态
   */
  @State groupList: GroupPartList[] = []
  
  /**
   * 书源列表
   * @type {BookSourcePart[]}
   * @default []
   * @description 所有书源数据列表
   * @state 使用@State装饰器管理组件内部状态
   */
  @State sourceList: BookSourcePart[] = []
  
  /**
   * 加载状态
   * @type {boolean}
   * @default true
   * @description 标识是否正在加载数据
   * @state 使用@State装饰器管理组件内部状态
   */
  @State loading: boolean = true
  
  /**
   * 错误文本
   * @type {string}
   * @default ''
   * @description 错误提示文本
   * @state 使用@State装饰器管理组件内部状态
   */
  @State errorText: string = ''
  
  /**
   * 批量模式状态
   * @type {boolean}
   * @description 标识是否处于批量管理模式
   * @link 使用@Link装饰器实现与父组件的双向绑定
   */
  @Link isBatch: boolean
  
  /**
   * 显示右侧对话框映射
   * @type {Record<string, boolean>}
   * @default {}
   * @description 记录每个书源右侧菜单的显示状态
   * @state 使用@State装饰器管理组件内部状态
   */
  @State showRightDialogMap: Record<string, boolean> = {}
  
  /**
   * 当前索引
   * @type {number}
   * @default 0
   * @description 当前选中的分组索引
   * @state 使用@State装饰器管理组件内部状态
   */
  @State currentIndex: number = 0
  
  /**
   * 置顶切换状态
   * @type {boolean}
   * @default false
   * @description 标识置顶/取消置顶的切换状态
   * @state 使用@State装饰器管理组件内部状态
   */
  @State topToggle: boolean = false
  
  /**
   * 刷新计数
   * @type {number}
   * @description 刷新计数器，变化时触发getList方法
   * @link @watch 使用@Link装饰器实现双向绑定，@Watch监听变化
   */
  @Link @Watch('getList') refreshCount: number
  
  /**
   * 关闭对话框回调
   * @type {Function}
   * @default () => {}
   * @description 关闭对话框的回调函数
   */
  closeDialog: () => void = () => {
  }
  
  /**
   * 滚动控制器
   * @type {Scroller}
   * @description 控制侧边栏滚动的控制器
   */
  private scroll: Scroller = new Scroller()
  
  /**
   * 第二滚动控制器
   * @type {Scroller}
   * @description 控制主列表滚动的控制器
   */
  private secondScroll = new Scroller()
  
  /**
   * 主题配置
   * @type {ThemeItem}
   * @description 从存储中读取的主题配置
   * @storageprop 使用@StorageProp装饰器从存储中读取数据
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 组件即将显示时的生命周期回调
   * @returns {void}
   * @description 组件初始化，开始加载数据
   */
  aboutToAppear() {
    console.info('TagInfo', '当前下标： ' + this.index) // 调试日志
    this.loading = true // 设置加载状态
    this.getList() // 获取数据
  }

  /**
   * 获取书源列表
   * @returns {void}
   * @description 从数据库获取书源数据，按类型和搜索关键词筛选
   */
  getList() {
    BookSourceDao.flowSearch({
      type: [0, 2, 1][this.type], // 类型映射：0->0(小说), 1->2(漫画), 2->1(有声书)
      searchKey: this.searchValue, // 搜索关键词
      showExplore: this.index === 0 // 是否显示探索（默认显示）
    }).then(data => {
      const bookSource = data ?? [] // 处理空数据
      console.info('TagInfo', JSON.stringify(bookSource.slice(0, 3))) // 调试日志
      this.sourceList = bookSource // 更新书源列表
      this.getGroupList() // 分组处理
      this.loading = false // 取消加载状态
      console.info('TagInfo', '数量 ' + this.sourceList.length) // 调试日志
      if (!this.sourceList.length) {
        this.errorText = `当前${this.titleArray[this.type]}还没有添加源` // 设置错误文本
      }
    })
  }

  /**
   * 获取分组列表
   * @returns {void}
   * @description 将书源按分组分类，构建分组列表
   */
  getGroupList() {
    const groupMap: Record<string, GroupPartList> = {}; // 分组映射
    this.sourceList.forEach((item: BookSourcePart) => {
      const title = item.bookSourceGroup; // 分组标题
      const bookSourceName = item.bookSourceName; // 书源名称
      if (bookSourceName.indexOf(this.searchValue) === -1) {
        return // 跳过不匹配搜索关键词的书源
      }
      if (!title) {
        return // 跳过无分组的书源
      }
      // 如果groupMap中还没有这个group，则创建一个新的GroupList对象
      if (!groupMap[title]) {
        groupMap[title] = { title: title, list: [] }; // 创建新分组
      }
      // 向当前group的list中添加BookSource对象
      groupMap[title].list.push(item); // 添加书源到分组
    })
    this.groupList = Object.values(groupMap); // 转换为数组
  }

  /**
   * 滚动变化动作
   * @param {number} start - 起始索引
   * @param {Boolean} flg - 标志位（true:侧边栏滚动, false:主列表滚动）
   * @returns {void}
   * @description 同步侧边栏和主列表的滚动位置
   */
  scrollChangeAction(start: number, flg: Boolean) {
    if (this.currentIndex !== start) {
      this.currentIndex = start; // 更新当前索引
      if (!flg) {
        this.scroll.scrollToIndex(start); // 滚动侧边栏
      } else {
        this.secondScroll.scrollToIndex(start); // 滚动主列表
      }
    }
  }

  build() {
    Column() {
      Stack() {
        Row() {
          Column() {
            Text('全选')
              .fontSize(14)
              .fontColor('#E0000000')
          }
          .onClick(() => {
            this.sourceList.forEach((item: BookSourcePart) => {
              this.activeNameMap[item.bookSourceUrl] = true
            })
          })

          Text(`已选${Object.values(this.activeNameMap).filter(o => o).length}项`)
            .fontSize(16)
            .fontWeight(700)
            .fontColor('#000000')

          Column() {
            Text('完成')
              .fontSize(14)
              .fontColor('#E0000000')
          }
          .onClick(() => {
            this.isBatch = false
            this.activeNameMap = {}
          })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .padding({
          left: PaddingConstants.PADDING_20,
          right: PaddingConstants.PADDING_20
        })
        .height(48)
        .translate({ y: this.isBatch ? 0 : -48 })
        .animation({
          duration: 300,
          delay: 300
        })
        .opacity(this.isBatch ? 1 : 0)
        .zIndex(1)

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
              console.info('TagInfo: 更新成功')
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
        .padding({
          top: this.isBatch ? 50 : 0,
          bottom: this.isBatch ? 56 + this.bottomRectHeight : this.bottomRectHeight
        })


        Row() {
          Row() {
            Column() {
              Text(this.topToggle ? '取消置顶' : '置顶')
                .fontSize(16)
            }
            .layoutWeight(1)
            .onClick(async () => {
              if (!Object.values(this.activeNameMap).filter(o => o).length) {
                showMessage('请至少选择一个')
                return
              }
              this.sourceList.forEach((item, i) => {
                if (this.activeNameMap[item.bookSourceUrl]) {
                  item.isTop = !this.topToggle
                  this.sourceList[i] = item
                }
              })
              await BookSourceDao.batchUpdateFlow(this.sourceList)
              this.activeNameMap = {}
              this.refreshCount += 1
              this.topToggle = !this.topToggle
            })

            Row().width(12)
            Column() {
              Text(this.index === 0 ? '隐藏' : '显示')
                .fontSize(16)
            }
            .layoutWeight(1)
            .onClick(async () => {
              if (!Object.values(this.activeNameMap).filter(o => o).length) {
                showMessage('请至少选择一个')
                return
              }
              this.sourceList.forEach((item, i) => {
                if (this.activeNameMap[item.bookSourceUrl]) {
                  item.showExplore = this.index !== 0
                  this.sourceList[i] = item
                }
              })
              await BookSourceDao.batchUpdateFlow(this.sourceList)
              this.activeNameMap = {}
              this.refreshCount += 1
            })
          }
          .padding({
            left: 20,
            right: 20,
          })
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .height(56)
        }
        .backgroundColor(Color.White)
        .position({ bottom: 0 })
        .zIndex(99)
        .translate({ y: this.isBatch ? 0 : 56 + this.bottomRectHeight })
        .animation({
          duration: 500
        })
        .padding({ bottom: this.bottomRectHeight })

        Column() {
          if (this.loading) {
            LoadingProgress()
              .color(this.theme.mainColor)
              .width('50%')
            Text('加载中...')
          } else if (this.errorText) {
            noFind()
          } else if (!this.sourceList.length) {
            noFind({
              hintIndex: 0
            })
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
      .alignContent(Alignment.Top)
    }
    .height('100%')
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
              this.rightDialogBuilder(this.Item_Right_Dialog_Data.map((itemData, index) => {
                if (index === 1) {
                  itemData.title = item.isTop ? '取消置顶' : '置顶'
                }
                if (index === 3) {
                  itemData.title = item.showExplore ? '隐藏' : '显示'
                }
                return itemData
              }), async (index: number) => {
                switch (index) {
                  case 0:
                    this.closeDialog()
                    router.pushUrl({
                      url: 'pages/view/Find/BookSource/AddSourcePage', params: {
                        id: item.bookSourceUrl
                      }
                    })
                    break;
                  case 1:
                    item.isTop = !item.isTop
                    this.showRightDialogMap[item.bookSourceUrl] = false
                    await BookSourceDao.updateFlow(item)
                    this.refreshCount += 1
                  case 2:
                    showMessage(this.Item_Right_Dialog_Data[index].title)
                    break;
                  case 3:
                    item.showExplore = !item.showExplore
                    this.showRightDialogMap[item.bookSourceUrl] = false
                    await BookSourceDao.updateFlow(item)
                    this.refreshCount += 1
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
      }
      .width('100%')
      .margin({ top: 3 })
      .justifyContent(FlexAlign.SpaceBetween)

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
    .border({
      width: 1,
      color: this.activeNameMap[item.bookSourceUrl] ? this.theme.mainColor : Color.White,
      style: BorderStyle.Solid
    })
    .backgroundColor(this.activeNameMap[item.bookSourceUrl] ? this.theme.secondColor : Color.White)
  }

  Item_Right_Dialog_Data: IconTitleVo[] = [
    new IconTitleVo($r('app.media.edit'), '编辑'),
    new IconTitleVo($r('app.media.top'), '置顶'),
    new IconTitleVo($r('app.media.search'), '搜索'),
    new IconTitleVo($r('app.media.ic_logout'), '显示'),
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
}

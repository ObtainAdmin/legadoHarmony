/**
 * 本地导入页面 - 扫描和导入本地书籍文件
 * 
 * 功能概述：
 * 1. 智能扫描本地存储中的书籍文件（txt、epub、pdf、mp3、wma等格式）
 * 2. 本地目录浏览，查看和管理本地文件
 * 3. 支持搜索功能，快速查找特定书籍
 * 4. 提供全选和批量导入功能
 * 5. 支持按时间、名称、大小排序
 * 
 * 页面结构：
 * - 顶部：搜索栏，支持展开/收起动画
 * - 主体：Tabs切换（智能扫描、本地目录）
 *   - 智能扫描Tab：自动扫描到的书籍列表
 *   - 本地目录Tab：手动浏览的本地文件列表
 * - 底部：操作栏（全选、导入书架）
 * 
 * 数据模型：
 * 使用SmartScanItem类表示扫描到的书籍项
 * 支持多种文件格式和排序方式
 */

import { router } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { ThemeStorageKey } from '../../../common/constants/Theme';
import { ThemeItem } from '../../../common/model/Theme';

/**
 * 智能扫描项数据模型类
 * 
 * 功能：封装本地扫描到的书籍文件信息
 * 属性：
 * - bookName: 书籍名称
 * - Type: 文件类型（EPUB、TXT、PDF等）
 * - CreateTime: 文件创建时间
 * - size: 文件大小
 * 
 * 使用场景：在智能扫描和本地目录列表中显示书籍信息
 */
class SmartScanItem {
  bookName: string
  Type: string
  CreateTime: Date
  size: string

  constructor(
    bookName: string,
    size: string,
    Type: string = 'EPUB',
    CreateTime: Date = new Date()
  ) {
    this.bookName = bookName
    this.size = size
    this.Type = Type
    this.CreateTime = CreateTime
  }
}

/**
 * 格式化日期函数
 * 
 * 功能：将Date对象格式化为"YYYY/MM/DD"字符串
 * @param date 要格式化的Date对象
 * @returns 格式化后的日期字符串
 * 
 * 示例：new Date(2023, 11, 25) -> "2023/12/25"
 */
function formatDate(date: Date): string {
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, '0'); // 月份从0开始，所以需要加1
  const day = date.getDate().toString().padStart(2, '0');
  return `${year}/${month}/${day}`;
}

/**
 * 本地导入页面结构体
 * 
 * 职责：
 * 1. 管理本地书籍文件的扫描和显示
 * 2. 处理搜索功能的交互和动画
 * 3. 控制Tabs切换和内容显示
 * 4. 提供排序和筛选功能
 * 5. 处理批量导入操作
 * 
 * 组件特点：
 * - 使用@Entry装饰器，表示这是一个页面级组件
 * - 使用@Component装饰器，表示这是一个UI组件
 * - 支持搜索栏展开/收起动画
 * - 集成主题颜色配置
 */
@Entry
@Component
struct LocalImportPage {
  /** 底部矩形高度，从应用存储中读取，用于适配不同设备 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 顶部矩形高度，从应用存储中读取，用于适配不同设备 */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 当前选中的Tab索引：0-智能扫描，1-本地目录 */
  @State currentTabIndex: number = 0
  
  /** 搜索框输入的值 */
  @State SearchValue: string = ""
  
  /** 搜索框点击状态，true表示搜索框已展开 */
  @State onSearchClick: boolean = false
  
  /** 搜索框垂直平移距离，用于动画效果 */
  @State SearchTranslateY: number = 0
  
  /** 搜索控制器，管理Search组件的状态和行为 */
  SearchController: SearchController = new SearchController()
  
  /** 支持的文件类型图标列表 */
  FilesTypeImageList: Array<string> = ["EPUB", "TXT", "PDF"]
  
  /** 智能扫描项列表，包含扫描到的书籍信息 */
  @State SmartScanItemList: SmartScanItem[] = [
  // new SmartScanItem("斗破苍穹", "12MB", "EPUB", new Date()),
  // new SmartScanItem("斗破苍穹", "12MB", "TXT", new Date()),
  // new SmartScanItem("斗破苍穹", "12MB", "PDF", new Date()),
  ]
  
  /** 菜单项列表，用于排序和筛选 */
  menuList: string[] = [
    '按时间排序',
    '按名称排序',
    '按大小排序',
    '系统文件夹',
  ]
  
  /** 应用主题配置，从应用存储中读取，用于UI元素颜色 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 页面显示时的生命周期方法
   * 功能：模拟数据加载，延迟1秒后显示测试数据
   * 使用场景：开发测试阶段，展示页面布局效果
   */
  onPageShow(): void {
    setTimeout(() => {
      this.SmartScanItemList = [
        new SmartScanItem("斗破苍穹", "12MB", "EPUB", new Date()),
        new SmartScanItem("斗破苍穹", "12MB", "TXT", new Date()),
        new SmartScanItem("斗破苍穹", "12MB", "PDF", new Date()),
      ]
    }, 1000)
  }

  build() {
    Stack() {
      Row({ space: 12 }) {
        if (this.onSearchClick) {
          Image($r('app.media.return_left'))
            .width(24)
            .onClick(() => {
              this.onSearchClick = false
              this.SearchTranslateY = 55
            })
        }
        Search({
          value: this.SearchValue,
          placeholder: '搜索',
          icon: "/common/images/search.svg",
          controller: this.SearchController
        })
          .width(this.onSearchClick ? "90%" : "100%")
          .onClick(() => {
            this.onSearchClick = true
            this.SearchTranslateY = -55
          })
          .onBlur(() => {
            this.onSearchClick = false
            this.SearchTranslateY = 0
          })
      }
      .translate({ x: 0, y: this.SearchTranslateY })
      .animation({
        duration: 500,
        curve: Curve.EaseOut,
        playMode: PlayMode.Normal
      })
      .width("100%")
      .height(40)
      .margin({
        top:55
      })
      .padding({
        left: 20,
        right: 20
      })
      .zIndex(2)

      if (!this.onSearchClick) {
        Tabs({
          barPosition: BarPosition.Start
        }) {
          TabContent() {
            Column() {
              if (this.SmartScanItemList.length > 0) {
                ForEach(this.SmartScanItemList, (item: SmartScanItem) => {
                  this.ScanShowItem(item)
                })
                Blank(1)
                Divider()
                this.BottomBar()
              } else {
                Image($r('app.media.no_record'))
                  .width(200)
                  .margin({
                    top: 144
                  })
                Text('暂未扫描到可用书籍，支持txt、epub、pdf、mp3、wma')
                  .textAlign(TextAlign.Center)
                  .lineHeight(22)
                  .opacity(0.45)
                  .font({
                    size: 14,
                    weight: 400
                  })
              }
            }
            .width('100%')
            .height("100%")
          }
          .padding({
            top: 40,
            left: 20,
            right: 20
          })
          .tabBar(this.TabBuilder(0, "智能扫描"))

          TabContent() {
            Column() {
              // this.SearchBar()
              if (this.SmartScanItemList.length > 0) {
                ForEach(this.SmartScanItemList, (item: SmartScanItem) => {
                  this.ScanShowItem(item)
                })
                Blank(1)
                Divider()
                this.BottomBar()
              } else {
                Image($r('app.media.no_record'))
                  .width(200)
                  .margin({
                    top: 144
                  })
                Text('暂未扫描到可用书籍，支持txt、epub、pdf、mp3、wma')
                  .textAlign(TextAlign.Center)
                  .lineHeight(22)
                  .opacity(0.45)
                  .font({
                    size: 14,
                    weight: 400
                  })
              }
            }
            .width('100%')
            .height("100%")
          }
          .padding({
            top: 40,
            left: 20,
            right: 20
          })
          .tabBar(this.TabBuilder(1, "本地目录"))
        }
        .onChange((index: number) => {
          this.currentTabIndex = index
        })
      } else {
        Column()
          .width("100%")
          .height("100%")
          .onClick(() => {
            // 狗鸿蒙的search组件点击其它地方不失焦
            this.onSearchClick = false
            this.SearchTranslateY = 0
          })
      }
    }
    .alignContent(Alignment.TopStart)
    .width("100%")
    .padding({
      top: this.topRectHeight,
      bottom: this.bottomRectHeight
    })
  }

  @Builder
  SearchBar() {

  }

  @Builder
  MenuBuilder() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      ForEach(this.menuList, (item: string, index) => {
        Row({ space: 8 }) {
          if (index === this.menuList.length - 1) {
            Image($r("app.media.my_center_file_icon")).width(20)
          }
          Text(`${item}`)
            .lineHeight(22)
            .font({
              size: 14,
              weight: 500
            })
        }
        .padding({
          left: 20,
          right: 20
        })
        .align(Alignment.Center)
        .width("100%")
        .height(46)

        if (index !== this.menuList.length - 1) {
          Divider()
            .width('80%')
            .strokeWidth(index !== this.menuList.length - 1 ? null : 4)
        }
      })
    }.width(140)
  }

  @Builder
  BottomBar() {
    Row() {
      Row() {
        CheckboxGroup({ group: 'checkboxGroup' })
        Text("全选")
          .lineHeight(24)
          .font({
            size: 16,
            weight: 400
          })
      }

      Text("导入书架")
        .lineHeight(24)
        .fontColor(this.theme.mainColor)
        .opacity(0.5)
        .font({
          size: 16,
          weight: 400
        })
    }
    .justifyContent(FlexAlign.SpaceAround)
    .width("100%")
    .height(56)
  }

  @Builder
  ScanShowItem(item: SmartScanItem) {
    Row({ space: 12 }) {
      Flex({
        direction: FlexDirection.Row,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.Center
      }) {
        Text(item.Type)
          .fontColor("#188BFF")
          .font({
            size: 10,
            weight: 700,
          })

      }
      .backgroundColor("#D8ECFF")
      .width(32)
      .height(32)
      .padding({
        top: 10,
        bottom: 10
      })
      .margin(4)

      Column() {
        Row() {
          Text(item.bookName)
            .lineHeight(22)
            .font({
              size: 14,
              weight: 500,
            })
        }
        .width("100%")

        Row() {
          Text(`${item.size} ${formatDate(item.CreateTime)}`)
            .lineHeight(18)
            .opacity(0.45)
            .font({
              size: 10,
              weight: 500,
            })
        }
        .width("100%")
      }
      .width("60%")

      Blank(1)
      Checkbox({ name: `${item.bookName}`, group: 'checkboxGroup' })
    }
    .padding({
      top: 10,
      bottom: 10
    })
    .width("100%")
  }

  @Builder
  TabBuilder(index = 0, name: string) {
    Column() {
      Flex({
        direction: index === 0 ? FlexDirection.Row : FlexDirection.RowReverse,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.Start
      }) {
        Column() {
          if (index) {
            Image($r('app.media.Column_More'))
              .width(24)
              .bindMenu(this.MenuBuilder)
          } else {
            Image($r('app.media.return_left'))
              .width(24)
              .onClick(() => {
                router.back()
              })
          }

        }
        .padding({
          left: index === 0 ? 20 : null,
          right: index === 1 ? 20 : null
        })
        .width("55.5%")
        .alignItems(index === 0 ? HorizontalAlign.Start : HorizontalAlign.End)

        Column() {
          Text(name)
            .lineHeight(24)
            .font({
              size: 16,
              weight: 500
            })
            .fontColor(this.currentTabIndex === index ? this.theme.mainColor : '#000000')
            .opacity(this.currentTabIndex === index ? null : 0.45)
        }
      }
      .height("100%")
    }
    .width('100%')
    .height("100%")
  }
}
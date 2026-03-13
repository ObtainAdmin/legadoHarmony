/**
 * 下载管理页面 - 管理书籍下载和导出功能
 * 
 * 功能概述：
 * 1. 显示下载中的书籍列表，支持暂停/继续操作
 * 2. 显示已下载的书籍列表，支持导出操作
 * 3. 显示已导出的书籍列表，支持文件管理
 * 4. 提供导出设置功能，包括格式、路径、净化选项等
 * 5. 支持编辑模式，批量选择和管理下载项
 * 
 * 页面结构：
 * - 顶部：分类标签（全部、小说、漫画、有声书等）
 * - 主体：Tabs切换（下载、导出）
 *   - 下载Tab：下载中列表、已下载列表
 *   - 导出Tab：已下载列表、已导出列表
 * - 底部：导出设置对话框
 * 
 * 数据模型：
 * 使用DownloadItem类表示下载项，包含书籍名称、下载进度、文件类型等信息
 * 使用持久化存储管理导出设置
 */

import { router } from '@kit.ArkUI';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import { ThemeItem } from '../../../common/model/Theme';
import { ThemeStorageKey } from '../../../common/constants/Theme';

/**
 * 下载项数据模型类
 * 
 * 功能：封装单个下载项的基本信息
 * 属性：
 * - bookName: 书籍名称
 * - downloadNumber: 已下载数量/章节数
 * - Total: 总数量/章节数
 * - Type: 文件类型（EPUB、TXT、PDF等）
 * 
 * 使用场景：在下载列表、已下载列表、已导出列表中显示下载项信息
 */
class DownloadItem {
  bookName: string
  downloadNumber: number
  Total: number
  Type: string

  constructor(
    bookName: string,
    downloadNumber: number,
    Total: number,
    Type: string,
  ) {
    this.bookName = bookName
    this.downloadNumber = downloadNumber
    this.Total = Total
    this.Type = Type
  }
}

// 持久化存储导出设置列表，初始值为5个false
PersistentStorage.persistProp('ExportSettingList', [false, false, false, false, false]);

/**
 * 下载管理页面结构体
 * 
 * 职责：
 * 1. 管理下载和导出功能的完整流程
 * 2. 显示三种下载状态：下载中、已下载、已导出
 * 3. 提供编辑模式，支持批量操作
 * 4. 管理导出设置对话框
 * 5. 处理分类筛选和Tabs切换
 * 
 * 组件特点：
 * - 使用@Entry装饰器，表示这是一个页面级组件
 * - 使用@Component装饰器，表示这是一个UI组件
 * - 支持主题颜色配置
 * - 使用持久化存储管理导出设置
 */
@Entry
@Component
struct DownloadManagementPage {
  /** 底部矩形高度，从应用存储中读取，用于适配不同设备 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 顶部矩形高度，从应用存储中读取，用于适配不同设备 */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 当前选中的Tab索引：0-下载，1-导出 */
  @State currentTabIndex: number = 0
  
  /** 当前选中的分类卡片索引，用于筛选不同类型的内容 */
  @State currentScrollCardIndex: number = 0
  
  /** 搜索框的值，当前未使用，保留供未来扩展 */
  @State SearchValue: string = ""
  
  /** 编辑模式状态，true表示进入编辑模式，false表示正常模式 */
  @State IsEdit: boolean = false
  
  /** 导出设置对话框显示状态 */
  @State isShowExportSetting: boolean = false
  
  /** 导出设置列表，存储在持久化存储中，包含5个开关设置 */
  @StorageLink('ExportSettingList') ExportSettingList: Array<boolean> = [false, false, false, false, false]
  
  /** 分类列表，用于筛选不同类型的内容 */
  @State questionsList: Array<string> = ["全部", "小说", "漫画", "有声书", "有声书", "有声书"]
  
  /** 下载中的项目列表，包含正在下载的书籍信息 */
  @State DownloadingItemList: DownloadItem[] = [
    new DownloadItem("斗破苍穹", 12, 100, "EPUB"),
    new DownloadItem("斗破苍穹", 70, 150, "TXT"),
    new DownloadItem("斗破苍穹", 50, 200, "PDF"),
    new DownloadItem("斗破苍穹", 50, 200, "PDF"),
  ]
  
  /** 已下载完成的项目列表，包含下载完成的书籍信息 */
  @State DownloadFinishItemList: DownloadItem[] = [
    new DownloadItem("斗破苍穹完成", 12, 100, "EPUB"),
    new DownloadItem("斗破苍穹完成", 70, 150, "TXT"),
    new DownloadItem("斗破苍穹完成", 50, 200, "PDF"),
  ]
  
  /** 已导出的项目列表，包含已导出文件的书籍信息 */
  @State ExportFinishList: DownloadItem[] = [
    new DownloadItem("斗破苍穹导出", 12, 100, "EPUB"),
    new DownloadItem("斗破苍穹导出", 70, 150, "TXT"),
    new DownloadItem("斗破苍穹导出", 50, 200, "PDF"),
  ]

  /** 应用主题配置，从应用存储中读取，用于UI元素颜色 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 构建下载管理页面UI的主要方法
   * 
   * 布局结构：
   * 1. Stack布局作为根容器
   * 2. 非编辑模式下显示分类筛选栏
   * 3. Tabs组件包含两个标签页：下载、导出
   * 
   * 下载Tab内容：
   * - 下载中列表：显示正在下载的书籍，带进度条
   * - 已下载列表：显示下载完成的书籍
   * 
   * 导出Tab内容：
   * - 已下载列表：显示可导出的书籍，带导出按钮
   * - 已导出列表：显示已导出的书籍
   * 
   * 交互功能：
   * - 分类筛选：点击分类标签筛选内容
   * - 编辑模式：点击更多按钮进入编辑模式
   * - Tabs切换：在下载和导出功能间切换
   */
  build() {
    Stack() {
      // 非编辑模式下显示分类筛选栏
      if (this.IsEdit === false) {
        Row({ space: 12 }) {
          Scroll() {
            Row({ space: 12 }) {
              ForEach(this.questionsList, (item: string, index) => {
                Column() {
                  Text(item)
                    .fontColor(this.currentScrollCardIndex === index ? this.theme.mainColor : 'rgba(0, 0, 0, 0.88)')
                    .fontSize(12)
                    .fontWeight(700)
                }
                .borderRadius(8)
                .padding(8)
                .backgroundColor(this.currentScrollCardIndex === index ? this.theme.secondColor : 'rgb(240,240,240)')
                .onClick(() => {
                  this.currentScrollCardIndex = index  // 更新选中的分类索引
                })
              })
            }
          }
          .align(Alignment.Start)
          .width("80%")
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Horizontal)

          Blank(1)
          // 更多按钮：点击进入编辑模式
          Image($r('app.media.more_search'))
            .width(24)
            .onClick(() => {
              this.IsEdit = true
            })
        }
        .width("100%")
        .margin({
          top: 55
        })
        .height(40)
        .padding({
          left: 20,
          right: 20
        })
        .zIndex(2)
      }

      // Tabs组件：下载和导出两个标签页
      Tabs({
        barPosition: BarPosition.Start
      }) {
        // 下载标签页
        TabContent() {
          Column() {
            // 下载-下载中列表
            if (this.DownloadingItemList.length > 0) {
              Row() {
                Text(`下载中 (${this.DownloadingItemList.length})`)
                  .opacity(0.45)
                  .lineHeight(20)
                  .font({
                    size: 12,
                    weight: 500
                  })
                Blank(1)
                if (this.IsEdit) {
                  CheckboxGroup({ group: 'DownloadingItemList' })
                } else {
                  Text("全部暂停")
                    .lineHeight(20)
                    .fontColor(this.theme.mainColor)
                    .font({
                      size: 12,
                      weight: 500
                    })
                }
              }
              .width("100%")
              .padding({
                top: 12,
                bottom: 12
              })

              ForEach(this.DownloadingItemList, (item: DownloadItem) => {
                this.ShowItem(item, "Downloading", 0)
              })
            }
            // 下载-已下载
            if (this.DownloadFinishItemList.length > 0) {
              Row() {
                Text(`已下载 (${this.DownloadFinishItemList.length})`)
                  .opacity(0.45)
                  .lineHeight(20)
                  .font({
                    size: 12,
                    weight: 500
                  })
                Blank(1)
                if (this.IsEdit) {
                  CheckboxGroup({ group: 'DownloadFinishItemList' })
                }
              }
              .width("100%")
              .padding({
                top: 12,
                bottom: 12
              })

              ForEach(this.DownloadFinishItemList, (item: DownloadItem) => {
                this.ShowItem(item, "DownloadFinish", 0)
              })
              Blank(1)
              Divider()
            }
          }
          .margin({
            top: this.IsEdit ? 0 : 40
          })
          .width('100%')
          .height("100%")
        }
        .padding({
          left: 20,
          right: 20
        })
        .tabBar(this.TabBuilder(0, "下载"))

        TabContent() {
          Column() {
            // 导出-已下载
            if (this.DownloadFinishItemList.length > 0 && !this.IsEdit) {
              Row() {
                Text(`已下载 (${this.DownloadFinishItemList.length})`)
                  .opacity(0.45)
                  .lineHeight(20)
                  .font({
                    size: 12,
                    weight: 500
                  })
                Blank(1)

                Text("全部导出")
                  .lineHeight(20)
                  .fontColor(this.theme.mainColor)
                  .font({
                    size: 12,
                    weight: 500
                  })
              }
              .width("100%")
              .padding({
                top: 12,
                bottom: 12
              })

              ForEach(this.DownloadFinishItemList, (item: DownloadItem) => {
                this.ShowItem(item, "DownloadFinish", 1)
              })
            }

            // 导出-已导出
            if (this.ExportFinishList.length > 0) {
              Row() {
                Text(`已导出 (${this.ExportFinishList.length})`)
                  .opacity(0.45)
                  .lineHeight(20)
                  .font({
                    size: 12,
                    weight: 500
                  })
                Blank(1)
                if (this.IsEdit) {
                  CheckboxGroup({ group: 'ExportFinishList' })
                } else {
                  Text("查看文件")
                    .lineHeight(20)
                    .fontColor(this.theme.mainColor)
                    .font({
                      size: 12,
                      weight: 500
                    })
                }
              }
              .width("100%")
              .padding({
                top: 12,
                bottom: 12
              })

              ForEach(this.ExportFinishList, (item: DownloadItem) => {
                this.ShowItem(item, "ExportFinish", 1)
              })
              Blank(1)
              Divider()
            }

          }
          .margin({
            top: this.IsEdit ? 0 : 40
          })
          .width('100%')
          .height("100%")
        }
        .padding({
          left: 20,
          right: 20
        })
        .tabBar(this.TabBuilder(1, "导出"))
      }
      .onChange((index: number) => {
        this.currentTabIndex = index
      })
    }
    .alignContent(Alignment.TopStart)
    .padding({
      top: this.topRectHeight,
      bottom: this.bottomRectHeight
    })
  }

  @Builder
  ShowItem(item: DownloadItem, itemType: string, currentTab: number) { // currentTab: 0 下载;1 导出
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
          if (itemType === "Downloading") {
            Text(`${item.downloadNumber}/${item.Total}`)
              .lineHeight(18)
              .opacity(0.45)
              .font({
                size: 10,
                weight: 500,
              })
          } else {
            Text(`全书已下载`)
              .lineHeight(18)
              .opacity(0.45)
              .font({
                size: 10,
                weight: 500,
              })
          }
        }
        .width("100%")
      }
      .width("55%")

      Blank(1)
      if (!this.IsEdit && itemType === "Downloading") {
        Progress({ value: item.downloadNumber / item.Total * 100, type: ProgressType.Ring })
          .width(32)
      } else if (this.IsEdit && itemType === "Downloading") {
        Checkbox({ name: `${item.bookName}`, group: 'DownloadingItemList' })
      } else if (this.IsEdit && itemType === "DownloadFinish" && currentTab === 0) {
        // 下载页的已下载
        Checkbox({ name: `${item.bookName}`, group: 'DownloadFinishItemList' })
      } else if (itemType === "DownloadFinish" && currentTab === 1) {
        // 导出页的已下载
        Progress({ value: 50, total: 100, type: ProgressType.Capsule })
          .color(this.theme.mainColor)
          .backgroundColor("#FFAF7A")
          .value(50)
          .width(68)
          .height(28)
          .style({ content: '50%', font: { size: 12, weight: 500 }, fontColor: "#FFFFFF", })
      } else if (this.IsEdit && itemType === "ExportFinish") {
        Checkbox({ name: `${item.bookName}`, group: 'ExportFinishList' })
      }
    }
    .padding({
      top: 10,
      bottom: 10
    })
    .width("100%")
  }

  @Builder
  ExportSettingDialog() {
    Column() {
      Row() {
        Text("导出设置")
          .lineHeight(24)
          .font({
            size: 16,
            weight: 500
          })
      }
      .padding({
        top: 12,
        bottom: 12
      })

      this.ExportSettingSwitchItem(0, "替换净化")
      this.ExportSettingSwitchItem(1, "TXT不导出章节名")
      this.ExportSettingSwitchItem(2, "TXT导出图片")
      this.ExportSettingSwitchItem(3, "多线程导出TXT")
      this.ExportSettingSwitchItem(4, "导出同时上传一份至云盘")

      this.ExportSettingClickItem(5, "导出格式", "TXT")
      this.ExportSettingClickItem(6, "导出路径", "/storage/emulated/阅读")
      this.ExportSettingClickItem(7, "文件命名", "")

      Blank(1)
      Divider()
      Row() {
        Text("取消")
      }
      .justifyContent(FlexAlign.Center)
      .width("100%")
      .onClick(() => {
        this.isShowExportSetting = false
      })
      .padding({
        top: 16,
        bottom: 16
      })
    }
    .padding({
      left: 20,
      right: 20
    })
  }

  @Builder
  ExportSettingSwitchItem(index: number, title: string) {
    Row() {
      Text(title)
        .lineHeight(22)
        .font({
          size: 14,
          weight: 400
        })
      Blank(1)
      Toggle({ type: ToggleType.Switch, isOn: this.ExportSettingList[index] })
        .onChange((value) => {
          this.ExportSettingList[index] = value // 按钮状态同步到数组对应元素
        })
      Text(this.ExportSettingList[index].toString()) // 验证按钮是否双向同步
    }
    .padding({
      top: 12,
      bottom: 12
    })
    .width("100%")
  }

  @Builder
  ExportSettingClickItem(index: number, title: string, rightString: string) {
    Row() {
      Text(title)
        .lineHeight(22)
        .font({
          size: 14,
          weight: 400
        })
      Blank(1)
      if (rightString) {
        Text(rightString)
          .lineHeight(20)
          .font({
            size: 12,
            weight: 400
          })
          .opacity(0.45)
      }
      Image($r('app.media.right'))
        .width(24)
        .onClick(() => {
          switch (index) {
            case 5:
              break
            case 6:
              break
            case 7:
              break
          }
        })
    }
    .padding({
      top: 12,
      bottom: 12
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
            if (this.IsEdit === true) {
              // 下面的flex是扩宽完成按钮的点击区域
              Flex({
                justifyContent: FlexAlign.End
              }) {
                Text("完成")
                  .lineHeight(22)
                  .font({
                    size: 14,
                    weight: 400
                  })
              }
              .width(50)
              .onClick(() => {
                this.IsEdit = false
              })
            } else {
              Image($r('app.media.Column_More'))
                .width(24)
                .bindSheet($$this.isShowExportSetting, this.ExportSettingDialog(), {
                  height: 520,
                  showClose: false,
                  dragBar: false,
                  blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
                  onDisappear: () => {
                    // this.clickBookType = ''
                  }
                })
                .onClick(() => {
                  this.isShowExportSetting = true
                })
            }
          } else {
            if (this.IsEdit === true) {
              Text("全选")
                .lineHeight(22)
                .font({
                  size: 14,
                  weight: 400
                })
                .onClick(() => {

                })
            } else {
              Image($r('app.media.return_left'))
                .width(24)
                .onClick(() => {
                  router.back()
                })
            }
          }

        }
        .padding({
          left: index === 0 ? 20 : null,
          right: index === 1 ? 20 : null
        })
        .width("70%")
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
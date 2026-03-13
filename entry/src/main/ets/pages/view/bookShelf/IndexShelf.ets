/**
 * 书架索引页面 - 书籍分类管理和导入功能的主页面
 * 
 * 功能概述：
 * 1. 提供三种书籍类型切换：小说、漫画、有声书
 * 2. 支持多种书籍导入方式：本地导入、网盘导入、网址导入、书单导入
 * 3. 管理书籍展示模式：列表模式、宫格模式
 * 4. 支持分组方式切换：标签分组、文件夹分组
 * 5. 提供搜索和更多功能菜单
 * 
 * 页面结构：
 * - 顶部：书籍类型标签（小说、漫画、有声书）和功能按钮（搜索、更多）
 * - 主体：Tabs切换不同书籍类型的内容
 * - 底部：多种导入对话框（本地导入、网盘导入、网址导入、书单导入）
 * 
 * 数据流：
 * 通过BookBodyContent组件显示具体书籍内容
 * 支持实时刷新和状态同步
 */

import BookMark from '../../../componets/head/BookMark'
import { router } from '@kit.ArkUI'
import BookBodyContent from './components/BookBodyContent'
import { FileHandler } from '../../../common/utils/FileHandler'
import Dialog from '../../../componets/common/Dialog'
import { showMessage } from '../../../componets/common/promptShow'
import { bookShelfImport } from '../../../database/entities/Books'
import { getPasteDataSync, isNetworkUrl, sleep } from '../../../common/utils/utils'
import booksUtil from '../../../common/utils/booksUtils'
import axios, { AxiosResponse } from '@ohos/axios'
import { ThemeItem } from '../../../common/model/Theme'
import { ThemeStorageKey } from '../../../common/constants/Theme'
import { IconTitleVo } from '../../../componetsmodel/IconTitleVo'
import dialogTitleFuction from '../../../componets/common/dialogTitleFuction'

/**
 * 书架索引页面结构体
 * 
 * 职责：
 * 1. 管理书籍类型的切换和状态同步
 * 2. 处理多种书籍导入方式的交互
 * 3. 控制书籍展示模式和分组方式
 * 4. 提供搜索和更多功能菜单
 * 5. 管理各种导入对话框的显示
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 使用export default导出，供其他页面引用
 * - 支持主题颜色配置
 * - 集成多种导入功能
 */
@Component
export default struct IndexShelf {
  /** 当前选中的书籍类型索引：0-小说，1-漫画，2-有声书 */
  @State currentIndex: number = 0
  
  /** 书籍类型标题数组，用于Tabs显示 */
  titleArray: Array<string> = ['小说', '漫画', '有声书']
  
  /** 书籍类型编号：1-文件夹分组，2-标签分组 */
  @State bookTypeNumber: number = 2
  
  /** 书籍展示模式：'列表'表示列表模式，'宫格'表示网格模式 */
  @State EXHIBIT: string = '列表'
  
  /** 分组方式：'标签'表示按标签分组，'文件夹'表示按文件夹分组，变化时触发changeGroup方法 */
  @State @Watch('changeGroup') GROUP: string = '标签'
  
  /** 更多功能菜单项列表 */
  private moreList: IconTitleVo[] = [
    new IconTitleVo($r('app.media.import_svg'), '书籍导入'),
    new IconTitleVo($r('app.media.down_svg'), '下载管理'),
    new IconTitleVo($r('app.media.import_book_svg'), '导入书单'),
    new IconTitleVo($r('app.media.batch_svg'), '批量管理'),
  ]
  
  /**
   * 分组方式变化处理函数
   * 功能：根据GROUP值更新bookTypeNumber
   * 逻辑：GROUP为'文件夹'时bookTypeNumber=1，否则为2
   */
  changeGroup() {
    if (this.GROUP === '文件夹') {
      this.bookTypeNumber = 1
    } else {
      this.bookTypeNumber = 2
    }
  }

  /** 书籍导入对话框显示状态 */
  @State isShowImport: boolean = false
  
  /** 网盘导入对话框显示状态 */
  @State isShowCloudImport: boolean = false
  
  /** 书单导入对话框显示状态 */
  @State isShowImportBookList: boolean = false
  
  /** 顶部矩形高度，从应用存储中读取，用于适配不同设备 */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 应用索引是否可滚动，从应用存储中读取 */
  @StorageProp('APP_INDEX_SCROLLABLE') APP_INDEX_SCROLLABLE: boolean = false
  
  /** 书籍刷新标记，存储在应用存储中，变化时触发书籍列表刷新 */
  @StorageLink('BOOK_IS_BOOK_REFRESHING') isBookRefreshing: number = 0
  
  /** 书单导入数据列表 */
  @State bookImport: bookShelfImport[] = []
  
  /** 应用主题配置，从应用存储中读取，用于UI元素颜色 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /** 网址导入对话框控制器 */
  dialogController: CustomDialogController = new CustomDialogController({
    builder: Dialog({
      title: '网址导入',
      child: () => {
        this.DialogInput("请输入书籍目录或详情页")
      }
    }),
    cornerRadius: 8,
    offset: { dx: 0, dy: 0 }
  })
  
  /** Tabs控制器，用于管理Tabs组件的切换 */
  tabsController: TabsController = new TabsController();
  
  /** 滚动控制器，用于管理水平滚动列表 */
  private scrollController: Scroller = new Scroller();

  /**
   * 构建书架索引页面UI的主要方法
   * 
   * 布局结构：
   * 1. Column布局作为根容器
   * 2. 顶部Flex布局：左侧书籍类型标签 + 右侧功能按钮
   * 3. 主体Tabs组件：切换不同书籍类型的内容
   * 
   * 顶部区域：
   * - 水平滚动列表：小说、漫画、有声书标签
   * - 功能按钮：搜索按钮、更多菜单按钮
   * 
   * 主体区域：
   * - Tabs组件：根据currentIndex切换显示对应类型的书籍内容
   * - 使用BookBodyContent组件显示具体书籍列表
   * 
   * 样式特点：
   * - 使用线性渐变背景，从主题主颜色到次要颜色
   * - 底部圆角设计
   * - 支持滚动控制
   */
  build() {
    Column() {
      // 顶部区域：书籍类型标签和功能按钮
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.End
      }) {
        // 左侧：书籍类型标签水平滚动列表
        Row() {
          List({ scroller: this.scrollController }) {
            ListItem() {
              BookMark({ title: '小说', index: 0, currentIndex: this.currentIndex }).onClick(() => {
                this.currentIndex = 0
                this.tabsController.changeIndex(0)
                console.log(this.currentIndex + '')
              })
            }

            ListItem() {
              BookMark({ title: '漫画', index: 1, currentIndex: this.currentIndex }).onClick(() => {
                this.currentIndex = 1
                this.tabsController.changeIndex(1)
                console.log(this.currentIndex + '')
              })
            }

            ListItem() {
              BookMark({ title: '有声书', index: 2, currentIndex: this.currentIndex }).onClick(() => {
                this.currentIndex = 2
                this.tabsController.changeIndex(2)
                console.log(this.currentIndex + '')
              })
            }
          }
          .height(40)
          .scrollBar(BarState.Off)
          .listDirection(Axis.Horizontal)
        }

        // 右侧：功能按钮区域
        Row() {
          // 网盘导入对话框绑定元素（隐藏）
          Flex() {
          }
          .width(0)
          .height(0)
          .bindSheet($$this.isShowCloudImport, this.CloudImportDialog(), {
            height: 240,
            showClose: false,
            dragBar: false,
            backgroundColor: "white",
            blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
            onDisappear: () => {
              // this.clickBookType = ''
            }
          })

          // 书单导入对话框绑定元素（隐藏）
          Flex() {
          }
          .width(0)
          .height(0)
          .bindSheet($$this.isShowImportBookList, this.ImportBookListDialog(), {
            height: 240,
            showClose: false,
            dragBar: false,
            backgroundColor: "white",
            blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
            onDisappear: () => {
              // this.clickBookType = ''
            }
          })

          // 可见功能按钮：搜索和更多
          Row({ space: 16 }) {
            // 搜索按钮：跳转到搜索页面
            Image($r('app.media.search')).width(24).onClick(() => {
              router.pushUrl({
                url: 'pages/view/search/SearchBook'
              });
            })
            
            // 更多按钮：显示功能菜单和书籍导入对话框
            Image($r('app.media.more')).width(24)
              .bindMenu(this.MenuBuilder())  // 绑定功能菜单
              .bindSheet($$this.isShowImport, this.ImportDialog(), {
                // 书籍导入弹窗绑定元素
                height: 200,
                showClose: false,
                dragBar: false,
                backgroundColor: "rgba(0, 0, 0, 0.15)",
                blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
              })
          }
        }.margin({ bottom: 12 })
      }
      .padding({ top: this.topRectHeight === 0 ? 30 : this.topRectHeight, left: 20, right: 20 })

      Tabs({
        barPosition: BarPosition.Start,
        controller: this.tabsController,
        index: this.currentIndex
      }) {
        ForEach(this.titleArray, () => {
          TabContent() {
            Column() {
              BookBodyContent({
                currentIndex: this.currentIndex,
                EXHIBIT: this.EXHIBIT,
                GROUP: this.GROUP,
                bookTypeNumber: this.bookTypeNumber
              })
            }
          }
        })
      }
      .layoutWeight(1)
      .barWidth(0)
      .barHeight(0)
      .onChange((index) => {
        this.tabsController.changeIndex(index)
        console.log('index:' + index)
        this.currentIndex = index
      })
      .backgroundColor(Color.White)
      .scrollable(this.APP_INDEX_SCROLLABLE)
    }
    .height('100%')
    .linearGradient({
      direction: GradientDirection.Bottom, // 渐变方向
      colors: [[this.theme.mainColor, 0], [this.theme.secondColor, 0.2]] // 数组末尾元素占比小于1时满足重复着色效果
    })
    .borderRadius({ bottomRight: 5, bottomLeft: 5 })
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
            this.changeTheme(index)
          })
      })
    }
  }
  @Builder
  // 书籍导入UI盒子
  ImportClickBox(index: number, image: string, text: string) {
    Column({ space: 8 }) {
      Flex() {
        Image($r(`${image}`))
          .width(24)
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .borderColor("rgba(0, 0, 0, 0.15)")
      .backgroundColor("white")
      .borderWidth(1)
      .padding(12)

      Text(text)
        .lineHeight(20)
        .font({
          size: 12,
          weight: 400
        })
    }
    .padding({
      top: 16,
      bottom: 12,
      left: 21,
      right: 21
    })
    .onClick(async () => {
      switch (index) {
        case 0:
          // 本地导入
          //   router.pushUrl({
          //     url: 'pages/view/bookShelf/LocalImportPage'
          //   });
          let FileResult = await FileHandler.documentPickerFile(undefined, ['.txt', '.epub', '.mobi', '.azw', '.azw3'])
          FileResult.forEach((item) => {
            FileHandler.CopyFile(item, this.currentIndex)
          })
          this.isShowImport = false
          setTimeout(() => {
            this.isBookRefreshing++
          }, 500)
          break
        case 1:
          // 云盘导入
          this.isShowCloudImport = true
          break
        case 2:
          // 网址导入
          this.dialogController.open();
          break
        case 3:
          // 书单粘贴导入
          this.pasteBookImport()
          break
        case 4:
          //书单本地导入
          let res = await FileHandler.documentPickerFile(1, ['.json'])
          FileHandler.ReadJSONFile(res[0]).then(async result => {
            if (result.length > 0) {
              this.bookImport = JSON.parse(result) as bookShelfImport[]
              this.bookImport.length > 0 ? await booksUtil.batchAdd(this.bookImport, this.currentIndex) : ''
              showMessage(this.bookImport.length > 0 ? `相关书单书籍内容导入${this.bookImport.length}本` :
                '未找到相关书单书籍内容')
            }
          })
          setTimeout(() => {
            this.isBookRefreshing++
          }, 500)
          break
      }
    })
  }

  @Builder
  // 书籍导入弹窗
  ImportDialog() {
    Column() {
      GridRow({
        columns: 3
      }) {
        GridCol() {
          this.ImportClickBox(0, "app.media.my_center_file_icon", "本地导入")
        }

        GridCol() {
          this.ImportClickBox(1, "app.media.my_center_cloud_icon", "网盘导入")
        }

        GridCol() {
          this.ImportClickBox(2, "app.media.official_website", "网址导入")
        }
      }
      .height("60%")

      Divider()

      Column() {
        Text('取消').fontSize(16).fontWeight(400)
          .lineHeight(24)
      }
      .onClick(() => {
        this.isShowImport = false
      })
      .alignItems(HorizontalAlign.Center)
      .padding({
        top: 16
      })
    }
  }

  @Builder
  DialogInput(placeholder: string, maxlength?: number) {
    Row() {
      TextInput({ placeholder: placeholder })// .maxLength(maxlength)
        // .showCounter(true)
        .cancelButton({
          icon: {
            src: $r('app.media.close')
          }
        })
    }
    .margin({
      top: 16,
      bottom: 16
    })
  }

  @Builder
  // 书籍导入-网盘导入弹窗
  CloudImportDialog() {
    Column() {
      Row() {
        Text("网盘导入")
          .lineHeight(24)
          .font({
            size: 16,
            weight: 500
          })
      }
      .padding({
        top: 12,
        bottom: 12,
      })

      Divider()

      Row({ space: 16 }) {
        Flex({
          wrap: FlexWrap.Wrap,
          alignContent: FlexAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          Text("坚")
            .lineHeight(24)
            .font({
              size: 16,
              weight: 500
            })
            .opacity(0.45)
        }
        .backgroundColor("rgba(0, 0, 0, 0.04)")
        .width(40)
        .height(40)

        Text("坚果云")
          .lineHeight(22)
          .font({
            size: 14,
            weight: 500
          })
          .opacity(0.88)
      }
      .padding({
        top: 12,
        bottom: 12,
      })
      .width("100%")
      .onClick(() => {

      })

      Row({ space: 16 }) {
        Flex({
          wrap: FlexWrap.Wrap,
          alignContent: FlexAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          Image($r('app.media.add')).width(24)

        }
        .backgroundColor("rgba(0, 0, 0, 0.04)")
        .width(40)
        .height(40)

        Text("添加webdav网盘")
          .lineHeight(22)
          .font({
            size: 14,
            weight: 500
          })
          .opacity(0.88)
      }
      .padding({
        top: 12,
        bottom: 12,
      })
      .width("100%")
      .onClick(() => {

      })

      Divider()

      Column() {
        Text('取消').fontSize(16).fontWeight(400)
          .lineHeight(24)
      }
      .onClick(() => {
        this.isShowCloudImport = false
      })
      .alignItems(HorizontalAlign.Center)
      .padding({
        top: 16
      })
    }
    .padding({
      left: 20,
      right: 20
    })
  }

  @Builder
  // 导入书单弹窗
  ImportBookListDialog() {
    Column() {
      Flex({
        direction: FlexDirection.Row,
        wrap: FlexWrap.Wrap,
        alignContent: FlexAlign.Center,
        justifyContent: FlexAlign.Start
      }) {
        Grid() {
          GridItem() {
            this.ImportClickBox(3, "app.media.Paste", "粘贴导入")
          }

          GridItem() {
            this.ImportClickBox(4, "app.media.my_center_file_icon", "本地导入")
          }
        }
        .columnsTemplate("1fr 1fr 1fr 1fr")
        .padding({
          top: 12
        })
      }
      .height("60%")

      Divider()

      Column() {
        Text('取消').fontSize(16).fontWeight(400)
          .lineHeight(24)
      }
      .onClick(() => {
        this.isShowImportBookList = false
      })
      .alignItems(HorizontalAlign.Center)
      .padding({
        top: 16
      })
    }
  }

  changeTheme(themeNum: number) {
    // 右上角更多
    switch (themeNum) {
      case 0:
        // 书籍导入弹窗
        this.isShowImport = true
        break
      case 1:
        // 下载管理页
        router.pushUrl({
          url: 'pages/view/bookShelf/DownloadManagementPage'
        });
        break
      case 2:
        // 导入书单弹窗
        this.isShowImportBookList = true
        break
      case 3:
        router.pushUrl({
          url: 'pages/view/bookShelf/Manage/BookManagePage',
          params: {
            currentIndex: this.currentIndex,
            EXHIBIT: this.EXHIBIT,
            bookTypeNumber: this.bookTypeNumber
          }
        })
        break
    }
  }

  //书单粘贴导入
  async pasteBookImport() {
    try {
      let url = getPasteDataSync()
      if (!url) {
        showMessage('未获取到粘贴信息，请求默认数据')
        await sleep()
        return
      }
      if (!isNetworkUrl(url ?? '')) {
        showMessage('复制的链接不正确')
        await sleep()
        url = undefined
        return
      }
      const res: AxiosResponse = await axios
        .get(url);
      this.bookImport = res.data as bookShelfImport[]
      showMessage(this.bookImport.length > 0 ? `相关书单书籍内容导入${this.bookImport.length}本` :
        '未找到相关书单书籍内容')
      this.bookImport.length > 0 ? booksUtil.batchAdd(this.bookImport, this.currentIndex) : ''
    } catch (err) {
      console.error('错误 ' + err);
    }
  }
}
/**
 * ============================================
 * ReaderPage.ets - 阅读器主页面组件
 * ============================================
 * 
 * 【功能说明】
 * 这是电子书阅读器的核心页面组件，提供以下功能：
 * - TXT 小说阅读展示
 * - 章节切换与目录导航
 * - 阅读设置（亮度、字号、排版等）
 * - 换源功能（更换书籍来源）
 * - 内容净化（去除广告和乱码）
 * - 听书功能（音频播放）
 * - 下载管理
 * - 网络导入书籍
 * 
 * 【使用方法】
 * 1. 从 BookDetailPage 页面跳转至此，需传递参数：
 *    - bookData: 书籍基本信息
 *    - clickBookChapter: 点击的章节序号
 *    - txtFile: 章节列表数组
 * 2. 点击页面中间区域显示/隐藏设置面板
 * 3. 使用底部滑块快速切换章节
 * 4. 点击"设置"按钮进入详细阅读设置
 * 
 * 【参数说明】
 * interface ParamsObj {
 *   bookData: BookList,         // 书籍数据对象（书名、作者、封面等）
 *   clickBookChapter: number,   // 初始章节索引（从 0 开始）
 *   txtFile: chaptersItem[]     // 章节列表数组
 * }
 * 
 *
 * @author cyd
 * @version 1.0
 */

import battery from 'ets/componets/common/battery';
import Dialog from 'ets/componets/common/Dialog';
import { router } from '@kit.ArkUI';
import sourceView from './sourceView';
import { NetworkInput } from 'ets/componets/Reader/NetworkInput';
import DownloadSettingDialog from '../../../componets/Reader/DownloadSettingDialog';
import LayoutMoreDialog from '../../../componets/Reader/LayoutMoreDialog';
import { TxtContentHandler } from '../../../componets/Reader/TxtContentHandler';
import { MusicPlayer } from 'ets/componets/Reader/MusicPlayer';
import purificationView from './purificationView';
import { chaptersItem } from 'ets/componets/dataList/ReaderChaptersItem';
import { BookList } from 'ets/componets/dataList/bookList';

// ============================================
// 参数接口定义
// ============================================
interface ParamsObj {
  bookData: BookList,           // 书籍数据：包含书名、作者、封面链接等信息
  clickBookChapter: number,     // 点击的章节序号（用于定位到指定章节开始阅读）
  txtFile: chaptersItem[]       // TXT 小说的章节列表数组
}

@Entry
@Component
struct ReaderPage {
  // ============================================
  // 状态变量定义
  // ============================================
  
  // 底部矩形高度（适配刘海屏/折叠屏的系统区域高度）
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  // 顶部矩形高度（适配刘海屏/折叠屏的系统区域高度）
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  // 阅读器左右边距（单位：vp）
  @State ReaderPadding: number = 24 
  
  // 控制上方设置面板显示状态
  @State isShowSetting: boolean = true
  
  // 控制下载弹窗显示状态
  @State isShowDownload: boolean = false
  
  // 控制听书面板显示状态
  @State isShowListen: boolean = false
  
  // 控制内容设置面板显示状态（字号、亮度等）
  @State isShowContentSetting: boolean = false
  
  // 控制更多布局设置弹窗显示状态
  @State isShowMoreLayout: boolean = false
  
  // 当前章节索引（从 0 开始计数）
  @State CurrentChapters: number = 0
  
  // 总章节数
  @State TotalChapters: number = 0
  
  // 当前亮度值（0-100）
  @State CurrentLuminance: number = 0 
  
  // 当前字号大小（12-48）
  @State CurrentFontSize: number = 20 
  
  // 行高倍数（影响文字间距）
  @State LineHeight: number = 1.8
  
  // 段落间距（单位：vp，负数表示紧凑）
  @State ParagraphSpacing: number = -2
  
  // 控制换源面板显示状态
  @State isShowSource: boolean = false
  
  // 控制净化面板显示状态
  @State isShowPurification: boolean = false
  
  // TXT 小说章节文件数组
  @State txtFile: chaptersItem[] = [];
  
  // ============================================
  // 网址导入弹窗控制器
  // ============================================
  dialogController: CustomDialogController = new CustomDialogController({
    builder: Dialog({
      title: '加入书架',              // 弹窗标题
      CancelString: "暂不加入",        // 取消按钮文本
      ConfirmString: "加入书架",       // 确认按钮文本
      child: () => {
        this.DialogString()           // 调用弹窗内容构建器
      },
    }),
    cornerRadius: 16,                 // 圆角半径
    gridCount: 4,                     // 网格数量
    offset: { dx: 0, dy: -300 }       // 弹窗偏移量
  })

  /**
   * 页面即将出现时调用
   * 用于初始化页面数据和接收路由参数
   */
  async aboutToAppear() {
    // 详情页加了个目录序号参数，所以修改了一下 params 的类型，不影响之前的 bookData，但需要多'.'一次
    // 上一个页面是 BookDetailPage
    let temp = router.getParams() as ParamsObj
    
    // 打印日志：输出书籍的文件链接
    console.log('router ReaderPage:' + temp.bookData.fileLink)
    
    // 保存 TXT 小说章节列表
    this.txtFile = temp.txtFile 
    
    // 计算总章节数
    this.TotalChapters = this.txtFile.length
    
    // 设置初始章节位置
    this.CurrentChapters = temp.clickBookChapter
  }

  build() {
    // 使用 Stack 布局实现图层叠加
    Stack() {
      // ============================================
      // 上层：控制面板（可隐藏）
      // ============================================
      Column() {
        if (this.isShowSetting) {
          // 阅读器 - 上方弹框
          Column() {
            // 顶部返回栏
            Row({ space: 8 }) {
              // 返回按钮
              Image($r("app.media.ic_public_return_left"))
                .width(24)
                .onClick(() => {
                  router.back()  // 返回上一页
                })
              
              // 章节标题显示
              Text(`${this.txtFile[this.CurrentChapters]?.chapterTitleNumber} ${this.txtFile[this.CurrentChapters]?.title}`
                .replace(new RegExp('\\s{1,}', 'g'), ' ')  // 将多个空格替换为一个空格
                .replaceAll('=', ''))                      // 移除等号
                .layoutWeight(1)                           // 占满剩余空间
                .maxLines(1)                               // 最多显示一行
                .textOverflow({ overflow: TextOverflow.Ellipsis })  // 超出显示省略号
              
              // 右上角工具栏
              Row({ space: 16 }) {
                // 刷新按钮（目前未实现功能）
                Image($r("app.media.refresh"))
                  .width(24)
                  .onClick(() => {

                  })
                
                // 下载按钮
                Image($r("app.media.down"))
                  .width(24)
                  .onClick(() => {
                    this.isShowDownload = true  // 显示下载设置弹窗
                  })
                  .bindSheet($$this.isShowDownload, this.DownloadDialog(), {
                    height: 500,
                    showClose: false,
                    dragBar: false,
                    blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
                    onDisappear: () => {
                      // 弹窗消失后的回调
                    }
                  })
                
                // 更多按钮（目前未实现功能）
                Image($r("app.media.more"))
                  .width(24)
                  .onClick(() => {

                  })
              }
            }
            .padding({ top: 12, left: 20, right: 20, bottom: 12 })
            .width("100%")

            // 网络输入组件（导入在线书籍）
            Row() {
              NetworkInput()
            }
            .padding({ top: 8, left: 20, right: 20, bottom: 12 })
            .width("100%")

            Divider()  // 分隔线
          }
          .backgroundColor("white")
          .transition(TransitionEffect.move(TransitionEdge.TOP).animation({ duration: 500 }))  // 顶部滑入动画

          Blank(1)  // 弹性空白区域
            .onClick(() => {
              this.isShowSetting = false  // 点击空白区域隐藏顶部面板
            })

          // 阅读器 - 下方弹框
          Column({ space: 20 }) {
            Divider()
            
            // 快捷操作区（换源、净化）
            if (!this.isShowContentSetting) {
              Row() {
                // 换源按钮
                Button({ type: ButtonType.Normal }) {
                  Row({ space: 4 }) {
                    Image($r("app.media.change_source_icon")).width(16).height(16)
                    Text("换源").fontColor($r('app.string.color_black_65'))
                      .font({ size: 14, weight: 400 })
                  }
                }
                .borderRadius(8)
                .height(40)
                .width("45%")
                .backgroundColor("rgba(0, 0, 0, 0.06)")
                .bindSheet($$this.isShowSource, this.sourceView(), {
                  height: '95%',
                  showClose: false,
                  dragBar: false,
                  maskColor: 'rgba(0,0,0,0.6)',
                  onDisappear: () => {
                    console.log('隐藏换源面板')
                  }
                })
                .onClick(() => {
                  this.isShowSource = true
                })

                // 净化按钮
                Button({ type: ButtonType.Normal }) {
                  Row({ space: 4 }) {
                    Image($r("app.media.purify_icon")).width(16).height(16)
                    Text("净化").fontColor($r('app.string.color_black_65'))
                      .font({ size: 14, weight: 400 })
                  }
                  .bindSheet($$this.isShowPurification, this.purificationView(), {
                    height: '40%',
                    showClose: false,
                    dragBar: false,
                    maskColor: 'rgba(0,0,0,0.6)',
                    onDisappear: () => {
                      console.log('隐藏净化面板')
                    }
                  })
                  .onClick(() => {
                    this.isShowPurification = true
                  })
                }
                .borderRadius(8)
                .height(40)
                .width("45%")
                .backgroundColor("rgba(0, 0, 0, 0.06)")
              }
              .padding({ top: 12, left: 24, right: 24 })
              .justifyContent(FlexAlign.SpaceBetween)
              .width("100%")

              // 章节导航区
              Row({ space: 16 }) {
                // 上一章按钮
                Text("上一章").onClick(() => {
                  if (this.CurrentChapters > 0) {
                    this.CurrentChapters--  // 递减章节索引
                  }
                })

                // 章节进度滑块
                Slider({
                  value: this.CurrentChapters,
                  max: this.TotalChapters - 1,
                  min: 0,
                  step: 1,
                  style: SliderStyle.InSet
                })
                  .selectedColor('rgba(0, 0, 0, 0.04)')
                  .blockSize({ width: 30, height: 30 })
                  .layoutWeight(1)
                  .onChange((value) => {
                    this.CurrentChapters = Number(value.toFixed(0))  // 更新当前章节
                  })

                // 下一章按钮
                Text("下一章").onClick(() => {
                  if (this.CurrentChapters < this.TotalChapters - 1) {
                    this.CurrentChapters++  // 递增章节索引
                  }
                })
              }
              .padding({ left: 24, right: 24 })
              .width("100%")
            } else {
              // ============================================
              // 详细设置面板
              // ============================================
              Column({ space: 24 }) {
                // 亮度调节
                Row({ space: 16 }) {
                  Text('亮度')
                  Slider({
                    value: this.CurrentLuminance,
                    max: 100,
                    min: 0,
                    step: 1,
                    style: SliderStyle.InSet
                  })
                    .selectedColor('rgba(0, 0, 0, 0.04)')
                    .blockSize({ width: 30, height: 30 })
                    .layoutWeight(1)
                    .onChange((value) => {
                      this.CurrentLuminance = value
                    })
                  Row() {
                    Text('跟随系统')  // 跟随系统亮度选项（待实现）
                  }
                }

                // 字号调节
                Row({ space: 16 }) {
                  Text('字号')
                  Slider({
                    value: this.CurrentFontSize,
                    max: 48,
                    min: 12,
                    step: 1,
                    style: SliderStyle.InSet
                  })
                    .selectedColor('rgba(0, 0, 0, 0.04)')
                    .blockSize({ width: 30, height: 30 })
                    .layoutWeight(1)
                    .onChange((value) => {
                      this.CurrentFontSize = value
                    })
                  Row() {
                    Button('字体')  // 字体选择（待实现）
                  }
                }

                // 排版预设
                Row({ space: 16 }) {
                  Text('排版')
                  // 紧凑模式
                  Button('紧凑')
                    .onClick(() => {
                      this.LineHeight = 1.6
                      this.ParagraphSpacing = -4
                    })
                  // 适中模式
                  Button('适中')
                    .onClick(() => {
                      this.LineHeight = 1.8
                      this.ParagraphSpacing = -2
                    })
                  // 宽松模式
                  Button('宽松')
                    .onClick(() => {
                      this.LineHeight = 2
                      this.ParagraphSpacing = 0
                    })
                  Row() {
                    // 更多排版设置
                    Button('更多')
                      .bindSheet($$this.isShowMoreLayout, this.LayoutMoreDialog(), {
                        height: 500,
                        showClose: false,
                        dragBar: false,
                        blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
                        onDisappear: () => {}
                      })
                      .onClick(() => {
                        this.isShowMoreLayout = true
                      })
                  }
                }

                // 背景色（待实现）
                Row({ space: 16 }) {
                  Text('背景')
                  Blank(1)
                  Row() {
                    Button('更多')
                  }
                }

                // 阅读方式选择（待完善）
                Row({ space: 16 }) {
                  Button('自动阅读')
                  Button('仿真翻页')
                  Button('更多设置')
                }
              }
              .padding({ left: 20, right: 20 })
            }
            
            // 底部功能网格
            Grid() {
              GridItem() {
                Column() {
                  Image($r("app.media.outlined")).width(24)
                  Text("目录")
                }
              }

              GridItem() {
                Column() {
                  Image($r("app.media.listen")).width(24)
                  Text("听书")
                }
              }
              .bindContentCover($$this.isShowListen, this.BookListen(), {
                modalTransition: ModalTransition.DEFAULT,
                backgroundColor: "rgba(51, 106, 128, 0.75)"
              })
              .onClick(() => {
                this.isShowListen = true
              })

              GridItem() {
                Column() {
                  Image($r("app.media.night_icon")).width(24)
                  Text("夜间")
                }
              }

              GridItem() {
                Column() {
                  Image($r(this.isShowContentSetting ? "app.media.my_center_set_icon_fill" :
                    "app.media.my_center_set_icon"))
                    .width(24)
                  Text("设置")
                }
                .onClick(() => {
                  this.isShowContentSetting = !this.isShowContentSetting  // 切换设置面板显示
                })
              }
            }
            .padding({ left: 24, right: 24 })
            .columnsTemplate("1fr 1fr 1fr 1fr")  // 四列均分
            .width("100%")
            .height(60)
          }
          .backgroundColor("white")
          .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 500 }))  // 底部滑出动画
        }
      }
      .width("100%")
      .height("100%")
      .zIndex(2)
      .enabled(this.isShowSetting)

      // ============================================
      // 下层：小说内容显示区
      // ============================================
      Column() {
        // 顶部空白占位
        Row() {
        }
        .width("100%")
        .height(40)

        // TXT 小说内容主体
        Column() {
          // txt 小说内容显示处理组件
          TxtContentHandler({
            txtFile: this.txtFile,               // 章节数据
            CurrentChapters: this.CurrentChapters, // 当前章节索引
            LineHeight: this.LineHeight,          // 行高设置
            CurrentFontSize: this.CurrentFontSize, // 字号设置
            ParagraphSpacing: this.ParagraphSpacing, // 段落间距
          })
        }
        .padding({
          left: this.ReaderPadding,
          right: this.ReaderPadding
        })
        .layoutWeight(1)  // 占据剩余空间

        Blank(1)
        
        // 底部状态栏
        Row({ space: 4 }) {
          Text("1/14  0.1%")  // 阅读进度显示（待绑定实际数据）
          Blank(1)
          TextClock({ timeZoneOffset: -8 })  // 时钟组件
            .format('hh:mm')
            .fontSize(12)
            .fontWeight(400)
          battery()  // 电池电量组件
        }
        .padding({ top: 16, bottom: 16, left: 24, right: 24 })
        .width("100%")

      }
      .height("100%")
      .onClick(() => {
        this.isShowSetting = true  // 点击页面显示控制面板
      })
    }
    .padding({
      top: this.topRectHeight,
      bottom: this.bottomRectHeight
    })
    .height('100%')
    .width('100%')
  }

  // ============================================
  // 自定义构建器
  // ============================================

  /**
   * 构建换源面板
   */
  @Builder
  sourceView() {
    Column() {
      Column() {
        Row().width(36).height(4).backgroundColor($r('app.string.color_black_15')).borderRadius(12)
      }
      .padding({ top: 12 })
      sourceView()
    }
  }

  /**
   * 构建净化面板
   */
  @Builder
  purificationView() {
    Column() {
      purificationView({
        isShowPurification: this.isShowPurification
      })
    }
  }

  /**
   * 构建对话框提示文本
   */
  @Builder
  DialogString() {
    Row() {
      Text("喜欢就加入书架吧")
        .lineHeight(22)
        .font({ size: 14, weight: 400 })
        .fontColor($r("app.string.color_black_45"))
    }
    .margin({ top: 12, bottom: 16 })
  }

  /**
   * 返回键按下时的回调
   * 弹出确认对话框
   */
  onBackPress() {
    this.dialogController.open();
    return true
  }

  /**
   * 构建听书面板
   */
  @Builder
  BookListen() {
    MusicPlayer({ WidthMinus: 118, isShowListen: this.isShowListen })
      .width("100%")
      .height("100%")
  }

  /**
   * 构建下载设置弹窗
   */
  @Builder
  DownloadDialog() {
    Column() {
      DownloadSettingDialog({
        isShowDownload: this.isShowDownload,
        isShowSetting: this.isShowSetting,
      })
    }
  }

  /**
   * 构建更多布局设置弹窗
   */
  @Builder
  LayoutMoreDialog() {
    LayoutMoreDialog({ ReaderPadding: this.ReaderPadding })
      .height(500)
      .width("100%")
  }
}

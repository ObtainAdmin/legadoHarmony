// ============ 导入模块 ============
import { router } from '@kit.ArkUI'; // 页面路由导航 API
import { ThemeStorageKey } from '../../../common/constants/Theme'; // 主题存储键常量
import { ThemeItem } from '../../../common/model/Theme'; // 主题类型定义

/**
 * @Entry - 页面入口装饰器
 * @Component - 组件装饰器
 * @struct HelpCenterPage - 帮助中心页面组件类
 */
@Entry
@Component
struct HelpCenterPage {
  
  // ============ 安全区域适配 ============
  
  /** @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
   * 底部安全区域高度（Home Indicator）
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** @StorageLink('topRectHeight') topRectHeight: number = 0
   * 顶部安全区域高度（刘海屏）
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0

  // ============ 搜索相关状态 ============
  
  /** @State SearchValue: string = ""
   * 搜索框输入内容
   */
  @State SearchValue: string = ""
  
  /** @State MoreQuestionsIndex: number = 0
   * 右侧问题分类列表的选中索引
   */
  @State MoreQuestionsIndex: number = 0
  
  /** @State MoreQuestionsRightWidth: number | string = 0
   * 右侧面板宽度（暂未使用）
   */
  @State MoreQuestionsRightWidth: number | string = 0

  // ============ 热门问题分类 ============
  
  /**
   * questionsList - 热门问题分类标签列表
   * 横向滚动展示的分类按钮
   */
  @State questionsList: Array<string> = ["热门问题", "校验问题", "书源问题", "订阅问题", "xx 问题"]

  /**
   * questionsShowList - 热门问题详情列表
   * 显示在"猜你想问"区域内的常见问题
   */
  @State questionsShowList: Array<string> = [
    "1、为什么第一次安装好后什么都没有？",
    "2、遇到目录为空怎么办？",
    "3、替换净化是什么？",
  ]
  
  // 教程问题列表（已注释）
  // @State tutorialQuestionsList: Array<string> = [
  //   "书源制作教程",
  //   "订阅源源制作教程",
  //   "替换净化教程",
  // ]

  // ============ 更多问题数据 ============
  
  /**
   * MoreQuestionsSideBarList - 侧边栏分类列表
   * 点击切换右侧内容区域的分类
   */
  @State MoreQuestionsSideBarList: Array<string> = [
    "热门问题",
    "书源校验",
    "书源",
    "订阅源",
    "备份",
    "替换净化",
    "有声书",
    "朗读引擎",
    "其他问题",
  ]
  
  /**
   * MoreQuestionsItemList - 默认分类下的问题列表
   * 显示在当前选中分类下的具体问题项
   */
  @State MoreQuestionsItemList: Array<string> = [
    "为什么第一次安装好后打开什么都没有",
    "遇到目录为空怎么办",
    "替换净化是什么",
    "如何进行云备份",
    "如何导入本地书籍"
  ]

  // ============ 滚动控制器 ============
  
  /** scroller: Scroller - 主滚动容器控制器
   * 用于控制横向滑动和 Edge.End 跳转
   */
  scroller: Scroller = new Scroller()

  // ============ 主题颜色绑定 ============
  
  /** @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
   * 响应式主题颜色绑定
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  // ============ UI 构建方法 - build() ============
  
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column (背景层)
   * ├─ Flex (固定头部：返回按钮 + 标题 + 搜索框)
   * └─ Scroll (横向滚动主内容区)
   *    ├─ Flex
   *    │  ├─ Column (左侧：猜你想问 + 常见问题)
   *    │  └─ Column (右侧：更多问题的双列布局)
   *    │       ├─ SideBarContainer (侧边栏分类)
   *    │       └─ Column (右侧问题列表)
   */
  build() {
    Column() {
      // ========== 顶部固定内容 ==========
      Flex({
        direction: FlexDirection.Column, // 垂直布局（占位用）
        alignItems: ItemAlign.Start, // 左对齐
        justifyContent: FlexAlign.Start // 顶对齐
      }) {
        
        // ========== 标题栏 ==========
        Flex() { // 水平弹性布局
          // 左侧返回按钮
          Column() {
            Image($r("app.media.return_left"))
              .size({ width: 24, height: 24 })
              .interpolation(ImageInterpolation.Medium) // 图片插值算法
              .onClick(() => {
                router.back() // 返回上一页
              })
          }
          .alignItems(HorizontalAlign.Start)
          .width('33%') // 占 33% 宽度

          // 中间标题
          Column() {
            Text(`帮助中心`)
              .lineHeight(24)
              .font({
                family: "PingFang SC",
                size: 16,
                weight: 500,
                style: FontStyle.Normal,
              })
          }.width('33%') // 占 33% 宽度
        }
        .padding({
          top: 12,
          bottom: 12,
        })
        .height(48) // 固定高度
        .width("100%")

        // ========== 搜索框 ==========
        Search({ value: this.SearchValue, placeholder: '搜索问题关键词', icon: "/common/images/search.svg" })
          .width("100%")
          .height(40)
        // .onChange(this.onChange) // 实时监听输入（未启用）
        // .onSubmit(this.onSubmit) // 提交事件（未启用）
      }
      .padding({
        left: 20,
        right: 20
      })
      .height(110) // 固定高度

      // ========== 横向滚动的主内容区 ==========
      Scroll(this.scroller) {
        Flex({
          direction: FlexDirection.Row, // 横向并排两栏
        }) {
          
          // ========== 左侧栏（猜你想问）==========
          Flex({
            direction: FlexDirection.Column,
          }) {
            // ========== 分类标题行 ==========
            Column() {
              Row() {
                Text("猜你想问")
                  .lineHeight(24)
                  .font({
                    family: "PingFang SC",
                    size: 16,
                    weight: 500,
                    style: FontStyle.Normal,
                  })
                Blank(20) // 空白填充
                
                // 更多问题链接
                Row() {
                  Text("更多问题")
                    .lineHeight(22)
                    .opacity(0.45) // 半透明灰色
                    .font({
                      family: "PingFang SC",
                      size: 14,
                      weight: 400,
                      style: FontStyle.Normal,
                    })
                  Image($r("app.media.right")) // 右箭头
                    .width(24)
                    .height(24)
                    .opacity(0.45)
                    .interpolation(ImageInterpolation.Medium)
                }
                .onClick(() => {
                  this.scroller.scrollEdge(Edge.End) // 滑动到最右边显示更多问题
                })
              }
              .width("100%")

              // ========== 问题分类横向滚动 ==========
              Row() {
                Scroll() {
                  Row({ space: 12 }) {
                    ForEach(this.questionsList, (item: string, index) => {
                      this.question(item, index) // 调用问答构建器
                    })
                  }
                }
                .scrollBar(BarState.Off)
                .scrollable(ScrollDirection.Horizontal) // 横向滚动
              }
              .margin({
                top: 16,
                bottom: 16
              })
              .width("100%")

              // ========== 常见问题列表 ==========
              ForEach(this.questionsShowList, (item: string, index) => {
                Row() {
                  Text(item)
                    .lineHeight(22)
                    .font({
                      family: "PingFang SC",
                      size: 14,
                      weight: 400,
                      style: FontStyle.Normal,
                    })
                  Blank(20) // 空白填充
                  Image($r("app.media.right")) // 右箭头
                    .width(24)
                    .height(24)
                    .interpolation(ImageInterpolation.Medium)
                    .onClick(() => {
                      // TODO: 查看问题详情
                    })
                }
                .margin({
                  top: 12,
                  bottom: 12
                })
                .width("100%")
              })
            }
            .borderRadius(12) // 圆角 12
            .width("100%") // 占满宽度
            .backgroundColor("#FFFFFF") // 白色背景
            .padding({
              top: 20,
              left: 16,
              right: 16
            })
            .margin({
              bottom: 16
            })
          }
          .padding({
            left: 20,
            right: 20
          })

          // ========== 右侧栏（更多问题）==========
          Column() {
            // 侧边栏 + 内容双列布局
            Row() {
              // 左侧侧边栏分类
              SideBarContainer(SideBarContainerType.Overlay) { // 覆盖式侧边栏
                Column() {
                  ForEach(this.MoreQuestionsSideBarList, (item: string, index) => {
                    Row() {
                      // 高亮竖线（仅在选中时显示）
                      if (this.MoreQuestionsIndex == index) {
                        Line({ width: 3, height: 16 })
                          .backgroundColor(this.theme.mainColor) // 使用主题色
                      }
                      // 分类文本
                      Text(item)
                        .lineHeight(22)
                        .font({
                          family: "PingFang SC",
                          size: 14,
                          weight: 500,
                          style: FontStyle.Normal,
                        })
                        .width("100%")
                        .textAlign(TextAlign.Center)
                    }
                    .height(48) // 固定高度
                    .width("100%")
                    .backgroundColor(this.MoreQuestionsIndex == index ? "#F5F5F5" : "white") // 选中浅色背景
                    .onClick(() => {
                      this.MoreQuestionsIndex = index // 更新选中索引
                    })
                  })
                }
              }
              .showControlButton(false) // 不显示控制面板按钮
              .width("24.4%") // 24.4% 宽度（约 88/360）
              .borderRadius({
                topRight: 12,
                bottomRight: 12
              })

              // 右侧内容显示区
              Column() {
                ForEach(this.MoreQuestionsItemList, (item: string, index) => {
                  Row() {
                    Text(item)
                      .width(200) // 固定宽度
                      .lineHeight(22)
                      .font({
                        family: "PingFang SC",
                        size: 14,
                        weight: 500,
                        style: FontStyle.Normal,
                      })
                    Blank(20) // 空白填充
                    Image($r("app.media.right")) // 右箭头
                      .width(24)
                      .height(24)
                      .opacity(0.45) // 半透明
                      .interpolation(ImageInterpolation.Medium)
                  }
                  .padding({
                    top: 12,
                    bottom: 12
                  })
                  .width("100%")
                })
              }
              .padding({
                left: 16,
                right: 16
              })
              .height("100%")
              .width("75.6%") // 剩余宽度（360-88)/360

            }
            .width("100%")
            .height(432) // 固定高度
          }

        }
        .width("200%") // 总宽度 200%，支持横向滚动
      }
      .scrollBar(BarState.Off) // 隐藏滚动条
      .scrollable(ScrollDirection.Horizontal) // 横向滚动
      .scrollSnap({ snapAlign: ScrollSnapAlign.START, snapPagination: "100%" }) // 吸附效果
      
    }
    .height("100%")
    .backgroundColor("#F5F5F5") // 浅灰背景
    .padding({
      top: this.topRectHeight
    })
  }

  // ============ 构建器：问题标签 ==========
  
  /**
   * @Builder question - 问题标签构建器
   * 
   * @param title - 标签文本
   * @param index - 索引号
   *   索引 0 特殊处理：高亮显示（主题色+深色背景）
   * 
   * @returns Column 组件，圆角卡片样式
   */
  @Builder
  question(title: string, index: number) {
    Column() {
      Text(title)
        .fontColor(index == 0 ? this.theme.mainColor : 'rgba(0, 0, 0, 0.88)') // 首项为主题色
        .fontSize(12) // 小字号
        .fontWeight(700) // 粗体
    }
    .borderRadius(8) // 圆角 8
    .padding(8) // 内边距 8
    .backgroundColor(index == 0 ? this.theme.secondColor : 'rgb(240,240,240)') // 首项次色背景，其余浅灰
  }
}

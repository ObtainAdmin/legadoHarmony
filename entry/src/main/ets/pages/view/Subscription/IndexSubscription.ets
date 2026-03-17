// import router from '@ohos.router'; // 引入路由管理器

/**
 * @file IndexSubscription.ets
 * @description 订阅首页组件 - 展示订阅分类列表（小说、漫画、收藏等），提供搜索和添加订阅功能
 * @component IndexSubscription - 订阅主页面的主结构体组件
 * @component SubscriptionCard - 订阅卡片子组件，用于展示各分类下的订阅源列表
 */

@Component
export default struct IndexSubscription {
  /** 更多操作菜单列表：粘贴导入、网络导入、本地导入、新建订阅、新建分组、批量管理 */
  MoreList: string[] = ['粘贴导入', '网络导入', '本地导入', '新建订阅', '新建分组', '批量管理']
  /** 小说分类数据列表 */
  NovelList: string[] = ['起点中文网', '小说']
  /** 漫画分类数据列表 */
  CartoonList: string[] = ['卡通']
  /** 收藏分类数据列表 */
  CollectList: string[] = ['起点中文网', '收藏', '收藏', '收藏']

  /** 搜索框绑定的输入值，双向绑定实现实时搜索 */
  @State SearchValue: string = ""
  /** 是否显示编辑管理模式，控制批量编辑功能开关 */
  @State ShowEditManage: Boolean = false
  /** 是否显示新建订阅弹窗，控制半模态弹窗的显示与隐藏 */
  @State NewSubscription: Boolean = false

  /**
   * 构建订阅首页UI结构
   * 整体布局：顶部搜索栏 + 小说/漫画/收藏三个订阅卡片
   */
  build() {
    Column() {
      // 顶部搜索栏区域：包含标题、搜索框、添加按钮
      Flex(
        {
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceEvenly
        }
      ) {
        Row({ space: 20 }) {
          // 页面标题
          Text("订阅")
          // 搜索组件，绑定SearchValue状态变量
          Search({ value: this.SearchValue, placeholder: '搜索订阅', icon: "/common/images/search.svg" })
            .width("60%")
            .height(40)
          // .onChange(this.onChange)
          // .onSubmit(this.onSubmit);
          // 添加订阅按钮，点击弹出菜单
          Image($r('app.media.addSubscription')).width(24).bindMenu(this.MenuBuilder)
        }
      }
      .height('10%')
      .width('100%')

      // 小说订阅卡片
      SubscriptionCard({
        Title: "小说",
        ButtonList: this.NovelList,
        ShowEditManage: this.ShowEditManage
      })
      // 漫画订阅卡片
      SubscriptionCard({
        Title: "漫画",
        ButtonList: this.CartoonList,
        ShowEditManage: this.ShowEditManage

      })
      // 收藏订阅卡片
      SubscriptionCard({
        Title: "收藏",
        ButtonList: this.CollectList,
        ShowEditManage: this.ShowEditManage
      })
    }
    .height('100%')
  }

  /**
   * 构建右上角添加按钮的弹出菜单
   * 使用Flex布局垂直排列菜单项，每个菜单项包含图标和文字
   */
  @Builder
  MenuBuilder() {
    Flex({ direction: FlexDirection.Column }) {
      // 遍历MoreList数组，为每个菜单项创建UI
      ForEach(this.MoreList, (item: String, index) => {
        Column() {
          Row() {
            // 菜单项图标
            Image($r('app.media.addSubscription'))
              .width(24)
              .height(24)
              .margin({
                right: 5
              })
            // 菜单项文字
            Text(`${item}`).fontSize(14)
          }
          .height(40)
          .justifyContent(FlexAlign.Center)
          .align(Alignment.Center)
          // 点击菜单项时触发MenuOnclick处理
          .onClick(() => {
            this.MenuOnclick(index)
          })

          // 除最后一个菜单项外，都添加分隔线
          if(index !== 5){
            Divider()
          }
        }

        .padding(5)
        .height(40)
        .margin({ bottom: 20 })
      })
    }
    // 点击"本地导入"时的半模态转场弹窗，绑定NewSubscription状态变量控制显示
    .bindSheet($$this.NewSubscription, this.NewSubscriptionDialog(), {
      height: 300,
      showClose: false,
      dragBar: false,
      blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
      onDisappear: () => {
        // this.clickBookType = ''
      }
    })
    .width(100)
  }

  /**
   * 构建新建订阅弹窗内容
   * 包含可滚动区域和取消按钮
   */
  @Builder
  NewSubscriptionDialog() {
    Column() {
      // 滚动区域，用于展示内容
      Scroll() {
        Flex({
          direction: FlexDirection.Row, wrap: FlexWrap.Wrap, alignContent: FlexAlign.Center,
          justifyContent: FlexAlign.Start
        }) {
          // ForEach(this.BooTypeList, (item: string) => {
          //   this.title(item)
          // })
        }
      }
      .height('65%')
      .scrollBar(BarState.Off)

      Divider()

      // 取消按钮区域
      Column() {
        Text('取消').fontSize(16).fontWeight(400)
          .lineHeight(24)
      }
      .onClick(() => {
        this.NewSubscription = false
      })
      .alignItems(HorizontalAlign.Center)
      .padding({
        left: 32,
        right: 32,
        top: 16
      })
    }

    // .width(CommonConstants.FULL_WIDTH)
    // .height(CommonConstants.FULL_HEIGHT)
  }

  /**
   * 菜单项点击事件处理函数
   * @param value - 点击的菜单项索引或标识
   * 根据索引执行不同操作：0-粘贴导入, 1-网络导入, 2-本地导入, 3-新建订阅, 4-新建分组, 5-批量管理
   */
  MenuOnclick(value:number|string){
    // MoreList: string[] = ['粘贴导入', '网络导入', '本地导入', '新建订阅', '新建分组', '批量管理']
    switch (value){
      case 0:
        // TODO: 实现粘贴导入功能
        break
      case 1:
        // TODO: 实现网络导入功能
        break
      case 2:
        // 显示本地导入弹窗
        this.NewSubscription =true
        break
      case 3:
        // TODO: 实现新建订阅功能
        break
      case 4:
        // TODO: 实现新建分组功能
        break
      case 5:
        // 切换批量管理模式的显示状态
        this.ShowEditManage = !this.ShowEditManage
        break
    }
  }
}




/**
 * @component SubscriptionCard
 * @description 订阅卡片组件 - 展示某一分类下的订阅源列表
 * @prop Title - 卡片标题（如"小说"、"漫画"）
 * @prop ButtonList - 该分类下的订阅源名称数组
 * @prop ShowEditManage - 是否显示编辑管理模式，控制复选框的显示
 */
@Component
struct SubscriptionCard {
  /** 卡片标题，由父组件传入 */
  @State Title: string = ''
  /** 订阅源按钮列表，由父组件传入 */
  @State ButtonList: string[] = []
  /** 是否显示卡片更多操作弹窗 */
  @State isCardShowMore: boolean = false
  /** 更多操作选项列表：置顶、重命名、移动至、分享、导出、删除 */
  @State BooTypeList: string[] = ['置顶', '重命名', '移动至', '分享', '导出', '删除']
  /** 是否处于编辑管理模式，控制复选框显示 */
  @Prop ShowEditManage: Boolean = false

  /**
   * 构建订阅卡片UI
   * 包含标题行和订阅源按钮列表
   */
  build() {
    Column() {
      // 卡片标题行：标题 + 更多操作按钮或复选框
      Row({ space: 20 }) {
        Text(this.Title)
        Blank(1) // 弹性空白，将内容推到两侧
        // 根据编辑模式显示复选框或更多操作按钮
        if (this.ShowEditManage) {
          Checkbox({})
        } else {
          Image($r('app.media.more_sub'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.isCardShowMore = true
            })
            // 绑定半模态弹窗，显示更多操作选项
            .bindSheet($$this.isCardShowMore, this.catalogMove(), {
              height: 300,
              showClose: false,
              dragBar: false,
              blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
              maskColor: 'rgba(0,0,0,0.6)',
              onDisappear: () => {
                // this.clickBookType = ''
              }
            })
        }
      }
      .width("88%")
      .margin({
        bottom: 12
      })

      // 订阅源按钮列表区域，使用Flex布局实现换行
      Flex({
        direction: FlexDirection.Row, wrap: FlexWrap.Wrap, alignContent: FlexAlign.Center,
        justifyContent: FlexAlign.Start
      }) {
        // 遍历ButtonList，为每个订阅源创建按钮
        ForEach(this.ButtonList, (item: string) => {
          Button() {
            Row() {
              // Ellipse图片临时用，修改后记得删除
              Image($r('app.media.Ellipse'))
                .width(30)
                .height(30)
              Text(item)
                .fontSize(14)
                .textOverflow({
                  overflow: TextOverflow.Ellipsis
                })
                .ellipsisMode(EllipsisMode.END)
                .maxLines(1)
                .width(this.ShowEditManage? "45%" : null)
                .margin({
                  left:12
                })
              // 编辑模式下显示复选框
              if (this.ShowEditManage) {
                Blank(1)
                Checkbox({})
              }
            }
            .width("100%")
            .padding({
              left:15,
              right:15
            })
          }
          .onClick(() => {
            // TODO: 订阅源点击事件处理
          })
          .type(ButtonType.Normal)
          .backgroundColor("#FFFFFF")
          .width(154)
          .height(54)
          .margin({ left: 15, bottom: 10 })
          .border({
            radius: 12
          })
        })

        // 添加网址按钮，用于添加新的订阅源
        Button() {
          Row() {
            Image($r('app.media.addURL'))
              .width(30)
              .height(30)
            Text("添加网址")
              .fontSize(14)
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
              .ellipsisMode(EllipsisMode.END)
              .maxLines(1)
              .width(this.ShowEditManage? "45%" : null)
              .margin({
                left:12
              })
              .fontColor("#000000")
              .opacity(0.45)
          }
          .width("100%")
          .padding({
            left:15,
            right:15
          })
        }
        .type(ButtonType.Normal)
        .backgroundColor("#FFFFFF")
        .width(154)
        .height(54)
        .margin({ left: 15, bottom: 10 })
        .border({
          radius: 12
        })
      }
    }
    .margin({
      bottom: 24
    })
  }

  /**
   * 构建更多操作弹窗内容
   * 包含操作选项网格和取消按钮
   */
  @Builder
  catalogMove() {
    Column() {
      // 可滚动区域展示操作选项
      Scroll() {
        Flex({
          direction: FlexDirection.Row,
          wrap: FlexWrap.Wrap,
          alignContent: FlexAlign.Center,
          justifyContent: FlexAlign.Start
        }) {
          // 遍历BooTypeList，为每个操作选项创建UI
          ForEach(this.BooTypeList, (item: string) => {
            this.title(item)
          })
        }
      }
      .height('65%')
      .scrollBar(BarState.Off)

      Divider()

      // 取消按钮
      Column() {
        Text('取消').fontSize(16).fontWeight(400)
          .lineHeight(24)
      }
      .onClick(() => {
        this.isCardShowMore = false
      })
      .alignItems(HorizontalAlign.Center)
      .padding({
        left: 32,
        right: 32,
        top: 16
      })
    }

    // .width(CommonConstants.FULL_WIDTH)
    // .height(CommonConstants.FULL_HEIGHT)
  }

  /**
   * 构建单个操作选项项UI
   * @param title - 操作选项的名称
   * @returns 包含图标和文字的Column组件
   */
  @Builder
  title(title: string) {
    Column() {
      Image($r('app.media.Ellipse'))
        .width(24)
        .height(24)
        .margin({ bottom: 10 })
      Text(title).fontSize(12).textOverflow({
        overflow: TextOverflow.Ellipsis
      }).ellipsisMode(EllipsisMode.END).maxLines(1)
    }
    .onClick(() => {
      // TODO: 操作选项点击事件处理
    })
    .margin({ left: 5, bottom: 10 })
    .width(85)
    .height(70)
    // .backgroundColor('rgba(0, 0, 0,0.06)')
    .padding({
      top: 8,
    })
  }
}
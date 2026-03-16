/**
 * @author 2008
 * @datetime 2024/7/13 23:33
 * @className: SubscriptionSearch
 * @description: 订阅源搜索页面组件
 *              功能：提供订阅源搜索功能，实时显示搜索结果
 *              交互：输入关键词搜索、显示搜索结果网格、点击跳转详情、无结果提示
 *              用途：独立的搜索页面，用于快速查找订阅源
 */
import CommonConstants from '../../../../common/constants/CommonConstants';
import FontConstants from '../../../../common/constants/FontConstants';
import { router } from '@kit.ArkUI';
import PaddingConstants from '../../../../common/constants/PaddingConstants';
import ImageConstants from '../../../../common/constants/ImageConstants';
import { rssSources } from '../../../../database/entities/rssSources';
import SubscriptionDao from '../../../../database/dao/SubscriptionDao';
import { showMessage } from '../../../../componets/common/promptShow';
import rssSourcesUtils from '../../../../common/utils/rssSourcesUtils';
import PreviewEffectImage from './PreviewEffectImage';
import { ThemeItem } from '../../../../common/model/Theme';
import { ThemeStorageKey } from '../../../../common/constants/Theme';

/**
 * 订阅源搜索页面
 * 作为独立页面使用(@Entry装饰器)，提供搜索功能
 */
@Entry
@Component
struct SubscriptionSearch {
  /**
   * 搜索关键词 - 使用@Watch监听变化
   * 当值改变时自动调用changeSearchValue方法
   * 默认值为'起点'
   */
  @State @Watch('changeSearchValue')searchValue: string = '起点';
  
  /**
   * 顶部安全区域高度 - 从全局存储中获取
   * 用于适配刘海屏/挖孔屏等异形屏幕
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /**
   * 搜索结果列表 - 存储匹配搜索关键词的订阅源
   * 类型为rssSources实体对象数组
   */
  @State
  searchList: rssSources[] = []
  
  /** 
   * 当前主题颜色 - 从全局存储中获取
   * 用于页面背景渐变色
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 页面显示时生命周期回调
   * 调用changeSearchValue()触发搜索
   */
  onPageShow(): void {
    this.changeSearchValue()
  }

  /**
   * 页面隐藏时生命周期回调
   * 当前未执行任何清理操作
   */
  onPageHide(): void {
    // this.searchValue = ''
    // this.searchList = []
  }

  /**
   * 搜索值变化处理
   * 当searchValue发生变化时触发(@Watch监听)
   * 逻辑：
   * - 如果搜索词非空，执行搜索
   * - 如果搜索词为空，清空结果列表
   */
  changeSearchValue(){
    if(this.searchValue.length > 0){
      this.searchSources()
    } else {
      this.searchList = []
    }
  }

  /**
   * 执行搜索操作
   * 调用SubscriptionDao.search()查询数据库
   * @param searchKey - 搜索关键词
   * @param enabled - 只搜索启用的订阅源
   * 查询结果更新到searchList状态变量
   */
  searchSources(){
    SubscriptionDao.search({
      searchKey: this.searchValue,
      enabled: true
    }).then(data =>{
      this.searchList = data
    })
  }



  /**
   * 构建UI布局
   * 整体采用Column垂直布局：
   * 1. 顶部搜索栏：Search输入框 + 取消按钮
   * 2. 内容区域：Scroll滚动容器，根据结果显示搜索结果或无结果提示
   * 背景：使用主题色的渐变背景
   */
  build() {
    Column(){
      // 顶部搜索栏区域
      Flex(
        {
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceEvenly
        }
      ) {
        Row({ space: 20 }) {
          // 搜索输入框 - 使用双向绑定$$this.searchValue
          Search({ value: $$this.searchValue, placeholder: '搜索订阅', icon: "/common/images/search.svg" })
            .layoutWeight(1)  // 占据剩余空间
            .height(40)
            .backgroundColor(Color.White)

          // 取消按钮 - 点击返回上一页
          Text('取消').font({
            size: FontConstants.FONT_SIZE_14,
            weight: FontConstants.FONT_WEIGHT_400,
            family: CommonConstants.FAMILY_PingFANG
          })
            .onClick(() => {
              router.back()
          })
          .fontColor($r('app.string.color_black_88'))

        }
      }
      .height('10%')
      .width('100%')

      // 内容滚动区域
      Scroll(){
        Column(){
          // 根据搜索结果数量显示不同内容
          if (this.searchList.length === 0){
            this.noResultLog()  // 无结果时显示空状态
          } else {
            this.searchBuilder()  // 有结果时显示网格
          }
        }
      }
      // 根据是否有结果调整对齐方式
      .align(this.searchList.length === 0? Alignment.Center:Alignment.Top)
      .padding({bottom:20})
      .layoutWeight(1)  // 占据剩余空间
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
    }
    // 渐变背景 - 从主色到次色的渐变
    .linearGradient({
      direction: GradientDirection.Bottom, // 渐变方向：从上到下
      colors: [[this.theme.mainColor, 0], [this.theme.secondColor, 0.2]] // 颜色数组和位置
    })
    // 内边距设置 - 顶部适配安全区域，左右固定20
    .padding({
      top: this.topRectHeight,
      left: PaddingConstants.PADDING_20,
      right: PaddingConstants.PADDING_20
    }
    )
    .height('100%')
  }

  /**
   * 搜索结果网格构建器
   * 使用GridRow创建5列网格布局展示搜索结果
   * 每个网格项包含：
   * - PreviewEffectImage: 订阅源图标(圆形裁剪)
   * - Text: 订阅源名称
   * 
   * 交互：点击跳转到订阅源详情页面
   */
  @Builder
  searchBuilder(){
    GridRow({
      columns: 5  // 每行5列
    }){
      // 遍历搜索结果
      ForEach(this.searchList,(item:rssSources)=>{
        GridCol(){
          Column({
            space: CommonConstants.SPACE_6
          }){
            // 订阅源图标预览 - 圆形样式
            PreviewEffectImage({
              customizeTitle:item.customizeTitle,
              sourceIcon:item.sourceIcon,
              sourceIconIsUrl:item.sourceIconIsUrl,
              isShowTitle:false,
              PreviewWidth:ImageConstants.IMG_WIDTH_40,
              PreviewHeight:ImageConstants.IMG_HEIGHT_40,
              sourceName:item.sourceName
            }).borderRadius(50)  // 圆形裁剪

            // 订阅源名称
            Text(`${item.sourceName}`).fontSize(10)
              .fontColor($r('app.string.color_black_88'))
              .lineHeight(18)
              .fontFamily(CommonConstants.FAMILY_PingFANG)
              .fontWeight(FontConstants.FONT_WEIGHT_400)
          }
          // 点击事件：跳转到订阅源详情
          .onClick(()=>{
            router.pushUrl({
              url: 'pages/view/Subscription/rssWebView',
              params: {
                url: item.sourceUrl
              }
            })
            // 添加到历史记录
            rssSourcesUtils.pushRssSourcesHistory(item)
          })
          .margin({bottom:20})
        }
      })

    }
  }

  /**
   * 无搜索结果提示构建器
   * 当searchList为空时显示：
   * - 图片：搜索空状态图标
   * - 文字："暂无搜索结果"提示
   */
  @Builder
  noResultLog(){
    Column({
      space:32  // 图片和文字间距32像素
    }){
      Image($r('app.media.icon_no_find_search')).width(121).height(110)
      Text('暂无搜索结果')
        .font({
          size:14,
          weight:400,
          family:CommonConstants.FAMILY_PingFANG
        })
        .textAlign(TextAlign.Center)
        .fontColor($r('app.string.color_black_45'))

    }
  }
}
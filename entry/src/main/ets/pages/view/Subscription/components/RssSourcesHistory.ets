/**
 * @author 2008
 * @datetime 2024/7/20 15:20
 * @className: RssSourcesHistory
 * @description: 最近使用订阅源历史记录组件
 *              功能：展示用户最近访问过的订阅源列表，支持清空历史和点击访问
 *              交互：水平滚动展示历史记录，点击跳转到对应订阅源，清空按钮删除所有历史
 *              用途：在订阅页面顶部显示快速访问入口
 */
import CommonConstants from '../../../../common/constants/CommonConstants'
import FontConstants from '../../../../common/constants/FontConstants'
import ImageConstants from '../../../../common/constants/ImageConstants'
import PaddingConstants from '../../../../common/constants/PaddingConstants'
import rssSourcesHistoryDao from '../../../../database/dao/RssSourcesHistoryDao'
import { rssSourcesHistory } from '../../../../database/entities/rssSourcesHistory'
import PreviewEffectImage from './PreviewEffectImage'
import { router } from '@kit.ArkUI'
import rssSourcesUtils from '../../../../common/utils/rssSourcesUtils'

/**
 * 最近使用订阅源历史记录组件
 * 展示用户最近访问的订阅源，提供快速访问功能
 */
@Component
export default struct RssSourcesHistory{
  /**
   * 最近使用列表 - 从父组件传入的历史记录数据
   * 数组元素为rssSourcesHistory实体对象，包含订阅源的基本信息
   */
  @Prop
  RecentlyUsed: rssSourcesHistory[] = []

  /**
   * 构建UI布局
   * 当RecentlyUsed有数据时显示：
   * 1. 标题行：显示"最近使用"标题和"清空"按钮
   * 2. 历史列表：水平滚动展示订阅源图标和名称
   */
  build() {
    Column(){
      // 只有当有历史记录时才显示整个组件
      if (this.RecentlyUsed.length > 0){
        // 标题行 - 左右布局：左侧标题，右侧清空按钮
        Flex({
          justifyContent:FlexAlign.SpaceBetween,
          alignItems: ItemAlign.Center
        }) {
          // "最近使用"标题
          Text('最近使用')
            .font({
              size:12,
              weight:FontConstants.FONT_WEIGHT_500,
              family: CommonConstants.FAMILY_PingFANG
            })
            .fontColor($r('app.string.color_black_88'))
            .lineHeight(20)
            .padding({
              top: PaddingConstants.PADDING_12,
              bottom: PaddingConstants.PADDING_12
            })

          // "清空"按钮 - 点击后删除所有历史记录
          Text('清空')
            .font({
              size:12,
              weight:FontConstants.FONT_WEIGHT_400,
              family: CommonConstants.FAMILY_PingFANG
            })
            .fontColor($r('app.string.color_black_45'))
            .lineHeight(20)
            .padding({
              top: PaddingConstants.PADDING_12,
              bottom: PaddingConstants.PADDING_12
            })
            .onClick(()=>{
              // 调用DAO删除数据库中的历史记录
              rssSourcesHistoryDao.deleteRssSourcesHistoryList(this.RecentlyUsed)
              // 清空本地数组，UI同步更新
              this.RecentlyUsed = []
            })
        }
        // 历史记录列表容器
        Flex(){
          this.RecentlyUsedBuilder()
        }
      }
    }.justifyContent(FlexAlign.Start)
  }
  
  /** 滚动控制器 - 用于控制历史列表的水平滚动 */
  scroller: Scroller = new Scroller()
  
  /**
   * 最近使用列表构建器
   * 创建水平滚动的List组件，展示每个历史记录项
   * 
   * 列表项结构：
   * - PreviewEffectImage: 订阅源图标预览
   * - Text: 订阅源名称
   * 
   * 交互：点击列表项跳转到对应的订阅源页面
   */
  @Builder
  RecentlyUsedBuilder(){
    List({
      scroller:this.scroller,
      space:PaddingConstants.PADDING_24  // 列表项间距24像素
    }){
      // 遍历历史记录数组
      ForEach(this.RecentlyUsed,(item:rssSourcesHistory,index:number)=>{
        ListItem(){
          // 垂直排列的Column：图标在上，名称在下
          Column({
            space: CommonConstants.SPACE_6  // 元素间距6像素
          }){
            // 订阅源图标预览组件
            PreviewEffectImage({
              sourceIcon:item.sourceIcon,
              customizeTitle:item.customizeTitle,
              PreviewWidth:ImageConstants.IMG_WIDTH_40,    // 宽度40
              PreviewHeight:ImageConstants.IMG_HEIGHT_40,  // 高度40
              sourceIconIsUrl:item.sourceIconIsUrl,
              isShowTitle:false,  // 不显示标题
              sourceName:item.sourceName
            })

            // 订阅源名称
            Text(`${item.sourceName}`).fontSize(10)
              .fontColor($r('app.string.color_black_88'))
              .lineHeight(18)
              .fontFamily(CommonConstants.FAMILY_PingFANG)
              .fontWeight(FontConstants.FONT_WEIGHT_400)
          }
        }
        // 点击事件：跳转到订阅源详情页面
        .onClick(()=>{
          // 使用router跳转到rssWebView页面
          router.pushUrl({
            url: 'pages/view/Subscription/rssWebView',
            params: {
              url: item.sourceUrl  // 传递订阅源URL
            }
          })
          // 更新历史记录访问时间（重新排序）
          rssSourcesUtils.pushRssSourcesHistory(item)
        })
      })
    }
    // List配置
    .height(80)
    .chainAnimation(true)      // 启用链式动画
    .edgeEffect(EdgeEffect.Spring)  // 弹簧边缘效果
    .listDirection(Axis.Horizontal) // 水平方向滚动
    .scrollBar(BarState.Off)   // 隐藏滚动条
    .padding({top:PaddingConstants.PADDING_12})
  }
}
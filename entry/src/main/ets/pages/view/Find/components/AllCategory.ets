/**
 * 全部分类组件 - 用于展示书籍分类和提供分类导航功能
 * 
 * 功能概述：
 * 1. 展示书籍分类标题和对应的分类项目网格
 * 2. 提供分类项点击导航功能，跳转到对应的书籍列表页面
 * 3. 底部提供取消按钮，用于关闭底部弹窗
 * 
 * 使用场景：
 * - 在发现页面的底部弹窗中展示所有可用的书籍分类
 * - 用户可以通过点击分类项快速导航到对应的书籍列表
 */

// 导入必要的类型和工具
import { ExploreItem } from '../../../../database/types/BookSourceType'  // 探索项数据类型
import { router } from '@kit.ArkUI'  // 路由导航工具
import { ExploreRule } from '../../../../database/entities/rule'  // 探索规则实体

/**
 * 分类组数据结构接口
 * 用于组织同一分类下的多个探索项
 */
export interface GroupExploreList {
  title: string,          // 分类标题
  url: string,            // 分类对应的URL地址
  columnsTemplate: string // 网格布局模板，控制每行显示的列数（如：'1fr 1fr'表示两列）
  list: ExploreItem[]     // 该分类下的探索项列表
}

/**
 * 全部分类组件
 * @prop {GroupExploreList[]} list - 分类组列表数据
 * @prop {boolean} showSheet - 控制底部弹窗显示状态（双向绑定）
 * @prop {string} bookSourceUrl - 书籍源URL地址
 * @prop {ExploreRule} exploreRule - 探索规则配置
 */
@Component
export default struct AllCategory {
  // 底部安全区域高度，从Storage中获取，用于适配不同设备的底部安全区域
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  // 分类组列表数据，由父组件传入
  @Prop list: GroupExploreList[] = []
  
  // 控制底部弹窗显示状态，与父组件双向绑定
  @Link showSheet: boolean
  
  // 书籍源URL地址，用于构建完整的导航链接
  @Prop bookSourceUrl: string = ''
  
  // 探索规则配置，用于传递给目标页面
  @Prop exploreRule: ExploreRule = {}

  /**
   * 组件UI构建方法
   * 定义组件的视觉结构和交互逻辑
   */
  build() {
    Column() {
      Column() {
        ForEach(this.list, (item: GroupExploreList) => {
          Column() {
            if (item.title !== 'null') {
              Row() {
                Text(item.title)
                  .fontSize(16)
                  .fontWeight(700)
              }
              .justifyContent(FlexAlign.Start)
              .margin({ top: 24, })
            }

            Grid() {
              ForEach(item.list, (item: ExploreItem) => {
                GridItem() {
                  this.buttonItem(item)
                }
              })
            }
            .columnsTemplate(item.columnsTemplate)
            .columnsGap(12)
            .rowsGap(12)
            .padding({ top: 12 })
          }
          .padding({ left: 20, right: 20 })
          .alignItems(HorizontalAlign.Start)
        })
      }
      .padding({ bottom: 12 })


      Column() {
        Button() {
          Text('取消')
            .fontColor('#73000000')
            .height(24)
            .lineHeight(24)
        }
        .width('100%')
        .borderRadius(24)
        .backgroundColor('#0A000000')
        .padding({
          top: 8,
          bottom: 8
        })
        .onClick(() => {
          this.showSheet = false
        })
      }
      .border({
        width: { top: 1 },
        color: '#0f000000',
        style: BorderStyle.Solid
      })
      .padding({
        top: 12,
        bottom: 12,
        left: 20,
        right: 20
      })
    }
    .padding({ bottom: this.bottomRectHeight + 30 })
  }

  /**
   * 构建单个分类按钮项
   * 创建可点击的分类项，点击后导航到对应的书籍列表页面
   * 
   * @param {ExploreItem} item - 单个探索项数据，包含标题和URL等信息
   * @returns {void}
   * 
   * 功能说明：
   * 1. 创建带有灰色背景的圆角按钮
   * 2. 显示分类标题（单行显示，超出部分省略）
   * 3. 点击后导航到CategoryList页面，传递相关参数
   * 4. 如果URL为空，则点击无效（不执行导航）
   * 
   * 样式特点：
   * - 浅灰色背景（#0F000000）
   * - 4px圆角边框
   * - 14px字体大小
   * - 灰色文字（#73000000）
   * - 固定高度20px，确保视觉一致性
   */
  @Builder
  buttonItem(item: ExploreItem) {
    Column() {
      Text(item.title)
        .fontSize(14)
        .textAlign(TextAlign.Center)
        .fontWeight(400)
        .width('100%')
        .height(20)
        .lineHeight(20)
        .fontColor('#73000000')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
    }
    .alignItems(HorizontalAlign.Center)
    .padding({
      top: 6,
      bottom: 6
    })
    .backgroundColor('#0F000000')
    .borderRadius(4)
    .onClick(() => {
      // 安全判断：只有存在URL的分类项才允许点击导航
      if (!item.url) {
        return
      }
      // 导航到分类列表页面，传递必要的参数
      router.pushUrl({
        url: 'pages/view/Find/CategoryList/Index',
        params: {
          bookSourceUrl: this.bookSourceUrl,  // 书籍源URL，用于构建完整请求地址
          exploreItem: item,                    // 当前点击的探索项数据
          exploreRule: this.exploreRule         // 探索规则配置
        }
      })
    })
  }
}
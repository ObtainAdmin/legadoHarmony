/**
 * 书籍卡片项组件 - 用于在发现页面展示单本书籍的信息
 * 
 * 组件功能：
 * 1. 展示书籍的基本信息：封面、书名、简介、作者、分类、字数
 * 2. 提供点击功能，点击后导航到书籍详情页面
 * 3. 使用防重复点击机制，避免用户快速多次点击
 * 4. 支持主题颜色，根据当前主题动态调整UI样式
 * 
 * 布局结构：
 * - 左侧：书籍封面图片（63x84px）
 * - 右侧：书籍详细信息
 *   - 书名（16px，加粗）
 *   - 简介（12px，两行，超出省略）
 *   - 标签区域：作者、分类、字数
 * 
 * 数据传递：
 * - 接收父组件传入的书籍数据（ExploreRule类型）
 * - 接收当前分类索引，用于确定书籍类型
 * - 点击时将所有书籍信息传递给详情页面
 */

// 导入必要的类型和工具
import { ExploreRule } from '../../../../database/entities/rule';  // 书籍数据类型
import { router } from '@kit.ArkUI';  // 路由导航
import clickUtil from '../../../../common/utils/ClickUtils';  // 防重复点击工具
import { ThemeStorageKey } from '../../../../common/constants/Theme';  // 主题常量
import { ThemeItem } from '../../../../common/model/Theme';  // 主题类型

/**
 * 书籍卡片项组件
 * @prop {ExploreRule} item - 书籍数据对象，包含书名、作者、简介等信息
 * @prop {number} currentIndex - 当前分类索引（0-小说，1-漫画，2-有声书）
 */
@Component
export struct CardItem {
  // 书籍数据，由父组件传入
  @Prop item: ExploreRule = {};
  
  // 当前分类索引，用于确定书籍类型
  currentIndex: number = 0

  // 主题颜色配置，用于UI样式
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 组件UI构建方法
   * 定义书籍卡片的视觉结构和交互逻辑
   * 
   * 布局说明：
   * 1. 外层Row：水平布局，包含封面和书籍信息
   * 2. 左侧Image：书籍封面，固定尺寸63x84px
   * 3. 右侧Column：垂直布局，包含书名、简介、标签
   * 4. 底部Row：水平布局，包含作者、分类、字数标签
   * 
   * 样式特点：
   * - 封面使用Contain模式，保持原始比例
   * - 书名使用16px字体，加粗显示
   * - 简介使用12px字体，限制两行，超出省略
   * - 标签使用不同背景色区分：作者（主题色）、分类（灰色）、字数（灰色）
   * - 整行可点击，点击后导航到详情页面
   */
  build() {
    Row() {
      // 左侧：书籍封面图片
      Image(this.item.coverUrl ?? $r('app.media.no_record'))
        .alt($r('app.media.find_empty'))  // 加载失败时的备用图片
        .width(63)      // 固定宽度63px
        .height(84)     // 固定高度84px
        .objectFit(ImageFit.Contain)  // 保持图片原始比例
        .borderRadius(4)  // 4px圆角
        .margin({ right: 12 })  // 右侧间距12px

      // 右侧：书籍详细信息
      Column() {
        // 书名
        Text(this.item.name)
          .fontSize(16)   // 16px字体
          .height(24)     // 固定高度24px
          .lineHeight(24) // 行高24px，确保垂直居中

        // 书籍简介
        Text(this.item.intro)
          .fontSize(12)   // 12px字体
          .lineHeight(20) // 行高20px
          .height(40)     // 固定高度40px，刚好显示两行
          .textOverflow({
            overflow: TextOverflow.Ellipsis  // 超出部分显示省略号
          })
          .maxLines(2)    // 最多显示两行

        // 标签区域：作者、分类、字数
        Row() {
          // 作者标签（使用主题颜色）
          Column() {
            Text(this.item.author)
              .fontSize(10)  // 10px字体
              .fontColor(this.theme.mainColor)  // 使用主题主色
          }
          .padding({ left: 6, right: 6 })  // 左右内边距6px
          .height(16)     // 固定高度16px
          .justifyContent(FlexAlign.Center)  // 内容居中
          .backgroundColor(this.theme.secondColor)  // 使用主题次要颜色作为背景

          // 分类标签（如果有）
          if (this.item.kind) {
            Column() {
              Text(this.item.kind)
                .fontSize(10)  // 10px字体
                .fontColor('#73000000')  // 灰色文字
            }
            .margin({ left: 8 })  // 左侧间距8px
            .padding({ left: 6, right: 6 })  // 左右内边距6px
            .height(16)     // 固定高度16px
            .justifyContent(FlexAlign.Center)  // 内容居中
            .backgroundColor('#0F000000')  // 浅灰色背景
          }

          // 字数标签（如果有）
          if (this.item.wordCount) {
            Column() {
              Text(this.item.wordCount)
                .fontSize(10)  // 10px字体
                .fontColor('#73000000')  // 灰色文字
            }
            .margin({ left: 8 })  // 左侧间距8px
            .padding({ left: 6, right: 6 })  // 左右内边距6px
            .height(16)     // 固定高度16px
            .justifyContent(FlexAlign.Center)  // 内容居中
            .backgroundColor('#0F000000')  // 浅灰色背景
          }
        }
        .padding({top: 4})  // 顶部内边距4px
        .width('100%')     // 宽度占满父容器
        .height(16)        // 固定高度16px
        .justifyContent(FlexAlign.Start)  // 内容左对齐
      }
      .alignItems(HorizontalAlign.Start)  // 子元素左对齐
      .justifyContent(FlexAlign.SpaceBetween)  // 垂直方向两端对齐
      .layoutWeight(1)  // 占满剩余空间
    }
    .width('100%')     // 宽度占满父容器
    .padding({ top: 20 })  // 顶部内边距20px
    .onClick(() => {
      // 使用防重复点击工具，避免用户快速多次点击
      clickUtil.preventClick(()=>{
        // 导航到书籍详情页面，传递书籍的所有相关信息
        router.pushUrl({
          url: 'pages/view/BookDetailPage',
          params: {
            bookName: this.item.name,      // 书名
            coverUrl: this.item.coverUrl,  // 封面URL
            author: this.item.author,      // 作者
            intro: this.item.intro,        // 简介
            bookUrl: this.item.bookUrl,    // 书籍URL
            wordCount: this.item.wordCount, // 字数
            bookType: this.currentIndex     // 书籍类型（0-小说，1-漫画，2-有声书）
          }
        })
      })
    })
  }
}
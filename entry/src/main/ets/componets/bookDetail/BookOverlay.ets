/**
 * @file BookOverlay.ets
 * @description 书籍封面叠加层组件
 * 
 * 功能概述：
 * 1. 显示书籍封面图片
 * 2. 支持显示"置顶"标签
 * 3. 支持显示半透明遮罩层
 * 4. 提供多种封面样式（通过coverType控制）
 * 
 * 使用场景：
 * - 书籍列表中的书籍封面显示
 * - 需要突出显示置顶书籍
 * - 需要特殊视觉效果的封面展示
 * 
 * 设计特点：
 * - 使用Stack布局实现多层叠加效果
 * - 支持动态显示/隐藏遮罩层
 * - 提供多种封面装饰样式
 */

import CommonConstants from '../../common/constants/CommonConstants'

/**
 * @class BookOverlay
 * @description 书籍封面叠加层组件
 * 
 * 组件职责：
 * 1. 渲染书籍封面图片
 * 2. 管理置顶标签的显示
 * 3. 控制遮罩层的可见性
 * 4. 应用不同的封面装饰样式
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct BookOverlay {
  /** 
   * @prop bookImage - 书籍封面图片资源
   * @description 可以是Resource对象或图片URL字符串
   * @type {Resource|string}
   */
  @Prop bookImage:Resource|string
  
  /** 
   * @prop isTop - 是否置顶
   * @description 控制是否在封面上显示"置顶"标签
   * @type {boolean}
   */
  @Prop isTop:boolean
  
  /** 
   * @prop isShow - 是否显示遮罩层
   * @description 控制是否显示半透明黑色遮罩层
   * @default false - 默认不显示遮罩
   * @type {boolean}
   */
  @Prop isShow:boolean = false
  
  /** 
   * @prop coverType - 封面类型
   * @description 控制封面装饰样式：
   * - 0或1: 显示两层装饰图片（occlusion1和occlusion2）
   * - 2: 不显示装饰图片
   * @default 0 - 默认显示装饰
   * @type {number}
   */
  @Prop coverType:number = 0
  
  /**
   * @method build
   * @description 构建书籍封面叠加层UI
   * 
   * 布局结构（从下到上）：
   * 1. 底层：两层装饰图片（coverType≠2时显示）
   * 2. 中间层：书籍封面图片 + 置顶标签
   * 3. 顶层：半透明遮罩层（isShow=true时显示）
   * 
   * 视觉层次（zIndex）：
   * - 遮罩层: zIndex(3)
   * - 封面层: zIndex(2)
   * - 装饰层: zIndex(1)和zIndex(0)
   * 
   * @returns {void}
   */
  build() {

    Stack(){
      if (this.isShow){
        Column(){

        }
        .zIndex(3)
        .backgroundColor('rgba(0,0,0,0.45)')
        .width(CommonConstants.NOVEL_IMG_WIDTH).height(CommonConstants.NOVEL_IMG_HEIGHT)
      }

      Stack(){
        if (this.isTop){
          Text('置顶').fontColor(Color.White).fontWeight(300).fontSize(8).padding(3).borderRadius(5)
            .backgroundColor('rgba(0, 0, 0, 0.45)').zIndex(1)
        }
        Image(this.bookImage)
          .draggable(false)
          .alt($r('app.media.icon_book_default_cover_one'))
          .width(CommonConstants.NOVEL_IMG_WIDTH)
          .height(CommonConstants.NOVEL_IMG_HEIGHT)
      }
      .zIndex(2)
      .alignContent(Alignment.BottomStart)
      if (this.coverType !== 2){
        Row(){
          Image($r('app.media.occlusion1')).draggable(false)
        }
        .zIndex(1)
        .width(CommonConstants.NOVEL_IMG_WIDTH + 5).height(CommonConstants.NOVEL_IMG_HEIGHT - 5)

        Row(){
          Image($r('app.media.occlusion2')).draggable(false)
        }.zIndex(0)
        .width(CommonConstants.NOVEL_IMG_WIDTH + 10).height(CommonConstants.NOVEL_IMG_HEIGHT - 10)
      }
    }
    .align(Alignment.BottomStart)
  }
}

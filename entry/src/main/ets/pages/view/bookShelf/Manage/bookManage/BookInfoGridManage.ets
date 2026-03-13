import CommonConstants from '../../../../../common/constants/CommonConstants'
import FontConstants from '../../../../../common/constants/FontConstants'
import { ThemeStorageKey } from '../../../../../common/constants/Theme'
import { ThemeItem } from '../../../../../common/model/Theme'
import { Books } from '../../../../../database/entities/Books'

/**
 * 书籍宫格管理组件
 * 
 * 功能概述：
 * 1. 提供书籍的宫格视图展示，用于管理页面
 * 2. 支持复选框选择功能，用于批量操作
 * 3. 显示书籍封面、名称、简介、本地标识、置顶标识
 * 4. 使用堆叠布局实现视觉层次效果
 * 
 * 使用场景：
 * - 在书籍管理页面中显示书籍列表（宫格模式）
 * - 支持用户选择书籍进行批量操作（置顶、移动、删除等）
 * 
 * 组件特点：
 * - 使用@Component装饰器，作为可复用组件
 * - 三层堆叠布局：本地标识层、复选框层、封面层
 * - 视觉层次：使用zIndex控制图层顺序
 * - 主题颜色适配：使用主题主颜色作为复选框选中颜色
 * - 响应式设计：固定尺寸的宫格布局
 * - 常量使用：使用CommonConstants和FontConstants统一管理常量
 */
@Component
export default struct BookInfoGridManage{
  /** 是否处于管理模式，通过@Prop装饰器从父组件传入 */
  @Prop isManage:boolean

  /** 书籍数据，通过@Prop装饰器从父组件传入 */
  @Prop bookData:Books

  /** 
   * 复选框状态记录，通过@Link装饰器与父组件双向绑定
   * 键为书籍ID，值为是否选中
   */
  @Link checkGroup:Record<number, boolean>
  
  /** 选择状态变化回调函数 */
  onSelect:Function = () => {}
  
  /** 主题颜色，通过@StorageProp从AppStorage获取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * 构建组件UI布局
   * 
   * 布局结构：
   * 1. 顶部：三层堆叠布局
   *    - 第一层：本地标识（如果是本地书籍）
   *    - 第二层：复选框层（管理模式下显示）和封面层
   *    - 第三层：背景层（黑色45%透明度）
   * 2. 中部：书籍名称（最多2行，超出显示省略号）
   * 3. 底部：书籍简介（灰色文字，单行显示）
   * 
   * 设计特点：
   * - 宫格尺寸：固定宽度和高度
   * - 封面尺寸：100×120像素
   * - 本地标识：棕色背景，米色文字，右上角和左下角圆角
   * - 置顶标识：黑色半透明背景，白色文字
   * - 文字样式：书籍名称加粗，简介灰色
   * - 内边距：左右8px，上下5px
   * - 元素间距：使用CommonConstants.SPACE_6（6px）
   */
  build() {
    Column({
      space:CommonConstants.SPACE_6  // 使用常量定义的元素间距
    }) {
      // 顶部：三层堆叠布局
      Stack(){
        // 第一层：本地标识（如果是本地书籍）
        if (this.bookData.isLocalBook){
          Text('本地')
            .fontColor('#FFEDD4')  // 米色文字
            .fontWeight(FontConstants.FONT_WEIGHT_400)  // 使用常量定义字体粗细
            .fontSize(9)
            .padding(3)
            .backgroundColor('#523000')  // 棕色背景
            .zIndex(1)  // 第一层级
            .borderRadius({
              topRight: 6,  // 右上角圆角
              bottomLeft: 6,  // 左下角圆角
            })
        }
        
        // 第二层：复选框层和封面层
        Stack(){
          // 管理模式下显示复选框
          if (this.isManage){
            Checkbox({
              name: JSON.stringify(this.bookData.id),  // 复选框名称（书籍ID）
              group: 'checkboxGroup'  // 复选框组
            })
              .onClick(()=>{
                this.onSelect()  // 触发选择回调
              })
              .select(this.bookData.id?this.checkGroup[this.bookData.id] ?? false:false)  // 绑定选中状态
              .selectedColor(this.theme.mainColor)  // 使用主题主颜色
              .unselectedColor('rgba(0, 0, 0, 0.35)')  // 未选中颜色
              .zIndex(2)  // 第二层级
              .onChange((val:boolean)=>{
                if (this.bookData.id) {
                  this.checkGroup[this.bookData.id] = val  // 更新选中状态
                }
              })
          }
          
          // 封面层：置顶标识和封面图片
          Stack(){
            // 置顶标识（如果书籍已置顶）
            if (this.bookData.isTop){
              Text('置顶').fontColor(Color.White).fontWeight(300).fontSize(8).padding(3).borderRadius(5)
                .backgroundColor('rgba(0, 0, 0, 0.45)').zIndex(1)  // 黑色半透明背景
            }
            // 书籍封面图片
            Image(this.bookData.coverUrl)
              .alt($r('app.media.icon_book_default_cover_one'))  // 默认封面
              .width(100)  // 固定宽度
              .height(120)  // 固定高度
          }.alignContent(Alignment.BottomStart)  // 底部对齐
        }
        .alignContent(Alignment.BottomEnd)  // 底部对齐
        .backgroundColor($r('app.string.color_black_45'))  // 黑色45%透明度背景
        .borderRadius(10)  // 圆角
      }
      .alignContent(Alignment.TopEnd)  // 顶部对齐

      // 中部：书籍名称（最多2行，超出显示省略号）
      Text(this.bookData.bookName)
        .fontSize(15)
        .fontWeight(700)  // 加粗
        .textOverflow({
          overflow:TextOverflow.Ellipsis  // 超出显示省略号
        })
        .ellipsisMode(EllipsisMode.END)  // 末尾省略
        .maxLines(2)  // 最多2行

      // 底部：书籍简介（灰色文字，单行显示）
      Text(this.bookData.intro).fontSize(12).fontColor('rgb(174,174,174)')  // 灰色文字
        .textOverflow({
          overflow:TextOverflow.Ellipsis  // 超出显示省略号
        })
        .ellipsisMode(EllipsisMode.END)  // 末尾省略
        .fontWeight(500)
        .maxLines(1)  // 单行显示
    }
    .padding({ left:8,right:8,bottom:5,top:5 })  // 内边距
  }
}
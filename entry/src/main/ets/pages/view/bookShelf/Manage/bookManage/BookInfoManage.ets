/**
 * 书籍信息管理组件
 * 
 * 功能概述：
 * 1. 显示书籍的基本信息：封面、名称、简介、最新章节
 * 2. 支持本地书籍标识显示
 * 3. 支持置顶标识显示
 * 4. 提供管理模式下选择书籍的功能
 * 5. 响应主题颜色变化，保持UI一致性
 * 
 * 使用场景：
 * - 在书籍列表页面中作为列表项使用
 * - 在书籍管理页面中显示选择复选框
 * - 在添加书籍到书单等场景中使用
 * 
 * 组件特点：
 * - 使用Flex布局实现水平排列
 * - 左侧显示书籍封面和状态标签（本地/置顶）
 * - 右侧显示书籍详细信息
 * - 根据isManage参数动态显示/隐藏复选框
 * - 支持文本溢出处理，确保UI整洁
 */
import FontConstants from '../../../../../common/constants/FontConstants'
import { ThemeStorageKey } from '../../../../../common/constants/Theme'
import { ThemeItem } from '../../../../../common/model/Theme'
import { Books } from '../../../../../database/entities/Books'

@Component
export default struct BookInfoManage{
  /** 
   * 是否处于管理模式
   * true: 显示复选框，允许选择书籍
   * false: 不显示复选框，仅展示书籍信息
   */
  @Prop isManage:boolean
  
  /** 
   * 书籍数据对象，包含书籍的所有信息
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop bookData:Books
  
  /** 
   * 复选框状态记录，键为书籍ID，值为是否选中
   * 通过@Link装饰器实现父子组件双向绑定
   */
  @Link checkGroup:Record<number, boolean>
  
  /** 
   * 选择回调函数，当用户点击复选框时触发
   * 默认为空函数，父组件可以覆盖此函数以处理选择事件
   */
  onSelect:Function = () => {}
  
  /** 
   * 主题颜色配置
   * 通过@StorageProp从AppStorage获取，自动响应主题变化
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * 构建组件UI
   * 
   * 布局结构：
   * 1. 使用Flex布局，水平方向，两端对齐
   * 2. 左侧：书籍封面区域（包含本地/置顶标签）
   * 3. 中间：书籍信息区域（名称、简介、最新章节）
   * 4. 右侧：复选框区域（仅在isManage为true时显示）
   * 
   * 设计特点：
   * - 使用圆角边框和内边距增强视觉效果
   * - 本地书籍使用特殊标签标识（棕色背景）
   * - 置顶书籍使用置顶标签标识
   * - 文本使用省略号处理溢出，确保布局稳定
   */
  build() {
    Flex(
      {
        alignItems:ItemAlign.Center,      // 垂直居中对齐
        justifyContent:FlexAlign.SpaceBetween  // 两端对齐
      }
    ) {
      // 左侧：书籍封面和信息区域
      Row({
        space:20  // 子元素间距20px
      }){
        // 书籍封面区域（使用Stack实现标签叠加）
        Stack(){
          // 本地书籍标签（显示在封面右上角）
          if (this.bookData.isLocalBook){
            Text('本地')
              .fontColor('#FFEDD4')  // 浅黄色文字
              .fontWeight(FontConstants.FONT_WEIGHT_400)  // 正常字体粗细
              .fontSize(9)           // 小字号
              .padding(3)            // 内边距
              .backgroundColor('#523000')  // 深棕色背景
              .zIndex(1)             // 确保标签在封面之上
              .borderRadius({
                topRight: 6,         // 右上角圆角
                bottomLeft: 6,       // 左下角圆角
              })
          }
          
          // 书籍封面和置顶标签区域
          Stack(){
            // 置顶标签（显示在封面左下角）
            if (this.bookData.isTop){
              Text('置顶')
                .fontColor(Color.White)  // 白色文字
                .fontWeight(FontConstants.FONT_WEIGHT_400)  // 正常字体粗细
                .fontSize(9)             // 小字号
                .padding(3)              // 内边距
                .borderRadius(5)         // 圆角
                .backgroundColor('rgba(0, 0, 0, 0.45)')  // 半透明黑色背景
                .zIndex(1)               // 确保标签在封面之上
            }
            
            // 书籍封面图片
            Image(this.bookData.coverUrl)
              .draggable(false)  // 禁止拖拽
              .alt($r('app.media.icon_book_default_cover_one'))  // 默认封面（资源引用）
              .width(60)   // 宽度60px
              .height(80)  // 高度80px
          }
          .alignContent(Alignment.BottomStart)  // 置顶标签对齐到左下角
        }
        .alignContent(Alignment.TopEnd)  // 本地标签对齐到右上角

        // 书籍信息区域
        Column({
          space:24  // 子元素间距24px
        })
        {
          // 书籍名称
          Text(this.bookData.bookName)
            .fontWeight(700)  // 加粗显示
            
          // 书籍详细信息
          Column(){
            // 书籍简介（单行显示，溢出省略）
            Text(this.bookData.intro)
              .fontSize(12)
              .fontColor('rgb(174,174,174)')  // 灰色文字
              .textOverflow({
                overflow:TextOverflow.Ellipsis  // 文本溢出显示省略号
              })
              .ellipsisMode(EllipsisMode.END)   // 省略号在末尾
              .fontWeight(500)                  // 中等字体粗细
              .maxLines(1)                      // 最多显示1行
              
            // 最新章节标题（单行显示，溢出省略）
            Text(this.bookData.durChapterTitle)
              .fontSize(12)
              .fontColor('rgb(174,174,174)')  // 灰色文字
              .textOverflow({
                overflow:TextOverflow.Ellipsis  // 文本溢出显示省略号
              })
              .ellipsisMode(EllipsisMode.END)   // 省略号在末尾
              .fontWeight(500)                  // 中等字体粗细
              .maxLines(1)                      // 最多显示1行
          }
          .width('40%')  // 宽度占父容器的40%
          .alignItems(HorizontalAlign.Start)  // 左对齐
        }
        .alignItems(HorizontalAlign.Start)  // 整个信息区域左对齐
      }
      
      // 右侧：复选框区域（仅在管理模式下显示）
      if (this.isManage){
        Row() {
          Checkbox({
            name: JSON.stringify(this.bookData.id)  // 复选框名称，使用书籍ID的JSON字符串
          })
            .onClick(()=>{
              // 点击复选框时触发选择回调
              this.onSelect()
            })
            .select(this.bookData.id?this.checkGroup[this.bookData.id] ?? false:false)  // 绑定选中状态
            .onChange((val:boolean)=>{
              // 复选框状态变化时更新checkGroup
              if (this.bookData.id) {
                this.checkGroup[this.bookData.id] = val
              }
            })
            .selectedColor(this.theme.mainColor)      // 选中时使用主题主颜色
            .unselectedColor('rgba(0, 0, 0, 0.35)')   // 未选中时使用半透明黑色
        }
        .padding({ left: 15, right: 15, bottom: 5, top: 5 })  // 内边距
      }
    }
    .padding(10)        // 整体内边距10px
    .borderRadius(10)   // 圆角10px
  }
}

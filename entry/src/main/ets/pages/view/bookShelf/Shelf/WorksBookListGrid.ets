/**
 * 书单宫格展示组件
 * 
 * 功能概述：
 * 1. 以宫格形式展示书单信息，适用于"宫格"展示模式
 * 2. 显示书单封面、名称、书籍数量等基本信息
 * 3. 支持置顶标识显示
 * 4. 支持复选框选择功能（用于批量管理）
 * 5. 提供多层堆叠视觉效果，增强UI层次感
 * 
 * 使用场景：
 * - 在书单列表页面，当展示模式为"宫格"时使用
 * - 在书单管理页面，需要批量选择书单时使用
 * - 在其他需要紧凑展示书单信息的场景中使用
 * 
 * 组件特点：
 * - 使用Stack布局实现多层堆叠效果
 * - 支持复选框覆盖层，用于批量选择
 * - 显示置顶标识，突出重要书单
 * - 使用装饰性遮挡层增强视觉效果
 * - 响应主题颜色变化，保持UI一致性
 */
import { ThemeStorageKey } from '../../../../common/constants/Theme'
import { ThemeItem } from '../../../../common/model/Theme'
import { WorksLists } from '../../../../database/entities/WorksLists'

@Component
export default struct WorksBookListGrid {
  /** 
   * 书单数据对象，包含书单的所有信息
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop work:WorksLists
  
  /** 
   * 是否显示复选框（用于批量选择）
   * true: 显示复选框，进入选择模式
   * false: 隐藏复选框，正常显示模式
   */
  @Prop isShowCheck:boolean
  
  /** 
   * 复选框状态记录，键为书单ID，值为是否选中
   * 通过@Link装饰器与父组件双向绑定，同步选择状态
   */
  @Link checkGroup:Record<number, boolean>
  
  /** 
   * 选择回调函数，当用户选择书单时触发
   * 默认为空函数，父组件可以覆盖此函数以处理选择逻辑
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
   * 1. 使用Column布局，水平起始对齐
   * 2. 顶部：多层堆叠的书单封面区域
   *    - 第0层：装饰性遮挡层2（最底层）
   *    - 第1层：装饰性遮挡层1（中间层）
   *    - 第2层：书单封面和置顶标识（主要内容层）
   *    - 第3层：复选框覆盖层（选择模式时显示）
   * 3. 中部：装饰性白色矩形（视觉分隔）
   * 4. 底部：书单信息区域（名称和书籍数量）
   * 
   * 设计特点：
   * - 使用多层Stack实现立体视觉效果
   * - 复选框覆盖层使用半透明黑色背景
   * - 置顶标识使用白色文字和半透明黑色背景
   * - 书单名称支持省略号，最多显示2行
   * - 书籍数量使用灰色文字，增强可读性
   */
  build() {
    Column() {
      // 顶部：多层堆叠的书单封面区域
      Stack() {
        // 复选框覆盖层（选择模式时显示）
        if (this.isShowCheck){
          Flex({
            alignItems: ItemAlign.End,      // 垂直底部对齐
            justifyContent: FlexAlign.End   // 水平右对齐
          }){
            Checkbox()
              .zIndex(2)  // 层级2
              .selectedColor(this.theme.mainColor)  // 选中颜色使用主题主色
              .unselectedColor('rgba(0, 0, 0, 0.35)')  // 未选中颜色：35%透明黑色
              .select(this.work.worksId?this.checkGroup[this.work.worksId] ?? false:false)  // 绑定选中状态
              .selectedColor(this.theme.mainColor)  // 再次设置选中颜色（确保生效）
              .onChange((val: boolean) => {
                // 复选框状态变化时更新选择状态
                if (this.work.worksId) {
                  this.checkGroup[this.work.worksId] = val
                }
              })
              .onClick(() => {
                this.onSelect()  // 触发选择回调
              })
          }
          .zIndex(3)  // 层级3（最上层）
          .backgroundColor('rgba(0,0,0,0.45)')  // 45%透明黑色背景
          .width(88).height(120)  // 固定宽高
        }
        
        // 书单封面和置顶标识层
        Stack(){
          // 置顶标识
          if (this.work.isTop){
            Text('置顶')
              .fontColor(Color.White)        // 白色文字
              .fontWeight(300)               // 字体粗细300
              .fontSize(8)                   // 字体大小8
              .padding(3)                    // 内边距3
              .borderRadius(5)               // 圆角5
              .backgroundColor('rgba(0, 0, 0, 0.45)')  // 45%透明黑色背景
              .zIndex(1)                     // 层级1
          }
          // 书单封面图片
          Image(this.work.worksCoverUrl)
            .draggable(false)  // 禁止拖拽
            .alt($r('app.media.icon_book_default_cover_one'))  // 默认封面
            .width(88)  // 宽度88
            .height(120)  // 高度120
        }
        .zIndex(2)  // 层级2
        .alignContent(Alignment.BottomStart)  // 底部起始对齐
        
        // 装饰性遮挡层1（中间层）
        Row() {
          Image($r('app.media.occlusion1'))  // 遮挡图片1
            .draggable(false)  // 禁止拖拽
        }
        .zIndex(1)  // 层级1
        .width(95)  // 宽度95
        .height(110)  // 高度110

        // 装饰性遮挡层2（最底层）
        Row() {
          Image($r('app.media.occlusion2'))  // 遮挡图片2
            .draggable(false)  // 禁止拖拽
        }
        .zIndex(0)  // 层级0（最底层）
        .width(100)  // 宽度100
        .height(100)  // 高度100
      }
      .align(Alignment.BottomStart)  // 底部起始对齐

      // 中部：装饰性白色矩形（视觉分隔）
      Row()
        .width(100)
        .height(20)
        .backgroundColor('rgba(255, 255, 255, 0.6)')  // 60%透明白色
        .borderRadius(10)  // 圆角10

      // 底部：书单信息区域
      Text(this.work.worksName)  // 书单名称
          .fontSize(15)          // 字体大小15
          .fontWeight(700)       // 字体粗细700（加粗）
          .textOverflow({
            overflow:TextOverflow.Ellipsis  // 文本溢出显示省略号
          })
          .ellipsisMode(EllipsisMode.END)   // 省略号在末尾
          .maxLines(2)                      // 最多显示2行
        
      Text(`共${this.work.worksBookNum}本`)  // 书籍数量
        .fontSize(12)                        // 字体大小12
        .fontColor('rgb(174,174,174)')       // 灰色文字
        .textOverflow({
          overflow:TextOverflow.Ellipsis     // 文本溢出显示省略号
        })
        .ellipsisMode(EllipsisMode.END)      // 省略号在末尾
        .fontWeight(500)                     // 字体粗细500
        .maxLines(1)                         // 最多显示1行
    }
    .alignItems(HorizontalAlign.Start)  // 水平起始对齐
    .padding({ left:8,right:8,bottom:5,top:5 })  // 内边距
  }
}

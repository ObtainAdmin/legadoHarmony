import { ThemeStorageKey } from '../../../../../common/constants/Theme'
import { ThemeItem } from '../../../../../common/model/Theme'
import { BookGroups } from '../../../../../database/entities/BookGroups'

/**
 * 文件夹宫格管理组件
 * 
 * 功能概述：
 * 1. 提供文件夹（分组）的宫格视图展示，用于管理页面
 * 2. 支持复选框选择功能，用于批量操作
 * 3. 显示分组封面、名称、书籍数量、置顶标识
 * 4. 使用堆叠布局实现视觉层次效果
 * 
 * 使用场景：
 * - 在书籍管理页面中显示分组列表（宫格模式）
 * - 支持用户选择分组进行批量操作（置顶、移动、删除等）
 * 
 * 组件特点：
 * - 使用@Component装饰器，作为可复用组件
 * - 三层堆叠布局：复选框层、封面层、遮挡层
 * - 视觉层次：使用zIndex控制图层顺序
 * - 主题颜色适配：使用主题主颜色作为复选框选中颜色
 * - 响应式设计：固定尺寸的宫格布局
 */
@Component
export default struct BookFolderGridManage {
  /** 分组数据，通过@Prop装饰器从父组件传入 */
  @Prop group:BookGroups
  
  /** 
   * 复选框状态记录，通过@Link装饰器与父组件双向绑定
   * 键为分组ID，值为是否选中
   */
  @Link checkGroup:Record<number, boolean>
  
  /** 是否处于管理模式，通过@Prop装饰器从父组件传入 */
  @Prop isManage:boolean
  
  /** 选择状态变化回调函数 */
  onSelect:Function = () => {}
  
  /** 主题颜色，通过@StorageProp从AppStorage获取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * 构建组件UI布局
   * 
   * 布局结构：
   * 1. 顶部：三层堆叠布局
   *    - 第一层（zIndex=2）：复选框层（管理模式下显示）和封面层
   *    - 第二层（zIndex=1）：遮挡层1（occlusion1）
   *    - 第三层（zIndex=0）：遮挡层2（occlusion2）
   * 2. 中部：白色半透明矩形（视觉分隔）
   * 3. 底部：分组名称和书籍数量
   * 
   * 设计特点：
   * - 宫格尺寸：固定宽度和高度
   * - 封面尺寸：88×120像素
   * - 置顶标识：黑色半透明背景，白色文字
   * - 文字样式：分组名称加粗，书籍数量灰色
   * - 内边距：左右8px，上下5px
   */
  build() {
    Column() {
      // 顶部：三层堆叠布局
      Stack() {
        // 第一层：复选框层和封面层（zIndex=2）
        Stack(){
          // 管理模式下显示复选框
          if (this.isManage){
            Checkbox()
              .zIndex(9)  // 最高层级
              .select(this.group.groupId?this.checkGroup[this.group.groupId] ?? false:false)  // 绑定选中状态
              .selectedColor(this.theme.mainColor)  // 使用主题主颜色
              .onChange((val: boolean) => {
                if (this.group.groupId) {
                  this.checkGroup[this.group.groupId] = val  // 更新选中状态
                }
              })
              .onClick(()=>{
                this.onSelect()  // 触发选择回调
              })
          }
          // 封面层：置顶标识和封面图片
          Stack(){
            // 置顶标识（如果分组已置顶）
            if (this.group.isTop){
              Text('置顶').fontColor(Color.White).fontWeight(300).fontSize(8).padding(3).borderRadius(5)
                .backgroundColor('rgba(0, 0, 0, 0.45)').zIndex(1)  // 黑色半透明背景
            }
            // 分组封面图片
            Image(this.group.coverUrl)
              .draggable(false)  // 禁止拖拽
              .alt($r('app.media.icon_book_default_cover_one'))  // 默认封面
              .width(88)  // 固定宽度
              .height(120)  // 固定高度
          }.alignContent(Alignment.BottomStart)  // 底部对齐
        }
        .alignContent(Alignment.BottomEnd)  // 底部对齐
        .zIndex(2)  // 第二层级

        // 第二层：遮挡层1（zIndex=1）
        Row() {
          Image($r('app.media.occlusion1')).draggable(false)  // 遮挡图片1
        }
        .zIndex(1).width(95).height(110)  // 尺寸略小于封面
        
        // 第三层：遮挡层2（zIndex=0）
        Row() {
          Image($r('app.media.occlusion2')).draggable(false)  // 遮挡图片2
        }
        .zIndex(0).width(100).height(100)  // 尺寸最小
      }
      .alignContent(Alignment.BottomStart)  // 底部对齐
      
      // 中部：白色半透明矩形（视觉分隔）
      Row().width(100).height(20).backgroundColor('rgba(255, 255, 255, 0.6)').borderRadius(10)
      
      // 底部：分组名称（最多2行，超出显示省略号）
      Text(this.group.groupName)
          .fontSize(15)
          .fontWeight(700)  // 加粗
          .textOverflow({
            overflow:TextOverflow.Ellipsis  // 超出显示省略号
          })
          .ellipsisMode(EllipsisMode.END)  // 末尾省略
          .maxLines(2)  // 最多2行
      
      // 底部：书籍数量（灰色文字，单行显示）
      Text(`共${this.group.bookIds?.length||0}本`).fontSize(12).fontColor('rgb(174,174,174)')  // 灰色文字
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
import { ThemeStorageKey } from '../../../../../common/constants/Theme'
import { ThemeItem } from '../../../../../common/model/Theme'
import BookOverlay from '../../../../../componets/bookDetail/BookOverlay'
import { BookGroups } from '../../../../../database/entities/BookGroups'

/**
 * 文件夹列表管理组件
 * 
 * 功能概述：
 * 1. 提供文件夹（分组）的列表视图展示，用于管理页面
 * 2. 支持复选框选择功能，用于批量操作
 * 3. 显示分组封面、名称、书籍数量
 * 4. 使用BookOverlay组件显示封面和置顶标识
 * 
 * 使用场景：
 * - 在书籍管理页面中显示分组列表（列表模式）
 * - 支持用户选择分组进行批量操作（置顶、移动、删除等）
 * 
 * 组件特点：
 * - 使用@Component装饰器，作为可复用组件
 * - 水平Flex布局：左侧分组信息，右侧复选框
 * - 使用BookOverlay组件：集成封面显示和置顶标识
 * - 主题颜色适配：使用主题主颜色作为复选框选中颜色
 * - 响应式设计：自适应宽度的列表布局
 */
@Component
export default struct BookFolderInfoManage {
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
   * 1. 左侧：分组信息区域
   *    - BookOverlay组件：显示封面和置顶标识
   *    - 分组名称：加粗显示
   *    - 书籍数量：灰色文字，单行显示
   * 2. 右侧：复选框区域（管理模式下显示）
   * 
   * 设计特点：
   * - 水平Flex布局：两端对齐（SpaceBetween）
   * - 内边距：10px
   * - 圆角：10px
   * - 分组信息区域：左侧BookOverlay，右侧文字信息
   * - 复选框区域：左右内边距15px，上下内边距5px
   */
  build() {
    Flex(
      {
        alignItems:ItemAlign.Center,  // 垂直居中对齐
        justifyContent:FlexAlign.SpaceBetween  // 两端对齐
      }
    ) {
      // 左侧：分组信息区域
      Row({
        space:20  // 元素间距20px
      }){
        // BookOverlay组件：显示封面和置顶标识
        BookOverlay({
          bookImage:this.group.coverUrl,  // 分组封面
          isTop:this.group.isTop,  // 是否置顶
          coverType:this.group.coverType  // 封面类型
        })
        
        // 右侧：文字信息区域
        Column({
          space:24  // 元素间距24px
        })
        {
          // 分组名称：加粗显示
          Text(this.group.groupName)
            .fontWeight(700)  // 加粗
          
          // 书籍数量信息
          Column(){
            // 书籍数量：灰色文字，单行显示
            Text(`共${this.group.bookIds?.length||0}本`).fontSize(12).fontColor('rgb(174,174,174)')  // 灰色文字
              .textOverflow({
                overflow:TextOverflow.Ellipsis  // 超出显示省略号
              })
              .ellipsisMode(EllipsisMode.END)  // 末尾省略
              .fontWeight(400)
              .maxLines(1)  // 单行显示
              .lineHeight(20)  // 行高20px
            
            // 注释掉的代码：更新信息显示（暂未使用）
            // Text(this.group.?this.folderList.newUpdateBook:'暂无更新')
            //   .fontSize(12)
            //   .fontWeight(400)
            //   .textOverflow({
            //     overflow:TextOverflow.Ellipsis
            //   })
            //   .ellipsisMode(EllipsisMode.END)
            //   .maxLines(1)
            //   .lineHeight(20)
          }
          .width('60%')  // 宽度60%
          .alignItems(HorizontalAlign.Start)  // 左对齐
        }
        .alignItems(HorizontalAlign.Start)  // 左对齐
      }
      
      // 右侧：复选框区域（管理模式下显示）
      if (this.isManage){
        Row() {
          Checkbox()
            // 判断是否存在当前id，绑定选中状态
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
        .padding({ left: 15, right: 15, bottom: 5, top: 5 })  // 内边距
      }

    }
    .padding(10)  // 整体内边距
    .borderRadius(10)  // 圆角
  }


}
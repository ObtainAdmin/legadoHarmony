/**
 * 书单信息组件 - 列表视图
 * 
 * 功能概述：
 * 1. 显示书单的基本信息：封面、名称、书籍数量、描述
 * 2. 支持选择模式：显示复选框供用户选择书单
 * 3. 响应主题颜色变化，使用应用主题色
 * 4. 提供良好的文本溢出处理，确保UI整洁
 * 
 * 使用场景：
 * - 在书单列表页面中作为列表项使用
 * - 在管理模式下显示选择复选框
 * 
 * 组件特点：
 * - 使用Flex布局实现水平排列
 * - 左侧显示书单封面，右侧显示书单信息
 * - 根据isShowCheck参数动态显示/隐藏复选框
 * - 支持主题颜色适配
 */
import { ThemeStorageKey } from '../../../../common/constants/Theme'
import { ThemeItem } from '../../../../common/model/Theme'
import BookOverlay from '../../../../componets/bookDetail/BookOverlay'
import { WorksLists } from '../../../../database/entities/WorksLists'


@Component
export default struct WorksBookListInfo{
  /** 
   * 复选框状态记录，键为书单ID，值为是否选中
   * 通过@Link装饰器实现父子组件双向绑定
   */
  @Link checkGroup:Record<number, boolean>
  
  /** 
   * 书单数据对象，包含书单的所有信息
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop work:WorksLists
  
  /** 
   * 是否显示复选框，用于管理/选择模式
   * true: 显示复选框，允许选择书单
   * false: 不显示复选框，仅展示信息
   */
  @Prop isShowCheck:boolean
  
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
   * 2. 左侧：书单封面（使用BookOverlay组件）
   * 3. 中间：书单信息（名称、书籍数量、描述）
   * 4. 右侧：复选框（仅在isShowCheck为true时显示）
   * 
   * 设计特点：
   * - 使用圆角边框和内边距增强视觉效果
   * - 文本使用省略号处理溢出，确保布局稳定
   * - 复选框使用主题主颜色，保持UI一致性
   */
  build() {
    Flex(
      {
        alignItems:ItemAlign.Center,      // 垂直居中对齐
        justifyContent:FlexAlign.SpaceBetween  // 两端对齐
      }
    ) {
      // 左侧：书单封面和信息区域
      Row({
        space:20  // 子元素间距20px
      }){
        // 书单封面区域
        Column(){
          BookOverlay({
            bookImage:this.work.worksCoverUrl,  // 书单封面图片URL
            isTop:false,                        // 不显示置顶标签
            isShow:this.isShowCheck             // 是否显示选择状态
          })
        }
        
        // 书单信息区域
        Column({
          space:24  // 子元素间距24px
        })
        {
          // 书单名称
          Text(this.work.worksName)
            .fontWeight(700)  // 加粗显示
          
          // 书单详细信息
          Column(){
            // 书籍数量显示
            Text(`共${this.work.worksBookNum}本`).fontSize(12).fontColor('rgb(174,174,174)')
              .textOverflow({
                overflow:TextOverflow.Ellipsis  // 文本溢出显示省略号
              })
              .ellipsisMode(EllipsisMode.END)   // 省略号在末尾
              .fontWeight(400)                  // 正常字体粗细
              .maxLines(1)                      // 最多显示1行
              .lineHeight(20)                   // 行高20px
            
            // 书单描述
            Text(this.work.worksDescribe)
              .fontSize(12).fontColor('rgb(174,174,174)')
              .fontSize(12)
              .fontWeight(400)
              .textOverflow({
                overflow:TextOverflow.Ellipsis  // 文本溢出显示省略号
              })
              .ellipsisMode(EllipsisMode.END)   // 省略号在末尾
              .maxLines(2)                      // 最多显示2行
              .lineHeight(20)                   // 行高20px
          }
          .width('60%')  // 宽度占父容器的60%
          .alignItems(HorizontalAlign.Start)  // 左对齐
        }
        .alignItems(HorizontalAlign.Start)  // 整个信息区域左对齐
      }
      
      // 右侧：复选框区域（仅在管理模式下显示）
      if (this.isShowCheck){
        Row() {
          Checkbox()
            .selectedColor(this.theme.mainColor)  // 使用主题主颜色作为选中颜色
            .select(this.work.worksId?this.checkGroup[this.work.worksId] ?? false:false)  // 绑定选中状态
            .onChange((val: boolean) => {
              // 复选框状态变化时更新checkGroup
              if (this.work.worksId) {
                this.checkGroup[this.work.worksId] = val
              }
            })
            .onClick(() => {
              // 点击复选框时触发选择回调
              this.onSelect()
            })
        }
        .padding({ left: 15, right: 15, bottom: 5, top: 5 })  // 内边距
      }

    }
    .padding(10)        // 整体内边距10px
    .borderRadius(10)   // 圆角10px
  }

}

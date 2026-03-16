/**
 * 书籍列表管理组件
 * 
 * 功能概述：
 * 1. 根据展示模式（EXHIBIT）动态渲染书籍列表
 * 2. 支持两种展示模式：宫格视图和列表视图
 * 3. 处理空数据状态，显示友好的空状态提示
 * 4. 提供书籍选择功能，支持批量操作
 * 5. 集成书籍信息展示组件（BookInfoManage/BookInfoGridManage）
 * 
 * 使用场景：
 * - 在书籍管理页面中显示书籍列表
 * - 在书架页面中根据用户偏好显示不同视图
 * - 在搜索结果显示页面中使用
 * 
 * 组件特点：
 * - 根据EXHIBIT参数动态切换展示模式
 * - 宫格模式：使用GridRow/GridCol布局，每行3列
 * - 列表模式：使用Column布局，垂直排列
 * - 空数据状态：显示默认图片和提示文字
 * - 支持选择状态传递，实现批量操作
 */
import BookInfoManage from './BookInfoManage'
import BookInfoGridManage from './BookInfoGridManage'
import { Books } from '../../../../../database/entities/Books'

@Component
export default struct bookListManage{
  /** 
   * 展示模式，控制书籍列表的显示方式
   * 可选值：'宫格' - 宫格视图，'列表' - 列表视图
   * 默认值：从父组件传递，通常来自用户设置或页面配置
   */
  @Prop EXHIBIT:string
  
  /** 
   * 书籍列表数据，包含要显示的所有书籍
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop bookList:Books[]
  
  /** 
   * 是否处于管理模式
   * true: 显示复选框，允许选择书籍
   * false: 不显示复选框，仅展示书籍信息
   * 默认值：true（默认显示复选框）
   */
  @Prop isManage:boolean = true
  
  /** 
   * 复选框状态记录，键为书籍ID，值为是否选中
   * 通过@Link装饰器实现父子组件双向绑定
   */
  @Link checkGroup:Record<number, boolean>
  
  /** 
   * 删除缓存状态标识（暂未使用）
   * 用于控制删除操作的相关状态
   */
  @State delCache:boolean = false
  
  /** 
   * 选择回调函数，当用户选择书籍时触发
   * 默认为空函数，父组件可以覆盖此函数以处理选择事件
   */
  onSelect:Function = () => {}
  
  /**
   * 构建组件UI
   * 
   * 逻辑流程：
   * 1. 检查书籍列表是否为空或null
   * 2. 如果为空：显示空状态提示（图片和文字）
   * 3. 如果不为空：根据EXHIBIT参数选择展示模式
   *    - '宫格'模式：使用GridRow布局，每行3列
   *    - 其他模式：使用Column布局，垂直列表
   * 
   * 设计特点：
   * - 空状态提示居中显示，有适当的边距
   * - 宫格模式适合浏览大量书籍，视觉效果好
   * - 列表模式适合查看详细信息，空间利用率高
   * - 组件间距统一为10px，保持UI一致性
   */
  build() {
    // 检查书籍列表是否为空
    if (this.bookList === null || this.bookList.length === 0) {
      // 空数据状态：显示提示信息
      Column() {
        // 空状态图片
        Image($r('app.media.no_record'))  // 资源引用：无记录图片
          .width(200)
          .height(200)
        
        // 提示文字
        Text('暂无浏览记录')
          .fontSize(12)
          .fontColor('rgba(96, 96, 96, 0.6)')  // 半透明灰色
          .fontWeight(500)                     // 中等字体粗细
          .padding(5)                          // 内边距
      }
      .margin({ top: 120 })  // 顶部边距120px，使内容居中

    } else {
      // 有数据状态：根据展示模式渲染书籍列表
      Column(
        {space:10}  // 子元素间距10px
      ){
        // 宫格展示模式
        if (this.EXHIBIT === '宫格') {
         GridRow({
           columns: 3  // 每行3列
         }){
           // 遍历书籍列表，渲染宫格项
           ForEach(this.bookList, (item: Books,index:number) => {
             GridCol(){
               // 使用宫格视图组件显示书籍信息
               BookInfoGridManage({
                 bookData:item,           // 当前书籍数据
                 isManage:this.isManage,  // 是否显示复选框
                 checkGroup:this.checkGroup,  // 选择状态记录
                 onSelect: ()=>{
                   // 选择回调，触发父组件的选择处理
                   this.onSelect()
                 }
               })
             }
           })
         }
        } else {
          // 列表展示模式（默认）
          Column({
            space: 10  // 子元素间距10px
          }) {
            // 遍历书籍列表，渲染列表项
            ForEach(this.bookList, (item: Books,index:number) => {
              // 使用列表视图组件显示书籍信息
              BookInfoManage({
                bookData:item,           // 当前书籍数据
                isManage:this.isManage,  // 是否显示复选框
                checkGroup:this.checkGroup,  // 选择状态记录
                onSelect: ()=>{
                  // 选择回调，触发父组件的选择处理
                  this.onSelect()
                }
              })
            })
          }
        }
      }

    }
  }
}

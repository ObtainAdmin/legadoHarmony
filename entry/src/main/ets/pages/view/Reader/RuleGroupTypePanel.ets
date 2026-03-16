/**
 * ============================================
 * RuleGroupTypePanel.ets - 规则分组管理面板组件
 * ============================================
 * 
 * 【功能说明】
 * 这是一个规则分组管理的面板组件，提供以下功能：
 * - 显示所有规则类型的分组网格布局
 * - 支持切换"管理"模式进行拖拽排序
 * - 点击完成退出管理模式
 * - 点击关闭按钮隐藏面板
 * - 使用主题色适配 UI 样式（选中项高亮）
 * 
 * 【使用方法】
 * 1. 通过 groupCoverShow 控制面板显示/隐藏
 * 2. 点击"管理"进入管理模式，可拖拽重新排序
 * 3. 点击"完成"保存排序并退出管理模式
 * 4. 点击×按钮关闭面板
 * 
 * 【参数说明】
 * @Link groupCoverShow: boolean         // 控制面板显示的双向绑定变量
 * @State isShowIcon: boolean           // 是否显示拖拽图标（管理模式标识）
 * @Link ruleList: Array<string>        // 规则类型列表（双向绑定，可重排序）
 * @StorageProp GROUP_LIST_DATA         // 从存储获取的分组数据
 * @StorageProp APP_INDEX_SCROLLABLE    // 应用索引滚动状态
 * @StorageProp THEME                   // 主题颜色配置
 * 
 *
 * @author cyd
 * @version 1.0
 */

import { ThemeStorageKey } from '../../../common/constants/Theme'
import { ThemeItem } from '../../../common/model/Theme'
import { showMessage } from '../../../componets/common/promptShow'
import { folderList } from '../../../componets/dataList/folderList'

@Component
export default struct RuleGroupTypePanel{
  // ============================================
  // 状态变量
  // ============================================
  
  // 覆盖层显示状态
  // true = 面板显示，false = 面板隐藏
  @Link groupCoverShow:boolean
  
  // 是否显示拖拽图标（管理模式开关）
  // true = 显示排序图标，进入拖拽模式
  // false = 隐藏排序图标，正常点击模式
  @State isShowIcon:boolean = false
  
  // 规则类型列表
  // 与父组件双向绑定，拖拽排序后会更新此数组
  @Link ruleList:Array<string>

  // 分组列表数据（从 Storage 读取）
  // 用于存储分组的扩展信息（颜色、图标等）
  @StorageProp('GROUP_LIST_DATA') groupData:folderList[] = []

  // 应用索引滚动状态（预留字段）
  @StorageProp('APP_INDEX_SCROLLABLE') APP_INDEX_SCROLLABLE: boolean = true
  
  // 主题颜色配置
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  build() {
    Column({ space:15 }) {  // 上下间距 15vp
      // ============================================
      // 标题栏
      // ============================================
      Flex({
        justifyContent:FlexAlign.SpaceBetween,  // 两端对齐
        alignItems:ItemAlign.End                // 底部对齐
      }){
        // 左侧：标题和提示文字
        Row({space:12}){
          // 主标题
          Text('分组管理')
            .fontSize(16)
            .fontWeight(500)
            .lineHeight(24)
            .fontColor('rgba(0, 0, 0, 0.88)')
          
          // 提示文字
          Text('点击进入，长按编辑')
            .fontSize(12)
            .fontWeight(400)
            .lineHeight(20)
            .fontColor('rgba(0, 0, 0, 0.45)')
        }.alignItems(VerticalAlign.Bottom)
        
        // 右侧：操作按钮区
        Row({space:12}){
          // 管理模式切换按钮
          Text(this.isShowIcon?'完成':'管理')
            .fontSize(12)
            .fontWeight(400)
            .lineHeight(20)
            .fontColor(this.theme.mainColor)  // 使用主题主色
            .onClick(()=>{
              this.isShowIcon = !this.isShowIcon  // 切换管理模式
            })
          
          // 关闭按钮
          Image($r('app.media.close'))
            .width(24).height(20)
            .onClick(()=>{
              this.groupCoverShow = false   // 关闭面板
              this.isShowIcon = false       // 退出管理模式
            })
        }
      }
      
      // ============================================
      // 分组网格区
      // ============================================
      Flex({
        direction: FlexDirection.Row,        // 行方向
        wrap: FlexWrap.Wrap,                 // 自动换行
        justifyContent:FlexAlign.Start       // 左对齐
      }){
        ForEach(this.ruleList, (item:string, index:number)=>{
          if (index === 0) {
            // -----------------------------------------
            // "全部"分组（特殊样式：主题色）
            // -----------------------------------------
            Row(){
              this.GroupTypeColor(item)  // 使用彩色样式构建器
              
              // 管理模式：显示排序图标
              if (this.isShowIcon) {
                Image($r('app.media.sort'))
                  .width(12).height(12)
                  .offset({x:-20,y:-20})  // 偏移至右上角
              }
            }
            .width('25%')  // 占 1/4 宽度，每行 4 个
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.dragIndex = index  // 记录起始拖拽索引
                console.info('onTouch' + this.dragIndex)
              }
            })
            .draggable(this.isShowIcon)  // 仅在管理模式可拖拽
            .onDragStart(()=>{
              console.log('onDragStart')
            })
            .onDrop((event: DragEvent, extraParams: string) => {
              console.log('onDrop')
              this.changeIndex(this.dragIndex, index)  // 交换位置
            })

          } else {
            // -----------------------------------------
            // 普通分组
            // -----------------------------------------
            Row(){
              this.GroupType(item)  // 使用普通样式构建器
              
              // 管理模式：显示排序图标
              if (this.isShowIcon) {
                Image($r('app.media.sort'))
                  .width(12).height(12)
                  .offset({x:-20,y:-20})
              }
            }
            .width('25%')
            .draggable(this.isShowIcon)
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.dragIndex = index
                console.info('onTouch' + this.dragIndex)
              }
            })
            .onDragStart(()=>{
              console.log('onDragStart')
            })
            .onDrop((event: DragEvent, extraParams: string) => {
              console.log('onDrop')
              this.changeIndex(this.dragIndex, index)  // 交换位置
            })
          }
        })
      }
    }
    .borderRadius({bottomLeft:20,bottomRight:20})  // 底部圆角
    .padding({left:20,right:20,top:12,bottom:12})
    .width('100%').backgroundColor(Color.White)
  }

  // ============================================
  // 拖拽相关状态和方法
  // ============================================
  
  // 当前拖拽元素的索引
  @State dragIndex: number = 0
  
  /**
   * 交换两个元素的位置
   * @param index1 - 源索引
   * @param index2 - 目标索引
   */
  changeIndex(index1: number, index2: number) {
    // 非管理模式下提示用户
    if (!this.isShowIcon) {
      showMessage('请在管理状态下拖到改变顺序')
      return
    }

    // 交换数组元素
    let temp1 = this.ruleList[index1];
    this.ruleList[index1] = this.ruleList[index2];
    this.ruleList[index2] = temp1;
  }
  
  /**
   * 构建"全部"分组样式（主题色高亮）
   * @param title - 分组名称
   */
  @Builder GroupTypeColor(title:string){
    Column(){
      Row(){
        Text(title)
          .fontWeight(500)
          .fontSize(12)
          .textOverflow({ overflow:TextOverflow.Ellipsis })
          .ellipsisMode(EllipsisMode.END)
          .maxLines(1)
          .fontColor(this.theme.mainColor)  // 使用主题主色
          .textAlign(TextAlign.Center)
      }
      .margin({ right: 16, bottom: 16 })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width(68)
      .backgroundColor(this.theme.secondColor)  // 使用主题次色背景
      .padding({left:16,right:16,top:6,bottom:6})
    }
  }
  
  /**
   * 构建普通分组样式
   * @param title - 分组名称
   */
  @Builder GroupType(title:string){
   Column(){
     Row(){
       Text(title)
         .fontWeight(500)
         .fontSize(12)
         .textOverflow({ overflow:TextOverflow.Ellipsis })
         .ellipsisMode(EllipsisMode.END)
         .maxLines(1)
         .fontColor(Color.Black)  // 黑色文字
         .textAlign(TextAlign.Center)
     }
     .margin({ right: 16, bottom: 16 })
     .justifyContent(FlexAlign.Center)
     .alignItems(VerticalAlign.Center)
     .width(68)
     .backgroundColor('rgba(0, 0, 0, 0.04)')  // 浅灰色背景
     .padding({left:16,right:16,top:6,bottom:6})
   }
  }
}

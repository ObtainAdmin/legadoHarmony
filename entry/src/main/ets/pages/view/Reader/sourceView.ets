/**
 * ============================================
 * sourceView.ets - 书源管理视图组件
 * ============================================
 * 
 * 【功能说明】
 * 这是一个完整的书源管理和切换界面，提供：
 * - 整本换源 / 单章换源模式切换
 * - 搜索书源（全文搜索）
 * - 显示搜索结果列表（共 24 个书源示例）
 * - 筛选功能入口
 * - 手动刷新按钮
 * - 每个书源的评分、章节信息和快捷操作
 * - 使用主题色适配 UI 样式
 * 
 * 【使用方法】
 * 1. 点击"整本换源"/"单章换源"切换模式
 * 2. 在搜索框输入关键字搜索书源
 * 3. 点击书源卡片查看详情和选择章节
 * 4. 点击右侧点赞/点踩图标评价书源
 * 5. 点击"点击刷新"重新加载书源列表
 * 6. 点击"筛选"打开筛选面板（待实现）
 * 
 * 【参数说明】
 * @State sourceType: string            // 当前换源模式（'整本换源'/'单章换源'）
 * @StorageLink bottomRectHeight        // 底部系统区域高度（适配）
 * @StorageProp THEME                   // 主题颜色配置
 * 
 *
 * @author 2008, cyd
 * @datetime 2024/6/7 19:48
 * @version 1.0
 */

import { ThemeStorageKey } from '../../../common/constants/Theme'
import { ThemeItem } from '../../../common/model/Theme'
import sourceCommon from './sourceCommon'

@Component
@Preview
export default struct sourceView{
  // ============================================
  // 状态变量
  // ============================================
  
  // 当前选中的换源模式
  // '整本换源' = 替换整本书的源
  // '单章换源' = 单独更换某一章节的源
  @State sourceType:string = '整本换源'
  
  // 底部系统区域高度（刘海屏/折叠屏适配）
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  // 主题颜色配置
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  build() {
    Column({ space:16 }) {
      // ============================================
      // 标题栏和搜索区
      // ============================================
      Stack(){
        Row({ space:12 }) {
          // 装饰性分隔线（视觉效果）
          Divider()
            .vertical(true)  // 垂直方向
            .height(15)
            .color('#989797')
            .opacity(0.5)
            .strokeWidth(1)

          // 页面标题
          Text('书源管理')
            .fontSize(14)
            .fontWeight(400)
            .fontColor($r('app.string.color_black_45'))
        }
        .margin({right:25})
        
        // 搜索框：搜索全文
        Search({placeholder:'搜索全文'})
      }
      .margin({left:20,right:20})
      .alignContent(Alignment.End)
      
      // ============================================
      // 模式切换标签栏
      // ============================================
      Flex() {
        Row({ space:24 }) {
          // "整本换源"标签
          Column(){
            Text('整本换源')
              .font({ size:16, weight:500 })
              .fontColor(
                this.sourceType === '整本换源'?
                  $r('app.string.color_black_88') :   // 选中：黑色
                  $r('app.string.color_black_45')     // 未选中：灰色
              )
            
            // 选中指示器（底部横线）
            if (this.sourceType === '整本换源'){
              Row()
                .width(10).height(3)
                .backgroundColor(this.theme.mainColor)  // 主题主色
                .borderRadius(8)
                .offset({y:16})
            }
          }.onClick(()=>{
            this.sourceType ='整本换源'  // 切换到整本换源模式
          })
          
          // "单章换源"标签
          Column(){
            Text('单章换源')
              .font({ size:16, weight:500 })
              .fontColor(
                this.sourceType !== '整本换源'?
                  $r('app.string.color_black_88') :   // 选中：黑色
                  $r('app.string.color_black_45')     // 未选中：灰色
              )
            
            // 选中指示器
            if (this.sourceType !== '整本换源'){
              Row()
                .width(10).height(3)
                .backgroundColor(this.theme.mainColor)
                .borderRadius(8)
                .offset({y:16})
            }
          }.onClick(()=>{
            this.sourceType ='单章换源'  // 切换到单章换源模式
          })
        }.padding({left:20,right:20})
      }
      
      Divider()  // 分隔线
      
      // ============================================
      // 结果统计和操作栏
      // ============================================
      Flex({
        justifyContent:FlexAlign.SpaceBetween,
        alignItems:ItemAlign.Center
      }){
        Row(){
          // 搜索结果数量
          Text('共搜索到 24 个书源，')
            .fontWeight(400)
            .fontSize(14)
            .fontColor($r('app.string.color_black_45'))
          
          // 刷新按钮（可点击）
          Text('点击刷新')
            .fontWeight(400)
            .fontSize(14)
            .fontColor(this.theme.mainColor)  // 主题色突出显示
        }
        
        // 筛选按钮
        Row({ space:4 }) {
          Image($r('app.media.screen_icon'))  // 筛选图标
            .width(16).height(16)
          
          Text('筛选')
            .fontWeight(400)
            .fontSize(14)
            .fontColor($r('app.string.color_black_45'))
        }
      }.margin({left:20,right:20})
      
      // ============================================
      // 书源列表（可滚动）
      // ============================================
      Scroll(){
        Column({ space:20 }) {  // 列表项间距 20vp
          // 第一个书源：已选中状态（5 星满分）
          sourceCommon({
            IsSelect: true,       // 选中状态
            rating: 5.0,          // 评分 5.0
            sourceType:this.sourceType
          })
          
          // 其他书源：未选中状态
          sourceCommon({
            IsSelect: false,
            rating: 4.5,
            sourceType:this.sourceType
          })
          sourceCommon({
            IsSelect: false,
            rating: 4.5,
            sourceType:this.sourceType
          })
          sourceCommon({
            IsSelect: false,
            rating: 4.5,
            sourceType:this.sourceType
          })
          sourceCommon({
            IsSelect: false,
            rating: 4.5,
            sourceType:this.sourceType
          })
          sourceCommon({
            IsSelect: false,
            rating: 4.5,
            sourceType:this.sourceType
          })
        }
      }
      .padding({ left:20, right:20, bottom:this.bottomRectHeight?this.bottomRectHeight+5:30 })
      .layoutWeight(1)  // 占据剩余空间
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)  // 隐藏滚动条

    }.padding({top:12})
  }
}

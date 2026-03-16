/**
 * ============================================
 * sourceCommon.ets - 书源通用组件
 * ============================================
 * 
 * 【功能说明】
 * 这是一个展示和管理书籍来源的通用组件，提供：
 * - 显示书名源信息（如起点中文网）
 * - 评分展示和交互式评分
 * - 精品标识徽章
 * - 最新章节/当前章节显示
 * - 选择章节功能（单本换源模式）
 * - 点赞/点踩快捷操作
 * - 根据选择状态调整 UI 样式
 * 
 * 【使用方法】
 * 1. 作为书籍来源卡片嵌入到来源列表中
 * 2. 通过 IsSelect 控制是否为选中状态（影响边框和背景色）
 * 3. 通过 sourceType 区分"整本换源"或单本换源模式
 * 4. 点击评分可调整该来源的评分
 * 5. 点击"选择章节"打开章节选择弹窗
 * 
 * 【参数说明】
 * @State rating: number            // 评分值（0-5，默认 3.5）
 * @Prop IsSelect: boolean          // 是否被选中（true=选中状态）
 * @Prop sourceType: string         // 来源类型（'整本换源'或其他）
 * @State isShowChapter: boolean    // 章节弹窗显示状态
 * @StorageProp THEME               // 主题颜色配置
 * 
 *
 * @author 2008, cyd
 * @datetime 2024/6/6 22:05
 * @version 1.0
 */

import { ThemeStorageKey } from '../../../common/constants/Theme'
import { ThemeItem } from '../../../common/model/Theme'
import chapterCommon from './chapterCommon'

@Component
export default struct sourceCommon{
  // ============================================
  // 状态变量
  // ============================================
  
  // 评分值（0-5 分）
  // 用户可点击星级进行评分
  @State rating: number = 3.5
  
  // 是否被选中
  // true = 选中状态（高亮边框和背景），false = 未选中
  @Prop IsSelect:boolean = true
  
  // 来源类型
  // '整本换源' = 整本书替换来源
  // 其他 = 单本换源（需选择章节）
  @Prop sourceType:string
  
  // 章节选择弹窗显示状态
  @State isShowChapter:boolean = false
  
  // 主题颜色配置
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  build() {
    Flex({
      justifyContent:FlexAlign.SpaceBetween,  // 两端对齐
      alignItems:ItemAlign.Center            // 垂直居中对齐
    }){
      // ============================================
      // 左侧：书源信息区
      // ============================================
      Column(){
        // 书源名称（如起点中文网）
        Text('起点中文网')
          .fontSize(16)
          .fontWeight(500)
          .lineHeight(24)
          .fontColor($r('app.string.color_black_88'))
          .padding({ bottom:8 })
        
        // 评分和徽章行
        Row(){
          // "精品"徽章标签
            Row(){
              Text('精品')
                .fontSize(9)
                .fontWeight(500)
                .textAlign(TextAlign.Center)
                .fontColor('#FFE5D4')  // 浅橙色文字
            }
            .borderRadius({topLeft:5,bottomLeft:5})  // 左侧圆角
            .align(Alignment.Center)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#854D00')  // 深棕色背景
            .padding({ top:4,bottom:4, left:4,right:4 })
          
          // 评分数字显示
          Row(){
            Text(this.rating.toFixed(1))  // 保留一位小数
              .fontSize(9)
              .fontWeight(500)
              .textAlign(TextAlign.Center)
              .fontColor('#854D00')  // 深棕色文字
          }
          .borderRadius({topRight:5,bottomRight:5})  // 右侧圆角
          .align(Alignment.Center)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFE5D4')  // 浅橙色背景
          .padding({ top:4,bottom:4, left:4,right:4 })
          
          // 评分交互组件
          Rating({ rating: this.rating, indicator: false })  // indicator=false 表示可编辑
            .stars(5)                 // 5 颗星
            .stepSize(0.5)            // 最小步进 0.5
            .onChange((value: number) => {
              this.rating = value     // 更新评分值
            }).padding({left:8})
        }
        .padding({ bottom:12 })
        
        // -----------------------------------------
        // 章节信息显示（根据来源类型不同）
        // -----------------------------------------
        if (this.sourceType === '整本换源'){
          // 整本换源模式：显示最新章节
          Row(){
            Text('最新 番外三 庆功宴')
              .fontSize(12)
              .fontWeight(400)
              .lineHeight(20)
              .fontColor($r('app.string.color_black_45'))
          }
        } else {
          // 单本换源模式：显示当前章节和选择按钮
          Flex({
            justifyContent:FlexAlign.SpaceBetween,
            alignItems:ItemAlign.End
          }){
            // 当前章节名称
            Text('第一章 牢狱之灾')
              .fontSize(12)
              .fontWeight(400)
              .lineHeight(20)
              .fontColor($r('app.string.color_black_45'))
            
            // 选择章节按钮（仅在非选中模式下显示）
            if (!this.IsSelect) {
              Row(){
                Text('选择章节').fontSize(12).fontColor($r('app.string.color_black_45'))
                
                Image($r("app.media.icon_right"))
                  .fillColor($r('app.string.color_black_65'))
                  .size({width:16,height:16})
              }
              // 绑定章节选择弹窗
              .bindSheet($$this.isShowChapter, this.chapterView(), {
                height: '95%',
                showClose: false,
                dragBar: false,
                maskColor: 'rgba(0,0,0,0.6)',
                onDisappear:()=>{
                  console.log('隐藏章节选择面板')
                }
              })
              .onClick(()=>{
                this.isShowChapter = true  // 打开章节选择弹窗
              })
            }
          }.padding({right:16})
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left:16,top:12,bottom:12 })
      
      // ============================================
      // 右侧：快捷操作按钮区（仅选中模式显示）
      // ============================================
      if (this.IsSelect){
        Column({ space:16 }) {
          // 点赞图标
          Image($r('app.media.likes_icon')).width(24).height(24)
          
          // 点踩图标
          Image($r('app.media.tread_icon')).width(24).height(24)
        }.margin({ right:24 })
      }
    }
    // 整体样式：边框和背景根据选中状态变化
    .border({
      width:this.IsSelect?1:0,                    // 选中时有边框
      color:this.theme.mainColor,                  // 使用主题主色
      style:BorderStyle.Solid
    })
    .borderRadius(12)  // 圆角
    .backgroundColor(
      this.IsSelect?
        this.theme.secondColor :                   // 选中时：主题次色背景
        'rgba(0, 0, 0, 0.06)'                      // 未选中：浅灰色背景
    )
  }
  
  /**
   * 构建章节选择弹窗内容
   */
  @Builder
  chapterView(){
   Column(){
     // 拖动手柄
     Column() {
       Row().width(36).height(4).backgroundColor($r('app.string.color_black_15')).borderRadius(12)
     }
     .padding({ top: 12 })
     
     // 章节选择组件
     chapterCommon({
       isShowChapter:this.isShowChapter
     })
   }
  }
}

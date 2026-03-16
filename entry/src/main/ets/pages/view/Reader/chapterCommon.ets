/**
 * ============================================
 * chapterCommon.ets - 章节选择弹窗组件
 * ============================================
 * 
 * 【功能说明】
 * 这是一个章节选择弹窗组件，提供以下功能：
 * - 搜索章节（通过标题关键字查找）
 * - 显示章节列表，支持滚动浏览
 * - 标记"正在阅读"的章节
 * - 单选某个章节进行跳转
 * - 使用主题色定制 UI 样式
 * 
 * 【使用方法】
 * 1. 将该组件嵌入到 CustomDialogController 或 Sheet 中
 * 2. 通过 @Link isShowChapter 控制弹窗显示/隐藏
 * 3. 用户可选择章节后点击"确认"按钮跳转
 * 4. 自动适配系统主题颜色
 * 
 * 【参数说明】
 * @Link isShowChapter: boolean    // 控制弹窗显示状态的双向绑定变量
 * @StorageProp THEME: ThemeItem   // 从存储中获取的主题颜色配置
 * 
 *
 * @author 2008, cyd
 * @datetime 2024/6/9 20:57
 * @version 1.0
 */

import CommonConstants from '../../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../../common/constants/Theme'
import { ThemeItem } from '../../../common/model/Theme'

@Component
export default struct chapterCommon{
  // ============================================
  // 状态变量
  // ============================================
  
  // 控制章节弹窗显示/隐藏的双向绑定变量
  // 父组件修改此值可控制弹窗的开启和关闭
  @Link isShowChapter:boolean
  
  // 主题颜色配置
  // 从 Storage 中读取 THEME 配置项，用于 UI 配色
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  build() {
   Column(){
     // ============================================
     // 上层内容区
     // ============================================
     Column(){
       // 搜索框：搜索章节标题
       Search({placeholder:'搜索章节'})
       
       // 章节列表滚动区域
       Scroll(){
         Column({
           space:12  // 列表项间距
         }){
           // 第一个章节：正在阅读的章节（高亮显示）
           this.chapterTitle(true)
           
           // 第二个章节：已阅读的章节
           this.chapterTitle(false,true)
           
           // 剩余章节列表（未读）
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
           this.chapterTitle()
         }
       }
       .padding({ top:12 })  // 顶部内边距
       .align(Alignment.TopStart)  // 内容靠上左对齐
       .scrollBar(BarState.Off)  // 隐藏滚动条
       .height('80%')  // 占据 80% 高度
     }
     .padding(20)  // 外层内边距

     Divider()  // 分隔线
     
     // ============================================
     // 底部操作按钮区
     // ============================================
     Row({space: 20}) {
       // 取消按钮：关闭弹窗，不进行选择
       Button('取消')
         .padding({left: 32, right: 32, top: 8, bottom: 8})
         .width(150)
         .height(40)
         .borderRadius(200)  // 圆形按钮
         .backgroundColor(this.theme.secondColor)  // 次主题色背景
         .fontColor(this.theme.mainColor)  // 主主题色文字
         .onClick(()=>{
           this.isShowChapter = false  // 关闭弹窗
         })

       // 确认按钮：确认选择的章节并跳转
       Button('确认')
         .padding({left: 32, right: 32, top: 8, bottom: 8})
         .width(150)
         .height(40)
         .borderRadius(200)  // 圆形按钮
         .backgroundColor(this.theme.mainColor)  // 主主题色背景
         .fontColor($r('sys.color.comp_background_list_card'))  // 系统预设文字颜色

     }
     .padding({top: 12, bottom: 12})
     .justifyContent(FlexAlign.Center)  // 按钮居中排列
     .width(CommonConstants.FULL_WIDTH)  // 占满全宽
     .height(64)
   }
  }

  /**
   * 构建单个章节条目
   * @param showRead - 是否显示"正在阅读"标识（true=正在阅读）
   * @param checkRead - 是否为已选中的章节（用于单选按钮选中状态）
   */
  @Builder chapterTitle(showRead:boolean = false,checkRead:boolean=false){
    Flex({
      justifyContent:FlexAlign.SpaceBetween,  // 两端对齐
      alignItems:ItemAlign.Center            // 垂直居中对齐
    }){
      // 章节标题文本
      // 如果是"正在阅读"则用灰色，否则用黑色
      Text(`${!showRead?'标题':'正在阅读'}: 第一章 牢狱之灾`)
        .fontSize(14)
        .fontWeight(400)
        .fontColor(!showRead?$r('app.string.color_black_88'):$r('app.string.color_black_45'))
      
      if (!showRead){
        // 非"正在阅读"时显示单选按钮
        Radio({value:'第一章',group:'radioGroup'})
          .checked(checkRead)  // 选中状态
          .radioStyle({
            checkedBackgroundColor: this.theme.mainColor  // 选中时为主题色
          })
          .border({width:2,color:'rgba(255, 255, 255, 0.10)'})
          .width(24)
          .height(24)
      } else {
        // "正在阅读"时用空白占位保持布局一致
        Text().height(24)
      }
    }
  }
}

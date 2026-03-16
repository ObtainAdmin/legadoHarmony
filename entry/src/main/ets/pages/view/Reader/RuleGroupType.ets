/**
 * ============================================
 * RuleGroupType.ets - 规则类型分组选择组件
 * ============================================
 * 
 * 【功能说明】
 * 这是一个规则类型分组选择器，用于筛选和分类阅读规则：
 * - 显示水平滚动的规则类型标签列表
 * - 支持选择"全部"或特定类型的规则
 * - 点击展开按钮可进入全屏规则分组面板
 * - 包含 7 种规则类型：全部、标题、标点、去广告、排版、格式、未分组
 * 
 * 【使用方法】
 * 1. 水平滑动浏览不同类型的规则标签
 * 2. 点击标签切换当前选中的规则类型
 * 3. 点击右侧"更多"按钮展开完整规则面板
 * 4. 通过 coverShow 控制是否显示覆盖层
 * 
 * 【参数说明】
 * @State globalPositionY: Length     // 全局 Y 轴位置（预留字段）
 * @Link coverShow: boolean           // 控制覆盖层显示的双向绑定变量
 * @State ruleType: string            // 当前选中的规则类型（默认'全部'）
 * @State ruleList: Array<string>    // 规则类型列表
 * 
 * 【规则类型列表】
 * ['全部', '标题', '标点', '去广告', '排版', '格式', '未分组']
 * 
 *
 * @author cyd
 * @version 1.0
 */

import BookType from '../../../componets/head/BookType'
import RuleGroupTypePanel from './RuleGroupTypePanel'

@Component
export default struct RuleGroupType {
  // ============================================
  // 状态变量
  // ============================================
  
  // 全局 Y 轴位置（预留字段，可用于定位相关元素）
  @State globalPositionY: Length = 0
  
  // 覆盖层显示状态
  // true = 显示全屏规则面板，false = 显示水平滚动标签
  // 与父组件双向绑定，外部可控
  @Link coverShow:boolean
  
  // 当前选中的规则类型
  // 点击标签时会更新此值，用于过滤显示的规则
  @State ruleType:string = '全部'
  
  // 规则类型列表
  // 定义了所有可用的规则分类选项
  @State ruleList:Array<string> = [
    '全部',       // 显示所有规则
    '标题',       // 仅显示标题相关规则
    '标点',       // 仅显示标点符号规则
    '去广告',     // 仅显示去广告规则
    '排版',       // 仅显示排版调整规则
    '格式',       // 仅显示格式转换规则
    '未分组'      // 显示未归类的规则
  ]

  build() {
    // 根据 coverShow 状态决定显示模式
    if (this.coverShow){
      // ============================================
      // 覆盖层模式：显示全屏规则面板
      // ============================================
      Stack(){
        // 规则分组面板（置顶显示）
        RuleGroupTypePanel({
          groupCoverShow:this.coverShow,  // 传递覆盖层状态
          ruleList:this.ruleList          // 传递规则类型列表
        }).zIndex(9999)  // 设置高 z-index 确保在最上层
        
        // 半透明遮罩层
        Rect()
          // .fillOpacity(0)  // 可选：完全透明
          .height('90%')    // 占据 90% 高度
          .width('100%')    // 占满全宽
          .fill('rgba(0, 0, 0, 0.45)')  // 深灰色半透明背景
          .offset({y:10})   // 向下偏移 10vp
      }.alignContent(Alignment.TopStart)  // 内容对齐到左上角
      
    } else {
      // ============================================
      // 普通模式：显示水平滚动标签栏
      // ============================================
      Flex(
        {
          alignItems: ItemAlign.Center,       // 垂直居中对齐
          justifyContent: FlexAlign.SpaceBetween // 两端对齐
        }
      ) {
        // 水平滚动区域：包含所有规则类型标签
        Scroll() {
          Row({ space: 10 }) {  // 标签间距 10vp
            ForEach(this.ruleList, (item:string)=>{
              // 渲染每个规则类型标签
              BookType({ 
                title: item,        // 标签文字
                bookType: this.ruleType  // 当前选中类型（用于高亮）
              }).onClick(() => {
                // 点击标签时更新当前选中的规则类型
                this.ruleType = item
              })
            })
          }
        }
        .scrollBar(BarState.Off)  // 隐藏滚动条
        .scrollable(ScrollDirection.Horizontal)  // 启用水平滚动
        
        // 更多搜索按钮（展开全屏面板）
        Row(){
          Image($r('app.media.more_search'))  // 更多搜索图标
            .width(25).height(25)
        }
        .width('10%')  // 占据 10% 宽度
        .onClick(()=>{
          this.coverShow = true  // 点击展开覆盖层
        })
      }
      .margin({ left: 20, right:20, bottom:10 })  // 外边距
    }
  }
}

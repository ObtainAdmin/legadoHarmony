/**
 * ============================================
 * purificationView.ets - 内容净化设置面板组件
 * ============================================
 * 
 * 【功能说明】
 * 这是一个内容净化功能控制面板，提供以下净化选项：
 * - 替换净化：使用规则替换指定内容
 * - 移除重复标题：删除文档中的重复章节标题
 * - 重新分段：优化段落划分
 * - 反转内容：反转文本顺序（特殊用途）
 * - 编辑内容：手动编辑净化后的内容
 * - 净化规则管理：进入规则管理界面
 * 
 * 【使用方法】
 * 1. 通过 @Link isShowPurification 控制面板显示/隐藏
 * 2. 点击各选项后的开关启用/禁用对应功能
 * 3. 点击"净化规则管理"可进入详细规则配置
 * 4. 点击底部"取消"关闭面板
 * 
 * 【参数说明】
 * @Link isShowPurification: boolean    // 控制面板显示状态的双向绑定变量
 * @State isRule: boolean               // 规则模式标识（预留扩展）
 * ruleViewDialog                      // 规则视图弹窗控制器
 * 
 *
 * @author 2008, cyd
 * @datetime 2024/6/12 21:48
 * @version 1.0
 */

import ruleView from './ruleView';

@Component
export default struct purificationView{
  // ============================================
  // 状态变量
  // ============================================
  
  // 控制净化面板显示/隐藏的双向绑定变量
  // 父组件修改此值可控制面板的开启和关闭
  @Link isShowPurification: boolean;
  
  // 规则模式标识（预留字段，待扩展使用）
  @State isRule: boolean = false;
  
  // ============================================
  // 规则视图弹窗控制器
  // ============================================
  ruleViewDialog: CustomDialogController | null = new CustomDialogController({
    builder: ruleView(),                 // 使用 ruleView 组件作为弹窗内容
    cancel: this.clickExitDialog,        // 取消回调
    autoCancel: true,                    // 点击外部自动关闭
    alignment: DialogAlignment.Top,      // 弹窗对齐方式（顶部）
    customStyle:true                     // 启用自定义样式
  })
  
  /**
   * 关闭规则视图弹窗
   */
  clickExitDialog(){
    this.ruleViewDialog?.close()
  }

  build() {
    Column(){
      // ============================================
      // 净化功能列表区
      // ============================================
      Column({ space:12 }) {  // 列表项间距 12vp
        // 替换净化功能（带开关）
        this.titleContent('替换净化')
        
        // 移除重复标题功能（带开关）
        this.titleContent('移除重复标题')
        
        // 重新分段功能（带开关）
        this.titleContent('重新分段')
        
        // 反转内容功能（带开关）
        this.titleContent('反转内容')
        
        // 编辑内容功能（带箭头，点击进入下一级）
        this.titleContent('编辑内容',true)
        
        // 净化规则管理入口（点击打开规则视图弹窗）
        Column(){
          this.titleContent('净化规则管理',true)  // true 表示显示箭头而非开关
        }.onClick(()=>{
          this.ruleViewDialog?.open()  // 打开规则管理弹窗
        })
      }.padding({ top:16, left:20, right:20, bottom:16 })
      
      Divider()  // 分隔线
      
      // ============================================
      // 底部操作区
      // ============================================
      Column({ space:12 }) {
        // 取消按钮文字
       Text('取消')
         .fontSize(16)
         .fontWeight(400)
         .fontColor($r('app.string.color_black_88'))

      }
      .onClick(()=>{
        this.isShowPurification = false  // 关闭净化面板
      })
      .padding({ top:16, left:20, right:20, bottom:16 })
    }
  }

  /**
   * 构建功能条目
   * @param title - 功能名称文本
   * @param isToggle - 是否显示箭头图标（true=箭头，false=开关）
   */
  @Builder titleContent(title:string,isToggle:boolean = false){
    Flex({
      justifyContent:FlexAlign.SpaceBetween,  // 两端对齐
      alignItems:ItemAlign.Center            // 垂直居中对齐
    }){
      // 功能名称
      Text(title)
        .fontSize(14)
        .fontWeight(400)
        .fontColor($r('app.string.color_black_88'))
      
      if (!isToggle){
        // 非跳转项：显示开关控件
        Toggle({ type: ToggleType.Switch, isOn: false})
          .selectedColor("#F60")  // 选中时橙色
          .hoverEffect(HoverEffect.None)  // 禁用悬停效果
      } else {
        // 跳转项：显示右箭头图标
        Image($r('app.media.icon_right'))
          .width(25).height(25)
      }

    }
  }
}

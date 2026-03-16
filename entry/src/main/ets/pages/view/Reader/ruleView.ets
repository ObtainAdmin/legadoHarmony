/**
 * ============================================
 * ruleView.ets - 规则管理视图组件
 * ============================================
 * 
 * 【功能说明】
 * 这是一个综合性的规则管理界面，提供以下核心功能：
 * - 替换净化规则管理：管理文本替换和净化规则
 * - 目录净化规则管理：管理章节目录的净化规则
 * - 批量操作：全选/取消选择、禁用、导出、删除规则
 * - 规则导入导出：支持从剪贴板或本地文件导入规则
 * - 规则分组管理：按类型分类规则（标题、标点、去广告等）
 * - 拖拽排序：可重新排列规则顺序
 * 
 * 【使用方法】
 * 1. 顶部切换标签页：替换净化 / 目录净化
 * 2. 点击"+"按钮打开更多菜单（新建、导入、批量管理等）
 * 3. 每个规则项可通过开关启用/禁用
 * 4. 勾选复选框选中多个规则进行批量操作
 * 5. 底部操作栏执行置顶、禁用、导出、删除等操作
 * 
 * 【参数说明】
 * @StorageLink topRectHeight/bottomRectHeight   // 系统区域高度适配
 * @State ruleTitle                              // 标签页标题数组
 * @State ruleType                               // 当前选中的规则类型
 * @State ruleArray                              // 规则列表数据
 * @State checkedRuleList                        // 已选中的规则列表
 * @StorageProp THEME                            // 主题颜色配置
 * 
 *
 * @author 2008, cyd
 * @datetime 2024/6/15 20:00
 * @version 1.0
 */

import CommonConstants from '../../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../../common/constants/Theme'
import { ThemeItem } from '../../../common/model/Theme'
import buttonCommon from '../../../componets/common/buttonCommon'
import InsideCircleIcon from '../../../componets/common/InsideCircleIcon'
import operateIcon from '../../../componets/common/operateIcon'
import { showMessage } from '../../../componets/common/promptShow'
import { buttonList } from '../../../componets/dataList/buttonList'
import exportRuleDialog from '../../../componets/Reader/exportRuleDialog'
import directoryPurification from './directoryPurification'
import newAddRule from './newAddRule'
import RuleGroupType from './RuleGroupType'

@Preview
@CustomDialog
@Component
export default struct ruleView{
  // ============================================
  // 状态变量
  // ============================================
  
  // 顶部系统区域高度（刘海屏/折叠屏适配）
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  // 底部系统区域高度（刘海屏/折叠屏适配）
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  // 规则类型标签标题数组
  // [0] = 替换净化, [1] = 目录净化
  @State ruleTitle:Array<string> = ['替换净化','目录净化']
  
  // 当前选中的规则类型
  @State ruleType:string = '替换净化'
  
  // 覆盖层显示状态（规则分组面板）
  @State coverShow:boolean = false
  
  // 新增替换规则弹窗显示状态
  @State newReplacementRule:boolean = false
  
  // 规则名称列表（模拟数据，实际应从存储加载）
  @State ruleArray:Array<string> =
    ['一个目录 (标题)','书名净化标题 (标题)','JS 标题 (标题)','章节名称规整 (标题)','序号加括号 (标题)',
      '章节名重复① (标题)','章节名重复② (标题)','章节符号净化 (标题)','第 XXX 章 XXX(规范章节)(标题)',
    '中文标题转数字 (可选)(标题)','中文标题转数字 (可选)(标题)1','中文标题转数字 (可选)(标题)2','中文标题转数字 (可选)(标题)3',
      '中文标题转数字 (可选)(标题)4','中文标题转数字 (可选)(标题)5','中文标题转数字 (可选)(标题)6','中文标题转数字 (可选)(标题)7']
  
  // 规则选择状态标识
  @State isRuleCheck:boolean = false
  
  // 自定义对话框控制器（预留）
  controller?: CustomDialogController
  
  // Tab 页签控制器
  tabsController: TabsController = new TabsController();
  
  // 全选复选框状态
  @State checkRule:boolean = false
  
  // 已选中的规则列表
  // 用于批量操作时确定目标规则
  @State checkedRuleList:Array<string> = [] 
  
  /**
   * 更新已选中规则列表
   * @param title - 规则标题
   * @param checkRule - true=选中，false=取消选中
   */
  checkedRuleListPush(title:string,checkRule:boolean){
    // checkRule 为 false 时从 checkedRuleList 中移除 title
    // checkRule 为 true 时将 title 添加到 checkedRuleList，先校验是否存在
    if (checkRule){
      if (this.checkedRuleList.includes(title)){
        return  // 已存在则不重复添加
      }
      this.checkedRuleList.push(title)
    }else{
      // 过滤掉要删除的元素
      this.checkedRuleList = this.checkedRuleList.filter(item => item !== title)
    }
    // 更新已选数量
    this.ruleNumber = this.checkedRuleList.length
  }
  
  // 主题颜色配置
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  build() {
    Flex({ direction:FlexDirection.Column }) {
      // ============================================
      // 标题栏
      // ============================================
      Flex({
        alignItems:ItemAlign.Center,
        justifyContent:FlexAlign.SpaceBetween
      }){
        // 返回按钮
        Image($r('app.media.return_left'))
          .width(24).height(24)
          .fillColor('rgba(0, 0, 0, 0.88)')
          .onClick(()=>{
            this.controller?.close()  // 关闭当前视图
          })
        
        // 中间：标签页切换
        Row({ space:16 }) {
          ForEach(this.ruleTitle, (item:string,index:number)=>{
            Column(){
              // 标签文字：选中时用主题色加粗，未选中用灰色
              Text(item)
                .font({ size:16, weight:this.ruleType === item?500:400 })
                .textAlign(TextAlign.Center)
                .lineHeight(24)
                .fontColor(this.ruleType === item?this.theme.mainColor:$r('app.string.color_black_45'))
              
              // 选中指示器（底部横线）
              Row()
                .width(10).height(3)
                .backgroundColor(this.theme.mainColor)
                .borderRadius(8)
                .offset({y:5})
                .visibility(this.ruleType === item?Visibility.Visible:Visibility.None)
                .opacity(this.ruleType === item?1:0)
                .scale({
                  centerX: "50%", centerY: "50%",
                  x: this.ruleType === item ? 1 : 0,
                  y: this.ruleType === item ? 1 : 0,
                })
                .animation({ duration: 600, curve: CommonConstants.UniCurve })
            }.onClick(()=>{
              this.ruleType = item  // 更新选中类型
              this.tabsController.changeIndex(index)  // 切换 Tab 页
            })
          })
        }
        
        // 右侧：添加按钮（带菜单）
        Image($r('app.media.addSubscription'))
          .width(24)
          .bindMenu(this.MenuBuilder)
      }.margin({ top:6,bottom:6,right:20,left:20 })
      .animationIsBatchF()
      
      // 头部标题区
      Column(){
        this.headTitle()
      }
      .padding({right:20,left:20})
      .animationIsBatchT()

      // 搜索框
      Search({ placeholder:'搜索' })
        .margin({ top:8,bottom:8, right:20,left:20 })
        .animationIsBatchF()
      
      Stack(){
        // 规则分组面板（仅替换净化模式显示）
        if (this.ruleType === '替换净化'){
          RuleGroupType({ coverShow:this.coverShow })
            .visibility(!this.isBatch?Visibility.Visible:Visibility.None)
            .opacity(!this.isBatch?1:0)
            .scale({
              centerX: "50%", centerY: "50%",
              x: !this.isBatch ? 1 : 0, y: !this.isBatch ? 1 : 0,
            })
            .animation({ duration: 600, curve: CommonConstants.UniCurve })
            .zIndex(9999)
            .backgroundColor(!this.coverShow?Color.White:'')
        }

        // Tab 页签容器
        Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
          TabContent(){ this.ruleBuilder() }  // 替换净化页面
          TabContent(){ this.ruleBuilder() }  // 目录净化页面
        }
        .barWidth(0)  // 隐藏默认指示条
        .barHeight(0)
        .onChange((index) => {
          this.tabsController.changeIndex(index)
          this.ruleType = index === 0 ? this.ruleTitle[0] : this.ruleTitle[1]
        })
      }
      .alignContent(Alignment.Top)
      
      // 底部操作栏
      Column(){
        this.operateListBuilder()
      }
      .animationIsBatchT()
      
      // 替换净化弹窗
      Flex().bindSheet($$this.newReplacementRule, this.newAddRule(), {
        height: '95%', showClose: false, dragBar: true, backgroundColor:Color.White,
        onDisappear: () => {}
      })
      
      // 目录净化弹窗
      Flex().bindSheet($$this.purification, this.directoryPurification(), {
        height: '95%', showClose: false, dragBar: true, backgroundColor:Color.White,
        onDisappear: () => {}
      })

    }
    .bindSheet($$this.isRuleChange, this.menuBuilder(), {
      height: '95%', showClose: false, dragBar: true, backgroundColor:Color.White,
      onDisappear: () => {}
    })
    .backgroundColor(Color.White)
    .padding({ top:this.topRectHeight, bottom:this.bottomRectHeight })
  }
  
  // 已选规则数量
  @State ruleNumber:number = 0
  
  // 所有规则总数
  @State ruleAll:number = this.ruleArray.length
  
  /**
   * 批量管理菜单
   * 包含全选/取消选择、确认操作
   */
  @Builder menuBuilder() {
    Column(){
      // 拖动手柄
      Column() {
        Row().width(36).height(4).backgroundColor($r('app.string.color_black_15')).borderRadius(12)
      }
      .padding({ top: 12,bottom:12 })
      
      // 规则列表预览
      Column(){ this.ruleBuilder(true) }
      .height('83%')
      
      // 底部操作区
      Column(){
        Row(){
          // 全选复选框
          Checkbox()
            .selectedColor(this.theme.mainColor)
            .margin({right:8})
            .select(this.checkRule)
            .onChange(()=>{
              this.checkRule = !this.checkRule
            })
          
          // 全选/取消全英文本
          Text(this.ruleNumber!==this.ruleAll?
            $r('app.string.select_all') : $r('app.string.deselect_all'))
            .fontColor($r('app.string.color_black_88'))
            .font({ size:16, weight:400 })
            .lineHeight(24)
            .margin({right:8})
          
          // 选中数量显示
          Text('(')
            .fontColor($r('app.string.color_black_88'))
            .font({ size:16, weight:400 })
            .lineHeight(24)
          Text(`${this.ruleNumber}`)
            .fontColor(this.theme.mainColor)
            .font({ size:16, weight:400 })
            .lineHeight(24)
          Text(`/${this.ruleAll})`)
            .fontColor($r('app.string.color_black_88'))
            .font({ size:16, weight:400 })
            .lineHeight(24)
        }
        .alignItems(VerticalAlign.Center)
        .padding({left:20})
        
        // 通用按钮组件
        buttonCommon({
          cancel:()=>{ this.isRuleChange = false },
          confirm:()=>{ showMessage('test111') }
        })
        .padding({bottom:12})
      }.alignItems(HorizontalAlign.Start)
    }
  }

  /**
   * 规则列表构建器
   * @param isTop - 是否为首项（控制内边距）
   */
  @Builder ruleBuilder(isTop:boolean = false){
    Flex({
      direction: FlexDirection.Column, wrap: FlexWrap.Wrap,
      alignItems:ItemAlign.Center
    }){
      Scroll(){
        Column({ space:12 }){
          ForEach(this.ruleArray,(item:string)=>{
            if (this.ruleType === this.ruleTitle[0]){
              this.ruleReplaceTitle(item,isTop)  // 替换净化规则样式
            } else {
              this.ruleDirectoryTitle(item,isTop)  // 目录净化规则样式
            }
          })
        }
        .padding({top:12,left:20,right:20,bottom:5})
      }
      .padding({top:!isTop?this.ruleType === this.ruleTitle[0]?this.isBatch?0:30:0:0})
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
  }

  // 单条规则启用状态
  @State isRule:boolean = false
  
  // 批量模式开关
  @State isBatch:boolean = false
  
  /**
   * 替换净化规则条目样式
   * @param title - 规则名称
   * @param isShowCheck - 是否显示复选框（批量模式下）
   */
  @Builder ruleReplaceTitle(title:string,isShowCheck:boolean = false){
    Flex({
      justifyContent:FlexAlign.SpaceBetween,
      alignItems:ItemAlign.Center
    }){
      // 规则名称
      Text(`${title}`).fontSize(14).fontWeight(400).fontColor($r('app.string.color_black_88'))
      
      Row({ space:6 }) {
        if (!isShowCheck){
          // 非批量模式：显示开关、更多菜单、复选框
          Toggle({ type: ToggleType.Switch, isOn: $$this.isRule})
            .selectedColor("#F60").hoverEffect(HoverEffect.None)
            .onChange(()=>{})
          
          // 更多翻译菜单
          Image($r('app.media.more_translate'))
            .width(24).height(24)
            .bindMenu(this.moreTranslate(),{ borderRadius:12 })
            .animationIsBatchF()
          
          // 单选复选框
          Checkbox()
            .selectedColor(this.theme.mainColor)
            .select(this.isRuleCheck)
            .onChange((value:boolean)=>{
              this.checkedRuleListPush(title,value)
            })
            .width(20).height(20)
            .animationIsBatchT()
        } else {
          // 批量模式：显示"新增"文字和复选框
          Text('新增')
            .font({ size:12, weight:400 })
            .fontColor($r('app.string.color_black_45'))
          
          Checkbox({ name: title })
            .selectedColor(this.theme.mainColor)
            .select(this.checkRule)
            .onChange((value:boolean)=>{
              this.checkedRuleListPush(title,value)
            })
        }
      }
    }
    .padding({left:16,right:16,top:12,bottom:12})
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.20)' })  // 阴影效果
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  /**
   * 目录净化规则条目样式
   * @param title - 规则名称
   * @param isShowCheck - 是否显示复选框（批量模式下）
   */
  @Builder ruleDirectoryTitle(title:string,isShowCheck:boolean = false){
    Column({ space:5 }) {
      Flex({
        justifyContent:FlexAlign.SpaceBetween,
        alignItems:ItemAlign.Center
      }){
        Text(`${title}`).fontSize(14).fontWeight(400).fontColor($r('app.string.color_black_88'))
        
        Row({ space:6 }) {
          if (!isShowCheck){
            Toggle({ type: ToggleType.Switch, isOn: $$this.isRule})
              .selectedColor("#F60").hoverEffect(HoverEffect.None)
            Image($r('app.media.more_translate'))
              .width(24).height(24)
              .bindMenu(this.moreTranslate(),{ borderRadius:12 })
              .animationIsBatchF()
            Checkbox()
              .selectedColor(this.theme.mainColor)
              .select(this.isRuleCheck)
              .onChange((value:boolean)=>{
                this.checkedRuleListPush(title,value)
              })
              .width(20).height(20)
              .animationIsBatchT()
          } else {
            Text('新增').font({ size:12, weight:400 }).fontColor($r('app.string.color_black_45'))
            Checkbox({ name: title })
              .select(this.checkRule)
              .onChange((value:boolean)=>{
                this.checkedRuleListPush(title,value)
              })
              .selectedColor(this.theme.mainColor)
          }
        }
      }
      // 描述文本（次级信息）
      Text(`${title}`).fontSize(12).fontWeight(400).fontColor($r('app.string.color_black_45'))
    }
    .alignItems(HorizontalAlign.Start)
    .padding({left:16,right:16,top:12,bottom:12})
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.20)' })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  // 主菜单选项列表
  MoreList: string[] = ['新建替换', '粘贴导入', '本地导入','批量管理','帮助']
  moreIcon: Resource[] = [$r('app.media.icon_rule_add'),$r('app.media.icon_rule_paste'),$r('app.media.icon_rule_export'),$r('app.media.icon_rule_batch'),$r('app.media.icon_rule_help')]
  
  // 规则变更菜单显示状态
  @State isRuleChange:boolean = false
  
  /**
   * 主菜单构建器
   * 点击"+"按钮时弹出
   */
  @Builder MenuBuilder() {
    Flex({ direction: FlexDirection.Column}) {
      ForEach(this.MoreList, (item: String, index) => {
        Column() {
          Row() {
            Image(this.moreIcon[index])
              .width(20).height(20)
              .margin({ right: 8 })
              .fillColor($r('app.string.color_black_88'))
            Text(`${item}`).fontSize(14)
          }
          .height(40)
          .onClick(()=>{ this.ruleDialog(index) })  // 调用对应功能
          Divider()
        }
        .alignItems(HorizontalAlign.Start)
        .padding(5)
        .height(40)
        .margin({ bottom: 20 })
      })
    }
    .width(100)
  }
  
  // 编辑模式标识
  @State isEdit:boolean = false
  
  @Builder newAddRule(){
    Column(){
      newAddRule({
        cancel:() =>{ this.newReplacementRule = false },
        isEdit:this.isEdit
      })
    }
  }
  
  @State purification:boolean = false
  
  @Builder directoryPurification(){
    Column(){
      directoryPurification({
        cancel:() =>{ this.purification = false },
        isEdit:this.isEdit
      })
    }
  }

  // 更多菜单选项（单个规则的操作）
  @State moreTranslateMenu:buttonList[] = [
    new buttonList(0,'编辑',$r('app.media.icon_operate_top')),
    new buttonList(1,'置顶',$r('app.media.icon_operate_export')),
    new buttonList(2,'移动至',$r('app.media.icon_operate_move')),
    new buttonList(3,'删除',$r('app.media.delete_svg'))
  ]
  
  @Builder moreTranslate(){
    Flex({ direction:FlexDirection.Column }) {
      ForEach(this.moreTranslateMenu, (item: buttonList, index) => {
        // 目录净化模式下隐藏"移动至"选项
        if (!(this.ruleType === this.ruleTitle[1] && index === 2)){
         Column(){
           Row(){
             Image(item.icon)
               .width(20).height(20)
               .margin({ right: 8 })
               .fillColor($r('app.string.color_black_88'))
             Text(`${item.title}`).fontSize(14)
           }.onClick(()=>{ this.moreTranslateFunction(index) })
           .padding({left:5,top:12,bottom:12})
           Divider()
         }
         .alignItems(HorizontalAlign.Start)
         .padding(5)
        }
      })
    }.width(100)
  }

  /**
   * 主菜单选项处理
   * @param index - 菜单项索引
   */
  ruleDialog(index:number){
    switch (index){
      case 0:  // 新建规则
        if (this.ruleType === this.ruleTitle[0]) {
          this.newReplacementRule = true; this.isEdit = false; break;  // 替换净化
        } else {
          this.purification = true; this.isEdit = false; break;  // 目录净化
        }
      case 1:  // 粘贴导入
        this.isRuleChange = true; break;
      case 3:  // 批量管理
        this.isBatch = !this.isBatch; break;
    }
  }

  /**
   * 单个规则更多菜单处理
   * @param index - 菜单项索引
   */
  moreTranslateFunction(index:number){
    switch (index){
      case 0:  // 编辑
        if (this.ruleType === this.ruleTitle[0]) {
          this.newReplacementRule = true; this.isEdit = true; break;
        } else {
          this.purification = true; this.isEdit = true; break;
        }
    }
  }

  /**
   * 头部标题构建器
   * 显示全选/取消选择和已选数量
   */
  @Builder headTitle(){
    Flex({ alignItems:ItemAlign.Center }) {
      Column(){
        Text(this.checkedRuleList.length === this.ruleArray.length?'取消选择':'全选')
          .fontSize(16)
          .onClick(()=>{ this.isRuleCheck = !this.isRuleCheck })
      }
      .alignItems(HorizontalAlign.Start)
      .width('33%')
      
      Column(){
        Text(`已选${this.checkedRuleList.length}项目`)
          .fontSize(20).fontWeight(600)
      }.width('33%')
      
      Column(){
        Text('完成')
          .fontSize(16)
          .onClick(()=>{
            this.isBatch = false
            this.checkedRuleList = []
            this.isRuleCheck = false
          })
      }
      .alignItems(HorizontalAlign.End)
      .width('33%')
    }
    .padding(10)
  }

  // 批量模式可见动画样式
  @Styles animationIsBatchF() {
    .visibility(!this.isBatch?Visibility.Visible:Visibility.None)
    .opacity(!this.isBatch?1:0)
    .scale({ centerX: "50%", centerY: "50%", x: !this.isBatch ? 1 : 0, y: !this.isBatch ? 1 : 0 })
    .animation({ duration: 600, curve: CommonConstants.UniCurve })
  }

  // 非批量模式可见动画样式
  @Styles animationIsBatchT() {
    .visibility(this.isBatch?Visibility.Visible:Visibility.None)
    .opacity(this.isBatch?1:0)
    .scale({ centerX: "50%", centerY: "50%", x: this.isBatch ? 1 : 0, y: this.isBatch ? 1 : 0 })
    .animation({ duration: 600, curve: CommonConstants.UniCurve })
  }

  // 底部操作栏按钮列表
  @State operateList:buttonList[] = [
    new buttonList(1,'置顶',$r('app.media.icon_operate_top')),
    new buttonList(2,'禁用',$r('app.media.icon_operate_export')),
    new buttonList(3,'导出',$r('app.media.icon_operate_export')),
    new buttonList(4,'移动至',$r('app.media.icon_operate_move')),
    new buttonList(5,'删除',$r('app.media.delete_svg'))
  ]
  
  @State operateDisable:boolean = false
  
  /**
   * 底部操作栏构建器
   * 根据规则类型调整列数（目录净化 4 列，替换净化 5 列）
   */
  @Builder operateListBuilder() {
    GridRow({ columns:this.ruleType === this.ruleTitle[1]?4:5 }) {
      ForEach(this.operateList,(item:buttonList)=>{
        // 目录净化模式下隐藏"移动至"选项
        if (!(this.ruleType === this.ruleTitle[1] && item.id === 4)) {
          GridCol(){
            if (item.id === 2) {
              // "禁用"按钮特殊处理：使用 Toggle 开关
              Column(){
                Toggle({ type: ToggleType.Switch, isOn: $$this.operateDisable})
                  .selectedColor(this.theme.mainColor).hoverEffect(HoverEffect.None)
                  .onChange(()=>{
                    if (this.checkedRuleList.length === 0) {
                      showMessage('请选择要禁用的内容')
                      this.operateDisable = false
                      return
                    }
                  })
                Text(item.title)
                  .fontColor($r('app.string.color_black_88'))
                  .fontSize(12).fontWeight(400).lineHeight(20)
              }.padding({ top:12,bottom:12 })
            } else {
              // 其他操作按钮
              operateIcon({ item:item })
                .onClick(()=>{ this.operateFunction(item.id) })
            }
          }
        }
      })
    }
  }
  
  /**
   * 操作栏按钮功能处理
   * @param index - 按钮 ID
   */
  operateFunction(index:number){
    switch (index){
      case 3:  // 导出
       this.operateExport();break;
    }
  }

  /**
   * 导出规则
   */
  operateExport(){
    this.exportRuleDialogController?.open()
    showMessage('导出');
  }

  // 导出规则弹窗控制器
  exportRuleDialogController: CustomDialogController | null = new CustomDialogController({
    builder: exportRuleDialog(),
    backgroundColor: Color.Transparent,
    autoCancel: false,
    alignment: DialogAlignment.Center,
    gridCount: 4,
    customStyle: false,
    cornerRadius: 16,
  })
}

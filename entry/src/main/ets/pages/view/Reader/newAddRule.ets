/**
 * ============================================
 * newAddRule.ets - 新建/编辑替换规则弹窗组件
 * ============================================
 * 
 * 【功能说明】
 * 这是一个用于创建或编辑文本替换规则的弹窗组件，提供：
 * - 新增/编辑替换规则（如去除广告、格式调整等）
 * - 规则名称和分组管理
 * - 支持正则表达式模式
 * - 定义替换对象和替换结果
 * - 指定替换范围（标题/正文）
 * - 设置超时时间
 * - 使用主题色适配 UI 样式
 * 
 * 【使用方法】
 * 1. 将本组件嵌入到 CustomDialogController 中
 * 2. 通过 isEdit 参数控制是"新增"还是"编辑"模式
 * 3. 填写各项规则信息后点击确认保存
 * 4. cancel 回调用于处理取消操作
 * 
 * 【参数说明】
 * @State changeRule: boolean        // 是否启用正则表达式模式
 * @State grouping: string           // 规则所属分组（默认'未分组'）
 * @State isShown: boolean           // 下拉菜单显示状态
 * @Prop isEdit: boolean             // 编辑模式标识
 * cancel: () => void               // 取消操作的回调函数
 * @StorageProp THEME: ThemeItem    // 主题颜色配置
 * 
 * 【字段说明】
 * - 名称：替换规则的显示名称（必填）
 * - 分组：规则所属分类（未分组/标题/标点/去广告/排版/格式）
 * - 替换对象：要匹配的正则表达式或文本（必填）
 * - 替换为：替换后的结果文本（必填）
 * - 替换范围：作用于标题或正文
 * - 超时毫秒数：规则执行超时时间（默认 3000ms）
 * 
 *
 * @author 2008, cyd
 * @datetime 2024/6/23 22:51
 * @version 1.0
 */

import CommonConstants from '../../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../../common/constants/Theme'
import { ThemeItem } from '../../../common/model/Theme'
import buttonCommon from '../../../componets/common/buttonCommon'
import { showMessage } from '../../../componets/common/promptShow'

@Component
@Preview
export default struct newAddRule{
  // ============================================
  // 状态变量
  // ============================================
  
  // 是否启用正则表达式模式
  // true = 使用正则表达式，false = 普通文本匹配
  @State changeRule:boolean = false
  
  // 当前选择的规则分组
  // 可选值：['未分组', '标题', '标点', '去广告', '排版', '格式']
  @State grouping:string = '未分组'
  
  // 分组下拉菜单显示状态
  @State isShown: boolean = false
  
  // 编辑模式标识
  // true = 编辑已有规则，false = 新增规则
  @Prop isEdit:boolean = false
  
  // 取消操作回调函数
  cancel: () => void = () => {
  }
  
  // 主题颜色配置
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  build() {
    Flex({
      direction:FlexDirection.Column,      // 垂直布局
      justifyContent:FlexAlign.SpaceBetween // 两端对齐
    }){
      // ============================================
      // 上层：表单内容区
      // ============================================
      Column(){
        // 标题栏
        Flex({
          justifyContent:FlexAlign.SpaceBetween
        }){
          // 标题文本：根据模式显示不同文案
          Text(this.isEdit?
            $r('app.string.edit_replacement_rule') :   // "编辑替换规则"
            $r('app.string.new_replacement_rule'))     // "新建替换规则"
            .font({
              size:18,
              weight:500,
              family:CommonConstants.FAMILY_PingFANG
            })
          
          // 右上角操作按钮区
          Row({ space:20 }) {
            // 复制规则按钮
            this.titleRule($r('app.media.ic_public_copy'),$r('app.string.copy'))
            
            // 粘贴规则按钮
            this.titleRule($r('app.media.icon_rule_paste'),$r('app.string.paste'))
          }
        }.padding({ top:28, left:20, right:20, bottom:12 })
        
        // ============================================
        // 表单输入区（可滚动）
        // ============================================
        Scroll(){
          Column(){
            // -----------------------------------------
            // 名称输入框（必填项）
            // -----------------------------------------
            Column({ space:8 }) {
              Row(){
                Text($r('app.string.appellation')  // "名称"
                  )
                  .textAlign(TextAlign.Start)
                  .fontColor($r('app.string.color_black_88'))
                  .font({ size:16, weight:500, family:CommonConstants.FAMILY_PingFANG })
                  .lineHeight(24)
                
                Text('*')  // 必填标识
                  .fontColor(this.theme.mainColor)
                  .font({ size:16, weight:500, family:CommonConstants.FAMILY_PingFANG })
                  .lineHeight(24)
              }
              
              TextInput({
                placeholder:$r('app.string.please_enter_name')  // "请输入名称"
              }).borderRadius(0)
            }
            .padding({top:12,bottom:12})
            .alignItems(HorizontalAlign.Start)
            
            // -----------------------------------------
            // 分组选择器
            // -----------------------------------------
            Column({ space:8 }) {
              Row(){
                Text($r('app.string.grouping')  // "分组"
                  )
                  .textAlign(TextAlign.Start)
                  .fontColor($r('app.string.color_black_88'))
                  .font({ size:16, weight:500, family:CommonConstants.FAMILY_PingFANG })
                  .lineHeight(24)
                
                Text('*')  // 必填标识
                  .fontColor(this.theme.mainColor)
                  .font({ size:16, weight:500, family:CommonConstants.FAMILY_PingFANG })
                  .lineHeight(24)
              }
              
              Stack(){
                // 分组显示区域：点击展开下拉菜单
                Column(){
                  Text(this.grouping)  // 当前选中的分组
                    .font({ size:15, weight:500 })
                    .fontColor($r('app.string.color_black_45'))
                    .borderRadius(0)
                    .width('100%')
                    .lineHeight(22)
                    .padding({ top:12, bottom:12, right:16, left:16 })
                }
                .alignItems(HorizontalAlign.Center)
                .backgroundColor($r('app.string.color_black_6'))
                
                // 下拉箭头图标
                Column(){
                  Image(this.isShown?
                    $r('app.media.direction_upper') :  // 向上箭头（展开状态）
                    $r('app.media.direction_down'))     // 向下箭头（收起状态）
                    .margin({right:16})
                    .width(15).height(15)
                    .fillColor($r('app.string.color_black_45'))
                    .bindContextMenu(this.isShown, this.MenuBuilder,
                      {
                        onDisappear: ()=>{
                          this.isShown = false;
                        },
                        borderRadius:0
                      })
                }
                .alignItems(HorizontalAlign.End)
                .onClick(()=>{
                  this.isShown = !this.isShown  // 切换下拉菜单显示状态
                })
                .width('100%')
              }
            }
            .padding({top:12,bottom:12})
            .alignItems(HorizontalAlign.Start)

            // -----------------------------------------
            // 替换对象（必填项）
            // -----------------------------------------
            Column({ space:8 }) {
              Flex({
                justifyContent:FlexAlign.SpaceBetween,
                alignItems:ItemAlign.End
              }){
                Row(){
                  Text('替换对象')  // 标签
                    .textAlign(TextAlign.Start)
                    .fontColor($r('app.string.color_black_88'))
                    .font({ size:16, weight:500, family:CommonConstants.FAMILY_PingFANG })
                    .lineHeight(24)
                  
                  Text('*')  // 必填标识
                    .fontColor(this.theme.mainColor)
                    .font({ size:16, weight:500, family:CommonConstants.FAMILY_PingFANG })
                    .lineHeight(24)
                }
                
                // 辅助选项区
                Row({ space:8 }) {
                  // 帮助图标
                  Image($r('app.media.help')).width(16).height(16)
                  
                  // 正则表达式提示文字
                  Text('使用正则表达式')
                    .font({ size:14, weight:400, family:CommonConstants.FAMILY_PingFANG })
                    .fontColor($r('app.string.color_black_45'))
                  
                  // 正则表达式开关
                  Toggle({ type: ToggleType.Switch, isOn: $$this.changeRule})
                    .selectedColor("#F60")  // 橙色选中态
                    .hoverEffect(HoverEffect.None)
                    .onChange(()=>{
                      // 切换时处理逻辑（待实现）
                    })
                }
              }
              
              // 多行文本框：输入要匹配的内容或正则规则
              TextArea({
                placeholder:'请输入替换对象或替换规则'
              }).borderRadius(0)
            }
            .padding({top:12,bottom:12})
            .alignItems(HorizontalAlign.Start)

            // -----------------------------------------
            // 替换为（必填项）
            // -----------------------------------------
            Column({ space:8 }) {
              Flex({
                justifyContent:FlexAlign.SpaceBetween,
                alignItems:ItemAlign.End
              }){
                Row(){
                  Text('替换为')  // 标签
                    .textAlign(TextAlign.Start)
                    .fontColor($r('app.string.color_black_88'))
                    .font({ size:16, weight:500, family:CommonConstants.FAMILY_PingFANG })
                    .lineHeight(24)
                }
                
                // 作用范围选择
                Row({ space:8 }) {
                  // 作用于标题单选
                  Row({ space:8 }) {
                    Text('作用于标题')
                      .font({ size:14, weight:400, family:CommonConstants.FAMILY_PingFANG })
                      .fontColor($r('app.string.color_black_45'))
                    
                    Radio({value:'default',group:'radioGroup'})
                      .radioStyle({ checkedBackgroundColor: this.theme.mainColor })
                      .onChange(()=>{})
                      .width(20).height(20)
                  }

                  // 作用于正文单选（默认选中）
                  Row({ space:8 }) {
                    Text('作用于正文')
                      .font({ size:14, weight:400, family:CommonConstants.FAMILY_PingFANG })
                      .fontColor($r('app.string.color_black_45'))
                    
                    Radio({value:'default',group:'radioGroup'})
                      .radioStyle({ checkedBackgroundColor: this.theme.mainColor })
                      .checked(true)  // 默认选中"作用于正文"
                      .onChange(()=>{})
                      .width(20).height(20)
                  }
                }
              }
              
              // 多行文本框：输入替换后的结果
              TextArea({
                placeholder:'请输入替换结果'
              }).borderRadius(0)
            }
            .padding({top:12,bottom:12})
            .alignItems(HorizontalAlign.Start)

            // -----------------------------------------
            // 替换范围（选填项）
            // -----------------------------------------
            Column({ space:8 }) {
              Row(){
                Text('替换范围')  // 标签
                  .textAlign(TextAlign.Start)
                  .fontColor($r('app.string.color_black_88'))
                  .font({ size:16, weight:500, family:CommonConstants.FAMILY_PingFANG })
                  .lineHeight(24)
              }
              
              // 多行文本框：指定适用的书名或书源 URL
              TextArea({
                placeholder:'选填书名或书源 URL'
              }).borderRadius(0)
            }
            .padding({top:12,bottom:12})
            .alignItems(HorizontalAlign.Start)

            // -----------------------------------------
            // 超时毫秒数
            // -----------------------------------------
            Column({ space:8 }) {
              Row(){
                Text('超时毫秒数')  // 标签
                  .textAlign(TextAlign.Start)
                  .fontColor($r('app.string.color_black_88'))
                  .font({ size:16, weight:500, family:CommonConstants.FAMILY_PingFANG })
                  .lineHeight(24)
              }
              
              // 单行输入框：默认值为 3000ms
              TextInput({
                text: '3000',
                placeholder:'请输入超时毫秒数',
              }).borderRadius(0)
            }
            .padding({top:12,bottom:12})
            .alignItems(HorizontalAlign.Start)
          }
          .margin({left:20,right:20})
        }
        .height('85%')  // 占据 85% 高度
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      
      // ============================================
      // 下层：底部操作按钮区
      // ============================================
      Column(){
        Divider()  // 分隔线
        
        // 通用按钮组件：包含取消和确认按钮
        buttonCommon({
          cancel: ()=>{
            this.cancel()  // 调用取消回调
          },
          confirm: ()=>{
            // 确认操作：显示提示信息（待完善实际保存逻辑）
            showMessage('newAddRule')
          }
        })
      }.padding({bottom:12})
    }
    .height('100%')  // 占满全高
  }
  
  /**
   * 构建标题规则按钮
   * 用于顶部操作区的图标 + 文字组合按钮
   * 
   * @param img - 按钮图标资源
   * @param title - 按钮文字资源
   */
  @Builder titleRule(img:Resource, title:Resource){
    Row({ space:4 }) {
      Image(img)
        .width(20).height(20)
      Text(title)
        .font({ size:14, weight:400 })
    }
  }
  
  // ============================================
  // 分组列表数据
  // ============================================
  @State GroupList: string[] = [
    '未分组',   // 默认分组
    '标题',     // 标题相关规则
    '标点',     // 标点符号规则
    '去广告',   // 去除广告规则
    '排版',     // 排版调整规则
    '格式'      // 格式转换规则
  ]
  
  /**
   * 构建分组下拉菜单
   * 使用 bindContextMenu 绑定的自定义菜单
   */
  @Builder MenuBuilder() {
    Flex({ 
      direction: FlexDirection.Column, 
      justifyContent: FlexAlign.Center, 
      alignItems: ItemAlign.Center 
    }) {
      ForEach(this.GroupList, (item:string, index) => {
        Column() {
          Flex({
            justifyContent:FlexAlign.SpaceBetween,
            alignItems:ItemAlign.Center
          }) {
            // 分组名称
            Text(item)
              .fontSize(14)
              .lineHeight(24)
              .fontColor(item === this.grouping ? 
                this.theme.mainColor :  // 已选中项用主题色
                $r('app.string.color_black_88'))  // 未选中项用灰色
            
            // 选中标记（仅对当前选中的项显示钩子图标）
            if (item === this.grouping){
              Image($r('app.media.hook'))
                .width(24).height(24)
            }
          }
          .padding({right:16,left:16})
          .height(30)
          .width('100%')
          .onClick(() => {
            this.grouping = item  // 点击选中该分组
          })
          
          // 最后一个元素后不加分隔线
          if (index != this.GroupList.length - 1) {
            Divider().height(10).color('#ccc')
          }
        }
      })
    }
    .width(150)  // 菜单宽度
  }
}

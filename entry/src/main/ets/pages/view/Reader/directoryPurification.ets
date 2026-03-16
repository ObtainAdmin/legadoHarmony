/**
 * ============================================
 * directoryPurification.ets - 目录净化弹窗组件
 * ============================================
 * 
 * 【功能说明】
 * 这是一个目录净化规则管理弹窗组件，用于：
 * - 新增或编辑目录净化规则
 * - 设置规则名称和正则表达式
 * - 提供示例输入帮助用户理解
 * - 支持复制/粘贴规则操作
 * - 使用主题色适配 UI 样式
 * 
 * 【使用方法】
 * 1. 将本组件嵌入到 CustomDialogController 中
 * 2. 通过 isEdit 参数控制是"新增"还是"编辑"模式
 * 3. 用户输入规则信息后点击确认保存
 * 4. cancel 回调用于处理取消操作
 * 
 * 【参数说明】
 * @Prop isEdit: boolean              // 编辑模式：true=编辑已有规则，false=新增规则
 * cancel: () => void                // 取消操作的回调函数
 * @StorageProp THEME: ThemeItem     // 从存储中获取的主题颜色配置
 * 
 * 【字段说明】
 * - 名称：净化规则的显示名称（必填）
 * - 正则表达式：用于匹配和过滤目录内容的正则表达式（必填）
 * - 示例：展示正则表达式的匹配示例（可选）
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
export default struct directoryPurification{
  // ============================================
  // 状态变量
  // ============================================
  
  // 编辑模式标识
  // true = 编辑已有规则，false = 新增规则
  // 影响标题显示和保存逻辑
  @Prop isEdit:boolean = false
  
  // 取消操作回调函数
  // 用户点击"取消"按钮时执行
  cancel: () => void = () => {
  }
  
  // 主题颜色配置
  // 从 Storage 中读取 THEME 配置项，用于 UI 配色
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
        // 标题栏：显示模式标题和操作按钮
        Flex({
          justifyContent:FlexAlign.SpaceBetween
        }){
          // 标题文本：根据模式显示不同文案
          Text(this.isEdit?
            $r('app.string.edit_directory_purification') :  // 编辑模式
            $r('app.string.new_directory_purification'))    // 新增模式
            .font({
              size:18,
              weight:500,
              family:CommonConstants.FAMILY_PingFANG  // 使用 PingFang 字体
            })
          
          // 右上角操作按钮区
          Row({ space:20 }) {
            // 复制规则按钮
            this.titleRule($r('app.media.ic_public_copy'),$r('app.string.copy'))
            
            // 粘贴规则按钮
            this.titleRule($r('app.media.icon_rule_paste'),$r('app.string.paste'))
          }
        }.padding({
          top:28,
          left:20,
          right:20,
          bottom:12
        })
        
        // ============================================
        // 表单输入区
        // ============================================
        Column(){
          // -----------------------------------------
          // 名称输入框（必填项）
          // -----------------------------------------
          Column({ space:8 }) {
            // 标签行：显示"名称"和必填标识*
            Row(){
              Text($r('app.string.appellation')  // "名称"本地化文本
                )
                .textAlign(TextAlign.Start)
                .fontColor($r('app.string.color_black_88'))
                .font({
                  size:16,
                  weight:500,
                  family:CommonConstants.FAMILY_PingFANG
                })
                .lineHeight(24)
              
              // 必填标识（红色星号）
              Text('*')
                .fontColor(this.theme.mainColor)  // 使用主题主色
                .font({
                  size:16,
                  weight:500,
                  family:CommonConstants.FAMILY_PingFANG
                })
                .lineHeight(24)
            }
            
            // 名称输入框
            TextInput({
              placeholder:$r('app.string.please_enter_name')  // 提示文字："请输入名称"
            }).borderRadius(0)  // 无边角圆度（保持简洁风格）
          }
          .padding({top:12,bottom:12})
          .alignItems(HorizontalAlign.Start)

          // -----------------------------------------
          // 正则表达式输入框（必填项）
          // -----------------------------------------
          Column({ space:8 }) {
            Flex({
              justifyContent:FlexAlign.SpaceBetween,
            }){
              // 标签行：显示"正则表达式"和必填标识*
              Row(){
                Text($r('app.string.regular_expressions')  // "正则表达式"本地化文本
                  )
                  .textAlign(TextAlign.Start)
                  .fontColor($r('app.string.color_black_88'))
                  .font({
                    size:16,
                    weight:500,
                    family:CommonConstants.FAMILY_PingFANG
                  })
                  .lineHeight(24)
                
                // 必填标识（红色星号）
                Text('*')
                  .fontColor(this.theme.mainColor)
                  .font({
                    size:16,
                    weight:500,
                    family:CommonConstants.FAMILY_PingFANG
                  })
                  .lineHeight(24)
              }
            }
            
            // 多行文本输入框：用于输入较长的正则表达式
            TextArea({
              placeholder: $r('app.string.please_enter_regular_expression')  // "请输入正则表达式"
            }).borderRadius(0)
          }
          .padding({top:12,bottom:12})
          .alignItems(HorizontalAlign.Start)

          // -----------------------------------------
          // 示例输入框（选填项）
          // -----------------------------------------
          Column({ space:8 }) {
            Row(){
              // 标签：显示"示例"
              Text($r('app.string.example')  // "示例"本地化文本
                )
                .textAlign(TextAlign.Start)
                .fontColor($r('app.string.color_black_88'))
                .font({
                  size:16,
                  weight:500,
                  family:CommonConstants.FAMILY_PingFANG
                })
                .lineHeight(24)
            }
            
            // 多行文本输入框：用于输入正则匹配示例
            TextArea({
              placeholder: $r('app.string.please_enter_example')  // "请输入示例"
            }).borderRadius(0)
          }
          .padding({top:12,bottom:12})
          .alignItems(HorizontalAlign.Start)
        }
        .margin({left:20,right:20})  // 左右外边距
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
      Image(img)      // 图标
        .width(20)
        .height(20)
      Text(title)     // 文字
        .font({
          size:14,
          weight:400
        })
    }
  }
}

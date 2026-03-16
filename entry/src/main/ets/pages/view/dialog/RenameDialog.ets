import { ThemeStorageKey } from "../../../common/constants/Theme"
import { ThemeItem } from "../../../common/model/Theme"

/**
 * @author 惟草木之零落兮
 * @date 2024/5/26 16:22
 * 
 * 重命名对话框组件
 * 
 * 功能说明：
 * 1. 提供一个文本输入框用于重命名操作
 * 2. 支持最多4个字符的输入限制
 * 3. 显示当前输入字符数/最大字符数
 * 4. 提供取消和确定按钮
 * 5. 支持主题颜色配置
 * 
 * 使用方法：
 * 1. 通过CustomDialogController打开此对话框
 * 2. 传入oldName参数作为原始名称
 * 3. 设置confirm回调函数处理确认操作
 * 4. 设置cancel回调函数处理取消操作
 * 
 * 参数说明：
 * @controller - 自定义对话框控制器，用于控制对话框的显示和隐藏
 * @textController - 文本输入控制器，用于控制文本输入框
 * @oldName - 原始名称，必填参数，作为输入框的占位符和默认值
 * @newName - 新名称，用户输入的新名称
 * @cancel - 取消回调函数，点击取消按钮时触发
 * @maxText - 当前输入字符数，用于显示字符计数
 * @confirm - 确认回调函数，点击确定按钮时触发，参数为新名称
 * @theme - 主题颜色配置，从本地存储中获取
 */
@Preview
@CustomDialog
export default struct RenameDialog{
    // 对话框控制器，用于控制对话框的显示和隐藏
    controller?: CustomDialogController
    
    // 文本输入控制器，用于控制文本输入框的行为
    textController: TextInputController = new TextInputController()
    
    // 原始名称，必填参数，作为输入框的占位符和默认值
    @Require @Prop oldName:string
    
    // 新名称，用户输入的新名称，初始为空字符串
    newName:string = ""

    // 取消回调函数，点击取消按钮时触发
    cancel: () => void = () => {
    }
    
    // 当前输入字符数，用于显示字符计数，初始值为原始名称的长度
    @State maxText: number = this.oldName.length

    // 确认回调函数，点击确定按钮时触发，参数为新名称
    confirm?: (value: string)=>void

    // 主题颜色配置，从本地存储中获取主题设置
    @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

    /**
     * 按钮样式定义
     * 功能：定义对话框中按钮的统一样式
     * 参数：无
     * 返回值：应用了样式的组件
     */
    @Styles buttonStyles(){
        .height(38)
        .padding({left: 32, right: 32, top: 8, bottom: 8})
        .borderRadius(px2vp(200))
    }

    /**
     * 构建对话框UI
     * 功能：构建重命名对话框的用户界面
     * 包含：
     * 1. 标题"重命名"
     * 2. 文本输入框，显示字符计数
     * 3. 取消和确定按钮
     */
    build(){
        Row(){
            Column(){
                // 对话框标题
                Text('重命名').fontColor('rgba(0, 0, 0, 0.88)').fontSize(18).fontWeight(500).lineHeight(26)
                    .textAlign(TextAlign.Center)
                    .margin({bottom: 16})

                // 文本输入区域，包含输入框和字符计数
                Stack({alignContent: Alignment.End}){
                    /**
                     * 文本输入框
                     * 参数：
                     * @placeholder - 占位符文本，显示原始名称
                     * @text - 输入框的当前值，绑定到newName
                     * @controller - 文本输入控制器
                     * 
                     * 功能：
                     * 1. 限制最大输入长度为4个字符
                     * 2. 实时更新字符计数
                     * 3. 使用主题颜色作为光标颜色
                     * 4. 当输入为空时，恢复为原始名称
                     */
                    TextInput({placeholder: this.oldName, text: this.newName, controller: this.textController})
                        .placeholderFont({size: 14, weight: 400})
                        .placeholderColor("#000000")
                        .fontSize(14)
                        .fontWeight(400)
                        .padding({left: 20, right:20, top: 8, bottom: 8})
                        .height(38)
                        .maxLength(4)  // 限制最大输入长度为4个字符
                        .caretColor(this.theme.mainColor)  // 使用主题颜色作为光标颜色
                        .onChange((value: string)=>{
                            // 输入变化时的处理逻辑
                            if (value.length > 4){
                                // 如果输入超过4个字符，截取前4个
                                value = value.substring(0, 4)
                            }
                            this.maxText = value.length  // 更新字符计数
                            if (this.maxText == 0){
                                // 如果输入为空，恢复为原始名称
                                this.newName = this.oldName
                                this.maxText = this.oldName.length
                                return
                            }
                            this.newName = value  // 更新新名称
                        })
                        .zIndex(1)

                    // 字符计数显示：当前字符数/最大字符数
                    Text(`${this.maxText}/4`)
                        .zIndex(2)
                        .margin({right: 20})
                        .font({size: 12, weight: 400})
                        .opacity(0.45)
                }.height(38).margin({bottom: 24})

                // .onSubmit((enterKey: EnterKeyType, event: SubmitEvent)=>{
                //
                // })
                // 按钮区域：取消和确定按钮
                Row(){
                    // 取消按钮
                    Button("取消")
                        .buttonStyles()
                        .margin({left: 24})
                        .fontWeight(500).fontSize(14).fontColor(this.theme.mainColor)
                        .backgroundColor(this.theme.secondColor)  // 使用主题次要颜色作为背景
                        .onClick(()=>{
                            this.controller?.close()  // 关闭对话框
                        })

                    Blank().layoutWeight(1)  // 空白区域，用于按钮间距

                    // 确定按钮
                    Button("确定")
                        .buttonStyles()
                        .margin({right: 24})
                        .fontWeight(500).fontSize(14).fontColor("rgba(255, 255, 255, 1)")
                        .backgroundColor(this.theme.mainColor)  // 使用主题主颜色作为背景
                        .onClick(()=>{
                            // 触发确认回调函数，传入新名称
                            if (this.confirm) this.confirm(this.newName)
                            this.controller?.close()  // 关闭对话框
                        })
                }
            }
            .backgroundColor("rgba(255, 255, 255, 1)")  // 白色背景
            .padding(24)
            .height(190)
            .width("100%")
            .borderRadius(16)  // 圆角边框
        }
        .padding({left: 38, right: 38})  // 左右边距
    }
}
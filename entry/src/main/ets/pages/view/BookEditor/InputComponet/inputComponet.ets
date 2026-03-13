/**
 * 自定义输入框组件 - 用于书籍编辑页面中的文本输入
 * 
 * 功能概述：
 * 1. 提供可配置的多行文本输入区域（TextArea）
 * 2. 支持自定义占位符、字体大小、颜色、对齐方式等样式
 * 3. 提供输入过滤和文本变化监听
 * 4. 支持透明背景，便于集成到不同样式的界面中
 * 
 * 设计特点：
 * - 高度可配置：通过Props传递所有样式和内容参数
 * - 响应式：实时监听文本变化并更新状态
 * - 轻量级：透明背景，不干扰父容器样式
 * 
 * 使用场景：
 * 在书籍编辑页面（BookEditorPage.ets）中用于书名、作者、封面地址、书籍简介等文本输入
 */

/**
 * 输入框组件结构体
 * 
 * 职责：
 * 1. 提供可配置的文本输入区域
 * 2. 管理输入框的焦点状态和文本内容
 * 3. 应用自定义样式配置
 * 4. 处理文本输入事件和过滤
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 使用export default导出，供其他页面引用
 * - 采用属性驱动设计，所有配置通过Props传递
 */
@Component
export default struct inputComponent {
  /** 输入框背景颜色状态，当前未使用，保留供未来扩展 */
  @State color:string = "#61ffffff"
  
  /** 输入框焦点状态，当前未使用，保留供未来扩展 */
  @State isFocus:boolean = false
  
  /** 输入框当前文本内容，支持ResourceStr类型（字符串或资源引用） */
  @Prop text: ResourceStr = ''
  
  /** 文本输入控制器，用于管理TextArea的焦点、选择等行为 */
  controller: TextInputController = new TextInputController()

  /** 占位符文本，当输入框为空时显示 */
  @Prop TEXT:ResourceStr;
  
  /** 字体大小，应用于占位符和输入文本 */
  @Prop FontSize:number = 14
  
  /** 字体颜色，可以是字符串颜色值或Color对象 */
  @Prop FontColor:string | Color
  
  /** 输入框宽度，由父组件指定 */
  @Prop Width:number
  
  /** 输入框高度，由父组件指定 */
  @Prop Height:number
  
  /** 文本对齐方式，默认为左对齐（Alignment.Start） */
  @Prop textAlign:Alignment = Alignment.Start
  
  /**
   * 构建输入框UI的主要方法
   * 
   * 组件特性：
   * 1. 使用TextArea实现多行文本输入
   * 2. 支持自定义占位符样式（颜色、字体大小）
   * 3. 光标颜色固定为橙色（#F60）
   * 4. 输入文本颜色固定为黑色
   * 5. 完全透明背景（#00ffffff）
   * 6. 支持输入过滤（当前过滤小写字母a-z）
   * 7. 实时监听文本变化
   * 
   * 设计考虑：
   * - 透明背景便于集成到不同样式的父容器中
   * - 固定光标和文本颜色确保视觉一致性
   * - 输入过滤功能可根据需要扩展
   */
  build() {
      // 创建多行文本输入区域
      TextArea({ text: this.text, placeholder:this.TEXT, controller: this.controller })
        // 应用文本对齐方式
        .align(this.textAlign)
        // 设置占位符颜色
        .placeholderColor(this.FontColor)
        // 设置占位符字体大小
        .placeholderFont({ size: this.FontSize})
        // 设置光标颜色为橙色
        .caretColor('#F60')
        // 设置输入文本颜色为黑色
        .fontColor(Color.Black)
        // 设置宽度和高度
        .width(this.Width)
        .height(this.Height)
        // 设置完全透明背景
        .backgroundColor('#00ffffff')
        // 输入过滤器：过滤小写字母a-z（示例功能，可根据需要修改）
        .inputFilter('[a-z]', (e) => {
          console.log(JSON.stringify(e))
        })
        // 监听文本变化事件，更新状态
        .onChange((value: string) => {
          this.text = value
        })
  }
}

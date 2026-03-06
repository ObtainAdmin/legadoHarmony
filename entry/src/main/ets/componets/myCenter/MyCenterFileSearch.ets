/**
 * @file MyCenterFileSearch.ets
 * @description 我的中心文件搜索组件
 * 
 * 功能概述：
 * 1. 提供文件搜索输入框
 * 2. 支持搜索值变化监听
 * 3. 提供搜索回调功能
 * 4. 支持预览模式
 * 
 * 使用场景：
 * - 文件管理页面搜索
 * - 我的中心页面搜索
 * - 需要搜索功能的场景
 * 
 * 设计特点：
 * - 简洁的搜索框设计
 * - 实时的搜索反馈
 * - 统一的视觉风格
 * - 支持预览模式
 * 
 * 组件结构：
 * 1. Row容器：水平布局，宽度100%，高度34px，上下外边距8px
 * 2. Search组件：搜索输入框，占满容器宽度
 * 
 * 技术特点：
 * - 使用@Preview装饰器支持预览模式
 * - 使用@Component装饰器声明组件
 * - 使用@State装饰器管理搜索值状态
 * - 使用@Watch装饰器监听状态变化
 * - 使用SearchController控制搜索组件
 */

/**
 * @author 惟草木之零落兮
 * @date 2024/5/22 15:05
 */

/**
 * @struct MyCenterFileSearch
 * @description 我的中心文件搜索组件
 * 
 * 组件职责：
 * 1. 提供搜索输入界面
 * 2. 管理搜索值状态
 * 3. 处理搜索值变化事件
 * 4. 提供搜索回调功能
 * 
 * @decorator @Preview - 支持预览模式
 * @decorator @Component - 声明为ArkTS组件
 */
@Preview
@Component
export default struct MyCenterFileSearch{
    /** 
     * @state @watch searchValue - 搜索值
     * @description 搜索输入框的值，使用@State管理状态，@Watch监听变化
     * @default '' - 默认空字符串
     * @watch searchEvent - 值变化时触发searchEvent回调
     * @type {string}
     */
    @State @Watch("searchEvent") searchValue: string = ''

    /** 
     * @property onResultCallBack - 搜索结果回调函数
     * @description 搜索值变化时的回调函数，父组件可以通过此函数获取搜索值
     * @type {(searchValue: string) => void | undefined}
     * 
     * 使用方式：
     * ```typescript
     * MyCenterFileSearch({
     *   onResultCallBack: (value: string) => {
     *     // 处理搜索值
     *     console.log('搜索值:', value)
     *   }
     * })
     * ```
     */
    onResultCallBack?: (searchValue: string)=> void

    /** 
     * @property controller - 搜索控制器
     * @description 控制搜索组件的控制器实例
     * @type {SearchController}
     */
    controller: SearchController = new SearchController()

    /**
     * @method build
     * @description 构建我的中心文件搜索组件UI
     * 
     * 布局结构：
     * 1. Row容器：水平布局，宽度100%，高度34px，上下外边距8px
     * 2. Search组件：搜索输入框
     *    - 宽度：100%（占满Row容器）
     *    - 高度：34px
     *    - 占位符：'搜索'
     *    - 占位符颜色：45%黑色（rgba(0, 0, 0, 0.45)）
     *    - 占位符字体：14px，400字重
     *    - 文本字体：14px，400字重
     *    - 内边距：左右16px，上下6px
     *    - 背景颜色：4%黑色（rgba(0, 0, 0, 0.04)）
     *    - 控制器：this.controller
     *    - 值绑定：this.searchValue
     * 
     * 事件处理：
     * 1. onSubmit：提交搜索时触发
     *    - 将输入值赋值给searchValue
     * 2. onChange：输入值变化时触发
     *    - 将输入值赋值给searchValue
     *    - 触发@Watch监听，调用searchEvent方法
     * 
     * 设计理念：
     * - 简洁的视觉设计：浅灰色背景，适当的圆角
     * - 友好的交互体验：实时反馈，支持提交和变化事件
     * - 统一的字体风格：一致的字体大小和字重
     * - 适当的间距：内边距确保输入舒适度
     * 
     * 使用示例：
     * ```typescript
     * // 在父组件中使用
     * MyCenterFileSearch({
     *   onResultCallBack: (value: string) => {
     *     // 处理搜索逻辑
     *     this.filterFiles(value)
     *   }
     * })
     * ```
     * 
     * 颜色说明：
     * 1. rgba(0, 0, 0, 0.45): 45%黑色，用于占位符文字
     * 2. rgba(0, 0, 0, 0.04): 4%黑色，用于搜索框背景
     * 
     * 注意事项：
     * - 搜索框高度固定为34px，适合工具栏使用
     * - 使用SearchController可以控制搜索框的焦点等状态
     * - 搜索值变化会实时触发onResultCallBack回调
     * - 组件支持预览模式，便于开发时查看效果
     * 
     * 扩展建议：
     * - 可以添加搜索图标
     * - 可以添加清除按钮
     * - 可以添加搜索历史
     * - 可以添加搜索建议
     * - 可以支持键盘快捷键
     * 
     * @returns {void}
     */
    build() {
        Row(){
            Search({ value: this.searchValue, placeholder: '搜索', controller: this.controller })
                .width('100%')
                .height(34)
                .placeholderColor("rgba(0, 0, 0, 0.45)")
                .placeholderFont({ size: 14, weight: 400 })
                .textFont({ size: 14, weight: 400 })
                .onSubmit((value: string) => {
                    this.searchValue = value
                })
                .onChange((value: string) => {
                    this.searchValue = value
                })
                .padding({left: 16, right: 16, top: 6, bottom: 6})
                .backgroundColor("rgba(0, 0, 0, 0.04)")
        }
        .margin({top: 8, bottom: 8})
        .width("100%")
        .height(34)
    }

    /**
     * @method searchEvent
     * @description 搜索事件处理函数
     * 
     * 功能说明：
     * 1. 处理搜索值变化事件
     * 2. 调用父组件传入的回调函数
     * 
     * 触发条件：
     * - searchValue状态发生变化时（通过@Watch装饰器监听）
     * - 包括输入变化和提交操作
     * 
     * 逻辑说明：
     * 1. 检查onResultCallBack回调函数是否存在
     * 2. 如果存在，调用回调函数并传入当前搜索值
     * 
     * 使用场景：
     * - 用户输入搜索内容时
     * - 用户提交搜索时
     * - 需要实时搜索过滤时
     * 
     * 注意事项：
     * - 使用@Watch装饰器监听searchValue变化
     * - 需要确保onResultCallBack函数正确绑定
     * - 搜索值变化会立即触发回调，适合实时搜索
     * 
     * 性能考虑：
     * - 频繁输入可能会触发多次回调
     * - 可以考虑添加防抖优化
     * - 可以根据实际需求调整触发频率
     * 
     * @returns {void}
     */
    searchEvent(){
        if (this.onResultCallBack) this.onResultCallBack(this.searchValue)
    }
}

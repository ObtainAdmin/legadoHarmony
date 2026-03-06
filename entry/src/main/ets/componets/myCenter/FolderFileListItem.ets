/**
 * @file FolderFileListItem.ets
 * @description 文件夹文件列表项组件
 * 
 * 功能概述：
 * 1. 显示文件夹或文件的基本信息
 * 2. 支持预览模式下的静态数据展示
 * 3. 提供统一的文件夹/文件项UI
 * 
 * 使用场景：
 * - 文件管理器列表项
 * - 文件夹浏览页面
 * - 预览模式下的UI展示
 * 
 * 设计特点：
 * - 简洁的图标+文字布局
 * - 清晰的层级信息展示
 * - 统一的视觉风格
 * - 支持预览模式
 * 
 * 组件结构：
 * 1. Row容器：水平布局，宽度100%，高度40px
 * 2. Image图标：文件夹/文件图标，40x40px
 * 3. Column容器：垂直布局，占满剩余空间
 *    - Text标题：文件夹/文件名称，14px字体
 *    - Text信息：大小和日期，10px字体
 * 
 * 技术特点：
 * - 使用@Preview装饰器支持预览模式
 * - 使用@Component装饰器声明组件
 * - 使用静态数据用于预览展示
 */

/**
 * @author 惟草木之零落兮
 * @date 2024/5/22 20:51
 */
import CommonConstants from '../../common/constants/CommonConstants'
import FolderAndFileItem from '../dataList/FolderAndFileItem'

/**
 * @struct FolderFileListItem
 * @description 文件夹文件列表项组件
 * 
 * 组件职责：
 * 1. 显示文件夹或文件的基本信息
 * 2. 在预览模式下展示静态数据
 * 3. 提供统一的列表项UI
 * 
 * @decorator @Preview - 支持预览模式
 * @decorator @Component - 声明为ArkTS组件
 */
@Preview
@Component
export default struct FolderFileListItem{
    /** 
     * @property data - 文件夹文件数据
     * @description 文件夹或文件的数据对象，包含标题、图标、大小、日期等信息
     * @type {FolderAndFileItem}
     * @default {title: "MATE 40 PRO 备份", icon: $r("app.media.ic_folder"), size: "12项", date: "2021/8/13", isFolder: true}
     * 
     * 数据结构说明：
     * - title: 文件夹/文件名称
     * - icon: 图标资源
     * - size: 大小或项目数量
     * - date: 最后修改日期
     * - isFolder: 是否为文件夹
     */
    data: FolderAndFileItem = {
        title: "MATE 40 PRO 备份",
        icon: $r("app.media.ic_folder"),
        size: "12项",
        date: "2021/8/13",
        isFolder: true
    }

    /**
     * @method build
     * @description 构建文件夹文件列表项组件UI
     * 
     * 布局结构：
     * 1. Row容器：水平布局，宽度100%，高度40px
     * 2. Image图标：文件夹/文件图标
     *    - 尺寸：40x40px
     *    - 右边距：12px
     * 3. Column容器：垂直布局，高度40px，占满剩余空间（layoutWeight: 1）
     *    - Text标题：文件夹/文件名称
     *      * 高度：22px
     *      * 宽度：100%
     *      * 最大行数：1（单行省略）
     *      * 字体大小：14px
     *      * 字重：500（中等）
     *      * 对齐方式：左对齐
     *      * 文字颜色：88%黑色（rgba(0, 0, 0, 0.88)）
     *    - Text信息：大小和日期
     *      * 高度：18px
     *      * 宽度：100%
     *      * 最大行数：1（单行省略）
     *      * 字体大小：10px
     *      * 字重：500（中等）
     *      * 对齐方式：左对齐
     *      * 文字颜色：45%黑色（rgba(0, 0, 0, 0.45)）
     *      * 内容格式：`${size} ${date}`（如："12项 2021/8/13"）
     * 
     * 设计理念：
     * - 清晰的视觉层次：图标突出，文字信息分层
     * - 高效的空间利用：固定高度，水平布局
     * - 一致的信息展示：统一的格式和样式
     * - 友好的文本处理：单行省略防止溢出
     * 
     * 使用示例：
     * ```typescript
     * // 在父组件中使用
     * FolderFileListItem()
     * 
     * // 实际使用时，data属性应该从父组件传入
     * FolderFileListItem({
     *   data: this.fileItemData
     * })
     * ```
     * 
     * 颜色说明：
     * 1. rgba(0, 0, 0, 0.88): 88%黑色，用于主要标题文字
     * 2. rgba(0, 0, 0, 0.45): 45%黑色，用于次要信息文字
     * 
     * 图标说明：
     * 1. $r("app.media.ic_folder"): 文件夹图标资源
     * 2. 实际使用时可以根据isFolder属性切换不同图标
     * 
     * 注意事项：
     * - 当前为预览模式，使用静态数据
     * - 实际使用时data应该作为@Prop从父组件传入
     * - 组件高度固定为40px，适合列表项使用
     * - 文本使用单行省略，确保布局稳定
     * 
     * 扩展建议：
     * - 可以添加选中状态样式
     * - 可以添加长按菜单功能
     * - 可以添加文件类型图标
     * - 可以添加文件操作按钮（如分享、删除）
     * - 可以支持拖拽功能
     * 
     * @returns {void}
     */
    build() {
        Row(){
            // 文件夹、 文件图标
            Image(this.data.icon)
                .size({width: 40,height: 40})
                .margin({right: 12})

            Column(){
                // 标题，名称
                Text(this.data.title)
                    .height(22)
                    .width("100%")
                    .maxLines(1)
                    .fontSize(14)
                    .fontWeight(500)
                    .textAlign(TextAlign.Start)
                    .fontColor("rgba(0, 0, 0, 0.88)")

                // 大小，数量、最后修改事件
                Text(`${this.data.size} ${this.data.date}`)
                    .height(18)
                    .width("100%")
                    .maxLines(1)
                    .fontSize(10)
                    .fontWeight(500)
                    .textAlign(TextAlign.Start)
                    .fontColor("rgba(0, 0, 0, 0.45)")
            }
            .height(40)
            .layoutWeight(1)  // 占满剩余空间
        }
        .height(40)
        .width("100%")
    }
}

/**
 * @file FolderAndFileItem.ets
 * @description 文件夹和文件项接口
 * 
 * 功能概述：
 * 1. 定义文件夹和文件项的数据结构
 * 2. 支持多种图标类型（PixelMap、ResourceStr、DrawableDescriptor）
 * 3. 提供文件系统项的基本信息字段
 * 4. 用于网盘、本地目录的文件列表展示
 * 
 * 使用场景：
 * - 网盘文件列表数据模型
 * - 本地目录文件列表数据模型
 * - 文件管理器中的文件夹和文件项
 * - 需要显示文件系统结构的场景
 * 
 * 数据字段说明：
 * 1. title: 文件夹/文件标题
 *   - 类型：string
 *   - 用途：显示文件夹或文件的名称
 * 
 * 2. icon: 文件夹/文件图标
 *   - 类型：PixelMap | ResourceStr | DrawableDescriptor
 *   - 用途：显示文件夹或文件的图标，支持多种图标类型
 * 
 * 3. size: 大小/数量
 *   - 类型：string
 *   - 用途：文件夹显示文件数量，文件显示文件大小
 * 
 * 4. date: 最后修改日期
 *   - 类型：string
 *   - 用途：显示文件夹或文件的最后修改时间
 * 
 * 5. isFolder: 是否为文件夹
 *   - 类型：boolean
 *   - 用途：标识该项是文件夹还是文件，用于排序（文件夹在最上面）
 * 
 * 设计特点：
 * - 使用TypeScript接口定义数据结构
 * - 灵活的图标类型支持
 * - 统一的文件系统项模型
 * - 支持文件夹和文件的区分
 * 
 * 技术特点：
 * - 使用联合类型支持多种图标格式
 * - 默认导出接口，便于导入使用
 * - 简洁的字段定义，易于扩展
 * 
 * @author 惟草木之零落兮
 * @date 2024/5/22 20:21
 */

/**
 * @interface FolderAndFileItem
 * @description 文件夹和文件项接口
 * 
 * 接口职责：
 * 1. 定义文件夹和文件项的数据结构
 * 2. 提供文件系统项的标准字段
 * 3. 支持多种图标类型
 * 4. 区分文件夹和文件
 * 
 * 字段说明：
 */
export default interface FolderAndFileItem {
    /** 
     * @property title - 文件夹/文件标题
     * @description 文件夹或文件的名称，用于显示
     * @type {string}
     */
    title: string, // 文件夹文件标题
    
    /** 
     * @property icon - 文件夹/文件图标
     * @description 文件夹或文件的图标，支持多种图标类型：
     * 1. PixelMap: 像素图，适用于动态生成的图标
     * 2. ResourceStr: 资源字符串，如'app.media.icon_folder'
     * 3. DrawableDescriptor: 可绘制描述符，适用于复杂图标
     * @type {PixelMap | ResourceStr | DrawableDescriptor}
     */
    icon: PixelMap | ResourceStr | DrawableDescriptor, // 文件夹文件图标
    
    /** 
     * @property size - 大小/数量
     * @description 文件夹显示包含的文件数量，文件显示文件大小
     * 示例：
     * - 文件夹: "5个项目"
     * - 文件: "2.5MB"
     * @type {string}
     */
    size: string, // 文件夹里文件数量，或者文件的大小
    
    /** 
     * @property date - 最后修改日期
     * @description 文件夹或文件的最后修改时间
     * 格式建议：YYYY-MM-DD HH:mm 或相对时间（如"2天前"）
     * @type {string}
     */
    date: string, // 最后修改日期
    
    /** 
     * @property isFolder - 是否为文件夹
     * @description 标识该项是文件夹还是文件
     * - true: 文件夹
     * - false: 文件
     * 用途：用于排序，文件夹通常显示在最上面
     * @type {boolean}
     */
    isFolder: boolean // 是否为文件夹，用于排序，文件夹在最上面
}

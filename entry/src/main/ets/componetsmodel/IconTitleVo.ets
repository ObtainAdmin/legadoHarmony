/**
 * @author 2008
 * @datetime 2024/6/28 22:43
 * @className: IconTitleVo
 * 
 * 图标标题数据模型类 (Icon Title Value Object)
 * 
 * 功能说明：
 * 1. 用于封装图标和标题的组合数据
 * 2. 在UI组件中显示带图标的标题时使用
 * 3. 作为数据传输对象在组件间传递图标标题信息
 * 
 * 使用场景：
 * - 导航菜单项
 * - 功能按钮
 * - 设置项列表
 * - 任何需要图标+标题组合的UI元素
 * 
 * 示例：
 * ```typescript
 * const item = new IconTitleVo($r('app.media.icon_home'), '首页');
 * ```
 */
export class IconTitleVo{
  /**
   * 图标资源
   * @type {Resource}
   * @description 使用ArkTS的资源引用方式，如：$r('app.media.icon_name')
   */
  icon:Resource;
  
  /**
   * 标题文本
   * @type {string}
   * @description 显示在图标旁边的文字内容
   */
  title:string;

  /**
   * 构造函数
   * @param {Resource} icon - 图标资源
   * @param {string} title - 标题文本
   * @description 创建图标标题数据对象
   */
  constructor(icon:Resource,title:string) {
    this.icon = icon
    this.title = title
  }
}

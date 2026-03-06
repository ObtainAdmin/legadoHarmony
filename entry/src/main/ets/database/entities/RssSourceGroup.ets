/**
 * @author 2008
 * @datetime 2024/12/6 23:31
 * @className: rssSourceGroup
 * 
 * RSS源分组实体类 (RSS Source Group Entity)
 * 
 * 功能说明：
 * 1. 定义RSS源分组的数据结构
 * 2. 管理RSS订阅源的分类和组织
 * 3. 支持分组的排序、置顶和删除控制
 * 4. 提供RSS源分组的基本属性和业务逻辑
 * 
 * 核心属性：
 * - 分组基本信息：ID、名称
 * - 分组显示控制：排序、是否置顶
 * - 分组权限：是否允许删除
 * 
 * 使用场景：
 * - RSS源分组管理
 * - RSS源分类展示
 * - 分组设置和配置
 */
@Observed
export class RssSourceGroup{
  rssGroupId?:number;
  //分组名称
  rssGroupName:string = "";
  //排序
  groupSort?:number;
  //是否置顶
  isTop:boolean = false;
  //是否允许删除
  isDelete:boolean = true;
}

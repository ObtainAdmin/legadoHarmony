/**
 * 书源部分信息实体类 (Book Source Part Entity)
 * 
 * 功能说明：
 * 1. 定义书源的简化数据结构，用于列表展示和快速操作
 * 2. 包含书源的核心属性和状态信息，但不包含复杂的解析规则
 * 3. 优化性能，减少数据传输量
 * 4. 支持书源列表的快速筛选、排序和状态管理
 * 
 * 核心属性：
 * - 书源基本信息：URL、名称、分组、等级、评分
 * - 状态控制：是否启用、是否置顶、是否显示最近图标
 * - 功能标识：是否有登录地址、是否有发现URL
 * - 性能指标：响应时间、权重、最后更新时间
 * 
 * 使用场景：
 * - 书源列表展示
 * - 书源快速筛选和排序
 * - 书源状态管理
 * - 书源性能监控
 */
@Observed
export class BookSourcePart {
  // 地址，包括 http/https
  bookSourceUrl: string = ""
  // 名称
  bookSourceName: string = ""
  // 分组
  bookSourceGroup?: string
  bookSourceGrade?: number = 2
  bookSourceScore?: string
  // 手动排序编号
  customOrder: number = 0
  // 是否启用
  enabled: boolean = true
  // 启用发现
  enabledExplore: boolean = true
  // 是否有登录地址
  hasLoginUrl: boolean = false
  // 最后更新时间，用于排序
  lastUpdateTime: number = 0
  // 响应时间，用于排序
  respondTime: number = 180000
  // 智能排序的权重
  weight: number = 0
  // 是否有发现url
  hasExploreUrl: boolean = false
  // 是否置顶
  isTop: boolean = false
  //是否新增或则更新点击过
  showRecentIcon: boolean = true
  showExplore: boolean = true
}

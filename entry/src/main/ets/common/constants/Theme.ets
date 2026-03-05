import { ThemeColorItem } from "../model/Theme"

/**
 * 主题颜色配置类 - 定义应用中可用的主题颜色方案
 * 
 * 功能：提供预定义的主题颜色方案，每个方案包含主色和辅助色
 * 使用方法：通过 ThemeColor.颜色名 访问对应的主题颜色方案
 * 颜色方案说明：
 *   - mainColor: 主色调，用于主要按钮、高亮元素等
 *   - secondColor: 辅助色，用于背景、次要元素等
 * 设计原则：主色和辅助色保持色彩协调，确保良好的视觉体验
 */
export class ThemeColor {
  /**
   * 橙色主题方案
   * 功能：橙色系主题，温暖、活力的视觉效果
   * 主色：#ff6600 - 鲜艳橙色（RGB: 255, 102, 0）
   * 辅助色：#ffece0 - 浅橙色背景（RGB: 255, 236, 224）
   * 使用场景：默认主题、强调操作、警告提示
   */
  static readonly ORANGE: ThemeColorItem = {mainColor: '#ff6600', secondColor: '#ffece0'}
  
  /**
   * 红色主题方案
   * 功能：红色系主题，热情、警示的视觉效果
   * 主色：#ef4444 - 鲜艳红色（RGB: 239, 68, 68）
   * 辅助色：#fde8e8 - 浅红色背景（RGB: 253, 232, 232）
   * 使用场景：错误提示、重要警告、删除操作
   */
  static readonly RED: ThemeColorItem = {mainColor: '#ef4444', secondColor: '#fde8e8'}
  
  /**
   * 黄色主题方案
   * 功能：黄色系主题，明亮、活泼的视觉效果
   * 主色：#ff9500 - 橙黄色（RGB: 255, 149, 0）
   * 辅助色：#fff2e0 - 浅黄色背景（RGB: 255, 242, 224）
   * 使用场景：提醒通知、次要操作
   */
  static readonly YELLOW: ThemeColorItem = {mainColor: '#ff9500', secondColor: '#fff2e0'}
  
  /**
   * 蓝色主题方案
   * 功能：蓝色系主题，冷静、专业的视觉效果
   * 主色：#188bff - 鲜艳蓝色（RGB: 24, 139, 255）
   * 辅助色：#e3f1ff - 浅蓝色背景（RGB: 227, 241, 255）
   * 使用场景：链接、信息提示、主要操作
   */
  static readonly BLUE: ThemeColorItem = {mainColor: '#188bff', secondColor: '#e3f1ff'}
  
  /**
   * 绿色主题方案
   * 功能：绿色系主题，自然、安全的视觉效果
   * 主色：#24b277 - 鲜艳绿色（RGB: 36, 178, 119）
   * 辅助色：#e4f5ee - 浅绿色背景（RGB: 228, 245, 238）
   * 使用场景：成功提示、确认操作、安全状态
   */
  static readonly GREEN: ThemeColorItem = {mainColor: '#24b277', secondColor: '#e4f5ee'}
}

/**
 * 主题存储键名类 - 定义主题相关数据在AppStorage中的存储键名
 * 
 * 功能：提供统一的存储键名常量，用于在应用存储中保存和读取主题数据
 * 使用方法：通过 ThemeStorageKey.键名 访问对应的存储键名
 * 存储说明：AppStorage是HarmonyOS提供的应用级数据存储机制
 */
export class ThemeStorageKey {
  /**
   * 当前主题键名
   * 功能：存储当前应用主题的键名
   * 使用场景：保存和读取用户选择的当前主题
   * 存储值：主题标识字符串或主题对象
   */
  static readonly THEME: string = 'theme'
  
  /**
   * 主题列表键名
   * 功能：存储可用主题列表的键名
   * 使用场景：保存和读取所有可用的主题列表
   * 存储值：主题对象数组
   */
  static readonly THEMELIST: string = 'themelist'
  
  /**
   * 主题列表字符串键名
   * 功能：存储主题列表JSON字符串的键名
   * 使用场景：以字符串形式保存主题列表，便于序列化存储
   * 存储值：主题列表的JSON字符串
   */
  static readonly THEMELISTSTR: string = 'themeliststr'
  
  /**
   * 主题索引键名
   * 功能：存储当前选中主题索引的键名
   * 使用场景：保存和读取用户在主题列表中选择的索引位置
   * 存储值：数字索引（从0开始）
   */
  static readonly THEMEINDEX: string = 'themeindex'
}

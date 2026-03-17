/**
 * appData.ets - 应用程序全局数据初始化模块
 * 
 * 功能说明：
 * 该模块负责应用程序启动时的全局数据初始化工作，包括：
 * 1. 应用主页面可滚动状态配置
 * 2. RSS订阅源分组数据初始化
 * 3. Web User-Agent配置加载
 * 4. 书籍列表数据初始化
 * 5. 发现/探索页面数据初始化
 * 
 * 数据存储说明：
 * - 使用 AppStorage 进行应用级内存存储，数据可在应用内各页面共享
 * - 使用 bookDataPreferences 进行持久化存储，数据会保存到本地
 * 
 * 使用方式：
 * import { initAppData, updateAppData } from '../storage/appData'
 * 
 * // 在应用入口处调用初始化
 * initAppData()
 * 
 * // 更新页面滚动状态
 * updateAppData(true)
 */

// 导入公共常量定义
import CommonConstants from '../common/constants/CommonConstants'
// 导入数据偏好设置工具类
import bookDataPreferences from '../common/utils/DataPreferencesUtils'
// 导入书籍列表数据初始化函数
import { initBookListData } from './bookListData'
// 导入发现页面数据初始化函数
import { initFindData } from './findData'
// 导入程序基础数据偏好设置
import programDataPreferences from '../preferences/programDataPreferences'


/**
 * APP_INDEX_SCROLLABLE 键名常量
 * 
 * 说明：用于标识应用主页面(Index)是否支持滚动
 * 值类型：boolean
 * 存储位置：AppStorage（应用级内存存储）
 */
let APP_INDEX_SCROLLABLE = 'APP_INDEX_SCROLLABLE'

/**
 * APP_INDEX_SCROLLABLE_DATA 默认值
 * 
 * 说明：应用主页面默认滚动状态
 * false - 禁用滚动（通常用于杂志风或瀑布流布局的展示页面）
 * true - 启用滚动（普通列表页面）
 */
const APP_INDEX_SCROLLABLE_DATA = false

/**
 * initAppData 函数
 * 
 * 功能：应用程序全局数据初始化入口
 * 
 * 初始化执行流程：
 * 1. 设置应用主页面滚动状态（默认禁用）
 * 2. 检查并初始化RSS订阅源分组数据（仅首次）
 * 3. 加载或初始化Web UA配置
 * 4. 初始化书籍列表相关状态数据
 * 5. 初始化发现/探索页面数据
 * 
 * 调用场景：
 * - 应用程序首次启动时
 * - 应用从后台恢复时
 * - 需要重置应用状态时
 * 
 * @returns void 无返回值
 */
export const initAppData = ()=>{
  // 第1步：设置应用主页面滚动状态
  // 使用 AppStorage.setOrCreate 确保键存在，不覆盖已有值
  AppStorage.setOrCreate(APP_INDEX_SCROLLABLE,APP_INDEX_SCROLLABLE_DATA)
  
  // 第2步：检查RSS订阅源分组是否已初始化
  // CommonConstants.RSS_SOURCES_GROUP_INIT 是初始化标志位
  // 只有从未初始化过的情况下才执行初始化，避免覆盖用户已配置的分组数据
  if (!bookDataPreferences.shared.get(CommonConstants.RSS_SOURCES_GROUP_INIT) as boolean) {
    // 调用 programDataPreferences 初始化默认分组列表
    programDataPreferences.initProgramDataPreferences()
    // 设置已初始化标志，防止下次重复初始化
    programDataPreferences.initRssSourcesListData()
  }
  
  // 第3步：加载Web User-Agent配置
  // 获取用户之前保存的UA设置（如果有的话）
  let SystemUA = programDataPreferences.getWebUAData();
  
  // 如果用户已配置过UA设置（值存在且不为0/false），则加载到AppStorage
  if (SystemUA) {
    AppStorage.setOrCreate(CommonConstants.SYSTEM_UA,SystemUA)
  } else {
    // 用户首次使用，初始化默认UA设置（0 = 默认/手机UA）
    programDataPreferences.updateWebUAData(0)
    AppStorage.setOrCreate(CommonConstants.SYSTEM_UA,0)
  }
  
  // 第4步：初始化书籍列表相关状态数据
  // 包括刷新状态、加载状态等标志位
  initBookListData()
  
  // 第5步：初始化发现/探索页面数据
  initFindData()
}

/**
 * updateAppData 函数
 * 
 * 功能：动态更新应用全局配置数据
 * 
 * @param INDEX_SCROLLABLE boolean 应用主页面是否可滚动
 *   - false: 禁用滚动（默认布局）
 *   - true: 启用滚动（普通列表）
 * 
 * @returns void 无返回值
 * 
 * 使用示例：
 * // 切换到可滚动列表模式
 * updateAppData(true)
 * 
 * // 切换到杂志风展示模式
 * updateAppData(false)
 * 
 * 注意事项：
 * 该方法只更新AppStorage中的运行时数据，不影响持久化存储
 * 应用重启后会恢复为 initAppData 中的默认值
 */
export const updateAppData = (INDEX_SCROLLABLE:boolean)=>{
  // 直接更新键值，不使用 setOrCreate（假设初始化已完成）
  AppStorage.set(APP_INDEX_SCROLLABLE,INDEX_SCROLLABLE)
}
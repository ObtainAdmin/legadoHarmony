/**
 * @author 2008
 * @datetime 2024/7/17 19:30
 * @className: programDataPreferences
 * 程序基础数据定义
 */
import CommonConstants from '../common/constants/CommonConstants'
import bookDataPreferences from '../common/utils/DataPreferencesUtils'

/**
 * programDataPreferences 类
 * 
 * 功能说明：
 * 该类用于管理阅读器应用程序的基础配置数据，主要包括：
 * 1. RSS订阅源分组数据的管理（新增、修改、查询）
 * 2. Web浏览器User-Agent(UA)设置的管理
 * 
 * 数据持久化方式：
 * 使用 bookDataPreferences 工具类将数据保存到本地存储，
 * 通过 CommonConstants 中定义的键名进行数据的存取操作
 * 
 * 使用示例：
 * import programPreferences from '../preferences/programDataPreferences'
 * 
 * // 初始化分组数据
 * programPreferences.initProgramDataPreferences()
 * 
 * // 获取分组列表
 * const groups = programPreferences.getRssSourcesListData()
 */
export class programDataPreferences {
  /**
   * rssSourcesGroup: RSS订阅源默认分组列表
   * 
   * 说明：应用程序预定义的RSS订阅源分类，共5个默认分组：
   * - 小说：用于管理小说类订阅源
   * - 漫画：用于管理漫画类订阅源
   * - 影视：用于管理影视资讯类订阅源
   * - 资讯：用于管理新闻资讯类订阅源
   * - 收藏夹：用于存放用户收藏的订阅源
   * 
   * 类型：字符串数组
   * 读取方式：只读属性，初始化后不应直接修改
   */
  readonly rssSourcesGroup: string[] = ['小说', '漫画', '影视', '资讯', '收藏夹']
  
  /**
   * initProgramDataPreferences 方法
   * 
   * 功能：初始化程序基础数据配置
   * 
   * 具体操作：
   * 1. 将默认的RSS订阅源分组列表(rssSourcesGroup)持久化存储
   * 2. 使用 CommonConstants.RSS_SOURCES_GROUP_LIST_DATA_KEY 作为存储键名
   * 
   * 调用场景：
   * - 应用程序首次启动时
   * - 需要重置分组数据为默认值时
   * 
   * @returns void 无返回值
   */
  initProgramDataPreferences = () => {
    //内容数据持久化
    //订阅源分组数据
    // 将默认分组列表写入本地存储，键名为 CommonConstants.RSS_SOURCES_GROUP_LIST_DATA_KEY
    bookDataPreferences.shared.set(CommonConstants.RSS_SOURCES_GROUP_LIST_DATA_KEY, programPreferences.rssSourcesGroup)
  }
  
  /**
   * initRssSourcesListData 方法
   * 
   * 功能：标记RSS订阅源分组列表已初始化
   * 
   * 具体操作：
   * 设置一个布尔标志位到本地存储，表示分组数据已经完成初始化
   * 键名为 CommonConstants.RSS_SOURCES_GROUP_INIT
   * 
   * 使用场景：
   * 在首次调用 initProgramDataPreferences 后调用，避免重复初始化
   * 可用于判断是否需要显示分组设置向导
   * 
   * @returns void 无返回值
   */
  //分组初始化标识
  initRssSourcesListData = () =>{
    // 设置初始化标志为true，表示已完成分组数据初始化
    bookDataPreferences.shared.set(CommonConstants.RSS_SOURCES_GROUP_INIT, true)
  }

  /**
   * updateRssSourcesListData 方法
   * 
   * 功能：更新RSS订阅源分组列表
   * 
   * 具体操作：
   * 整个替换存储的分组数据数组
   * 
   * @param data string[] 新的分组列表数据
   * @returns void 无返回值
   * 
   * 使用示例：
   * programPreferences.updateRssSourcesListData(['小说', '漫画', '影视', '音乐', '收藏夹'])
   */
  updateRssSourcesListData = (data:string[] ) =>{
    // 直接用新数组覆盖原有数据
    bookDataPreferences.shared.set(CommonConstants.RSS_SOURCES_GROUP_LIST_DATA_KEY,data)
  }

  /**
   * updateRssSourcesData 方法
   * 
   * 功能：向RSS订阅源分组列表中添加一个新的分组
   * 
   * 具体操作：
   * 1. 先从存储中获取当前的分组列表
   * 2. 将新分组名称添加到数组末尾
   * 3. 将更新后的数组重新保存到存储
   * 
   * @param data string 要添加的分组名称
   * @returns void 无返回值
   * 
   * 注意：如果存储中不存在分组数据，该方法可能会出错
   *      建议在添加前先调用 initProgramDataPreferences 初始化
   * 
   * 使用示例：
   * programPreferences.updateRssSourcesData('游戏')
   */
  updateRssSourcesData = (data:string ) =>{
    // 从存储中获取现有的分组列表
    let group = bookDataPreferences.shared.get(CommonConstants.RSS_SOURCES_GROUP_LIST_DATA_KEY) as string[]
    // 将新分组添加到列表末尾
    group.push(data)
    // 重新保存更新后的列表
    bookDataPreferences.shared.set(CommonConstants.RSS_SOURCES_GROUP_LIST_DATA_KEY, group)
  }

  /**
   * getRssSourcesListData 方法
   * 
   * 功能：获取当前RSS订阅源分组列表
   * 
   * 具体操作：
   * 从本地存储中读取分组列表数据并返回
   * 
   * @returns string[] 分组名称数组，如果无数据则返回空数组或null
   * 
   * 使用示例：
   * const groups = programPreferences.getRssSourcesListData()
   * groups.forEach(group => console.log(group))
   */
  getRssSourcesListData = () => {
    // 读取并返回存储中的分组列表数据
    return bookDataPreferences.shared.get(CommonConstants.RSS_SOURCES_GROUP_LIST_DATA_KEY) as string[]
  }

  /**
   * initWebUADataPreferences 方法
   * 
   * 功能：初始化Web User-Agent(UA)设置
   * 
   * 具体操作：
   * 设置默认的UA索引值为0，存储键名为 CommonConstants.SYSTEM_UA
   * 
   * 说明：
   * UA用于模拟不同浏览器或设备的请求头，
   * 部分网站会根据UA返回不同的页面内容或适配版本
   * 
   * @returns void 无返回值
   */
  //WEB UA设置
  initWebUADataPreferences = () => {
    // 设置默认UA索引为0（通常对应系统默认值/手机UA）
    bookDataPreferences.shared.set(CommonConstants.SYSTEM_UA, 0)
  }
  
  /**
   * updateWebUAData 方法
   * 
   * 功能：更新Web User-Agent设置
   * 
   * @param UAIndex number UA选项索引
   *   0 - 默认/手机UA
   *   1 - PC桌面浏览器UA
   *   2 - 平板UA
   *   ... 其他自定义选项
   *   
   * @returns void 无返回值
   * 
   * 使用示例：
   * // 切换到PC端UA
   * programPreferences.updateWebUAData(1)
   */
  //更新WEB UA
  updateWebUAData = (UAIndex:number ) =>{
    // 将用户选择的UA索引保存到存储
    bookDataPreferences.shared.set(CommonConstants.SYSTEM_UA,UAIndex)
  }
  
  /**
   * getWebUAData 方法
   * 
   * 功能：获取当前Web User-Agent设置
   * 
   * 具体操作：
   * 从存储中读取用户配置的UA索引值
   * 
   * @returns number 当前配置的UA索引，默认为0
   * 
   * 使用示例：
   * const uaIndex = programPreferences.getWebUAData()
   * // 根据索引获取对应的UA字符串
   * const uaString = uaList[uaIndex]
   */
  //获取WEB UA
  getWebUAData = () => {
    // 返回存储中的UA索引值
    return bookDataPreferences.shared.get(CommonConstants.SYSTEM_UA) as number
  }
}

/**
 * programPreferences 单例实例
 * 
 * 说明：
 * 创建 programDataPreferences 类的唯一实例，供全局使用
 * 这种单例模式确保整个应用程序共享同一份配置数据
 * 
 * 使用方式：
 * import programPreferences from '../preferences/programDataPreferences'
 * programPreferences.initProgramDataPreferences()
 */
const programPreferences = new programDataPreferences()
export default programPreferences
/**
 * 搜索配置数据模型类 - 定义搜索请求的配置信息
 * 
 * @author 2008
 * @datetime 2024/8/15 0:06
 * @className: SearchConfig
 * 
 * 功能：描述搜索请求的完整配置，包括路径、方法、请求体、字符集等
 * 使用场景：
 *   - 小说搜索功能的请求配置
 *   - 网络请求的参数封装
 *   - 搜索规则的解析和存储
 * 特性：支持GET/POST方法、自定义请求体、字符集设置、WebView模式等
 */
export class SearchConfig {
  /**
   * 搜索路径
   * 功能：搜索规则的标识路径或名称
   * 使用场景：标识不同的搜索源或搜索规则
   */
  path: string;
  
  /**
   * HTTP方法
   * 功能：搜索请求使用的HTTP方法（GET或POST）
   * 使用场景：决定如何发送搜索请求
   * 注意：构造函数中会转换为大写字母
   */
  method: string;
  
  /**
   * 请求体
   * 功能：POST请求的请求体内容，GET请求时可能为空
   * 使用场景：POST请求时携带搜索参数
   * 特殊标记：可能包含{{key}}占位符，会被实际关键词替换
   */
  body: string;
  
  /**
   * 字符集
   * 功能：请求和响应的字符编码
   * 使用场景：正确解析搜索结果的文本内容
   * 默认值：'UTF-8'
   */
  charset: string;
  
  /**
   * 请求URL
   * 功能：搜索请求的目标URL
   * 使用场景：发送HTTP请求到目标服务器
   */
  url: string;
  
  /**
   * 是否使用WebView
   * 功能：标识是否需要在WebView中执行搜索
   * 使用场景：某些网站需要JavaScript渲染或复杂交互时使用WebView
   * 默认值：false（默认使用HTTP请求）
   */
  webView: boolean;

  /**
   * 构造函数
   * @param path - 搜索路径/规则标识
   * @param method - HTTP方法（GET/POST），会自动转换为大写
   * @param body - 请求体内容
   * @param charset - 字符集，默认为'UTF-8'
   * @param url - 请求URL
   * @param webView - 是否使用WebView，默认为false
   */
  constructor(path: string, method: string, body: string, charset: string, url: string, webView: boolean) {
    this.path = path;
    this.method = method.toUpperCase(); // 确保方法为大写
    this.body = body;
    this.charset = charset ?? 'UTF-8';
    this.url = url;
    this.webView = webView;
  }

  /**
   * 替换请求体中的关键字
   * 功能：将请求体中的{{key}}占位符替换为实际搜索关键词
   * @param keyword - 用户输入的搜索关键词
   * 使用场景：执行搜索前准备完整的请求体
   * 注意：关键词会进行URL编码，确保特殊字符正确处理
   */
  setKeyword(keyword: string): void {
    this.body = this.body.replace('{{key}}', encodeURIComponent(keyword));
  }
}

/**
 * 搜索配置数据接口
 * 功能：定义从JSON解析的搜索配置数据结构
 * 使用场景：parseSearchString函数解析字符串时使用此接口
 */
interface SearchConfigData {
  method: string;
  body?: string;
  charset?: string;
  url: string;
  webView?: boolean;
}

/**
 * 解析搜索配置字符串
 * 功能：将特定格式的字符串解析为SearchConfig对象
 * @param searchString - 搜索配置字符串，格式为"path, {json配置}"
 * 返回值：SearchConfig - 解析后的搜索配置对象
 * 使用场景：从配置文件或数据库读取搜索规则时解析
 * 字符串格式示例："小说源1, {method:'GET', url:'https://example.com/search', charset:'UTF-8'}"
 * 解析步骤：
 *   1. 按逗号分割路径和JSON配置
 *   2. 清理JSON字符串（添加引号、替换单引号）
 *   3. 解析JSON为SearchConfigData对象
 *   4. 创建SearchConfig实例
 */
export function parseSearchString(searchString: string): SearchConfig {
  // 拆分字符串，获取路径与配置
  const splitIndex = searchString.indexOf(',');
  const path = searchString.substring(0, splitIndex).trim();
  const configString = searchString.substring(splitIndex + 1).trim();

  // 对 JSON 配置进行清理和格式化
  const cleanConfigString = configString
    .replace(/(\w+)\s*:/g, '"$1":')  // 给键加上引号（将 key: 转换为 "key":）
    .replace(/'/g, '"');             // 将单引号替换为双引号

  // 解析 JSON 配置
  const config: SearchConfigData = JSON.parse(cleanConfigString);

  return new SearchConfig(
    path,
    config.method ?? 'GET',
    config.body ?? '',
    config.charset ?? 'UTF-8',
    config.url ?? '',
    config.webView ?? false
  );
}

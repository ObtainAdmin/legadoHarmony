/**
 * URL解析工具类 - 提供URL解析和构建功能的工具类
 * 
 * 功能：封装URL解析相关功能，包括URL参数替换、路径构建、占位符处理等
 * 核心特性：
 *   1. URL参数解析：解析搜索URL中的路径和查询参数
 *   2. 占位符替换：替换URL中的{{key}}、{{page}}等占位符
 *   3. URL构建：根据基础URL、路径和查询参数构建完整URL
 *   4. 书源支持：支持书源配置的URL规则解析
 * 使用场景：书籍搜索URL构建、书源规则解析、网络请求URL处理
 */
import { BookSource } from '../../database/entities/BookSource';
import AppPattern from '../constants/AppPattern';
import { parseSearchString, SearchConfig } from '../model/SearchConfig';
import networkUtil from './NetworkUtils';

/**
 * URL解析接口 - 定义URL解析所需的参数
 * 
 * 功能：描述URL解析过程中需要的所有参数
 * 使用场景：作为ParseURL类的构造参数，传递URL解析配置
 */
export interface IParseURL {
  baseUrl: string;          // 基础URL
  searchUrl: string;        // 搜索URL（可能包含占位符）
  page: number;             // 页码
  keyword: string;          // 搜索关键词
  removeCookie?: boolean;   // 是否移除Cookie（可选）
  bookSource: BookSource;   // 书源配置
  speakText?: string;       // 语音文本（可选，用于语音功能）
  speakSpeed?: number;      // 语速（可选，用于语音功能）
}

/**
 * URL解析数据类 - 封装URL解析的配置数据
 * 
 * 功能：存储URL解析过程中的所有配置数据
 * 使用场景：作为ParseURLUtils类的输入参数
 */
export class ParseURL {
  baseUrl: string = '';           // 基础URL
  searchUrl: string = '';         // 搜索URL
  page: number = 1;               // 当前页码，默认第1页
  keyword: string = '';           // 搜索关键词
  removeCookie?: boolean = false; // 是否移除Cookie，默认不移除
  speakText?: string;             // 语音文本
  speakSpeed?: number;            // 语速
  bookSource?: BookSource;        // 书源配置

  /**
   * 构造函数
   * 功能：初始化ParseURL实例，支持从IParseURL接口初始化
   * @param parseUrl - URL解析配置（可选）
   * 使用场景：创建URL解析配置对象
   */
  constructor(parseUrl?: IParseURL) {
    this.baseUrl = parseUrl?.baseUrl || '';
    this.searchUrl = parseUrl?.searchUrl || '';
    this.page = parseUrl?.page || 1;
    this.keyword = parseUrl?.keyword || '';
    this.removeCookie = parseUrl?.removeCookie;
    this.bookSource = parseUrl?.bookSource;
    this.speakText = parseUrl?.speakText;
    this.speakSpeed = parseUrl?.speakSpeed;
  }
}

/**
 * URL解析工具类 - 提供URL解析和构建的核心功能
 * 
 * 功能：执行URL解析、占位符替换、URL构建等操作
 * 使用场景：处理书源搜索规则，构建实际的搜索URL
 */
export class ParseURLUtils {
  parseURL: ParseURL = new ParseURL();  // URL解析配置
  ruleUrl: string = '';                  // 规则URL（清理后的searchUrl）
  url: string = '';                      // 基础URL（清理后的baseUrl）

  /**
   * 初始化方法
   * 功能：清理和预处理URL，移除特殊字符和模式
   * 处理流程：
   *   1. 从baseUrl中移除AppPattern.pattern匹配的部分
   *   2. 清理searchUrl和baseUrl，移除空白字符和换行符
   * 使用场景：在URL处理前进行预处理
   */
  private init() {
    let urlMatcher = this.parseURL.baseUrl.match(AppPattern.pattern);
    if (urlMatcher && urlMatcher.length > 0) {
      this.parseURL.baseUrl = this.parseURL.baseUrl.substring(0, urlMatcher.index);
    }
    this.ruleUrl = networkUtil.cleanUrl(this.parseURL.searchUrl);
    this.url = networkUtil.cleanUrl(this.parseURL.baseUrl);
  }

  /**
   * 设置URL解析配置
   * 功能：更新ParseURLUtils实例的URL解析配置
   * @param value - 新的ParseURL配置
   * 使用场景：更新URL解析参数
   */
  setParseURL(value: ParseURL) {
    this.parseURL = value;
  }

  /**
   * 提取和替换占位符
   * 功能：移除URL中的{{...}}占位符
   * @param ruleUrl - 包含占位符的规则URL
   * 返回值：string - 移除占位符后的URL
   * 使用场景：预处理书源规则URL，移除不需要的占位符
   */
  extractAndReplace(ruleUrl: string): string {
    if (ruleUrl.startsWith("{{")) {
      const end = ruleUrl.indexOf("}}");
      if (end !== -1) {
        const result = ruleUrl.replace(/{{[^}]*}}/, '');
        return result ?? '';
      }
    }
    return ruleUrl;
  }

  /**
   * 替换占位符
   * 功能：将字符串中的占位符替换为实际值
   * @param str - 包含占位符的字符串
   * @param placeholder - 占位符，如'{{key}}'、'{{page}}'
   * @param replacement - 要替换的值
   * 返回值：string - 替换后的字符串
   * 使用场景：将URL中的{{key}}替换为实际关键词，{{page}}替换为实际页码
   */
  replacePlaceholders(str: string, placeholder: string, replacement: string): string {
    const regex = new RegExp(placeholder, 'g');
    return str.replace(regex, replacement);
  }

  /**
   * 构建基础URL
   * 功能：根据基础URL、路径和查询参数构建完整URL
   * @param baseUrl - 基础URL
   * @param path - 路径部分
   * @param body - 查询参数部分
   * 返回值：string - 构建后的完整URL
   * 处理逻辑：
   *   1. 如果path不是完整URL，则与baseUrl拼接
   *   2. 处理路径和查询参数之间的连接符（/或?）
   *   3. 确保URL格式正确，移除多余的斜杠
   * 使用场景：构建搜索请求的完整URL
   */
  buildBaseUrl(baseUrl: string, path: string, body: string): string {
    const ensureNoLeadingSlash = (str: string) => str.replace(/^\/+/, '');
    const ensureNoTrailingSlash = (str: string) => str.replace(/\/+$/, '');

    if (path) {
      if (!path.startsWith('http://') && !path.startsWith('https://')) {
        path = ensureNoTrailingSlash(baseUrl) + '/' + ensureNoLeadingSlash(path);
      } else {
        path = ensureNoTrailingSlash(path);
      }
    } else {
      path = ensureNoTrailingSlash(baseUrl);
    }

    if (path && body) {
      if (!path.endsWith('/') && !body.startsWith('/')) {
        // 需要校验path如果结尾是/就替换为? 如果没有/就添加?
        if (path.endsWith('/')) {
          path = path.slice(0, -1);
        }
        path += '?';
      } else if (path.endsWith('/') && body.startsWith('/')) {
        body = ensureNoLeadingSlash(body);
      }
    }
    return ensureNoTrailingSlash(path + body);
  }

  /**
   * 处理规则URL
   * 功能：解析书源规则URL，构建实际的搜索URL
   * 返回值：SearchConfig | string - 解析后的搜索配置或URL字符串
   * 处理流程：
   *   1. 初始化URL配置
   *   2. 提取和替换占位符
   *   3. 尝试解析为SearchConfig（包含路径和查询参数）
   *   4. 构建完整URL并替换占位符
   *   5. 如果解析失败，则按简单URL处理
   * 使用场景：书源搜索规则解析，构建实际请求URL
   */
  processRuleUrl(): SearchConfig | string {
    this.init();
    let baseUrl = '';
    let searchUrl = this.ruleUrl;
    searchUrl = this.extractAndReplace(searchUrl);
    
    try {
      let parseSearch = parseSearchString(searchUrl);
      baseUrl = this.buildBaseUrl(this.url, parseSearch.path, parseSearch.body);
      baseUrl = this.replacePlaceholders(baseUrl, '{{key}}', decodeURIComponent(this.parseURL.keyword));
      baseUrl = this.replacePlaceholders(baseUrl, '{{page}}', this.parseURL.page.toString());
      baseUrl = networkUtil.getAbsoluteURL(this.url, baseUrl);
      parseSearch.url = baseUrl;
      return parseSearch;
    } catch (e) {
      baseUrl = this.buildBaseUrl(this.url, searchUrl, '');
      baseUrl = this.replacePlaceholders(baseUrl, '{{key}}', decodeURIComponent(this.parseURL.keyword));
      baseUrl = this.replacePlaceholders(baseUrl, '{{page}}', this.parseURL.page.toString());
      return baseUrl;
    }
  }
}

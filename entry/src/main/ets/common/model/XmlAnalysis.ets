/**
 * XML分析模块 - 用于解析搜索结果的XML/HTML数据
 * 
 * 功能：通过HTTP请求将搜索数据发送到后端服务器进行解析，获取结构化的书籍列表
 * 核心特性：
 *   1. 后端解析：将复杂的XML/HTML解析逻辑委托给后端服务器
 *   2. 相对URL处理：自动处理相对URL，转换为完整URL
 *   3. 类型安全：使用TypeScript接口确保数据类型安全
 * 使用场景：小说搜索结果的解析，特别是需要复杂HTML/XML解析的场景
 */
import { SearchRule } from '../../database/entities/rule';
import { SearchBook } from '../../database/entities/SearchBook';
import { BookSource } from '../../database/entities/BookSource';
import { ExploreQuery } from '../../database/types/BookSourceType';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { isNetworkUrl } from '../utils/utils';
import CommonConstants from '../constants/CommonConstants';

/**
 * XML分析接口 - 定义XML分析所需的数据结构
 * 
 * 功能：描述发送到后端解析服务的数据结构
 * 使用场景：创建XmlAnalysisData实例时使用此接口
 */
export interface IXmlAnalysis {
  /**
   * 基础URL
   * 功能：搜索请求的基础地址
   * 使用场景：用于拼接相对URL，获取完整URL
   */
  baseUrl: string;
  
  /**
   * 请求内容
   * 功能：搜索请求的响应内容（HTML/XML）
   * 使用场景：发送到后端进行解析的原始数据
   */
  body: string;
  
  /**
   * 书源信息
   * 功能：搜索使用的书源配置
   * 使用场景：提供书源类型、URL等配置信息
   */
  bookSource: BookSource;
  
  /**
   * 变量（可选）
   * 功能：解析过程中使用的自定义变量
   * 使用场景：动态解析规则、条件判断等
   */
  variable?: string;
  
  /**
   * 搜索URL
   * 功能：实际发送搜索请求的URL
   * 使用场景：记录搜索来源，用于调试和日志
   */
  searchUrl: string;
}
/**
 * 数据规则接口 - 定义发送到后端解析服务的数据结构
 * 
 * 功能：描述发送到后端解析API的请求数据结构
 * 使用场景：getBookList方法中构建请求数据
 */
interface dataRule {
  /**
   * 请求内容
   * 功能：要解析的HTML/XML内容
   */
  body: string;
  
  /**
   * 搜索规则
   * 功能：解析使用的搜索规则配置
   */
  rule: SearchRule;
  
  /**
   * 搜索URL
   * 功能：搜索请求的原始URL
   */
  searchUrl: string;
}

/**
 * XML分析数据类 - XML分析的数据容器类
 * 
 * 功能：封装XML分析所需的所有数据，提供默认值和构造函数
 * 使用场景：存储和管理XML分析过程中的数据
 */
export class XmlAnalysisData {
  /**
   * 基础URL
   * 功能：搜索请求的基础地址
   * 默认值：空字符串
   */
  baseUrl: string = '';
  
  /**
   * 请求内容
   * 功能：搜索请求的响应内容（HTML/XML）
   * 默认值：空字符串
   */
  body: string = '';
  
  /**
   * 书源信息（可选）
   * 功能：搜索使用的书源配置
   */
  bookSource?: BookSource;
  
  /**
   * 变量（可选）
   * 功能：解析过程中使用的自定义变量
   */
  variable?: string;
  
  /**
   * 搜索URL
   * 功能：实际发送搜索请求的URL
   * 默认值：空字符串
   */
  searchUrl: string = '';
  
  /**
   * 构造函数
   * @param xmlDate - 可选的IXmlAnalysis接口数据，用于初始化对象
   * 功能：使用提供的XML分析数据初始化对象，未提供的字段使用默认值
   */
  constructor(xmlDate?: IXmlAnalysis) {
    this.baseUrl = xmlDate?.baseUrl || '';
    this.body = xmlDate?.body || '';
    this.bookSource = xmlDate?.bookSource;
    this.variable = xmlDate?.variable;
    this.searchUrl = xmlDate?.searchUrl || '';
  }
}
/**
 * XML分析类 - 执行XML/HTML解析的核心类
 * 
 * 功能：管理XML分析过程，包括初始化、发送解析请求、处理解析结果
 * 使用场景：搜索结果的解析、书籍列表的提取
 */
export class XmlAnalysis {
  /**
   * XML分析数据
   * 功能：存储XML分析所需的所有数据
   * 默认值：新的XmlAnalysisData实例
   */
  xmlDate: XmlAnalysisData = new XmlAnalysisData();
  
  /**
   * URL
   * 功能：当前分析的URL地址
   * 默认值：空字符串
   */
  url: string = '';
  
  /**
   * 搜索规则（可选）
   * 功能：用于解析的搜索规则配置
   */
  source?: SearchRule;
  
  /**
   * 搜索URL
   * 功能：搜索请求的原始URL
   * 默认值：空字符串
   */
  searchUrl: string = '';
  
  /**
   * 初始化方法
   * 功能：设置XML分析所需的数据和配置
   * @param xmlDate - XML分析数据对象
   * 使用场景：开始分析前初始化分析器
   * 效果：设置xmlDate、url、source、searchUrl等属性
   */
  init(xmlDate: XmlAnalysisData) {
    this.xmlDate = xmlDate;
    this.url = xmlDate.searchUrl;
    this.source = this.xmlDate.bookSource?.ruleSearch;
    this.searchUrl = this.xmlDate.searchUrl;
  }

  /**
   * 获取书籍列表
   * 功能：发送解析请求到后端服务器，获取解析后的书籍列表
   * 返回值：Promise<SearchBook[]> - 解析后的书籍列表
   * 使用场景：解析搜索结果，获取结构化的书籍信息
   * 处理流程：
   *   1. 检查是否有搜索规则，如果没有则返回空数组
   *   2. 构建请求数据（body、rule、searchUrl）
   *   3. 设置axios超时时间为5秒
   *   4. 发送POST请求到后端解析API
   *   5. 处理响应数据：
   *      - 设置书籍类型
   *      - 设置书源信息
   *      - 处理相对URL（书籍URL、封面URL）
   *   6. 返回处理后的书籍列表
   */
  async getBookList(): Promise<SearchBook[]> {
    let bookList: SearchBook[] = [];
    if (!this.source) return bookList;
    
    const data: dataRule = {
      body: this.xmlDate.body,
      rule: this.source,
      searchUrl: this.searchUrl
    };
    
    // 设置请求超时时间
    axios.defaults.timeout = 5000;
    
    // 发送解析请求到后端服务器
    let response: AxiosResponse<object> = await axios.post(CommonConstants.BASE_URL + '/search/analysisBook', data);
    
    if (response.data) {
      // 处理解析结果
      bookList = (response.data as SearchBook[]).map(item => {
        // 设置书籍类型
        item.bookType = this.xmlDate.bookSource?.bookSourceType ?? 0;
        // 设置书源信息
        item.source = this.xmlDate.bookSource;
        
        // 处理相对URL：书籍URL
        if (item.bookUrl && !isNetworkUrl(item.bookUrl)) {
          item.tocUrl = this.xmlDate.bookSource?.bookSourceUrl + item.bookUrl;
        }
        
        // 处理相对URL：封面URL
        if (item.coverUrl && !isNetworkUrl(item.coverUrl)) {
          item.coverUrl = this.xmlDate.bookSource?.bookSourceUrl + item.coverUrl;
        }
        
        return item;
      });
    }

    // 调试日志：如果有解析结果则输出日志
    if (bookList.length > 0) {
      console.log('test');
    }
    
    return bookList;
  }

  /**
   * 解析XML
   * 功能：执行XML解析的公共接口方法
   * 返回值：Promise<SearchBook[]> - 解析后的书籍列表
   * 使用场景：外部调用解析功能
   * 实现：直接调用getBookList方法
   */
  async analysisXml(): Promise<SearchBook[]> {
    return await this.getBookList();
  }
}
// const xmlAnalysis = new XmlAnalysis();
// export default xmlAnalysis as XmlAnalysis;

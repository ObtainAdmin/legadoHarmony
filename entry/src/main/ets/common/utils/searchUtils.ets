/**
 * 搜索工具类 - 提供书籍搜索功能的工具类
 * 
 * 功能：封装书籍搜索相关功能，包括书源管理、搜索请求、结果解析等
 * 核心特性：
 *   1. 多书源搜索：支持同时搜索多个启用的书源
 *   2. 分页搜索：支持分页加载更多搜索结果
 *   3. URL解析：使用ParseURLUtils解析书源搜索规则
 *   4. 结果解析：使用XmlAnalysis解析搜索结果
 * 使用场景：书籍搜索页面、书源搜索功能
 */
import { showMessage } from '../../componets/common/promptShow';
import bookSourceDao from '../../database/dao/BookSourceDao';
import { BookSource } from '../../database/entities/BookSource';
import { SearchBook } from '../../database/entities/SearchBook';
import { XmlAnalysis, XmlAnalysisData } from '../model/XmlAnalysis';
import networkUtil from './NetworkUtils';
import { IParseURL, ParseURL, ParseURLUtils } from './ParseURLUtils';
import requestUtil from './requestUtils';

class searchUtils {
  /**
   * 搜索结果列表
   * 功能：存储搜索到的书籍列表
   */
  searchBooks: SearchBook[] = [];
  
  /**
   * 启用的书源列表
   * 功能：存储当前启用的书源，用于并行搜索
   */
  private bookSourceParts: BookSource[] = [];
  
  /**
   * 搜索关键词
   * 功能：当前搜索的关键词
   */
  private searchKey: string = '';
  
  /**
   * 搜索页码
   * 功能：当前搜索的页码，用于分页
   */
  private searchPage: number = 1;
  
  /**
   * 搜索ID
   * 功能：标识当前搜索会话，用于区分不同的搜索请求
   */
  private mSearchId: number = 0;

  /**
   * 搜索书籍
   * 功能：根据关键词搜索书籍，并行搜索所有启用的书源
   * @param searchKey - 搜索关键词
   * 使用场景：用户输入关键词进行书籍搜索
   * 处理流程：
   *   1. 检查搜索关键词是否为空
   *   2. 获取所有启用的书源
   *   3. 检查是否有启用的书源
   *   4. 清空之前的搜索结果
   *   5. 对每个书源并行调用searchData方法进行搜索
   */
  async search(searchKey: string) {
    if (!searchKey) {
      return;
    }
    this.searchKey = searchKey;
    this.bookSourceParts = await bookSourceDao.getEnabledPartByGroup();
    if (!this.bookSourceParts || this.bookSourceParts.length === 0) {
      showMessage('启用书源为空');
      return;
    }
    this.searchBooks = [];
    for (const bookSource of this.bookSourceParts) {
      this.searchData(this.searchKey, Date.now(), bookSource);
    }
  }

  /**
   * 搜索数据
   * 功能：执行单个书源的搜索，管理搜索ID和页码
   * @param searchKey - 搜索关键词
   * @param searchId - 搜索会话ID，用于区分不同的搜索请求
   * @param bookSource - 书源对象
   * 返回值：Promise<SearchBook[]> - 搜索到的书籍列表
   * 使用场景：单个书源的搜索执行
   * 处理流程：
   *   1. 更新搜索关键词
   *   2. 检查搜索ID：如果ID不同，重置页码为1；如果ID相同，页码加1（分页搜索）
   *   3. 调用searchBook方法执行实际搜索
   *   4. 捕获异常，返回空数组
   * 搜索ID机制：用于区分不同的搜索会话，确保分页正确
   */
  async searchData(searchKey: string, searchId: number, bookSource: BookSource): Promise<SearchBook[]> {
    this.searchKey = searchKey;
    if (searchId != this.mSearchId) {
      this.mSearchId = searchId;
      this.searchPage = 1;
    } else {
      this.searchPage++;
    }
    try {
      let book = await this.searchBook(bookSource);
      return book;
    } catch (e) {
      console.log(e.message);
      return [];
    }
  }

  /**
   * 搜索书籍（核心方法）
   * 功能：根据书源配置执行搜索，解析搜索结果
   * @param bookSource - 书源对象，包含搜索URL、规则等配置
   * 返回值：Promise<SearchBook[]> - 搜索到的书籍列表
   * 使用场景：单个书源的具体搜索实现
   * 处理流程：
   *   1. 检查书源搜索URL是否有效
   *   2. 使用ParseURLUtils解析搜索URL，处理分页和关键词替换
   *   3. 构建XmlAnalysisData对象
   *   4. 如果书源有搜索规则（ruleSearch），使用XmlAnalysis解析搜索结果
   *   5. 返回解析后的书籍列表
   * 关键技术：
   *   - ParseURLUtils: 处理书源搜索URL中的变量替换（如${key}、${page}）
   *   - XmlAnalysis: 使用XPath或正则表达式解析HTML/XML响应
   * 注意：当前版本中body获取逻辑被注释，可能需要根据实际需求启用
   */
  async searchBook(bookSource: BookSource): Promise<SearchBook[]> {
    if (!bookSource.searchUrl || bookSource.searchUrl === undefined) {
      throw new Error('搜索url为空');
    }
    let books: SearchBook[] = [];
    let urls = '';
    let body = '';

    // 解析搜索url
    const parseURLUtil = new ParseURLUtils();
    let xmlAnalysis = new XmlAnalysis();
    const parseURLData: IParseURL = {
      page: this.searchPage,
      keyword: this.searchKey,
      baseUrl: bookSource.bookSourceUrl,
      searchUrl: bookSource.searchUrl,
      bookSource: bookSource
    };
    parseURLUtil.setParseURL(new ParseURL(parseURLData));
    let parse = parseURLUtil.processRuleUrl();
    if (typeof parse !== 'string') {
      urls = parse.url;
      // body = await requestUtil.requestHtml(parse);
    } else {
      urls = parse;
      // let res = await requestUtil.requestUrlHtml(parse);
      // if (res === undefined) return [];
      // if (networkUtil.checkContentType(res)) {
      //   console.log('Json数据');
      // }
      // body = res;
    }
    if (bookSource.ruleSearch) {
      xmlAnalysis.init(new XmlAnalysisData({
        baseUrl: parseURLData.baseUrl,
        body: body,
        bookSource: bookSource,
        searchUrl: urls
      }));
      let searchBooks = await xmlAnalysis.analysisXml();
      books.push(...searchBooks);
    }
    return books;
  }
}

const searchUtil = new searchUtils();
export default searchUtil as searchUtils;

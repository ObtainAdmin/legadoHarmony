/**
 * 书籍历史记录工具类 - 管理阅读历史记录的工具类
 * 
 * @author 2008
 * @datetime 2024/8/5 22:30
 * @className: BookHistoryUtils
 * 
 * 功能：提供阅读历史记录的增删改查操作，同步更新书籍的阅读进度
 * 核心特性：
 *   1. 历史记录管理：删除单个或全部历史记录
 *   2. 阅读进度同步：添加历史记录时同步更新书籍的阅读进度
 * 使用场景：阅读历史页面、阅读进度跟踪、历史记录清理
 */
import bookHistoryDao from '../../database/dao/BookHistoryDao';
import { BookHistory } from '../../database/entities/BookHistory';
import { Books } from '../../database/entities/Books';
import booksUtils from './booksUtils';

export class BookHistoryUtils {
  /**
   * 删除单个书籍历史记录
   * 功能：根据书籍ID删除对应的阅读历史记录
   * @param id - 书籍ID
   * 返回值：Promise<void> - 删除操作的结果
   * 使用场景：用户手动删除某本书的阅读历史
   */
  async deleteBookHistory(id: number) {
    return await bookHistoryDao.deleteBookHistory(id);
  }
  
  /**
   * 删除所有书籍历史记录
   * 功能：清空所有阅读历史记录
   * 使用场景：清理所有阅读历史，释放存储空间
   */
  async deleteAllBookHistory() {
    bookHistoryDao.deleteAllBookHistory();
  }
  
  /**
   * 添加书籍历史记录
   * 功能：添加阅读历史记录，并同步更新书籍的阅读进度
   * @param books - 书籍历史记录对象（BookHistory类型）
   * 使用场景：用户阅读书籍后记录阅读进度
   * 处理流程：
   *   1. 将历史记录插入数据库
   *   2. 创建Books对象并设置阅读进度信息：
   *      - 书籍ID
   *      - 当前章节标题
   *      - 最后检查时间（使用历史记录中的章节时间）
   *      - 当前章节索引
   *      - 当前章节时间（使用当前时间戳）
   *   3. 调用booksUtils.partialUpdate部分更新书籍信息
   * 注意：此方法确保历史记录和书籍阅读进度保持同步
   */
  async addBooks(books: BookHistory) {
    // 插入历史记录
    bookHistoryDao.insert(books);
    
    // 创建Books对象并设置阅读进度
    let book = new Books();
    book.id = books.id;  // 书籍ID
    book.durChapterTitle = books.durChapterTitle;  // 当前章节标题
    book.lastCheckTime = books.durChapterTime;  // 最后检查时间
    book.durChapterIndex = books.durChapterIndex;  // 当前章节索引
    book.durChapterTime = Date.now();  // 当前章节时间（使用当前时间戳）
    
    // 部分更新书籍信息
    booksUtils.partialUpdate(book);
  }
}

// 创建单例实例并导出
const bookHistoryUtils = new BookHistoryUtils();
export default bookHistoryUtils as BookHistoryUtils;

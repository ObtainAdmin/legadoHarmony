/**
 * 书籍工具类 - 提供书籍管理的各种工具方法
 * 
 * 功能：封装书籍相关的数据库操作，提供书籍管理的高层接口
 * 核心特性：
 *   1. 书籍置顶：设置或取消书籍置顶状态
 *   2. 书籍添加：添加新书籍到书架
 *   3. 书籍校验：检查书籍是否已存在
 *   4. 批量操作：批量添加、移动、删除书籍
 *   5. 分组管理：与书籍分组工具类协同工作
 * 使用场景：书籍管理页面、批量操作、书籍相关业务逻辑
 */
import BooksDao from '../../database/dao/BooksDao'
import { Books, bookShelfImport, BOOK_SEARCH_TYPE } from '../../database/entities/Books'
import bookGroupUtils from './bookGroupUtils'
import toolsUtils from './ToolsUtils'

class booksUtils {
  /**
   * 置顶书籍
   * 功能：设置或取消书籍的置顶状态
   * @param id - 书籍ID或ID数组
   * @param isTop - 是否置顶（true:置顶, false:取消置顶）
   * 返回值：Promise<boolean> - 操作是否成功
   * 使用场景：书籍列表排序，将重要书籍置顶显示
   */
  async isTopBook(id: number | number[], isTop: boolean): Promise<boolean> {
    let Ids: number[] = toolsUtils.numberArrays(id);
    try {
      Ids.forEach((item: number) => {
        BooksDao.isUpdateBookTop(item, isTop);
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  /**
   * 添加书籍
   * 功能：添加新书籍到书架
   * @param books - 书籍数据对象（Books类型）
   * 使用场景：添加新书籍到书架
   * 处理逻辑：
   *   1. 设置isJoin为true（表示已加入书架）
   *   2. 设置bookGroup，默认为3（未分组）
   *   3. 插入数据库
   */
  async addBooks(books: Books) {
    books.isJoin = true;
    books.bookGroup = books.bookGroup ?? 3; // 默认未分组（分组ID: 3）
    BooksDao.insert(books);
  }
  /**
   * 校验书籍是否存在
   * 功能：检查书籍是否已存在于书架中
   * @param bookUrl - 书籍URL（可选）
   * @param bookName - 书籍名称（可选）
   * 返回值：Promise<boolean> - 书籍是否存在
   * 使用场景：添加书籍前检查是否已存在，避免重复添加
   */
  async isExistBooks(bookUrl?: string, bookName?: string): Promise<boolean> {
    let books: Books[] = await BooksDao.isExistBooks(bookUrl, bookName);
    return books.length > 0;
  }
  /**
   * 部分更新书籍信息
   * 功能：更新书籍的部分字段，而不是全部字段
   * @param books - 包含更新字段的书籍对象
   * 使用场景：更新书籍的阅读进度、最后阅读时间等部分信息
   */
  async partialUpdate(books: Books) {
    BooksDao.partialUpdate(books);
  }
  //批量添加
  async batchAdd(books: bookShelfImport[], bookType:number){
    books.forEach((item:bookShelfImport)=>{
      let book:Books = {
        bookName: item.name,
        bookUrl: item.bookUrl,
        author: item.author,
        intro: item.intro,
        bookGroup: 3,
        latestChapterTime: 0,
        totalChapterNum: 0,
        durChapterIndex: 0,
        durChapterPos: 0,
        durChapterTime: 0,
        canUpdate: false,
        sort: 0,
        originOrder: 0,
        syncTime: 0,
        bookType: bookType,
        isTop: false,
        isJoin: true,
        isLocalBook: false
      }
      BooksDao.insert(book)
    })
  }
  /**
   * @author 2008
   * @param id 需要移动的书籍Id
   * @param group 移动到的分组Id
   * updateBooks 书籍批量移动
   */
  async updateBooks(id:number|number[], group:number){
    let BookGroupId: Record<number, number> = {}
    //循环更新
    let bookId:number[] = toolsUtils.numberArrays(id)
    //根据书籍获取旧的分组Id
    BookGroupId = await BooksDao.getBookIdsByGroupId(bookId)

    if (Object.values(BookGroupId).map(o=>o).length === 0){
      await bookGroupUtils.updateAddBookIds(group, bookId)
    } else {
      bookGroupUtils.updateMoveBookIdsByGroupId(BookGroupId)
      //同时将新的书籍Id添加到分组中
      bookGroupUtils.updateAddBookIds(group, bookId)
    }
    //再去更新新的书籍的分组
    bookId.forEach((item:number)=>{
      BooksDao.updateBookGroup(item,group)
    })
  }

  async delBooksById(id:number|number[]){
    let BookGroupId: Record<number, number> = {}
    let bookId:number[] = toolsUtils.numberArrays(id)
    //根据书籍获取分组Id
    BookGroupId = await BooksDao.getBookIdsByGroupId(bookId)
    if (Object.values(BookGroupId).map(o=>o).length > 0) {
      bookGroupUtils.updateMoveBookIdsByGroupId(BookGroupId)
    }

    BooksDao.deleteBook(bookId)
  }

  async getBookByIds(ids:number|number[]){
    let bookId: number[] = toolsUtils.numberArrays(ids)
    return await BooksDao.getBookByIds(bookId)
  }

  //校验类型数据查询数组内容
  getOrder(type:string){
    return BOOK_SEARCH_TYPE.indexOf(type) ?? 0;
  }
}
let booksUtil = new booksUtils();
export default booksUtil as booksUtils;

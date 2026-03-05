/**
 * 书单工具类 - 管理书单相关功能的工具类
 * 
 * @author 2008
 * @datetime 2024/8/2 0:48
 * @className: worksListsUtils
 * 
 * 功能：封装书单相关的数据库操作，包括书单的增删改查和书籍ID提取
 * 核心特性：
 *   1. 书单管理：添加、更新、删除书单
 *   2. 批量操作：支持批量删除书单
 *   3. 书籍ID提取：从书单中提取书籍ID列表
 * 使用场景：书单管理页面、书单操作、书籍ID处理
 */
import worksListsDao from '../../database/dao/WorksListsDao';
import { WorksBookList } from '../../database/entities/WorksBookList';
import { WorksLists } from '../../database/entities/WorksLists';
import ToolsUtils from './ToolsUtils';

export class WorksListsUtils {
  /**
   * 添加书单
   * 功能：向数据库插入新的书单
   * @param worksLists - 要添加的书单对象
   * 使用场景：用户创建新书单
   * 处理流程：调用worksListsDao.insert方法插入书单
   */
  async addWorksLists(worksLists: WorksLists) {
    worksListsDao.insert(worksLists);
  }

  /**
   * 更新书单
   * 功能：更新数据库中已存在的书单
   * @param worksLists - 要更新的书单对象
   * 使用场景：用户修改书单信息
   * 处理流程：调用worksListsDao.update方法更新书单
   */
  async updateWorksLists(worksLists: WorksLists) {
    worksListsDao.update(worksLists);
  }

  /**
   * 根据ID删除书单
   * 功能：删除一个或多个书单
   * @param id - 书单ID或书单ID数组
   * 使用场景：用户删除书单
   * 处理流程：
   *   1. 使用ToolsUtils.numberArrays将参数统一为数组格式
   *   2. 检查数组是否为空
   *   3. 调用worksListsDao.deleteWorks方法删除书单
   */
  async delWorksByIds(id: number | number[]) {
    let ids = ToolsUtils.numberArrays(id);
    if (ids.length === 0) return;
    worksListsDao.deleteWorks(ids);
  }

  /**
   * 获取书单中的书籍ID
   * 功能：从书单书籍列表中提取所有书籍ID
   * @param worksBookList - 书单书籍列表数组
   * 返回值：number[] - 书籍ID数组
   * 使用场景：获取书单中的所有书籍ID，用于批量操作
   * 处理流程：
   *   1. 过滤掉undefined的项
   *   2. 提取每项的bookId属性
   *   3. 过滤掉undefined的bookId
   *   4. 如果结果为空，返回空数组
   *   5. 将bookId数组转换为逗号分隔的字符串，再分割为数字数组
   * 注意：此方法处理的是逗号分隔的字符串格式的bookId，如"1,2,3"
   */
  getBookIds(worksBookList: WorksBookList[]): number[] {
    const bookIds = worksBookList
      .filter(item => item !== undefined)  // 过滤掉 undefined 的 item
      .map(item => item.bookId)
      .filter(bookId => bookId !== undefined);

    // 如果 bookIds 长度为 0，直接返回空数组
    if (bookIds.length === 0) {
      return [];
    }

    return bookIds.toString().split(',').map(Number);
  }
}

// 创建单例实例并导出
const worksListsUtils = new WorksListsUtils();
export default worksListsUtils;

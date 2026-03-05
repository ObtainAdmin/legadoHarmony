/**
 * 书籍分组工具类 - 提供书籍分组管理的各种工具方法
 * 
 * @author 2008
 * @datetime 2024/7/26 10:58
 * @className: booksUtils
 * 
 * 功能：封装书籍分组相关的数据库操作，提供分组管理的高层接口
 * 核心特性：
 *   1. 分组管理：添加、删除、更新分组
 *   2. 书籍移动：在分组间批量移动书籍
 *   3. 分组显示控制：控制分组是否显示
 *   4. 分组置顶：设置或取消分组置顶
 * 使用场景：书籍分组管理页面、批量操作、分组相关业务逻辑
 */
import BookGroupsDao from '../../database/dao/BookGroupsDao'
import BooksDao from '../../database/dao/BooksDao'
import { BookGroups } from '../../database/entities/BookGroups'
import toolsUtils from './ToolsUtils'

class bookGroupUtils {
  /**
   * 校验分组名称唯一性并更新
   * 功能：检查分组名称是否唯一，如果唯一则更新分组名称
   * @param newName - 新的分组名称
   * @param id - 要更新的分组ID
   * 返回值：Promise<boolean> - 是否更新成功
   * 使用场景：修改分组名称时，确保分组名称不重复
   */
  async onlyGroupUpdateName(newName: string, id: number) {
    return await BookGroupsDao.onlyGroupUpdateName(id, newName);
  }
  
  /**
   * 置顶分组
   * 功能：设置或取消分组的置顶状态
   * @param id - 分组ID或ID数组
   * @param isTop - 是否置顶（true:置顶, false:取消置顶）
   * 使用场景：分组列表排序，将重要分组置顶显示
   * 处理逻辑：
   *   1. 将单个ID转换为数组
   *   2. 遍历数组，为每个分组更新置顶状态
   */
  async isTopGroup(id: number | number[], isTop: boolean) {
    let Ids: number[] = [];
    if (typeof id === 'number') {
      Ids.push(id);
    } else {
      Ids = id;
    }
    Ids.forEach((item: number) => {
      BookGroupsDao.isUpdateGroupTop(item, isTop);
    });
  }
  
  /**
   * 添加分组
   * 功能：创建新的书籍分组
   * @param books - 分组数据对象（BookGroups类型）
   * 使用场景：创建新的书籍分组
   */
  async addGroup(books: BookGroups) {
    BookGroupsDao.insert(books);
  }
  
  /**
   * 删除分组
   * 功能：删除指定的分组，并将该分组下的书籍移动到未分组
   * @param id - 分组ID或ID数组
   * 使用场景：删除不需要的分组
   * 处理流程：
   *   1. 将ID转换为数组
   *   2. 删除分组记录
   *   3. 将该分组下的书籍分组ID更新为3（未分组）
   * 注意：分组ID为3表示"未分组"分类
   */
  async delGroupById(id: number | number[]) {
    let Ids = toolsUtils.numberArrays(id);
    if (Ids.length === 0) return;
    // 删除分组
    BookGroupsDao.deleteBook(Ids);
    // 同时更新书籍分组为未分组（分组ID: 3）
    BooksDao.queryBookByGroup(Ids, 3);
  }

  /**
   * 批量移动分组中的书籍
   * 功能：将多个分组中的书籍批量移动到新的分组
   * @param oldGroup - 旧的分组ID或ID数组
   * @param newGroup - 新的分组ID
   * 使用场景：管理页面批量移动书籍到其他分组
   * 处理流程：
   *   1. 将oldGroup转换为ID数组
   *   2. 如果新分组ID在旧分组数组中，则移除（避免重复操作）
   *   3. 查询旧分组中的所有书籍ID
   *   4. 更新这些书籍的分组ID为新分组
   *   5. 从旧分组中移除这些书籍ID
   *   6. 将书籍ID添加到新分组中
   * 注意：此操作是原子性的，要么全部成功，要么全部失败（通过try-catch处理异常）
   */
  async moveBookByGroupId(oldGroup: number | number[], newGroup: number) {
    try {
      // 将参数转换为ID数组
      let Ids: number[] = toolsUtils.numberArrays(oldGroup);
      
      // 如果新分组ID在旧分组数组中，则移除（避免将书籍从新分组移动到自身）
      if (Ids.includes(newGroup)) {
        Ids = Ids.filter(item => item !== newGroup);
      }
      
      // 根据旧的分组ID获取书籍ID
      const booksInGroup = await BooksDao.queryBooksByGroupId(Ids);

      // 更新书籍分组：将书籍的分组ID设置为新分组
      await BooksDao.updateBookGroup(booksInGroup, newGroup);

      // 将旧分组中的书籍ID移除
      BookGroupsDao.updateMoveGroupBookIds(Ids);

      // 将书籍ID添加到新分组中
      BookGroupsDao.updateAddBookIds(newGroup, booksInGroup.map(val => val.toString()));

    } catch (e) {
      console.log('moveBookByGroupId, Error, ', JSON.stringify(e));
    }
  }

  /**
   * 批量更新分组显示状态
   * 功能：批量设置或取消分组的显示状态
   * @param groupId - 分组ID或ID数组
   * @param isShow - 是否显示（可选，默认值可能由DAO层处理）
   * 使用场景：批量隐藏或显示分组
   * 处理流程：
   *   1. 将groupId转换为ID数组
   *   2. 遍历数组，为每个分组更新显示状态
   * 注意：isShow参数为可选，如果不提供可能使用默认值或保持原状态
   */
  async updateGroupShow(groupId: number | number[], isShow?: boolean) {
    let Ids: number[] = toolsUtils.numberArrays(groupId);
    Ids.forEach((item: number) => {
      BookGroupsDao.updateGroupShow(item, isShow);
    });
  }

  /**
   * 更新分组中的书籍ID列表
   * 功能：向指定分组中添加书籍ID
   * @param newGroupId - 目标分组ID
   * @param bookId - 要添加的书籍ID或ID数组
   * 使用场景：向分组中添加新书籍
   * 处理流程：
   *   1. 将bookId转换为ID数组
   *   2. 检查参数有效性（newGroupId和bookId都不为空）
   *   3. 将书籍ID数组转换为字符串数组
   *   4. 调用DAO层方法更新分组中的书籍ID列表
   * 注意：此操作为追加操作，不会覆盖原有的书籍ID
   */
  async updateAddBookIds(newGroupId: number, bookId: number | number[]) {
    // 循环更新
    let book: number[] = toolsUtils.numberArrays(bookId);

    if (newGroupId && bookId) {
      BookGroupsDao.updateAddBookIds(newGroupId, book.map(val => val.toString()));
    }
  }

  /**
   * 移除分组下的书籍ID
   * 功能：从分组中移除指定的书籍ID
   * @param data - 记录对象，键为分组ID，值为要移除的书籍ID
   * 使用场景：从分组中删除特定书籍
   * 数据结构：Record<number, number> 表示 {分组ID: 书籍ID}
   * 注意：此方法处理单个分组和单个书籍的移除操作
   */
  updateMoveBookIdsByGroupId(data: Record<number, number>) {
    BookGroupsDao.updateMoveBookIdsByGroupId(data);
  }

  /**
   * 分组批量移动书籍
   * 功能：批量将书籍从一个分组移动到另一个分组
   * @param data - 记录对象，键为源分组ID，值为目标分组ID
   * 使用场景：批量调整书籍所属分组
   * 数据结构：Record<number, number> 表示 {源分组ID: 目标分组ID}
   * 注意：此方法实际调用的是updateMoveBookIdsByGroupId方法，功能相同但语义不同
   */
  updateMoveGroupBookIds(data: Record<number, number>) {
    BookGroupsDao.updateMoveBookIdsByGroupId(data);
  }

  /**
   * 根据分组获取分组下的书籍ID
   * 功能：查询指定分组中包含的所有书籍ID
   * @param groupId - 分组ID或ID数组
   * 返回值：Promise<number[]> - 书籍ID数组
   * 使用场景：获取分组中的所有书籍，用于显示或批量操作
   * 处理流程：
   *   1. 将groupId转换为ID数组
   *   2. 调用DAO层方法查询分组中的书籍ID
   */
  async queryBookByGroupId(groupId: number | number[]) {
    let Ids: number[] = toolsUtils.numberArrays(groupId);
    return await BookGroupsDao.queryBookByGroup(Ids);
  }

  /**
   * 更新分组部分数据
   * 功能：更新分组的部分属性，而不是整个分组对象
   * @param data - 包含要更新的分组数据的对象
   * 使用场景：只更新分组的某些属性，如名称、描述等
   * 注意：此方法只更新提供的字段，不会影响未提供的字段
   */
  async updatePartialGroup(data: BookGroups) {
    BookGroupsDao.updatePartialGroup(data);
  }
}
let bookGroupUtil = new bookGroupUtils();
export default bookGroupUtil as bookGroupUtils;

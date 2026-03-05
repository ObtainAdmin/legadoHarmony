/**
 * 任务搜索书籍类 - 使用多线程并行搜索书籍的异步任务管理器
 * 
 * @author 2008
 * @datetime 2024/8/16 20:16
 * @className: taskSearchBook
 * 
 * 功能：管理多线程书籍搜索任务，并行搜索多个书源，提高搜索效率
 * 核心特性：
 *   1. 多线程并行搜索：使用HarmonyOS的taskPool实现多线程并行搜索
 *   2. 动态任务分配：根据书源数量动态分配线程任务
 *   3. 实时结果回调：搜索过程中实时返回结果，提升用户体验
 *   4. 任务取消支持：支持取消正在执行的搜索任务
 * 使用场景：小说搜索功能，需要同时搜索多个书源时使用
 */
import taskPool from '@ohos.taskpool';
import { BookSource } from '../../database/entities/BookSource';
import bookSourceDao from '../../database/dao/BookSourceDao';
import { showMessage } from '../../componets/common/promptShow';
import searchUtil from '../utils/searchUtils';
import { SearchBook } from '../../database/entities/SearchBook';

class taskSearchBook {
  /**
   * 书源分区数组
   * 功能：存储要搜索的书源列表，按线程分区
   * 使用场景：将书源分配给不同的线程进行并行搜索
   */
  private bookSourceParts: BookSource[] = [];
  
  /**
   * 最大线程数
   * 功能：限制同时执行的最大线程数量
   * 使用场景：控制并发度，避免创建过多线程
   * 默认值：5
   */
  MAX_THREADS: number = 5;
  
  /**
   * 任务数组
   * 功能：存储所有创建的taskPool.Task对象
   * 使用场景：管理所有搜索任务，支持取消操作
   */
  tasks: taskPool.Task[] = [];
  
  /**
   * 搜索到的书籍数量
   * 功能：记录当前搜索到的书籍总数
   * 使用场景：显示搜索结果统计信息
   */
  taskSearchBookNumber: number = 0;
  
  /**
   * 搜索开始时间
   * 功能：记录搜索开始的时间戳（毫秒）
   * 使用场景：计算搜索耗时，显示性能信息
   */
  dataStart: number = 0;
  /**
   * 执行多线程搜索
   * 功能：使用多线程并行搜索多个书源，实时返回搜索结果
   * @param searchKey - 搜索关键词
   * @param returnBook - 回调函数，用于实时返回搜索到的书籍
   * @param cancel - 回调函数，搜索完成或取消时调用
   * @param source - 可选的书源数组，如果不提供则从数据库获取启用的书源
   * 返回值：Promise<void> - 搜索执行Promise
   * 使用场景：需要高性能并行搜索的场景
   * 处理流程：
   *   1. 初始化搜索状态：记录开始时间、清空任务数组
   *   2. 获取书源列表：从数据库或参数中获取
   *   3. 计算线程数：根据书源数量动态计算，最多MAX_THREADS个线程
   *   4. 分割书源：将书源平均分配给各个线程
   *   5. 创建任务：为每个线程创建taskPool.Task
   *   6. 设置回调：实时接收搜索结果
   *   7. 执行任务：并行执行所有任务
   *   8. 处理结果：合并所有线程的搜索结果
   *   9. 显示统计：显示搜索耗时和结果数量
   * 线程分配策略：每20个书源分配一个线程，最多5个线程
   */
  async search(searchKey: string, returnBook: (newUrls: SearchBook[]) => void, cancel: () => void, source?: BookSource[]): Promise<void> {
    this.dataStart = Date.now();
    this.tasks = [];
    this.taskSearchBookNumber = 0;
    this.bookSourceParts = [];
    if (!searchKey) {
      return;
    }

    if (!source) {
      this.bookSourceParts = await bookSourceDao.getEnabledPartByGroup();
    } else {
      this.bookSourceParts.push(...source);
    }

    if (!this.bookSourceParts || this.bookSourceParts.length === 0) {
      showMessage('启用书源为空');
      cancel();
      return;
    }

    const numBookSources = this.bookSourceParts.length;
    const numThreads = Math.min(Math.ceil(numBookSources / 20), this.MAX_THREADS);
    // 创建一个回调函数
    const callback = (newUrls: SearchBook[]) => {
      this.taskSearchBookNumber += newUrls.length;
      returnBook(newUrls);
    };

    console.log(`${this.bookSourceParts}`);

    for (let i = 0; i < numThreads; i++) {
      const sourcesSlice = this.bookSourceParts.slice(
        (i * numBookSources) / numThreads,
        ((i + 1) * numBookSources) / numThreads
      );

      const task = new taskPool.Task(
        `搜索${i}`,
        searchTask,
        searchKey, sourcesSlice
      );
      task.onReceiveData(callback);
      this.tasks.push(task);
    }

    try {
      if (this.tasks.length > 0) {
        const results = await Promise.all(this.tasks.map(async (task, index) => {
          console.log(`任务执行中... ${task.name} ${task.isDone()}`);
          try {
            return await taskPool.execute(task, index % 3);
          } catch (e) {
            console.log(e.message);
            return [];
          }
        }));
        const searchBooks = results.flat();
        let dataEnd = Date.now();
        if (this.tasks.length > 0) {
          showMessage(`搜索中止,共搜索到${this.taskSearchBookNumber}个结果` + `用时${(dataEnd - this.dataStart) / 1000}秒`);
        }
        cancel();
      }
    } catch (error) {
      console.error('Error during search:', error);
      cancel();
      showMessage('搜索中止');
    }
  }

  /**
   * 取消所有搜索任务
   * 功能：取消所有正在执行的搜索任务，清理资源
   * 使用场景：用户取消搜索、页面跳转等需要中断搜索的场景
   * 处理流程：
   *   1. 遍历所有任务
   *   2. 检查任务是否已完成
   *   3. 如果任务未完成，调用taskPool.cancel取消任务
   *   4. 显示搜索统计信息
   *   5. 清理任务数组和书源数组
   * 注意：取消操作是异步的，任务可能不会立即停止
   */
  cancelAllTasks() {
    if (this.tasks.length > 0) {
      this.tasks.forEach((task) => {
        console.log(`任务执行中 ${task.name} ${task.isDone()}`);
        if (task.isDone()) {
          return;
        }
        taskPool.cancel(task);
        console.log(`任务已取消 ${task.name} ${task.isDone()}`);
      });
    }
    let dataEnd = Date.now();
    showMessage(`搜索中止,共搜索到${this.taskSearchBookNumber}个结果` + `用时${(dataEnd - this.dataStart) / 1000}秒`);
    this.tasks = [];
    this.taskSearchBookNumber = 0;
    this.bookSourceParts = [];
  }

}

/**
 * 搜索任务函数（并发执行）
 * 功能：在单独的线程中执行搜索任务，处理一组书源
 * @Concurrent 装饰器：标记此函数为并发函数，可以在不同线程中执行
 * @param searchKey - 搜索关键词
 * @param bookSource - 要搜索的书源数组
 * 返回值：Promise<SearchBook[]> - 搜索到的书籍列表
 * 使用场景：taskPool多线程执行环境
 * 处理流程：
 *   1. 遍历书源数组
 *   2. 检查任务是否被取消（taskPool.Task.isCanceled()）
 *   3. 对每个书源调用searchUtil.searchData执行搜索
 *   4. 使用taskPool.Task.sendData实时发送搜索结果
 *   5. 返回所有书源的搜索结果
 * 并发特性：此函数在独立线程中运行，不阻塞主线程
 */
@Concurrent
async function searchTask(searchKey: string, bookSource: BookSource[]): Promise<SearchBook[]> {
  let searchBook: SearchBook[] = [];
  try {
    for (const source of bookSource) {
      if (taskPool.Task.isCanceled()) {
        console.log('任务已取消');
        return [];
      }
      const newUrls = await searchUtil.searchData(searchKey, Date.now(), source);
      if (newUrls.length > 0) {
        searchBook.push(...newUrls);
      }
      taskPool.Task.sendData(newUrls);
    }
    return searchBook;
  } catch (e) {
    console.log(e.message);
    return [];
  }
}
const taskSearchBooks = new taskSearchBook();
export default taskSearchBooks as taskSearchBook;

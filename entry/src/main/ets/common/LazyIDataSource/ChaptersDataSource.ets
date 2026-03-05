/**
 * 章节数据源类 - 专门用于管理小说章节数据的数据源
 * 
 * @author 2008
 * @datetime 2024/7/10 23:25
 * @className: ChaptersDataSource
 * 
 * 功能：继承BasicDataSource，专门用于管理chaptersItem类型的数据，提供章节相关的数据操作
 * 继承关系：ChaptersDataSource → BasicDataSource<chaptersItem>
 * 数据类型：chaptersItem - 小说章节项，包含章节标题、内容、URL等信息
 * 使用场景：小说阅读器的章节列表、目录页面等需要展示和管理章节的UI组件
 * 特性：重写了部分方法以适配章节数据的特定需求
 */
import { chaptersItem } from '../../componets/dataList/ReaderChaptersItem';
import BasicDataSource from './BasicDataSource';

export default class ChaptersDataSource extends BasicDataSource<chaptersItem> {
    /**
     * 章节数据数组
     * 功能：存储章节数据项的数组，实际的数据存储容器
     * 使用场景：所有章节操作都基于此数组
     * 类型：chaptersItem[] - 章节项数组
     * 注意：此数组与父类的originDataArray功能相同，但为了类型安全而单独定义
     */
    private dataArray: chaptersItem[] = [];

    /**
     * 获取数据源总长度
     * 功能：返回当前章节数据数组中元素的数量
     * 返回值：number - 章节数组的长度
     * 使用场景：LazyForEach组件渲染章节列表时获取章节总数
     * 重写说明：重写父类方法，使用子类自己的dataArray
     */
    public totalCount(): number {
      return this.dataArray.length;
    }

    /**
     * 根据下标获取章节数据
     * 功能：通过索引位置获取对应的章节项
     * @param index - 章节索引，从0开始
     * 返回值：chaptersItem - 索引位置的章节项
     * 使用场景：渲染特定章节时获取章节数据
     * 重写说明：重写父类方法，使用子类自己的dataArray
     */
    public getData(index: number): chaptersItem {
      return this.dataArray[index];
    }

    /**
     * 获取列表数据
     * 功能：返回完整的章节数据数组
     * 返回值：chaptersItem[] - 完整的章节数据数组
     * 使用场景：需要获取所有章节数据的场景，如导出、批量处理等
     * 日志：输出当前数据数组的JSON字符串，便于调试
     */
    public getListData(): chaptersItem[] {
      console.log('getListData', JSON.stringify(this.dataArray));
      return this.dataArray;
    }

    /**
     * 添加章节数据
     * 功能：在指定索引位置插入单个章节项
     * @param index - 插入位置的索引
     * @param data - 要插入的章节项
     * 使用场景：在章节列表中间插入新章节
     * 效果：在指定位置插入章节，触发ADD通知
     */
    public addData(index: number, data: chaptersItem): void {
      this.dataArray.splice(index, 0, data);
      this.notifyDataAdd(index);
    }

    /**
     * 推送章节数据
     * 功能：在章节数据数组末尾添加单个章节项
     * @param data - 要添加的章节项
     * 使用场景：添加新章节到列表末尾
     * 效果：在数组末尾添加章节，触发ADD通知
     */
    public pushData(data: chaptersItem): void {
      this.dataArray.push(data);
      this.notifyDataAdd(this.dataArray.length - 1);
    }

    /**
     * 推送所有章节数据
     * 功能：将多个章节项逐个添加到数据数组末尾
     * @param data - 要添加的章节项数组
     * 使用场景：批量添加章节，如从网络加载章节列表后添加
     * 效果：逐个添加章节，每添加一个触发一次ADD通知
     */
    public pushAllData(data: chaptersItem[]): void {
      for (const d of data) {
        this.dataArray.push(d);
        this.notifyDataAdd(this.dataArray.length - 1);
      }
    }

    /**
     * 重新加载新数据
     * 功能：清空现有数据并加载新的章节数据
     * @param data - 新的章节数据数组
     * 使用场景：刷新章节列表、切换书籍时重新加载章节
     * 效果：
     *   1. 清空现有数据数组
     *   2. 逐个添加新数据，每添加一个触发ADD通知
     *   3. 最后触发RELOAD通知，确保UI完全更新
     * 注意：此方法比直接替换数组更优化，可以触发正确的动画效果
     */
    public reloadNewData(data: chaptersItem[]): void {
      this.dataArray = [];
      for (const d of data) {
        this.dataArray.push(d);
        this.notifyDataAdd(this.dataArray.length - 1);
      }
      this.notifyDataReload();
    }
}

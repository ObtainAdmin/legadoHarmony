/**
 * RSS源数据源类 - 专门用于管理RSS源分组数据的数据源
 * 
 * @author 2008
 * @datetime 2024/7/16 00:36
 * @className: rssSourcesDataSource
 * 
 * 功能：继承BasicDataSource，专门用于管理rssGroupList类型的数据，提供RSS源分组相关的数据操作
 * 继承关系：rssSourcesDataSource → BasicDataSource<rssGroupList>
 * 数据类型：rssGroupList - RSS源分组项，包含分组名称、RSS源列表等信息
 * 使用场景：RSS阅读器、订阅源管理、RSS源分组列表等需要展示和管理RSS源的UI组件
 * 特性：重写了部分方法以适配RSS源分组数据的特定需求
 * 注意：类名使用小写开头，不符合TypeScript类命名规范，但为保持与现有代码一致而保留
 */
import { rssGroupList } from '../../database/entities/rssSources';
import BasicDataSource from './BasicDataSource';

export default class rssSourcesDataSource extends BasicDataSource<rssGroupList> {
    /**
     * RSS源分组数据数组
     * 功能：存储RSS源分组数据项的数组，实际的数据存储容器
     * 使用场景：所有RSS源分组操作都基于此数组
     * 类型：rssGroupList[] - RSS源分组项数组
     * 注意：此数组与父类的originDataArray功能相同，但为了类型安全而单独定义
     */
    private dataArray: rssGroupList[] = [];

    /**
     * 获取数据源总长度
     * 功能：返回当前RSS源分组数据数组中元素的数量
     * 返回值：number - RSS源分组数组的长度
     * 使用场景：LazyForEach组件渲染RSS源列表时获取分组总数
     * 重写说明：重写父类方法，使用子类自己的dataArray
     */
    public totalCount(): number {
      return this.dataArray.length;
    }

    /**
     * 根据下标获取RSS源分组数据
     * 功能：通过索引位置获取对应的RSS源分组项
     * @param index - 索引，从0开始
     * 返回值：rssGroupList - 索引位置的RSS源分组项
     * 使用场景：渲染特定RSS源分组时获取其数据
     * 重写说明：重写父类方法，使用子类自己的dataArray
     */
    public getData(index: number): rssGroupList {
      return this.dataArray[index];
    }

    /**
     * 获取列表数据
     * 功能：返回完整的RSS源分组数据数组
     * 返回值：rssGroupList[] - 完整的RSS源分组数据数组
     * 使用场景：需要获取所有RSS源分组数据的场景，如导出、批量处理等
     * 日志：输出当前数据数组的JSON字符串，便于调试
     */
    public getListData(): rssGroupList[] {
      console.log('getListData', JSON.stringify(this.dataArray));
      return this.dataArray;
    }

    /**
     * 添加RSS源分组数据
     * 功能：在指定索引位置插入单个RSS源分组项
     * @param index - 插入位置的索引
     * @param data - 要插入的RSS源分组项
     * 使用场景：在RSS源列表中间插入新分组
     * 效果：在指定位置插入数据，触发ADD通知
     */
    public addData(index: number, data: rssGroupList): void {
      this.dataArray.splice(index, 0, data);
      this.notifyDataAdd(index);
    }

    /**
     * 推送RSS源分组数据
     * 功能：在数据数组末尾添加单个RSS源分组项
     * @param data - 要添加的RSS源分组项
     * 使用场景：添加新RSS源分组到列表末尾
     * 效果：在数组末尾添加数据，触发ADD通知
     */
    public pushData(data: rssGroupList): void {
      this.dataArray.push(data);
      this.notifyDataAdd(this.dataArray.length - 1);
    }

    /**
     * 推送所有RSS源分组数据
     * 功能：将多个RSS源分组项逐个添加到数据数组末尾
     * @param data - 要添加的RSS源分组项数组
     * 使用场景：批量添加RSS源分组，如从网络加载RSS源列表后添加
     * 效果：逐个添加数据，每添加一个触发一次ADD通知
     */
    public pushAllData(data: rssGroupList[]): void {
      for (const d of data) {
        this.dataArray.push(d);
        this.notifyDataAdd(this.dataArray.length - 1);
      }
    }

    /**
     * 重新加载新数据
     * 功能：清空现有数据并加载新的RSS源分组数据
     * @param data - 新的RSS源分组数据数组
     * 使用场景：刷新RSS源列表、重新加载订阅源时重新加载数据
     * 效果：
     *   1. 清空现有数据数组
     *   2. 逐个添加新数据，每添加一个触发ADD通知
     *   3. 最后触发RELOAD通知，确保UI完全更新
     * 注意：此方法比直接替换数组更优化，可以触发正确的动画效果
     */
    public reloadNewData(data: rssGroupList[]): void {
      this.dataArray = [];
      for (const d of data) {
        this.dataArray.push(d);
        this.notifyDataAdd(this.dataArray.length - 1);
      }
      this.notifyDataReload();
    }
}

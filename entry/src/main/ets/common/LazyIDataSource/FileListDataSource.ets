/**
 * 文件夹和文件数据源类 - 专门用于管理文件和文件夹数据的数据源
 * 
 * @author 惟草木之零落兮
 * @date 2024/5/22 20:17
 * 
 * 功能：继承BasicDataSource，专门用于管理FolderAndFileItem类型的数据，提供文件和文件夹相关的数据操作
 * 继承关系：FolderFileDataSource → BasicDataSource<FolderAndFileItem>
 * 数据类型：FolderAndFileItem - 文件和文件夹项，包含名称、路径、类型、大小等信息
 * 使用场景：文件管理器、文件选择器、文件列表等需要展示和管理文件的UI组件
 * 特性：重写了部分方法以适配文件和文件夹数据的特定需求
 */
import BasicDataSource from './BasicDataSource';
import FolderAndFileItem from '../../componets/dataList/FolderAndFileItem';

export default class FolderFileDataSource extends BasicDataSource<FolderAndFileItem> {
    /**
     * 文件和文件夹数据数组
     * 功能：存储文件和文件夹数据项的数组，实际的数据存储容器
     * 使用场景：所有文件和文件夹操作都基于此数组
     * 类型：FolderAndFileItem[] - 文件和文件夹项数组
     * 注意：此数组与父类的originDataArray功能相同，但为了类型安全而单独定义
     */
    private dataArray: FolderAndFileItem[] = [];

    /**
     * 获取数据源总长度
     * 功能：返回当前文件和文件夹数据数组中元素的数量
     * 返回值：number - 文件和文件夹数组的长度
     * 使用场景：LazyForEach组件渲染文件列表时获取文件总数
     * 重写说明：重写父类方法，使用子类自己的dataArray
     */
    public totalCount(): number {
        return this.dataArray.length;
    }

    /**
     * 根据下标获取文件或文件夹数据
     * 功能：通过索引位置获取对应的文件或文件夹项
     * @param index - 索引，从0开始
     * 返回值：FolderAndFileItem - 索引位置的文件或文件夹项
     * 使用场景：渲染特定文件或文件夹时获取其数据
     * 重写说明：重写父类方法，使用子类自己的dataArray
     */
    public getData(index: number): FolderAndFileItem {
        return this.dataArray[index];
    }

    /**
     * 添加文件或文件夹数据
     * 功能：在指定索引位置插入单个文件或文件夹项
     * @param index - 插入位置的索引
     * @param data - 要插入的文件或文件夹项
     * 使用场景：在文件列表中间插入新文件或文件夹
     * 效果：在指定位置插入数据，触发ADD通知
     */
    public addData(index: number, data: FolderAndFileItem): void {
        this.dataArray.splice(index, 0, data);
        this.notifyDataAdd(index);
    }

    /**
     * 推送文件或文件夹数据
     * 功能：在数据数组末尾添加单个文件或文件夹项
     * @param data - 要添加的文件或文件夹项
     * 使用场景：添加新文件或文件夹到列表末尾
     * 效果：在数组末尾添加数据，触发ADD通知
     */
    public pushData(data: FolderAndFileItem): void {
        this.dataArray.push(data);
        this.notifyDataAdd(this.dataArray.length - 1);
    }

    /**
     * 推送所有文件或文件夹数据
     * 功能：将多个文件或文件夹项逐个添加到数据数组末尾
     * @param data - 要添加的文件或文件夹项数组
     * 使用场景：批量添加文件或文件夹，如扫描目录后添加文件列表
     * 效果：逐个添加数据，每添加一个触发一次ADD通知
     */
    public pushAllData(data: FolderAndFileItem[]): void {
        for (const d of data) {
            this.dataArray.push(d);
            this.notifyDataAdd(this.dataArray.length - 1);
        }
    }

    /**
     * 重新加载新数据
     * 功能：清空现有数据并加载新的文件和文件夹数据
     * @param data - 新的文件和文件夹数据数组
     * 使用场景：刷新文件列表、切换目录时重新加载文件
     * 效果：
     *   1. 清空现有数据数组
     *   2. 逐个添加新数据，每添加一个触发ADD通知
     *   3. 最后触发RELOAD通知，确保UI完全更新
     * 注意：此方法比直接替换数组更优化，可以触发正确的动画效果
     */
    public reloadNewData(data: FolderAndFileItem[]): void {
        this.dataArray = [];
        for (const d of data) {
            this.dataArray.push(d);
            this.notifyDataAdd(this.dataArray.length - 1);
        }
        this.notifyDataReload();
    }
}

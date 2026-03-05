/**
 * 基础数据源类 - 泛型数据源实现，用于管理数据数组并提供数据变更通知
 * 
 * @author 惟草木之零落兮
 * @date 2024/5/22 20:10
 * 
 * 功能：实现IDataSource接口，为LazyForEach组件提供数据源支持，管理数据数组的增删改查操作
 * 泛型参数：T - 数据项类型，可以是任意类型（对象、基本类型等）
 * 核心特性：
 *   1. 数据管理：提供完整的数据增删改查操作方法
 *   2. 变更通知：自动通知监听器数据变化，触发UI更新
 *   3. 类型安全：使用TypeScript泛型确保类型安全
 *   4. 错误处理：对越界操作进行安全检查并抛出错误
 * 使用场景：作为LazyForEach组件的数据源，用于列表、网格等需要动态数据更新的UI组件
 */
export default class BasicDataSource<T> implements IDataSource {
    /**
     * 数据变更监听器数组
     * 功能：存储所有注册的数据变更监听器
     * 使用场景：当数据发生变化时，通知所有监听器更新UI
     * 类型：DataChangeListener[] - 数据变更监听器接口数组
     */
    private listeners: DataChangeListener[] = [];
    
    /**
     * 原始数据数组
     * 功能：存储实际的数据项
     * 使用场景：所有数据操作都基于此数组
     * 类型：T[] - 泛型数组，存储类型为T的数据项
     */
    private originDataArray: T[] = [];

    /**
     * 获取数据源总长度
     * 功能：返回当前数据数组中元素的数量
     * 返回值：number - 数据数组的长度，如果数组为空则返回0
     * 使用场景：LazyForEach组件需要知道数据总数来渲染对应数量的子组件
     */
    public totalCount(): number {
        return this.originDataArray.length ?? 0;
    }
    
    /**
     * 根据下标获取数据
     * 功能：通过索引位置获取对应的数据项
     * @param index - 数据索引，从0开始
     * 返回值：T - 索引位置的数据项
     * 使用场景：LazyForEach组件渲染每个子组件时获取对应数据
     * 注意：不进行越界检查，调用者需确保索引有效
     */
    public getData(index: number): T {
        return this.originDataArray[index];
    }

    /**
     * 获取原始数据数组
     * 功能：返回内部存储的原始数据数组的引用
     * 返回值：T[] - 原始数据数组
     * 使用场景：需要直接操作原始数据数组的高级场景
     * 注意：返回的是数组引用，直接修改会影响数据源状态
     */
    public getOriginDataArray(): T[] {
        return this.originDataArray;
    }

    /**
     * 清空数据
     * 功能：清空所有数据并通知监听器重新加载
     * 使用场景：重置数据源、清除所有数据
     * 效果：originDataArray变为空数组，触发RELOAD通知
     */
    public clear() {
        this.originDataArray = [];
        this.notifyDataReload();
    }

    /**
     * 插入指定位置数据
     * 功能：在指定索引位置插入单个数据项
     * @param index - 插入位置的索引，0表示第一个位置，length表示末尾
     * @param data - 要插入的数据项
     * 使用场景：在列表中间插入新项
     * 异常：如果索引越界（小于0或大于数组长度）则抛出错误
     * 效果：在指定位置插入数据，触发ADD通知
     */
    public addSpecifyIndexData(index: number, data: T): void {
        if (index < 0 || index > this.originDataArray.length) {
            throw new Error("Index out of bounds");
        }
        this.originDataArray.splice(index, 0, data);
        this.notifyDataAdd(index);
    }

    /**
     * 全量数据添加
     * 功能：将数组中的所有数据项逐个添加到数据源末尾
     * @param data - 要添加的数据项数组
     * 使用场景：批量添加数据，如从网络加载数据后添加到列表
     * 效果：逐个添加数据，每添加一个触发一次ADD通知
     */
    public pushAllData(data: T[]): void {
        for (const d of data) {
            this.originDataArray.push(d);
            this.notifyDataAdd(this.originDataArray.length - 1);
        }
    }
    
    /**
     * 追加数据
     * 功能：在数据数组末尾添加单个数据项
     * @param data - 要追加的数据项
     * 使用场景：添加新项到列表末尾
     * 效果：在数组末尾添加数据，触发ADD通知
     */
    public appendData(data: T): void {
        this.originDataArray.push(data);
        this.notifyDataAdd(this.originDataArray.length - 1);
    }

    /**
     * 删除指定索引的数据
     * 功能：删除指定索引位置的数据项
     * @param index - 要删除的数据索引，从0开始
     * 使用场景：删除列表中的特定项
     * 异常：如果索引越界（小于0或大于等于数组长度）则抛出错误
     * 效果：删除指定位置的数据，触发DELETE通知
     */
    public deleteData(index: number): void {
        if (index < 0 || index >= this.originDataArray.length) {
            throw new Error("Index out of bounds");
        }
        this.originDataArray.splice(index, 1);
        this.notifyDataDelete(index);
    }

    /**
     * 移动数据到指定索引
     * 功能：将数据从一个位置移动到另一个位置
     * @param from - 源位置索引，要移动的数据当前位置
     * @param to - 目标位置索引，数据要移动到的位置
     * 使用场景：拖拽排序、调整数据顺序
     * 异常：如果任一索引越界则抛出错误
     * 效果：数据位置发生变化，触发MOVE通知
     */
    public moveData(from: number, to: number): void {
        if (from < 0 || from >= this.originDataArray.length || to < 0 || to >= this.originDataArray.length) {
            throw new Error("Index out of bounds");
        }
        const data = this.originDataArray[from];
        this.originDataArray.splice(from, 1);
        this.originDataArray.splice(to, 0, data);
        this.notifyDataMoveOperation(from, to);
    }

    /**
     * 移动并更新数据
     * 功能：将数据从一个位置移动到另一个位置，并用新数据替换
     * @param from - 源位置索引，要移动的数据当前位置
     * @param to - 目标位置索引，数据要移动到的位置
     * @param newData - 新数据，用于替换移动的数据
     * 使用场景：拖拽排序同时更新数据内容
     * 异常：如果任一索引越界则抛出错误
     * 效果：数据位置和内容都发生变化，触发MOVE通知
     */
    public moveDataUpdate(from: number, to: number, newData: T): void {
        if (from < 0 || from >= this.originDataArray.length || to < 0 || to >= this.originDataArray.length) {
            throw new Error("Index out of bounds");
        }
        const data = this.originDataArray[from];
        this.originDataArray.splice(from, 1);
        this.originDataArray.splice(to, 0, newData);
        this.notifyDataMoveOperation(from, to);
    }

    /**
     * 向数组第一个位置插入数据
     * 功能：在数据数组的开头插入数据项
     * @param data - 要插入的数据项
     * 使用场景：添加新项到列表开头
     * 效果：在数组开头插入数据，触发ADD通知（索引0）
     */
    public unshiftData(data: T): void {
        this.originDataArray.unshift(data);
        this.notifyDataAdd(0);
    }

    /**
     * 翻转数组
     * 功能：反转数据数组中元素的顺序
     * 使用场景：倒序显示列表
     * 效果：数组元素顺序反转，触发RELOAD通知（需要重新加载所有项）
     */
    public reverseData(): void {
        this.originDataArray.reverse();
        this.notifyDataReload();
    }

    /**
     * 数组按照指定的规则排序
     * 功能：使用自定义比较函数对数据数组进行排序
     * @param compareFn - 比较函数，接受两个参数a和b，返回负数表示a在b前，正数表示a在b后，0表示相等
     * 使用场景：对列表进行排序（按时间、字母、数字等）
     * 效果：数组按指定规则排序，触发RELOAD通知（需要重新加载所有项）
     */
    public sortData(compareFn: (a: T, b: T) => number): void {
        this.originDataArray.sort(compareFn);
        this.notifyDataReload();
    }

    /**
     * 追加多条数据
     * 功能：将多个数据项逐个追加到数据数组末尾
     * @param dataList - 要追加的数据项数组
     * 使用场景：批量添加数据到列表末尾
     * 效果：逐个追加数据，最后触发一次RELOAD通知（优化性能，避免多次单独通知）
     */
    public appendDataList(dataList: T[]): void {
        dataList.forEach(data => {
            this.appendData(data)
        })
        this.notifyDataReload();
    }

    /**
     * 插入多条数据
     * 功能：在指定索引位置插入多个数据项
     * @param index - 插入位置的起始索引
     * @param dataList - 要插入的数据项数组
     * 使用场景：批量在列表中间插入数据
     * 异常：如果索引越界则抛出错误
     * 效果：在指定位置插入多个数据，每个数据插入都会触发ADD通知
     */
    public insertDataList(index: number, dataList: T[]): void {
        if (index < 0 || index > this.originDataArray.length) {
            throw new Error("Index out of bounds");
        }
        dataList.forEach(data => {
            this.addSpecifyIndexData(index, data)
        })
    }

    /**
     * 修改指定索引的数据
     * 功能：更新指定索引位置的数据项内容
     * @param index - 要修改的数据索引
     * @param data - 新的数据项
     * 使用场景：更新列表项的内容
     * 效果：替换指定位置的数据，触发CHANGE通知
     */
    public changeData(index: number, data: T): void {
        this.originDataArray[index] = data;
        this.notifyDataChange(index);
    }

    /**
     * 获取数据下标
     * 功能：查找数据项在数组中的索引位置
     * @param data - 要查找的数据项
     * 返回值：number - 数据项的索引，如果未找到则返回-1
     * 使用场景：根据数据内容查找其在列表中的位置
     * 注意：使用JSON.stringify进行深度比较，可能对复杂对象有性能影响
     */
    public getIndex(data: T): number {
        return this.originDataArray.findIndex((item) => {
            return JSON.stringify(item) === JSON.stringify(data);
        });
    }

    /**
     * 注册数据变更监听器（框架侧调用）
     * 功能：为LazyForEach组件添加数据变更监听器
     * @param listener - 数据变更监听器接口实例
     * 使用场景：LazyForEach组件初始化时注册监听，以便接收数据变更通知
     * 注意：此方法由HarmonyOS框架自动调用，通常不需要手动调用
     */
    registerDataChangeListener(listener: DataChangeListener): void {
        if (this.listeners.indexOf(listener) < 0) {
            console.info('add listener');
            this.listeners.push(listener);
        }
    }

    /**
     * 注销数据变更监听器（框架侧调用）
     * 功能：为对应的LazyForEach组件移除数据变更监听器
     * @param listener - 要移除的数据变更监听器接口实例
     * 使用场景：LazyForEach组件销毁时注销监听，避免内存泄漏
     * 注意：此方法由HarmonyOS框架自动调用，通常不需要手动调用
     */
    unregisterDataChangeListener(listener: DataChangeListener): void {
        const pos = this.listeners.indexOf(listener);
        if (pos >= 0) {
            console.info('remove listener');
            this.listeners.splice(pos, 1);
        }
    }

    /**
     * 通知数据重新加载
     * 功能：通知所有监听器数据已完全变化，需要重新加载所有子组件
     * 使用场景：清空数据、翻转数组、排序等导致整个数据数组变化的情况
     * 效果：触发DataOperationType.RELOAD操作，LazyForEach会重新渲染所有项
     */
    notifyDataReload(): void {
        this.listeners.forEach(listener => {
            listener.onDatasetChange([{type: DataOperationType.RELOAD}]);
        })
    }

    /**
     * 通知数据添加
     * 功能：通知所有监听器在指定索引位置添加了新数据
     * @param index - 新数据添加的索引位置
     * 使用场景：追加数据、插入数据等添加操作
     * 效果：触发DataOperationType.ADD操作，LazyForEach会在指定位置添加新项
     */
    notifyDataAdd(index: number): void {
        this.listeners.forEach(listener => {
            listener.onDatasetChange([{type: DataOperationType.ADD, index: index}]);
        })
    }

    /**
     * 通知数据变更
     * 功能：通知所有监听器指定索引位置的数据内容已发生变化
     * @param index - 数据发生变化的索引位置
     * 使用场景：修改数据内容
     * 效果：触发DataOperationType.CHANGE操作，LazyForEach会重建指定位置的项
     */
    notifyDataChange(index: number): void {
        this.listeners.forEach(listener => {
            listener.onDatasetChange([{type: DataOperationType.CHANGE, index: index}])
            // listener.onDataChange(index); // 旧版API，已弃用
        })
    }

    /**
     * 通知数据删除
     * 功能：通知所有监听器指定索引位置的数据已被删除
     * @param index - 数据被删除的索引位置
     * 使用场景：删除数据项
     * 效果：触发DataOperationType.DELETE操作，LazyForEach会移除指定位置的项
     */
    notifyDataDelete(index: number): void {
        this.listeners.forEach(listener => {
            listener.onDatasetChange([{type: DataOperationType.DELETE, index: index}])
            // listener.onDataDelete(index); // 旧版API，已弃用
        })
    }

    /**
     * 通知数据移动操作
     * 功能：通知所有监听器数据位置已发生变化（从旧位置移动到新位置）
     * @param oldIndex - 数据原来的索引位置
     * @param newIndex - 数据移动后的新索引位置
     * 使用场景：移动数据、拖拽排序
     * 效果：触发DataOperationType.MOVE操作，LazyForEach会移动指定位置的项
     */
    notifyDataMoveOperation(oldIndex: number, newIndex: number): void {
        this.listeners.forEach(listener => {
            listener.onDatasetChange([{type: DataOperationType.MOVE, index: {from: oldIndex, to: newIndex}}])
        })
    }
}

/**
 * 数据偏好设置工具类 - 管理应用轻量级数据存储的工具类
 * 
 * 功能：封装HarmonyOS的dataPreferences API，提供简单的键值对数据存储
 * 核心特性：
 *   1. 单例模式：通过static shared属性提供全局访问
 *   2. 懒加载：首次使用时初始化preferences实例
 *   3. 线程安全：使用同步方法确保数据一致性
 *   4. 自动持久化：设置数据后自动调用flush保存到磁盘
 * 使用场景：应用配置存储、用户偏好设置、临时数据缓存
 */
import CommonConstants from '../constants/CommonConstants';
import dataPreferences from '@ohos.data.preferences';

// 获取应用上下文
let context = getContext(this);

export default class bookDataPreferences {
  /**
   * 单例实例
   * 功能：提供全局唯一的bookDataPreferences实例
   * 使用场景：在整个应用中共享同一个数据存储实例
   */
  static shared = new bookDataPreferences();
  
  /**
   * preferences实例
   * 功能：dataPreferences.Preferences对象，用于实际的数据操作
   * 注意：使用懒加载，首次使用时通过initPreferences()初始化
   */
  preferences?: dataPreferences.Preferences;
  
  /**
   * 偏好设置名称
   * 功能：标识数据存储的文件名
   * 默认值：CommonConstants.PREFERENCES_BOOK_DATA_KEY（书籍数据键）
   */
  preferencesName: string = CommonConstants.PREFERENCES_BOOK_DATA_KEY;

  /**
   * 初始化preferences实例
   * 功能：创建或获取preferences实例
   * 使用场景：首次使用数据存储时自动调用
   * 实现：使用dataPreferences.getPreferencesSync同步获取preferences实例
   */
  initPreferences() {
    this.preferences = dataPreferences.getPreferencesSync(context, { name: this.preferencesName });
  }

  /**
   * 设置数据
   * 功能：存储键值对数据
   * @param key - 数据键名
   * @param value - 数据值（支持dataPreferences.ValueType类型）
   * 处理流程：
   *   1. 检查preferences实例是否存在，不存在则初始化
   *   2. 输出调试日志
   *   3. 使用putSync同步存储数据
   *   4. 调用flush立即将数据持久化到磁盘
   */
  set(key: string, value: dataPreferences.ValueType) {
    if (!this.preferences) {
      this.initPreferences();
    }
    console.log('setinitPreferences', key, value);
    this.preferences?.putSync(key, value);
    this.preferences?.flush();
  }

  /**
   * 获取数据
   * 功能：根据键名获取存储的数据
   * @param key - 数据键名
   * 返回值：dataPreferences.ValueType | null | undefined - 存储的数据值，不存在时返回null
   * 处理流程：
   *   1. 检查preferences实例是否存在，不存在则初始化
   *   2. 使用getSync同步获取数据，默认值为null
   */
  get(key: string): dataPreferences.ValueType | null | undefined {
    if (!this.preferences) {
      this.initPreferences();
    }
    let value = this.preferences?.getSync(key, null);
    return value;
  }

  /**
   * 删除数据
   * 功能：删除指定键名的数据
   * @param key - 要删除的数据键名
   * 处理流程：
   *   1. 检查preferences实例是否存在，不存在则初始化
   *   2. 检查键名是否存在
   *   3. 如果存在，使用deleteSync同步删除数据
   *   4. 调用flush立即将更改持久化到磁盘
   */
  delete(key: string) {
    if (!this.preferences) {
      this.initPreferences();
    }
    if (this.preferences?.hasSync(key)) {
      this.preferences.deleteSync(key);
      this.preferences.flush();
    }
  }
}

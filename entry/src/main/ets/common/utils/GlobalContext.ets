/**
 * 全局上下文类 - 提供全局对象存储和访问的单例类
 * 
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * 功能：提供全局对象的存储和访问机制，使用单例模式确保全局唯一性
 * 核心特性：
 *   1. 单例模式：确保整个应用中只有一个GlobalContext实例
 *   2. 键值存储：使用Map结构存储全局对象
 *   3. 类型安全：支持TypeScript类型检查
 * 使用场景：跨页面/组件共享数据、全局配置管理、服务对象存储
 */
export class GlobalContext {
  /**
   * 私有构造函数
   * 功能：防止外部直接实例化，确保单例模式
   */
  private constructor() { }
  
  /**
   * 单例实例
   * 功能：存储GlobalContext的唯一实例
   * 注意：使用静态属性，确保类级别唯一性
   */
  private static instance: GlobalContext;
  
  /**
   * 对象存储Map
   * 功能：使用键值对存储全局对象
   * 键：string类型，对象的标识符
   * 值：Object类型，存储的全局对象
   */
  private _objects = new Map<string, Object>();

  /**
   * 获取全局上下文实例
   * 功能：提供全局唯一的GlobalContext实例（懒汉式单例）
   * 返回值：GlobalContext - 全局上下文实例
   * 使用场景：需要访问全局对象时调用此方法获取实例
   * 实现：如果实例不存在则创建，存在则直接返回
   */
  public static getContext(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  /**
   * 获取对象
   * 功能：根据键名获取存储的全局对象
   * @param value - 对象的键名
   * 返回值：Object | undefined - 存储的对象，如果不存在则返回undefined
   * 使用场景：根据键名获取之前存储的全局对象
   */
  getObject(value: string): Object | undefined {
    return this._objects.get(value);
  }

  /**
   * 设置对象
   * 功能：将对象存储到全局上下文中
   * @param key - 对象的键名，用于后续检索
   * @param objectClass - 要存储的对象
   * 使用场景：将需要全局共享的对象存储到全局上下文中
   */
  setObject(key: string, objectClass: Object): void {
    this._objects.set(key, objectClass);
  }
}

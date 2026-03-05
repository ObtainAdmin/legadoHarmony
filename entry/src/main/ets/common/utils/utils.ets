/**
 * 通用工具函数集合 - 提供各种常用工具函数的模块
 * 
 * 功能：封装各种常用的工具函数，包括粘贴板操作、URL判断、延迟函数、去重、JSON处理等
 * 核心特性：
 *   1. 粘贴板操作：获取系统粘贴板内容
 *   2. URL判断：判断URL是否为网络链接
 *   3. 异步延迟：提供sleep函数用于延迟执行
 *   4. 数据去重：去除对象数组中的重复项
 *   5. JSON处理：JSON字符串验证和解析
 *   6. 字符串处理：判断字符串是否为空或空白
 *   7. Gson类：JSON序列化和反序列化工具
 * 使用场景：通用工具函数，可在任何需要的地方使用
 */
import { unifiedDataChannel } from '@kit.ArkData';
import { pasteboard } from '@kit.BasicServicesKit';

/**
 * 获取粘贴板数据（同步）
 * 功能：同步获取系统粘贴板中的文本内容
 * 返回值：string | undefined - 粘贴板中的文本内容，如果获取失败则返回undefined
 * 使用场景：获取用户复制的文本内容，如URL、文本等
 * 处理流程：
 *   1. 获取系统粘贴板实例
 *   2. 同步获取统一数据
 *   3. 获取第一条记录（假设为纯文本）
 *   4. 返回文本内容
 * 注意事项：如果粘贴板中没有内容或获取失败，返回undefined
 */
export const getPasteDataSync = (): string | undefined => {
  try {
    const data = pasteboard.getSystemPasteboard().getUnifiedDataSync();
    let records = data.getRecords();
    let record = records[0] as unifiedDataChannel.PlainText;
    return record.textContent;
  } catch (e) {
    console.error(`获取失败：${e}`);
    return undefined;
  }
};

/**
 * 判断是否为网络URL
 * 功能：判断URL是否以http://或https://开头
 * @param url - 要判断的URL字符串
 * 返回值：boolean - 如果是网络URL返回true，否则返回false
 * 使用场景：判断链接是否为网络链接，用于决定是否进行网络请求
 */
export const isNetworkUrl = (url: string): boolean => {
  return url.startsWith('http://') || url.startsWith('https://');
};

/**
 * 延迟函数
 * 功能：创建一个延迟指定时间的Promise
 * @param duration - 延迟时间（毫秒），默认1000毫秒
 * 返回值：Promise<void> - 延迟结束后解析的Promise
 * 使用场景：需要延迟执行的场景，如动画、等待操作
 * 示例：await sleep(2000); // 延迟2秒
 */
export const sleep = (duration: number = 1000): Promise<void> => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve();
    }, duration);
  });
};

/**
 * 去除对象数组中的重复项
 * 功能：通过JSON序列化去除对象数组中的重复对象
 * @param list - 要去重的对象数组
 * 返回值：T[] - 去重后的对象数组
 * 使用场景：处理包含重复对象的数组，确保每个对象唯一
 * 处理原理：
 *   1. 将每个对象序列化为JSON字符串
 *   2. 使用Set去除重复的JSON字符串
 *   3. 将去重后的JSON字符串反序列化为对象
 * 注意事项：对象顺序可能改变，因为Set不保证顺序
 */
export const deduplicateObjects = <T>(list: T[]): T[] => {
  const uniqueSet = new Set(list.map(item => JSON.stringify(item)));
  return Array.from(uniqueSet).map(strItem => JSON.parse(strItem) as T);
};

/**
 * 判断是否为有效的JSON字符串
 * 功能：验证字符串是否为有效的JSON格式
 * @param json - 要验证的字符串
 * 返回值：boolean - 如果是有效的JSON返回true，否则返回false
 * 使用场景：验证用户输入或网络响应是否为有效的JSON
 */
export const isJson = (json: string): boolean => {
  try {
    JSON.parse(json);
    return true;
  } catch (e) {
    return false;
  }
};

/**
 * 判断字符串是否为空或空白
 * 功能：判断字符串是否为null、undefined或只包含空白字符
 * @param value - 要判断的字符串
 * 返回值：boolean - 如果为空或空白返回true，否则返回false
 * 使用场景：验证用户输入是否为空
 * 处理逻辑：
 *   1. 检查是否为null或undefined
 *   2. 去除空白字符后检查长度是否为0
 */
export const isNullOrBlank = (value: string | null | undefined): boolean => {
  return value == null || value.trim().length === 0;
};

/**
 * 判断是否为绝对URL
 * 功能：判断URL是否以http://或https://开头（与isNetworkUrl功能相同）
 * @param url - 要判断的URL字符串
 * 返回值：boolean - 如果是绝对URL返回true，否则返回false
 * 使用场景：判断链接是否为绝对路径
 * 注意：此函数与isNetworkUrl功能相同，可能是为了保持兼容性或不同语义
 */
export const isAbsUrl = (url: string): boolean => {
  return url.startsWith('http://') || url.startsWith('https://');
};

/**
 * Gson类 - JSON序列化和反序列化工具类
 * 
 * 功能：提供类型安全的JSON序列化和反序列化方法
 * 核心特性：
 *   1. toString: 将对象序列化为JSON字符串
 *   2. toJson: 将JSON字符串反序列化为对象
 *   3. 类型安全：使用泛型确保类型安全
 *   4. 容错处理：处理空值和解析错误
 * 使用场景：JSON数据处理，类型安全的序列化/反序列化
 */
class Gson {
  /**
   * 对象转JSON字符串
   * 功能：将对象序列化为JSON字符串
   * @param info - 要序列化的对象
   * 返回值：string | undefined - JSON字符串，如果输入为空则返回undefined
   * 使用场景：将对象转换为JSON字符串进行存储或传输
   */
  toString<T>(info?: T): string | undefined {
    if (!info) {
      return undefined;
    }
    return JSON.stringify(info);
  }

  /**
   * JSON字符串转对象
   * 功能：将JSON字符串反序列化为对象
   * @param json - 要反序列化的JSON字符串
   * 返回值：T | undefined - 反序列化的对象，如果输入为空或解析失败则返回undefined
   * 使用场景：将JSON字符串转换为对象进行处理
   * 容错处理：如果解析失败，返回undefined而不是抛出异常
   */
  toJson<T>(json?: string): T | undefined {
    if (!json) {
      return undefined;
    }
    try {
      return JSON.parse(json) as T;
    } catch (error) {
      return undefined;
    }
  }
}

// 创建并导出Gson单例实例
export const GSON = new Gson();

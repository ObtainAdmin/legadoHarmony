/**
 * 通用工具类 - 提供常用工具方法的工具类
 * 
 * @author 2008
 * @datetime 2024/7/29 12:44
 * @className: ToolsUtils
 * 
 * 功能：封装常用的工具方法，包括类型转换、时间判断等
 * 核心特性：
 *   1. 类型转换：将数字或字符串转换为数组
 *   2. 时间判断：判断时间是否在24小时内
 *   3. 简单易用：提供简洁的API接口
 * 使用场景：数据处理、类型转换、时间判断
 */
export class ToolsUtils {
  /**
   * 数字转换数组
   * 功能：将数字或数字数组统一转换为数字数组
   * @param ids - 数字或数字数组
   * 返回值：number[] - 转换后的数字数组
   * 使用场景：处理可能为单个数字或多个数字的参数，统一为数组格式
   * 处理逻辑：
   *   1. 如果参数是数字，创建包含该数字的数组
   *   2. 如果参数已经是数组，直接返回
   * 示例：
   *   - 输入：5 → 输出：[5]
   *   - 输入：[1, 2, 3] → 输出：[1, 2, 3]
   */
  numberArrays(ids: number | number[]): number[] {
    let Ids: number[] = [];
    if (typeof ids === 'number') {
      Ids.push(ids);
    } else {
      Ids = ids;
    }
    return Ids;
  }

  /**
   * 字符串转换数组
   * 功能：将字符串或字符串数组统一转换为字符串数组
   * @param ids - 字符串或字符串数组
   * 返回值：string[] - 转换后的字符串数组
   * 使用场景：处理可能为单个字符串或多个字符串的参数，统一为数组格式
   * 处理逻辑：
   *   1. 如果参数是字符串，创建包含该字符串的数组
   *   2. 如果参数已经是数组，直接返回
   * 示例：
   *   - 输入："hello" → 输出：["hello"]
   *   - 输入：["a", "b", "c"] → 输出：["a", "b", "c"]
   */
  stringArrays(ids: string | string[]): string[] {
    let Ids: string[] = [];
    if (typeof ids === 'string') {
      Ids.push(ids);
    } else {
      Ids = ids;
    }
    return Ids;
  }

  /**
   * 判断是否是24小时内
   * 功能：判断给定时间戳是否在当前时间的24小时内
   * @param lastTime - 要判断的时间戳（毫秒）
   * 返回值：boolean - 如果时间在24小时内返回true，否则返回false
   * 使用场景：判断内容是否新鲜、是否在有效期内
   * 计算逻辑：
   *   1. 计算当前时间与给定时间的时间差（毫秒）
   *   2. 将毫秒转换为小时（除以1000 * 60 * 60）
   *   3. 判断时间差是否小于等于24小时
   * 公式：(当前时间 - 给定时间) / (1000 * 60 * 60) <= 24
   */
  is24Hour(lastTime: number): boolean {
    return (new Date().getTime() - lastTime) / (1000 * 60 * 60) <= 24;
  }
}

// 创建单例实例并导出
const toolsUtils = new ToolsUtils();
export default toolsUtils as ToolsUtils;

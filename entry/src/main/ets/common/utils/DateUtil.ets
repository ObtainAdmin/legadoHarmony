/**
 * 时间工具类 - 提供时间格式化和处理功能
 * 
 * Copyright (C), 2024-05-13
 * @author LinXun
 * @date 2024/5/13 15:31
 * @version 1.0
 * 
 * 功能：封装时间处理相关功能，提供统一的时间格式化接口
 * 核心特性：
 *   1. 时间格式化：将时间戳格式化为易读的字符串
 *   2. 补零处理：自动为个位数的月、日、时、分补零
 *   3. 标准格式：输出"YYYY-MM-DD HH:MM"格式的时间字符串
 * 使用场景：显示书籍更新时间、阅读历史时间、日志时间等
 */
class DateUtil {
  /**
   * 格式化时间
   * 功能：将时间戳格式化为"YYYY-MM-DD HH:MM"格式的字符串
   * @param num - 时间戳（毫秒数）
   * 返回值：string - 格式化后的时间字符串，格式为"YYYY-MM-DD HH:MM"
   * 使用场景：显示时间信息，如书籍最后更新时间、阅读记录时间等
   * 处理流程：
   *   1. 创建Date对象
   *   2. 提取年、月、日、时、分
   *   3. 对月、日、时、分进行补零处理（个位数前补0）
   *   4. 拼接为"YYYY-MM-DD HH:MM"格式的字符串
   * 示例：
   *   - 输入：1715587200000（2024年5月13日 15:31）
   *   - 输出："2024-05-13 15:31"
   */
  formateDate(num: number): string {
    let date = new Date(num);
    let year = date.getFullYear();
    let month = date.getMonth() + 1;  // 月份从0开始，需要+1
    let day = date.getDate();
    let hour = date.getHours();
    let minute = date.getMinutes();
    
    // 补零处理：个位数前补0
    let m = month < 10 ? '0' + month : month.toString();
    let d = day < 10 ? '0' + day : day.toString();
    let h = hour < 10 ? '0' + hour : hour.toString();
    let mi = minute < 10 ? '0' + minute : minute.toString();
    
    return `${year}-${m}-${d} ${h}:${mi}`;
  }
}

// 创建单例实例并导出
let dateUtil = new DateUtil();
export default dateUtil as DateUtil;

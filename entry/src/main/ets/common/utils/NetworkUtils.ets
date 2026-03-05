/**
 * 网络工具类 - 提供网络相关功能的工具类
 * 
 * @author 2008
 * @datetime 2024/8/15 13:15
 * @className: NetworkUtils
 * 
 * 功能：封装网络相关的工具方法，包括URL处理、内容类型检查等
 * 核心特性：
 *   1. URL处理：绝对URL解析、基础URL提取、URL清理
 *   2. 内容类型检查：判断数据是JSON、HTML还是其他类型
 *   3. 类型判断：判断数据是字符串还是ArrayBuffer
 * 使用场景：网络请求处理、URL解析、内容类型识别
 */
import { url } from '@kit.ArkTS';

class NetworkUtils {
  /**
   * 获取绝对URL
   * 功能：将相对URL转换为绝对URL
   * @param baseUrl - 基础URL，用于解析相对URL
   * @param searchUrl - 要解析的URL（可以是相对或绝对URL）
   * 返回值：string - 解析后的绝对URL，如果解析失败则返回原始URL
   * 使用场景：处理书源中的相对URL，确保网络请求使用正确的绝对URL
   */
  getAbsoluteURL(baseUrl: string, searchUrl: string): string {
    try {
      const absoluteUrl = url.URL.parseURL(searchUrl, baseUrl);
      return absoluteUrl.href;
    } catch (error) {
      console.error('Failed to resolve absolute URL:', error);
      return searchUrl;
    }
  }

  /**
   * 获取基础URL
   * 功能：从完整URL中提取基础URL（协议+域名+端口）
   * @param url - 完整的URL字符串
   * 返回值：Promise<string | null> - 基础URL，如果不是HTTP/HTTPS URL则返回null
   * 使用场景：提取书源的基础URL，用于后续的相对URL解析
   * 处理逻辑：
   *   1. 检查URL是否以http://或https://开头
   *   2. 查找第三个斜杠的位置（协议后的第一个斜杠）
   *   3. 如果找到斜杠，返回斜杠之前的部分；否则返回完整URL
   */
  async getBaseUrl(url: string): Promise<string | null> {
    if (!url) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      let index = url.indexOf("/", 9); // 从第9个字符开始查找（跳过"https://"）
      if (index === -1) {
        return url;
      } else {
        return url.substring(0, index);
      }
    }
    return null;
  }

  /**
   * 检查内容类型
   * 功能：判断数据内容是JSON、HTML还是其他类型
   * @param data - 要检查的数据内容
   * 返回值：boolean | null - true表示JSON，false表示HTML，null表示其他类型
   * 使用场景：网络响应内容类型识别，决定如何解析响应数据
   * 处理逻辑：
   *   1. 尝试解析为JSON，成功则返回true
   *   2. 如果解析失败，检查是否包含HTML标签
   *   3. 包含HTML标签则返回false，否则返回null
   */
  checkContentType(data: string) {
    try {
      // 尝试将数据解析为 JSON
      if (typeof data === 'object') {
        return true;
      }
      JSON.parse(data);
      return true;
    } catch (e) {
      // 如果解析失败，检查是否存在 HTML 标签
      if (/<\/?[^>]+(>|$)/.test(data)) {
        return false;
      } else {
        // 如果既不是有效的 JSON 也不是 HTML，则返回未知类型
        return null;
      }
    }
  }

  /**
   * 判断类型是否为字符串
   * 功能：判断数据是字符串类型还是ArrayBuffer类型
   * @param data - 要检查的数据（string | ArrayBuffer）
   * 返回值：boolean - true表示字符串，false表示ArrayBuffer
   * 使用场景：网络响应数据处理，根据类型选择不同的处理方式
   */
  isString(data: string | ArrayBuffer): boolean {
    return typeof data === 'string';
  }

  /**
   * 清理URL
   * 功能：移除URL中的空白字符和换行符
   * @param url - 要清理的URL字符串
   * 返回值：string - 清理后的URL
   * 使用场景：处理用户输入或书源配置中的URL，确保URL格式正确
   * 清理内容：
   *   1. 移除开头和结尾的空白字符
   *   2. 移除中间的换行符和回车符
   */
  cleanUrl(url: string) {
    return url.replace(/^\s+|\s+$/g, '').replace(/[\r\n]+/g, '');
  }
}

// 创建单例实例并导出
const networkUtil = new NetworkUtils();
export default networkUtil as NetworkUtils;

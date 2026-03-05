/**
 * 网络请求工具类 - 封装HTTP请求功能的工具类
 * 
 * @author 2008
 * @datetime 2024/8/16 11:49
 * @className: requestUtils
 * 
 * 功能：封装axios库，提供统一的HTTP请求接口，支持GET/POST请求、编码处理等
 * 核心特性：
 *   1. 请求配置：支持自定义请求头、超时设置、响应类型
 *   2. 编码处理：自动处理不同字符编码的响应数据
 *   3. 容错机制：GET失败自动尝试POST，POST失败自动尝试GET
 *   4. 随机Cookie：生成随机Cookie避免反爬虫机制
 * 使用场景：书源搜索请求、网页内容抓取、API调用
 */
import axios, { AxiosRequestConfig, AxiosResponse } from '@ohos/axios';
import { SearchConfig } from '../model/SearchConfig';
import { util } from '@kit.ArkTS';

class requestUtils {

  /**
   * 请求HTML内容
   * 功能：根据SearchConfig配置发送HTTP请求，获取HTML内容
   * @param config - 搜索配置，包含URL、方法、请求体、字符编码等
   * 返回值：Promise<string> - 解码后的HTML文本内容
   * 使用场景：书源搜索、网页内容抓取
   * 处理流程：
   *   1. 配置请求选项：设置请求头、响应类型、超时时间
   *   2. 判断请求方法：优先使用config.method，默认POST
   *   3. 发送请求：根据方法发送GET或POST请求
   *   4. 容错处理：如果首选方法失败，自动尝试另一种方法
   *   5. 解码响应：根据字符编码解码ArrayBuffer为字符串
   * 请求头说明：
   *   - User-Agent: 模拟Chrome浏览器
   *   - Accept: 接受多种内容类型
   *   - Cookie: 随机生成的Cookie，避免反爬虫
   *   - Content-Encoding: 支持多种压缩编码
   *   - Accept-Language: 中文优先
   */
  async requestHtml(config: SearchConfig): Promise<string> {
    // 明确类型声明
    const requestOptions: AxiosRequestConfig = {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Cookie': this.generateRandomCookie(),
        'Content-Encoding': 'gzip, deflate, br, zstd',
        'Accept-Language': 'zh-CN,zh;q=0.9'
      },
      responseType: 'array_buffer', // 使用arraybuffer以便处理不同编码的文本
      timeout: 5000
    };

    // 判断请求方法，如果没有指定则默认为POST
    const requestMethod: string = config.method ? config.method.toUpperCase() : 'POST';

    // 处理请求
    let response: AxiosResponse<ArrayBuffer>;
    if (requestMethod === 'GET') {
      try {
        response = await axios.get<ArrayBuffer>(config.url, requestOptions);
      } catch (e) {
        response = await axios.post<ArrayBuffer>(config.url, config.body || '', requestOptions);
      }
    } else {
      try {
        response = await axios.post<ArrayBuffer>(config.url, config.body || '', requestOptions);
      } catch (e) {
        response = await axios.get<ArrayBuffer>(config.url, requestOptions);
      }
    }
    
    let res = this.textDecoder(response.data, config.charset ?? 'UTF-8');
    // 处理响应数据
    return res;
  }



  /**
   * 请求URL HTML内容
   * 功能：发送HTTP请求获取指定URL的HTML内容，自动尝试GET和POST方法
   * @param url - 请求的URL地址
   * 返回值：Promise<string> - HTML文本内容
   * 使用场景：简单的网页内容抓取，不需要复杂配置
   * 处理流程：
   *   1. 配置请求选项：设置请求头、响应类型、超时时间
   *   2. 尝试GET请求
   *   3. 如果GET失败，尝试POST请求
   *   4. 返回响应数据
   * 与requestHtml方法的区别：
   *   - 此方法使用简单的配置，responseType为'object'
   *   - 不处理字符编码转换，假设响应为UTF-8
   *   - 不接收SearchConfig参数，使用默认配置
   */
  async requestUrlHtml(url: string): Promise<string> {
    // 明确类型声明
    const requestOptions: AxiosRequestConfig = {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Cookie': this.generateRandomCookie(),
        'Content-Encoding': 'gzip, deflate, br, zstd',
        'Accept-Language': 'zh-CN,zh;q=0.9'
      },
      responseType: 'object', // 使用 object 响应类型，直接返回字符串
      timeout: 5000
    };
    // 处理请求
    let response: AxiosResponse<string>;

    try {
      response = await axios.get<string>(url, requestOptions);
    } catch (e) {
      response = await axios.post<string>(url, requestOptions);
    }
    // 处理响应数据
    return response.data;
  }

  /**
   * 文本解码器
   * 功能：将ArrayBuffer按指定字符编码解码为字符串
   * @param data - 要解码的ArrayBuffer数据
   * @param encoding - 字符编码，默认'UTF-8'
   * 返回值：string - 解码后的字符串
   * 使用场景：处理不同字符编码的HTTP响应
   * 处理流程：
   *   1. 创建指定编码的TextDecoder
   *   2. 将ArrayBuffer转换为Uint8Array
   *   3. 使用decodeWithStream方法解码
   * 编码支持：UTF-8、GBK、GB2312、ISO-8859-1等
   * 注意：ignoreBOM: true表示忽略字节顺序标记
   */
  private textDecoder(data: ArrayBuffer, encoding: string = 'UTF-8'): string {
    let textDecoder = util.TextDecoder.create(encoding, { ignoreBOM: true });
    const result = new Uint8Array(data);
    let decodedText = textDecoder.decodeWithStream(result);
    return decodedText;
  }

  /**
   * 生成随机Cookie
   * 功能：生成随机的Cookie值，用于避免反爬虫机制
   * 返回值：string - 随机Cookie字符串
   * 使用场景：HTTP请求头中的Cookie字段
   * 生成算法：
   *   1. 生成两个随机字符串（Math.random().toString(36)生成36进制字符串）
   *   2. 截取第2到第15个字符（去掉"0."前缀）
   *   3. 拼接两个随机字符串
   *   4. 格式化为"random-cookie=随机值"
   * 目的：模拟真实浏览器的Cookie，避免被识别为爬虫
   */
  private generateRandomCookie(): string {
    const randomValue = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
    return `random-cookie=${randomValue}`;
  }
}

const requestUtil = new requestUtils();
export default requestUtil as requestUtils;

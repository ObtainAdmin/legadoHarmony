/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 我的设置常量类 - 定义应用中用户设置相关的常量键名
 * 
 * 功能：提供统一的设置项键名常量，用于存储和读取用户偏好设置
 * 使用方法：通过 MySetConstants.常量名 访问对应的设置键名
 * 分类：
 *   1. 阅读相关设置
 *   2. 图片相关设置
 *   3. 网络相关设置
 *   4. 系统相关设置
 * 注意事项：
 *   - 这些常量用作偏好设置存储的键名
 *   - 对应的值通常是布尔值或字符串
 *   - 设置项通常有对应的UI开关控件
 */
export default class MySetConstants {
  // ==================== 阅读相关设置 ====================
  
  /**
   * 自动刷新设置键名
   * 功能：控制是否自动刷新内容的设置项键名
   * 使用场景：阅读时自动刷新章节内容
   * 值类型：布尔值（true/false）
   */
  static readonly SET_REFRESH: string = 'setRefresh';

  /**
   * 自动跳转最近阅读设置键名
   * 功能：控制是否自动跳转到最近阅读位置的设置项键名
   * 使用场景：打开书籍时自动定位到上次阅读位置
   * 值类型：布尔值（true/false）
   */
  static readonly SET_JUMP: string = 'setJump';

  /**
   * 默认启用替换净化设置键名
   * 功能：控制是否默认启用文本替换净化功能的设置项键名
   * 使用场景：自动净化阅读内容中的广告、乱码等
   * 值类型：布尔值（true/false）
   */
  static readonly SET_REPLACE: string = 'setReplace';

  /**
   * 返回时提示放入书架设置键名
   * 功能：控制返回时是否提示将书籍放入书架的设置项键名
   * 使用场景：阅读页面返回时提示用户收藏书籍
   * 值类型：布尔值（true/false）
   */
  static readonly SET_TIP: string = 'setTip';

  /**
   * 书籍保存设置键名
   * 功能：控制是否保存书籍数据的设置项键名
   * 使用场景：自动保存阅读进度和书籍信息
   * 值类型：布尔值（true/false）
   */
  static readonly SET_BOOK_SAVE: string = 'setBookSave';

  /**
   * 预下载设置键名
   * 功能：控制是否预下载后续章节的设置项键名
   * 使用场景：提前下载下一章内容以提升阅读体验
   * 值类型：布尔值（true/false）
   */
  static readonly SET_PRE_DOWNLOAD: string = 'setPreDownload';

  // ==================== 图片相关设置 ====================
  
  /**
   * 图片抗锯齿设置键名
   * 功能：控制是否启用图片抗锯齿效果的设置项键名
   * 使用场景：提升图片显示质量，减少锯齿感
   * 值类型：布尔值（true/false）
   */
  static readonly SET_IMG_ANTI: string = 'setImgAnti';

  /**
   * 图片缓存设置键名
   * 功能：控制是否启用图片缓存的设置项键名
   * 使用场景：缓存已加载的图片，提升加载速度
   * 值类型：布尔值（true/false）
   */
  static readonly SET_IMG_CACHE: string = 'setImgCache';

  // ==================== 网络相关设置 ====================
  
  /**
   * Webservice唤醒锁设置键名
   * 功能：控制Webservice是否保持唤醒状态的设置项键名
   * 使用场景：防止Webservice在后台被系统休眠
   * 值类型：布尔值（true/false）
   */
  static readonly SET_AWAKEN: string = 'setAwaken';

  /**
   * Web端口设置键名
   * 功能：控制Web服务端口的设置项键名
   * 使用场景：设置本地Web服务的监听端口
   * 值类型：字符串（端口号，如"8080"）
   */
  static readonly SET_WEB_PORT: string = 'setWebPort';

  /**
   * 清除Web缓存设置键名
   * 功能：控制是否清除Web缓存的设置项键名
   * 使用场景：清理浏览器缓存数据
   * 值类型：布尔值（true/false）
   */
  static readonly SET_CLEAR_WEB: string = 'setClearWeb';

  /**
   * 用户代理设置键名
   * 功能：控制HTTP请求中User-Agent头的设置项键名
   * 使用场景：自定义请求头，模拟不同设备或浏览器
   * 值类型：字符串（User-Agent字符串）
   */
  static readonly SET_USER_AGENT: string = 'setUserAgent';

  // ==================== 系统相关设置 ====================
  
  /**
   * 全程响应耳机按键设置键名
   * 功能：控制是否全程响应耳机按键操作的设置项键名
   * 使用场景：通过耳机按键控制阅读翻页、播放暂停等
   * 值类型：布尔值（true/false）
   */
  static readonly SET_HEAD: string = 'setHead';

  /**
   * 文字操作显示搜索设置键名
   * 功能：控制选中文字时是否显示搜索选项的设置项键名
   * 使用场景：长按文字时弹出搜索菜单
   * 值类型：布尔值（true/false）
   */
  static readonly SET_SEARCH: string = 'setSearch';

  /**
   * 语言设置键名
   * 功能：控制应用显示语言的设置项键名
   * 使用场景：切换应用界面语言（中文、英文等）
   * 值类型：字符串（语言代码，如"zh-CN"、"en-US"）
   */
  static readonly SET_LANGUAGE: string = 'setLanguage';
}

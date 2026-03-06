/**
 * SearchHead 组件 - 搜索头部组件
 * 
 * 功能概述：
 * 1. 提供搜索输入框、返回按钮和搜索/取消按钮
 * 2. 管理搜索状态和搜索任务的生命周期
 * 3. 处理搜索输入变化和提交逻辑
 * 4. 对搜索结果进行去重、合并和智能排序
 * 5. 集成路由导航和任务取消功能
 * 
 * 设计特点：
 * 1. 灵活布局：使用Flex布局实现响应式头部
 * 2. 状态管理：使用@Consume装饰器消费全局搜索状态
 * 3. 智能搜索：根据输入内容动态调整搜索策略
 * 4. 结果处理：对搜索结果进行去重、合并和相似度排序
 * 5. 视觉设计：背景图片装饰，圆角底部设计
 * 
 * 使用场景：
 * 1. 搜索页面的头部区域
 * 2. 需要搜索输入和状态管理的界面
 * 3. 需要集成搜索任务管理的场景
 * 
 * 组件结构：
 * - 返回按钮：导航返回，取消搜索任务
 * - 搜索输入框：输入搜索内容，实时监听变化
 * - 搜索/取消按钮：根据搜索状态切换功能
 * - 背景区域：装饰性背景图片
 * 
 * 注意事项：
 * 1. 需要正确处理搜索任务的启动和取消
 * 2. 搜索结果需要智能去重和排序
 * 3. 搜索状态需要与全局状态同步
 */

import { router } from '@kit.ArkUI';
import taskSearchBooks from '../../common/model/taskSearchBook';
import { SearchBook } from '../../database/entities/SearchBook';
import { showMessage } from '../common/promptShow';


@Component
export struct SearchHead {
  /**
   * 搜索关键词
   * @type {string}
   * @description 全局搜索关键词
   * @consume 使用@Consume装饰器消费全局状态
   */
  @Consume SearchValue: string
  
  /**
   * 搜索状态
   * @type {number}
   * @description 全局搜索状态（0:未开始, 1:进行中, 2:已完成）
   * @consume 使用@Consume装饰器消费全局状态
   */
  @Consume SearchStatus: number
  
  /**
   * 搜索书籍列表
   * @type {SearchBook[]}
   * @description 全局搜索书籍列表数据
   * @consume 使用@Consume装饰器消费全局状态
   */
  @Consume('searchBookList') books: SearchBook[]
  
  /**
   * 上一次搜索关键词
   * @type {string}
   * @default ''
   * @description 记录上一次搜索的关键词，用于判断是否需要重新搜索
   * @state 使用@State装饰器管理组件内部状态
   */
  @State lastSearch: string = ''
  
  /**
   * 搜索状态标识
   * @type {boolean}
   * @description 全局搜索进行中标识
   * @consume 使用@Consume装饰器消费全局状态
   */
  @Consume('isSearch') isSearch: boolean
  
  /**
   * 顶部矩形高度
   * @type {number}
   * @default 0
   * @description 从存储中读取的顶部矩形高度，用于布局计算
   * @storagelink 使用@StorageLink装饰器实现与存储的双向绑定
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  // @State bookIndex:number = 0 // 预留的书籍索引（注释状态）
  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建搜索头部的完整UI结构
   * 包含返回按钮、搜索输入框和搜索/取消按钮
   */
  build() {
    Flex({
      alignItems: ItemAlign.End, // 底部对齐
      justifyContent: FlexAlign.SpaceBetween // 两端对齐
    }) {
      Row({ space: 15 }) { // 15px间距
        /**
         * 返回按钮
         * @description 25x25px返回图标，点击返回上一页
         * 如果正在搜索，同时取消所有搜索任务
         */
        Image($r('app.media.return_left'))
          .width(25)
          .height(25)
          .onClick(() => {
            router.back() // 路由返回
            if (this.isSearch) {
              taskSearchBooks.cancelAllTasks() // 取消搜索任务
            }
          })
        
        /**
         * 搜索输入框
         * @description 70%宽度，40px高度，自定义搜索图标
         * 监听输入变化和提交事件
         */
        Search({ 
          value: this.SearchValue, // 绑定搜索值
          placeholder: '搜索书名或作者', // 占位文本
          icon: "/common/images/search.svg" // 搜索图标
        })
          .width("70%") // 70%宽度
          .height(40) // 40px高度
          .onChange(this.onChange) // 输入变化回调
          .onSubmit(this.onSubmit); // 提交回调
        
        /**
         * 搜索/取消按钮
         * @description 根据搜索状态显示"搜索"或"取消"
         * 10%宽度，40px高度，600字重
         */
        Text(this.isSearch ? "取消" : "搜索")
          .width("10%")
          .height(40)
          .fontWeight(600) // 600字重
          .onClick(() => {
            if (this.isSearch) {
              // 取消搜索
              taskSearchBooks.cancelAllTasks() // 取消所有任务
              console.log(`取消搜索${this.books.length}`) // 调试日志
              this.isSearch = false // 更新搜索状态
            } else {
              // 开始搜索
              this.onSubmit(this.SearchValue) // 提交搜索
            }
          })
      }
      .margin({ left: 5 }) // 左侧5px外边距
      .width("100%") // 100%宽度
      .margin({ top: this.topRectHeight }) // 顶部外边距，适配状态栏
    }
    .borderRadius({ bottomRight: 5, bottomLeft: 5 }) // 底部左右5px圆角
    .backgroundImage($r('app.media.backgroundimage')) // 背景图片
    .backgroundImageSize({ width: '100%' }) // 背景图片100%宽度
    .height(50+this.topRectHeight) // 50px基础高度 + 顶部矩形高度
  }

  /**
   * 输入变化回调
   * @param {string} value - 新的输入值
   * @returns {void}
   * @description 监听搜索输入框变化，更新搜索关键词
   * 记录上一次搜索值，用于判断是否需要重新搜索
   */
  onChange = (value: string) => {
    this.lastSearch = this.SearchValue // 记录上一次搜索值
    this.SearchValue = value; // 更新当前搜索值
  }
  
  /**
   * 提交搜索回调
   * @param {string} value - 提交的搜索值
   * @returns {Promise<void>}
   * @description 处理搜索提交逻辑
   * 1. 验证搜索内容非空
   * 2. 判断是否需要更新搜索状态
   * 3. 启动搜索任务
   * 4. 处理搜索结果回调
   */
  onSubmit = async (value: string) => {
    this.SearchValue = value; // 更新搜索值
    if (!this.SearchValue) {
      showMessage('搜索内容不能为空') // 显示提示消息
      return
    }
    // 判断是否需要重新搜索：列表为空或搜索词变化
    if (this.books.length === 0 || this.SearchValue !== this.lastSearch) {
      this.SearchStatus = 1 // 更新搜索状态为进行中
    }
    this.isSearch = true // 标记搜索进行中
    this.books = [] // 清空书籍列表
    // 启动搜索任务
    taskSearchBooks.search(this.SearchValue, 
      (newUrls: SearchBook[]) => {
        // 搜索成功回调
        this.setBookList(newUrls) // 处理搜索结果
      }, 
      () => {
        // 搜索完成回调
        this.SearchStatus = 2 // 更新搜索状态为已完成
        this.isSearch = false // 标记搜索结束
      }
    )
  }

  /**
   * 设置书籍列表
   * @param {SearchBook[]} books - 新的书籍列表
   * @returns {void}
   * @description 处理搜索结果，进行去重和合并
   * 1. 按书名和作者去重
   * 2. 合并相同书籍的不同来源
   * 3. 统计每个书籍的来源数量
   */
  setBookList(books: SearchBook[]) {
    if (books.length === 0) {
      return // 空列表直接返回
    }
    books.forEach((book: SearchBook) => {
      let found = false; // 标记是否找到重复书籍
      if (!book.name) {
        return // 跳过无名书籍
      }
      // 遍历现有书籍列表查找重复项
      for (let item of this.books) {
        if (item.name === book.name && item.author === book.author) {
          item.belongCount++; // 增加来源计数
          // 源来的books的source源 id和 books的source源 id相同不添加
          if (item.source?.bookSourceUrl !== book.source?.bookSourceUrl && book.source) {
            // 确保 sourceList 已经存在并且是一个数组
            if (!item.sourceList) {
              item.sourceList = []; // 初始化来源列表
            }
            item.sourceList.push(book.source) // 添加新来源
          }
          found = true; // 标记已找到
          break; // 跳出循环
        }
      }

      // 未找到重复项，添加新书籍
      if (!found) {
        book.belongCount = 1 // 初始化来源计数
        this.books.push(book); // 添加到列表
      }
    });
    this.sortBooksBySearchValue() // 对书籍进行排序
  }

  /**
   * 按搜索值排序书籍
   * @returns {void}
   * @description 根据书籍名称与搜索关键词的相似度进行排序
   * 1. 计算每个书籍名称与搜索词的相似度
   * 2. 按相似度降序排序
   * 3. 相似度相同时按来源数量降序排序
   */
  sortBooksBySearchValue() {
    this.books.sort((a: SearchBook, b: SearchBook) => {
      const aName = a.name || ''; // 书籍A名称
      const bName = b.name || ''; // 书籍B名称
      const searchValue = this.SearchValue || ''; // 搜索关键词

      // 计算相似度
      const aNameSimilarity = this.getSimilarity(aName.toLowerCase(), searchValue.toLowerCase());
      const bNameSimilarity = this.getSimilarity(bName.toLowerCase(), searchValue.toLowerCase());

      if (aNameSimilarity !== bNameSimilarity) {
        return bNameSimilarity - aNameSimilarity; // 按相似度降序
      }

      return b.belongCount - a.belongCount; // 相似度相同时按来源数量降序
    });
  }

  /**
   * 计算字符串相似度
   * @param {string} str1 - 第一个字符串
   * @param {string} str2 - 第二个字符串
   * @returns {number} 相似度分数
   * @description 计算两个字符串的相似度
   * 1. 计算相同位置相同字符的数量
   * 2. 减去长度差异作为惩罚
   * 3. 返回相似度分数（越高越相似）
   */
  getSimilarity(str1: string, str2: string) {
    const lengthDifference = Math.abs(str1.length - str2.length); // 长度差异
    const commonLength = Math.min(str1.length, str2.length); // 公共长度
    let similarity = 0; // 相似度计数器

    // 遍历公共长度，统计相同位置相同字符的数量
    for (let i = 0; i < commonLength; i++) {
      if (str1[i] === str2[i]) {
        similarity++; // 相同字符计数
      }
    }

    return similarity - lengthDifference; // 相似度减去长度差异
  }

  /**
   * 计算匹配字符数量
   * @param {string} last - 上一个字符串
   * @param {string} current - 当前字符串
   * @returns {number} 匹配字符数量
   * @description 计算当前字符串中的字符在上一字符串中出现的次数
   * 用于辅助相似度计算，考虑字符频率
   */
  countMatchingChars(last: string, current: string) {
    // 创建一个对象来存储字符串 a 中的字符及其出现次数
    const charsInA: Record<string, number> = {};
    // 填充对象
    for (const char of last) {
      charsInA[char] = (charsInA[char] || 0) + 1; // 统计字符频率
    }
    // 初始化计数器
    let count = 0;
    // 遍历字符串 b 中的每个字符
    for (const char of current) {
      // 如果字符存在于 a 中，则计数器加一
      if (charsInA[char]) {
        count++; // 匹配计数
      }
    }
    return count; // 返回匹配数量
  }

  /**
   * 组件即将显示时的生命周期回调
   * @returns {void}
   * @description 组件初始化逻辑，打印当前搜索状态
   */
  aboutToAppear(): void {
    console.log(this.SearchStatus.toString()); // 打印搜索状态
  }
}

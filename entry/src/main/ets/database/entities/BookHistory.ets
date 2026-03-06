/**
 * @author 2008
 * @datetime 2024/8/5 21:15
 * @className: BookHistory
 * 
 * 书籍浏览历史实体类 (Book History Entity)
 * 
 * 功能说明：
 * 1. 定义书籍阅读历史的数据结构
 * 2. 记录用户的阅读进度和阅读习惯
 * 3. 提供继续阅读功能的基础数据支持
 * 4. 管理阅读历史的基本属性和业务逻辑
 * 
 * 核心属性：
 * - 书籍基本信息：名称、作者、URL、封面
 * - 阅读进度：章节时间、章节索引、章节标题、章节内容
 * - 书籍类型：小说、漫画、有声
 * - 时间信息：创建时间、更新时间、最近阅读时间
 * - 关联信息：源书籍ID、排序
 * 
 * 使用场景：
 * - 继续阅读功能
 * - 阅读历史查看
 * - 阅读进度同步
 * - 阅读习惯分析
 */
@Observed
export class BookHistory {
  id?:number
  // 书籍名称
  bookName:string = ''
  // 作者名称
  author: string = ''
  //阅读地址
  bookUrl:string = ''
  //封面地址
  coverUrl:string = ''
  //最近一次阅读书籍的时间(打开正文的时间)
  durChapterTime:number = 0
  //最近一次阅读章节的序号
  durChapterIndex:number = 0
  //最近一次阅读章节的标题
  durChapterTitle:string = ''
  //最近一次阅读章节进度
  durChapterContent:string = ''
  //排序
  sort:number = 0
  //小说0/漫画1/有声2
  bookType?:number
  //源书籍ID
  originBookId?:number
  //创建时间
  createTime?:number = 0
  //更新时间
  updateTime?:number = 0

  /**
   * 构造函数
   * @param {BookHistory} [bookHistory] - 可选的BookHistory对象，用于复制属性
   * @description 支持从现有BookHistory对象复制属性值
   */
  constructor(bookHistory?:BookHistory) {
    if (bookHistory) {
      this.id = bookHistory.id
      this.bookName = bookHistory.bookName
      this.author = bookHistory.author
      this.durChapterTime = bookHistory.durChapterTime
      this.durChapterIndex = bookHistory.durChapterIndex
      this.durChapterTitle = bookHistory.durChapterTitle
      this.durChapterContent = bookHistory.durChapterContent
      this.sort = bookHistory.sort
      this.bookType = bookHistory.bookType
    }
  }
}

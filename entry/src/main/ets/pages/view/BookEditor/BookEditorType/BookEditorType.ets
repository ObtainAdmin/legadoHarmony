/**
 * 书籍编辑数据模型类 - 封装书籍编辑相关的所有数据
 * 
 * 功能概述：
 * 1. 管理书籍的基本信息：书名、作者、封面、封面URL、简介
 * 2. 提供选择状态管理，用于封面选择等场景
 * 3. 提供完整的setter和getter方法，支持数据封装
 * 4. 支持可选参数初始化，便于灵活创建对象
 * 
 * 设计模式：
 * 采用经典的数据模型模式，将数据和行为封装在一起
 * 使用私有属性和公共方法，确保数据安全性和一致性
 * 
 * 使用场景：
 * 在书籍编辑页面（BookEditorPage.ets）中作为数据模型使用
 * 在封面选择弹窗中管理多个封面选项的选择状态
 */
export class BookEditorType {
  /** 书籍名称，可选属性 */
  private BookName?:string;
  
  /** 书籍作者，可选属性 */
  private BookAuthor?:string;
  
  /** 书籍封面图标资源，Resource类型，可选属性 */
  private BookIcon?:Resource;
  
  /** 书籍封面图片URL地址，可选属性 */
  private BookIconUrl?:string;
  
  /** 书籍简介文本，可选属性 */
  private BookSynopsis?:string;
  
  /** 选择状态标记，用于封面选择等场景，可选属性 */
  private isSelect?:boolean;

  /**
   * 构造函数 - 创建书籍编辑数据模型实例
   * 
   * @param bookName 书籍名称（可选）
   * @param bookAuthor 书籍作者（可选）
   * @param bookIcon 书籍封面图标资源（可选）
   * @param bookIconUrl 书籍封面图片URL地址（可选）
   * @param bookSynopsis 书籍简介文本（可选）
   * @param isSelect 选择状态标记（可选，默认false）
   * 
   * 使用示例：
   * new BookEditorType('书名', '作者', $r('app.media.icon'), 'https://example.com/cover.jpg', '简介内容', false)
   */
  constructor(bookName?:string, bookAuthor?:string, bookIcon?:Resource, bookIconUrl?:string, bookSynopsis?:string, isSelect?:boolean) {
    this.BookName = bookName;
    this.BookAuthor = bookAuthor;
    this.BookIcon = bookIcon;
    this.BookIconUrl = bookIconUrl;
    this.BookSynopsis = bookSynopsis;
    this.isSelect = isSelect
  }


  /**
   * 设置书籍名称
   * @param bookName 书籍名称字符串
   */
  setBookName(bookName:string):void {
    this.BookName = bookName;
  }

  /**
   * 设置书籍作者
   * @param bookAuthor 书籍作者字符串
   */
  setBookAuthor(bookAuthor:string):void {
    this.BookAuthor = bookAuthor;
  }

  /**
   * 设置书籍封面图标资源
   * @param bookIcon 书籍封面图标资源（Resource类型）
   */
  setBookIcon(bookIcon:Resource):void {
    this.BookIcon = bookIcon;
  }

  /**
   * 设置书籍封面图片URL地址
   * @param bookIconUrl 封面图片URL地址字符串
   */
  setBookIconUrl(bookIconUrl:string):void {
    this.BookIconUrl = bookIconUrl;
  }

  /**
   * 设置书籍简介文本
   * @param bookSynopsis 书籍简介文本字符串
   */
  setBookSynopsis(bookSynopsis:string):void {
    this.BookSynopsis = bookSynopsis;
  }

  /**
   * 设置书籍选择状态
   * @param isSelect 选择状态布尔值，true表示选中，false表示未选中
   * 使用场景：在封面选择弹窗中标记当前选中的封面
   */
  setBookSelect(isSelect:boolean):void {
    this.isSelect = isSelect;
  }

  /**
   * 获取书籍名称
   * @returns 书籍名称字符串，如果未设置则返回'undefined'
   */
  getBookName():string {
    if (this.BookName) {
      return this.BookName;
    }
    return 'undefined';
  }

  /**
   * 获取书籍作者
   * @returns 书籍作者字符串，如果未设置则返回'undefined'
   */
  getBookAuthor():string {
    if (this.BookAuthor) {
      return this.BookAuthor;
    }
    return 'undefined';
  }

  /**
   * 获取书籍封面图标资源
   * @returns 书籍封面图标资源（ResourceStr类型），如果未设置则返回'undefined'
   */
  getBookIcon():ResourceStr {
    if (this.BookIcon) {
      return this.BookIcon;
    }
    return 'undefined';
  }

  /**
   * 获取书籍封面图片URL地址
   * @returns 封面图片URL地址字符串，如果未设置则返回'undefined'
   */
  getBookIconUrl():string {
    if (this.BookIconUrl) {
      return this.BookIconUrl;
    }
    return 'undefined';
  }

  /**
   * 获取书籍简介文本
   * @returns 书籍简介文本字符串，如果未设置则返回'undefined'
   */
  getBookSynopsis():string {
    if (this.BookSynopsis) {
      return this.BookSynopsis;
    }
    return 'undefined';
  }

  /**
   * 获取书籍选择状态
   * @returns 选择状态布尔值，true表示选中，false表示未选中
   * 如果未设置选择状态，默认返回false
   */
  getBookSelect():boolean {
    if(this.isSelect) {
      return this.isSelect
    }
    return false
  }
}

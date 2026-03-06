/**
 * Copyright (C), 2024-05-13
 * @author LinXun
 * @date 2024/5/13 15:25
 * @version 1.0
 * @description: 笔记显示模型
 * 
 * 笔记数据模型类 (Note Value Object)
 * 
 * 功能说明：
 * 1. 用于封装单条笔记的完整数据
 * 2. 在阅读器应用中显示和操作笔记时使用
 * 3. 作为笔记数据的传输对象
 * 
 * 数据结构：
 * - 包含笔记的基本信息：ID、引用内容、笔记内容、创建时间
 * - 笔记内容为可选字段，用户可能只标记引用而不添加笔记
 * 
 * 使用场景：
 * - 阅读器的笔记显示
 * - 笔记的创建、编辑、删除
 * - 笔记的导入导出
 * - 笔记搜索和过滤
 * 
 * 示例：
 * ```typescript
 * const myNote = new NoteVO(1, "这是引用的文本", "2024-05-13 15:30:00", "这是我的笔记内容");
 * ```
 */
export class NoteVO {
  /**
   * 笔记ID
   * @type {number}
   * @description 唯一标识符，通常对应数据库中的笔记ID
   */
  id: number;
  
  /**
   * 笔记引用内容
   * @type {string}
   * @description 用户标记的原文引用内容，通常是书籍中的一段文本
   */
  noteContent: string;
  
  /**
   * 笔记内容
   * @type {string | undefined}
   * @description 用户添加的笔记内容，可选字段
   */
  note?: string;
  
  /**
   * 创建时间
   * @type {string}
   * @description 笔记创建的时间戳，格式通常为"YYYY-MM-DD HH:mm:ss"
   */
  createTime: string;
  
  /**
   * 构造函数
   * @param {number} id - 笔记ID
   * @param {string} noteContent - 笔记引用内容
   * @param {string} createTime - 创建时间
   * @param {string} [note] - 笔记内容（可选）
   * @description 创建笔记数据对象
   */
  constructor(id: number, noteContent: string, createTime: string, note?: string) {
    this.id = id;
    this.noteContent = noteContent;
    this.note = note;
    this.createTime = createTime;
  }
}

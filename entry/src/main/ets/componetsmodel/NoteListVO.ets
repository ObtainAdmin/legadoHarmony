/**
 * Copyright (C), 2024-05-13
 * @author LinXun
 * @date 2024/5/13 15:38
 * @version 1.0
 * @description: 笔记列表显示模型
 * 
 * 笔记列表显示数据模型类 (Note List Value Object)
 * 
 * 功能说明：
 * 1. 用于封装章节及其关联的笔记列表数据
 * 2. 在阅读器应用中显示章节笔记时使用
 * 3. 组织笔记按章节分组显示
 * 
 * 数据结构：
 * - 每个NoteListVO对象代表一个章节
 * - 每个章节包含多个NoteVO（具体笔记）
 * 
 * 使用场景：
 * - 阅读器的笔记管理界面
 * - 章节笔记列表展示
 * - 笔记的批量操作（删除、导出等）
 * 
 * 示例：
 * ```typescript
 * const chapterNotes = new NoteListVO(1, "第一章", [note1, note2, note3]);
 * ```
 */
import { NoteVO } from './NoteVO';

export class NoteListVO {
  /**
   * 章节ID
   * @type {number}
   * @description 唯一标识符，通常对应数据库中的章节ID
   */
  id: number;
  
  /**
   * 章节名称
   * @type {string}
   * @description 章节的标题或名称，用于显示
   */
  chapterName: string;
  
  /**
   * 笔记列表
   * @type {NoteVO[]}
   * @description 该章节下的所有笔记对象数组
   */
  noteList: NoteVO[];
  
  /**
   * 构造函数
   * @param {number} id - 章节ID
   * @param {string} chapterName - 章节名称
   * @param {NoteVO[]} noteList - 笔记列表
   * @description 创建章节笔记列表数据对象
   */
  constructor(id: number, chapterName: string, noteList: NoteVO[]) {
    this.id = id;
    this.chapterName = chapterName;
    this.noteList = noteList;
  }
}

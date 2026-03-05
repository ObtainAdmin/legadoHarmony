/**
 * @file NoteIndex.ets
 * @description 书籍笔记索引组件
 * 
 * 功能概述：
 * 1. 显示书籍的章节笔记列表
 * 2. 支持按章节分组显示笔记
 * 3. 提供空状态提示（无笔记时显示）
 * 4. 支持笔记内容的编辑和保存
 * 
 * 使用场景：
 * - 书籍详情页的笔记查看和管理
 * - 用户阅读时的笔记记录和查看
 * - 学习笔记的整理和展示
 * 
 * 设计特点：
 * - 使用List和ListItemGroup实现分组列表
 * - 支持嵌套的ForEach渲染
 * - 提供Builder函数构建表头
 * - 包含空状态UI设计
 * 
 * @copyright (C), 2024-05-10
 * @author LinXun
 * @date 2024/5/10 13:24
 * @version 1.0
 */

import CommonConstants from '../../../common/constants/CommonConstants'
import { NoteListVO } from '../../../componetsmodel/NoteListVO';
import { NoteVO } from '../../../componetsmodel/NoteVO';
import NoteListItem from './NoteListItem'

/**
 * @class NoteIndex
 * @description 笔记索引组件
 * 
 * 组件职责：
 * 1. 管理笔记数据状态
 * 2. 渲染分组笔记列表
 * 3. 处理空状态显示
 * 4. 协调笔记子组件的渲染
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct NoteIndex {
  /** 
   * @state noteList - 笔记列表数据
   * @description 包含章节和对应笔记的列表数据
   * @type {NoteListVO[]}
   * @default 示例数据，包含两个章节的笔记
   */
   @State noteList: NoteListVO[] = [
    new NoteListVO(1, '第一章 牢狱之灾', [
      new NoteVO(1, '许七安幽幽醒来，嗅到了空气中潮湿的腐臭味，令人轻微的不适，胃酸翻涌', '2020-03-14 12:34', '备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息'),
      new NoteVO(2, '2许七安幽幽醒来，嗅到了空气中潮湿的腐臭味，令人轻微的不适，胃酸翻涌', '2020-03-14 12:34')
    ]),
    new NoteListVO(2, '第二章 妖物作祟', [
      new NoteVO(3, '3许七安幽幽醒来，嗅到了空气中潮湿的腐臭味，令人轻微的不适，胃酸翻涌', '2020-03-14 12:34', '备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息'),
      new NoteVO(4, '4许七安幽幽醒来，嗅到了空气中潮湿的腐臭味，令人轻微的不适，胃酸翻涌', '2020-03-14 12:34', '备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息备注信息')
    ]),
  ];
  
  /** 
   * @builder itemHead - 章节表头构建器
   * @description 构建每个章节分组的表头UI
   * 
   * 功能特点：
   * 1. 显示章节名称
   * 2. 使用Blank组件实现右对齐效果
   * 3. 统一的表头样式
   * 
   * @param {string} text - 章节名称文本
   * @returns {void}
   */
  @Builder
  itemHead(text: string) {
    Row() {
      Text(text)
        .fontSize(14)
        .fontWeight(500)
        .lineHeight(22)
        .fontColor('#e0000000')
      Blank()
    }
    .width(CommonConstants.FULL_WIDTH)
    .padding({bottom: 12})
  }
  
  /**
   * @method build
   * @description 构建笔记索引组件UI
   * 
   * 逻辑流程：
   * 1. 检查笔记列表是否为空或undefined
   * 2. 如果为空：显示空状态UI（图片+文字提示）
   * 3. 如果不为空：渲染分组笔记列表
   * 
   * 空状态UI：
   * - 显示"暂无笔记"图片
   * - 显示"暂无笔记"文字提示
   * 
   * 笔记列表UI：
   * - 使用List组件作为容器
   * - 外层ForEach遍历章节（NoteListVO）
   * - 使用ListItemGroup实现章节分组
   * - 内层ForEach遍历章节内的笔记（NoteVO）
   * - 使用NoteListItem组件渲染单个笔记
   * - 关闭滚动条（BarState.Off）
   * 
   * 数据流：
   * - 通过saveChange回调函数更新笔记内容
   * - 笔记编辑后实时更新数据模型
   * 
   * @returns {void}
   */
  build() {
    /*if (true) {
      Column() {
        Image($r('app.media.ic_public_none'))
          .width(200)
          .height(168)
        Text('暂无笔记')
          .fontSize(14)
          .fontWeight(400)
          .lineHeight(22)
          .fontColor('#73000000')
      }
    }*/
    if (this.noteList === undefined || this.noteList.length === 0) {
      Column() {
        Image($r('app.media.ic_public_none'))
          .width(200)
          .height(168)
        Text('暂无笔记')
          .fontSize(14)
          .fontWeight(400)
          .lineHeight(22)
          .fontColor('#73000000')
      }
    } else {
      Column() {
        List({ space: 12 }) {
          ForEach(this.noteList, (list: NoteListVO) => {
            ListItemGroup({ space: 12, header: this.itemHead(list.chapterName) }) {
              ForEach(list.noteList, (item: NoteVO) => {
                ListItem() {
                  NoteListItem({noteVO: item, saveChange: (val: string) => {
                     item.note = val;
                    }
                  })
                }
              })
            }
          })
        }
        .scrollBar(BarState.Off)
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
    }
  }
}

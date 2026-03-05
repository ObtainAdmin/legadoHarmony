/**
 * @file NoteListItem.ets
 * @description 笔记列表项组件
 * 
 * 功能概述：
 * 1. 显示单个笔记的详细信息（内容、创建时间、备注）
 * 2. 提供笔记编辑功能（通过底部弹窗）
 * 3. 支持笔记操作菜单（复制、分享、删除）
 * 4. 实现字数统计和限制
 * 
 * 使用场景：
 * - 笔记列表中的单个笔记项显示
 * - 笔记内容的查看和编辑
 * - 笔记管理操作（复制、分享、删除）
 * 
 * 设计特点：
 * - 使用双层弹窗设计（操作菜单+编辑面板）
 * - 支持主题颜色配置
 * - 包含字数统计和限制
 * - 使用bindSheet实现底部弹窗
 * 
 * @copyright (C), 2024-05-13
 * @author LinXun
 * @date 2024/5/13 15:20
 * @version 1.0
 */

import CommonConstants from '../../../common/constants/CommonConstants'
import { NoteVO } from '../../../componetsmodel/NoteVO';
import CircleGeneralButton from './CircleGeneralButton';
import { promptAction } from '@kit.ArkUI';
import { ThemeItem } from '../../../common/model/Theme';
import { ThemeStorageKey } from '../../../common/constants/Theme';

/**
 * @class NoteListItem
 * @description 笔记列表项组件
 * 
 * 组件职责：
 * 1. 展示单个笔记的完整信息
 * 2. 管理笔记编辑状态
 * 3. 处理笔记操作（编辑、复制、分享、删除）
 * 4. 协调弹窗显示和隐藏
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct NoteListItem {
  /** 
   * @private noteVO - 笔记数据对象
   * @description 包含笔记内容、创建时间、备注等信息
   * @type {NoteVO}
   * @default 示例笔记数据
   */
  private  noteVO: NoteVO = new NoteVO(1, '许七安幽幽醒来，嗅到了空气中潮湿的腐臭味，令人轻微的不适，胃酸翻涌', '2020-03-14 12:34');
  
  /** 
   * @state newPanelFlag - 操作面板显示标志
   * @description 控制操作菜单弹窗的显示/隐藏
   * @default false - 默认不显示
   * @type {boolean}
   */
  @State newPanelFlag: boolean = false;
  
  /** 
   * @state editPanelFlag - 编辑面板显示标志
   * @description 控制编辑弹窗的显示/隐藏
   * @default false - 默认不显示
   * @type {boolean}
   */
  @State editPanelFlag: boolean = false;
  
  /** 
   * @state wordCount - 字数统计
   * @description 当前编辑内容的字数统计
   * @default 48 - 默认值，最大字数限制
   * @type {number}
   */
  @State wordCount: number = 48;
  
  /** 
   * @state editContent - 编辑内容
   * @description 正在编辑的笔记内容
   * @default '' - 默认空字符串
   * @type {string}
   */
  @State editContent: string = '';
  
  /** 
   * @private saveChange - 保存变更回调函数
   * @description 当笔记内容保存时调用的回调函数
   * @type {Function}
   * @param {string} val - 保存的笔记内容
   */
  private saveChange = (val: string) => {};
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * @method textChange
   * @description 文本内容变更处理函数
   * 
   * 功能：
   * 1. 更新编辑内容
   * 2. 重新计算字数统计
   * 
   * @param {string} val - 新的文本内容
   * @returns {void}
   */
  textChange(val: string): void {
    this.editContent = val;
    this.wordCount = this.editContent.length;
  }
  
  /**
   * @method save
   * @description 保存笔记内容
   * 
   * 操作流程：
   * 1. 更新笔记对象的note属性
   * 2. 调用保存回调函数
   * 3. 关闭所有弹窗
   * 4. 显示保存成功提示
   * 
   * @returns {void}
   */
  save() {
    this.noteVO.note = this.editContent;
    this.saveChange(this.editContent);
    this.newPanelFlag = false;
    this.editPanelFlag = false;
    promptAction.showToast({ message: '修改成功'})
  }
  /**
   * @builder EditPanelDialog
   * @description 编辑面板弹窗构建器
   * 
   * 功能特点：
   * 1. 提供笔记编辑界面
   * 2. 显示原笔记内容和编辑区域
   * 3. 包含字数统计和保存功能
   * 
   * 布局结构：
   * 1. 顶部操作栏：关闭按钮、字数统计、保存按钮
   * 2. 中部：原笔记内容展示区（带引用图标）
   * 3. 底部：文本编辑区域（TextArea）
   * 
   * 交互功能：
   * - 点击关闭按钮：隐藏编辑面板
   * - 文本编辑：实时字数统计和限制（最大48字）
   * - 点击保存按钮：调用save方法保存内容
   * 
   * @returns {void}
   */
  @Builder EditPanelDialog() {
    Column() {
      // 顶部操作栏
      Row({space: 12}) {
        // 关闭按钮
        Image($r('app.media.ic_public_dis_confirm'))
          .width(24)
          .height(24)
          .fillColor('#e0000000')
          .onClick(() => {
            this.editPanelFlag = false;
          })
        Blank() // 占位空间，实现左右布局
        // 字数统计：当前字数/最大字数
        Text() {
          Span(this.wordCount.toString())
          Span('/')
          Span('48')
        }
        .fontSize(14)
        .fontWeight(400)
        .lineHeight(22)
        .fontColor('#73000000')
        // 保存按钮
        Button('保存')
          .width(52)
          .height(22)
          .borderRadius(40)
          .padding({top: 2, bottom: 2, left: 16, right: 16})
          .backgroundColor(this.theme.mainColor) // 使用主题主色
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.save();
          })
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(48)
      .padding({top: 12, bottom: 12})
      
      // 编辑内容区域
      Column({space: 12}) {
        // 原笔记内容展示
        Row() {
          Text() {
            ImageSpan($r('app.media.ic_public_note_quote')) // 引用图标
              .width(20)
              .height(20)
            Span(this.noteVO.noteContent) // 原笔记内容
              .fontSize(12)
              .fontWeight(400)
              .lineHeight(20)
              .fontColor('#73000000')
          }
        }
        .width(CommonConstants.FULL_WIDTH)
        .padding({top: 12, bottom: 12, left: 16, right: 16})
        .height('auto')
        .borderRadius(8)
        .backgroundColor('#0a000000') // 浅灰色背景
        
        // 文本编辑区域
        TextArea({text: this.editContent})
          .height('auto')
          .fontColor('#e0000000')
          .caretColor(this.theme.mainColor) // 光标使用主题色
          .fontSize(12)
          .fontWeight(400)
          .fontColor('#e0000000')
          .maxLength(48) // 最大48个字符
          .onChange((val: string) => {
            this.textChange(val); // 文本变化时更新字数
          })
          .onAppear(() => {
            // 弹窗出现时初始化编辑内容
            if (this.noteVO.note) {
              this.editContent = this.noteVO.note;
            }
          })
      }
      .width(CommonConstants.FULL_WIDTH)
      .padding({top: 12, bottom: 16})
    }
    .width(CommonConstants.FULL_WIDTH)
    .height('auto')
    .padding({top: 8, left: 20, right: 20})
  }
  /**
   * @builder NewPanelDialog
   * @description 操作面板弹窗构建器
   * 
   * 功能特点：
   * 1. 提供笔记操作菜单（编辑、复制、分享、删除）
   * 2. 使用Grid布局展示四个操作按钮
   * 3. 包含取消按钮关闭弹窗
   * 
   * 布局结构：
   * 1. 顶部：4个操作按钮网格（编辑、复制、分享、删除）
   * 2. 中部：分隔线
   * 3. 底部：取消按钮
   * 
   * 交互功能：
   * - 点击编辑按钮：打开编辑面板弹窗
   * - 点击复制按钮：复制笔记内容（功能待实现）
   * - 点击分享按钮：分享笔记（功能待实现）
   * - 点击删除按钮：删除笔记（功能待实现）
   * - 点击取消按钮：关闭操作面板
   * 
   * 技术特点：
   * - 使用bindSheet嵌套，实现双层弹窗
   * - 编辑按钮点击后打开EditPanelDialog
   * - 使用Grid实现等分布局
   * 
   * @returns {void}
   */
  @Builder NewPanelDialog() {
    Column({space: 12}) {
      // 操作按钮网格
      Grid() {
        // 编辑按钮
        GridItem() {
          CircleGeneralButton()
            .onClick(() => {
              this.editPanelFlag = true; // 触发编辑面板显示
            })
            .bindSheet($$this.editPanelFlag, this.EditPanelDialog(), {
              height: SheetSize.FIT_CONTENT,
              showClose: false,
              dragBar: false,
              blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
              maskColor: 'rgba(0,0,0,0.6)',
              onDisappear: () => {
                // 弹窗消失时的回调
              }
            })
        }
        // 复制按钮
        GridItem() {
          CircleGeneralButton({icon: $r('app.media.ic_public_copy'), text: '复制'})
        }
        // 分享按钮
        GridItem() {
          CircleGeneralButton({icon: $r('app.media.ic_public_share'), text: '分享'})
        }
        // 删除按钮
        GridItem() {
          CircleGeneralButton({icon: $r('app.media.ic_public_delete'), text: '删除'})
        }
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(118)
      .columnsTemplate('1fr 1fr 1fr 1fr') // 4等分网格
      
      Divider() // 分隔线
      
      // 取消按钮
      Column() {
        Text('取消').fontSize(16).fontWeight(400)
          .lineHeight(24)
      }
      .height(56)
      .onClick(() => {
        this.newPanelFlag = false; // 关闭操作面板
      })
      .alignItems(HorizontalAlign.Center)
      .padding({
        left: 32,
        right: 32,
        top: 16,
        bottom: 16
      })
    }
    .width(CommonConstants.FULL_WIDTH)
    .padding({top: 12, bottom: 12})
    .backgroundColor('#0f000000') // 半透明黑色背景
  }
  
  /**
   * @method build
   * @description 构建笔记列表项主UI
   * 
   * 布局结构：
   * 1. 顶部：创建时间 + 更多操作按钮
   * 2. 中部：笔记内容（带引用图标）
   * 3. 底部：备注内容（如果有）
   * 
   * 交互功能：
   * - 点击更多按钮：打开操作面板（NewPanelDialog）
   * - 操作面板通过bindSheet绑定显示
   * 
   * 样式特点：
   * - 使用圆角矩形卡片设计
   * - 浅灰色背景区分内容
   * - 根据是否有备注动态调整底部内边距
   * - 备注区域有顶部边框分隔
   * 
   * 条件渲染：
   * - 如果noteVO.note为undefined，底部内边距为0
   * - 否则底部内边距为12px
   * 
   * @returns {void}
   */
  build() {
    Column({space: 12}) {
      Row() {
        Text(this.noteVO.createTime)
          .fontSize(12)
          .fontWeight(400)
          .lineHeight(20)
          .fontColor('#73000000')
        Blank()
        Image($r('app.media.more'))
          .width(16)
          .height(16)
          .fillColor('#73000000')
          .onClick(() => {
            this.newPanelFlag = true;
          })
          .bindSheet($$this.newPanelFlag, this.NewPanelDialog(), {
            height: SheetSize.FIT_CONTENT,
            showClose: false,
            dragBar: false,
            blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
            maskColor: 'rgba(0,0,0,0.6)',
            onDisappear: () => {
              // this.clickBookType = ''
            }
          })
      }
      .height(20)
      .width(CommonConstants.FULL_WIDTH)
      Text() {
        ImageSpan($r('app.media.ic_public_note_quote'))
          .width(20)
          .height(20)
        Span(this.noteVO.noteContent)
          .fontSize(12)
          .fontWeight(400)
          .lineHeight(20)
          .fontColor('#e0000000')
      }
      Text(this.noteVO.note)
        .fontSize(12)
        .fontWeight(400)
        .lineHeight(20)
        .fontColor('#73000000')
        .padding({top: 12})
        .border({
          width: {top: 1},
          color: '#0f000000'
        })
    }
    .width(CommonConstants.FULL_WIDTH)
    .height('auto')
    .borderRadius(8)
    .padding({left: 16, right: 16, top: 12, bottom: this.noteVO.note === undefined ? 0 : 12})
    .backgroundColor('#0a000000')
  }
}

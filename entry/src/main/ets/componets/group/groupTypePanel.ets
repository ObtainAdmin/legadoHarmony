/**
 * @file groupTypePanel.ets
 * @description 分组类型面板组件
 * 
 * 功能概述：
 * 1. 显示和管理书籍分组（显示分组和隐藏分组）
 * 2. 支持分组拖拽排序和编辑
 * 3. 提供分组显示/隐藏切换功能
 * 4. 支持标签锁功能控制分组标签栏行为
 * 
 * 使用场景：
 * - 分组管理页面
 * - 标签编辑页面
 * - 文件夹管理页面
 * - 需要批量管理分组的场景
 * 
 * 设计特点：
 * - 支持管理模式切换（管理/完成）
 * - 支持拖拽排序分组
 * - 支持分组显示/隐藏切换
 * - 提供标签锁功能控制滚动行为
 * - 使用Flex布局实现灵活的网格布局
 * 
 * 组件结构：
 * 1. 头部区域：标题 + 管理/完成按钮 + 关闭按钮
 * 2. 显示分组区域：使用GroupTypeColor/GroupType构建器显示分组
 * 3. 隐藏分组区域：显示被隐藏的分组，支持长按编辑
 * 4. 底部弹窗：分组详情弹窗和操作弹窗
 * 
 * 技术特点：
 * - 使用@Link装饰器实现父子组件数据同步
 * - 使用@State装饰器管理组件内部状态
 * - 使用@StorageProp装饰器获取本地存储配置
 * - 使用@Builder装饰器创建可复用的UI构建器
 * - 使用CustomDialogController管理自定义弹窗
 */

import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'
import bookGroupUtil from '../../common/utils/bookGroupUtils'
import BookGroupsDao from '../../database/dao/BookGroupsDao'
import { BookGroups } from '../../database/entities/BookGroups'
import BookManageDialog from '../../pages/view/bookShelf/components/dialog/BookManageDialog'
import FolderInfoDialog from '../../pages/view/bookShelf/components/dialog/FolderInfoDialog'
import { updateAppData } from '../../storage/appData'
import customizeDialogExample from '../common/customizeDialog'
import hideDialogExample from '../common/hideDialog'
import { showMessage } from '../common/promptShow'

/**
 * @class groupTypePanel
 * @description 分组类型面板组件
 * 
 * 组件职责：
 * 1. 管理分组的显示和隐藏
 * 2. 处理分组的拖拽排序
 * 3. 控制分组管理模式的切换
 * 4. 处理分组详情和操作弹窗
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct groupTypePanel {
  /** 
   * @link groupCoverShow - 分组面板显示状态
   * @description 控制分组面板的显示/隐藏，与父组件双向绑定
   * @type {boolean}
   */
  @Link groupCoverShow: boolean
  
  /** 
   * @state isShowIcon - 是否显示图标（管理模式）
   * @description 控制是否显示管理图标（删除/排序/添加图标）
   * @default false - 默认不显示
   * @type {boolean}
   */
  @State isShowIcon: boolean = false
  
  /** 
   * @prop showGroupList - 显示分组列表
   * @description 需要显示的分组列表，从父组件传入
   * @default [] - 默认空数组
   * @type {BookGroups[]}
   */
  @Prop showGroupList: BookGroups[] = []
  
  /** 
   * @state hideList - 隐藏分组列表
   * @description 被隐藏的分组列表，从数据库查询获取
   * @type {BookGroups[]}
   */
  @State hideList: BookGroups[] = []
  
  /** 
   * @prop currentIndex - 当前索引
   * @description 当前选中的分组类型索引，从父组件传入
   * @default 0 - 默认第一个
   * @type {number}
   */
  @Prop currentIndex: number = 0
  
  /** 
   * @storage APP_INDEX_SCROLLABLE - 应用索引可滚动
   * @description 控制标签栏是否可滚动的配置，存储在本地
   * @default true - 默认可滚动
   * @type {boolean}
   */
  @StorageProp('APP_INDEX_SCROLLABLE') APP_INDEX_SCROLLABLE: boolean = true
  
  /** 
   * @prop clickGroup - 点击的分组
   * @description 当前点击的分组对象，从父组件传入
   * @type {BookGroups}
   */
  @Prop clickGroup: BookGroups
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method aboutToAppear
   * @description 组件即将显示时的生命周期方法
   * 
   * 功能说明：
   * 1. 组件初始化时调用
   * 2. 获取隐藏分组列表数据
   * 
   * 调用时机：
   * - 组件首次创建时
   * - 组件从后台切换到前台时
   * 
   * @returns {void}
   */
  aboutToAppear(): void {
    this.getGroupList()
  }

  /**
   * @method getGroupList
   * @description 获取分组列表
   * 
   * 功能说明：
   * 1. 从数据库查询隐藏的分组数据
   * 2. 根据currentIndex和show条件筛选
   * 3. 更新hideList状态
   * 
   * 查询条件：
   * - type: this.currentIndex（分组类型）
   * - show: false（只查询隐藏的分组）
   * 
   * 数据流程：
   * 1. 调用BookGroupsDao.searchHide()查询数据库
   * 2. Promise.then()处理查询结果
   * 3. 将结果赋值给this.hideList
   * 
   * 注意事项：
   * - 使用异步查询，避免阻塞UI
   * - 只查询隐藏的分组（show为false）
   * - 需要导入BookGroupsDao和BookGroups
   * 
   * @returns {void}
   */
  getGroupList() {
    BookGroupsDao.searchHide({
      type: this.currentIndex,
      show: false
    }).then((val) => {
      this.hideList = val
    })
  }

  build() {
    Column({
      space: 15
    }) {
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.End
      }) {
        Row({ space: 12 }) {
          Text('显示分组').fontSize(16).fontWeight(500).lineHeight(24).fontColor('rgba(0, 0, 0, 0.88)')
          Text('点击进入').fontSize(12).fontWeight(400).lineHeight(20).fontColor('rgba(0, 0, 0, 0.45)')
        }.alignItems(VerticalAlign.Bottom)

        Row({ space: 12 }) {
          Text(this.isShowIcon ? '完成' : '管理')
            .fontSize(12)
            .fontWeight(400)
            .lineHeight(20)
            .fontColor(this.theme.mainColor)
            .onClick(() => {
              this.isShowIcon = !this.isShowIcon
            })
          Image($r('app.media.close')).width(24).height(20).onClick(() => {
            this.groupCoverShow = false
            this.isShowIcon = false
          })
        }
      }

      Flex({
        direction: FlexDirection.Row, wrap: FlexWrap.Wrap,
        justifyContent: FlexAlign.Start
      }) {
        ForEach(this.showGroupList, (item: BookGroups, index: number) => {
          if (item.show) {
            Row() {
              if (index === 0) {
                this.GroupTypeColor(item.groupName)
              } else {
                this.GroupType(item.groupName)
              }
              if (this.isShowIcon) {
                Image(!item.isSystem ? $r('app.media.clear') : $r('app.media.sort'))
                  .width(12)
                  .height(12)
                  .offset({ x: -20, y: -20 })
                  .onClick(() => {
                    if (!item.isSystem && item.groupId) {
                      this.isHide = true
                      this.checkListNumber = item.groupId
                      this.clickHideDialog?.open()
                    }
                  })
              }
            }
            .width('25%')
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.dragIndex = index // 获取当前拖拽子组件的索引
                console.info('onTouch' + this.dragIndex)
              }
            })
            .draggable(this.isShowIcon)
            .onDragStart(() => {
              console.log('onDragStart')
            })
            .onDrop((event: DragEvent, extraParams: string) => {
              console.log('onDrop')
              this.changeIndex(this.dragIndex, index, 0)
            })
            .onClick(() => {
              this.clickGroup = item
              this.isShowBookFolderInfoDialog = true
            })
          }
        })
      }

      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.End
      }) {
        Row({ space: 12 }) {
          Text('隐藏分组').fontSize(16).fontWeight(500).lineHeight(24).fontColor('rgba(0, 0, 0, 0.88)')
          Text('点击进入,长按编辑').fontSize(12).fontWeight(400).lineHeight(20).fontColor('rgba(0, 0, 0, 0.45)')
        }.alignItems(VerticalAlign.Bottom)

        Row({ space: 8 }) {
          Image($r('app.media.help')).width(20).height(20).onClick(() => {
            this.tagLockDialog?.open()
          })
          Text('标签锁').fontSize(16).fontWeight(500).lineHeight(24).fontColor('rgba(0, 0, 0, 0.45)')
          Toggle({ type: ToggleType.Switch, isOn: $$this.APP_INDEX_SCROLLABLE })
            .selectedColor(this.theme.mainColor).hoverEffect(HoverEffect.None)
            .onChange(() => {
              updateAppData(this.APP_INDEX_SCROLLABLE)
              showMessage(this.APP_INDEX_SCROLLABLE ? '标签栏锁已开启' : '标签栏已解锁')
            })
        }.alignItems(VerticalAlign.Bottom).justifyContent(FlexAlign.End)
      }

      if (this.hideList.length > 0) {
        Flex({
          direction: FlexDirection.Row, wrap: FlexWrap.Wrap, alignContent: FlexAlign.Center
        }) {
          ForEach(this.hideList, (item: BookGroups, index: number) => {
            Row() {
              this.GroupType(item.groupName)
              if (this.isShowIcon) {
                Image($r('app.media.add_new_fill')).width(12).height(12).offset({ x: -20, y: -20 })
                  .onClick(() => {
                    if (item.groupId) {
                      this.isHide = false
                      this.checkListNumber = item.groupId
                    }
                    this.clickHideDialog?.open()
                  })
              }
            }
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.dragIndex = index // 获取当前拖拽子组件的索引
                console.info('onTouch' + this.dragIndex)
              }
            })
            .draggable(this.isShowIcon)
            .onDragStart(() => {
              console.log('onDragStart')
            })
            .onDrop((event: DragEvent, extraParams: string) => {
              console.log('onDrop')
              this.changeIndex(this.dragIndex, index, 1)
            })
            .onClick(() => {
              this.clickGroup = item
              this.isShowBookFolderInfoDialog = true
            })
            .gesture(
              LongPressGesture({ repeat: false, duration: 500 })
                .onAction((event: GestureEvent) => {
                  this.dialogGroupData = item
                  // this.group = item
                  this.changeNumber = 1
                  this.groupInfoDialog?.open()
                }))
            .width('25%')
          })
        }
      } else {
        Flex({
          justifyContent: FlexAlign.Center
        }) {
          Text('暂无隐藏分组').fontSize(12).fontWeight(400).fontColor('rgba(0, 0, 0, 0.45)')
        }
        .borderRadius(4)
        .width('100%')
        .backgroundColor('rgba(0, 0, 0, 0.04)')
        .padding({ top: 6, bottom: 6 })

      }
      Flex()
        .bindSheet($$this.isShowBookFolderInfoDialog, this.bookFolderInfoDialog(), {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 200],
          showClose: false,
          dragBar: true,
          maskColor: 'rgba(0,0,0,0.6)',
          onDisappear: () => {
            console.log('隐藏')
          }
        })

    }
    .offset({ y: -15 })
    .borderRadius({ bottomLeft: 20, bottomRight: 20 })
    .padding({
      left: 15,
      right: 15,
      top: 12,
      bottom: 20
    })
    .width('100%')
    .backgroundColor(Color.White)
  }

  /** 
   * @state tagLockContent - 标签锁内容
   * @description 标签锁功能说明文本
   * @default '长按底部tab栏书架图标可锁定分组标签栏，再次长按解锁，锁定后左右滑动将直接切换小说，漫画，有声书分组大类。'
   * @type {string}
   */
  @State tagLockContent: string = '长按底部tab栏书架图标可锁定分组标签栏，再次长按解锁，锁定后左右滑动将直接切换小说，漫画，有声书分组大类。'
  
  /** 
   * @dialog tagLockDialog - 标签锁对话框
   * @description 标签锁功能说明对话框控制器
   * @type {CustomDialogController | null}
   */
  tagLockDialog: CustomDialogController | null = new CustomDialogController({
    builder: customizeDialogExample({
      confirm: () => {
        this.onAccept()
      },
      title: '标签锁',
      content: this.tagLockContent
    }),
    width: '90%',
    autoCancel: true,
    alignment: DialogAlignment.Center,
    // offset: { dx: 0, dy: '-40%' },
    gridCount: 4,
    customStyle: false,
    cornerRadius: 25
  })

  /**
   * @method onAccept
   * @description 标签锁对话框确认回调
   * 
   * 功能说明：
   * 1. 关闭标签锁对话框
   * 
   * @returns {void}
   */
  onAccept() {
    this.tagLockDialog?.close()
  }

  /** 
   * @state dragIndex - 拖拽索引
   * @description 当前拖拽的分组索引
   * @default 0
   * @type {number}
   */
  @State dragIndex: number = 0

  /**
   * @method changeIndex
   * @description 改变分组索引（拖拽排序）
   * 
   * 功能说明：
   * 1. 处理分组拖拽排序逻辑
   * 2. 验证是否处于管理模式
   * 3. 记录拖拽操作日志
   * 
   * 参数说明：
   * @param {number} index1 - 原始索引
   * @param {number} index2 - 目标索引
   * @param {number} [type=2] - 分组类型（0:显示分组, 1:隐藏分组, 2:未指定）
   * 
   * 验证逻辑：
   * 1. 检查isShowIcon是否为true（管理模式）
   * 2. 如果不是管理模式，显示提示信息
   * 
   * 当前状态：
   * - 仅记录日志，未实现实际的数据库排序更新
   * - TODO: 更新排序顺序到数据库中sort字段
   * 
   * 使用场景：
   * - 显示分组拖拽排序
   * - 隐藏分组拖拽排序
   * 
   * @returns {void}
   */
  changeIndex(index1: number, index2: number, type: number = 2) { // 交换数组位置
    if (!this.isShowIcon) {
      showMessage('请在管理状态下拖到改变顺序')
      return
    }
    console.log('changeIndex' + index1 + ',' + index2)
    //TODO 更新排序顺序到数据库中sort
  }

  /**
   * @builder GroupTypeColor
   * @description 分组类型颜色构建器（第一个分组特殊样式）
   * 
   * 功能说明：
   * 1. 创建第一个分组的特殊样式
   * 2. 使用主题主色作为文字颜色
   * 3. 使用主题次色作为背景色
   * 
   * 参数说明：
   * @param {string} title - 分组标题
   * 
   * 样式说明：
   * - 文字：主题主色，12px字体，500字重，居中，单行省略
   * - 容器：68px宽度，主题次色背景，内边距16/6px，外边距右/下16px
   * - 布局：Column容器，Row内容居中
   * 
   * 使用场景：
   * - 显示分组列表的第一个分组
   * - 需要突出显示的重要分组
   * 
   * 设计理念：
   * - 第一个分组使用特殊样式，增强视觉层次
   * - 使用主题颜色保持界面一致性
   * - 固定宽度确保布局整齐
   * 
   * @returns {void}
   */
  @Builder
  GroupTypeColor(title: string) {
    Column() {
      Row() {
        Text(title)
          .fontWeight(500)
          .fontSize(12)
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
          .ellipsisMode(EllipsisMode.END)
          .maxLines(1)
          .fontColor(this.theme.mainColor)
          .textAlign(TextAlign.Center)
      }
      .margin({ right: 16, bottom: 16 })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width(68)
      .backgroundColor(this.theme.secondColor)
      .padding({
        left: 16,
        right: 16,
        top: 6,
        bottom: 6
      })
    }
  }

  /**
   * @builder GroupType
   * @description 分组类型构建器（普通分组样式）
   * 
   * 功能说明：
   * 1. 创建普通分组的样式
   * 2. 使用黑色文字
   * 3. 使用4%黑色作为背景色
   * 
   * 参数说明：
   * @param {string} title - 分组标题
   * 
   * 样式说明：
   * - 文字：黑色，12px字体，500字重，居中，单行省略
   * - 容器：68px宽度，4%黑色背景，内边距16/6px，外边距右/下16px
   * - 布局：Column容器，Row内容居中
   * 
   * 使用场景：
   * - 显示分组列表的普通分组
   * - 隐藏分组列表的所有分组
   * 
   * 设计理念：
   * - 简洁的灰色背景，不分散用户注意力
   * - 固定宽度确保布局整齐
   * - 与GroupTypeColor形成视觉对比
   * 
   * @returns {void}
   */
  @Builder
  GroupType(title: string) {
    Column() {
      Row() {
        Text(title)
          .fontWeight(500)
          .fontSize(12)
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
          .ellipsisMode(EllipsisMode.END)
          .maxLines(1)
          .fontColor(Color.Black)
          .textAlign(TextAlign.Center)
      }
      .margin({ right: 16, bottom: 16 })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width(68)
      .backgroundColor('rgba(0, 0, 0, 0.04)')
      .padding({
        left: 16,
        right: 16,
        top: 6,
        bottom: 6
      })
    }
  }

  /** 
   * @state changeNumber - 改变编号
   * @description 分组操作类型编号（当前未使用）
   * @default 0
   * @type {number}
   */
  @State changeNumber: number = 0
  
  /** 
   * @state dialogGroupData - 对话框分组数据
   * @description 对话框中显示的分组数据
   * @type {BookGroups}
   */
  @State dialogGroupData: BookGroups = new BookGroups()
  
  /** 
   * @dialog groupInfoDialog - 分组信息对话框
   * @description 分组信息编辑对话框控制器
   * @type {CustomDialogController | null}
   */
  groupInfoDialog: CustomDialogController | null = new CustomDialogController({
    builder: FolderInfoDialog({
      itemData: this.dialogGroupData,
      cancel: () => {
        this.exitDialog()
      }
    }),
    cancel: this.exitDialog,
    autoCancel: true,
    width: '100%',
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })

  /**
   * @method exitDialog
   * @description 退出对话框
   * 
   * 功能说明：
   * 1. 重置changeNumber状态
   * 2. 重新获取分组列表
   * 3. 关闭分组信息对话框
   * 
   * 调用时机：
   * - 对话框取消时
   * - 对话框操作完成时
   * 
   * @returns {void}
   */
  exitDialog() {
    this.changeNumber = 0
    this.getGroupList()
    this.groupInfoDialog?.close()
  }

  /** 
   * @state isShowBookFolderInfoDialog - 是否显示书籍文件夹信息对话框
   * @description 控制书籍文件夹信息对话框的显示/隐藏
   * @default false
   * @type {boolean}
   */
  @State isShowBookFolderInfoDialog: boolean = false

  /**
   * @builder bookFolderInfoDialog
   * @description 书籍文件夹信息对话框构建器
   * 
   * 功能说明：
   * 1. 创建书籍管理对话框
   * 2. 传递当前分组信息
   * 
   * 参数传递：
   * - title: 分组名称
   * - currentIndex: 当前分组类型索引
   * - bookTypeNumber: 分组ID
   * 
   * 对话框功能：
   * - 显示分组详情
   * - 管理分组中的书籍
   * - 支持书籍搜索和筛选
   * 
   * 使用场景：
   * - 点击分组时显示
   * - 需要管理分组内容时
   * 
   * @returns {void}
   */
  @Builder
  bookFolderInfoDialog() {
    Column() {
      BookManageDialog({
        title: this.clickGroup.groupName,
        currentIndex: this.currentIndex,
        bookTypeNumber: this.clickGroup.groupId,
      })
    }
  }

  /** 
   * @state checkListNumber - 检查列表编号
   * @description 需要显示/隐藏的分组ID
   * @default 0
   * @type {number}
   */
  @State checkListNumber: number = 0
  
  /** 
   * @state isHide - 是否隐藏
   * @description 标识操作是隐藏还是显示分组
   * @default false
   * @type {boolean}
   */
  @State isHide: boolean = false
  
  /** 
   * @storagelink BOOK_IS_BOOK_GROUPS_REFRESHING - 分组刷新状态
   * @description 分组刷新状态，存储在本地，用于触发数据刷新
   * @default 0
   * @type {number}
   */
  @StorageLink('BOOK_IS_BOOK_GROUPS_REFRESHING') BOOK_IS_BOOK_GROUPS_REFRESHING: number = 0
  
  /** 
   * @dialog clickHideDialog - 点击隐藏对话框
   * @description 分组显示/隐藏操作对话框控制器
   * @type {CustomDialogController | null}
   */
  clickHideDialog: CustomDialogController | null = new CustomDialogController({
    builder: hideDialogExample({
      confirm: () => {
        this.clickHideAccept()
      },
      isHide: this.isHide
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    gridCount: 4,
    customStyle: false,
    cornerRadius: 25,
  })

  /**
   * @method clickHideAccept
   * @description 点击隐藏对话框确认回调
   * 
   * 功能说明：
   * 1. 更新分组显示状态
   * 2. 延迟重新获取分组列表
   * 3. 触发分组刷新状态更新
   * 4. 显示操作成功提示
   * 5. 重置相关状态
   * 
   * 操作逻辑：
   * 1. 调用bookGroupUtil.updateGroupShow()更新分组显示状态
   * 2. 延迟500ms确保数据库更新完成
   * 3. 重新获取分组列表
   * 4. 增加BOOK_IS_BOOK_GROUPS_REFRESHING触发刷新
   * 5. 显示成功提示信息
   * 6. 重置checkListNumber和isHide状态
   * 
   * 注意事项：
   * - 使用setTimeout确保数据库操作完成
   * - BOOK_IS_BOOK_GROUPS_REFRESHING++会触发其他组件的刷新
   * - 提示信息根据操作类型动态显示
   * 
   * @returns {void}
   */
  clickHideAccept() {
    bookGroupUtil.updateGroupShow(this.checkListNumber, !this.isHide)
    setTimeout(() => {
      this.getGroupList()
      this.BOOK_IS_BOOK_GROUPS_REFRESHING++
      showMessage('显示成功')
    }, 500)
    this.checkListNumber = 0
    this.isHide = false
  }
}
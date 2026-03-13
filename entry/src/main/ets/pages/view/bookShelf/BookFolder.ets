/**
 * 书籍文件夹组件 - 显示和管理书籍分组（文件夹）
 * 
 * 功能概述：
 * 1. 显示书籍分组列表，支持宫格和列表两种展示模式
 * 2. 提供分组管理功能：长按编辑、点击查看详情
 * 3. 支持分组置顶、封面显示等特性
 * 4. 管理分组数据的加载和刷新
 * 5. 提供分组信息对话框和分组管理对话框
 * 
 * 展示模式：
 * - 宫格模式：3列网格布局，显示封面、分组名称、书籍数量
 * - 列表模式：单列列表布局，显示封面、分组名称、书籍数量
 * 
 * 交互功能：
 * - 点击分组：打开分组管理对话框
 * - 长按分组：打开分组信息编辑对话框
 * - 支持分组置顶标记显示
 * 
 * 数据源：
 * 从数据库通过BookGroupsDao获取分组数据
 * 支持按类型筛选和实时刷新
 */

import { it } from '@ohos/hypium'
import BookOverlay from '../../../componets/bookDetail/BookOverlay'
import { showMessage } from '../../../componets/common/promptShow'
import { folderList } from '../../../componets/dataList/folderList'
import BookGroupsDao from '../../../database/dao/BookGroupsDao'
import { BookGroups } from '../../../database/entities/BookGroups'
import BookManageDialog from './components/dialog/BookManageDialog'
import FolderInfoDialog from './components/dialog/FolderInfoDialog'

/**
 * 书籍文件夹组件结构体
 * 
 * 职责：
 * 1. 管理书籍分组的显示和布局
 * 2. 处理分组数据的加载和状态管理
 * 3. 提供分组交互功能（点击、长按）
 * 4. 管理分组相关对话框的显示
 * 5. 支持不同展示模式的切换
 * 
 * 组件特点：
 * - 使用@Component装饰器，表示这是一个可复用的UI组件
 * - 使用export default导出，供其他页面引用
 * - 支持响应式设计，根据EXHIBIT属性切换展示模式
 * - 集成数据库操作，实时同步分组数据
 */
@Component
export default struct BookFolder {
  /** 展示模式：'宫格'表示网格布局，其他值表示列表布局 */
  @Prop EXHIBIT: string
  
  /** 当前分组类型索引，用于筛选特定类型的分组 */
  currentIndex: number = 0
  
  /** 对话框状态变化标记，用于触发UI更新 */
  @State changeNumber: number = 0
  
  /** 分组管理对话框显示状态 */
  @State isShowBookFolderInfoDialog: boolean = false
  
  /** 分组数据刷新标记，存储在应用存储中，变化时自动调用getGroupList */
  @StorageLink('BOOK_IS_BOOK_GROUPS_REFRESHING') @Watch('getGroupList') BOOK_IS_BOOK_GROUPS_REFRESHING: number = 0

  /**
   * 组件即将出现时调用的生命周期方法
   * 功能：初始化分组数据
   */
  aboutToAppear(): void {
    this.getGroupList()
  }

  /** 分组数据列表，从数据库加载的BookGroups对象数组 */
  @State groupList: BookGroups[] = []

  /**
   * 获取分组列表数据
   * 功能：从数据库查询指定类型的分组数据，并更新状态
   * 异步操作：数据库查询是异步操作，使用Promise处理结果
   */
  getGroupList() {
    BookGroupsDao.search({
      type: this.currentIndex
    }).then((val) => {
      this.groupList = val
    })
  }

  /**
   * 构建书籍文件夹组件UI的主要方法
   * 
   * 布局逻辑：
   * 1. 根据EXHIBIT属性决定使用网格布局（3列）还是列表布局（1列）
   * 2. 遍历分组数据，过滤显示非系统分组
   * 3. 根据展示模式调用不同的Builder函数渲染每个分组
   * 
   * 交互功能：
   * - 长按手势：打开分组信息编辑对话框
   * - 点击事件：打开分组管理对话框（底部面板）
   * 
   * 设计特点：
   * - 使用GridRow实现响应式布局
   * - 使用bindSheet实现底部面板
   * - 支持手势交互
   */
  build() {
    GridRow({
      columns: this.EXHIBIT === '宫格' ? 3 : 1  // 宫格模式3列，列表模式1列
    }) {
      ForEach(this.groupList, (item: BookGroups) => {
        if (item.show && !item.isSystem) {  // 只显示可见的非系统分组
          GridCol() {
            Column() {
              // 根据展示模式选择不同的渲染方式
              if (this.EXHIBIT === '宫格') {
                this.bookInfoGrid(item)  // 宫格模式
              } else {
                this.bookFolderInfo(item)  // 列表模式
              }
            }
          }
          // 长按手势：打开分组信息编辑对话框
          .gesture(
            LongPressGesture({ repeat: false, duration: 500 })
              .onAction((event: GestureEvent) => {
                this.dialogGroupData = item
                this.changeNumber = 1
                this.groupInfoDialog?.open()
              }))
          // 点击事件：打开分组管理对话框（底部面板）
          .onClick(() => {
            this.isShowBookFolderInfoDialog = true
            this.clickGroup = item
          })
        }
      })
    }
    // 绑定底部面板：分组管理对话框
    .bindSheet($$this.isShowBookFolderInfoDialog, this.bookFolderInfoDialog(), {
      detents: [SheetSize.MEDIUM, SheetSize.LARGE, 200],  // 面板停靠位置
      showClose: false,  // 不显示关闭按钮
      dragBar: true,  // 显示拖拽条
      maskColor: 'rgba(0,0,0,0.6)',  // 遮罩颜色
      onDisappear: () => {
        console.log('隐藏')
      }
    })
  }

  /** 当前点击的分组数据，用于传递给对话框 */
  @Prop clickGroup: BookGroups

  /**
   * 构建分组管理对话框的Builder函数
   * 
   * 功能：创建底部面板内容，显示分组管理对话框
   * 传递参数：
   * - title: 分组名称，作为对话框标题
   * - currentIndex: 当前分组类型索引
   * - bookTypeNumber: 分组ID，用于标识具体分组
   * 
   * 使用场景：用户点击分组时显示，用于管理分组内的书籍
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
   * 构建宫格模式下的分组项UI
   * 
   * 布局结构：
   * 1. 封面区域：使用Stack实现多层重叠效果
   *   - 置顶标签（如果分组被置顶）
   *   - 封面图片
   *   - 阴影效果（如果coverType不等于2）
   * 2. 白色装饰条：增加视觉层次
   * 3. 分组名称：大号粗体，限制2行显示
   * 4. 书籍数量：小号灰色文字，显示分组中的书籍数量
   * 
   * 设计特点：
   * - 使用zIndex控制图层叠加顺序
   * - 支持置顶标签显示
   * - 根据coverType决定是否显示阴影效果
   * - 使用装饰条增加立体感
   * 
   * @param item 分组数据对象
   */
  @Builder
  bookInfoGrid(item: BookGroups) {
    Column({
      space: 5
    }) {
      Column() {
        Column() {
          Stack() {
            Stack() {
              Stack() {
                // 置顶标签：如果分组被置顶，显示"置顶"标签
                if (item.isTop) {
                  Text('置顶')
                    .fontColor(Color.White)
                    .fontWeight(300)
                    .fontSize(8)
                    .padding(3)
                    .borderRadius(5)
                    .backgroundColor('rgba(0, 0, 0, 0.45)')
                    .zIndex(1)
                }
                // 封面图片
                Image(item.coverUrl)
                  .draggable(false)
                  .alt($r('app.media.icon_book_default_cover_one'))  // 加载失败时的默认图片
                  .width(88)
                  .height(120)
              }.alignContent(Alignment.BottomStart)
            }
            .zIndex(2)

            // 阴影效果：如果coverType不等于2，显示两层阴影
            if (item.coverType !== 2) {
              Row() {
                Image($r('app.media.occlusion1')).draggable(false)
              }
              .zIndex(1)
              .width(95).height(110)

              Row() {
                Image($r('app.media.occlusion2'))
              }.zIndex(0)
              .width(100).height(100)
            }
          }
          .align(Alignment.BottomStart)
        }

        // 白色装饰条，增加视觉层次感
        Row().width(100).height(20).backgroundColor('rgba(255, 255, 255, 0.6)').borderRadius(10)
      }

      // 分组名称：大号粗体，限制2行显示
      Text(item.groupName)
        .fontSize(15)
        .fontWeight(700)
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })
        .ellipsisMode(EllipsisMode.END)
        .maxLines(2)
      
      // 书籍数量：显示分组中的书籍总数
      Text(`共${item.bookIds?.length || 0}本`)
        .fontSize(12)
        .fontColor('rgb(174,174,174)')
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })
        .ellipsisMode(EllipsisMode.END)
        .fontWeight(500)
        .maxLines(1)
    }
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: 8,
      right: 8,
      bottom: 5,
      top: 5
    })
  }

  /**
   * 构建列表模式下的分组项UI
   * 
   * 布局结构：
   * 1. 使用Flex布局，内容居中对齐，两端分布
   * 2. 左侧：封面图片（使用BookOverlay组件）
   * 3. 右侧：分组信息和书籍数量
   *   - 分组名称：粗体显示
   *   - 书籍数量：小号灰色文字
   * 
   * 设计特点：
   * - 使用BookOverlay组件显示封面，支持置顶和封面类型
   * - 简洁的列表布局，适合显示大量分组
   * - 使用圆角和内边距增加视觉舒适度
   * 
   * @param group 分组数据对象
   */
  @Builder
  bookFolderInfo(group: BookGroups) {
    Flex(
      {
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.SpaceBetween
      }
    ) {
      Row({
        space: 20
      }) {
        // 使用BookOverlay组件显示封面，支持置顶标记和封面类型
        BookOverlay({
          bookImage: group.coverUrl,
          isTop: group.isTop,
          coverType: group.coverType
        })
        
        // 分组信息列
        Column({
          space: 24
        }) {
          // 分组名称
          Text(group.groupName)
            .fontWeight(700)
          
          Column() {
            // 书籍数量
            Text(`共${group.bookIds?.length || 0}本`)
              .fontSize(12)
              .fontColor('rgb(174,174,174)')
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
              .ellipsisMode(EllipsisMode.END)
              .fontWeight(400)
              .maxLines(1)
              .lineHeight(20)
            
            // 注释掉的更新信息显示（备用功能）
            // Text(group.newUpdateBook?group.newUpdateBook:'暂无更新')
            //   .fontSize(12)
            //   .fontWeight(400)
            //   .textOverflow({
            //     overflow:TextOverflow.Ellipsis
            //   })
            //   .ellipsisMode(EllipsisMode.END)
            //   .maxLines(1)
            //   .lineHeight(20)
          }
          .width('60%')
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
      }
    }
    .padding(10)
    .borderRadius(10)
  }

  /** 对话框分组数据，用于传递给分组信息编辑对话框 */
  @State dialogGroupData: BookGroups = new BookGroups()
  
  /** 分组信息编辑对话框控制器，管理对话框的显示和隐藏 */
  groupInfoDialog: CustomDialogController | null = new CustomDialogController({
    builder: FolderInfoDialog({
      itemData: this.dialogGroupData,  // 传递分组数据
      cancel: () => {
        this.exitDialog()  // 取消回调
      }
    }),
    cancel: this.exitDialog,  // 取消回调函数
    autoCancel: true,  // 点击外部自动取消
    width: '100%',  // 对话框宽度
    alignment: DialogAlignment.Bottom,  // 底部对齐
    customStyle: true  // 使用自定义样式

  })

  /**
   * 退出对话框
   * 功能：关闭分组信息编辑对话框并重置状态
   * 操作：
   * 1. 重置changeNumber状态标记
   * 2. 关闭对话框
   */
  exitDialog() {
    this.changeNumber = 0
    this.groupInfoDialog?.close()
  }
}

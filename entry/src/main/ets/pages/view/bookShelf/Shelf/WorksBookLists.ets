/**
 * 书单列表组件
 * 
 * 功能概述：
 * 1. 展示书单列表，支持"宫格"和"列表"两种展示模式
 * 2. 提供书单选择功能，支持批量管理
 * 3. 集成书单详情查看和编辑功能
 * 4. 支持长按操作，显示书单操作菜单
 * 5. 响应数据刷新，自动更新书单列表
 * 
 * 使用场景：
 * - 在书架页面展示用户创建的书单
 * - 在书单管理页面进行批量操作
 * - 在其他需要展示书单列表的场景中使用
 * 
 * 组件特点：
 * - 支持动态切换展示模式（宫格/列表）
 * - 集成书单编辑功能，支持预览和修改
 * - 提供长按操作菜单，快速访问常用功能
 * - 响应数据变化，自动刷新书单列表
 * - 使用对话框和弹窗提供丰富的交互体验
 */
import confirmDialogExample from '../../../../componets/common/confirmDialog'
import { showMessage } from '../../../../componets/common/promptShow'
import { WorksLists } from '../../../../database/entities/WorksLists'
import WorksBookListGrid from './WorksBookListGrid'
import worksBookInfoDialog from '../../dialog/worksBookInfoDialog'
import WorksBookListInfo from './WorksBookListInfo'
import worksListsDao from '../../../../database/dao/WorksListsDao'
import newBookShelf from '../Manage/bookManage/newBookShelf'

@Component
export default struct WorksBookLists {
  /** 
   * 复选框状态记录，键为书单ID，值为是否选中
   * 通过@Link装饰器与父组件双向绑定，同步选择状态
   */
  @Link checkGroup: Record<number, boolean>
  
  /** 
   * 展示模式：'宫格'或'列表'
   * 控制书单的展示方式
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop EXHIBIT: string
  
  /** 
   * 当前索引，用于区分不同的书籍类型或分类
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop currentIndex: number
  
  /** 
   * 书单列表数据
   * 通过@Prop装饰器从父组件传递，单向绑定
   * 默认值：空数组
   */
  @Prop worksLists: WorksLists[] = []
  
  /** 
   * 是否显示复选框（用于批量选择）
   * true: 显示复选框，进入选择模式
   * false: 隐藏复选框，正常显示模式
   * 默认值：false
   */
  @Prop isShowCheck: boolean = false
  
  /** 
   * 当前选中的书单数据
   * 通过@State装饰器管理组件内部状态
   * 初始化为空书单对象
   */
  @State worksBook: WorksLists = new WorksLists()
  
  /** 
   * 书单列表刷新状态标识
   * 通过@StorageLink与AppStorage同步，触发书单数据刷新
   * 使用@Watch装饰器监听变化，变化时触发getWorkLists方法
   */
  @StorageLink('BOOK_IS_BOOK_WORKS_BOOK_LIST') @Watch('getWorkLists') isWorksBookListRefreshing: number = 0
  
  /** 
   * 选择回调函数，当用户选择书单时触发
   * 默认为空函数，父组件可以覆盖此函数以处理选择逻辑
   */
  onSelect: Function = () => {
  }

  /**
   * 组件显示时初始化数据
   * 
   * 功能：如果传入的书单列表为空，则从数据库加载书单数据
   * 逻辑：检查worksLists是否为空，为空则调用getWorkLists方法
   */
  aboutToAppear(): void {
    if (this.worksLists.length === 0) {
      this.getWorkLists()  // 加载书单列表
    }
  }

  /** 
   * 书单状态：1-预览（默认）
   * 用于控制书单编辑界面的显示状态
   */
  @State workBookListStatus: number = 1

  /**
   * 获取书单列表
   * 
   * 功能：从数据库查询当前类型的书单数据
   * 使用worksListsDao.search方法，根据currentIndex（类型）查询
   */
  getWorkLists() {
    worksListsDao.search({
      type: this.currentIndex  // 书籍类型
    }).then((val) => {
      this.worksLists = val  // 更新书单列表
    })
  }

  /**
   * 构建组件UI
   * 
   * 布局结构：
   * 1. 使用Column布局作为容器
   * 2. 根据EXHIBIT模式动态渲染书单列表：
   *    - '宫格'模式：使用WorksBookListGrid组件，3列网格
   *    - '列表'模式：使用WorksBookListInfo组件，1列列表
   * 3. 集成书单编辑弹窗（全屏覆盖）
   * 
   * 交互功能：
   * - 点击书单：进入书单编辑/预览界面
   * - 长按书单：显示书单操作菜单
   * - 复选框选择：支持批量选择书单
   */
  build() {
    Column() {
      // 书单列表网格/列表
      GridRow({
        columns: this.EXHIBIT === '宫格' ? 3 : 1  // 动态列数：宫格3列，列表1列
      }) {
        // 遍历书单列表，渲染每个书单项
        ForEach(this.worksLists, (item: WorksLists, index: number) => {
          GridCol() {
            if (this.EXHIBIT === '宫格') {
              // 宫格模式：使用WorksBookListGrid组件
              WorksBookListGrid({
                work: item,                    // 书单数据
                isShowCheck: this.isShowCheck, // 是否显示复选框
                checkGroup: this.checkGroup,   // 复选框状态记录
                onSelect: () => {
                  this.onSelect()  // 触发选择回调
                }
              }).width('33%')  // 宽度33%（3列布局）
                .gesture(
                  // 长按手势：显示书单操作菜单
                  LongPressGesture({ repeat: false, duration: 500 })
                    .onAction((event: GestureEvent) => {
                        this.worksBook = item  // 设置当前书单
                        this.shelfInfoDialog?.open()  // 打开书单操作菜单
                    }))
                .onClick(() => {
                    // 点击：进入书单编辑/预览界面
                    this.worksBook = item  // 设置当前书单
                    this.isShowEditBook = true  // 显示书单编辑弹窗
                })

            } else {
              // 列表模式：使用WorksBookListInfo组件
              WorksBookListInfo({
                work: item,                    // 书单数据
                isShowCheck: this.isShowCheck, // 是否显示复选框
                checkGroup: this.checkGroup,   // 复选框状态记录
                onSelect: () => {
                  this.onSelect()  // 触发选择回调
                }
              })
                .gesture(
                  // 长按手势：显示书单操作菜单
                  LongPressGesture({ repeat: false, duration: 500 })
                    .onAction((event: GestureEvent) => {
                      this.worksBook = item  // 设置当前书单
                      this.shelfInfoDialog?.open()  // 打开书单操作菜单
                    }))
                .onClick(() => {
                  // 点击：进入书单编辑/预览界面
                  this.worksBook = item  // 设置当前书单
                  this.isShowEditBook = true  // 显示书单编辑弹窗
                })
            }
          }
        })
      }

      // 书单编辑弹窗（全屏覆盖）
      Flex()
        .bindContentCover($$this.isShowEditBook, this.showEditBook(), {
          modalTransition: ModalTransition.DEFAULT,  // 默认过渡动画
          onDisappear: () => {
            this.isShowEditBook = false;  // 弹窗消失时重置状态
          }
        })
    }
  }

  /** 
   * 是否显示书单编辑弹窗
   * true: 显示书单编辑界面
   * false: 隐藏书单编辑界面
   */
  @State isShowEditBook: boolean = false

  /**
   * 书单编辑弹窗构建器
   * 
   * 功能：构建书单编辑界面的全屏覆盖弹窗
   * 使用newBookShelf组件，支持书单的预览和修改
   * 
   * @returns 书单编辑弹窗的UI内容
   */
  @Builder
  showEditBook() {
    Column() {
      newBookShelf({
        currentIndex: this.currentIndex,  // 当前索引
        changeShowNumber: () => {
          this.isShowEditBook = false  // 关闭弹窗
          setTimeout(() => {
            this.getWorkLists()  // 延迟刷新书单列表
          }, 200)
        },
        returnClose: true,  // 返回时关闭页面
        workBookListStatus: this.workBookListStatus,  // 书单状态
        lastWorkBookList: this.worksBook  // 当前书单数据
      })
    }
    .backgroundColor(Color.White)  // 白色背景
  }

  /** 
   * 书单操作菜单对话框控制器
   * 用于显示书单操作菜单（底部弹窗）
   */
  shelfInfoDialog: CustomDialogController | null = new CustomDialogController({
    builder: worksBookInfoDialog({
      works: this.worksBook,  // 当前书单数据
      cancel: () => {
        this.exitDialog()  // 取消回调
      }
    }),
    cancel: this.exitDialog,  // 取消回调函数
    autoCancel: true,         // 点击背景自动关闭
    width: '100%',            // 全屏宽度
    alignment: DialogAlignment.Bottom,  // 底部对齐
    customStyle: true         // 使用自定义样式

  })

  /**
   * 退出对话框处理函数
   * 
   * 功能：对话框关闭后刷新书单列表
   * 延迟100ms后调用getWorkLists方法，确保数据更新
   */
  exitDialog() {
    setTimeout(() => {
      this.getWorkLists()  // 刷新书单列表
    }, 100)
  }

  /** 
   * 是否删除缓存
   * 用于控制删除操作的相关状态
   */
  @State delCache: boolean = false
  
  /** 
   * 书单删除确认对话框控制器
   * 用于显示删除确认对话框，防止误操作
   */
  shelfInfoDel: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      cancel: () => {
        this.onCancel()  // 取消回调
      },
      confirm: () => {
        this.onAccept()  // 确认回调
      },
      delCache: this.delCache  // 是否删除缓存
    }),
    cancel: this.exitApp,      // 取消回调函数
    autoCancel: true,          // 点击背景自动关闭
    alignment: DialogAlignment.Center,  // 居中显示
    gridCount: 4,              // 网格数量为4
    customStyle: false,        // 不使用自定义样式
    cornerRadius: 25,          // 圆角半径为25
  })

  /**
   * 取消删除操作
   * 目前为空实现，可根据需要添加取消逻辑
   */
  onCancel() {
    //this.isClear = false  // 注释掉的代码，可能用于控制清除状态
  }

  /**
   * 确认删除操作
   * 调用delShelf方法执行删除操作
   */
  onAccept() {
    this.delShelf()  // 执行删除操作
  }

  /**
   * 删除书单功能
   * 
   * 功能：删除当前选中的书单
   * 目前仅显示成功提示，实际删除逻辑需要根据业务需求实现
   */
  delShelf() {
    showMessage('删除成功')  // 显示删除成功提示
  }

  /**
   * 退出应用处理函数
   * 目前为空实现，可根据需要添加退出逻辑
   */
  exitApp() {
    // this.isClear = false  // 注释掉的代码，可能用于控制清除状态
  }
}

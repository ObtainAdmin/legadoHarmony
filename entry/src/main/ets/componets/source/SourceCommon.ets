/**
 * SourceCommon 组件 - 通用书源页面组件
 *
 * 功能概述：
 * 1. 提供书源管理界面，支持默认显示和隐藏书源两种视图
 * 2. 集成搜索功能，支持按关键词筛选书源
 * 3. 提供更多操作菜单（排序、书源管理、批量管理）
 * 4. 支持批量管理模式，显示批量操作工具栏
 * 5. 使用Tabs组件切换不同书源视图，集成动画效果
 *
 * 设计特点：
 * 1. 分层布局：使用Stack实现搜索栏和内容区域的叠加
 * 2. 状态管理：管理搜索值、批量模式、刷新计数等状态
 * 3. 动画效果：批量模式切换时的平滑平移动画
 * 4. 组件复用：复用sourceTabs、SourceView等子组件
 * 5. 交互设计：直观的搜索、菜单和批量操作
 *
 * 使用场景：
 * 1. 书源管理页面
 * 2. 需要搜索和筛选书源的界面
 * 3. 需要批量操作书源的场景
 *
 * 组件结构：
 * - 搜索区域：搜索框和更多操作菜单
 * - 标签区域：sourceTabs组件显示书源分类
 * - 内容区域：Tabs组件切换SourceView视图
 * - 批量工具栏：批量模式时显示的工具栏
 *
 * 注意事项：
 * 1. 需要正确处理批量模式的切换和动画
 * 2. 搜索功能需要与子组件同步
 * 3. 菜单操作需要路由跳转和状态更新
 */
import ImageConstants from '../../common/constants/ImageConstants'
import PaddingConstants from '../../common/constants/PaddingConstants'
import { IconTitleVo } from '../../componetsmodel/IconTitleVo'
import dialogTitleFuction from '../common/dialogTitleFuction'
import { showMessage } from '../common/promptShow'
import { dataItem } from '../dataList/dataItem'
import { sourceTabs } from './sourceTabs'
import SourceView from './SourceView'
import { router } from '@kit.ArkUI'

// 新增预览父组件
@Entry
@Component
@Preview
struct SourceCommon_Preview {
  @State previewCurrentIndex: number = 0
  @State previewRefreshCount: number = 0 // 新增状态变量
  @State previewShowDialog: boolean = false // 新增状态变量

  build() {
    Column() {
      SourceCommon({
        currentIndex: this.previewCurrentIndex,
        refreshCount: this.previewRefreshCount, // 传递必填属性
        showDialog: this.previewShowDialog // 传递必填属性
      })
    }
  }
}

@Component
struct SourceCommon {
  /**
   * 当前索引
   * @type {number}
   * @description 父组件传递的当前索引，用于标识书源类型
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop currentIndex: number
  /**
   * 书源列表
   * @type {dataItem[]}
   * @default [new dataItem("默认显示", 12), new dataItem("隐藏书源", 12)]
   * @description 书源分类列表，包含默认显示和隐藏书源
   * @state 使用@State装饰器管理组件内部状态
   */
  @State sourceList: dataItem[] = [
    new dataItem("默认显示", 12),
    new dataItem("隐藏书源", 12)
  ]
  /**
   * 显示对话框状态
   * @type {boolean}
   * @description 控制是否显示对话框，与父组件双向绑定
   * @link 使用@Link装饰器实现与父组件的双向绑定
   */
  @Link showDialog: boolean
  /**
   * Tabs控制器
   * @type {TabsController}
   * @description 控制Tabs组件切换的控制器
   */
  sourceController: TabsController = new TabsController();
  /**
   * 阅读索引
   * @type {number}
   * @default 0
   * @description 当前选中的书源索引，变化时触发changeSourceIndex方法
   * @state @watch 使用@State装饰器管理状态，@Watch监听变化
   */
  @State @Watch('changeSourceIndex') readIndex: number = 0
  /**
   * 显示更多对话框状态
   * @type {boolean}
   * @default false
   * @description 控制是否显示更多操作菜单
   * @state 使用@State装饰器管理组件内部状态
   */
  @State showMoreDialog: boolean = false
  /**
   * 搜索值
   * @type {string}
   * @default ''
   * @description 搜索框的输入值，用于筛选书源
   * @state 使用@State装饰器管理组件内部状态
   */
  @State searchValue: string = ''
  /**
   * 批量模式状态
   * @type {boolean}
   * @default false
   * @description 标识是否处于批量管理模式
   * @state 使用@State装饰器管理组件内部状态
   */
  @State isBatch: boolean = false
  /**
   * 刷新计数
   * @type {number}
   * @description 刷新计数器，用于触发子组件刷新
   * @link 使用@Link装饰器实现与父组件的双向绑定
   */
  @Link refreshCount: number

  /**
   * 改变书源索引回调
   * @returns {void}
   * @description 监听readIndex变化，更新Tabs控制器索引
   */
  changeSourceIndex() {
    this.sourceController.changeIndex(this.readIndex) // 更新Tabs选中索引
  }

  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建通用书源页面的完整UI结构
   * 包含搜索区域、标签区域和内容区域
   */
  build() {
    Column() {
      Column() {
        Stack() { // 使用Stack实现搜索栏和内容区域的叠加
          /**
           * 搜索和标签区域
           * @description 包含搜索框、更多菜单和书源标签
           * 批量模式时向上平移120px，显示批量工具栏
           */
          Column() {
            /**
             * 搜索行
             * @description 12px间距，包含搜索框和更多菜单
             */
            Row({
              space: 12
            }) {
              /**
               * 搜索框
               * @description 90%宽度，搜索书源
               */
              Search({
                value: this.searchValue,
                placeholder: '搜索书源'
              })
                .width('90%')
                .onChange((value: string) => {
                  this.searchValue = value // 更新搜索值
                })

              /**
               * 更多菜单按钮
               * @description 24x24px更多图标，绑定菜单
               */
              Image($r('app.media.more_vertical'))
                .width(ImageConstants.IMG_WIDTH_24)
                .height(ImageConstants.IMG_WIDTH_24)
                .layoutWeight(1) // 占用剩余空间
                .bindMenu(// 绑定菜单
                  this.showMoreDialog, // 菜单显示状态
                  this.rightDialogBuilder(this.More_Right_Dialog_Data, async (index: number) => {
                    /**
                     * 菜单项点击回调
                     * @description 处理不同菜单项的操作
                     */
                    switch (index) {
                      case 0: // 按时间排序
                      case 1: // 按评分排序
                        showMessage(this.More_Right_Dialog_Data[index].title); // 显示提示消息
                        break;
                      case 2: // 书源管理
                        this.showDialog = false // 关闭对话框
                        router.pushUrl({
                          // 路由跳转
                          url: 'pages/view/Find/BookSource/Index' // 书源管理页面
                        })
                        break;
                      case 3: // 批量管理
                        this.isBatch = true // 进入批量模式
                        break;
                    }
                  }),
                  {
                    onDisappear: () => {
                      this.showMoreDialog = false // 菜单消失时更新状态
                    }
                  })
                .onClick(() => {
                  this.showMoreDialog = true // 点击显示菜单
                })
            }

            /**
             * 书源标签组件
             * @description 显示默认显示和隐藏书源标签
             */
            sourceTabs({
              sourceList: this.sourceList,
              read_index: this.readIndex
            })
          }
          .padding({
            left: PaddingConstants.PADDING_20, // 左侧20px内边距
            right: PaddingConstants.PADDING_20 // 右侧20px内边距
          })
          .translate({ y: !this.isBatch ? 0 : -120 }) // 批量模式时向上平移120px
          .animation({
            duration: 500, // 500ms动画
            delay: 0 // 无延迟
          })
          .zIndex(1) // 层级1，显示在内容区域上方

          /**
           * 书源内容区域
           * @description Tabs组件切换不同书源视图
           */
          Tabs({
            barPosition: BarPosition.Start, // 标签栏在起始位置
            controller: this.sourceController // Tabs控制器
          }) {
            ForEach([0, 1], (item: number) => { // 两个标签页：默认显示和隐藏书源
              TabContent() {
                /**
                 * 书源视图组件
                 * @description 显示具体书源内容
                 */
                SourceView({
                  searchValue: this.searchValue, // 搜索值
                  isBatch: this.isBatch, // 批量模式状态
                  type: this.currentIndex, // 书源类型
                  index: item, // 标签页索引
                  refreshCount: this.refreshCount, // 刷新计数
                  closeDialog: () => {
                    this.showDialog = false // 关闭对话框回调
                  }
                })
              }
              .height('100%') // 100%高度
              .align(Alignment.Top) // 顶部对齐
            })
          }
          .barWidth(0) // 隐藏标签栏宽度
          .barHeight(0) // 隐藏标签栏高度
          .scrollable(false) // 禁用滚动
          .layoutWeight(1) // 占用剩余空间
          .padding({ top: this.isBatch ? 0 : 120 }) // 批量模式时顶部内边距为0，否则为120px
        }
        .alignContent(Alignment.Top) // 顶部对齐内容
      }
      .justifyContent(FlexAlign.Center) // 居中对齐
    }
    .backgroundColor('#f5f5f5') // 浅灰色背景
  }

  /**
   * 更多菜单数据
   * @type {IconTitleVo[]}
   * @description 更多操作菜单的数据列表
   * 包含图标和标题，用于构建菜单项
   */
  More_Right_Dialog_Data: IconTitleVo[] = [
    new IconTitleVo($r('app.media.appointment_time'), '按时间排序'), // 时间排序
    new IconTitleVo($r('app.media.icon_no_source_find'), '按评分排序'), // 评分排序
    new IconTitleVo($r('app.media.add_book_shelf'), '书源管理'), // 书源管理
    new IconTitleVo($r('app.media.icon_rule_batch'), '批量管理'),// 批量管理
  ]

  /**
   * 右侧对话框构建器
   * @param {IconTitleVo[]} list - 菜单项列表
   * @param {Function} dialogRightChange - 菜单项点击回调函数
   * @returns {void}
   * @description 构建更多操作菜单的UI
   * 使用dialogTitleFuction组件构建每个菜单项
   */
  @Builder
  rightDialogBuilder(list: IconTitleVo[], dialogRightChange: (_index: number) => void) {
    Column() {
      ForEach(list, (item: IconTitleVo, index) => {
        /**
         * 对话框标题功能组件
         * @description 显示菜单项图标和标题
         * 最后一个菜单项不显示底部边框
         */
        dialogTitleFuction({
          title: item.title, // 菜单项标题
          icon: item.icon, // 菜单项图标
          isBorder: list.length !== index + 1 // 非最后一项显示边框
        })
          .onClick(() => {
            dialogRightChange(index) // 点击回调
          })
      })
    }
  }
}

export default SourceCommon


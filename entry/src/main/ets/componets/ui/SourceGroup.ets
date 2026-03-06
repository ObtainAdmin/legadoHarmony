/**
 * SourceGroup 组件 - 通用分组选择弹窗组件
 * 
 * 功能概述：
 * 1. 提供分组选择界面，支持从分组列表中选择目标分组
 * 2. 实现三列网格布局，优化分组显示效果
 * 3. 提供确认和取消操作，支持自定义回调函数
 * 4. 集成滚动功能，支持大量分组的浏览
 * 
 * 设计特点：
 * 1. 简洁布局：使用Column、Grid和Scroll构建分层界面
 * 2. 网格布局：三列网格，16px间距，96px宽度
 * 3. 视觉设计：6%黑色背景的分组标签，圆角设计
 * 4. 交互设计：直观的标题、分组列表和操作按钮
 * 5. 响应式设计：支持不同数量的分组显示
 * 
 * 使用场景：
 * 1. 书源分组选择弹窗
 * 2. 需要从分组列表中选择的场景
 * 3. 需要网格布局显示选项的界面
 * 
 * 组件结构：
 * - 标题区域：显示"移动至"标题
 * - 分组列表：三列网格布局的分组标签
 * - 操作区域：取消按钮
 * 
 * 注意事项：
 * 1. 分组列表需要正确处理空值情况
 * 2. 回调函数需要正确绑定和调用
 * 3. 网格布局需要考虑不同屏幕尺寸
 */
import CommonConstants from '../../common/constants/CommonConstants'
import PaddingConstants from '../../common/constants/PaddingConstants'

@Component
export default struct SourceGroup {
  /**
   * 分组列表
   * @type {string[]}
   * @default []
   * @description 可供选择的分组名称列表
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop groupList: string[] = []
  
  /**
   * 当前名称
   * @type {string}
   * @description 当前选中的分组名称
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop currentName: string
  
  /**
   * 标题
   * @type {string}
   * @default '移动至'
   * @description 弹窗标题文本
   */
  title: string = '移动至'
  
  /**
   * 确认回调函数
   * @type {Function}
   * @default (_groupName) => {}
   * @description 选择分组后的确认回调
   */
  confirm: (groupName: string) => void = (_groupName) => {
  }
  
  /**
   * 取消回调函数
   * @type {Function}
   * @default () => {}
   * @description 取消操作的回调函数
   */
  cancel: () => void = () => {
  }

  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建分组选择弹窗的完整UI结构
   * 包含标题区域、分组列表和操作区域
   */
  build() {
    Column() {
      /**
       * 标题区域
       * @description 显示弹窗标题，16px字体，700字重
       */
      Column() {
        Text(this.title) // 标题文本
          .fontSize(16) // 16px字体
          .fontWeight(700) // 700字重
          .lineHeight(24) // 24px行高
      }
      .padding({
        right: 20, // 右侧20px内边距
        left: 20, // 左侧20px内边距
        top: 12, // 顶部12px内边距
        bottom: 12 // 底部12px内边距
      })

      Divider() // 分割线
      
      /**
       * 分组列表区域
       * @description 滚动区域，三列网格布局
       */
      Scroll() {
        Grid() {
          ForEach(this.groupList, (item: string, index: number) => {
            GridItem() {
              this.titleBuilder(item) // 构建分组标签
            }
            .onClick(() => {
              this.confirm(item) // 点击确认回调
            })
          })
        }
        .columnsTemplate('1fr 1fr 1fr') // 三列等宽网格
        .columnsGap(16) // 列间距16px
        .rowsGap(16) // 行间距16px
      }
      .padding(PaddingConstants.PADDING_20) // 20px内边距
      .align(Alignment.Top) // 顶部对齐
      .layoutWeight(1) // 占用剩余空间
      .scrollBar(BarState.Off) // 关闭滚动条

      /**
       * 操作区域
       * @description 包含分割线和取消按钮
       */
      Column() {
        Divider().strokeWidth(0.5) // 0.5px分割线

        Button('取消') // 取消按钮
          .padding({
            left: 32, // 左侧32px内边距
            right: 32, // 右侧32px内边距
            top: 8, // 顶部8px内边距
            bottom: 8 // 底部8px内边距
          })
          .width('100%') // 100%宽度
          .height(56) // 56px高度
          .type(ButtonType.Normal) // 普通按钮类型
          .stateEffect(false) // 禁用状态效果
          .buttonStyle(ButtonStyleMode.TEXTUAL) // 文本样式按钮
          .fontColor('#E0000000') // 87%黑色字体
          .onClick(() => {
            this.cancel() // 点击取消回调
          })
      }
    }
    .width(CommonConstants.FULL_WIDTH) // 100%宽度
    .height(CommonConstants.FULL_HEIGHT) // 100%高度
  }

  /**
   * 标题构建器
   * @param {string} title - 分组标题
   * @returns {void}
   * @description 构建分组标签的UI
   * 96px宽度，4px圆角，6%黑色背景
   */
  @Builder
  titleBuilder(title: string) {
    Column() {
      Text(title) // 分组标题
        .fontSize(14) // 14px字体
        .textOverflow({
          overflow: TextOverflow.Ellipsis // 省略号溢出
        })
        .lineHeight(20) // 20px行高
        .maxLines(1) // 单行显示
    }
    .width(96) // 96px宽度
    .borderRadius(4) // 4px圆角
    .backgroundColor($r('app.string.color_black_6')) // 6%黑色背景
    .padding({
      left: 16, // 左侧16px内边距
      right: 16, // 右侧16px内边距
      top: 8, // 顶部8px内边距
      bottom: 8 // 底部8px内边距
    })
  }
}

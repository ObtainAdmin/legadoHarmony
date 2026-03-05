/**
 * @file SideBar.ets
 * @description 侧边栏组件
 * 
 * 功能概述：
 * 1. 显示分类左侧列表
 * 2. 支持角标显示（显示列表项数量）
 * 3. 支持拖拽排序功能
 * 4. 支持多种数据格式（GroupList、GroupPartList、字符串）
 * 5. 高亮当前选中项
 * 
 * 使用场景：
 * - 分类筛选的侧边栏
 * - 分组管理的左侧列表
 * - 需要拖拽排序的列表
 * - 需要显示数量的分类列表
 * 
 * 设计特点：
 * - 使用List组件实现高性能列表
 * - 支持拖拽排序（可配置开启/关闭）
 * - 支持角标显示（可配置开启/关闭）
 * - 使用主题颜色配置
 * - 动画效果支持
 * 
 * 数据格式支持：
 * 1. GroupList[]：包含title和list属性的对象数组
 * 2. GroupPartList[]：分组部分列表
 * 3. string[]：简单字符串数组
 * 
 * 交互特点：
 * - 点击项：高亮显示并调用clickAction回调
 * - 拖拽排序：交换列表项位置并调用onDragChange回调
 * - 当前选中项：左侧显示彩色指示条
 * 
 * 样式特点：
 * - 列表项高度：48px
 * - 指示条：3x16px，主题主色，12px圆角
 * - 角标：红色背景，白色文字，16px高度
 * - 拖拽图标：drag资源，24x24px
 * - 圆角：右上和右下12px
 * 
 * @author Andy
 * @datetime 2024/7/6 01:06
 */

import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'
import { GroupList, GroupPartList } from '../../database/entities/BookSource'

/**
 * @class SideBar
 * @description 侧边栏组件
 * 
 * 组件职责：
 * 1. 管理侧边栏列表的显示和交互
 * 2. 处理拖拽排序逻辑
 * 3. 管理角标显示
 * 4. 应用主题颜色配置
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct SideBar {
  /** 
   * @link currentIndex - 当前选中索引
   * @description 当前选中项的索引，双向绑定
   * @type {number}
   */
  @Link currentIndex: number
  
  /** 
   * @prop sideBarList - 侧边栏列表数据
   * @description 侧边栏显示的数据列表，支持多种格式
   * @type {GroupList[] | GroupPartList[] | string[]}
   */
  @Prop sideBarList: GroupList[] | GroupPartList[] | string[]
  
  /** 
   * @prop isBadge - 是否显示角标
   * @description 控制是否在列表项右上角显示数量角标
   * @default false - 默认不显示角标
   * @type {boolean}
   */
  @Prop isBadge: boolean = false
  
  /** 
   * @prop isDrag - 是否开启拖拽
   * @description 控制是否启用拖拽排序功能
   * @default false - 默认不开启拖拽
   * @type {boolean}
   */
  @Prop isDrag: boolean = false
  
  /** 
   * @prop clickAction - 点击回调函数
   * @description 列表项被点击时调用的回调函数
   * @type {Function}
   * @param {number} index - 被点击项的索引
   */
  clickAction: Function = (_index: number) => {
  }
  
  /** 
   * @prop scroller - 滚动控制器
   * @description 控制列表滚动的Scroller对象，可选
   * @type {Scroller | undefined}
   */
  scroller?: Scroller = undefined
  
  /** 
   * @prop onDragChange - 拖拽变化回调
   * @description 拖拽排序完成后调用的回调函数
   * @type {Function}
   * @param {GroupList[] | GroupPartList[] | string[]} list - 排序后的列表
   */
  onDragChange: (list: GroupList[] | GroupPartList[] | string[]) => void = (_list) => {}

  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method changeListItemIndex
   * @description 交换列表项位置
   * 
   * 功能说明：
   * 1. 交换数组中两个索引位置的元素
   * 2. 调用onDragChange回调通知外部数据变化
   * 
   * 算法步骤：
   * 1. 临时保存index1位置的元素
   * 2. 将index2位置的元素赋值给index1
   * 3. 将临时元素赋值给index2
   * 4. 调用回调函数传递更新后的列表
   * 
   * 使用场景：
   * - 拖拽排序时交换元素位置
   * - 手动调整列表顺序
   * 
   * 注意事项：
   * - 直接修改原数组（sideBarList）
   * - 需要确保索引在有效范围内
   * - 会触发UI重新渲染
   * 
   * @param {number} index1 - 第一个索引位置
   * @param {number} index2 - 第二个索引位置
   * @returns {void}
   */
  changeListItemIndex(index1: number, index2: number) {
    let tempItem = this.sideBarList[index1];
    this.sideBarList[index1] = this.sideBarList[index2];
    this.sideBarList[index2] = tempItem;
    this.onDragChange(this.sideBarList)
  }
  
  /**
   * @method build
   * @description 构建侧边栏主UI
   * 
   * 布局结构：
   * 1. List组件：高性能列表容器
   * 2. ForEach：遍历sideBarList生成列表项
   * 3. ListItem：每个列表项容器
   * 4. Stack：叠加布局（用于指示条）
   * 
   * 列表配置：
   * - 高度：100%父容器高度
   * - 宽度：100%父容器宽度
   * - 滚动条：关闭（BarState.Off）
   * - 列配置：每列48-88px宽度（lanes）
   * - 圆角：右上和右下12px
   * 
   * 列表项结构：
   * 1. Stack：叠加容器
   *   - ItemBuilder：构建列表项内容
   *   - 条件显示：当前选中项的指示条
   * 2. 高度：48px固定高度
   * 
   * 指示条样式：
   * - 显示条件：currentIndex === index
   * - 尺寸：3x16px
   * - 颜色：主题主色
   * - 圆角：12px
   * - 位置：顶部16px
   * 
   * 拖拽事件处理：
   * 1. onItemDragStart：拖拽开始
   *   - 检查isDrag是否开启
   *   - 返回拖拽预览（ItemBuilder）
   * 2. onItemDrop：拖拽放下
   *   - 检查isDrag是否开启
   *   - 检查拖拽是否成功
   *   - 调用changeListItemIndex交换位置
   * 
   * 设计理念：
   * - 使用List组件确保高性能
   * - 通过条件渲染减少不必要的UI元素
   * - 提供灵活的配置选项
   * - 支持多种数据格式
   * 
   * @returns {void}
   */
  build() {
    List({ scroller: this.scroller }) {
      ForEach(this.sideBarList, (item: GroupList | string, index: number) => {
        ListItem() {
          Stack({ alignContent: Alignment.TopStart }) {
            this.ItemBuilder(item, index)

            if (this.currentIndex === index) {
              Row()
                .width(3)
                .height(16)
                .backgroundColor(this.theme.mainColor)
                .borderRadius(12)
                .position({
                  top: 16
                })
            }
          }
        }
        .height(48)
      })
    }
    .height('100%')
    .width('100%')
    .scrollBar(BarState.Off)
    .lanes({ minLength: 48, maxLength: 88 })
    .borderRadius({
      topRight: 12,
      bottomRight: 12
    })
    .onItemDragStart((event: ItemDragInfo, index: number) => {
      console.info('TagInfo index:', index)
      if (!this.isDrag) {
        return;
      }
      const item = this.sideBarList[index] as GroupList;
      return this.ItemBuilder(item, index, 88);
    })
    .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
      if (!this.isDrag) return;
      if (!isSuccess || insertIndex >= this.sideBarList.length) {
        return;
      }
      this.changeListItemIndex(itemIndex, insertIndex);
    })
  }

  /**
   * @builder ItemBuilder
   * @description 构建列表项内容
   * 
   * 功能说明：
   * 1. 构建单个列表项的UI内容
   * 2. 根据数据类型显示不同的文本
   * 3. 条件显示角标和拖拽图标
   * 4. 处理点击事件
   * 
   * 布局结构：
   * 1. 外层Row：水平布局容器
   * 2. 内层Stack：文本和角标叠加
   * 3. 条件Column：拖拽图标区域
   * 
   * 文本处理：
   * - 字符串类型：直接显示字符串
   * - GroupList类型：显示item.title
   * - 高度：48px固定高度
   * - 对齐：居中对齐
   * - 字重：当前选中项加粗，其他正常
   * 
   * 角标显示条件：
   * 1. isBadge为true
   * 2. item不是字符串类型（即GroupList类型）
   * 3. 显示item.list.length（列表数量）
   * 
   * 角标样式：
   * - 文本：10px字体，500字重，白色
   * - 容器：16px高度，左右4px内边距
   * - 背景色：红色（0xEF4444）
   * - 圆角：20px（胶囊形状）
   * - 位置：右上角，向右偏移-10px
   * 
   * 拖拽图标显示条件：
   * - isDrag为true时显示
   * 
   * 拖拽图标样式：
   * - 图标：drag资源
   * - 尺寸：24x24px（注意：代码中有重复的width设置）
   * - 不可拖动：draggable(false)
   * - 内边距：5px
   * - 右边距：-10px
   * 
   * 容器样式：
   * - 宽度：参数传入，默认100%
   * - 对齐：水平居中，垂直居中
   * - 背景色：当前选中项浅灰色（0xF5F5F5），其他白色
   * - 圆角：根据位置动态计算
   *   * 顶部圆角：当前项的下一个项
   *   * 底部圆角：当前项的上一个项或最后一项
   * - 动画：100ms线性动画
   * 
   * 点击事件：
   * - 调用clickAction回调，传入index
   * 
   * 参数说明：
   * @param {GroupList | string} item - 列表项数据
   * @param {number} index - 列表项索引
   * @param {number | string} [width='100%'] - 列表项宽度，拖拽预览时使用88px
   * 
   * 设计理念：
   * - 通过Builder实现可复用的列表项构建
   * - 支持拖拽预览（传入不同宽度）
   * - 动态圆角实现视觉连续性
   * - 条件渲染减少不必要的UI元素
   * 
   * 注意事项：
   * - 代码中有重复的.width(32)和.width(24)，可能是个错误
   * - 角标只对GroupList类型显示，字符串类型不显示
   * - 拖拽预览时使用固定宽度88px
   * 
   * @returns {void}
   */
  @Builder
  ItemBuilder(item: GroupList | string, index: number, width: number | string = '100%') {
    Row() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Text(typeof item === 'string' ? item : item.title)
          .height(48)
          .textAlign(TextAlign.Center)
          .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)

        if (this.isBadge && typeof item !== 'string') {
          Column() {
            Text(item.list.length.toString())
              .fontSize(10)
              .fontWeight(500)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
          }
          .height(16)
          .position({
            right: -10
          })
          .justifyContent(FlexAlign.Center)
          .padding({ left: 4, right: 4 })
          .borderRadius(20)
          .backgroundColor(0xEF4444)
        }
      }

      if (this.isDrag) {
        Column() {
          Image($r('app.media.drag'))
            .width(32)
            .width(24)
            .draggable(false)
        }
        .padding(5)
        .margin({ right: -10 })
      }
    }
    .width(width)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.currentIndex === index ? 0xF5F5F5 : Color.White)
    .borderRadius({
      topRight: this.currentIndex + 1 === index ? 12 : 0,
      bottomRight: this.currentIndex - 1 === index || this.sideBarList.length === index + 1 ? 12 : 0
    })
    .animation({
      duration: 100,
      curve: Curve.Linear
    })
    .onClick(() => {
      this.clickAction(index)
    })
  }
}

/**
 * 筛选文本组件
 * 
 * 用于书源管理页面的筛选器标签，显示筛选条件文本和状态
 * 支持显示下拉箭头图标和关闭图标（用于"登录"筛选条件）
 * 根据激活状态显示不同的颜色和背景
 * 
 * @Component 声明为ArkUI组件
 * @default 默认导出
 */
import { ThemeStorageKey } from "../../../../../common/constants/Theme"
import { ThemeItem } from "../../../../../common/model/Theme"

@Component
export default struct FilterText {
  /** 筛选条件索引，用于标识不同的筛选类型 */
  index: number = 0
  
  /** 筛选条件标题文本，从父组件传入 */
  @Prop title: string
  
  /** 是否处于激活状态，从父组件传入 */
  @Prop hasActive: boolean = false
  
  /** 是否显示下拉箭头图标，默认为true */
  isIcon: boolean = true
  
  /** 点击事件回调函数，参数为当前索引值 */
  onChange: (val: number) => void = (_val) => {}
  
  /** 主题颜色配置，从应用存储中获取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 构建组件UI
   * 
   * 组件结构：
   * 1. 显示标题文本，根据激活状态使用主题色或灰色
   * 2. 如果isIcon为true，显示下拉箭头图标
   * 3. 如果是"登录"筛选条件(index=4)且处于激活状态，显示关闭图标
   * 4. 点击整个区域触发onChange回调
   */
  build() {
    Row() {
      // 标题文本
      Text(this.title)
        .fontSize(12)
        .fontColor(this.hasActive ? this.theme.mainColor : '#E0000000')
      
      // 下拉箭头图标（条件渲染）
      if (this.isIcon) {
        Image($r('app.media.down_arrow'))
          .width(8)
          .margin({ left: 6 })
          .fillColor(this.hasActive ? this.theme.mainColor : '#E0000000')
      }
      
      // 关闭图标（仅用于"登录"筛选条件且处于激活状态）
      if (this.index === 4 && this.hasActive) {
        Image($r('app.media.close'))
          .width(8)
          .margin({ left: 2 })
          .fillColor(this.hasActive ? this.theme.mainColor : '#E0000000')
      }
    }
    .height(22)
    .padding({
      top: 2,
      bottom: 2,
      left: 4,
      right: 4
    })
    .layoutWeight(1)
    .backgroundColor(this.hasActive ? this.theme.secondColor : Color.White)
    .borderRadius(4)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // 点击时触发回调，传递当前索引
      this.onChange(this.index)
    })
  }
}

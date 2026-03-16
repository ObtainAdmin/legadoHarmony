/**
 * 筛选选项组件
 * 
 * 用于书源管理页面的筛选选项面板，以网格形式显示多个选项
 * 支持单选和再次点击取消选择功能
 * 根据选中状态显示不同的边框和背景颜色
 * 
 * @Component 声明为ArkUI组件
 * @default 默认导出
 */
import { ThemeStorageKey } from "../../../../../common/constants/Theme";
import { ThemeItem } from "../../../../../common/model/Theme";

/**
 * 选项接口定义
 * 
 * @property label - 选项显示文本
 * @property value - 选项值，支持数字、字符串或布尔类型
 */
export interface Options {
  label: string;
  value?: number | string | boolean;
}

@Component
export default struct FiltrateOption {
  /** 选项列表数据 */
  options: Options[] = []
  
  /** 网格列数，默认为3列 */
  columns: number = 3
  
  /** 是否支持再次点击取消选择，true表示支持 */
  isAgain: boolean = false
  
  /** 当前选中的值，从父组件传入 */
  @Prop value?: number | string | boolean
  
  /** 选项变化回调函数，参数为选中的值或undefined（取消选择时） */
  onChange: (value?: number | string | boolean) => void = () => {}
  
  /** 主题颜色配置，从应用存储中获取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 构建组件UI
   * 
   * 组件结构：
   * 1. 使用Grid布局显示选项网格
   * 2. 每个选项使用GridItem包装
   * 3. 选项文本根据选中状态使用主题色或灰色
   * 4. 选中选项有边框和背景色高亮
   * 5. 点击选项触发onChange回调
   */
  build() {
    Grid() {
      ForEach(this.options, (item: Options) => {
        GridItem() {
          // 选项文本
          Text(item.label)
            .fontColor(this.value === item.value ? this.theme.mainColor : '#E0000000')
            .fontSize(12)
            .height(20)
            .lineHeight(20)
        }
        // 选项边框样式
        .border({
          radius: 4,
          width: 1,
          style: BorderStyle.Solid,
          color: this.value === item.value ? this.theme.mainColor : '#0A000000'
        })
        .padding({ top: 6, bottom: 6 })
        // 选项背景色
        .backgroundColor(this.value === item.value ? this.theme.secondColor : '#0A000000')
        .onClick(() => {
          // 处理点击事件
          if (this.value !== undefined && this.isAgain && this.value === item.value) {
            // 如果支持再次点击取消，且点击的是已选中的选项，则取消选择
            this.onChange(undefined)
            return
          }
          // 否则选择当前选项
          this.onChange(item.value)
        })
      })
    }
    // 设置网格列模板，每列等宽
    .columnsTemplate(Array(this.columns).fill('1fr').join(' '))
    .columnsGap(16)
    .rowsGap(16)
    .padding({ bottom: 12, top: 12 })
  }
}

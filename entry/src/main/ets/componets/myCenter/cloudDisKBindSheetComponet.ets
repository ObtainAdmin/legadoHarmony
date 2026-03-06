/**
 * @file cloudDisKBindSheetComponet.ets
 * @description 云盘绑定底部弹窗组件
 * 
 * 功能概述：
 * 1. 显示云盘绑定选项列表
 * 2. 支持选项选择和状态反馈
 * 3. 根据设备类型显示不同图标
 * 4. 提供选中状态的视觉反馈
 * 
 * 使用场景：
 * - 云盘绑定选择页面
 * - 设备选择弹窗
 * - 需要单选列表的场景
 * 
 * 设计特点：
 * - 简洁的列表布局
 * - 清晰的选中状态反馈
 * - 根据设备类型显示不同图标
 * - 统一的主题颜色应用
 * 
 * 组件结构：
 * 1. Column容器：包裹所有选项，设置间距和内边距
 * 2. ForEach循环：遍历items数组
 * 3. Row容器：每个选项的水平布局
 * 4. Image图标：根据设备类型显示不同图标
 * 5. Text文本：显示选项标题
 * 
 * 技术特点：
 * - 使用@Prop装饰器接收数据项
 * - 使用@Link装饰器实现双向数据绑定
 * - 使用@StorageProp装饰器获取主题配置
 * - 使用ForEach循环渲染动态列表
 */

import { PublicConstants } from '../../common/constants/PublicConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'
import { dataItem } from '../dataList/dataItem'

/**
 * @struct cloudDisKBindSheetComponet
 * @description 云盘绑定底部弹窗组件
 * 
 * 组件职责：
 * 1. 显示云盘绑定选项列表
 * 2. 管理当前选中索引
 * 3. 处理选项点击事件
 * 4. 应用主题颜色到选中状态
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export struct cloudDisKBindSheetComponet{
  /** 
   * @prop items - 数据项数组
   * @description 云盘绑定选项列表，从父组件传入
   * @type {dataItem[]}
   */
  @Prop items:dataItem[]
  
  /** 
   * @link bindSheetIndex - 绑定弹窗索引
   * @description 当前选中的选项索引，与父组件双向绑定
   * @type {number}
   */
  @Link bindSheetIndex:number
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * @method build
   * @description 构建云盘绑定底部弹窗组件UI
   * 
   * 布局结构：
   * 1. Column容器：垂直布局，间距16px，顶部内边距12px，左右内边距20px
   * 2. ForEach循环：遍历items数组，为每个数据项创建选项
   * 
   * 选项结构（每个dataItem）：
   * 1. Row容器：水平布局，间距10px，内边距上下14px，左右20px，宽度280px，圆角8px
   * 2. Image图标：根据设备类型显示不同图标
   *    - type为1：手机图标（$r("app.media.phone_icon")）
   *    - 其他类型：文件图标（$r("app.media.my_center_file_icon")）
   *    - 尺寸：20x20px
   *    - 填充颜色：选中时主题主色，未选中时黑色
   * 3. Text文本：显示选项标题
   *    - 字体大小：14px
   *    - 行高：22px
   *    - 文字颜色：选中时主题主色，未选中时黑色
   * 
   * 选中状态样式：
   * 1. 背景颜色：选中时主题次色，未选中时浅灰色（rgb(245, 245, 245)）
   * 2. 边框：选中时1px主题主色边框，未选中时无边框（0px白色边框）
   * 
   * 交互逻辑：
   * 1. 点击事件：设置bindSheetIndex为当前索引
   * 2. 状态反馈：选中状态立即反映在视觉样式上
   * 
   * 设计理念：
   * - 清晰的视觉层次：选中状态明显区别于未选中状态
   * - 直观的图标表示：不同设备类型使用不同图标
   * - 一致的主题应用：使用主题颜色系统
   * - 舒适的交互体验：适当的间距和圆角
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中使用
   * cloudDisKBindSheetComponet({
   *   items: this.cloudDiskOptions,
   *   bindSheetIndex: $selectedIndex
   * })
   * ```
   * 
   * 颜色说明：
   * 1. theme.mainColor: 主题主色，用于选中状态的图标和文字
   * 2. theme.secondColor: 主题次色，用于选中状态的背景
   * 3. Color.Black: 黑色，用于未选中状态的图标和文字
   * 4. rgb(245, 245, 245): 浅灰色，用于未选中状态的背景
   * 5. PublicConstants.THEME_COLOR_WHITE: 白色，用于未选中状态的边框（实际为0px，不可见）
   * 
   * 图标说明：
   * 1. phone_icon: 手机图标，表示移动设备
   * 2. my_center_file_icon: 文件图标，表示其他设备或默认类型
   * 
   * 注意事项：
   * - 需要导入PublicConstants、ThemeStorageKey、ThemeItem
   * - dataItem类型需要包含title和type属性
   * - 边框在未选中状态为0px，实际上不可见
   * - 组件宽度固定为280px
   * 
   * 扩展建议：
   * - 可以添加更多设备类型图标
   * - 可以添加设备状态显示（如在线/离线）
   * - 可以添加设备容量信息
   * - 可以添加多选支持
   * 
   * @returns {void}
   */
  build() {
    Column({space:16}){
      ForEach(this.items,(item:dataItem,index:number)=>{
        Row({space:10}){
          //$r("app.media.my_center_file_icon")
          Image(item.type==1?$r("app.media.phone_icon"):$r("app.media.my_center_file_icon"))
            .size({width:20,height:20})
            .fillColor(index==this.bindSheetIndex ? this.theme.mainColor :  Color.Black)
          Text(item.title).fontSize(14)
            .lineHeight(22)
            .fontColor(index==this.bindSheetIndex? this.theme.mainColor :Color.Black)
        }.padding({top:14,bottom:14,left:20,right:20})
        .width(280)
        .borderRadius(8)
        .backgroundColor(index==this.bindSheetIndex? this.theme.secondColor:"rgb(245, 245, 245)")
        .onClick(()=>{
          this.bindSheetIndex=index
        })
        .border({
          width:index==this.bindSheetIndex?1:0,
          color:index==this.bindSheetIndex? this.theme.mainColor :PublicConstants.THEME_COLOR_WHITE
        })
      })
    }.padding({top:12,left:20,right:20})

  }
}

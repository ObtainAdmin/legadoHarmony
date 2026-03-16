// ============ 导入模块 ============
import { ThemeColor, ThemeStorageKey } from '../../../common/constants/Theme' // 主题常量
import { ThemeItem } from '../../../common/model/Theme' // 主题类型定义
import { promptAction, PromptAction, router } from '@kit.ArkUI' // UI 提示和路由 API
import { themeManager } from '../../../common/utils/ThemeManager' // 主题管理器工具类
import { JSON } from '@kit.ArkTS' // JSON 处理库（未使用）

/**
 * @Component - 组件装饰器
 * @struct MyThemeConfigComp - 个性主题组件模块
 * 
 * 功能说明：
 *   - 展示已保存的自定义主题列表
 *   - 提供"自定义主题"入口按钮
 *   - 支持点击切换主题
 *   - 支持长按删除主题
 */
@Component
export struct MyThemeConfigComp {
  
  /** @StorageProp(ThemeStorageKey.THEMEINDEX) activeIndex: number = 0
   * 被选中的主题索引
   * 用于标记哪个主题当前正在使用
   */
  @StorageProp(ThemeStorageKey.THEMEINDEX)
  activeIndex: number = 0 
  
  /** @State longPressGestureIndex: number = 0
   * 长按选中主题的索引（用于删除确认对话框）
   */
  @State longPressGestureIndex: number = 0 

  /** @StorageProp(ThemeStorageKey.THEMELIST) themeList: ThemeItem[] = []
   * 主题列表数据
   * 存储用户创建的所有自定义主题
   */
  @StorageProp(ThemeStorageKey.THEMELIST)
  themeList: ThemeItem[] = []

  // ============ 主题颜色绑定 ============
  
  /** @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
   * 响应式主题颜色绑定
   * 用于按钮、背景等动态配色
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  // ============ 删除确认对话框控制器 ============
  
  /** dialog: CustomDialogController - 删除确认弹窗控制器
   * 配置：
   *   - builder: dialogBuilder（构建弹窗内容）
   *   - customStyle: true（启用自定义样式）
   *   - alignment: Center（居中对齐）
   *   - autoCancel: false（不允许自动取消）
   */
  dialog: CustomDialogController = new CustomDialogController({
    builder: this.dialogBuilder,
    customStyle: true,
    alignment: DialogAlignment.Center,
    autoCancel: false
  })

  // ========== 构建器：删除确认弹窗 ==========
  
  /**
   * @Builder dialogBuilder - 构建自定义弹窗
   * 
   * 布局层次：
   * Column
   * ├─ Text("确定要删除吗？") 标题
   * └─ Row (按钮行)
   *    ├─ "取消"按钮（灰底白字）
   *    └─ "确定"按钮（主色底白字）
   * 
   * 功能：
   *   点击确定后：
   *     - 若主题数>1: 调用 themeManager.deleteTheme 删除
   *     - 若主题数<=1: 提示"删除失败，至少需要保留一个主题"
   */
  @Builder
  dialogBuilder() {
    Column({space: 24}) { // 子组件间距 24
      Text('确定要删除吗？')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Row({space: 12}) { // 左右间距 12
        
        // 取消按钮（可取消）
        Button('取消')
          .fontSize(14)
          .fontColor(this.theme.mainColor) // 主色文本
          .backgroundColor(this.theme.secondColor) // 次色背景
          .onClick(() => {
            this.dialog.close() // 关闭弹窗
          })
          .width(112)
          .height(38)
        
        // 确定按钮（执行删除）
        Button('确定')
          .fontSize(14)
          .fontColor(Color.White) // 白色文本
          .backgroundColor(this.theme.mainColor) // 主色背景
          .onClick(() => {
            if (this.themeList.length > 1) {
              // 有多个主题时允许删除
              themeManager.deleteTheme(this.longPressGestureIndex)
            } else {
              // 只有一个主题时提示不能删除
              promptAction.showToast({message: "删除失败，至少需要保留一个主题"})
            }
            this.dialog.close() // 关闭弹窗
          })
          .width(112)
          .height(38)
      }
      .justifyContent(FlexAlign.Center) // 居中排列按钮

    }
    .padding(24) // 内边距 24
    .width(284) // 固定宽度
    .height(136) // 固定高度
    .justifyContent(FlexAlign.Center) // 垂直居中
    .alignItems(HorizontalAlign.Center) // 水平居中
    .backgroundColor(Color.White) // 白色背景
    .borderRadius(32) // 大圆角（半圆形底部）
  }

  // ========== 构建器：主题列表项 ==========
  
  /**
   * @Builder themeItemBuilder - 构建个性主题下列表元素
   * 
   * @param item - ThemeItem 主题对象
   * @param index - 索引位置
   * 
   * @returns Column 组件，包含：
   *   - 主卡片：彩色背景 + 右上角"使用中"标签（如果是当前主题）
   *   - 底部：主题名称文本
   * 
   * 视觉设计：
   *   - 主色块 154x77 像素，带圆角 8
   *   - "使用中"标签：红底白字，位于右上角
   *   - 总高度 107 像素（含底部名称空间）
   */
  @Builder
  themeItemBuilder(item: ThemeItem, index: number) {
    Column({space: 8}) { // 上下间距 8
      
      // 主题色卡片
      Column() {
        // 如果选中主题，显示"使用中"标签
        if (this.activeIndex == index) {
          Text('使用中')
            .fontSize(9) // 超小字号
            .fontColor('#fff') // 白色文字
            .backgroundColor('#ef4444') // 红色背景
            .textAlign(TextAlign.Center)
            .lineHeight(14)
            .width(39) // 紧凑宽度
            .height(14)
            .borderRadius({
              topRight: 8, // 右上圆角
              bottomLeft: 8
            })
            .position({right: 0, top: 0}) // 定位到右上角
        }
      }
      .width(154) // 卡片宽度
      .height(77) // 卡片高度
      .borderRadius(8) // 圆角 8
      .backgroundColor(item.mainColor) // 使用主题的主色作为背景
      
      // 主题名称文本
      Text(item.text)
        .fontSize(14)
        .height(22)
        .lineHeight(22)
        .width('100%')
    }
    .width(154) // 总宽度
    .height(107) // 总高度（77+8+22）
  }

  // ========== UI 构建方法 - build() ==========
  
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column
   * └─ Grid (网格布局)
   *    ├─ GridItem(自定义主题按钮)
   *    └─ ForEach(themeList) -> GridItem(主题卡片)
   * 
   * 网格配置：
   *   - 2 列等宽布局
   *   - 列间距 12 像素
   *   - 行间距 12 像素
   * 
   * 功能说明：
   *   1. 左上角：自定义主题按钮（灰色占位）
   *   2. 其余：显示所有已保存的主题卡片
   */
  build() {
    Column() {
      
      // ========== 网格容器 ==========
      Grid() {
        
        // ========== 第一个格：自定义主题按钮 ==========
        // 自定义主题
        GridItem() {
          Column({space: 8}) { // 上下间距 8
            
            Column() {
              Image($r('app.media.my_theme_config_custom')) // 铅笔图标
                .width(24)
                .aspectRatio(1)
            }
            .alignItems(HorizontalAlign.Center) // 图标居中
            .justifyContent(FlexAlign.Center)
            .width(154) // 方块宽度
            .height(77) // 方块高度
            .borderRadius(8) // 圆角 8
            .backgroundColor('#f5f5f5') // 浅灰背景
            // 点击跳转到创建自定义主题页面
            .onClick(() => {
              router.pushUrl({
                url: '/pages/view/myCenter/CreateCustomTheme'.slice(1) // 去掉开头的斜杠
              })
            })

            Text('自定义主题')
              .fontSize(14)
              .height(22)
              .lineHeight(22)
              .width('100%')
          }
          .width(154) // 总宽度
          .height(107) // 总高度
          

        }
        
        // ========== 遍历渲染所有已保存的主题 =========
        ForEach(this.themeList, (item: ThemeItem, index) => {
          GridItem() {
            this.themeItemBuilder(item, index) // 调用主题卡片构建器
          }
          
          // ========== 点击切换主题 ===========
          .onClick(() => {
            this.activeIndex = index // 更新选中索引
            themeManager.setTheme(this.themeList[index], index) // 应用主题
          })
          
          // ========== 长按删除主题 ===========
          .gesture(
            LongPressGesture() // 长按手势
              .onAction(() => {
                this.dialog.open() // 打开删除确认弹窗
                this.longPressGestureIndex = index // 记录待删除的索引
              })
          )
        })
      }
      .columnsTemplate('1fr 1fr') // 2 列等宽布局
      .columnsGap(12) // 列间距 12 像素
      .rowsGap(12) // 行间距 12 像素
      .width('100%') // 占满宽度
      .height('100%') // 占满高度
      
    }
    .width('100%')
    .height('100%')
  }
}

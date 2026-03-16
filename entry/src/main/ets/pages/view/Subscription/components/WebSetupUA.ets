/**
 * @author 2008
 * @datetime 2024/8/7 16:48
 * @className: WebSetupUA
 * @description: UA设置对话框组件 - 用于配置Web请求的用户代理(User-Agent)
 *              功能：选择不同的UA类型(Android/Phone/电脑/自定义)，用于模拟不同设备访问
 *              交互：点击选项切换UA类型，自动保存并关闭对话框
 */
import CommonConstants from '../../../../common/constants/CommonConstants'
import programPreferences from '../../../../preferences/programDataPreferences'

/**
 * UA设置对话框组件
 * 提供用户代理(UA)类型的选择配置界面
 */
@CustomDialog
@Component
export default struct WebSetupUA {
  /** 对话框控制器 - 用于控制对话框的显示/隐藏 */
  controller?: CustomDialogController
  /** 底部安全区域高度 - 从存储中获取，适配底部手势条 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 
   * UA选项列表 - 预定义的UA类型选项
   * 数组元素：显示名称
   * 索引对应：0-Android, 1-Phone, 2-电脑, 3-自定义
   */
  ua: string[] = ['Android', 'Phone', '电脑', '自定义']
  
  /** 当前选中的UA设置字符串 - 用于显示当前选择 */
  @State uaSet: string = 'Android'
  
  /** 
   * 系统UA设置 - 从全局存储中读取当前UA类型索引
   * 使用StorageLink实现双向绑定，修改后自动同步到全局存储
   */
  @StorageLink(CommonConstants.SYSTEM_UA) SYSTEM_UA: number = 0

  /**
   * 构建UI布局
   * 包含标题、UA选项列表、取消按钮
   */
  build() {
    Column() {
      // 顶部标题栏
      Column() {
        Text('UA设置')
          .fontColor($r('app.string.color_black_88'))
          .textAlign(TextAlign.Center)
          .padding({ top: 12, bottom: 12 })
          .lineHeight(24)
          .fontWeight(500)
      }
      
      // UA选项列表区域
      Column() {
        /**
         * 遍历UA选项数组，为每个选项创建可点击的行
         * ForEach遍历ua数组，为每个UA类型创建一行UI
         * @param title - UA类型显示名称(Android/Phone/电脑/自定义)
         * @param index - UA类型索引(0-3)
         */
        ForEach(this.ua, (title: string, index) => {
          // 每一行使用Flex布局，左右对齐
          Flex({
            justifyContent: FlexAlign.SpaceBetween // 两端对齐：文字在左，勾选图标在右
          }) {
            // UA类型名称
            Text(title)
              .fontColor($r('app.string.color_black_88'))
              .textAlign(TextAlign.Center)
              .padding({ top: 12, bottom: 12 })
              .lineHeight(24)
              .fontWeight(500)
            
            // 选中状态图标 - 当前选中的UA类型显示勾选图标
            // 使用条件渲染：只有当SYSTEM_UA等于当前索引时才显示勾选图标
            Image(this.SYSTEM_UA === index ? $r('app.media.hook') : '')
              .width(24)
              .height(24)
          }
          // 点击行时切换UA类型
          .onClick(() => {
            // 更新选中的UA索引到全局存储
            this.SYSTEM_UA = index
            // 保存UA设置到偏好存储，持久化保存
            programPreferences.updateWebUAData(index)
            // 关闭对话框
            this.controller?.close()
          })
        })
      }
      // 设置列表样式：左对齐、左右内边距
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 20, right: 20 })

      // 取消按钮区域
      Column() {
        Divider() // 分隔线
        Column() {
          Text('取消')
            .fontSize($r('app.string.color_black_88'))
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontWeight(400)
            .lineHeight(24)
        }
        // 取消按钮内边距
        .padding({ left: 32, right: 32, top: 16, bottom: 16 })
      }
      // 点击取消按钮关闭对话框
      .onClick(() => {
        this.controller?.close()
      })
    }
    // 设置对话框样式：顶部圆角、白色背景、全宽
    .borderRadius({ topLeft: 20, topRight: 20 })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .width('100%')
  }
}
/**
 * @file diskComponet.ets
 * @description 磁盘组件（设备名称编辑组件）
 * 
 * 功能概述：
 * 1. 显示设备名称和图标
 * 2. 支持设备名称编辑功能
 * 3. 提供设备名称格式化显示
 * 4. 管理设备名称编辑对话框
 * 
 * 使用场景：
 * - 设备管理页面
 * - 设备信息编辑
 * - 需要显示和编辑设备名称的场景
 * 
 * 设计特点：
 * - 简洁的设备信息显示
 * - 便捷的编辑入口（右箭头图标）
 * - 统一的对话框编辑体验
 * - 设备名称格式化显示（零宽空格分隔）
 * 
 * 组件结构：
 * 1. Row容器：水平布局，宽度280px
 * 2. 左侧区域：设备名称和图标
 * 3. 右侧区域：设备值和编辑按钮
 * 4. 对话框：设备名称编辑对话框
 * 
 * 技术特点：
 * - 使用@ObjectLink装饰器实现对象双向绑定
 * - 使用@State装饰器管理组件内部状态
 * - 使用@Prop装饰器接收父组件数据
 * - 使用@Watch装饰器监听状态变化
 * - 使用CustomDialogController管理对话框
 */

import { dataItem } from '../dataList/dataItem'
import { myCenterInputDialog } from './myCenterInputDialog'

/**
 * @struct diskComponet
 * @description 磁盘组件（设备名称编辑组件）
 * 
 * 组件职责：
 * 1. 显示设备名称和图标
 * 2. 管理设备名称编辑状态
 * 3. 处理设备名称编辑对话框
 * 4. 格式化设备名称显示
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export struct diskComponet{
  /** 
   * @objectlink deviceName - 设备名称数据项
   * @description 设备名称数据对象，与父组件双向绑定
   * @type {dataItem}
   */
  @ObjectLink deviceName:dataItem

  /** 
   * @state @watch diskDialogStatus - 磁盘对话框状态
   * @description 控制设备名称编辑对话框的显示/隐藏
   * @default false - 默认隐藏
   * @watch diskDialogStatusChange - 状态变化时触发回调
   * @type {boolean}
   */
  @State @Watch("diskDialogStatusChange") diskDialogStatus:boolean=false
  
  /** 
   * @prop deviceNameValue - 设备名称值
   * @description 设备名称的当前值，从父组件传入
   * @default "" - 默认空字符串
   * @type {string}
   */
  @Prop deviceNameValue:string=""
  
  /** 
   * @state a - 测试状态（未使用）
   * @description 测试用的状态变量，当前未使用
   * @default "12" - 默认值"12"
   * @type {string}
   */
  @State a:string="12"

  /**
   * @method build
   * @description 构建磁盘组件UI
   * 
   * 布局结构：
   * 1. Row容器：水平布局，宽度280px
   * 2. 左侧区域（40%宽度）：设备名称和图标
   *    - Row容器：水平布局，间距12px
   *    - Text文本：显示设备名称，14px字体，22px行高
   *    - Image图标：显示设备图标，20x20px，图标为空时隐藏
   * 3. 右侧区域（60%宽度）：设备值和编辑按钮
   *    - Row容器：水平布局，间距5px，上下内边距12px，右对齐
   *    - 设备值容器：宽度100px，底部外边距3px
   *      * Text文本：显示格式化后的设备值，12px字体，20px行高，45%黑色，单行省略，右对齐
   *    - 编辑按钮：右箭头图标
   *      * ImageSpan：24x24px，底部对齐，点击触发设备编辑
   * 
   * 设备图标显示逻辑：
   * - 图标不为空字符串：显示图标
   * - 图标为空字符串：隐藏图标（Visibility.None）
   * 
   * 设备值格式化：
   * - 使用fillingString方法格式化设备值
   * - 在每个字符间插入零宽空格（\u200B）
   * - 确保长设备值可以正确换行
   * 
   * 编辑按钮交互：
   * - 点击右箭头图标触发device_onclick方法
   * - 设置deviceNameValue为当前设备值
   * - 设置diskDialogStatus为true打开对话框
   * 
   * 设计理念：
   * - 清晰的视觉分区：左侧名称，右侧值和操作
   * - 便捷的编辑入口：明显的右箭头图标
   * - 友好的长文本处理：格式化显示支持换行
   * - 灵活的设备图标：支持显示/隐藏
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中使用
   * diskComponet({
   *   deviceName: $deviceData,
   *   deviceNameValue: this.currentDeviceName
   * })
   * ```
   * 
   * 颜色说明：
   * 1. rgba(0, 0, 0, 0.45): 45%黑色，用于设备值文字
   * 
   * 图标说明：
   * 1. deviceName.icon: 设备图标资源
   * 2. $r("app.media.right"): 右箭头图标
   * 
   * 注意事项：
   * - 需要导入dataItem类型
   * - 设备值使用toString()转换为字符串
   * - 图标显示条件：icon不为空字符串
   * - 组件宽度固定为280px
   * 
   * 扩展建议：
   * - 可以添加设备状态显示（如在线/离线）
   * - 可以添加设备类型图标
   * - 可以添加设备容量信息
   * - 可以添加设备连接状态
   * 
   * @returns {void}
   */
  build() {
    Row(){
      Row({space:12}){
        Text(this.deviceName.title).fontSize(14).lineHeight(22)
        Image(this.deviceName.icon).size({width:20,height:20})
          .visibility(this.deviceName.icon!=""?Visibility.Visible:Visibility.None)
      }.width("40%")
      Row({space:5}){
        Row(){
          Text(this.fillingString(this.deviceName.value.toString()))
            .fontSize(12)
            .lineHeight(20)
            .fontColor("rgba(0, 0, 0, 0.45)")
            .textOverflow({overflow:TextOverflow.Ellipsis})
            .maxLines(1)
            .width("100%")
            .textAlign(TextAlign.End)
        }.width(100).margin({bottom:3})
        Text(){
          ImageSpan($r("app.media.right"))
            .size({width:24,height:24})
            .verticalAlign(ImageSpanAlignment.BOTTOM)
            .onClick(()=>{
              this.device_onclick()
            })
        }
      }.width("60%")
      .padding({top:12,bottom:12})
      .justifyContent(FlexAlign.End)
    }.width(280)
  }

  /**
   * @method diskDialogStatusChange
   * @description 磁盘对话框状态变化回调
   * 
   * 功能说明：
   * 1. 监听diskDialogStatus状态变化
   * 2. 当状态变为true时打开设备名称编辑对话框
   * 
   * 触发条件：
   * - diskDialogStatus从false变为true时
   * 
   * 逻辑说明：
   * 1. 检查diskDialogStatus是否为true
   * 2. 如果为true，调用deviceNameInfo?.open()打开对话框
   * 
   * 使用场景：
   * - 点击编辑按钮后
   * - 需要编辑设备名称时
   * 
   * 注意事项：
   * - 使用@Watch装饰器监听状态变化
   * - 需要确保deviceNameInfo已初始化
   * 
   * @returns {void}
   */
  diskDialogStatusChange(){
    if (this.diskDialogStatus) {
      this.deviceNameInfo?.open()
    }
  }

  /**
   * @method onCancel
   * @description 取消编辑回调
   * 
   * 功能说明：
   * 1. 处理编辑对话框的取消操作
   * 2. 关闭对话框
   * 
   * 逻辑说明：
   * 1. 设置diskDialogStatus为false
   * 2. 对话框会自动关闭
   * 
   * 使用场景：
   * - 点击编辑对话框的取消按钮
   * - 用户放弃编辑操作
   * 
   * @returns {void}
   */
  onCancel() {
    this.diskDialogStatus = false
  }

  /**
   * @method onAccept
   * @description 确认编辑回调
   * 
   * 功能说明：
   * 1. 处理编辑对话框的确认操作
   * 2. 更新设备名称值
   * 3. 关闭对话框
   * 
   * 逻辑说明：
   * 1. 将deviceNameValue赋值给deviceName.value
   * 2. 设置diskDialogStatus为false
   * 3. 对话框会自动关闭
   * 
   * 使用场景：
   * - 点击编辑对话框的确认按钮
   * - 用户完成编辑操作
   * 
   * 注意事项：
   * - 需要确保deviceNameValue已更新
   * - deviceName.value会被更新，通过@ObjectLink同步到父组件
   * 
   * @returns {void}
   */
  onAccept() {
    this.deviceName.value=this.deviceNameValue
    this.diskDialogStatus = false
  }

  /**
   * @method exitApp
   * @description 弹窗关闭回调
   * 
   * 功能说明：
   * 1. 处理对话框关闭操作
   * 2. 重置对话框状态
   * 
   * 逻辑说明：
   * 1. 设置diskDialogStatus为false
   * 
   * 使用场景：
   * - 对话框被关闭时（点击外部或关闭按钮）
   * - 需要重置编辑状态时
   * 
   * 注意事项：
   * - 作为CustomDialogController的cancel回调
   * - 确保对话框状态正确重置
   * 
   * @returns {void}
   */
  exitApp() {
    this.diskDialogStatus = false
  }

  /**
   * @method device_onclick
   * @description 设备点击事件处理
   * 
   * 功能说明：
   * 1. 处理编辑按钮点击事件
   * 2. 准备编辑对话框数据
   * 3. 打开编辑对话框
   * 
   * 逻辑说明：
   * 1. 将当前设备值赋值给deviceNameValue
   * 2. 设置diskDialogStatus为true
   * 3. 触发diskDialogStatusChange回调打开对话框
   * 
   * 使用场景：
   * - 点击右箭头编辑按钮时
   * - 需要编辑设备名称时
   * 
   * 注意事项：
   * - 使用箭头函数定义，确保this上下文正确
   * - 需要将设备值转换为字符串
   * 
   * @returns {void}
   */
  device_onclick=()=>{
    this.deviceNameValue=this.deviceName.value.toString()
    this.diskDialogStatus=true
  }
  /** 
   * @property deviceNameInfo - 设备名称信息对话框控制器
   * @description 控制设备名称编辑对话框的显示/隐藏
   * @type {CustomDialogController | null}
   */
  deviceNameInfo: CustomDialogController | null = new CustomDialogController({
    builder: myCenterInputDialog({
      title:"设备名称",
      value:this.deviceNameValue,
      placeholder:"请输入设备名称",
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() }

    }),
    cancel: this.exitApp,
    autoCancel: true,
    alignment: DialogAlignment.Center,
    offset:{dx:0,dy:20},
    customStyle: true
  })

  /**
   * @method aboutToAppear
   * @description 组件即将显示时的生命周期方法
   * 
   * 功能说明：
   * 1. 组件初始化时调用
   * 2. 当前为空实现，可用于初始化操作
   * 
   * 使用场景：
   * - 组件加载时
   * - 需要初始化数据时
   * 
   * 注意事项：
   * - 当前为空实现，可根据需要添加初始化逻辑
   * 
   * @returns {void}
   */
  aboutToAppear(): void {

  }

  /**
   * @method fillingString
   * @description 填充字符串方法（格式化设备值）
   * 
   * 功能说明：
   * 1. 格式化设备值字符串
   * 2. 在每个字符间插入零宽空格（\u200B）
   * 3. 确保长字符串可以正确换行
   * 
   * 实现原理：
   * 1. 遍历输入字符串的每个字符
   * 2. 在每个字符后添加零宽空格
   * 3. 返回格式化后的字符串
   * 
   * 零宽空格说明：
   * - Unicode字符：\u200B
   * - 特性：不可见，不占宽度，但允许换行
   * - 作用：使长字符串可以在任意字符位置换行
   * 
   * 使用场景：
   * - 显示长设备名称时
   * - 需要确保文本正确换行时
   * - 格式化显示设备值
   * 
   * 参数说明：
   * @param {string} value - 需要格式化的字符串
   * 
   * 返回值说明：
   * @returns {string} 格式化后的字符串（每个字符间插入零宽空格）
   * 
   * 示例：
   * - 输入："设备名称"
   * - 输出："设\u200B备\u200B名\u200B称"
   * 
   * 注意事项：
   * - 零宽空格不会影响文本显示宽度
   * - 可以改善长文本的换行效果
   * - 适用于需要精确控制换行位置的场景
   * 
   * 扩展建议：
   * - 可以添加其他格式化选项（如省略号、截断等）
   * - 可以支持多种格式化模式
   * - 可以添加长度限制
   * 
   * @returns {string} 格式化后的字符串
   */
  fillingString(value:string):string{
    let val=""
    for (let index = 0; index < value.length; index++) {
      val=val+value[index]+"\u200B"
    }
    return val
  }
}

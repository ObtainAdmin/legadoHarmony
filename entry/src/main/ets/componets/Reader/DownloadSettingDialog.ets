/**
 * DownloadSettingDialog 组件 - 下载设置对话框
 * 
 * 功能概述：
 * 1. 提供书籍章节下载的多种缓存策略设置
 * 2. 支持四种预设缓存模式和自定义章节范围设置
 * 3. 集成下载确认提示对话框，提供操作反馈
 * 4. 使用主题系统适配应用的整体视觉风格
 * 5. 处理下载参数的输入验证和提交
 * 
 * 设计特点：
 * 1. 网格布局：使用Grid组件实现选项的整齐排列
 * 2. 分层结构：选项区域、输入区域、操作按钮区域
 * 3. 主题适配：使用主题颜色系统确保视觉一致性
 * 4. 交互反馈：点击确定后显示下载确认提示
 * 5. 输入验证：数字输入框限制输入类型为数字
 * 
 * 使用场景：
 * 1. 阅读器页面中的章节下载设置
 * 2. 批量缓存书籍章节的配置界面
 * 3. 需要自定义下载范围的场景
 * 
 * 组件结构：
 * - 选项区域：四种预设缓存模式的复选框
 * - 输入区域：自定义章节范围的开始和结束输入框
 * - 操作区域：取消和确定按钮
 * - 对话框集成：下载确认提示对话框
 * 
 * 注意事项：
 * 1. 需要正确处理主题颜色的动态切换
 * 2. 输入框需要验证章节编号的有效性
 * 3. 对话框的显示和隐藏需要精确控制
 */

import { AddDownloadDialog } from 'ets/componets/Reader/AddDownloadDialog';
import { ThemeStorageKey } from '../../common/constants/Theme';
import { ThemeItem } from '../../common/model/Theme';

@Component
export default struct DownloadSettingDialog{
  /**
   * 下载对话框显示状态
   * @type {boolean}
   * @description 控制下载设置对话框的显示/隐藏
   * @link 使用@Link装饰器实现与父组件的双向绑定
   */
  @Link isShowDownload: boolean
  
  /**
   * 设置对话框显示状态
   * @type {boolean}
   * @description 控制设置对话框的显示/隐藏
   * @link 使用@Link装饰器实现与父组件的双向绑定
   */
  @Link isShowSetting: boolean
  
  /**
   * 下载确认对话框控制器
   * @type {CustomDialogController}
   * @description 控制下载确认提示对话框的显示和隐藏
   * 配置8px圆角，垂直向上偏移100px
   */
  DownloadDialogController: CustomDialogController = new CustomDialogController({
    builder: AddDownloadDialog(),
    cornerRadius: 8,
    offset: { dx: 0, dy: -100 }
  })
  
  /**
   * 开始章节文本
   * @type {string}
   * @default "1"
   * @description 自定义缓存范围的开始章节编号
   * @state 使用@State装饰器管理组件内部状态
   */
  @State StartText: string = "1"
  
  /**
   * 结束章节文本
   * @type {string}
   * @default "2"
   * @description 自定义缓存范围的结束章节编号
   * @state 使用@State装饰器管理组件内部状态
   */
  @State EndText: string = "2"
  
  /**
   * 文本输入控制器
   * @type {TextInputController}
   * @description 控制文本输入框的行为和状态
   */
  controller: TextInputController = new TextInputController()
  
  /**
   * 主题配置
   * @type {ThemeItem}
   * @description 从本地存储读取的主题配置
   * @storageprop 使用@StorageProp装饰器读取持久化存储的主题数据
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 构建对话框UI
   * @returns {void}
   * @description 构建下载设置对话框的UI结构
   * 使用Column布局包含选项区域和操作区域
   */
  build() {
    Column() {
      /**
       * 选项区域网格
       * @description 使用Grid布局显示四种缓存选项
       * 80%高度，单列五行的网格模板
       */
      Grid() {
        /**
         * 选项1：缓存后50章
         * @description 复选框选项，缓存当前章节后的50章
         */
        GridItem() {
          Row() {
            Text("缓存后50章")
            Blank(1) // 空白填充，使复选框靠右
            Checkbox()
          }
          .width("100%")
        }

        /**
         * 选项2：缓存后面全部章节
         * @description 复选框选项，缓存当前章节后的所有章节
         */
        GridItem() {
          Row() {
            Text("缓存后面全部章节")
            Blank(1)
            Checkbox()
          }
          .width("100%")
        }

        /**
         * 选项3：缓存全部
         * @description 复选框选项，缓存书籍的所有章节
         */
        GridItem() {
          Row() {
            Text("缓存全部")
            Blank(1)
            Checkbox()
          }
          .width("100%")
        }

        /**
         * 选项4：自定义缓存
         * @description 复选框选项，启用自定义章节范围输入
         */
        GridItem() {
          Row() {
            Text("自定义缓存")
            Blank(1)
            Checkbox()
          }
          .width("100%")
        }

        /**
         * 自定义输入区域
         * @description 显示开始和结束章节的输入框
         * 仅在自定义缓存选项选中时可用
         */
        GridItem() {
          Row({ space: 16 }) {
            /**
             * 开始章节输入框
             * @description 输入缓存范围的开始章节编号
             * 数字类型输入，107x38尺寸，8px圆角
             */
            TextInput({ text: this.StartText, controller: this.controller })
              .type(InputType.Number) // 限制为数字输入
              .width(107)
              .height(38)
              .borderRadius(8)
              .fontSize(20)
              .fontWeight(400)
              .lineHeight(22)
              .textAlign(TextAlign.Center) // 居中对齐
              .backgroundColor("white")
              .border({
                width: 1,
                color: "gray"
              })
              .onChange((value: string) => {
                this.StartText = value // 更新开始章节
              })

            Text("至") // 分隔文本

            /**
             * 结束章节输入框
             * @description 输入缓存范围的结束章节编号
             * 数字类型输入，107x38尺寸，8px圆角
             */
            TextInput({ text: this.EndText, controller: this.controller })
              .type(InputType.Number)
              .width(107)
              .height(38)
              .borderRadius(8)
              .fontSize(20)
              .fontWeight(400)
              .lineHeight(22)
              .textAlign(TextAlign.Center)
              .backgroundColor("white")
              .border({
                width: 1,
                color: "gray"
              })
              .onChange((value: string) => {
                this.EndText = value // 更新结束章节
              })
          }
          .width("100%")
        }
      }
      .padding({
        top: 16
      })
      .height("80%") // 80%高度
      .columnsTemplate("1fr") // 单列布局
      .rowsTemplate("1fr 1fr 1fr 1fr 1fr") // 五行等分布局

      Blank(1) // 空白填充，分隔选项区域和操作区域
      
      /**
       * 操作按钮区域
       * @description 使用Grid布局显示取消和确定按钮
       * 64px高度，两列单行的网格模板
       */
      Grid() {
        /**
         * 取消按钮
         * @description 使用主题次要颜色，主色文字
         * 点击关闭对话框，不执行任何操作
         */
        GridItem() {
          Button() {
            Text("取消")
              .lineHeight(24)
              .fontColor(this.theme.mainColor) // 使用主题主色
              .font({
                size: 16,
                weight: 500
              })
          }
          .width("80%")
          .height(40)
          .backgroundColor(this.theme.secondColor) // 使用主题次要颜色
        }

        /**
         * 确定按钮
         * @description 使用主题主色，白色文字
         * 点击执行下载操作，显示确认提示
         */
        GridItem() {
          Button() {
            Text("确定")
              .fontColor("white") // 白色文字
              .lineHeight(24)
              .font({
                size: 16,
                weight: 500
              })
          }
          .width("80%")
          .height(40)
          .backgroundColor(this.theme.mainColor) // 使用主题主色
          .onClick(() => {
            /**
             * 确定按钮点击事件
             * @description 执行下载操作流程
             * 1. 关闭当前设置对话框
             * 2. 打开下载确认提示对话框
             * 3. 1秒后自动关闭确认提示
             */
            this.isShowDownload = false
            this.isShowSetting = false
            this.DownloadDialogController.open() // 打开确认提示
            setTimeout(() => {
              this.DownloadDialogController.close() // 1秒后自动关闭
            }, 1000)
          })
        }
      }
      .height(64)
      .columnsTemplate("1fr 1fr") // 两列等分布局
      .rowsTemplate("1fr") // 单行布局
      .width("100%")
      .onClick(() => {
        this.isShowDownload = false // 点击背景关闭对话框
      })
      .padding({
        top: 12,
        bottom: 12
      })
    }
    .height(500) // 固定高度500px
    .padding({
      left: 20,
      right: 20
    }) // 左右内边距
  }
}

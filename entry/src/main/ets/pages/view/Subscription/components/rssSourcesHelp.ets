/**
 * @author 2008
 * @datetime 2024/7/22 13:40
 * @className: rssSourcesHelp
 * @description: 订阅源帮助信息组件 - 显示书源和订阅源的帮助文档链接及规则说明
 *              功能：展示帮助文档入口链接、规则标志说明、规则类型说明
 *              交互：点击链接可跳转至对应帮助文档，展示规则编写规范
 */
import CommonConstants from '../../../../common/constants/CommonConstants'
import FontConstants from '../../../../common/constants/FontConstants'
import TextConstants from '../../../../common/constants/TextConstants'

@Component
export default struct rssSourcesHelp {
  build() {
    Column({
      space:5
    }) {
      Row({
        space:8
      }){
        Row()
          .width(5)
          .height(5)
          .borderRadius(5)
          .backgroundColor('#188BFF')
        Text('书源帮助文档')
          .font({
            size:FontConstants.FONT_SIZE_14,
            weight:FontConstants.FONT_WEIGHT_400,
            family:CommonConstants.FAMILY_PingFANG
          })
          .lineHeight(TextConstants.TEXT_LINE_HEIGHT_22)
          .fontColor('#188BFF')
          .decoration({ type: TextDecorationType.Underline, color: '#188BFF' })
      }

      Row({
        space:8
      }){
        Row()
          .width(5)
          .height(5)
          .borderRadius(5)
          .backgroundColor('#188BFF')
        Text('订阅源帮助文档')
          .font({
            size:FontConstants.FONT_SIZE_14,
            weight:FontConstants.FONT_WEIGHT_400,
            family:CommonConstants.FAMILY_PingFANG
          })
          .lineHeight(TextConstants.TEXT_LINE_HEIGHT_22)
          .fontColor('#188BFF')
          .decoration({ type: TextDecorationType.Underline, color: '#188BFF' })
      }

      Row({
        space:8
      }){
        Row()
          .width(5)
          .height(5)
          .borderRadius(5)
          .backgroundColor('#188BFF')
        Text('辅助键盘❓中可插入URL参数模板,打开帮助,js教程,正则教程,选择文件')
          .font({
            size:FontConstants.FONT_SIZE_14,
            weight:FontConstants.FONT_WEIGHT_400,
            family:CommonConstants.FAMILY_PingFANG
          })
          .lineHeight(TextConstants.TEXT_LINE_HEIGHT_22)
          .fontColor('#188BFF')
          .decoration({ type: TextDecorationType.Underline, color: '#188BFF' })
      }

      Row({
        space:8
      }){
        Row()
          .width(5)
          .height(5)
          .borderRadius(5)
          .backgroundColor('#188BFF')
        Text('规则标志, {{......}}内使用规则必须有明显的规则标志,没有规则标志当作js执行')
          .font({
            size:FontConstants.FONT_SIZE_14,
            weight:FontConstants.FONT_WEIGHT_400,
            family:CommonConstants.FAMILY_PingFANG
          })
          .lineHeight(TextConstants.TEXT_LINE_HEIGHT_22)
          .fontColor('#188BFF')
          .decoration({ type: TextDecorationType.Underline, color: '#188BFF' })
      }
      Column(){
        Text('@@ 默认规则,直接写时可以省略@@\n' +
          '@XPath: xpath规则,直接写时以//开头可省略@XPath\n' +
          '@Json: json规则,直接写时以$.开头可省略@Json\n' +
          ': regex规则,不可省略,只可以用在书籍列表和目录列表')
          .font({
            size:FontConstants.FONT_SIZE_14,
            weight:FontConstants.FONT_WEIGHT_400,
            family:CommonConstants.FAMILY_PingFANG
          })
          .lineHeight(TextConstants.TEXT_LINE_HEIGHT_22)
          .fontColor($r('app.string.color_black_88'))
          .margin({
            top:12,
            bottom:12,
            left:16,
            right:16
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .backgroundColor($r('app.string.color_black_6'))
    }.alignItems(HorizontalAlign.Start)
  }
}
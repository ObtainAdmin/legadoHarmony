/**
 * @file dialogNewSources.ets
 * @description 新建订阅源弹窗组件，提供选择新建常规网站或订阅源的功能
 * @author 2008
 * @datetime 2024/7/16 16:16
 * @className: dialogNewSources
 * 
 * @overview
 * 该组件是一个底部弹窗，展示两个选项：
 * 1. 常规网站 - 打开新建常规网站表单
 * 2. 订阅源 - 打开新建订阅源表单
 * 使用GridRow布局展示选项图标和标题
 */

// 导入常量定义
import CommonConstants from '../../../../common/constants/CommonConstants'    // 通用常量（间距等）
import FontConstants from '../../../../common/constants/FontConstants'        // 字体常量
import ImageConstants from '../../../../common/constants/ImageConstants'      // 图片尺寸常量
import PaddingConstants from '../../../../common/constants/PaddingConstants'  // 内边距常量

// 导入数据模型
import { IconTitleVo } from '../../../../componetsmodel/IconTitleVo'          // 图标标题数据模型

// 导入子组件
import newSources from './newSources'                                         // 新建订阅源组件
import newSourcesNetWork from './newSourcesNetWork'                           // 新建常规网站组件

/**
 * @class dialogNewSources
 * @description 新建订阅源弹窗组件
 * @decorator @Component - 标记为ArkTS组件
 * @decorator @Preview - 支持预览
 * @export default - 默认导出
 */
@Component
@Preview
export default struct dialogNewSources{
  /**
   * @property {Function} btnClick - 按钮点击回调函数，用于关闭弹窗
   * @default 空函数
   */
  btnClick: Function = () => {
  }

  /**
   * @property {boolean} isShowNewSourcesNetwork - 是否显示新建常规网站弹窗
   * @decorator @State - 状态变量，变化时触发UI刷新
   * @default false
   */
  @State isShowNewSourcesNetwork: boolean = false

  /**
   * @property {boolean} isShowNewSources - 是否显示新建订阅源弹窗
   * @decorator @State - 状态变量，变化时触发UI刷新
   * @default false
   */
  @State isShowNewSources: boolean = false

  /**
   * @property {IconTitleVo[]} newSources - 选项列表数据
   * @decorator @State - 状态变量
   * @description 包含两个选项：常规网站和订阅源
   *   - 索引0: 常规网站（网络图标）
   *   - 索引1: 订阅源（源图标）
   */
  @State
  newSources: IconTitleVo[] = [
    new IconTitleVo($r('app.media.icon_dialog_new_sources_network'), '常规网站'),
    new IconTitleVo($r('app.media.icon_dialog_new_sources'), '订阅源')
  ]

  /**
   * @method build
   * @description 构建UI界面
   * @returns {Column} 返回构建的UI组件
   */
  build() {
    Column(){
      // 选项列表构建器
      this.contentListBuilder()
      
      // 分隔线
      Divider()

      // 取消按钮
      Text('取消').fontSize(16).fontWeight(400)
        .lineHeight(24).padding({
        top:PaddingConstants.PADDING_16
      , bottom:PaddingConstants.PADDING_16
      })
        .onClick(()=>{
          // 点击取消时调用回调关闭弹窗
          this.btnClick()
        })
      
      // Flex占位，用于绑定新建常规网站弹窗（bindSheet）
      Flex()
        .bindSheet($$this.isShowNewSourcesNetwork,this.newSourcesNetworkBuilder(),{
          height: '95%',           // 弹窗高度为屏幕的95%
          dragBar: true,           // 显示拖拽条
          showClose:false,         // 不显示关闭按钮
          onDisappear:()=>{
            // 弹窗消失时重置状态
            this.isShowNewSourcesNetwork = false
          }
        })

      // Flex占位，用于绑定新建订阅源弹窗（bindSheet）
      Flex()
        .bindSheet($$this.isShowNewSources,this.newSourcesBuilder(),{
          height: '95%',           // 弹窗高度为屏幕的95%
          dragBar: true,           // 显示拖拽条
          showClose:false,         // 不显示关闭按钮
          onDisappear:()=>{
            // 弹窗消失时重置状态
            this.isShowNewSources = false
          }
        })
    }.padding({ top: 16})  // 顶部内边距16
  }

  /**
   * @builder newSourcesNetworkBuilder
   * @description 构建新建常规网站的弹窗内容
   * @returns {Flex} 包含newSourcesNetWork组件的Flex容器
   */
  @Builder
  newSourcesNetworkBuilder(){
    Flex(){
      newSourcesNetWork({
        isEdit:false,             // 非编辑模式，即新建模式
        hideNewWork:()=>{
          // 关闭回调：先关闭当前弹窗，再关闭新建网站弹窗
          this.btnClick()
          this.isShowNewSourcesNetwork = false
        }
      })
    }
  }

  /**
   * @builder newSourcesBuilder
   * @description 构建新建订阅源的弹窗内容
   * @returns {Column} 包含newSources组件的Column容器
   */
  @Builder
  newSourcesBuilder(){
    Column(){
      newSources({
        isEdit:false,             // 非编辑模式，即新建模式
        hideNewSources:()=>{
          // 关闭回调：先关闭当前弹窗，再关闭新建订阅源弹窗
          this.btnClick()
          this.isShowNewSources = false
        },
      })
    }
  }

  /**
   * @builder contentListBuilder
   * @description 构建选项列表UI（常规网站和订阅源两个选项）
   * @returns {GridRow} 网格布局的选项列表
   * @layout GridRow 5列网格布局
   */
  @Builder
  contentListBuilder(){
    GridRow({
      columns: 5  // 每行5列
    }){
      // 遍历newSources数组渲染每个选项
      ForEach(this.newSources,(item:IconTitleVo,index:number)=>{
        GridCol(){
          // 垂直排列的图标和标题
          Column({
            space: CommonConstants.SPACE_6  // 图标和标题间距6
          }){
            // 图标容器
            Column(){
              Image(item.icon)
                .width(ImageConstants.IMG_WIDTH_24)
                .height(ImageConstants.IMG_HEIGHT_24)
                .borderRadius(8)
            }
            .backgroundColor(Color.White)
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.20)' })  // 阴影效果
            .borderRadius(50)  // 圆形边框
            .border({width:1,color:$r('app.string.color_black_15')})  // 边框
            .padding(PaddingConstants.PADDING_12)

            // 选项标题
            Text(`${item.title}`).fontSize(12)
              .fontColor($r('app.string.color_black_65'))
              .lineHeight(18)
              .textAlign(TextAlign.Center)
              .fontFamily(CommonConstants.FAMILY_PingFANG)
              .fontWeight(FontConstants.FONT_WEIGHT_400)
          }
          .onClick(()=>{
            // 点击选项时根据索引显示对应弹窗
            this.onClickShowNewSources(index)
          })
          .margin({bottom:20})  // 底部外边距20
        }
      })
    }
  }

  /**
   * @method onClickShowNewSources
   * @description 处理选项点击事件，根据索引显示对应弹窗
   * @param {number} index - 点击的选项索引
   *   - 0: 显示新建常规网站弹窗
   *   - 1: 显示新建订阅源弹窗
   * @returns {void}
   */
  onClickShowNewSources(index:number){
    switch (index){
      case 0:
        // 索引0：打开常规网站弹窗
        this.isShowNewSourcesNetwork = true
        break;
      case 1:
        // 索引1：打开订阅源弹窗
        this.isShowNewSources = true
        break;
      default:
        break;
    }
    // this.btnClick()  // 注释掉的代码：原意可能是点击后立即关闭当前弹窗
  }
}

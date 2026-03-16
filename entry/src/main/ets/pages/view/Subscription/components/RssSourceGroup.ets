/**
 * @author 2008
 * @datetime 2024/7/19 22:02
 * @className: RssSourceGroup
 * @description: 订阅源分组选择弹窗组件
 *              功能：显示所有订阅源分组列表，支持选择目标分组进行移动操作
 *              交互：点击分组名称选中，确认/取消按钮控制操作
 *              用途：用于批量编辑时将订阅源移动到其他分组
 */
import CommonConstants from '../../../../common/constants/CommonConstants'
import PaddingConstants from '../../../../common/constants/PaddingConstants'
import { ThemeStorageKey } from '../../../../common/constants/Theme'
import { ThemeItem } from '../../../../common/model/Theme'
import rssSourcesUtil from '../../../../common/utils/rssSourcesUtils'
import buttonCommon from '../../../../componets/common/buttonCommon'
import { showMessage } from '../../../../componets/common/promptShow'

/**
 * 订阅源分组选择弹窗组件
 * 提供分组列表展示和选择功能，用于移动订阅源到其他分组
 */
@Component
export default struct RssSourceGroup {
  /** 
   * 订阅源分组列表 - 从数据库获取的所有分组名称
   * 通过getRssSourceList()方法异步加载
   */
  @State sourceGroupList:string[] = []
  
  /**
   * 确认回调函数
   * 用户点击确认按钮时触发，执行移动操作
   */
  confirm: Function = ()=>{

  }
  
  /**
   * 取消回调函数
   * 用户点击取消按钮时触发，关闭弹窗不执行操作
   */
  cancel:Function = () =>{

  }
  
  /** 
   * 当前主题颜色 - 从全局存储中获取
   * 用于选中分组名称的颜色高亮显示
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 组件即将显示时生命周期回调
   * 调用getRssSourceList()加载分组列表数据
   */
  aboutToAppear() {
   this.getRssSourceList()
  }

  /**
   * 异步获取订阅源分组列表
   * 调用rssSourcesUtil工具类从数据库查询所有分组名称
   * 结果存储到sourceGroupList状态变量
   */
  async getRssSourceList() {
    this.sourceGroupList = await rssSourcesUtil.getRssSourcesGroup()
  }

  /** 
   * 目标移动分组 - 从父组件传入的链接状态
   * 用于显示当前选中的分组名称，并支持双向绑定
   */
  @Link moveGroup:string
  
  /**
   * 构建UI布局
   * 整体采用Flex垂直布局，分为三个区域：
   * 1. 顶部标题区：显示"移动至 xxx"提示
   * 2. 中间分组列表：网格形式展示所有分组
   * 3. 底部按钮区：确认和取消按钮
   */
  build() {
    Flex({
      justifyContent:FlexAlign.SpaceBetween,
      direction:FlexDirection.Column
    }) {
      // 标题行 - 显示"移动至"提示和当前选中的分组名称
      Row({
        space:5
      }){
        Text('移动至').fontSize(16).fontWeight(700).lineHeight(24)
        // 当前选中的分组名称，使用主题颜色高亮显示
        Text(`${this.moveGroup}`).fontSize(16).fontWeight(700).lineHeight(24).fontColor(this.theme.mainColor)
      }
      .padding({
        right:20,
        left:20,
        top:12,
        bottom:12
      })
      Divider()
      
      // 分组列表区域 - 使用Scroll和GridRow实现网格布局
      Scroll(){
        GridRow({
          columns:3  // 每行3列
        }){
          // 遍历分组列表，为每个分组创建选择项
          ForEach(this.sourceGroupList, (item: string, index: number) => {
            GridCol(){
              // 使用titleBuilder构建分组标签
              this.titleBuilder(item)
            }
          })
        }
      }
      .padding(PaddingConstants.PADDING_20)
      .align(Alignment.Top)
      .height('60%')  // 占据60%高度
      .scrollBar(BarState.Off)  // 隐藏滚动条
      
      // 底部按钮区域
      Column(){
        Divider().strokeWidth(0.5)
        buttonCommon({
          confirm:()=>{
            this.confirm()
          },
          cancel:()=>{
            this.cancel()
          }
        })
      }
    }
    // 全屏显示
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
  }

  /**
   * 分组标签构建器
   * @param title - 分组名称
   * 创建可点击的分组标签，点击后更新moveGroup为当前分组
   * 
   * 样式说明：
   * - 灰色背景(6%黑色)
   * - 圆角标签样式
   * - 文字单行显示，超出省略
   * - 固定宽度96，底部外边距16
   */
  @Builder titleBuilder(title:string) {
    Column() {
      Text(title)
        .fontSize(14)
        .textOverflow({
          overflow:TextOverflow.Ellipsis  // 文字超出时显示省略号
        })
        .ellipsisMode(EllipsisMode.END)  // 在末尾省略
        .maxLines(1)  // 最多显示1行
    }
    // 点击事件：选中当前分组
    .onClick(()=>{
      this.moveGroup = title
    })
    .width(96)
    .margin({bottom:PaddingConstants.PADDING_16})
    .backgroundColor($r('app.string.color_black_6'))
    .padding({
      left:16,
      right:16,
      top:8,
      bottom:8
    })
  }
}
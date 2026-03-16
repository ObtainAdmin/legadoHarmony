/**
 * @author 2008
 * @datetime 2024/7/14 22:58
 * @className: SubscriptionContent
 * @description: 订阅内容展示组件 - 用于显示一组订阅源的内容
 *              功能：
 *                - 以卡片形式展示订阅源列表（前2个大卡片，其余小图标）
 *                - 支持长按编辑（编辑、置顶、移动分组、删除）
 *                - 支持批量编辑模式
 *                - 显示最近导入的红点标记（24小时内）
 *              交互：
 *                - 点击跳转订阅源详情
 *                - 长按弹出操作菜单
 *                - 右上角菜单支持批量操作
 *              用途：用于展示"收藏"、"分组"等分类下的订阅源列表
 */
import CommonConstants from '../../../../common/constants/CommonConstants'
import FontConstants from '../../../../common/constants/FontConstants'
import ImageConstants from '../../../../common/constants/ImageConstants'
import PaddingConstants from '../../../../common/constants/PaddingConstants'
import { rssSources } from '../../../../database/entities/rssSources'
import { IconTitleVo } from '../../../../componetsmodel/IconTitleVo'
import dialogTitleFuction from '../../../../componets/common/dialogTitleFuction'
import { showMessage } from '../../../../componets/common/promptShow'
import newSourcesNetWork from '../RssSources/newSourcesNetWork'
import newSources from '../RssSources/newSources'
import { router } from '@kit.ArkUI'
import SubscriptionDao from '../../../../database/dao/SubscriptionDao'
import CircleIcon from '../../../../componets/common/CircleIcon'
import DialogCancelButton from '../../../../componets/common/DialogCancelButton'
import confirmDialogExample from '../../../../componets/common/confirmDialog'
import RssSourceGroup from './RssSourceGroup'
import PreviewEffectImage from './PreviewEffectImage'
import rssSourcesUtils from '../../../../common/utils/rssSourcesUtils'
import { ThemeItem } from '../../../../common/model/Theme'
import { ThemeStorageKey } from '../../../../common/constants/Theme'

/**
 * 订阅内容展示组件
 * 以卡片网格形式展示订阅源，支持多种交互操作
 */
@Component
export default struct SubscriptionContent{
  /** 订阅分组标题 - 从父组件传入，如"收藏"、"分组名" */
  @Prop subscriptionTitle: string
  
  /** 
   * 订阅源列表 - 当前分组下的所有订阅源
   * 类型为rssSources实体对象数组
   */
  @Prop contentList: rssSources[] = []
  
  /**
   * 是否显示操作按钮弹窗 - 控制长按/菜单弹窗的显示
   * true: 显示操作菜单（编辑、置顶、移动、删除）
   * false: 隐藏弹窗
   */
  @State isButtonFunction: boolean = false
  
  /** 
   * 当前操作的订阅源索引 - 用于标识当前选中的订阅源
   * 在长按或点击菜单时设置，用于后续操作
   */
  @State contentIndex:number = 0
  
  /** 
   * 是否处于批量编辑模式 - 从父组件传入
   * true: 显示复选框，支持批量操作
   * false: 正常浏览模式
   */
  @Prop batchEdit: boolean
  
  /**
   * 是否全选 - 从父组件消费的状态
   * 用于批量编辑时控制全选/取消全选
   */
  @Consume('batchAll') batchAll: boolean
  
  /** 
   * 当前主题颜色 - 从全局存储中获取
   * 用于复选框选中颜色等主题相关样式
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * 批量选择列表 - 从父组件消费的状态
   * Record类型，key为订阅源ID，value为是否选中
   */
  @Consume('batchList') batchList: Record<number, boolean>
  
  /**
   * 刷新回调函数 - 从父组件传入
   * 用于操作完成后刷新订阅源列表
   */
  refresh: () => void = () => {

  }
  
  /**
   * 显示添加订阅源弹窗回调 - 从父组件传入
   * 用于"收藏"分组为空时点击添加
   */
  showAddDialog:() => void=() => {

  }

  /**
   * 构建UI布局
   * 整体结构：
   * 1. 标题栏：显示分组名称、操作提示、更多菜单按钮
   * 2. 空状态：收藏分组为空时显示添加按钮
   * 3. 订阅源网格：
   *    - 前2个以大卡片形式展示（2列网格）
   *    - 其余以小图标形式展示（5列网格）
   * 4. 弹窗：编辑弹窗、长按菜单、分组选择、删除确认
   */
  build() {
    Column(){
      Column({
        space:16
      }){
        // 标题栏区域
        Flex({
          justifyContent:FlexAlign.SpaceBetween,
          alignItems: ItemAlign.Center,
          alignContent: FlexAlign.Center
        }) {
          Row({
            space:CommonConstants.SPACE_12
          }){
            // 分组标题
            Text(this.subscriptionTitle)
              .font({
                size:FontConstants.FONT_SIZE_16,
                weight:FontConstants.FONT_WEIGHT_500,
                family: CommonConstants.FAMILY_PingFANG
              })
              .fontColor($r('app.string.color_black_88'))
              .lineHeight(24)
              .padding({
                top: PaddingConstants.PADDING_12,
              })
            // 长按编辑提示
            Text('长按编辑')
              .font({
                size:12,
                weight:FontConstants.FONT_WEIGHT_400,
                family: CommonConstants.FAMILY_PingFANG
              })
              .fontColor($r('app.string.color_black_45'))
              .lineHeight(20)
              .padding({
                top: PaddingConstants.PADDING_12,

              })
          }.alignItems(VerticalAlign.Bottom)

          // 更多操作按钮（菜单）
          Image($r('app.media.more'))
            .fillColor($r('app.string.color_black_45'))
            .width(ImageConstants.IMG_WIDTH_24)
            .height(ImageConstants.IMG_HEIGHT_24)
            .bindMenu(
              this.rightDialogBuilder(this.Item_Right_Dialog_Data, async (index: number) => {
                switch (index) {
                  case 0:
                    showMessage('重命名')
                    break
                  case 1:
                    showMessage('置顶')
                    break
                  case 2:
                    this.isShowGroup = true
                    break
                  case 3:
                    SubscriptionDao.deleteRssSourcesList(this.contentList)
                    setTimeout(()=>{
                      this.refresh()
                    },200)
                    showMessage('删除成功')
                    break
                }
              }),
              {
                onDisappear: () => {

                }
              })
            .onClick(() => {

            })
        }
        
        // 空状态：收藏分组为空时显示添加按钮
        if (this.contentList.length === 0 && this.subscriptionTitle === '收藏'){
          Flex({
            justifyContent:FlexAlign.Start
          }){
            Column(){
              Image($r('app.media.icon_rule_add'))
                .fillColor($r('app.string.color_black_45'))
                .width(24)
                .height(24)
                .margin(10)
            }
            .align(Alignment.Start)
            .justifyContent(FlexAlign.Center)
            .borderRadius(10)
            .backgroundColor($r('app.string.color_black_6'))
          }
          .onClick(()=>{
              this.showAddDialog()
          })
        }

        // 前2个订阅源 - 以大卡片形式展示（2列网格）
        GridRow({
          columns:2
        }){
          ForEach(this.contentList,(item:rssSources,index:number)=>{
            if (index < 2 && !this.batchEdit){
              GridCol({
                span:1
              }){
                Row(){
                  this.contentCoverBuilder(item)
                }
                .onClick(()=>{
                  SubscriptionDao.updateRecentIcon(item)
                  router.pushUrl({
                    url: 'pages/view/Subscription/rssWebView',
                    params: {
                      url: item.sourceUrl,
                      id:item.id
                    }
                  })
                  rssSourcesUtils.pushRssSourcesHistory(item)
                  this.refresh()
                })
                .gesture(
                  LongPressGesture({ repeat: false,duration:500 })
                    .onAction((event: GestureEvent) => {
                      this.contentIndex = index
                      this.isButtonFunction = true
                    }))
              }
            }
          })
        }

        // 其余订阅源 - 以小图标形式展示（5列网格）
        GridRow({
          columns: 5
        }){
          ForEach(this.contentList,(item:rssSources,index:number)=>{
            if (index >= 2 || this.batchEdit) {
              GridCol(){
                this.contentListBuilder(item)
              }
              .onClick(()=>{
                SubscriptionDao.updateRecentIcon(item)
                router.pushUrl({
                  url: 'pages/view/Subscription/rssWebView',
                  params: {
                    url: item.sourceUrl,
                    id: item.id
                  }
                })
                rssSourcesUtils.pushRssSourcesHistory(item)
                this.refresh()
              })
              .gesture(
                LongPressGesture({ repeat: false,duration:500 })
                  .onAction((event: GestureEvent) => {
                    this.contentIndex = index
                    this.isButtonFunction = true
                  }))
            }
          })
        }

      }
      .margin({top: PaddingConstants.PADDING_12})
      .borderRadius(12)
      .backgroundColor(Color.White)
      .padding(20)
      
      // 常规网站编辑弹窗 - 用于编辑网络类型订阅源
      Flex()
        .bindSheet($$this.isShowNewSourcesNetwork,this.newSourcesNetworkBuilder(),{
          height: '95%',
          dragBar: true,
          showClose:false,
          onDisappear:()=>{
            this.isShowNewSourcesNetwork = false
            this.isButtonFunction = false
          }
        })
      
      // 订阅源编辑弹窗 - 用于编辑RSS类型订阅源
      Flex()
        .bindSheet($$this.isShowNewSources,this.newSourcesBuilder(),{
          height: '95%',
          dragBar: true,
          showClose:false,
          onDisappear:()=>{
            this.isShowNewSources = false
          }
        })
      
      // 长按操作弹窗 - 显示编辑、置顶、移动、删除按钮
      Flex()
        .bindSheet($$this.isButtonFunction,this.dialogTitleFuction(),{
          height: 200,
          dragBar: true,
          showClose:false,
          onDisappear:()=>{
            this.contentIndex = -1
          }
        })
      
      // 分组选择弹窗 - 用于移动订阅源到其他分组
      Flex()
        .bindSheet($$this.isShowGroup,this.showCheckGroup(),{
          height: 300,
          dragBar: true,
          showClose:false,
          onDisappear:()=>{
            this.contentIndex = -1
            this.isShowGroup = false
          }
        })

    }
  }
  
  /** 是否显示网络类型订阅源编辑弹窗 */
  @State isShowNewSourcesNetwork:boolean = false
  
  /** 是否显示RSS类型订阅源编辑弹窗 */
  @State isShowNewSources:boolean = false
  
  /** 是否显示分组选择弹窗 */
  @State isShowGroup:boolean = false
  
  /**
   * 网络类型订阅源编辑弹窗构建器
   * 用于编辑网络类型的订阅源（sourceType === 0）
   */
  @Builder
  newSourcesNetworkBuilder(){
    Flex(){
      newSourcesNetWork({
        isEdit:true,
        hideNewWork:()=>{
          this.isShowNewSourcesNetwork = false
          this.refresh()
        },
        formModel:this.contentList[this.contentIndex]
      })
    }
  }

  /**
   * RSS类型订阅源编辑弹窗构建器
   * 用于编辑RSS类型的订阅源（sourceType === 1）
   */
  @Builder
  newSourcesBuilder(){
    Column(){
      newSources({
        isEdit:true,
        hideNewSources:()=>{
          this.isShowNewSources = false
          this.refresh()
        },
        formModel:this.contentList[this.contentIndex]
      })
    }
  }
  
  /** 目标移动分组 - 用于分组选择弹窗 */
  @State moveGroup:string = ''
  
  /**
   * 分组选择弹窗构建器
   * 用于选择目标分组并执行移动操作
   */
  @Builder
  showCheckGroup(){
    Flex(){
      RssSourceGroup({
        moveGroup:this.moveGroup,
        confirm:()=>{
          if (this.contentIndex === undefined){
            showMessage('数据丢失请重新选择')
            return
          }
          if (this.moveGroup) {
            this.contentList[this.contentIndex].sourceGroup = this.moveGroup
            SubscriptionDao.update(this.contentList[this.contentIndex]).then((val)=>{
              if (val) {
                setTimeout(()=>{
                  this.isButtonFunction = false
                  this.isShowGroup = false
                  this.moveGroup = ''
                  showMessage('移动成功')
                  this.refresh()
                },200)
              } else {
                showMessage('移动失败')
              }
            })

          } else {
            showMessage('请选择要移动的分组')
          }
        },
        cancel:()=>{
          this.isShowGroup = false
        }
      })
    }
  }

  /**
   * 右上角菜单数据 - 定义菜单项的图标和标题
   * 包含：重命名、置顶、移动至、删除
   */
  Item_Right_Dialog_Data: IconTitleVo[] = [
    new IconTitleVo($r('app.media.ic_public_edit'), '重命名'),
    new IconTitleVo($r('app.media.icon_operate_top'), '置顶'),
    new IconTitleVo($r('app.media.icon_operate_move'), '移动至'),
    new IconTitleVo($r('app.media.delete_svg'), '删除'),
  ]

  /**
   * 长按操作菜单数据 - 定义长按弹窗的图标和标题
   * 包含：编辑、置顶、移动至、删除
   */
  Item_Dialog_Data: IconTitleVo[] = [
    new IconTitleVo($r('app.media.ic_public_edit'), '编辑'),
    new IconTitleVo($r('app.media.icon_operate_top'), '置顶'),
    new IconTitleVo($r('app.media.icon_operate_move'), '移动至'),
    new IconTitleVo($r('app.media.delete_svg'), '删除'),
  ]

  /**
   * 长按操作弹窗构建器
   * 显示编辑、置顶、移动、删除四个操作按钮
   * 根据订阅源类型(sourceType)决定打开哪种编辑器
   */
  @Builder
  dialogTitleFuction() {
    Column(){
      GridRow({
        columns:4
      }){
       ForEach(this.Item_Dialog_Data,(item:IconTitleVo,index:number)=>{
         GridCol(){
           CircleIcon({
             item:item
           })
         }
         .onClick(()=>{
           switch (index) {
             case 0 :
               // 编辑 - 根据类型打开不同编辑器
               switch (this.contentList[this.contentIndex].sourceType){
                 case 0:
                   this.isShowNewSourcesNetwork = true
                   break
                 case 1:
                   this.isShowNewSources = true
                   break
               }
               break
             case 1:
               // 置顶操作
               this.isTopRssSources()
               break
             case 2:
               // 打开分组选择弹窗
               this.isShowGroup = true
               break
             case 3:
               // 打开删除确认弹窗
               this.rssSourcesDelDialog?.open()
               break
           }
         })
       })
      }
      .padding(PaddingConstants.PADDING_20)
      DialogCancelButton({
        btnClick:()=>{
          this.isButtonFunction = false
          this.contentIndex = -1
        }
      })
    }
    .width('100%')
  }
  
  /** 是否删除缓存 - 用于删除确认弹窗 */
  @State delCache:boolean = false
  
  /**
   * 删除确认弹窗控制器
   * 用于确认删除订阅源操作
   */
  rssSourcesDelDialog: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      confirm: ()=> { this.deleteRssSources() },
      delCache: this.delCache
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    gridCount: 4,
    customStyle: false,
    cornerRadius: 25,
  })

  /**
   * 删除订阅源方法
   * 从数据库删除当前选中的订阅源，并刷新列表
   */
  deleteRssSources(){
    SubscriptionDao.deleteRssSources(this.contentList[this.contentIndex])
      .then((val:boolean)=>{
        val?showMessage('删除成功'):showMessage('删除失败')
        this.rssSourcesDelDialog?.close()
        this.isButtonFunction = false
        this.refresh()
      })
  }

  /**
   * 置顶订阅源方法
   * 将当前选中的订阅源置顶
   */
  isTopRssSources(){
    SubscriptionDao.isTopRssSources(this.contentList[this.contentIndex])
      .then((val:boolean)=>{
        val?showMessage('置顶成功'):showMessage('置顶失败')
        this.rssSourcesDelDialog?.close()
        this.isButtonFunction = false
        this.refresh()
      })
  }

  /**
   * 右侧菜单构建器
   * @param list - 菜单项列表
   * @param dialogRightChange - 菜单项点击回调
   * 用于构建右上角弹出菜单
   * 收藏分组隐藏"重命名"和"删除"选项
   */
  @Builder
  rightDialogBuilder(list: IconTitleVo[], dialogRightChange: (_index: number) => void) {
    Flex({
      justifyContent:FlexAlign.Start,
      direction:FlexDirection.Column
    }){
      ForEach(list, (item: IconTitleVo, index) => {
        if (this.subscriptionTitle.indexOf('收藏') === -1){
          dialogTitleFuction({
            title: item.title,
            icon: item.icon,
            isBorder: list.length !== index + 1
          })
            .onClick(() => {
              dialogRightChange(index)
            })
        } else {
          // 收藏分组只显示置顶和移动
          if (item.title !== '重命名' && item.title !== '删除') {
            dialogTitleFuction({
              title: item.title,
              icon: item.icon,
              isBorder: list.length !== index + 1
            })
              .onClick(() => {
                dialogRightChange(index)
              })
          }
        }

      })
    }

  }
  
  /**
   * 卡片背景颜色数组
   * 用于大卡片背景的随机颜色选择
   */
  colorCheck:string[] = ['#FFE5D4','#FFE3ED','#FCDFDF','#E2F4E4','#FFE5D4','#FFE3ED']
  
  /**
   * 大卡片订阅源构建器（用于前2个订阅源）
   * @param item - 订阅源数据对象
   * 
   * 布局结构：
   * - 水平Row布局：图标 + 名称
   * - 图标右上角显示红点（24小时内导入）
   * - 随机背景颜色
   */
  @Builder
  contentCoverBuilder(item:rssSources){
    Row({
      space:12
    }){
      Stack(){
        // 订阅源图标
        PreviewEffectImage({
          sourceIcon:item.sourceIcon,
          customizeTitle:item.customizeTitle,
          PreviewWidth:ImageConstants.IMG_WIDTH_40,
          PreviewHeight:ImageConstants.IMG_HEIGHT_40,
          isShowTitle:false,
          sourceName:item.sourceName
        })
          .borderRadius(8)

        // 红点标记：24小时内导入的订阅源显示红点
        if (this.isShowRecentIcon(item.lastUpdateTime)  && item.showRecentIcon)
        Row().width(8).height(8)
          .borderRadius(8)
          .backgroundColor('#EF4444')
          .position({
            right: -2,
            top:-2
          })
      }.alignContent(Alignment.TopEnd)
      
      // 订阅源名称
      Text(item.sourceName)
        .font({
          size:14,
          weight:FontConstants.FONT_WEIGHT_500,
          family: CommonConstants.FAMILY_PingFANG
        })
        .layoutWeight(1)
        .lineHeight(22)
        .fontColor($r('app.string.color_black_88'))
    }
    .margin({right:20,bottom:20})
    .borderRadius(12)
    // 随机选择背景颜色
    .backgroundColor(this.colorCheck[Math.floor(Math.random() * this.colorCheck.length)])
    .padding(PaddingConstants.PADDING_12)

  }
  
  /**
   * 判断是否显示最近导入红点
   * @param lastTime - 最后更新时间戳
   * @returns true: 24小时内导入，显示红点；false: 超过24小时，不显示
   * 
   * 计算逻辑：
   * 当前时间 - 最后更新时间 <= 24小时(1000 * 60 * 60 * 24毫秒)
   */
  isShowRecentIcon(lastTime:number){
    return (new Date().getTime() - lastTime)/(1000 * 60 * 60) <= 24
  }

  /**
   * 小图标订阅源构建器（用于其余订阅源）
   * @param item - 订阅源数据对象
   * 
   * 布局结构：
   * - 垂直Column布局：图标 + 名称
   * - 批量编辑模式下显示复选框
   * - 图标右上角显示红点（24小时内导入且非批量编辑模式）
   */
  @Builder
  contentListBuilder(item:rssSources){
    Stack(){
      Column({
        space: CommonConstants.SPACE_6
      }){
        Stack(){
          // 订阅源图标
          PreviewEffectImage({
            sourceIcon:item.sourceIcon,
            customizeTitle:item.customizeTitle,
            PreviewWidth:ImageConstants.IMG_WIDTH_40,
            PreviewHeight:ImageConstants.IMG_HEIGHT_40,
            isShowTitle:false,
            sourceName:item.sourceName
          })
            .borderRadius(8)
          
          // 批量编辑模式下的复选框
          Checkbox({
            group:'checkBatch',
            name:JSON.stringify(item.id)
          })
            .onChange((val)=>{
              if (item.id) {
                this.batchList[item.id] = val
              }
            })
            .select(item?.id?this.batchList[item.id]??false:false)
            .width(15)
            .selectedColor(this.theme.mainColor)
            .unselectedColor('rgba(0, 0, 0, 0.35)')
              .position({
                top:-10,
                right:-10
              })
          .visibility(this.batchEdit?Visibility.Visible:Visibility.None)
          .zIndex(2)
          
          // 红点标记：24小时内导入且非批量编辑模式时显示
          if (this.isShowRecentIcon(item.lastUpdateTime) && item.showRecentIcon && !this.batchEdit){
            Row().width(8).height(8)
              .borderRadius(8)
              .backgroundColor('#EF4444')
              .position({
                right: -2,
                top:-2
              })
          }
        }
        .alignContent(Alignment.TopEnd)

        // 订阅源名称
        Text(`${item.sourceName}`)
          .minFontSize(8)
          .maxFontSize(12)
          .fontSize(10)
          .fontColor($r('app.string.color_black_88'))
          .lineHeight(18)
          .fontFamily(CommonConstants.FAMILY_PingFANG)
          .fontWeight(FontConstants.FONT_WEIGHT_400)
      }.margin({bottom:20})
    } .alignContent(Alignment.TopEnd)
  }
}
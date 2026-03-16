/**
 * @author 2008
 * @datetime 2024/8/7 16:02
 * @className: WebSetup
 * @description: Web页面设置底部弹窗组件 - 提供Web浏览器的快捷操作菜单
 *              功能：刷新页面、分享链接、浏览器打开、UA设置
 *              交互：点击图标触发对应功能，底部弹出式对话框
 */
import PaddingConstants from '../../../../common/constants/PaddingConstants'
import InsideCircleIcon from '../../../../componets/common/InsideCircleIcon'
import { IconTitleVo } from '../../../../componetsmodel/IconTitleVo'
import WebSetupUA from './WebSetupUA'

/**
 * Web设置组件
 * 提供Web浏览器的快捷操作配置界面
 */
@Component
@CustomDialog
export default struct WebSetup {
  /** 对话框控制器 - 用于控制WebSetup弹窗的显示/隐藏 */
  controller?: CustomDialogController
  /** 刷新回调函数 - 点击刷新按钮时触发，用于刷新WebView页面 */
  refreshing:Function = ()=>{}
  /** 复制链接回调函数 - 点击分享按钮时触发，用于复制当前URL */
  copyUrl:Function = ()=>{}
  /** UA设置回调函数 - （预留）用于处理UA设置逻辑 */
  uaSetUp:Function = ()=>{}
  /** 浏览器打开回调函数 - 点击"浏览器打开"时触发，用于外部浏览器打开链接 */
  startBrowsable:Function = ()=>{}
  /** 
   * 功能菜单列表 - 定义底部弹窗显示的功能项
   * 包含：刷新、分享、浏览器打开、UA设置四个功能
   */
  moreList: IconTitleVo[] = [
    new IconTitleVo($r('app.media.icon_web_refresh'), '刷新'),
    new IconTitleVo($r('app.media.ic_public_share'), '分享'),
    new IconTitleVo($r('app.media.browser'), '浏览器打开'),
    new IconTitleVo($r('app.media.phone'), 'UA设置'),
  ]
  /** 底部安全区域高度 - 从全局存储获取，用于适配底部手势条/导航栏 */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0

  /**
   * 构建UI布局
   * 创建底部弹窗式功能菜单，包含4个功能图标和取消按钮
   */
  build() {
    Column(){
      // 功能图标网格区域 - 4列布局展示功能按钮
      GridRow({
        columns:4
      }){
        // 遍历功能列表，为每个功能创建图标按钮
        ForEach(this.moreList,(item:IconTitleVo,index:number)=>{
          GridCol(){
            InsideCircleIcon({
              icon:item.icon,
              title:item.title
            })
          }
          // 点击图标触发对应功能处理
          .onClick(()=>{
            this.webSetUp(index)
          })
        })
      }
      .padding({
        top:PaddingConstants.PADDING_12,
        bottom:PaddingConstants.PADDING_12
      })
      // 取消按钮区域
      Column(){
        Text('取消')
          .onClick(()=>{
            this.controller?.close()
          })
      }
    }
    .padding({
      bottom:this.bottomRectHeight
    })
    .borderRadius({topLeft:20,topRight:20})
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .width('100%')
  }

  /**
   * 功能设置处理方法
   * 根据点击的图标索引执行对应的功能操作
   * @param index - 功能项索引(0-刷新, 1-分享, 2-浏览器打开, 3-UA设置)
   */
  webSetUp(index:number){
    switch (index){
      case 0:
        // 触发刷新回调并关闭弹窗
        this.refreshing()
        this.controller?.close()
        break
      case 1:
        // 触发复制链接回调并关闭弹窗
        this.copyUrl();this.controller?.close();break
      case 2:
        // 触发浏览器打开回调并关闭弹窗
        this.startBrowsable();this.controller?.close();break
      case 3:
        // 打开UA设置二级弹窗
        this.webSetupUADialog?.open();break;

    }
  }

  /**
   * UA设置对话框控制器
   * 用于打开UA设置子对话框，允许用户配置User-Agent
   */
  webSetupUADialog: CustomDialogController | null = new CustomDialogController({
    builder: WebSetupUA(),
    cancel: this.exitDialog,
    autoCancel: true,
    width:'100%',
    alignment: DialogAlignment.Bottom,
    customStyle:true,
    backgroundColor: Color.White,
  })

  /**
   * 退出对话框处理
   * 关闭UA设置对话框和当前WebSetup对话框
   */
  exitDialog(){
    this.webSetupUADialog?.close()
    this.controller?.close()
  }
}
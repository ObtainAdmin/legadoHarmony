/**
 * @author 2008
 * @datetime 2024/7/20 11:40
 * @className: PreviewEffectImage
 * @description: 预览效果图片组件 - 用于显示RSS源的图标预览效果
 *              功能：支持本地图标和网络图标，可自定义标题和尺寸
 *                     当图片加载失败时，自动显示首字母占位图
 *              交互：根据sourceIconIsUrl自动判断图标类型，加载失败时显示首字母占位
 */
import CommonConstants from '../../../../common/constants/CommonConstants'
import FontConstants from '../../../../common/constants/FontConstants'
import { ThemeStorageKey } from '../../../../common/constants/Theme'
import { ThemeItem } from '../../../../common/model/Theme'

/**
 * 预览效果图片组件
 * 用于在订阅源列表中显示RSS源的图标，支持多种显示模式
 */
@Component
export default struct PreviewEffectImage{
  /** 自定义标题 - 当没有图标URL时显示的文字，用于生成首字母占位图 */
  @Prop customizeTitle:string = ''
  
  /** 图标路径 - 可以是本地资源路径(如'app.media.xxx')或网络URL */
  @Prop sourceIcon:string = ''
  
  /** 
   * 图标是否为URL - 控制图标加载方式
   * true: 表示网络图片，直接使用sourceIcon作为URL加载
   * false: 表示本地资源，通过$r()方式加载
   */
  @Prop sourceIconIsUrl:boolean = false
  
  /** 预览图片宽度 - 默认60像素，可根据布局需要调整 */
  @Prop PreviewWidth:number = 60
  
  /** 预览图片高度 - 默认60像素，可根据布局需要调整 */
  @Prop PreviewHeight:number = 60
  
  /** 
   * 是否显示标题 - 控制是否显示"预览效果"文字
   * 通常在大图预览时显示标题，小图标列表中隐藏
   */
  @Prop isShowTitle:boolean = true
  
  /** 图片圆角半径 - 默认4像素，控制图标显示为圆角矩形 */
  @Prop ImageRadius:number = 4
  
  /** 源名称 - 图片加载失败时用于生成占位文字，显示首字符 */
  @Prop sourceName:string = ''
  
  /** 
   * 图片加载错误状态 - 内部状态管理
   * true: 图片加载失败，显示占位图
   * false: 图片加载成功或正在加载
   */
  @State isError:boolean = false
  
  /** 
   * 当前主题颜色 - 从全局存储中获取
   * 用于LoadingProgress进度条的颜色显示
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 构建UI布局
   * 根据状态显示预览效果、加载中或错误占位图
   * 布局结构：垂直排列的Column
   *   - 标题区域(可选): 显示"预览效果"文字
   *   - 图片区域: 根据isError状态显示实际图片或占位图
   */
  build() {
    Column(){
      // 显示标题区域（可选）
      if (this.isShowTitle){
        Flex(){
          Text('预览效果')
            .font({
              size:FontConstants.FONT_SIZE_12,
              weight:FontConstants.FONT_WEIGHT_400,
              family:CommonConstants.FAMILY_PingFANG
            })
            .lineHeight(20)
            .fontColor($r('app.string.color_black_45'))
        }
      }
      // 根据加载状态显示不同内容
      if (this.isError){
        // 图片加载失败，显示占位图
        this.ImageStack(true)
      } else {
        // 正常显示，包含加载进度
        Stack(){
          this.ImageStack(this.customizeTitle.length > 0 && !this.sourceIconIsUrl)
          // 加载中状态 - 显示进度条和提示文字
          Column(){
            LoadingProgress().color(this.theme.mainColor).height(30)
            Text('图片加载中...').fontSize(5).fontColor(this.theme.mainColor)
          }.zIndex(-1)
        }
      }
    }
  }

  /**
   * 占位图名称数组 - 用于图片加载失败时显示不同颜色/样式的占位背景
   * 数组元素对应资源文件：icon_check_image_one 到 icon_check_image_ten
   * 根据源名称长度选择不同的预设图标，使不同源的占位图有所区别
   */
  initialImage:string[] = ['one','two','three','four','five','six','seven','eight','nine','ten']

  /**
   * 图片堆叠布局构建器
   * @param isShow - 是否显示自定义标题文字（true时显示首字母）
   * 功能：构建图片或占位图的堆叠布局
   * 
   * 布局说明：
   * - Stack容器内包含两个层级：
   *   1. 文字层（zIndex:9）: 显示源名称或自定义标题的首字母
   *   2. 图片层: 显示实际图标或预设占位图标
   * 
   * 显示逻辑：
   * - isError为true时: 显示预设占位图标(使用initialImage数组根据sourceName长度选择)
   * - isError为false时: 显示实际图标(本地资源或网络图片)
   */
  @Builder ImageStack(isShow:boolean){
    Stack(){
      // 显示文字层（错误时显示源名称首字母，正常时显示自定义标题首字母）
      if (isShow || this.isError){
        Text(this.isError?this.sourceName.slice(0,1):this.customizeTitle.slice(0,1)).font({
          size:FontConstants.FONT_SIZE_16,
          weight:FontConstants.FONT_WEIGHT_700,
          family:CommonConstants.FAMILY_PingFANG
        })
          .zIndex(9)
          .fontColor(Color.White)
      }
      // 图片显示层
      if (this.isError){
        // 错误状态：显示预设的占位图标
        // 根据源名称长度选择不同的背景图标（icon_check_image_one ~ icon_check_image_ten）
        Image($r(`app.media.icon_check_image_${this.initialImage[this.sourceName.slice(0,9).length]}`))
          .width(this.PreviewWidth)
          .height(this.PreviewHeight)
          .animation(({
            duration:1000
          }))
          .draggable(false)
          .borderRadius(this.ImageRadius)
      } else {
        // 正常状态：显示实际图标
        // 支持本地资源（app.media.xxx）和网络URL
        Image(this.sourceIcon.indexOf('app.media.')>-1?$r(this.sourceIcon):this.sourceIcon)
          .width(this.PreviewWidth)
          .height(this.PreviewHeight)
          .animation(({
            duration:1000
          }))
          .draggable(false)
          .borderRadius(this.ImageRadius)
          // 图片加载失败回调 - 切换到错误状态显示占位图
          .onError(()=>{
            this.isError = true
          })
      }

    }
  }
}
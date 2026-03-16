/**
 * @author 2008
 * @datetime 2024/7/19 23:58
 * @className: RssSourceCheckImage
 * @description: RSS源自定义图标选择器组件
 *              功能：提供自定义图标标题输入、预设图标背景选择、实时预览效果
 *              交互：输入单字标题、选择背景图标、实时预览效果、提交/取消操作
 *              用途：用于新建或编辑RSS源时自定义显示图标
 */
import CommonConstants from '../../../../common/constants/CommonConstants'
import FontConstants from '../../../../common/constants/FontConstants'
import PaddingConstants from '../../../../common/constants/PaddingConstants'
import { ThemeStorageKey } from '../../../../common/constants/Theme'
import { ThemeItem } from '../../../../common/model/Theme'
import buttonCommon from '../../../../componets/common/buttonCommon'
import FormInput from '../../../../componets/Form/FormInput'
import PreviewEffectImage from './PreviewEffectImage'

/**
 * RSS源自定义图标选择器组件
 * 提供图标自定义功能，包括标题文字和背景样式选择
 */
@Component
@Preview
export default struct RssSourceCheckImage{
  /** 自定义标题 - 用户输入的单字标题，用于显示在图标中心 */
  @Prop customizeTitle:string = ''
  
  /** 当前选中的图标索引 - 用于Radio组件的选中状态 */
  @State imageIndex:number = 0
  
  /** 标题最大长度限制 - 限制用户只能输入1个字符 */
  maxLength:number = 1
  
  /** 
   * 预设图标资源字符串数组 - 定义10种可选的背景图标
   * 对应资源文件：icon_check_image_one 到 icon_check_image_ten
   * 这些图标用于作为自定义图标的背景
   */
  @State
  ImageCheckString:string[] = [
    'app.media.icon_check_image_one',
    'app.media.icon_check_image_two',
    'app.media.icon_check_image_three',
    'app.media.icon_check_image_four',
    'app.media.icon_check_image_five',
    'app.media.icon_check_image_six',
    'app.media.icon_check_image_seven',
    'app.media.icon_check_image_eight',
    'app.media.icon_check_image_nine',
    'app.media.icon_check_image_ten'
  ]
  
  /** 当前选中的图标资源字符串 - 用于PreviewEffectImage组件显示 */
  @Prop imageString:string = ''
  
  /**
   * 提交回调函数
   * @param _value - 输入的自定义标题
   * @param _imageString - 选中的图标资源路径
   * 当用户点击确认按钮时触发，将选择结果传递给父组件
   */
  onSubmit:Function = (_value: string, _imageString:string) => {}
  
  /**
   * 取消回调函数
   * 当用户点击取消按钮时触发，关闭选择器而不保存
   */
  onCancel:Function = ()=>{}
  
  /** 滚动控制器 - 用于图标列表的水平滚动控制 */
  scroller: Scroller = new Scroller()
  
  /** 
   * 当前主题颜色 - 从全局存储中获取
   * 用于Radio选中状态的颜色显示
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 构建UI布局
   * 整体采用Flex垂直布局，分为三个区域：
   * 1. 顶部输入区：标题输入框和图标选择列表
   * 2. 中部预览区：实时显示图标效果
   * 3. 底部按钮区：确认和取消按钮
   */
  build() {
    Flex({
      direction:FlexDirection.Column,
      justifyContent:FlexAlign.SpaceBetween
    }){
      // 顶部输入区域 - 包含标题输入、图标选择、效果预览
      Column({
        space:12
      }){
        // 标题文字
        Text('自定义图标')
          .font({
            size:FontConstants.FONT_SIZE_16,
            weight:FontConstants.FONT_WEIGHT_500,
            family:CommonConstants.FAMILY_PingFANG
          })
          .fontColor($r('app.string.color_black_88'))
          .lineHeight(24)
        
        // 标题输入框 - 限制最大长度为1个字符
        FormInput({
          value:this.customizeTitle,
          maxLength:this.maxLength,
          onChange:(value:string)=>{
            this.customizeTitle = value
          }
        })
        
       // 图标选择区域
       Column(){
       	// 区域标题
       	Flex(){
       	  Text('选择图标背景')
       	    .font({
       	      size:FontConstants.FONT_SIZE_12,
       	      weight:FontConstants.FONT_WEIGHT_400,
       	      family:CommonConstants.FAMILY_PingFANG
       	    })
       	    .lineHeight(20)
       	    .fontColor($r('app.string.color_black_45'))
       	}
       	
       	// 水平滚动列表 - 展示所有可选图标背景
       	List({
       	  scroller:this.scroller,
       	  space:12
       	}){
       	  // 遍历预设图标数组，为每个图标创建选择项
       	  ForEach(this.ImageCheckString,(item:string,index:number)=>{
       	    ListItem(){
       	      Stack(){
       	        /**
       	         * 单选按钮 - 用于选择图标背景
       	         * @param value - Radio的值为索引的JSON字符串
       	         * @param group - 所属组名'iconGroup'，确保单选互斥
       	         */
       	        Radio({value:JSON.stringify(index),group:'iconGroup'})
       	          .radioStyle({
       	            checkedBackgroundColor: this.theme.mainColor
       	          })
       	          .zIndex(999)
       	          .onChange(()=>{
       	            // 选中时更新imageString为对应图标资源路径
       	            this.imageString = item
       	          })
       	        
       	        // 图标预览
       	        Image($r(item))
       	          .width(42)
       	          .height(42)
       	      }
       	    }
       	  })
       	}
       	// 列表配置：启用链式动画、弹簧边缘效果、水平方向、隐藏滚动条
       	.chainAnimation(true)
       	.edgeEffect(EdgeEffect.Spring)
       	.listDirection(Axis.Horizontal)
       	.scrollBar(BarState.Off)
       	.padding({top:PaddingConstants.PADDING_12})
       }
       .height(80)
       
        // 实时预览组件 - 只有当标题和图标都选择后才显示
        PreviewEffectImage({
          customizeTitle:this.customizeTitle,
          sourceIcon:this.imageString
        })
          // 根据条件控制可见性和动画效果
          .visibility(this.imageString && this.customizeTitle ?Visibility.Visible:Visibility.None)
          .opacity(this.imageString && this.customizeTitle ?1:0)
          .scale({
            centerX: "50%",
            centerY: "50%",
            x: this.imageString && this.customizeTitle  ? 1 : 0,
            y: this.imageString && this.customizeTitle  ? 1 : 0,
          })
          // 配置入场动画：600ms，使用自定义缓动曲线
          .animation({
            duration: 600,
            curve: CommonConstants.UniCurve
          })
      }
      .padding(PaddingConstants.PADDING_20)
      
      // 底部按钮区域
      Column(){
        Divider().strokeWidth(0.5)
        // 通用按钮组件 - 包含确认和取消按钮
        buttonCommon({
          confirm:()=>{
            // 点击确认时触发onSubmit回调，传递标题和图标
            this.onSubmit(this.customizeTitle,this.imageString)
          },
          cancel:()=>{
            // 点击取消时触发onCancel回调
            this.onCancel()
          }
        })
      }
      .padding({
        bottom:PaddingConstants.PADDING_20
      })
    }
    // 组件尺寸：全屏显示
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
  }
}
/**
 * 封面图片显示组件 - 提供多种书籍封面显示样式
 * 
 * 功能概述：
 * 1. 根据封面数量（coverCount）显示不同的封面样式
 * 2. 支持三种样式：默认样式、自定义样式、全图样式
 * 3. 提供单选按钮供用户选择样式
 * 4. 支持自定义图片上传和显示
 * 
 * 样式说明：
 * - coverCount=1：默认样式，使用BookOverlay组件显示书籍封面
 * - coverCount=2：自定义样式，具有重叠阴影效果的封面显示
 * - coverCount=3：全图样式，大尺寸全图显示
 * 
 * 使用场景：
 * 在书籍编辑、主题设置等需要选择封面样式的界面中使用
 * 
 * @author 2008
 * @datetime 2024/5/27 16:09
 * @className: coverInfoImageShow
 */

import CommonConstants from '../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'
import BookOverlay from '../../componets/bookDetail/BookOverlay'

/**
 * 封面图片显示组件结构体
 * 
 * 职责：
 * 1. 根据封面数量渲染对应的封面样式
 * 2. 管理封面样式的选择状态
 * 3. 处理用户样式选择事件
 * 4. 应用主题颜色到交互元素
 * 
 * 设计特点：
 * - 使用条件渲染，根据coverCount显示不同样式
 * - 提供单选按钮供用户选择偏好样式
 * - 支持外部图片资源和本地资源
 */
@Component
export default struct coverInfoImageShow {
  /** 封面数量，决定显示的样式类型：1-默认，2-自定义，3-全图 */
  @Prop coverCount:number
  
  /** 封面图片资源，可以是Resource对象或图片URL字符串 */
  @Prop image:Resource|string
  
  /** 封面图片字符串表示，用于自定义样式和全图样式 */
  @Prop imageString:string
  
  /** 当前选中的图片样式索引：0-默认，1-自定义，2-全图 */
  @Prop selectImage:number = 0
  
  /** 样式选择回调函数，当用户选择不同样式时调用 */
  onSelectImageNumber:Function = (_selectImage:number)=>{}
  
  /** 应用主题配置，从应用存储中读取，用于单选按钮等交互元素 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  /**
   * 构建组件UI的主要方法
   * 
   * 逻辑流程：
   * 根据coverCount的值决定渲染哪种封面样式
   * - coverCount=1：渲染默认样式
   * - coverCount=2：渲染自定义样式（重叠阴影效果）
   * - coverCount=3：渲染全图样式
   * 
   * 设计考虑：
   * 使用条件分支而不是动态组件，因为每种样式的布局差异较大
   * 这样可以保持代码的清晰性和可维护性
   */
  build() {
    if (this.coverCount === 1){
      this.coverImageOne(this.image)
    } else if (this.coverCount === 2){
      this.coverImageTwo()
    } else if (this.coverCount === 3){
      this.coverImageThree()
    }
  }

  /**
   * 构建默认封面样式（coverCount=1）
   * 
   * 样式特点：
   * 1. 使用BookOverlay组件显示书籍封面，带有装饰性叠加效果
   * 2. 底部有白色装饰条，增加视觉层次
   * 3. 提供"默认样式"标签和单选按钮
   * 
   * 交互功能：
   * - 单选按钮使用主题颜色
   * - 选择时触发onSelectImageNumber回调
   * 
   * @param bookImage 书籍封面图片资源
   */
  @Builder coverImageOne(bookImage:Resource|string){
    Column(){
      // 使用BookOverlay组件显示书籍封面，带有装饰性效果
      BookOverlay({
        bookImage:bookImage
      })
      
      // 白色装饰条，增加视觉层次感
      Row().width(86)
        .height(20)
        .backgroundColor(Color.White)
        .borderRadius(2)
        .shadow({ radius: 5, color: 'rgba(0, 0, 0, 0.10)' })
      
      // 样式标签和选择按钮
      Row({
        space:12
      }){
        // 样式名称标签
        Text('默认样式')
          .fontWeight(400)
          .fontSize(14)
          .fontColor($r('app.string.color_black_45'))
          .lineHeight(22)
        
        // 单选按钮，用于选择此样式
        Radio({value:JSON.stringify('0'),group:'radioGroup'})
          .checked(this.selectImage === 0)  // 根据当前选中状态设置checked
          .radioStyle({
            checkedBackgroundColor: this.theme.mainColor  // 使用主题颜色
          })
          .border({width:2,color:'rgba(255, 255, 255, 0.10)'})
          .width(20).height(20)
          .onChange((val)=>{
            val? this.onSelectImageNumber(0):''  // 触发选择回调
          })
      }
      .padding({top:8})
    }
  }

  /**
   * 构建自定义封面样式（coverCount=2）
   * 
   * 样式特点：
   * 1. 使用Stack布局创建重叠阴影效果
   * 2. 三层叠加：主图片、第一层阴影、第二层阴影
   * 3. 支持自定义图片上传，无图片时显示上传提示
   * 4. 具有立体感和深度感的视觉效果
   * 
   * 布局层次（从下到上）：
   * - zIndex=0：第二层阴影（最大尺寸）
   * - zIndex=1：第一层阴影（中等尺寸）
   * - zIndex=2：主图片（标准尺寸）
   * 
   * 交互功能：提供"自定义"标签和单选按钮
   */
  @Builder coverImageTwo(){
    Column(){
      // 使用Stack创建重叠效果
      Stack(){
        // 主图片层（最上层）
        Flex({
          alignItems: ItemAlign.End,
        }){
          if (this.imageString) {
            // 显示自定义图片
            Image(this.imageString).draggable(false)
          } else {
            // 无图片时显示上传提示
            Column(){
              Image($r('app.media.add_image')).width(24).height(24).draggable(false)
              Text('添加图片或gif').fontColor(Color.White).fontWeight(400).fontSize(10).lineHeight(18)
            }
            .padding({top:19,bottom:19,left:17,right:17})
          }
        }
        .borderRadius(5)
        .backgroundColor($r('app.string.color_black_65'))  // 深色背景
        .align(Alignment.Start)
        .width(CommonConstants.NOVEL_IMG_WIDTH).height(CommonConstants.NOVEL_IMG_HEIGHT)
        .zIndex(2)  // 最上层

        // 第一层阴影（中间层）
        Row(){
          Image($r('app.media.occlusion1')).draggable(false)
        }
        .zIndex(1)
        .width(CommonConstants.NOVEL_IMG_WIDTH + 5).height(CommonConstants.NOVEL_IMG_HEIGHT - 5)

        // 第二层阴影（最底层）
        Row(){
          Image($r('app.media.occlusion2')).draggable(false)
        }.zIndex(0)
        .width(CommonConstants.NOVEL_IMG_WIDTH + 10).height(CommonConstants.NOVEL_IMG_HEIGHT - 10)
      }
      .align(Alignment.BottomStart)  // 底部对齐
      
      // 白色装饰条
      Row().width(86).height(20).backgroundColor(Color.White).borderRadius(2)
        .shadow({ radius: 5, color: 'rgba(0, 0, 0, 0.10)' })
      
      // 样式标签和选择按钮
      Row({
        space:12
      }){
        Text('自定义')
          .fontWeight(400).fontSize(14).fontColor($r('app.string.color_black_45')).lineHeight(22)
        Radio({value:JSON.stringify('1'),group:'radioGroup'})
          .checked(this.selectImage === 1)
          .radioStyle({
            checkedBackgroundColor: this.theme.mainColor
          })
          .border({width:2,color:'rgba(255, 255, 255, 0.10)'})
          .width(20).height(20)
          .onChange((val)=>{
            val? this.onSelectImageNumber(1):''
          })
      }
      .padding({top:8})
    }
  }

  /**
   * 构建全图封面样式（coverCount=3）
   * 
   * 样式特点：
   * 1. 大尺寸全图显示，比标准尺寸更大
   * 2. 简单的Flex布局，无重叠效果
   * 3. 支持自定义图片上传，无图片时显示上传提示
   * 4. 适合需要突出显示封面图片的场景
   * 
   * 尺寸说明：
   * - 宽度：NOVEL_IMG_WIDTH + 14（比标准宽度大14像素）
   * - 高度：NOVEL_IMG_HEIGHT + 18（比标准高度大18像素）
   * 
   * 交互功能：提供"全图样式"标签和单选按钮
   */
  @Builder coverImageThree(){
    Column(){
      // 大尺寸全图容器
      Flex({
        alignItems: ItemAlign.End,
      }){
        if (this.imageString) {
          // 显示自定义图片
          Image(this.imageString)
        } else {
          // 无图片时显示上传提示
          Column(){
            Image($r('app.media.add_image')).width(24).height(24)
            Text('添加图片或gif').fontColor(Color.White).fontWeight(400).fontSize(10).lineHeight(18)
          }.padding({top:37,bottom:37,left:14,right:13})
        }
      }
      .borderRadius(5)
      .backgroundColor($r('app.string.color_black_65'))  // 深色背景
      .align(Alignment.Start)
      .width(CommonConstants.NOVEL_IMG_WIDTH + 14).height(CommonConstants.NOVEL_IMG_HEIGHT + 18)
      
      // 样式标签和选择按钮
      Row({
        space:12
      }){
        // 样式名称标签
        Text('全图样式')
          .fontWeight(400).fontSize(14).fontColor($r('app.string.color_black_45')).lineHeight(22)
        
        // 单选按钮，用于选择此样式
        Radio({value:JSON.stringify('2'),group:'radioGroup'})
          .checked(this.selectImage === 2)
          .radioStyle({
            checkedBackgroundColor: this.theme.mainColor
          })
          .border({width:2,color:'rgba(255, 255, 255, 0.10)'})
          .width(20).height(20)
          .onChange((val)=>{
            val? this.onSelectImageNumber(2):''  // 触发选择回调
          })
      }
      .padding({top:8})
    }
  }
}

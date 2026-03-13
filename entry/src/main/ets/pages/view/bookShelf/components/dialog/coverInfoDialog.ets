import { pickerAvatar } from '../../../../../common/utils/photoViewPicker'
import coverInfoImageShow from '../../../coverInfoImageShow'
import { BookGroups } from '../../../../../database/entities/BookGroups'
import { showMessage } from '../../../../../componets/common/promptShow'
import buttonCommon from '../../../../../componets/common/buttonCommon'
import bookGroupUtil from '../../../../../common/utils/bookGroupUtils'
import { ThemeItem } from '../../../../../common/model/Theme'
import { ThemeStorageKey } from '../../../../../common/constants/Theme'

@CustomDialog
/**
 * 分组封面信息对话框组件
 * 
 * 功能概述：
 * 1. 提供分组封面设置界面，支持三种封面显示模式
 * 2. 允许用户从相册选择封面图片
 * 3. 设置封面是否仅用于当前分组
 * 4. 更新分组封面信息到数据库
 * 
 * 使用场景：
 * - 在分组管理中选择封面设置时弹出此对话框
 * - 用户可以为分组设置个性化封面
 * 
 * 组件特点：
 * - 使用@CustomDialog装饰器，作为自定义对话框组件
 * - 使用@Preview装饰器，支持预览模式
 * - 集成相册图片选择功能
 * - 支持主题颜色适配
 * - 三种封面显示模式切换
 */
@Preview
export default struct coverInfoDialog{
  /** 对话框控制器，用于控制对话框的显示和隐藏 */
  controller?: CustomDialogController
  
  /** 
   * 分组数据，通过@Prop装饰器从父组件传入
   * 包含分组的基本信息：分组ID、分组名称、封面URL、封面类型、封面仅用于当前分组标志等
   */
  @Prop itemData:BookGroups
  
  /** 封面图片URL，用于临时存储用户选择的图片 */
  @State coverImages:string = ''
  
  /** 分组刷新状态标识，通过@StorageLink与AppStorage同步，触发分组数据刷新 */
  @StorageLink('BOOK_IS_BOOK_GROUPS_REFRESHING') BOOK_IS_BOOK_GROUPS_REFRESHING: number = 0
  
  /** 取消回调函数，对话框关闭时调用 */
  cancel: () => void = () => {
  }
  
  /**
   * 组件初始化方法
   * 功能：在组件即将显示时调用，初始化封面图片URL
   */
  aboutToAppear(): void {
    this.coverImages = this.itemData.coverUrl??''  // 从分组数据加载封面URL
  }
  
  /** 封面文件夹状态（暂未使用） */
  @State coverFolder:boolean = false
  
  /** 主题颜色，通过@StorageProp从AppStorage获取 */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  /**
   * 构建对话框UI布局
   * 
   * 布局结构：
   * 1. 顶部：分组信息区域（分组名称、书籍数量）和"仅用于当前分组"开关
   * 2. 中部：封面选择区域（三种封面显示模式）
   * 3. 底部：操作按钮区域（取消、确定）
   * 
   * 设计特点：
   * - 使用圆角顶部边框（topLeft:20, topRight:20）
   * - 白色背景，符合HarmonyOS设计规范
   * - 响应式布局，适应不同屏幕尺寸
   * - 使用主题颜色系统化按钮样式
   */
  build() {
    Column(){
      // 顶部：分组信息和设置区域
      Flex({
        justifyContent:FlexAlign.SpaceBetween,
        alignItems:ItemAlign.Center
      }){
        // 左侧：分组信息
        Column(){
          Text(this.itemData.groupName).fontColor('rgba(0, 0, 0, 0.88)').fontSize(16).fontWeight(500).lineHeight(24)
          Text(`共${0}本`).fontColor('rgba(0, 0, 0, 0.45)').fontWeight(400).lineHeight(20).fontSize(12)  // 注意：书籍数量固定为0，可能需要动态获取
        }
        // 右侧："仅用于当前分组"开关
        Row(){
          Text('仅用于当前分组')
          Toggle({ type: ToggleType.Switch, isOn: this.itemData.coverOnly})
            .selectedColor("#F60").hoverEffect(HoverEffect.None)  // 橙色选中状态
            .onChange((val)=>{
              this.itemData.coverOnly = val  // 更新封面仅用于当前分组标志
            })
        }
      }.padding(20)
      
      // 分割线
      Divider().strokeWidth(0.5)
      
      // 中部：封面选择区域（三种显示模式）
      Flex({
        direction: FlexDirection.Row,
        justifyContent:FlexAlign.SpaceBetween
      }){
        // 模式1：显示当前封面（不可点击）
        coverInfoImageShow({
          coverCount:1,
          image:this.itemData.coverUrl,
          selectImage:this.itemData.coverType??0,
          onSelectImageNumber:(number:number)=>{
            this.itemData.coverType = number  // 更新封面类型
          }
        })
        // 模式2：自定义封面（可点击选择图片）
        coverInfoImageShow({
          coverCount:2,
          imageString:this.coverImages,
          selectImage:this.itemData.coverType??0,
          onSelectImageNumber:(number:number)=>{
            this.itemData.coverType = number  // 更新封面类型
          }
        }).onClick(()=>{
          this.setCoverImages()  // 点击选择图片
        })
        // 模式3：自定义封面（可点击选择图片）
        coverInfoImageShow({
          coverCount:3,
          imageString:this.coverImages,
          selectImage:this.itemData.coverType??0,
          onSelectImageNumber:(number:number)=>{
            this.itemData.coverType = number  // 更新封面类型
          }
        }).onClick(()=>{
          this.setCoverImages()  // 点击选择图片
        })
      }.padding(20)
      
      // 分割线
      Divider().strokeWidth(0.5).padding({bottom:16})
      
      // 底部：操作按钮区域
      Column(){
        Flex({
          justifyContent:FlexAlign.SpaceBetween
        }) {
          // 取消按钮（使用主题次要颜色）
          Column(){
            Text('取消').fontSize(16).fontWeight(400).fontColor(this.theme.mainColor)
              .lineHeight(24)
              .padding({left:32,right:32,bottom:8,top:8})
          }
          .onClick(()=>{
            this.cancel()  // 执行取消回调
          })
          .width('49%')  // 占据49%宽度
          .borderRadius(20)  // 圆角
          .alignItems(HorizontalAlign.Center)  // 居中
          .backgroundColor(this.theme.secondColor)  // 使用主题次要颜色作为背景
          
          // 确定按钮（使用主题主颜色）
          Column(){
            Text('确定')
              .fontSize(16)
              .fontWeight(400)
              .fontColor(Color.White)  // 白色文字
              .lineHeight(24)
              .padding({left:32,right:32,bottom:8,top:8})
              .onClick(async ()=>{
                bookGroupUtil.updatePartialGroup(this.itemData)  // 更新分组信息
                setTimeout(()=>{
                  this.BOOK_IS_BOOK_GROUPS_REFRESHING++  // 触发分组刷新
                  this.controller?.close()  // 关闭对话框
                  showMessage('修改成功!')  // 显示成功提示
                },100)
              })
          }
          .width('49%')  // 占据49%宽度
          .borderRadius(20)  // 圆角
          .alignItems(HorizontalAlign.Center)  // 居中
          .backgroundColor(this.theme.mainColor)  // 使用主题主颜色作为背景
        }
      }
      .alignItems(HorizontalAlign.Center)  // 水平居中
      .padding({right:20,left:20,bottom:16})  // 内边距
    }
    .borderRadius({topLeft:20,topRight:20})  // 顶部圆角
    .backgroundColor(Color.White)  // 白色背景
    .width('100%')  // 全宽
  }

  /**
   * 设置封面图片
   * 
   * 功能：打开相册选择器，让用户选择封面图片
   * 逻辑：
   * 1. 调用pickerAvatar()打开相册选择器
   * 2. 获取用户选择的图片URI
   * 3. 更新coverImages状态和itemData.coverUrl
   * 
   * 注意：此方法为异步方法，需要等待用户选择完成
   */
  async setCoverImages(){
    let imageUrl = await pickerAvatar();  // 打开相册选择器
    this.coverImages = imageUrl?.photoUris[0] || ''  // 获取第一张图片的URI
    this.itemData.coverUrl = this.coverImages  // 更新分组封面URL
  }
}

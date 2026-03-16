/**
 * @author 2008
 * @datetime 2024/5/23 22:21
 * @className: shareShelfBook
 * 
 * 书单分享对话框组件
 * 
 * 功能说明：
 * 1. 显示书单信息（名称、描述、包含的书籍）
 * 2. 提供多种分享方式：微信、QQ、朋友圈、QQ空间、导出本地、复制链接、保存图片、系统分享
 * 3. 支持将书单内容保存为图片到本地相册
 * 4. 支持设置分享链接的有效期（7天或永久有效）
 * 5. 显示书籍封面、名称、简介和推荐语
 * 
 * 使用方法：
 * 1. 通过CustomDialogController打开此对话框
 * 2. 传入works参数作为要分享的书单数据
 * 3. 对话框会自动加载书单中的书籍信息
 * 
 * 参数说明：
 * @controller - 自定义对话框控制器，用于控制对话框的显示和隐藏
 * @works - 书单数据，包含书单名称、描述、书籍列表等信息
 * @buttonListInfo - 分享按钮列表，包含8种分享方式
 * @bookList - 书单中的书籍列表，从数据库加载
 * @appContext - 应用上下文，用于权限申请
 * @atManager - 权限管理器，用于申请保存图片权限
 * @pixmap - 组件截图生成的像素图，用于保存图片
 * @validDate - 链接有效期，默认为"7天有效"
 * @footerDialogShow - 底部对话框显示状态，控制有效期选择对话框
 * 
 * 技术实现说明：
 * 1. 使用ArkUI框架构建自定义对话框组件
 * 2. 采用Stack布局实现多层叠加效果（背景遮罩、内容区域、底部操作栏）
 * 3. 使用componentSnapshot API进行组件截图，生成分享图片
 * 4. 集成媒体库API保存图片到相册
 * 5. 使用权限管理API申请存储权限
 * 6. 采用响应式状态管理，数据变化自动更新UI
 * 
 * 注意事项：
 * 1. 保存图片功能需要用户授予WRITE_IMAGEVIDEO权限
 * 2. 书单中的书籍信息通过异步方式从数据库加载
 * 3. 分享功能目前仅显示提示信息，实际分享功能需要集成第三方SDK
 * 4. 组件包含一个隐藏的Column（id='shareBook'）用于生成分享图片
 */
// 组件导入：圆形图标组件，用于分享按钮的图标显示
import InsideCircleIcon from '../../../componets/common/InsideCircleIcon'
// 数据模型导入：按钮列表数据模型，定义分享按钮的数据结构
import { buttonList } from '../../../componets/dataList/buttonList'
// ArkUI API导入：组件截图功能，用于将组件内容转换为图片
import componentSnapshot from '@ohos.arkui.componentSnapshot'
// 多媒体API导入：图像处理功能，用于图片的编码和像素图操作
import image from '@ohos.multimedia.image'
// 文件系统API导入：文件读写操作，用于保存图片到本地文件
import fs from '@ohos.file.fs';
// 媒体库API导入：相册访问助手，用于将图片保存到系统相册
import { photoAccessHelper } from '@kit.MediaLibraryKit'
// 工具函数导入：消息提示组件，用于显示操作反馈
import { showMessage } from '../../../componets/common/promptShow'
// AbilityKit API导入：权限管理和上下文功能
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
// 基础服务API导入：错误处理类型定义
import { BusinessError } from '@kit.BasicServicesKit'
// 数据库实体导入：书单数据实体，定义书单的数据结构
import { WorksLists } from '../../../database/entities/WorksLists'
// 工具类导入：书单工具函数，提供书单相关操作
import worksListsUtils from '../../../common/utils/WorksListsUtils'
// 数据访问对象导入：书籍数据访问对象，提供数据库操作接口
import BooksDao from '../../../database/dao/BooksDao'
// 数据库实体导入：书籍数据实体，定义书籍的数据结构
import { Books } from '../../../database/entities/Books'
// 常量导入：内边距常量，统一UI间距标准
import PaddingConstants from '../../../common/constants/PaddingConstants'

// @CustomDialog装饰器：声明此组件为自定义对话框组件，可通过CustomDialogController控制显示/隐藏
// @Preview装饰器：允许在DevEco Studio的预览器中预览此组件
// @Component装饰器：声明此结构体为ArkUI组件，具有组件化能力
@CustomDialog
@Preview
@Component
export default struct shareWorksBook {
  // 对话框控制器：可选参数，用于控制对话框的显示和隐藏
  // 当通过CustomDialogController打开对话框时，系统会自动注入此控制器
  controller?: CustomDialogController
  
  // 书单数据：通过@Prop装饰器声明为组件的输入属性
  // 类型为WorksLists，包含书单名称、描述、书籍列表等完整信息
  // @Prop装饰器表示此属性由父组件传入，组件内部不能修改
  @Prop works:WorksLists
  
  // 分享按钮列表：通过@State装饰器声明为组件的状态变量
  // @State装饰器表示此变量是响应式的，当其值变化时会触发UI更新
  // 包含8种分享方式：微信、QQ、朋友圈、QQ空间、导出本地、复制链接、保存图片、系统分享
  // 每个按钮包含id、标题和图标资源
  @State buttonListInfo: buttonList[] = [
    new buttonList(1, '微信', $r('app.media.wechat')),
    new buttonList(2, 'QQ', $r('app.media.QQ_blue')),
    new buttonList(3, '朋友圈', $r('app.media.circle_friends')),
    new buttonList(4, 'QQ空间', $r('app.media.QQ_space')),
    new buttonList(5, '导出本地', $r('app.media.export')),
    new buttonList(6, '复制链接', $r('app.media.copy_link')),
    new buttonList(7, '保存图片', $r('app.media.save_img')),
    new buttonList(8, '系统分享', $r('app.media.more'))
  ]
  // 书籍列表：通过@State装饰器声明为组件的状态变量
  // 存储从数据库加载的书单中的书籍信息，初始为空数组
  // 当数据加载完成后，UI会自动更新显示书籍信息
  @State bookList:Books[] = []

  // aboutToAppear生命周期方法：在组件即将显示时调用
  // 异步方法，用于执行初始化操作，如加载书单中的书籍信息
  // 工作流程：
  // 1. 检查书单中是否有书籍列表(worksBookList)
  // 2. 如果有，使用worksListsUtils工具提取书籍ID数组
  // 3. 如果ID数组不为空，调用getBookIds方法加载书籍详情
  async aboutToAppear(): Promise<void> {
    if (this.works.worksBookList) {
      let bookIds = worksListsUtils.getBookIds(this.works.worksBookList)
      if (bookIds.length > 0) {
        this.getBookIds(bookIds)
      }
    }
  }
  // 应用上下文：存储当前组件的上下文信息
  // 通过getContext(this)获取，用于权限申请等需要上下文的操作
  private appContext: common.Context = getContext(this);
  // 权限管理器：用于申请和管理应用权限
  // 通过abilityAccessCtrl.createAtManager()创建，主要用于申请保存图片的存储权限
  private atManager = abilityAccessCtrl.createAtManager();
  
  // getBookIds方法：根据书籍ID数组从数据库加载书籍详情
  // 参数：ids - 书籍ID数组，从书单中提取
  // 功能：异步调用BooksDao.getBookByIds查询数据库，将结果赋值给bookList状态变量
  // 当bookList更新时，UI会自动重新渲染显示书籍信息
  getBookIds(ids:number[]){
    BooksDao.getBookByIds(ids).then((val)=>{
      this.bookList = val
    })
  }

  // build方法：ArkUI组件的核心构建方法，定义组件的UI结构和布局
  // 返回值为组件树，系统会根据此方法构建用户界面
  // 整体布局：使用Stack布局实现三层叠加结构
  // 1. 底层：黑色半透明遮罩层（点击关闭对话框）
  // 2. 中层：书单内容展示区域（白色背景）
  // 3. 顶层：分享操作区域（底部操作栏）
  build() {
    // Stack布局：允许子组件叠加显示，通过zIndex控制层级
    Stack() {
      // 第一层：背景遮罩层
      // 黑色半透明矩形，覆盖整个对话框，点击时关闭对话框
      Rect()
        .height('100%')
        .width('100%')
        .backgroundColor(Color.Black)
        .onClick(() => {
          this.controller?.close()  // 点击遮罩层关闭对话框
        })
        .opacity(0.15)  // 15%不透明度，实现半透明效果
        .zIndex(1)  // 层级1，最底层
      
      // 第二层：书单内容展示区域
      // 白色背景卡片，显示书单名称、描述和书籍列表
      Flex({
        direction:FlexDirection.Column,  // 垂直方向布局
        justifyContent:FlexAlign.SpaceBetween  // 子组件在垂直方向两端对齐
      }){
        Column({
          space:PaddingConstants.PADDING_10  // 子组件间距10
        }){
          // 书单名称：居中显示，16号字体，中等字重
          Text(this.works.worksName)
            .textAlign(TextAlign.Center)
            .fontSize(16).fontWeight(500).lineHeight(24).fontColor($r('app.string.color_black_88'))
          // 书单描述：居中显示，12号字体，常规字重
          Text(this.works.worksDescribe)
            .textAlign(TextAlign.Center)
            .fontSize(12).fontWeight(400).lineHeight(20).fontColor($r('app.string.color_black_88'))
          // 书籍列表：使用ForEach遍历bookList，为每本书调用BookShelfInfo构建器
          Column({
            space:PaddingConstants.PADDING_15  // 书籍项间距15
          }){
            ForEach(this.bookList,(item:Books,index)=>{
              this.BookShelfInfo(item,index)
            })
          }
        }
        .alignItems(HorizontalAlign.Start)  // 子组件左对齐
      }
      .margin(40)  // 外边距40，使内容区域不贴边
      .padding({ top: 24, left: 20, right: 20, bottom: 24 })  // 内边距
      .backgroundColor(Color.White)  // 白色背景
      .zIndex(2)  // 层级2，中间层
      
      // 第三层：用于图片保存的隐藏内容区域
      // 此区域在UI中不可见（Visibility.Hidden），专门用于生成分享图片
      // 包含书单信息、最多4本书籍和底部推广信息
      Column(){
        Column({
          space:10
        }){
          Text(this.works.worksName)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontWeight(500)
            .lineHeight(24)
            .fontColor($r('app.string.color_black_88'))
          Text(this.works.worksDescribe)
            .textAlign(TextAlign.Center)
            .fontSize(12)
            .fontWeight(400)
            .lineHeight(20)
            .fontColor($r('app.string.color_black_88'))

          Column({
            space:PaddingConstants.PADDING_15
          }){
            // 只显示前4本书籍，避免分享图片过长
            ForEach(this.bookList.slice(0, 4),(item:Books,index)=>{
              this.BookShelfInfo(item,index)
            })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 24, left: 20, right: 20, bottom: 24 })
        .backgroundColor('#FFF7EC')  // 浅黄色背景，用于分享图片
        this.footerSaveImage()  // 底部推广信息（二维码等）
      }
      .id('shareBook')  // 设置ID，用于componentSnapshot截图
      .margin(40)
      .position({y: 0})  // 定位到顶部
      .visibility(Visibility.Hidden)  // 隐藏，不显示在UI中

      // 第四层：底部分享操作区域
      // 白色背景，圆角顶部，包含分享按钮和链接有效期设置
      Column() {
        // 顶部拖拽指示器：灰色横条，提示用户可上下拖拽
        Column() {
          Row().width(36).height(4).backgroundColor($r('app.string.color_black_15')).borderRadius(12)
        }
        .padding({ top: 12, bottom: 28 })

        Flex({
          direction: FlexDirection.Row, wrap: FlexWrap.Wrap,
          justifyContent: FlexAlign.Start
        }) {

        }
        // 分享按钮区域：使用GridRow实现4列网格布局
        // 每个网格单元格包含一个分享按钮（InsideCircleIcon组件）
        GridRow({
          columns:4  // 4列网格
        }){
          ForEach(this.buttonListInfo, (item: buttonList) => {
            GridCol(){
              InsideCircleIcon({
                icon: item.icon,
                title:item.title
              }).onClick(() => {
                // 根据按钮ID执行不同的分享操作
                switch (item.id) {
                  case 1:
                    showMessage('跳转微信');
                    break;
                  case 2:
                    showMessage('跳转QQ');
                    break;
                  case 3:
                    showMessage('跳转朋友圈');
                    break;
                  case 4:
                    showMessage('跳转QQ空间');
                    break;
                  case 5:
                    showMessage('导出本地成功');
                    break;
                  case 6:
                    showMessage('已复制链接');
                    break;
                  case 7:
                    this.requestPermissionSaveImage();  // 保存图片功能
                    break;
                  case 8:
                    showMessage('系统分享');
                    break;
                }
              })
            }
          })
        }

        // 链接有效期设置区域
        Column() {
          this.footerTitle()  // 调用footerTitle构建器显示有效期设置
        }
        .borderRadius(8)
        .margin({ left: 20, right: 20, bottom: 20 })
        .backgroundColor($r('app.color.share_shelf_book_background'))
      }
      .zIndex(3)  // 层级3，最顶层
      .borderRadius({ topLeft: 20, topRight: 20 })  // 顶部圆角
      .backgroundColor(Color.White)
    }
    .align(Alignment.Bottom)  // Stack整体底部对齐，实现从底部弹出的对话框效果
  }
  // 像素图状态变量：存储组件截图生成的像素图
  // 类型为image.PixelMap | undefined，初始为undefined
  // 当执行保存图片操作时，componentSnapshot.get()会生成像素图并存储在此变量中
  @State pixmap: image.PixelMap | undefined = undefined
  
  // requestPermissionSaveImage方法：申请权限并保存图片到相册
  // 异步方法，处理完整的图片保存流程：
  // 1. 申请WRITE_IMAGEVIDEO权限（写入媒体文件权限）
  // 2. 使用componentSnapshot对id为'shareBook'的组件进行截图
  // 3. 将像素图编码为JPEG格式的二进制数据
  // 4. 创建相册资源并写入文件
  // 5. 显示保存成功或失败的消息提示
  async requestPermissionSaveImage() {
    try {
      // 第一步：申请存储权限
      this.atManager.requestPermissionsFromUser(this.appContext,['ohos.permission.WRITE_IMAGEVIDEO']).then(async ()=>{
        // 第二步：对隐藏的分享内容区域进行截图
        // componentSnapshot.get('shareBook')：获取id为'shareBook'的组件的像素图
        componentSnapshot.get('shareBook').then((pixmap: image.PixelMap)=>{
          this.pixmap = pixmap  // 存储像素图到状态变量
          
          // 第三步：创建图像打包器，将像素图编码为JPEG格式
          const imagePackerApi = image.createImagePacker();
          let packOpts : image.PackingOption = { format:"image/jpeg", quality:98 };  // JPEG格式，质量98%

          // 第四步：编码像素图为二进制数据
          imagePackerApi.packing(pixmap, packOpts).then(async (data : ArrayBuffer) => {
            // 第五步：获取应用上下文和相册访问助手
            let context = getContext();
            let helper = photoAccessHelper.getPhotoAccessHelper(context);
            
            // 第六步：在相册中创建新的图片资源
            let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
            
            // 第七步：打开文件并写入编码后的图片数据
            let file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
            await fs.write(file.fd, data);
            await fs.close(file.fd);
            
            // 第八步：显示保存成功提示
            showMessage('保存成功');
          }).catch((error : BusinessError) => {
            // 图片编码或保存失败处理
            showMessage('保存失败,未获取权限');
            console.error('Failed to pack the image. And the error is: ' + error);
          })
        });
      })
    } catch (e) {
      // 异常处理：权限申请失败或其他异常
      showMessage('保存失败,未获取权限');
    }
  }

  // 链接有效期状态变量：存储当前选择的链接有效期
  // 默认值为'7天有效'，用户可选择'永久有效'
  // 当值变化时，UI会自动更新显示
  @State validDate:string = '7天有效'
  
  // 底部对话框显示状态：控制链接有效期选择对话框的显示/隐藏
  // true：显示选择对话框，false：隐藏选择对话框
  @State footerDialogShow:boolean = false
  
  // footerTitle构建器：构建链接有效期设置区域
  // @Builder装饰器声明这是一个UI构建器方法，可在build方法中调用
  // 功能：显示当前有效期设置，点击后弹出选择对话框
  @Builder footerTitle(){
    Flex({
      direction:FlexDirection.Row,  // 水平方向布局
      justifyContent:FlexAlign.SpaceBetween  // 两端对齐
    }){
      // 左侧：标题文本
      Text('链接有效期').fontColor($r('app.string.color_black_88')).fontSize(12).fontWeight(400).lineHeight(20).textAlign(TextAlign.Center)
      // 右侧：当前有效期值和右箭头图标
      Row({
        space:8  // 子组件间距8
      }){
        Text(this.validDate).fontColor($r('app.string.color_black_45')).fontSize(12).fontWeight(400)
        Image($r('app.media.icon_right')).width(24).height(24).fillColor(($r('app.string.color_black_45')))
      }
    }
    .onClick(()=>{
      this.footerDialogShow = true  // 点击显示选择对话框
    })
    // 绑定底部弹出对话框（bindSheet）
    // 当footerDialogShow为true时，显示footerDialog构建的内容
    .bindSheet($$this.footerDialogShow,this.footerDialog(), {
      height:200,  // 对话框高度200
      showClose: false,  // 不显示关闭按钮
      blurStyle:BlurStyle.COMPONENT_ULTRA_THIN,  // 超薄模糊效果
      maskColor: 'rgba(0,0,0,0.6)',  // 遮罩颜色，60%黑色
      onDisappear:()=>{  // 对话框消失时的回调
        this.footerDialogShow = false
      }
    })
    .padding(16)  // 内边距16
  }

  // footerSaveImage构建器：构建分享图片的底部推广信息区域
  // 用于隐藏的分享内容区域（id='shareBook'）的底部
  // 包含应用Logo、名称、推广文案和二维码
  @Builder footerSaveImage(){
    Flex({
      justifyContent:FlexAlign.SpaceBetween,  // 两端对齐
      direction:FlexDirection.Row,  // 水平方向布局
      alignItems:ItemAlign.Center  // 垂直居中对齐
    }
    ){
      // 左侧：应用Logo和推广文案
      Column(){
        Row({
          space:5  // Logo之间的间距
        }){
          Image($r('app.media.legado_icon')).width(32).height(20)  // 应用图标
          Image($r('app.media.legado')).width(65).height(15)  // 应用名称Logo
        }
        Text('扫描二维码下载 开源阅读').fontSize(10).fontWeight(400).lineHeight(18).textAlign(TextAlign.Center)
      }
      // 右侧：二维码图片
      Image($r('app.media.QR_Code')).width(46).height(46)
    }
    .backgroundColor(Color.White)  // 白色背景
    .padding({ top: 24,bottom:24, left: 20, right: 20 })  // 内边距
  }


  // footerDialog构建器：构建链接有效期选择对话框
  // 通过bindSheet弹出，提供"7天"和"永久有效"两个选项
  @Builder footerDialog(){
    // 对话框标题
    Column(){
      Text('链接有效日期')
        .fontColor($r('app.string.color_black_88'))
        .textAlign(TextAlign.Center)
        .padding({top:12,bottom:12})
        .lineHeight(24)
        .fontWeight(500)
    }
    // 选项区域
    Column(){
      // 选项1：7天有效期
      Flex({
        justifyContent:FlexAlign.SpaceBetween,  // 两端对齐
        alignItems:ItemAlign.Center  // 垂直居中对齐
      }
      ){
        Text('7天')
          .fontColor($r('app.string.color_black_88'))
          .textAlign(TextAlign.Center)
          .padding({top:12,bottom:12})
          .lineHeight(24)
          .fontWeight(500)

        // 勾选图标：当validDate为'7天有效'时显示勾选图标
        Image(this.validDate === '7天有效'?$r('app.media.hook'):'').width(24).height(24)
      }
      .onClick(()=>{
        this.validDate = '7天有效'  // 设置有效期
        this.footerDialogShow = false  // 关闭对话框
        showMessage('修改成功')  // 显示成功提示
      })
      // 选项2：永久有效
      Flex({
        justifyContent:FlexAlign.SpaceBetween,
        alignItems:ItemAlign.Center
      }
      ){
        Text('永久有效')
          .fontColor($r('app.string.color_black_88'))
          .textAlign(TextAlign.Center)
          .padding({top:12,bottom:12})
          .lineHeight(24)
          .fontWeight(500)
        // 勾选图标：当validDate为'永久有效'时显示勾选图标
        Image(this.validDate === '永久有效'?$r('app.media.hook'):'').width(24).height(24)
      }
      .onClick(()=>{
        this.validDate = '永久有效'  // 设置有效期
        this.footerDialogShow = false  // 关闭对话框
        showMessage('修改成功')  // 显示成功提示
      })
    }.padding({left:20,right:20})  // 选项区域内边距

    // 取消按钮
    Column(){
      Text('取消').fontSize($r('app.string.color_black_88')).textAlign(TextAlign.Center).fontSize(16).fontWeight(400).lineHeight(24)
    }.padding({left:32,right:32,top:16,bottom:16})
    .onClick(()=>{
      this.footerDialogShow = false  // 点击取消关闭对话框
    })

  }

  // BookShelfInfo构建器：构建单本书籍的信息展示卡片
  // 参数：
  //   book - 书籍数据对象，包含封面、名称、简介等信息
  //   index - 书籍在书单中的索引，用于获取对应的推荐语
  // 功能：显示书籍封面、名称、简介、标签和推荐语（如果有）
  @Builder BookShelfInfo(book:Books,index:number){
    Column(){
      // 第一行：书籍封面和基本信息
      Row({
        space:PaddingConstants.PADDING_10  // 封面和文字间距10
      }){
        // 书籍封面图片
        Image(book.coverUrl)
          .draggable(false)  // 禁止拖拽
          .alt($r('app.media.icon_book_default_cover_one'))  // 加载失败时的默认图片
          .width(69)  // 固定宽度
          .height(92)  // 固定高度

        // 书籍文字信息区域
        Column({
          space:10  // 文字行间距10
        }) {
          // 书籍名称：16号字体，中等字重，最多显示2行，超出部分显示省略号
          Text(book.bookName).fontSize(16).fontWeight(500).lineHeight(24)
            .textOverflow({
              overflow:TextOverflow.Ellipsis  // 文本溢出显示省略号
            })
            .ellipsisMode(EllipsisMode.END)  // 省略号在末尾
            .maxLines(2)  // 最多2行
            .position({y: 0})  // 垂直位置调整
          // 书籍简介：12号字体，灰色文字，最多显示2行，固定高度50
          Text(book.intro)
            .fontSize(12)
            .lineHeight(20)
            .fontColor('rgba(0, 0, 0, 0.45)')  // 45%黑色，浅灰色
            .textOverflow({
              overflow:TextOverflow.Ellipsis
            })
            .height(50)  // 固定高度，确保布局稳定
            .ellipsisMode(EllipsisMode.END)
            .maxLines(2)
          // 书籍标签：作者、分类、状态、字数等信息
          // 注意：此处使用了硬编码的示例数据，实际应从书籍数据中获取
          Row(){
            Text('卖报小郎君·').fontSize(10).fontWeight(400).fontColor($r('app.string.color_black_45'))
            Text('玄幻·').fontSize(10).fontWeight(400).fontColor($r('app.string.color_black_45'))
            Text('完本·').fontSize(10).fontWeight(400).fontColor($r('app.string.color_black_45'))
            Text('380万字').fontSize(10).fontWeight(400).fontColor($r('app.string.color_black_45'))
          }
        }
      }

      // 第二行：推荐语（如果书单中有该书籍的推荐语）
      // 检查当前书籍在书单中是否有推荐语
      if (this.works.worksBookList && this.works.worksBookList[index].recommend){
        Column(){
          // 显示推荐语，使用空值合并运算符提供默认值
          Text(this.works.worksBookList[index].recommend ?? '')
            .padding({
              top:PaddingConstants.PADDING_8,
              bottom:PaddingConstants.PADDING_8,
              left:PaddingConstants.PADDING_12,
              right:PaddingConstants.PADDING_12
            })
        }
        .borderRadius(8)  // 圆角边框
        .margin({
          top:PaddingConstants.PADDING_16  // 顶部间距16
        })
        .alignItems(HorizontalAlign.Start)  // 左对齐
        .width('100%')  // 宽度100%
        .backgroundColor($r('app.string.color_black_4'))  // 浅灰色背景，4%黑色
      }
    }
    .alignItems(HorizontalAlign.Start)  // 整体左对齐
    .width('100%')  // 宽度100%
  }
}
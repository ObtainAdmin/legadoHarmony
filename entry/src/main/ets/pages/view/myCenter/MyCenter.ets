// ============ 导入模块 ============
import { Attribute } from '../../../common/utils/Attribute' // 属性工具类
import router from '@ohos.router' // 系统路由 API（注意：不是@kit.ArkUI）
import { WebdavService } from '../../../componets/webDavService/WebdavService' // WebDAV 服务组件
import { promptAction } from '@kit.ArkUI' // UI 提示操作
import { dataItem } from '../../../componets/dataList/dataItem' // 列表项数据模型
import { PublicConstants, TextConstants } from '../../../common/constants/PublicConstants' // 公共常量
import { ColumnModifier } from '../../../common/utils/ComponetModifier' // 列修饰器工具类
import { ThemeStorageKey } from '../../../common/constants/Theme' // 主题存储键常量
import { ThemeItem } from '../../../common/model/Theme' // 主题类型定义
import { image } from '@kit.ImageKit' // 图像处理库
import { resourceManager } from '@kit.LocalizationKit' // 本地化资源管理器
import { BusinessError } from '@kit.BasicServicesKit' // 业务错误类型

/**
 * @Entry - 页面入口装饰器
 * @Component - 组件装饰器
 * @struct MyCenter - 个人中心主页面组件类
 * 
 * 功能说明：
 *   - 展示用户头像、昵称、阅读时长等个人信息
 *   - 统计面板：读过/读完/书签/勋章数量
 *   - 快捷功能区：云盘、主题、书源、净化
 *   - WebDAV 服务状态显示
 *   - 底部功能列表：帮助中心、关于我们、清理缓存、我的设置
 */
@Entry
@Component
export default struct MyCenter {
  
  // ============ 状态变量 ============
  
  /** @State reading_time: number = 0
   * 今日阅读时长（分钟），从本地存储读取
   */
  @State reading_time: number = 0
  
  // ========== 顶部统计数据列表 ==========
  /**
   * head_list - 顶部统计数据项
   * 每项数据结构：[标题，数值]
   */
  @State head_list: dataItem[] = [
    new dataItem("读过", 20),
    new dataItem("读完", 20),
    new dataItem("书签", 20),
    new dataItem("勋章", 20),
  ]
  
  // ========== 中间快捷功能区 ============
  /**
   * center_list - 中间四格功能区
   * 每项数据结构：[标题，索引，图标资源]
   */
  @State center_list: dataItem[] = [
    new dataItem("备份", 1, $r("app.media.my_center_cloud_icon")), // 云备份
    new dataItem("主题", 2, $r("app.media.my_center_book_icon")), // 主题管理
    new dataItem("书源", 3, $r("app.media.my_center_theme_icon")), // 书源管理
    new dataItem("净化", 4, $r("app.media.my_center_purify_icon")), // 净化规则
  ]
  
  // ========== 底部功能列表 ==========
  /**
   * end_list - 底部帮助相关功能
   * 每项数据结构：[标题，索引，图标资源]
   */
  @State end_list: dataItem[] = [
    new dataItem("帮助中心", 1, $r("app.media.my_center_help_icon")),
    new dataItem("关于我们", 2, $r("app.media.my_center_about_icon")),
    new dataItem("清理缓存", 3, $r("app.media.my_center_clean_icon")),
    new dataItem("文件管理", 4, $r("app.media.my_center_file_icon")),
  ]
  
  // ============ 安全区域适配 ============
  
  /** @StorageLink('topRectHeight') topRectHeight: number = 0
   * 顶部安全区域高度
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  // ColumnModifier 自定义设置
  Column = new ColumnModifier()

  // ============ 主题颜色绑定 ============
  
  /** @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
   * 响应式主题颜色绑定（全局共享）
   * 用于渐变背景等动态配色
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  // ============ UI 构建方法 - build() ============
  
  /**
   * build() - 页面 UI 构建入口
   * 
   * 布局层次：
   * Column (渐变背景容器)
   * ├─ Row (右上角模式切换区：设置图标 + 夜间模式图标)
   * ├─ Scroll (可滚动内容区)
   * │  ├─ Row (用户信息：头像 + 昵称 + 云盘登录按钮)
   * │  ├─ Blank (间距)
   * │  ├─ Row (统计数据：读过/读完/书签/勋章)
   * │  ├─ Blank (间距)
   * │  ├─ Row (快捷功能四格)
   * │  ├─ Blank (间距)
   * │  ├─ WebdavService (WebDAV 服务组件)
   * │  ├─ Blank (间距)
   * │  └─ Column (底部功能列表)
   */
  build() {
    Column() {
      // ========== 右上角模式图标区 ==========
      Row({ space: 10 }) { // 左右间距 10
        // ========== 设置图标 ==========
        Image($r("app.media.my_center_set_icon"))
          .size({ width: 30, height: 30 })
          .interpolation(ImageInterpolation.Medium) // 图片插值算法
          .onClick(() => {
            this.toMySetPage() // 跳转到设置页
          })
        
        // ========== 夜间模式图标 ==========
        Image($r("app.media.night_icon")).size({ width: 30, height: 30 }).interpolation(ImageInterpolation.Medium)
      }.justifyContent(FlexAlign.End).width("100%").onClick(this.night_onclick) // 右对齐 + 点击事件

      // ========== 可滚动内容区 ==========
      Scroll() {
        Column() {
          
          // ========== 用户信息区域 ==========
          Row() {
            // 头像图片
            Image($r("app.media.user_avatar")).size({ width: 54, height: 54 })
              .borderRadius(60) // 圆形头像
              .interpolation(ImageInterpolation.Medium) // 插值算法
              .onClick(this.avatar_onclick) // 点击头像事件

            //昵称及阅读时长
            Column({ space: 8 }) {

              // 昵称文本
              Text("夏目友人").fontSize(16).fontWeight(600).lineHeight(24)
              
              // 今日阅读时长文本
              Text("今日阅读" + this.reading_time + "分钟").fontSize(12).fontColor(TextConstants.TEXT_FONT_COLOR)
                .lineHeight(20)
            }
            .alignItems(HorizontalAlign.Start) // 左对齐
            .width("45%") // 占 45% 宽度
            .height("100%")
            .layoutWeight(1) // 占据弹性空间
            
            .justifyContent(FlexAlign.SpaceBetween) // 纵向两端对齐

            // ===== 右侧云盘登录按钮 =====
            Row() {
              Text("云盘登录")
                .fontColor(TextConstants.TEXT_FONT_COLOR) // 使用文本常量色
                .fontSize(12)
                .width(48)
                .height(22)
            }.onClick(() => {
              this.cloudDisk_onclick() // 跳转云盘登录页
            })
            .border({ width: 1, color: TextConstants.TEXT_FONT_COLOR, radius: 25 }) // 圆角边框
            .padding({
              top: 4,
              left: 14,
              right: 14,
              bottom: 4
            })
            .borderWidth(1) // 边框宽度
          }.justifyContent(FlexAlign.SpaceBetween).width("100%").height(54).onClick(this.night_onclick)

          Blank(24) // 垂直间距 24 像素

          // ========== 统计数据行 ==========
          Row() {
            ForEach(this.head_list, (item: dataItem, index: number) => {
              Column({ space: 5 }) { // 上下间距 5
                Text(item.value.toString()).fontSize(20).fontWeight(600) // 大字号数字
                Text(item.title).fontSize(10).fontWeight(500) // 小字号标题
              }.onClick(() => {
                this.head_onclick(index) // 点击跳转到对应统计页
              })
            })
          }.justifyContent(FlexAlign.SpaceBetween).width("100%").padding({ left: 20, right: 20 })

          Blank(16) // 垂直间距 16 像素

          // ========== 快捷功能区（云盘/书源/主题/净化）==========
          Row() {
            ForEach(this.center_list, (item: dataItem) => {
              Column({ space: 4 }) {
                Image(item.icon).size({ width: 24, height: 24 }) // 图标
                Text(item.title).fontSize(12) // 标题文字
              }
              .width(80) // 固定宽度
              .height(48) // 固定高度
              .justifyContent(FlexAlign.Center) // 内容居中
              .onClick(() => this.centerOnclick(item.value)) // 点击事件
            })
          }
          .width("100%")
          .justifyContent(FlexAlign.SpaceBetween) // 均匀分布
          .padding({ top: 16, bottom: 16 }) // 上下内边距
          .backgroundColor(PublicConstants.THEME_COLOR_WHITE) // 白色背景
          .borderRadius(10) // 圆角 10

          Blank(16) // 垂直间距 16 像素

          // ========== WebDAV 服务组件 ==========
          WebdavService()
          
          Blank(16) // 垂直间距 16 像素

          // ========== 底部功能列表（帮助中心/关于/清理缓存/设置）==========
          Column() {
            Scroll() {
              Column() {
                ForEach(this.end_list, (item: dataItem) => {
                  Row({ space: 10 }) { // 水平间距 10
                    Image(item.icon).size({ width: 20, height: 20 }).interpolation(ImageInterpolation.High) // 图标
                    Text(item.title).fontSize(14).width("75%").layoutWeight(1) // 标题占 75%
                    Image($r("app.media.right")).size({ width: 24, height: 24 }) // 右箭头
                  }
                  .width("100%")
                  .height(45) // 固定高度
                  .justifyContent(FlexAlign.SpaceBetween) // 两端对齐
                  .padding({
                    top: 12,
                    bottom: 12,
                    left: 20,
                    right: 20
                  })
                  .onClick(() => this.endOnclick(item.value)) // 点击跳转
                })
              }
            }
            .scrollBar(BarState.Off) // 隐藏滚动条
          }
          .padding({ top: 5, bottom: 5 }) // 上下内边距
          .backgroundColor(PublicConstants.THEME_COLOR_WHITE) // 白色背景
          .borderRadius(10) // 圆角 10
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      .height('100%')
      .scrollBar(BarState.Off) // 隐藏滚动条
      .padding({ bottom: 10 }) // 底部内边距
      
    }
    .attributeModifier(this.Column) // 应用自定义修饰器
    
    // ========== 渐变背景 ==========
    .linearGradient({
      direction: GradientDirection.Bottom, // 渐变方向：从上到下
      colors: [[this.theme.mainColor, 0.0], [this.theme.secondColor, 0.2]] // 数组末尾元素占比小于 1 时满足重复着色效果
      // mainColor 在 0% 位置，secondColor 从 20% 开始重复
    })
    .height('100%')
  }

  // ============ 事件处理方法 ============
  
  /**
   * night_onclick - 夜间模式切换事件
   * TODO: 待实现夜间模式切换逻辑
   */
  night_onclick() {
    
  }

  /**
   * avatar_onclick - 头像点击事件
   * TODO: 待实现编辑头像或进入个人中心详情
   */
  avatar_onclick() {
    
  }

  /**
   * head_onclick - 统计数据项点击事件
   * 
   * @param value - 点击项的索引
   *   case 0-2: 读过/读完/书签 -> 跳转到 readStatistics 页面
   *   case 3: 勋章 -> 特殊处理
   */
  head_onclick(value: number) {
    console.log("点击了" + value)
    if (value == 3) {
      // 勋章详情页（待实现）
    } else {
      router.pushUrl({
        url: "pages/view/myCenter/readStatistics",
        params: {
          value: value // 传递当前项的索引
        }
      })
    }
  }

  /**
   * centerOnclick - 快捷功能区点击事件
   * 
   * @param value - 点击项的 value 值
   *   case 1: 备份 -> cloudDisk
   *   case 2: 主题 -> MyThemeConfig
   *   case 3: 书源 -> 待实现
   *   case 4: 净化 -> 待实现
   */
  centerOnclick(value: number | string) {
    switch (value) {
      case 1:
        // promptAction.showToast({
        //   message: '请点击右上角，完成云盘登录',
        //   duration: 1000,
        // })
        router.pushUrl({
          url: 'pages/view/myCenter/cloudDisk'
        })
        break
    // 点击主题
      case 2:
        router.pushUrl({
          url: '/pages/view/myCenter/MyThemeConfig'.slice(1) // 去掉开头的斜杠
        })
        break
      case 3:
        // TODO: 跳转到书源管理页
        break
      case 4:
        // TODO: 跳转到净化规则页
        break
    }
  }

  /**
   * endOnclick - 底部功能列表点击事件
   * 
   * @param value - 点击项的 value 值
   *   case 1: 帮助中心 -> helpCenterPage
   *   case 2: 关于我们 -> aboutUs/aboutUsPage
   *   case 3: 清理缓存 -> clearCache
   *   case 4: 我的设置 -> MySetPage
   */
  endOnclick(value: number | string) {
    switch (value) {
      case 1:
        // 帮助中心
        router.pushUrl({
          url: 'pages/view/myCenter/helpCenterPage'
        })
        break;
      case 2:
        // 关于我们
        router.pushUrl({
          url: 'pages/view/myCenter/aboutUs/aboutUsPage'
        })
        break;
      case 3:
        // 清理缓存
        router.pushUrl({
          url: 'pages/view/myCenter/clearCache'
        })
        break;
      case 4:
        // TODO: 跳转到我的设置页
    }
  }

  /**
   * toMySetPage - 跳转到我的设置页
   * 通过点击右上角设置图标触发
   */
  toMySetPage() {
    router.pushUrl({
      url: 'pages/view/myCenter/MySetPage'
    })
  }

  /**
   * cloudDisk_onclick - 跳转云盘登录
   * 通过点击"云盘登录"按钮触发
   */
  cloudDisk_onclick() {
    router.pushUrl({
      url: 'pages/view/myCenter/WebDav'
    })
  }
}

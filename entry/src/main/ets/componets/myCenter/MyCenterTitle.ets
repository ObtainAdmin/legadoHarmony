/**
 * MyCenterTitle 组件 - 我的中心页面标题栏
 * 
 * 功能概述：
 * 1. 提供统一的我的中心页面标题栏布局，包含返回按钮、标题文本和可选的操作按钮
 * 2. 支持编辑模式显示编辑图标，用于修改标题
 * 3. 支持更多菜单模式显示下拉菜单，提供排序选项和退出登录功能
 * 4. 适配系统状态栏高度，确保标题栏正确显示
 * 5. 支持主题切换，根据当前主题显示相应的颜色
 * 
 * 设计特点：
 * 1. 响应式布局：自动适配不同设备的屏幕宽度和状态栏高度
 * 2. 模块化设计：通过属性控制不同功能的显示/隐藏
 * 3. 主题集成：使用主题管理系统实现颜色一致性
 * 4. 交互友好：提供清晰的视觉反馈和操作指引
 * 
 * 使用场景：
 * 1. 我的中心页面顶部标题栏
 * 2. 需要标题编辑功能的页面
 * 3. 需要下拉菜单操作的页面
 * 
 * 组件结构：
 * - 返回按钮：点击返回上一页
 * - 标题区域：居中显示页面标题，支持编辑模式
 * - 操作区域：右侧显示更多菜单或占位空间
 * - 下拉菜单：提供排序选项和退出登录功能
 * 
 * 注意事项：
 * 1. 需要确保主题数据正确初始化
 * 2. 状态栏高度需要正确同步
 * 3. 菜单功能目前不支持自定义形状
 */

import { router } from '@kit.ArkUI'
import CommonConstants from '../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'

@Component
export struct MyCenterTitle{

  /**
   * 页面标题文本
   * @type {string}
   * @required 是
   * @description 显示在标题栏中央的文本内容
   */
  @Prop title:string

  /**
   * 是否显示编辑按钮
   * @type {boolean}
   * @default false
   * @description 为true时在标题右侧显示编辑图标，点击可触发编辑事件
   */
  isShowEdit?:boolean = false
  
  /**
   * 是否显示更多菜单
   * @type {boolean}
   * @default false
   * @description 为true时在标题栏右侧显示更多菜单图标
   */
  isShowMore?:boolean = false

  /**
   * 编辑标题按钮点击事件
   * @type {function}
   * @param {ClickEvent} event - 点击事件对象
   * @description 点击编辑图标时触发的事件回调
   */
  onEditClickEvent?: (event: ClickEvent) => void
  
  /**
   * 当前选中的菜单项索引
   * @type {number}
   * @default 0
   * @description 用于跟踪下拉菜单中当前选中的排序选项
   * @storage 使用StorageLink持久化存储，确保状态在页面间保持一致
   */
  @StorageLink("onSelect") onSelect: number = 0

  /**
   * 状态栏高度
   * @type {number}
   * @default 0
   * @description 系统状态栏的高度，用于适配不同设备的标题栏位置
   * @storage 使用StorageProp持久化存储
   */
  @StorageProp('topRectHeight') topRectHeight: number = 0

  /**
   * 当前主题配置
   * @type {ThemeItem}
   * @description 应用的主题配置对象，包含颜色、字体等样式信息
   * @storage 使用StorageProp从主题存储键中获取
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建标题栏的主要UI结构，包含状态栏适配、返回按钮、标题区域和操作区域
   */
  build() {
    Column(){
      /**
       * 状态栏占位空白
       * @description 根据系统状态栏高度动态调整，如果高度为0则使用默认值40
       * 确保标题栏内容不被状态栏遮挡
       */
      Blank(this.topRectHeight == 0 ? 40 : this.topRectHeight)

      Row(){
        /**
         * 返回按钮
         * @description 点击返回上一页面，使用标准返回图标
         * 尺寸通过CommonConstants.TITLE_IMG_SIZE常量控制
         */
        Image($r("app.media.return_left"))
          .size({width:CommonConstants.TITLE_IMG_SIZE,height:CommonConstants.TITLE_IMG_SIZE})
          .onClick(()=>{
            router.back() // 调用路由返回功能
          })

        Row(){
          /**
           * 标题区域容器
           * @description 包含标题文本和可选的编辑图标，使用弹性布局确保居中显示
           */
          Row(){
            /**
             * 编辑模式左侧占位
             * @description 当显示编辑按钮时，左侧添加占位空白以平衡布局
             * 确保标题在编辑模式下仍然保持视觉居中
             */
            if (this.isShowEdit){
              Blank(CommonConstants.TITLE_IMG_SIZE)
                .margin({right: 8})
            }

            /**
             * 标题文本
             * @description 显示页面标题，使用加粗字体和居中对齐
             * 字体大小16px，行高24px，确保良好的可读性
             */
            Text(this.title).fontSize(16).fontWeight(600).lineHeight(24)
              .textAlign(TextAlign.Center)

            /**
             * 编辑图标
             * @description 仅在编辑模式下显示，点击触发编辑事件
             * 使用16x16尺寸的编辑图标，左侧8px边距
             */
            if (this.isShowEdit){
              Image($r("app.media.ic_public_edit"))
                .size({width: 16,height: 16})
                .margin({left: 8})
                .onClick(this.onEditClickEvent)
            }
          }
        }
        .justifyContent(FlexAlign.Center) // 水平居中
        .layoutWeight(1) // 占满剩余空间，确保标题居中

        /**
         * 右侧操作区域
         * @description 根据配置显示更多菜单图标或占位空白
         * 使用占位空白确保标题在无操作按钮时仍然居中
         */
        if (this.isShowMore){
          /**
           * 更多菜单图标
           * @description 显示垂直三点菜单图标，绑定下拉菜单
           * 点击弹出排序选项和退出登录功能
           */
          Image($r("app.media.more_vertical"))
            .size({width:CommonConstants.TITLE_IMG_SIZE,height:CommonConstants.TITLE_IMG_SIZE})
            .bindMenu(this.menu) // 绑定自定义菜单构建器
        }else { 
          /**
           * 占位空白
           * @description 当不显示更多菜单时，使用空白占位
           * 保持标题栏布局对称，确保标题居中显示
           */
          Blank(CommonConstants.TITLE_IMG_SIZE)
        }
      }
      /**
       * 标题栏容器样式
       * @description 使用100%宽度适配所有设备，垂直居中布局
       * 上下各12px内边距提供舒适的视觉间距
       * 注释掉的代码展示了之前的固定宽度实现，现已改为响应式设计
       */
      .width("100%").justifyContent(FlexAlign.Center).padding({top:12,bottom:12})
      //.width(320).justifyContent(FlexAlign.Start).padding({top:12,bottom:12}) // 旧版固定宽度实现
    }
  }

  /**
   * 菜单构建器
   * @returns {void}
   * @description 构建下拉菜单的UI结构，包含排序选项组和退出登录项
   * 使用圆角12px的菜单容器，提供良好的视觉体验
   * 
   * 菜单结构：
   * 1. 排序选项组（MenuItemGroup）
   *    - 按时间排序
   *    - 按名称排序
   *    - 按大小排序
   * 2. 退出登录项（单独MenuItem）
   * 
   * 注意事项：
   * - 目前菜单不支持自定义形状（如三角形指示器）
   * - 使用radius(12)提供圆角效果
   */
  @Builder menu(){
    Column(){
      // TODO: 菜单现在不支持自定义形状，未来可添加三角形指示器
      // Image($r("app.media.ic_menu_triangle"))
      //   .width(18)
      //   .height(8)
      
      Menu() {
        /**
         * 排序选项组
         * @description 包含三种排序方式的菜单项
         * 使用MenuItemGroup将相关功能分组显示
         */
        MenuItemGroup() {
          MenuItem(this.menuItemUi("按时间排序", 0))
          MenuItem(this.menuItemUi("按名称排序", 1))
          MenuItem(this.menuItemUi("按大小排序", 2))
        }
        
        /**
         * 退出登录项
         * @description 单独的菜单项，使用红色文字强调操作风险
         */
        MenuItem(this.logout())
      }
      .radius(12) // 菜单圆角
    }
  }

  /**
   * 菜单项UI构建器
   * @param {string} text - 菜单项显示文本
   * @param {number} index - 菜单项索引，用于判断是否选中
   * @returns {void}
   * @description 构建单个菜单项的UI，包含文本和选中状态指示器
   * 
   * 设计特点：
   * 1. 选中状态使用主题主色高亮显示
   * 2. 选中项右侧显示勾选图标
   * 3. 统一的内边距和高度确保视觉一致性
   * 4. 点击事件更新选中状态
   * 
   * 布局参数：
   * - 左右内边距：20px
   * - 上下内边距：12px
   * - 固定高度：46px
   */
  @Builder menuItemUi(text: string, index: number){
    Row(){
      Row(){
        /**
         * 菜单项文本
         * @description 根据选中状态显示不同颜色
         * 选中时使用主题主色，未选中时使用黑色
         */
        Text(text)
          .font({size: 16, weight: 400})
          .fontColor(index === this.onSelect ? this.theme.mainColor : "#000000")
          .height(22)
        
        /**
         * 选中状态指示器
         * @description 选中时显示勾选图标，未选中时使用空白占位
         * 保持布局一致性，避免文本位置跳动
         */
        if (this.onSelect === index){
          Image($r("app.media.ic_select"))
            .height(20)
            .width(20)
            .margin({left: 8})
        }else {
          Blank(20)
            .margin({left: 8})
        }
      }
      .alignItems(VerticalAlign.Center) // 垂直居中
    }
    .padding({left: 20, right: 20, top: 12, bottom: 12})
    .height(46)
    .onClick(()=>{
      this.onSelect = index // 更新选中状态
    })
  }

  /**
   * 退出登录菜单项构建器
   * @returns {void}
   * @description 构建退出登录菜单项的UI，使用红色文字强调操作风险
   * 
   * 设计特点：
   * 1. 使用红色文字（#EF4444）突出显示危险操作
   * 2. 包含退出图标增强识别性
   * 3. 与其他菜单项保持一致的布局参数
   * 
   * 视觉元素：
   * - 退出图标：20x20尺寸，右侧8px边距
   * - 红色文本："退出登录"字样
   * - 统一的内边距和高度
   */
  @Builder logout(){
    Row(){
      Row(){
        Image($r("app.media.ic_logout"))
          .height(20)
          .width(20)
          .margin({right: 8})
        Text("退出登录")
          .font({size: 16, weight: 400})
          .fontColor("#EF4444") // 使用红色强调危险操作
          .height(22)
      }
      .alignItems(VerticalAlign.Center)
    }
    .padding({left: 20, right: 20, top: 12, bottom: 12})
    .height(46)
  }
}
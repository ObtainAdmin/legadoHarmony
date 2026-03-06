/**
 * @file groupTypeSearchPanel.ets
 * @description 分组类型搜索面板组件
 * 
 * 功能概述：
 * 1. 显示搜索相关的分组列表（显示分组和隐藏分组）
 * 2. 支持分组详情弹窗显示
 * 3. 排除特定分组（groupId为1和5）
 * 4. 支持搜索结果的回调处理
 * 
 * 使用场景：
 * - 搜索页面中的分组选择面板
 * - 分组筛选页面
 * - 需要排除系统分组的场景
 * 
 * 设计特点：
 * - 简洁的UI设计，专注于分组选择
 * - 排除特定系统分组
 * - 支持分组详情弹窗
 * - 使用Flex布局实现网格布局
 * 
 * 组件结构：
 * 1. 头部区域：标题 + 关闭按钮
 * 2. 显示分组区域：使用GroupTypeColor/GroupType构建器显示分组
 * 3. 隐藏分组区域：显示被隐藏的分组
 * 4. 底部弹窗：分组管理弹窗
 * 
 * 技术特点：
 * - 使用@Link装饰器实现父子组件数据同步
 * - 使用@Prop装饰器接收父组件数据
 * - 使用@State装饰器管理组件内部状态
 * - 使用@StorageProp装饰器获取主题配置
 * - 使用@Builder装饰器创建可复用的UI构建器
 */

import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'
import BookGroupsDao from '../../database/dao/BookGroupsDao'
import { BookGroups } from '../../database/entities/BookGroups'
import BookManageDialog from '../../pages/view/bookShelf/components/dialog/BookManageDialog'
import { showMessage } from '../common/promptShow'

/**
 * @class groupTypeSearchPanel
 * @description 分组类型搜索面板组件
 * 
 * 组件职责：
 * 1. 管理搜索相关的分组显示
 * 2. 处理分组详情弹窗
 * 3. 排除特定系统分组
 * 4. 处理搜索回调
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct groupTypeSearchPanel{
  /** 
   * @link groupCoverShow - 分组面板显示状态
   * @description 控制分组搜索面板的显示/隐藏，与父组件双向绑定
   * @type {boolean}
   */
  @Link groupCoverShow:boolean
  
  /** 
   * @prop showGroupList - 显示分组列表
   * @description 需要显示的分组列表，从父组件传入
   * @default [] - 默认空数组
   * @type {BookGroups[]}
   */
  @Prop showGroupList:BookGroups[] = []
  
  /** 
   * @state hideList - 隐藏分组列表
   * @description 被隐藏的分组列表，从数据库查询获取
   * @type {BookGroups[]}
   */
  @State hideList:BookGroups[] = []
  
  /** 
   * @prop currentIndex - 当前索引
   * @description 当前选中的分组类型索引，从父组件传入
   * @default 0 - 默认第一个
   * @type {number}
   */
  @Prop currentIndex:number = 0
  
  /** 
   * @prop clickGroup - 点击的分组
   * @description 当前点击的分组对象，从父组件传入
   * @type {BookGroups}
   */
  @Prop clickGroup:BookGroups
  
  /** 
   * @link searchBookList - 搜索书籍列表
   * @description 搜索到的书籍ID列表，与父组件双向绑定
   * @type {number[]}
   */
  @Link searchBookList:number[]
  
  /** 
   * @storage theme - 主题颜色配置
   * @description 从本地存储中获取的主题配置
   * @type {ThemeItem}
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * @method aboutToAppear
   * @description 组件即将显示时的生命周期方法
   * 
   * 功能说明：
   * 1. 组件初始化时调用
   * 2. 获取隐藏分组列表数据
   * 
   * @returns {void}
   */
  aboutToAppear(): void {
    this.getGroupList()
  }

  /**
   * @method getGroupList
   * @description 获取分组列表
   * 
   * 功能说明：
   * 1. 从数据库查询隐藏的分组数据
   * 2. 根据currentIndex和show条件筛选
   * 3. 更新hideList状态
   * 
   * 查询条件：
   * - type: this.currentIndex（分组类型）
   * - show: false（只查询隐藏的分组）
   * 
   * @returns {void}
   */
  getGroupList(){
    BookGroupsDao.searchHide({
      type:this.currentIndex,
      show: false
    }).then((val)=>{
      this.hideList = val
    })
  }

  /**
   * @method build
   * @description 构建分组类型搜索面板组件UI
   * 
   * 布局结构：
   * 1. 头部Flex：标题区域 + 关闭按钮
   *   - 左侧Row：'显示分组'标题 + '点击进入'提示
   *   - 右侧Row：关闭图标，点击关闭面板
   * 
   * 2. 显示分组区域Flex：
   *   - Flex布局：行方向，自动换行，左对齐
   *   - ForEach循环：遍历showGroupList
   *   - 显示条件：item.show为true且item.groupId不为1和5
   *   - 第一个分组使用GroupTypeColor（主题色），其他使用GroupType
   *   - 点击事件：设置clickGroup并打开详情弹窗
   *   - 宽度：25%（每行4个）
   * 
   * 3. 隐藏分组标题区域Flex：
   *   - '隐藏分组'标题 + '点击进入'提示
   * 
   * 4. 隐藏分组内容区域：
   *   - 条件显示：hideList.length > 0时显示分组列表
   *   - Flex布局：行方向，自动换行，居中对齐
   *   - ForEach循环：遍历hideList
   *   - GroupType构建器显示分组
   *   - 点击事件：设置clickGroup并打开详情弹窗
   *   - 宽度：25%
   *   - 空状态：显示'暂无隐藏分组'提示
   * 
   * 5. 底部弹窗绑定：
   *   - 使用bindSheet绑定bookFolderInfoDialog弹窗
   *   - 弹窗尺寸：MEDIUM、LARGE、200px
   *   - 遮罩颜色：60%黑色
   * 
   * 容器样式：
   * - Column：间距15px，y轴偏移-15px，底部圆角20px
   * - 内边距：左右15px，顶部12px，底部20px
   * - 宽度：100%，背景色：白色
   * 
   * 交互逻辑：
   * 1. 关闭按钮：点击将groupCoverShow设置为false
   * 2. 分组点击：设置clickGroup，打开详情弹窗
   * 3. 详情弹窗：显示BookManageDialog，处理搜索回调
   * 
   * 设计理念：
   * - 简洁明了：专注于分组选择和搜索功能
   * - 分类清晰：显示分组和隐藏分组分开显示
   * - 视觉层次：第一个分组使用主题色突出显示
   * - 响应式：网格布局适应不同屏幕尺寸
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中使用
   * groupTypeSearchPanel({
   *   groupCoverShow: $groupCoverShow,
   *   showGroupList: this.groupList,
   *   currentIndex: this.currentIndex,
   *   clickGroup: this.clickGroup,
   *   searchBookList: $searchBookList
   * })
   * ```
   * 
   * 颜色说明：
   * 1. rgba(0, 0, 0, 0.88): 88%黑色，用于主要标题
   * 2. rgba(0, 0, 0, 0.45): 45%黑色，用于辅助文字
   * 3. rgba(0, 0, 0, 0.04): 4%黑色，用于分组背景
   * 4. rgba(0, 0, 0, 0.6): 60%黑色，用于弹窗遮罩
   * 5. theme.mainColor: 主题主色，用于第一个分组
   * 6. theme.secondColor: 主题次色，用于第一个分组背景
   * 
   * 注意事项：
   * - 排除groupId为1和5的分组，与GroupTypeSearch保持一致
   * - 第一个分组使用特殊样式突出显示
   * - 详情弹窗通过bindSheet绑定，支持手势操作
   * - 搜索回调通过searchCheck函数处理
   * - 需要导入BookGroupsDao、BookGroups、BookManageDialog等依赖
   * 
   * 扩展建议：
   * - 可以添加分组搜索功能
   * - 可以添加分组筛选功能
   * - 可以添加分组收藏功能
   * - 可以添加分组预览功能
   * 
   * @returns {void}
   */
  build() {
    Column({
      space:15
    }){
      Flex({
        justifyContent:FlexAlign.SpaceBetween,
        alignItems:ItemAlign.End
      }){
        Row({space:12}){
          Text('显示分组').fontSize(16).fontWeight(500).lineHeight(24).fontColor('rgba(0, 0, 0, 0.88)')
          Text('点击进入').fontSize(12).fontWeight(400).lineHeight(20).fontColor('rgba(0, 0, 0, 0.45)')
        }.alignItems(VerticalAlign.Bottom)
        Row({space:12}){
          Image($r('app.media.close')).width(24).height(20).onClick(()=>{
            this.groupCoverShow = false
          })
        }
      }

      Flex({
        direction: FlexDirection.Row, wrap: FlexWrap.Wrap,
        justifyContent:FlexAlign.Start
      }){
        ForEach(this.showGroupList,(item:BookGroups,index:number)=>{
          if (item.show && item.show && item.groupId != 1 && item.groupId != 5) {
            Row(){
              if (index === 0){
                this.GroupTypeColor(item.groupName)
              } else {
                this.GroupType(item.groupName)
              }
            }.width('25%')
            .onClick(() => {
              this.clickGroup = item
              this.isShowBookFolderInfoDialog = true
            })
          }
        })
      }

      Flex({
        justifyContent:FlexAlign.SpaceBetween,
        alignItems:ItemAlign.End
      }){
        Row({space:12}){
          Text('隐藏分组').fontSize(16).fontWeight(500).lineHeight(24).fontColor('rgba(0, 0, 0, 0.88)')
          Text('点击进入').fontSize(12).fontWeight(400).lineHeight(20).fontColor('rgba(0, 0, 0, 0.45)')
        }.alignItems(VerticalAlign.Bottom)
      }
      if (this.hideList.length > 0){
        Flex({
          direction: FlexDirection.Row, wrap: FlexWrap.Wrap,alignContent:FlexAlign.Center
        }){
          ForEach(this.hideList, (item: BookGroups,index:number) => {
              Row(){
                this.GroupType(item.groupName)
              }
              .onClick(()=>{
                this.clickGroup = item
                this.isShowBookFolderInfoDialog = true
              })
              .width('25%')
          })
        }
      } else {
        Flex({
          justifyContent:FlexAlign.Center
        }){
          Text('暂无隐藏分组').fontSize(12).fontWeight(400).fontColor('rgba(0, 0, 0, 0.45)')
        }
        .borderRadius(4)
        .width('100%')
        .backgroundColor('rgba(0, 0, 0, 0.04)')
        .padding({top:6,bottom:6})

      }
      Flex()
        .bindSheet($$this.isShowBookFolderInfoDialog, this.bookFolderInfoDialog(), {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 200],
          showClose: false,
          dragBar: true,
          maskColor: 'rgba(0,0,0,0.6)',
          onDisappear:()=>{
            console.log('隐藏')
          }
        })

    }
    .offset({y:-15})
    .borderRadius({bottomLeft:20,bottomRight:20})
    .padding({left:15,right:15,top:12,bottom:20})
    .width('100%').backgroundColor(Color.White)
  }

  @Builder GroupTypeColor(title:string){
    Column(){
      Row(){
        Text(title).fontWeight(500).fontSize(12).textOverflow({
          overflow:TextOverflow.Ellipsis
        }).ellipsisMode(EllipsisMode.END)
          .maxLines(1).fontColor(this.theme.mainColor)
          .textAlign(TextAlign.Center)
      }
      .margin({ right: 16, bottom: 16 })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width(68)
      .backgroundColor(this.theme.secondColor)
      .padding({left:16,right:16,top:6,bottom:6})
    }
  }
  @Builder GroupType(title:string){
   Column(){
     Row(){
       Text(title).fontWeight(500).fontSize(12).textOverflow({
         overflow:TextOverflow.Ellipsis
       }).ellipsisMode(EllipsisMode.END)
         .maxLines(1).fontColor(Color.Black)
         .textAlign(TextAlign.Center)
     }
     .margin({ right: 16, bottom: 16 })
     .justifyContent(FlexAlign.Center)
     .alignItems(VerticalAlign.Center)
     .width(68)
     .backgroundColor('rgba(0, 0, 0, 0.04)').padding({left:16,right:16,top:6,bottom:6})
   }
  }
  @State isShowBookFolderInfoDialog:boolean = false
  @Builder bookFolderInfoDialog(){
    Column(){
      BookManageDialog({
        title:this.clickGroup.groupName,
        currentIndex:this.currentIndex,
        bookTypeNumber:this.clickGroup.groupId,
        isManage:true,
        isManageSearch:true,
        searchCheck:(val:number[])=>{
          this.searchBookList = val
          this.isShowBookFolderInfoDialog = false
        }
      })
    }
  }

}

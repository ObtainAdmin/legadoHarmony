/**
 * @file ImportCommon.ets
 * @description 通用导入页面组件
 * 
 * 功能概述：
 * 1. 提供书源批量导入功能
 * 2. 支持书源分组显示和管理
 * 3. 支持全选/取消全选操作
 * 4. 支持书源更新和新增识别
 * 5. 提供分组移动功能
 * 
 * 使用场景：
 * - 书源导入页面
 * - 书源管理页面
 * - 批量操作书源的场景
 * 
 * 设计特点：
 * - 双栏布局：左侧分组导航，右侧书源列表
 * - 智能识别：自动识别已有书源和需要更新的书源
 * - 批量操作：支持全选和分组操作
 * - 分组管理：支持书源分组显示和移动
 * 
 * 组件结构：
 * 1. 主布局：Column容器，包含所有内容
 * 2. 内容区域：Row双栏布局（侧边栏+列表）
 * 3. 操作区域：全选控制、警告提示、确认取消按钮
 * 4. 分组弹窗：底部弹窗用于分组选择
 * 
 * 技术特点：
 * - 使用@StorageProp装饰器获取本地存储数据
 * - 使用@State装饰器管理组件内部状态
 * - 使用@Prop装饰器接收父组件数据
 * - 使用@Link装饰器实现双向数据绑定
 * - 使用@StorageLink装饰器实现存储数据双向绑定
 * - 使用@Builder装饰器创建可复用的UI构建器
 * - 使用Scroller实现滚动同步
 */

/**
 * @author Andy
 * @datetime 2024/7/3 19:56
 * @className: ImportCommon
 * 通用导入页
 */
import SideBar from '../common/SideBar';
import { showMessage } from '../common/promptShow';
import Score from '../common/Score';
import Tag from '../common/Tag';
import BookSourceDao from '../../database/dao/BookSourceDao';
import { BookSource, GroupList, SOURCE_GROUP_MAP } from '../../database/entities/BookSource';
import SourceGroup from '../ui/SourceGroup';
import text from '@ohos.graphics.text';
import { ThemeItem } from '../../common/model/Theme';
import { ThemeStorageKey } from '../../common/constants/Theme';

/**
 * @class ImportCommon
 * @description 通用导入页面组件
 * 
 * 组件职责：
 * 1. 管理书源导入的整个流程
 * 2. 处理书源数据的分类和显示
 * 3. 管理用户选择状态
 * 4. 处理数据库操作
 * 5. 提供分组管理功能
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct ImportCommon {
  /** 
   * @storage pathBookSource - 书源路径
   * @description 书源文件路径，存储在本地
   * @default '' - 默认空字符串
   * @type {string}
   */
  @StorageProp('pathBookSource') pathBookSource: string = ''
  
  /** 
   * @state localSourceList - 本地书源列表
   * @description 从数据库查询的本地已有书源列表
   * @type {BookSource[]}
   */
  @State localSourceList: BookSource[] = []
  
  /** 
   * @prop sourceList - 源书源列表
   * @description 需要导入的书源列表，从父组件传入
   * @type {BookSource[]}
   */
  @Prop sourceList: BookSource[] = []
  
  /** 
   * @link show - 显示状态
   * @description 控制导入页面的显示/隐藏，与父组件双向绑定
   * @type {boolean}
   */
  @Link show: boolean;
  
  /** 
   * @state groupList - 分组列表
   * @description 按书源分组分类后的列表
   * @type {GroupList[]}
   */
  @State groupList: GroupList[] = []
  
  /** 
   * @state currentIndex - 当前索引
   * @description 当前选中的分组索引
   * @default 0 - 默认第一个分组
   * @type {number}
   */
  @State currentIndex: number = 0
  
  /** 
   * @state insertMap - 插入映射
   * @description 记录每个书源是否被选中导入的映射表
   * @type {Record<string, boolean>}
   */
  @State insertMap: Record<string, boolean> = {}
  
  /** 
   * @state alreadyNameMap - 已有名称映射
   * @description 记录书源是否已存在于本地的映射表
   * @type {Record<string, boolean>}
   */
  @State alreadyNameMap: Record<string, boolean> = {}
  
  /** 
   * @state updateNameMap - 更新名称映射
   * @description 记录书源是否需要更新的映射表
   * @type {Record<string, boolean>}
   */
  @State updateNameMap: Record<string, boolean> = {}
  
  /** 
   * @state fullActive - 全选激活状态
   * @description 控制全选复选框的状态
   * @default false - 默认未选中
   * @type {boolean}
   */
  @State fullActive: boolean = false
  
  /** 
   * @state waringActive - 警告激活状态
   * @description 控制是否允许更新正在使用的书源
   * @default false - 默认不允许
   * @type {boolean}
   */
  @State waringActive: boolean = false
  
  /** 
   * @storagelink refreshCount - 刷新计数
   * @description 刷新计数器，用于触发其他组件刷新，存储在本地
   * @default 0
   * @type {number}
   */
  @StorageLink('refreshCount') refreshCount: number = 0
  
  /** 
   * @state isShowGroup - 是否显示分组
   * @description 控制分组选择弹窗的显示/隐藏
   * @default false - 默认隐藏
   * @type {boolean}
   */
  @State isShowGroup: boolean = false
  
  /** 
   * @state groupName - 分组名称
   * @description 当前操作的分组名称
   * @default '' - 默认空字符串
   * @type {string}
   */
  @State groupName: string = ''
  
  /** 
   * @state groupIndex - 分组索引
   * @description 当前操作的分组类型索引
   * @default 0
   * @type {number}
   */
  @State groupIndex: number = 0
  
  /** 
   * @private scroll - 滚动控制器（侧边栏）
   * @description 控制侧边栏的滚动
   * @type {Scroller}
   */
  private scroll: Scroller = new Scroller()
  
  /** 
   * @private secondScroll - 滚动控制器（主列表）
   * @description 控制主列表的滚动
   * @type {Scroller}
   */
  private secondScroll = new Scroller()
  
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
   * 2. 从数据库查询本地已有书源
   * 3. 调用getGroupList()进行数据分组
   * 
   * 数据流程：
   * 1. 调用BookSourceDao.search()查询数据库
   * 2. 成功时：将查询结果赋值给localSourceList，调用getGroupList()
   * 3. 失败时：直接调用getGroupList()
   * 
   * 注意事项：
   * - 使用异步查询，避免阻塞UI
   * - 需要处理查询失败的情况
   * - 需要导入BookSourceDao
   * 
   * @returns {void}
   */
  aboutToAppear() {
    BookSourceDao.search().then(data => {
      const bookSource = data ?? []
      this.localSourceList = bookSource
      this.getGroupList()
    }).catch(() => {
      this.getGroupList()
    })
  }

  /**
   * @method getGroupList
   * @description 获取分组列表
   * 
   * 功能说明：
   * 1. 将书源按bookSourceGroup分组
   * 2. 识别已有书源和需要更新的书源
   * 3. 更新相关状态映射表
   * 
   * 分组逻辑：
   * 1. 创建groupMap对象用于分组
   * 2. 遍历sourceList中的每个书源
   * 3. 根据bookSourceGroup进行分组
   * 4. 将分组结果转换为数组赋值给groupList
   * 
   * 识别逻辑：
   * 1. 遍历本地书源列表localSourceList
   * 2. 通过bookSourceUrl匹配书源
   * 3. 如果找到匹配的书源：
   *    - 设置alreadyNameMap[url] = true（标记为已有）
   *    - 检查书源信息是否有变化：
   *      * bookSourceName不同
   *      * searchUrl不同
   *      * ruleSearch.bookList不同
   *      * ruleContent.content不同
   *    - 如果有变化，设置insertMap[url] = true和updateNameMap[url] = true（标记为需要更新）
   * 
   * 特殊处理：
   * - 如果bookSourceType >= 3，设置为0（避免SOURCE_GROUP_MAP数组越界）
   * 
   * 数据结构：
   * - GroupList: { title: string, list: BookSource[] }
   * - groupMap: Record<string, GroupList>
   * 
   * 使用场景：
   * - 组件初始化时
   * - 分组移动后重新分组
   * 
   * @returns {void}
   */
  getGroupList() {
    const groupMap: Record<string, GroupList> = {};
    this.sourceList.forEach((item: BookSource) => {
      const title = item.bookSourceGroup;
      const bookSourceName = item.bookSourceName;
      if (item.bookSourceType >= 3){
        item.bookSourceType = 0 //SOURCE_GROUP_MAP中未有3的情况,会出现数组越界
      }
      if (title) {
        // 如果groupMap中还没有这个group，则创建一个新的GroupList对象
        if (!groupMap[title]) {
          groupMap[title] = { title: title, list: [] };
        }
        // 向当前group的list中添加BookSource对象
        groupMap[title].list.push(item);
      }
      for (let i = 0; i < this.localSourceList.length; i++) {
        const localItem = this.localSourceList[i];
        if (localItem.bookSourceUrl === item.bookSourceUrl) {
          this.alreadyNameMap[item.bookSourceUrl] = true
          if (
            localItem.bookSourceName !== item.bookSourceName ||
            localItem.searchUrl !== item.searchUrl ||
            localItem.ruleSearch?.bookList !== item.ruleSearch?.bookList ||
            localItem.ruleContent?.content !== item.ruleContent?.content
          ) {
            this.insertMap[item.bookSourceUrl] = true
            this.updateNameMap[item.bookSourceUrl] = true
          }
          break;
        }
      }
    })
    this.groupList = Object.values(groupMap);
  }

  /**
   * @method scrollChangeAction
   * @description 滚动变化动作
   * 
   * 功能说明：
   * 1. 处理侧边栏和主列表的滚动同步
   * 2. 根据来源更新当前索引并滚动到对应位置
   * 
   * 参数说明：
   * @param {number} start - 新的索引位置
   * @param {Boolean} flg - 滚动来源标志
   *   - false: 来自主列表滚动
   *   - true: 来自侧边栏点击
   * 
   * 逻辑说明：
   * 1. 检查当前索引是否与新的索引不同
   * 2. 如果不同，更新currentIndex
   * 3. 根据flg决定滚动哪个滚动控制器：
   *   - flg为false：滚动侧边栏（scroll）
   *   - flg为true：滚动主列表（secondScroll）
   * 
   * 使用场景：
   * - 侧边栏点击时（flg为true）
   * - 主列表滚动时（flg为false）
   * 
   * @returns {void}
   */
  scrollChangeAction(start: number, flg: Boolean) {
    if (this.currentIndex !== start) {
      this.currentIndex = start;
      if (!flg) {
        this.scroll.scrollToIndex(start);
      } else {
        this.secondScroll.scrollToIndex(start);
      }
    }
  }

  /**
   * @method resetState
   * @description 重置状态
   * 
   * 功能说明：
   * 1. 重置组件的主要状态
   * 2. 为下一次导入做准备
   * 
   * 重置内容：
   * 1. sourceList: 清空书源列表
   * 2. groupList: 清空分组列表
   * 3. currentIndex: 重置为0（第一个分组）
   * 
   * 调用时机：
   * - 导入完成后
   * - 需要重新开始导入时
   * 
   * @returns {void}
   */
  resetState() {
    this.sourceList = []
    this.groupList = []
    this.currentIndex = 0
  }

  /**
   * @method getSourceGroupAll
   * @description 获取所有源分组
   * 
   * 功能说明：
   * 1. 获取SOURCE_GROUP_MAP中所有的分组名称
   * 2. 将嵌套数组扁平化为一维数组
   * 
   * 数据结构：
   * - SOURCE_GROUP_MAP: 源分组映射表，键为分组索引，值为分组名称数组
   * - 返回值: 所有分组名称的一维数组
   * 
   * 使用场景：
   * - 判断分组是否为系统预定义分组
   * - 分组管理功能中
   * 
   * @returns {string[]} 所有分组名称数组
   */
  getSourceGroupAll () {
    return Object.values(SOURCE_GROUP_MAP).flat()
  }

  /**
   * @method build
   * @description 构建通用导入页面组件UI
   * 
   * 布局结构：
   * 1. 主容器：Column，背景色为0xF5F5F5，上下内边距12px
   * 2. 内容区域：Row双栏布局，占满剩余空间
   *    - 左侧：SideBar侧边栏，宽度88px
   *    - 右侧：List书源列表，右边距20px，支持粘性头部
   * 3. 操作区域：从上到下依次为：
   *    - 全选控制行：Checkbox + 计数文本
   *    - 警告提示行：警告图标 + 提示文本 + Checkbox
   *    - 按钮行：取消按钮 + 确认按钮
   * 4. 分组弹窗：使用bindSheet绑定showCheckGroup构建器
   * 
   * 侧边栏配置：
   * - currentIndex: 当前选中索引
   * - sideBarList: 分组标题数组
   * - scroller: 滚动控制器
   * - clickAction: 点击回调，触发滚动同步
   * 
   * 列表配置：
   * - scroller: 滚动控制器
   * - ForEach循环：遍历groupList
   * - ListItemGroup：每个分组一个列表项组
   *   * header: classifyHeader构建的分组头部
   *   * space: 0（无间距）
   * - onScrollIndex: 滚动索引变化回调，触发滚动同步
   * - sticky: 粘性头部样式
   * 
   * 全选控制逻辑：
   * 1. Checkbox绑定fullActive状态
   * 2. 选中颜色使用主题主色
   * 3. 变化时更新fullActive，并同步更新所有书源的insertMap
   * 4. 文本显示：'全选（选中数/总数）'，选中数使用主题主色
   * 
   * 警告提示逻辑：
   * 1. 警告图标使用主题主色填充
   * 2. 提示文本：'允许对书架中正在使用的书源进行更新'，红色文字
   * 3. Checkbox绑定waringActive状态
   * 4. 背景色使用主题次色
   * 
   * 按钮逻辑：
   * 1. 取消按钮：主题主色文字，主题次色背景，点击隐藏页面
   * 2. 确认按钮：白色文字，主题主色背景，点击执行导入操作
   *    - 过滤出选中的书源（insertMap[url]为true）
   *    - 调用BookSourceDao.batchInsert批量插入
   *    - 隐藏页面，重置状态，显示成功提示，刷新计数+1
   * 
   * 分组弹窗配置：
   * - 高度：320px
   * - 显示拖拽条：true
   * - 不显示关闭按钮：false
   * - 消失回调：设置isShowGroup为false
   * 
   * 设计理念：
   * - 清晰的视觉层次：双栏布局，操作区域在底部
   * - 高效的操作流程：全选、警告确认、导入一气呵成
   * - 实时的状态反馈：选中计数实时更新
   * - 安全的操作确认：警告提示防止误操作
   * 
   * 使用示例：
   * ```typescript
   * // 在父组件中使用
   * ImportCommon({
   *   sourceList: this.importSources,
   *   show: $showImportDialog,
   * })
   * ```
   * 
   * 颜色说明：
   * 1. 0xF5F5F5: 浅灰色背景
   * 2. theme.mainColor: 主题主色，用于选中状态和重要元素
   * 3. theme.secondColor: 主题次色，用于次要背景
   * 4. #EF4444: 红色，用于警告文字
   * 5. Color.White: 白色，用于按钮文字和卡片背景
   * 6. rgba(0, 0, 0, 0.45): 45%黑色，用于次要文字
   * 
   * 注意事项：
   * - 需要导入SideBar、Score、Tag等组件
   * - 使用bindSheet实现底部弹窗
   * - 批量插入使用异步操作
   * - 刷新计数用于触发其他组件更新
   * 
   * 扩展建议：
   * - 可以添加导入进度显示
   * - 可以添加导入失败处理
   * - 可以添加书源预览功能
   * - 可以添加搜索筛选功能
   * 
   * @returns {void}
   */

  build() {
    Column() {
      Row({ space: 12 }) {
        SideBar({
          currentIndex: this.currentIndex,
          sideBarList: this.groupList.map(o => o.title),
          scroller: this.scroll,
          clickAction: (index: number) => {
            this.scrollChangeAction(index, true)
          }
        })
          .width(88)

        List({ scroller: this.secondScroll }) {
          ForEach(this.groupList, (item: GroupList, index: number) => {
            ListItemGroup({
              header: this.classifyHeader(`${item.title}`, ` (${item.list.length})` , index, item.list[0].bookSourceType || 0),
              space: 0
            }) {
              ForEach(item.list, (bookSource: BookSource, j: number) => {
                this.CourseItem(bookSource, index, j)
              })
            }
          })
        }
        .padding({ right: 20 })
        .sticky(StickyStyle.Header)
        .onScrollIndex((start) => {
          this.scrollChangeAction(start, false)
        })
        .layoutWeight(1)
      }
      .layoutWeight(1)

      Row() {
        Checkbox()
          .select(this.fullActive)
          .selectedColor(this.theme.mainColor)
          .onChange((val: boolean) => {
            this.fullActive = val
            this.sourceList.forEach((item: BookSource) => {
              this.insertMap[item.bookSourceUrl] = val
            })
          })

        Text() {
          Span('全选（')
          Span(Object.values(this.insertMap).filter(o => o).length + '')
            .fontColor(this.theme.mainColor)
          Span(`/${this.sourceList.length})`)
        }
        .margin({ left: 8 })
      }
      .width('100%')
      .height(40)
      .padding({ left: 20, right: 20 })
      .backgroundColor(Color.White)

      Row() {
        Image($r('app.media.warning'))
          .width(20)
          .fillColor(this.theme.mainColor)

        Text('允许对书架中正在使用的书源进行更新')
          .fontSize(14)
          .fontColor('#EF4444')
          .padding({ left: 8 })

        Blank()

        Checkbox()
          .select(this.waringActive)
          .selectedColor(this.theme.mainColor)
          .onChange((val: boolean) => {
            this.waringActive = val
          })
      }
      .width('100%')
      .height(48)
      .padding({ left: 20, right: 20 })
      .backgroundColor(this.theme.secondColor)

      Row({ space: 20 }) {
        Button('取消')
          .height(40)
          .fontColor(this.theme.mainColor)
          .backgroundColor(this.theme.secondColor)
          .layoutWeight(1)
          .onClick(() => {
            this.show = false;
          })

        Button('确认')
          .height(40)
          .fontColor(Color.White)
          .backgroundColor(this.theme.mainColor)
          .layoutWeight(1)
          .onClick(async  () => {
            const insertBookSources = this.sourceList.filter(item => this.insertMap[item.bookSourceUrl] ?? false)
            await BookSourceDao.batchInsert(insertBookSources)
            this.show = false;
            this.resetState()
            showMessage('添加成功')
            this.refreshCount += 1
          })
      }
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 12,
        bottom: 12
      })

      //分组
      Flex()
        .bindSheet($$this.isShowGroup, this.showCheckGroup(), {
          height: 320,
          dragBar: true,
          showClose: false,
          onDisappear: () => {
            this.isShowGroup = false
          }
        })
    }
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(0xF5F5F5)
  }

  /**
   * @builder classifyHeader
   * @description 分类头部构建器
   * 
   * 功能说明：
   * 1. 创建分组列表的头部
   * 2. 显示分组标题和书源数量
   * 3. 为非系统分组提供分组移动功能
   * 4. 提供分组全选功能
   * 
   * 布局结构：
   * 1. Row容器：水平布局，垂直居中对齐，右边距16px，背景色#f5f5f5
   * 2. Text文本：分组标题 + 数量，左对齐，48px高度，16px粗体，单行省略
   * 3. Blank空白：占满剩余空间
   * 4. 条件渲染：如果不是系统预定义分组，显示分组移动按钮
   * 5. CheckboxGroup：分组全选复选框组
   * 
   * 分组移动按钮：
   * 1. 显示条件：当前分组不在getSourceGroupAll()返回的系统分组中
   * 2. 内容：系统分组名称 + 右箭头图标
   * 3. 样式：14px字体，22px行高，主题主色，垂直居中对齐，右边距6px
   * 4. 点击事件：设置groupName和groupIndex，显示分组选择弹窗
   * 
   * 全选功能：
   * 1. CheckboxGroup：分组级别的复选框组
   * 2. 分组名称：'checkboxGroup' + index
   * 3. 形状：圆形
   * 4. 选中颜色：主题主色
   * 
   * 设计理念：
   * - 清晰的标题显示：分组名称 + 数量统计
   * - 灵活的分组管理：非系统分组可移动
   * - 便捷的批量操作：分组级别全选
   * - 一致的视觉风格：与整体设计保持一致
   * 
   * 参数说明：
   * @param {string} title - 分组标题
   * @param {string} num - 数量文本（格式：' (数量)'）
   * @param {number} index - 分组索引
   * @param {number} groupIndex - 分组类型索引（用于SOURCE_GROUP_MAP）
   * 
   * 使用场景：
   * - ListItemGroup的header属性
   * - 分组列表的头部显示
   * 
   * 注意事项：
   * - 需要调用getSourceGroupAll()判断是否为系统分组
   * - 使用SOURCE_GROUP_MAP获取系统分组名称
   * - CheckboxGroup需要与CourseItem中的Checkbox配合使用
   * 
   * @returns {void}
   */
  @Builder
  classifyHeader(title: string, num: string, index: number, groupIndex: number) {
    Row() {
      Text(title + num)
        .textAlign(TextAlign.Start)
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })

      Blank()

      if (!this.getSourceGroupAll().includes(title)) {
        Row() {
          Text(SOURCE_GROUP_MAP[groupIndex][0])
            .fontSize(14)
            .lineHeight(22)
            .fontColor(this.theme.mainColor)
          Image($r('app.media.f60_right'))
            .width(16)
        }
        .alignItems(VerticalAlign.Center)
        .padding({ right: 6 })
        .onClick(() => {
          this.groupName = title
          this.groupIndex = groupIndex
          this.isShowGroup = true
        })
      }

      CheckboxGroup({ group: 'checkboxGroup' + index })
        .checkboxShape(CheckBoxShape.CIRCLE)
        .selectedColor(this.theme.mainColor)
    }
    .alignItems(VerticalAlign.Center)
    .padding({ right: 16 })
    .backgroundColor('#f5f5f5')
  }

  /**
   * @builder CourseItem
   * @description 课程项构建器（书源项）
   * 
   * 功能说明：
   * 1. 创建单个书源的显示项
   * 2. 显示书源名称、状态标签、选择状态
   * 3. 显示书源评分和导入状态
   * 
   * 布局结构：
   * 1. Column容器：垂直布局，宽度100%，高度100vp，底部外边距12px，圆角12px，内边距16px，白色背景
   * 2. 第一行Row：书源名称 + 状态标签 + 空白 + 复选框
   * 3. 第二行Row：书源评分 + 导入状态文本
   * 
   * 书源名称：
   * - 字体：16px，24px行高，中等字重
   * 
   * 状态标签：
   * - 显示条件：i % 2 === 0（偶数索引显示，可能是示例逻辑）
   * - 内容：'正在使用'
   * - 颜色：绿色文字(#24B277)，浅绿色背景(#1F24B277，20%透明度)
   * 
   * 复选框：
   * - 名称：'checkbox' + j（唯一标识）
   * - 分组：'checkboxGroup' + i（与classifyHeader中的分组对应）
   * - 选中状态：从insertMap中获取，默认false
   * - 选中颜色：主题主色
   * - 变化回调：更新insertMap中对应书源的选择状态
   * 
   * 书源评分：
   * - 使用Score组件显示
   * - 参数：grade（等级）、score（分数）
   * 
   * 导入状态：
   * - 根据updateNameMap和alreadyNameMap判断状态
   * - '更新'：需要更新（updateNameMap[url]为true）
   * - '已有'：已存在但不需要更新（alreadyNameMap[url]为true）
   * - '新增'：新书源（其他情况）
   * - 样式：12px字体，45%黑色
   * 
   * 设计理念：
   * - 清晰的视觉层次：重要信息突出显示
   * - 便捷的操作：复选框便于选择
   * - 完整的信息：名称、状态、评分、导入状态
   * - 美观的卡片设计：圆角、阴影、内边距
   * 
   * 参数说明：
   * @param {BookSource} item - 书源对象
   * @param {number} i - 分组索引
   * @param {number} j - 书源在分组中的索引
   * 
   * 使用场景：
   * - ForEach循环中的书源项
   * - 分组列表中的每个书源
   * 
   * 注意事项：
   * - 需要导入Tag和Score组件
   * - insertMap、updateNameMap、alreadyNameMap需要正确维护
   * - 状态标签的显示逻辑可能需要根据实际需求调整
   * 
   * 扩展建议：
   * - 可以添加书源详情预览
   * - 可以添加书源测试功能
   * - 可以添加书源收藏功能
   * 
   * @returns {void}
   */
  @Builder
  CourseItem(item: BookSource, i: number, j: number) {
    Column() {
      Row() {
        Text(item.bookSourceName)
          .fontSize(16)
          .lineHeight(24)
          .fontWeight(FontWeight.Medium)

        if (i % 2 === 0) {
          Tag({ text: '正在使用', color: '#24B277', bgColor: '#1F24B277' })
        }

        Blank()

        Checkbox({ name: 'checkbox' + j, group: 'checkboxGroup' + i })
          .select(this.insertMap[item.bookSourceUrl] ?? false)
          .selectedColor(this.theme.mainColor)
          .onChange((val: boolean) => {
            this.insertMap[item.bookSourceUrl] = val
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Blank()

      Row() {
        Score({ grade: item.bookSourceGrade, score: item.bookSourceScore })

        Text(this.updateNameMap[item.bookSourceUrl] ?? false ?
          '更新' : (this.alreadyNameMap[item.bookSourceUrl] ?? false ? '已有' : '新增'))
          .fontSize(12)
          .fontColor('rgba(0, 0, 0, 0.45)')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100vp')
    .margin({
      bottom: 12
    })
    .borderRadius(12)
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12
    })
    .backgroundColor(Color.White)
  }

  /**
   * @builder showCheckGroup
   * @description 显示选择分组构建器
   * 
   * 功能说明：
   * 1. 创建分组选择弹窗
   * 2. 提供分组选择功能
   * 3. 处理分组移动确认和取消
   * 
   * 布局结构：
   * 1. Flex容器：包裹SourceGroup组件
   * 2. SourceGroup组件：分组选择组件
   * 
   * SourceGroup配置：
   * - title: '导入至'（弹窗标题）
   * - groupList: SOURCE_GROUP_MAP[this.groupIndex]（可用的分组列表）
   * - confirm: 确认回调函数
   * - cancel: 取消回调函数
   * 
   * 确认回调逻辑：
   * 1. 遍历sourceList中的所有书源
   * 2. 如果书源的原分组等于当前操作的groupName，将其分组更新为选择的新groupName
   * 3. 更新sourceList
   * 4. 调用getGroupList()重新分组
   * 5. 设置isShowGroup为false关闭弹窗
   * 
   * 取消回调逻辑：
   * 1. 设置isShowGroup为false关闭弹窗
   * 
   * 设计理念：
   * - 简洁的弹窗设计：专注于分组选择功能
   * - 直观的操作流程：选择->确认->更新
   * - 实时的数据更新：分组变化立即反映在界面上
   * 
   * 使用场景：
   * - 点击分组移动按钮时
   * - 需要更改书源分组时
   * 
   * 注意事项：
   * - 需要导入SourceGroup组件
   * - 使用SOURCE_GROUP_MAP获取可用的分组列表
   * - 确认回调是异步函数，支持异步操作
   * - 分组更新后需要重新调用getGroupList()刷新界面
   * 
   * 扩展建议：
   * - 可以添加新建分组功能
   * - 可以添加分组重命名功能
   * - 可以添加分组删除功能
   * 
   * @returns {void}
   */
  @Builder
  showCheckGroup() {
    Flex() {
      SourceGroup({
        title: '导入至',
        groupList: SOURCE_GROUP_MAP[this.groupIndex],
        confirm: async (groupName) => {
          const sourceList = this.sourceList.map(item => {
            if (item.bookSourceGroup === this.groupName) {
              item.bookSourceGroup = groupName
            }
            return item
          })
          this.sourceList = sourceList
          this.getGroupList()
          this.isShowGroup = false
        },
        cancel: () => {
          this.isShowGroup = false
        }
      })
    }
  }
}

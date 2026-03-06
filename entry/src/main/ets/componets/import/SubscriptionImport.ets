/**
 * @file SubscriptionImport.ets
 * @description 订阅源导入页面组件
 * 
 * 功能概述：
 * 1. 提供RSS订阅源的批量导入功能
 * 2. 支持订阅源分组显示和管理
 * 3. 支持全选/取消全选操作
 * 4. 支持订阅源更新和新增识别
 * 5. 提供分组选择和管理功能
 * 
 * 使用场景：
 * - RSS订阅源导入页面
 * - 订阅源管理页面
 * - 批量操作订阅源的场景
 * 
 * 设计特点：
 * - 双栏布局：左侧分组导航，右侧订阅源列表
 * - 智能识别：自动识别已有订阅源和需要更新的订阅源
 * - 批量操作：支持全选和分组操作
 * - 分组管理：支持订阅源分组显示和选择
 * 
 * 组件结构：
 * 1. 主布局：Column容器，包含所有内容
 * 2. 内容区域：Row双栏布局（侧边栏+列表）
 * 3. 操作区域：全选控制、分组选择、确认取消按钮
 * 4. 分组弹窗：底部弹窗用于分组选择
 * 
 * 技术特点：
 * - 使用@State装饰器管理组件内部状态
 * - 使用@Prop装饰器接收父组件数据
 * - 使用@Link装饰器实现双向数据绑定
 * - 使用@StorageProp装饰器获取主题配置
 * - 使用@Builder装饰器创建可复用的UI构建器
 * - 使用Scroller实现滚动同步
 * - 使用LongPressGesture支持长按批量操作
 */
import SideBar from '../common/SideBar';
import { showMessage } from '../common/promptShow';
import Tag from '../common/Tag';
import subscriptionDao from '../../database/dao/SubscriptionDao';
import { rssGroupList, rssSources } from '../../database/entities/rssSources';
import SubscriptionDao from '../../database/dao/SubscriptionDao';
import FontConstants from '../../common/constants/FontConstants';
import CommonConstants from '../../common/constants/CommonConstants';
import PaddingConstants from '../../common/constants/PaddingConstants';
import addBookTypeDialog from '../common/addBookTypeDialog';
import { ThemeItem } from '../../common/model/Theme';
import { ThemeStorageKey } from '../../common/constants/Theme';
import rssSourcesUtils from '../../common/utils/rssSourcesUtils';

/**
 * @class SubscriptionImport
 * @description 订阅源导入页面组件
 * 
 * 组件职责：
 * 1. 管理订阅源导入的整个流程
 * 2. 处理订阅源数据的分类和显示
 * 3. 管理用户选择状态
 * 4. 处理数据库操作
 * 5. 提供分组管理功能
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct SubscriptionImport {
  /** 
   * @state localSourceList - 本地订阅源列表
   * @description 从数据库查询的本地已有订阅源列表
   * @type {rssSources[]}
   */
  @State localSourceList: rssSources[] = []
  
  /** 
   * @prop subscriptionList - 订阅源列表
   * @description 需要导入的订阅源列表，从父组件传入
   * @type {rssSources[]}
   */
  @Prop subscriptionList: rssSources[] = []
  
  /** 
   * @link show - 显示状态
   * @description 控制导入页面的显示/隐藏，与父组件双向绑定
   * @type {boolean}
   */
  @Link show: boolean;
  
  /** 
   * @state groupList - 分组列表
   * @description 按订阅源分组分类后的列表
   * @type {rssGroupList[]}
   */
  @State groupList: rssGroupList[] = []
  
  /** 
   * @state currentIndex - 当前索引
   * @description 当前选中的分组索引
   * @default 0 - 默认第一个分组
   * @type {number}
   */
  @State currentIndex: number = 0
  
  /** 
   * @state insertMap - 插入映射
   * @description 记录每个订阅源是否被选中导入的映射表
   * @type {Record<string, boolean>}
   */
  @State insertMap: Record<string, boolean> = {}
  
  /** 
   * @state alreadyNameMap - 已有名称映射
   * @description 记录订阅源是否已存在于本地的映射表
   * @type {Record<string, boolean>}
   */
  @State alreadyNameMap: Record<string, boolean> = {}
  
  /** 
   * @state updateNameMap - 更新名称映射
   * @description 记录订阅源是否需要更新的映射表
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
   * @description 控制是否允许更新正在使用的订阅源（当前未使用）
   * @default false - 默认不允许
   * @type {boolean}
   */
  @State waringActive: boolean = false
  
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
   * @state sourceGroup - 源分组
   * @description 当前选择的订阅源分组名称
   * @default '' - 默认空字符串
   * @type {string}
   */
  @State sourceGroup: string = ''
  
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
   * 2. 从数据库查询本地已有订阅源
   * 3. 调用getGroupList()进行数据分组
   * 
   * 数据流程：
   * 1. 调用subscriptionDao.search()查询数据库
   * 2. 成功时：将查询结果赋值给localSourceList，调用getGroupList()
   * 3. 失败时：直接调用getGroupList()
   * 
   * 注意事项：
   * - 使用异步查询，避免阻塞UI
   * - 需要处理查询失败的情况
   * - 需要导入subscriptionDao
   * 
   * @returns {void}
   */
  aboutToAppear() {
    subscriptionDao.search().then(data => {
      const rssSources = data ?? []
      this.localSourceList = rssSources
      this.getGroupList()
    }).catch(() => {
      this.getGroupList()
    })
  }

  /**
   * @method getRssSourceList
   * @description 获取RSS源列表
   * 
   * 功能说明：
   * 1. 获取可用的订阅源分组列表
   * 2. 更新sourceGroupList状态
   * 
   * 实现方式：
   * - 调用rssSourcesUtils.getRssSourcesGroup()获取分组列表
   * - 将结果赋值给sourceGroupList
   * 
   * 使用场景：
   * - 打开分组选择弹窗前
   * - 添加新分组后刷新列表
   * 
   * 注意事项：
   * - 异步方法，需要await调用
   * - 需要导入rssSourcesUtils
   * 
   * @returns {Promise<void>}
   */
  async getRssSourceList() {
    // this.sourceGroupList = programDataPreferences.getRssSourcesListData()
    this.sourceGroupList = await rssSourcesUtils.getRssSourcesGroup();
  }

  /**
   * @method getGroupList
   * @description 获取分组列表
   * 
   * 功能说明：
   * 1. 将订阅源按sourceGroup分组
   * 2. 识别已有订阅源和需要更新的订阅源
   * 3. 更新相关状态映射表
   * 
   * 分组逻辑：
   * 1. 创建groupMap对象用于分组
   * 2. 遍历subscriptionList中的每个订阅源
   * 3. 根据sourceGroup进行分组
   *    - 有分组：按分组名称分组
   *    - 无分组：归入"其他"分组
   * 4. 将分组结果转换为数组赋值给groupList
   * 
   * 识别逻辑：
   * 1. 遍历本地订阅源列表localSourceList
   * 2. 通过sourceUrl匹配订阅源
   * 3. 如果找到匹配的订阅源：
   *    - 设置alreadyNameMap[url] = true（标记为已有）
   *    - 检查订阅源信息是否有变化：
   *      * sourceName不同
   *      * sourceUrl不同
   *      * rssListRule.ruleTitle不同
   *      * rssWebViewRule.ruleContent不同
   *    - 如果有变化，设置insertMap[url] = true和updateNameMap[url] = true（标记为需要更新）
   * 
   * 特殊处理：
   * - 设置item.sourceType = 1（固定值）
   * 
   * 数据结构：
   * - rssGroupList: { title: string, list: rssSources[] }
   * - groupMap: Record<string, rssGroupList>
   * 
   * 使用场景：
   * - 组件初始化时
   * - 数据更新后重新分组
   * 
   * @returns {void}
   */
  getGroupList() {
    const groupMap: Record<string, rssGroupList> = {};
    this.subscriptionList.forEach((item: rssSources) => {
      const title = item.sourceGroup;
      item.sourceType = 1
      if (title) {
        // 如果groupMap中还没有这个group，则创建一个新的GroupList对象
        if (!groupMap[title]) {
          groupMap[title] = { title: title, list: [] };
        }
        // 向当前group的list中添加BookSource对象
        groupMap[title].list.push(item);
      } else {
        if (!groupMap['其他']) {
          groupMap['其他'] = { title: '其他', list: [] };
        }
        groupMap['其他'].list.push(item);
      }
      for (let i = 0; i < this.localSourceList.length; i++) {
        const localItem = this.localSourceList[i];
        if (localItem.sourceUrl === item.sourceUrl) {
          this.alreadyNameMap[item.sourceUrl] = true
          if (
            localItem.sourceName !== item.sourceName ||
              localItem.sourceUrl !== item.sourceUrl ||
              localItem.rssListRule?.ruleTitle !== item.rssListRule?.ruleTitle ||
              localItem.rssWebViewRule?.ruleContent !== item.rssWebViewRule?.ruleContent
          ) {
            this.insertMap[item.sourceUrl] = true
            this.updateNameMap[item.sourceUrl] = true
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
   * 1. subscriptionList: 清空订阅源列表
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
    this.subscriptionList = []
    this.groupList = []
    this.currentIndex = 0
  }

  /** 
   * @state isBatch - 是否批量模式
   * @description 控制是否进入批量操作模式
   * @default false - 默认非批量模式
   * @type {boolean}
   */
  @State isBatch: boolean = false

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
          ForEach(this.groupList, (item: rssGroupList, index: number) => {
            ListItemGroup({
              header: this.classifyHeader(`${item.title} (${item.list.length})`, index),
              space: 0
            }) {
              ForEach(item.list, (rssSource: rssSources, j: number) => {
                this.CourseItem(rssSource, index, j)
              })
            }
          })
        }
        .height('100%')
        .padding({ right: 20 })
        .sticky(StickyStyle.Header)
        .onScrollIndex((start) => {
          this.scrollChangeAction(start, false)
        })
        .layoutWeight(1)
        .gesture(
          LongPressGesture({ repeat: false, duration: 500 })
            .onAction((event: GestureEvent) => {
              this.isBatch = true
            })
        )
      }
      .layoutWeight(1)

      Flex({
        justifyContent: FlexAlign.SpaceBetween
      }) {
        Row() {
          Checkbox()
            .select(this.fullActive)
            .selectedColor(this.theme.mainColor)
            .onChange((val: boolean) => {
              this.fullActive = val
              this.subscriptionList.forEach((item: rssSources) => {
                this.insertMap[item.sourceUrl] = val
              })
            })

          Text() {
            Span('全选（')
            Span(Object.values(this.insertMap).filter(o => o).length + '')
              .fontColor(this.theme.mainColor)
            Span(`/${this.subscriptionList.length})`)
          }
          .margin({ left: 8 })
        }
        .height(40)

        Row({
          space: 6
        }) {
          if (this.sourceGroup.length > 0) {
            Text(`订阅源分组:${this.sourceGroup}`)
              .font({
                size: 14,
                weight: FontConstants.FONT_WEIGHT_700
              })
              .textAlign(TextAlign.Center)
              .fontColor(this.theme.mainColor)
              .lineHeight(22)
          }
          Text('导入至')
            .font({
              size: 14,
              weight: FontConstants.FONT_WEIGHT_400
            })
            .textAlign(TextAlign.Center)
            .fontColor(this.theme.mainColor)
            .lineHeight(22)
            .onClick(() => {
              this.getRssSourceList()
              this.isCatalogMove = true
            })
        }.height(40)
      }
      .padding({ left: 20, right: 20 })
      .backgroundColor(Color.White)


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
          .onClick(async () => {
            if (this.sourceGroup.length === 0) {
              showMessage('请选择分组')
              return
            }
            const insertRssSources = this.subscriptionList.filter(item => this.insertMap[item.sourceUrl] ?? false)
            //将insertRssSources里面的分组改为sourceGroup
            insertRssSources.forEach((item: rssSources) => {
              item.sourceGroup = this.sourceGroup
              item.sourceIconIsUrl = true
            })
            await SubscriptionDao.batchInsert(insertRssSources)
            this.show = false;
            this.resetState()
            showMessage('导入成功')
          })
      }
      .backgroundColor(Color.White)
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 12,
        bottom: 12
      })

      Flex()
        .bindSheet($$this.isCatalogMove, this.catalogMove(), {
          height: 330,
          showClose: false,
          dragBar: false,
          blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
          maskColor: 'rgba(0,0,0,0.6)'
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
   * 3. 提供分组全选功能
   * 
   * 布局结构：
   * 1. Row容器：水平布局，右边距16px，背景色#f5f5f5
   * 2. Text文本：分组标题，左对齐，48px高度，16px粗体，单行省略
   * 3. CheckboxGroup：分组全选复选框组
   * 
   * 全选功能：
   * 1. CheckboxGroup：分组级别的复选框组
   * 2. 分组名称：'checkboxGroup' + index
   * 3. 形状：圆形
   * 4. 选中颜色：主题主色
   * 
   * 设计理念：
   * - 清晰的标题显示：分组名称 + 数量统计
   * - 便捷的批量操作：分组级别全选
   * - 一致的视觉风格：与整体设计保持一致
   * 
   * 参数说明：
   * @param {string} title - 分组标题（包含数量信息）
   * @param {number} index - 分组索引
   * 
   * 使用场景：
   * - ListItemGroup的header属性
   * - 分组列表的头部显示
   * 
   * 注意事项：
   * - CheckboxGroup需要与CourseItem中的Checkbox配合使用
   * - 标题已包含数量信息，格式为"分组名称 (数量)"
   * 
   * @returns {void}
   */
  @Builder
  classifyHeader(title: string, index: number) {
    Row() {
      Text(title)
        .textAlign(TextAlign.Start)
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })
      CheckboxGroup({ group: 'checkboxGroup' + index })
        .checkboxShape(CheckBoxShape.CIRCLE)
        .selectedColor(this.theme.mainColor)
    }
    .padding({ right: 16 })
    .backgroundColor('#f5f5f5')
  }

  /**
   * @builder CourseItem
   * @description 课程项构建器（订阅源项）
   * 
   * 功能说明：
   * 1. 创建单个订阅源的显示项
   * 2. 显示订阅源名称、状态标签、选择状态
   * 3. 显示订阅源导入状态
   * 
   * 布局结构：
   * 1. Column容器：垂直布局，宽度100%，高度100vp，底部外边距12px，圆角12px，内边距16px，白色背景
   * 2. 第一行Row：订阅源名称 + 状态标签 + 空白 + 复选框
   * 3. 第二行Row：导入状态文本
   * 
   * 订阅源名称：
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
   * - 变化回调：更新insertMap中对应订阅源的选择状态
   * 
   * 导入状态：
   * - 根据updateNameMap和alreadyNameMap判断状态
   * - '更新'：需要更新（updateNameMap[url]为true）
   * - '已有'：已存在但不需要更新（alreadyNameMap[url]为true）
   * - '新增'：新订阅源（其他情况）
   * - 样式：12px字体，45%黑色
   * 
   * 设计理念：
   * - 清晰的视觉层次：重要信息突出显示
   * - 便捷的操作：复选框便于选择
   * - 完整的信息：名称、状态、导入状态
   * - 美观的卡片设计：圆角、阴影、内边距
   * 
   * 参数说明：
   * @param {rssSources} item - 订阅源对象
   * @param {number} i - 分组索引
   * @param {number} j - 订阅源在分组中的索引
   * 
   * 使用场景：
   * - ForEach循环中的订阅源项
   * - 分组列表中的每个订阅源
   * 
   * 注意事项：
   * - 需要导入Tag组件
   * - insertMap、updateNameMap、alreadyNameMap需要正确维护
   * - 状态标签的显示逻辑可能需要根据实际需求调整
   * 
   * 扩展建议：
   * - 可以添加订阅源详情预览
   * - 可以添加订阅源测试功能
   * - 可以添加订阅源收藏功能
   * 
   * @returns {void}
   */
  @Builder
  CourseItem(item: rssSources, i: number, j: number) {
    Column() {
      Row() {
        Text(item.sourceName)
          .fontSize(16)
          .lineHeight(24)
          .fontWeight(FontWeight.Medium)

        if (i % 2 === 0) {
          Tag({ text: '正在使用', color: '#24B277', bgColor: '#1F24B277' })
        }

        Blank()

        Checkbox({ name: 'checkbox' + j, group: 'checkboxGroup' + i })
          .select(this.insertMap[item.sourceUrl] ?? false)
          .selectedColor(this.theme.mainColor)
          .onChange((val: boolean) => {
            this.insertMap[item.sourceUrl] = val
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Blank()

      Row() {
        Text(this.updateNameMap[item.sourceUrl] ?? false ?
          '更新' : (this.alreadyNameMap[item.sourceUrl] ?? false ? '已有' : '新增'))
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
   * @state isCatalogMove - 是否显示目录移动
   * @description 控制分组选择弹窗的显示/隐藏
   * @default false - 默认隐藏
   * @type {boolean}
   */
  @State isCatalogMove: boolean = false
  
  /** 
   * @state sourceGroupList - 源分组列表
   * @description 可用的订阅源分组列表
   * @default [] - 默认空数组
   * @type {string[]}
   */
  @State sourceGroupList: string[] = []

  /**
   * @builder catalogMove
   * @description 目录移动构建器（分组选择弹窗）
   * 
   * 功能说明：
   * 1. 创建分组选择弹窗
   * 2. 显示可用的分组列表
   * 3. 提供新建分组功能
   * 4. 处理分组选择和取消操作
   * 
   * 布局结构：
   * 1. Column容器：垂直布局，宽度100%，高度100%
   * 2. 标题区域：显示"导入至"标题
   * 3. 分割线：0.5px宽度
   * 4. 滚动区域：分组列表，3列网格布局
   *    - 第一项：新建分组按钮（+图标）
   *    - 其他项：分组名称文本
   * 5. 分割线：0.5px宽度
   * 6. 取消区域：显示"取消"文本
   * 
   * 标题区域：
   * - 文本："导入至"
   * - 样式：16px字体，700字重，24px行高
   * - 内边距：上下12px，左右20px
   * 
   * 滚动区域：
   * - 使用Scroll组件支持滚动
   * - 使用GridRow实现3列网格布局
   * - 高度：65%
   * - 内边距：20px
   * - 对齐方式：顶部对齐
   * - 滚动条：关闭
   * 
   * 取消区域：
   * - 文本："取消"
   * - 样式：16px字体，400字重，24px行高
   * - 点击事件：关闭弹窗
   * - 对齐方式：水平居中
   * - 内边距：顶部16px，左右32px
   * 
   * 设计理念：
   * - 清晰的层级结构：标题->列表->取消
   * - 高效的布局：网格布局充分利用空间
   * - 直观的操作：新建分组按钮明显
   * - 一致的交互：点击取消关闭弹窗
   * 
   * 使用场景：
   * - 点击"导入至"按钮时
   * - 需要选择订阅源分组时
   * 
   * 注意事项：
   * - 需要导入CommonConstants、PaddingConstants
   * - 使用titleBuilder构建每个分组项
   * - 弹窗通过bindSheet绑定显示
   * 
   * 扩展建议：
   * - 可以添加分组搜索功能
   * - 可以添加分组管理功能（重命名、删除）
   * - 可以添加分组图标支持
   * 
   * @returns {void}
   */
  @Builder
  catalogMove() {
    Column() {
      Column() {
        Text('导入至').fontSize(16).fontWeight(700).lineHeight(24)

      }
      .padding({
        right: 20,
        left: 20,
        top: 12,
        bottom: 12
      })

      Divider().strokeWidth(0.5)
      Scroll() {
        GridRow({
          columns: 3,
        }) {
          GridCol() {
            this.titleBuilder('')
          }

          ForEach(this.sourceGroupList, (item: string, index: number) => {
            GridCol() {
              this.titleBuilder(item)
            }

          })
        }
      }
      .padding(PaddingConstants.PADDING_20)
      .align(Alignment.Top)
      .height('65%')
      .scrollBar(BarState.Off)

      Divider().strokeWidth(0.5)
      Column() {
        Text('取消').fontSize(16).fontWeight(400)
          .lineHeight(24)
      }
      .onClick(() => {
        this.isCatalogMove = false
      })
      .alignItems(HorizontalAlign.Center)
      .padding({
        left: 32,
        right: 32,
        top: 16
      })
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
  }

  /**
   * @builder titleBuilder
   * @description 标题构建器（分组项）
   * 
   * 功能说明：
   * 1. 创建单个分组项的显示
   * 2. 支持新建分组和现有分组两种模式
   * 3. 处理分组选择点击事件
   * 
   * 布局结构：
   * 1. Column容器：垂直布局，宽度96px，高度36px，底部外边距16px，内边距16px，背景色为6%黑色
   * 2. 内容：
   *    - 新建分组：显示加号图标
   *    - 现有分组：显示分组名称文本
   * 
   * 新建分组模式（title为空字符串）：
   * - 显示：加号图标
   * - 图标尺寸：24px
   * - 点击事件：打开新建分组对话框
   * 
   * 现有分组模式（title不为空）：
   * - 显示：分组名称文本
   * - 样式：14px字体，单行省略
   * - 点击事件：设置sourceGroup为当前分组，关闭弹窗，显示提示消息
   * 
   * 设计理念：
   * - 清晰的视觉区分：新建和现有分组明显不同
   * - 一致的交互体验：点击都有明确反馈
   * - 美观的网格布局：固定尺寸确保对齐
   * - 实用的功能：支持快速新建分组
   * 
   * 参数说明：
   * @param {string} title - 分组标题（空字符串表示新建分组）
   * 
   * 使用场景：
   * - catalogMove构建器中的分组列表
   * - 分组选择弹窗中的每个分组项
   * 
   * 注意事项：
   * - 需要导入PaddingConstants
   * - 新建分组时调用addNewGroupType对话框
   * - 选择现有分组时显示提示消息
   * 
   * 扩展建议：
   * - 可以添加分组图标
   * - 可以添加分组描述
   * - 可以添加分组使用统计
   * 
   * @returns {void}
   */
  @Builder
  titleBuilder(title: string) {
    Column() {
      if (title === '') {
        Image($r('app.media.add')).width(24)
      } else {
        Text(title).fontSize(14).textOverflow({
          overflow: TextOverflow.Ellipsis
        }).ellipsisMode(EllipsisMode.END).maxLines(1)
      }
    }
    .onClick(() => {
      if (title === '') {
        this.addNewGroupType?.open()
        return
      } else {
        showMessage(title)
        this.sourceGroup = title
        this.isCatalogMove = false;
      }
    })
    .width(96)
    .height(36)
    .margin({ bottom: PaddingConstants.PADDING_16 })
    .backgroundColor($r('app.string.color_black_6'))
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
  }

  /** 
   * @state newGroupType - 新分组类型
   * @description 新建分组的名称
   * @default '' - 默认空字符串
   * @type {string}
   */
  @State newGroupType: string = ''
  
  /** 
   * @property addNewGroupType - 添加新分组类型对话框控制器
   * @description 控制新建分组对话框的显示/隐藏
   * @type {CustomDialogController | null}
   */
  addNewGroupType: CustomDialogController | null = new CustomDialogController({
    builder: addBookTypeDialog({
      cancel: () => {
        this.addNewGroupType?.close()
      },
      confirm: async () => {
        let insertSuccess: boolean = await rssSourcesUtils.addGroupType(this.newGroupType)
        this.newGroupType = ''
        if (insertSuccess) {
          setTimeout(() => {
            this.getRssSourceList()
          }, 200)
        }
      },
      bookType: this.newGroupType
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    gridCount: 4,
    customStyle: false,
    cornerRadius: 25
  })
  
  /** 
   * @state isInsert - 是否插入
   * @description 标记是否正在插入新分组（当前未使用）
   * @default false - 默认false
   * @type {boolean}
   */
  @State isInsert: boolean = false
  
  /**
   * @method addGroupType (注释掉的方法)
   * @description 添加分组类型（已注释，使用对话框方式替代）
   * 
   * 原功能说明：
   * 1. 检查分组名称是否重复
   * 2. 插入新分组到数据库
   * 3. 刷新分组列表
   * 4. 显示操作结果提示
   * 
   * 当前状态：
   * - 已注释，使用addNewGroupType对话框替代
   * - 保留代码作为参考
   * 
   * 替代方案：
   * - 使用addBookTypeDialog组件
   * - 通过rssSourcesUtils.addGroupType方法添加分组
   * - 自动处理重复检查和刷新
   */
  // async addGroupType(){
  //   let group = await rssSourcesUtils.getRssSourcesGroup();
  //   group.map((data:string)=>{
  //     if(data === this.newGroupType){
  //       this.isInsert = true
  //     }
  //   })
  //   if (this.isInsert) {
  //     showMessage('分组名称重复')
  //     this.isInsert = false
  //   } else {
  //     rssSourcesUtils.insertRssSourceGroup(this.newGroupType)
  //     //添加分组后再次刷新分组列表
  //     setTimeout(()=>{
  //       this.getRssSourceList()
  //     },200)
  //     showMessage(`添加分组${this.newGroupType}成功!`)
  //   }
  //   this.newGroupType = ''
  // }
}

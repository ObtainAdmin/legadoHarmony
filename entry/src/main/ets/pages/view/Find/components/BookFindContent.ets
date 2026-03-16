/**
 * @author 2008
 * @datetime 2024/7/14 21:54
 * @className: BookFind
 * @description: 发现公用书籍展示组件 - 负责展示特定分类下的书籍列表
 * 
 * 组件功能：
 * 1. 根据传入的探索项(exploreItem)和规则(exploreRule)加载对应的书籍列表
 * 2. 支持网络请求获取书籍数据，自动处理相对路径的URL拼接
 * 3. 提供加载状态、错误状态、空状态的完整UI展示
 * 4. 支持点击查看更多功能，导航到完整的书籍列表页面
 * 5. 使用CardItem组件展示每本书籍的详细信息
 * 
 * 数据流：
 * - 接收父组件传入的探索项和规则配置
 * - 通过网络请求获取书籍列表数据
 * - 将数据传递给CardItem组件进行展示
 * - 处理用户交互（点击书籍项、点击查看更多）
 * 
 * 状态管理：
 * - loading: 控制加载状态显示
 * - errorExplore: 控制错误状态显示
 * - bookList: 存储获取到的书籍列表数据
 */

// 导入网络请求库
import axios, { AxiosResponse, AxiosError } from '@ohos/axios'
// 导入工具函数
import { isNetworkUrl } from '../../../../common/utils/utils'
// 导入无数据组件
import noFind from '../../../../componets/common/noFind'
// 导入数据类型
import { ExploreRule } from '../../../../database/entities/rule'
import { ExploreItem, ExploreQuery } from '../../../../database/types/BookSourceType'
// 导入UI组件
import mayAlsoLike from '../mayAlsoLike'
import { CardItem } from './CardItem'
import { router } from '@kit.ArkUI'
// 导入常量和主题
import CommonConstants from '../../../../common/constants/CommonConstants';
import { ThemeItem } from '../../../../common/model/Theme'
import { ThemeStorageKey } from '../../../../common/constants/Theme'

/**
 * 书籍发现内容组件
 * @prop {number} currentIndex - 当前分类索引（小说/漫画/有声书）
 * @prop {string} bookSourceUrl - 书籍源URL，用于构建完整的请求地址
 * @prop {ExploreItem} exploreItem - 探索项数据，包含标题和URL等信息
 * @prop {number} counter - 刷新计数器，触发数据重新加载
 * @prop {ExploreRule} exploreRule - 探索规则配置，定义如何解析书籍数据
 */
@Component
export default struct BookFindContent {
  // 当前分类索引，用于确定书籍类型
  @Prop currentIndex: number
  
  // 书籍源URL，用于拼接完整的请求地址
  @Prop bookSourceUrl: string
  
  // 探索项数据，包含分类标题和请求URL等信息
  @Prop exploreItem: ExploreItem
  
  // 刷新计数器，带有@Watch监听，值变化时自动重新加载数据
  @Prop @Watch('getList') counter: number = 0
  
  // 加载状态 - true表示正在加载数据
  @State loading: boolean = true
  
  // 错误状态 - true表示加载数据失败
  @State errorExplore: boolean = false
  
  // 书籍列表 - 存储获取到的书籍数据
  @State bookList: ExploreRule[] = []
  
  // 探索规则配置，定义书籍数据的解析规则
  @Prop exploreRule: ExploreRule = {}
  
  // 点击事件处理函数（当前未使用）
  handleClick: () => void = () => {
  }
  
  // 主题颜色配置，用于UI样式
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 组件即将出现时的生命周期方法
   * 触发时机：组件创建并即将渲染时
   * 功能：初始化组件数据，开始加载书籍列表
   */
  aboutToAppear() {
    this.getList()
  }

  /**
   * 获取书籍列表的核心方法
   * 功能概述：根据探索项和规则配置，通过网络请求获取书籍数据
   * 
   * 数据处理流程：
   * 1. 设置加载状态为true
   * 2. 处理URL：替换分页参数，拼接完整的请求地址
   * 3. 构建请求参数对象（ExploreQuery）
   * 4. 发送网络请求获取数据
   * 5. 处理响应数据：修复封面URL的相对路径问题
   * 6. 更新组件状态，触发UI重新渲染
   * 
   * 错误处理：
   * - 网络请求失败时设置errorExplore为true，显示错误状态
   * - 确保在任何情况下都要取消加载状态，避免界面卡死
   */
  getList() {
    this.loading = true
    let url = this.exploreItem.url.replace('{{page}}', "1")
    if (!isNetworkUrl(url)) {
      url = this.bookSourceUrl + url
    }
    const exploreQuery: ExploreQuery = {
      url,
      bookList: this.exploreRule.bookList,
      pageSize: 3,
      name: this.exploreRule.name,
      author: this.exploreRule.author,
      intro: this.exploreRule.intro,
      kind: this.exploreRule.kind,
      lastChapter: this.exploreRule.lastChapter,
      bookUrl: this.exploreRule.bookUrl,
      coverUrl: this.exploreRule.coverUrl,
      wordCount: this.exploreRule.wordCount
    }
    axios.post(CommonConstants.BASE_URL + '/common/analysisRules', exploreQuery).then((res: AxiosResponse) => {
      console.info('TagInfo, 解析内容：', JSON.stringify(res.data))
      this.bookList = (res.data as ExploreRule[]).map(item => {
        if (item.coverUrl && !isNetworkUrl(item.coverUrl)) {
          item.coverUrl = this.bookSourceUrl + item.coverUrl
        }
        return item
      })
      this.loading = false
      this.errorExplore = false
    }).catch((err: AxiosError) => {
      console.log('TagInfo 请求失败：', JSON.stringify(err.message));
      this.loading = false
      this.errorExplore = true
    })
  }

  /**
   * 组件UI构建方法
   * 定义组件的视觉结构和交互逻辑
   * 
   * 布局结构：
   * 1. 外层Column：作为根容器，设置间距
   * 2. 内层Column：白色背景的内容卡片，包含所有内容
   * 3. 标题区域：使用mayAlsoLike组件显示分类标题
   * 4. 内容区域：根据状态显示不同的内容
   * 
   * 状态管理：
   * - 加载状态：显示LoadingProgress和提示文字
   * - 错误状态：显示noFind组件，提供重试功能
   * - 空数据状态：显示noFind组件，使用hintIndex=0的提示
   * - 正常状态：显示书籍列表和"查看更多"按钮
   * 
   * 交互功能：
   * 1. 错误状态点击：重新调用getList()加载数据
   * 2. 书籍项点击：由CardItem组件内部处理，导航到书籍详情页
   * 3. 查看更多点击：导航到CategoryList页面，显示完整书籍列表
   */
  build() {
    Column({
      space: 16  // 设置子元素之间的间距为16
    }) {
      Column() {
        // 标题区域：显示分类标题
        mayAlsoLike({
          mayAlsoLike: this.exploreItem.title,  // 使用探索项的标题作为显示文本
          handleClick: this.handleClick         // 点击事件处理（当前未使用）
        })
        
        // 根据加载状态显示不同的内容
        if (this.loading) {
          // 加载中状态：显示加载动画和提示文字
          Column() {
            LoadingProgress()
              .color(this.theme.mainColor)  // 使用主题颜色
              .width('50%')                   // 设置加载动画宽度
            Text('内容加载中...')              // 加载提示文字
          }
          .justifyContent(FlexAlign.Center)  // 内容居中显示
          .layoutWeight(1)                   // 占满剩余空间
          
        } else if (this.errorExplore) {
          // 错误状态：显示错误提示和重试按钮
          noFind({
            onclick: () => {
              // 点击重试时重新加载数据
              this.getList()
            }
          })
          
        } else if (this.bookList.length === 0) {
          // 空数据状态：显示无数据提示
          noFind({
            hintIndex: 0  // 使用预设的无数据提示
          })
          
        } else {
          // 正常状态：显示书籍列表
          Column() {
            // 遍历书籍列表，为每本书创建一个CardItem组件
            ForEach(this.bookList, (item: ExploreRule, index) => {
              CardItem({ 
                item: item,              // 书籍数据
                currentIndex: this.currentIndex  // 当前分类索引，用于确定书籍类型
              })
            })
            
            // 查看更多按钮：当书籍数量等于3时显示
            // 注意：这里的3是硬编码的，与请求参数中的pageSize: 3对应
            if (this.bookList.length === 3) {
              Column() {
                Text('查看更多')
                  .lineHeight(20)
                  .fontColor('#73000000')  // 灰色文字
              }
              .width('100%')              // 宽度占满父容器
              .padding({ top: 8, bottom: 8 })  // 上下内边距
              .margin({ top: 20 })        // 上边距
              .backgroundColor('#0F000000')    // 浅灰色背景
              .borderRadius(4)            // 4px圆角
              .onClick(() => {
                // 点击导航到分类列表页面，显示完整的书籍列表
                router.pushUrl({
                  url: 'pages/view/Find/CategoryList/Index',
                  params: {
                    bookSourceUrl: this.bookSourceUrl,    // 书籍源URL
                    exploreItem: this.exploreItem,        // 当前探索项
                    exploreRule: this.exploreRule,        // 探索规则
                    currentIndex: this.currentIndex       // 当前分类索引
                  }
                })
              })
            }
          }
          .height('100%')               // 高度占满父容器
          .alignItems(HorizontalAlign.Start)  // 内容左对齐
          .justifyContent(FlexAlign.Start)    // 从顶部开始排列
        }
      }
      .padding({
        left: 16,   // 左内边距
        right: 16,  // 右内边距
        top: 20,    // 上内边距
        bottom: 20  // 下内边距
      })
      .borderRadius(12)              // 12px圆角
      .backgroundColor(Color.White)  // 白色背景
      .height(436)                   // 固定高度436px
    }
    .margin({ top: 12 })             // 顶部外边距12px
  }
}
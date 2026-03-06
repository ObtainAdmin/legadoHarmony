/**
 * SearchRefresh 组件 - 搜索刷新组件
 * 
 * 功能概述：
 * 1. 提供搜索页面的刷新功能，显示加载状态
 * 2. 集成主题系统，支持动态主题颜色的加载指示器
 * 3. 监听刷新状态变化，更新全局搜索状态
 * 4. 提供"玩命加载中..."的视觉反馈
 * 
 * 设计特点：
 * 1. 简洁布局：使用Column和Refresh组件构建刷新界面
 * 2. 主题集成：加载指示器使用主题主色
 * 3. 状态管理：监听刷新状态，3秒后自动完成刷新
 * 4. 视觉反馈：45%黑色的文本，居中对齐的加载指示器
 * 
 * 使用场景：
 * 1. 搜索页面需要刷新功能的场景
 * 2. 需要显示加载状态并更新全局状态的界面
 * 3. 需要集成主题系统的刷新组件
 * 
 * 组件结构：
 * - 刷新容器：Refresh组件包裹内容区域
 * - 加载指示器：LoadingProgress组件和文本
 * - 状态监听：监听刷新状态变化和完成事件
 * 
 * 注意事项：
 * 1. 刷新完成后需要更新全局搜索状态
 * 2. 加载指示器颜色需要与主题同步
 * 3. 刷新时间需要合理设置（当前为3秒）
 */

import { ThemeStorageKey } from "../../common/constants/Theme";
import { ThemeItem } from "../../common/model/Theme";

@Component
export struct SearchRefresh{
  /**
   * 文本颜色
   * @type {string}
   * @default "rgba(0, 0, 0, 0.45)"
   * @description 刷新文本的颜色，45%黑色
   * @state 使用@State装饰器管理组件内部状态
   */
  @State color:string="rgba(0, 0, 0, 0.45)"
  
  /**
   * 搜索状态
   * @type {number}
   * @description 全局搜索状态，刷新完成后更新为2（已完成）
   * @consume 使用@Consume装饰器消费全局状态
   */
  @Consume  SearchStatus: number;

  /**
   * 主题配置
   * @type {ThemeItem}
   * @description 从存储中读取的主题配置
   * @storageprop 使用@StorageProp装饰器从存储中读取数据
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem

  /**
   * 刷新组件构建器
   * @returns {void}
   * @description 构建刷新时显示的加载组件
   * 包含主题色的加载进度条和"玩命加载中..."文本
   */
  @Builder refresh(){
    Stack(){
      Row(){
        LoadingProgress() // 加载进度指示器
          .color(this.theme.mainColor) // 主题主色
          .height(30) // 30px高度
        Text("玩命加载中...") // 加载文本
          .fontSize(16) // 16px字体
          .margin({left:20}) // 左侧20px外边距
          .fontColor(this.color) // 45%黑色
      }.alignItems(VerticalAlign.Center) // 垂直居中对齐
    }.width("100%").height("100%").align(Alignment.Center) // 100%宽高，居中对齐
  }
  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建搜索刷新组件的完整UI结构
   * 包含刷新容器和状态监听逻辑
   */
  build() {
    Column(){
      /**
       * 刷新容器
       * @description 10%高度，始终处于刷新状态
       * 使用refresh构建器显示加载内容
       */
      Refresh({refreshing:true,builder:this.refresh()}){
        // 刷新内容区域（当前为空）
      }
      .height("10%") // 10%高度
      /**
       * 刷新状态变化监听
       * @description 监听刷新状态变化，打印状态信息
       */
      .onStateChange((refreshStatus: RefreshStatus) => {
        console.info('Refresh onStatueChange state is ' + refreshStatus) // 打印状态变化
      })
      /**
       * 刷新开始监听
       * @description 刷新开始时触发，3秒后更新搜索状态为已完成
       */
      .onRefreshing(() => {
        setTimeout(() => {
          this.SearchStatus = 2 // 3秒后更新搜索状态为已完成
        }, 3000) // 3000ms延迟
        console.log('onRefreshing test') // 调试日志
      })
    }
    .height("80%") // 80%高度
    .width("100%") // 100%宽度
    .justifyContent(FlexAlign.Center) // 居中对齐
  }

}

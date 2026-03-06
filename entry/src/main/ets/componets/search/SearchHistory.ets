
/**
 * SearchHistory 组件 - 搜索历史组件
 * 
 * 功能概述：
 * 1. 显示用户的搜索历史记录，支持展开/收起功能
 * 2. 提供搜索历史标签的灵活布局，支持换行显示
 * 3. 实现展开/收起动画效果，提升用户体验
 * 4. 预留排行榜功能区域，支持水平滚动
 * 
 * 设计特点：
 * 1. 响应式布局：使用Flex布局实现标签的自动换行
 * 2. 动画效果：展开/收起图标旋转动画，1000ms持续时间
 * 3. 状态管理：管理展开状态、旋转角度和内容高度
 * 4. 视觉层次：清晰的标题、操作按钮和内容区域划分
 * 5. 交互设计：直观的展开/收起和删除操作
 * 
 * 使用场景：
 * 1. 搜索页面的历史记录区域
 * 2. 需要显示用户搜索历史的界面
 * 3. 需要支持展开/收起功能的标签列表
 * 
 * 组件结构：
 * - 标题区域：搜索历史标题和操作按钮（展开/收起、删除）
 * - 历史记录区域：Flex布局的标签列表，支持换行
 * - 排行榜区域：预留的水平滚动排行榜（当前为注释状态）
 * 
 * 注意事项：
 * 1. 需要正确处理展开/收起状态切换
 * 2. 动画效果需要平滑过渡
 * 3. 标签布局需要考虑不同屏幕尺寸
 */

@Component
export struct SearchHistory{

  /**
   * 历史书籍名称列表
   * @type {String[]}
   * @default ["仙逆","一念永恒","一念永恒","一念永恒", "一念永恒", "吞噬星空", "凡人修仙传", "夜的命名术", "夜的命名术", "一念永恒", "一念永恒", "一念永恒", "一念永恒", "一念永恒"]
   * @description 用户搜索过的书籍名称历史记录
   * @state 使用@State装饰器管理组件内部状态
   */
  @State  historyBookNames: String[] = ["仙逆","一念永恒","一念永恒","一念永恒", "一念永恒", "吞噬星空", "凡人修仙传", "夜的命名术", "夜的命名术", "一念永恒", "一念永恒", "一念永恒", "一念永恒", "一念永恒"]
  
  /**
   * 排行榜列表
   * @type {String[]}
   * @default ["小说热搜榜", "漫画热搜榜", "听书热搜榜"]
   * @description 预留的排行榜分类列表
   * @state 使用@State装饰器管理组件内部状态
   */
  @State rankingList: String[] = ["小说热搜榜", "漫画热搜榜", "听书热搜榜"]
  
  /**
   * 旋转角度
   * @type {number}
   * @default 0
   * @description 展开/收起图标的旋转角度（0度或180度）
   * @state 使用@State装饰器管理组件内部状态
   */
  @State rotateImages: number= 0;
  
  /**
   * 旋转状态
   * @type {boolean}
   * @default false
   * @description 标识是否处于展开状态
   * @state 使用@State装饰器管理组件内部状态
   */
  @State rotateState: boolean=false;
  
  /**
   * 滚动控制器
   * @type {Scroller}
   * @description 控制排行榜区域滚动的控制器实例
   */
  scroller: Scroller = new Scroller()
  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建搜索历史组件的完整UI结构
   * 包含标题区域、历史记录区域和预留的排行榜区域
   */
  build() {
    Column() {
      /**
       * 搜索历史标题区域
       * @description 90px间距，包含标题和操作按钮
       * 40%宽度用于标题，剩余空间用于操作按钮
       */
      Row({ space: 90 }) {
        Text("搜索历史") // 标题文本
          .width("40%") // 40%宽度
          .height(40) // 40px高度
          .fontWeight(600) // 600字重
          .fontSize(20); // 20px字体
        
        /**
         * 操作按钮区域
         * @description 10px间距，包含展开/收起按钮和删除按钮
         */
        Row({ space: 10 }) {
          /**
           * 展开/收起按钮
           * @description 包含文本和图标，点击切换展开状态
           */
          Row() {
            Text(this.rotateState?"收起":"展开") // 动态文本
              .fontColor($r("app.color.search_launch")) // 搜索启动颜色
            Image("/common/images/search_launch.svg") // 展开/收起图标
              .width(24).height(24)
              .fillColor($r("app.color.search_launch")) // 搜索启动颜色
              .onClick((event: ClickEvent) => {
                /**
                 * 点击事件
                 * @description 切换展开/收起状态和旋转角度
                 */
                if(this.rotateState==true){
                  this.rotateImages=0; // 收起：0度
                  this.rotateState=false; // 更新状态
                }else{
                  this.rotateImages=180; // 展开：180度
                  this.rotateState=true; // 更新状态
                }
              })
              .animation({
                duration: 1000, // 1000ms动画持续时间
                tempo:2 // 2倍速度
              })
              .rotate({angle: this.rotateImages}) // 应用旋转角度
          }

          /**
           * 删除按钮
           * @description 删除图标，预留功能
           */
          Image("/common/images/search_del.svg") // 删除图标
            .width(24).height(24)
            .fillColor($r("app.color.search_launch")) // 搜索启动颜色
        }
      }
      .width("100%") // 100%宽度
      .padding({ top:10 }); // 顶部10px内边距

      /**
       * 历史记录区域
       * @description Flex布局，行方向，自动换行
       * 根据展开状态动态调整高度（展开180px，收起100px）
       */
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        ForEach(this.historyBookNames, (item: String, index) => {
          Text(item.toString()) // 历史记录标签
            .padding({ top: 5, left: 15, right: 15}) // 内边距
            .backgroundColor($r("app.color.search_history")) // 搜索历史背景色
            .margin({ right: 10, bottom: 10 }) // 外边距
            .fontSize(13) // 13px字体
        })
      }
      .width("100%") // 100%宽度
      .height(this.rotateState?180:100) // 动态高度
      .padding({ top: 10 ,bottom:10 }) // 上下10px内边距
      .clip(true); // 裁剪溢出内容

      /**
       * 排行榜区域（预留功能）
       * @description 水平滚动区域，当前为注释状态
       * 预留用于显示小说、漫画、听书热搜榜
       */
      // Scroll(this.scroller) {
      //   Row({ space: 20 }) {
      //     ForEach(this.rankingList, (item) => {
      //       //排行榜内容组件
      //       Ranking()
      //     })
      //   }.width("50%").height("80%").alignItems(VerticalAlign.Top).margin({ top: 20 })
      // }
      // .scrollable(ScrollDirection.Horizontal)
      // .width(1700)
    }
    .padding({
      left:20, // 左侧20px内边距
      right:20 // 右侧20px内边距
    })
  }
}

/**
 * 源调试组件
 * 
 * 用于书源调试功能，提供搜索页面和调试页面的切换
 * 通过水平滑动动画在两个页面之间切换
 * 搜索页面用于输入搜索关键词，调试页面显示调试结果
 * 
 * @Component 声明为ArkUI组件
 * @default 默认导出
 */
@Component
export default struct SourceDebug {
  /** 搜索关键词输入值 */
  @State searchValue: string = ''
  
  /** 是否显示调试页面，true显示调试页面，false显示搜索页面 */
  @State isDebug: boolean = false

  /**
   * 构建组件UI
   * 
   * 组件结构：
   * 1. 使用Stack布局叠加两个页面
   * 2. 搜索页面：包含搜索框和内容提示区域
   * 3. 调试页面：包含搜索框和调试结果区域，以及返回按钮
   * 4. 通过translate动画实现水平滑动切换效果
   */
  build() {
    Stack() {
      // 搜索页面
      Scroll() {
        Column() {
          // 搜索框
          Row() {
            Search({
              value: this.searchValue,
              placeholder: `搜索书名或作者`,
              icon: "/common/images/search.svg"
            })
              .width("100%")
              .height(40)
              .onChange((value: string) => {
                // 输入变化时更新搜索值并切换到调试页面
                this.searchValue = value
                this.isDebug = true
              })
              .onSubmit(() => {
                // 提交搜索时切换到调试页面
                this.isDebug = true
              })
          }
          .padding({
            left: 20,
            right: 20,
            top: 8,
          })

          // 内容提示区域
          Column(){
            Text('内容提示')
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      // 根据isDebug状态水平平移，实现滑动效果
      .translate({x: this.isDebug ? -500 : 0})
      .animation({
        duration: 500
      })

      // 调试页面
      Scroll() {
        Column(){
          // 搜索框（与搜索页面相同）
          Row() {
            Search({
              value: this.searchValue,
              placeholder: `搜索书名或作者`,
              icon: "/common/images/search.svg"
            })
              .width("100%")
              .height(40)
              .onChange((value: string) => {
                this.searchValue = value
                this.isDebug = true
              })
              .onSubmit(() => {
                this.isDebug = true
              })
          }
          .padding({
            left: 20,
            right: 20,
            top: 8,
          })

          // 调试结果区域
          Column() {
            Text('调试页面')
            Button('返回').onClick(() => {
              // 点击返回按钮切换回搜索页面
              this.isDebug = false
            })
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      // 根据isDebug状态水平平移，实现滑动效果
      .translate({x: this.isDebug ? 0 : 500})
      .animation({
        duration: 500
      })
    }
    .alignContent(Alignment.Top)
  }
}

/**
 * NetworkInput 组件 - 网络输入显示组件
 * 
 * 功能概述：
 * 1. 显示网络来源标识和对应的URL地址
 * 2. 提供简洁的视觉展示，标识当前内容的网络来源
 * 3. 使用胶囊形状设计，提供良好的视觉层次
 * 4. 支持长URL的省略号显示，避免内容溢出
 * 
 * 设计特点：
 * 1. 胶囊形状：使用40px圆角创建胶囊形状的容器
 * 2. 分层设计：白色来源标签叠加在浅灰色背景上
 * 3. 紧凑布局：30px固定高度，充分利用有限空间
 * 4. 文本处理：URL使用省略号处理长文本，单行显示
 * 5. 视觉层次：白色标签突出来源，灰色背景作为整体容器
 * 
 * 使用场景：
 * 1. 阅读器页面中显示当前章节的网络来源
 * 2. 需要展示URL和来源标识的界面
 * 3. 网络内容来源的可视化标识
 * 
 * 组件结构：
 * - 来源标签：白色胶囊形状，包含返回图标和来源名称
 * - URL文本：浅灰色背景上的URL地址，省略号处理
 * 
 * 注意事项：
 * 1. URL文本需要正确处理溢出情况
 * 2. 来源标签的尺寸需要适配不同长度的来源名称
 * 3. 整体高度固定，需要确保内容不会超出容器
 */

@Component
export struct NetworkInput {
  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建网络输入显示组件的UI结构
   * 使用水平布局排列来源标签和URL文本
   */
  build() {
    Row() {
      /**
       * 来源标签区域
       * @description 白色胶囊形状，包含返回图标和来源名称
       * 12px图标，10px字体，18px行高
       */
      Row() {
        /**
         * 返回图标
         * @description 12px宽度的向左返回图标
         * 表示内容来自网络，可点击返回或表示来源
         */
        Image($r("app.media.ic_public_return_left"))
          .width(12)
        
        /**
         * 来源名称
         * @description "笔趣阁"来源标识
         * 10px字体，500字重，18px行高
         */
        Text("笔趣阁")
          .lineHeight(18)
          .font({
            size: 10,
            weight: 500
          })
      }
      .margin({
        left: 3 // 左侧3px外边距
      })
      .borderRadius(40) // 40px圆角，创建胶囊形状
      .backgroundColor("white") // 白色背景
      .padding({
        top: 4,
        bottom: 4,
        left: 12,
        right: 12
      }) // 上下4px，左右12px内边距

      /**
       * URL文本区域
       * @description 显示完整的URL地址，使用省略号处理溢出
       * 浅灰色背景上的黑色文本
       */
      Text("https://www.qidian.com/book/10319406240624062")
        .textOverflow({ overflow: TextOverflow.Ellipsis }) // 溢出显示省略号
        .maxLines(1) // 单行显示
    }
    .backgroundColor("rgba(0, 0, 0, 0.06)") // 6%黑色背景，浅灰色
    .width("100%") // 100%宽度
    .height(30) // 固定30px高度
    .borderRadius(40) // 40px圆角，整体胶囊形状
  }
}

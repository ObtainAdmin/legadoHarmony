/**
 * AddDownloadDialog 组件 - 添加下载确认对话框
 * 
 * 功能概述：
 * 1. 显示下载操作成功的确认提示，告知用户内容已加入下载列表
 * 2. 提供"查看"按钮，允许用户快速跳转到下载管理页面
 * 3. 使用自定义对话框样式，提供良好的视觉反馈
 * 
 * 设计特点：
 * 1. 简洁布局：图标+文本+空白+操作按钮的水平排列
 * 2. 视觉层次：使用白色文字突出主要信息，橙色文字强调操作按钮
 * 3. 固定尺寸：56px高度，100%宽度，确保在不同设备上的一致性
 * 4. 深色背景：使用深灰色(#333333)背景，突出对话框内容
 * 
 * 使用场景：
 * 1. 用户添加内容到下载列表后的成功提示
 * 2. 需要快速确认操作结果的场景
 * 3. 提供后续操作入口的提示对话框
 * 
 * 组件结构：
 * - 确认图标：白色对勾图标，表示操作成功
 * - 提示文本：白色文字"已加入下载列表"
 * - 空白区域：使用Blank组件填充空间
 * - 操作按钮：橙色"查看"文字，可点击跳转
 * 
 * 注意事项：
 * 1. 需要配合CustomDialogController使用
 * 2. 对话框内容固定，不支持自定义文本
 * 3. 查看按钮的点击事件需要在父组件中处理
 */

@CustomDialog
export struct AddDownloadDialog {
  /**
   * 对话框控制器
   * @type {CustomDialogController}
   * @description 控制对话框的显示和隐藏
   * 可选属性，由调用方传入
   */
  controller?: CustomDialogController;

  /**
   * 构建对话框UI
   * @returns {void}
   * @description 构建下载确认对话框的UI结构
   * 使用水平布局，包含图标、文本和操作按钮
   */
  build() {
    Row({ space: 8 }) {
      /**
       * 确认图标
       * @description 白色对勾图标，24x24尺寸
       * 表示操作成功完成，提供视觉确认
       */
      Image($r('app.media.ic_public_confirm'))
        .width(24)
        .height(24)
        .fillColor('#FFFFFF')
      
      /**
       * 提示文本
       * @description 白色文字"已加入下载列表"
       * 14px字体，400字重，22px行高
       * 清晰传达操作结果
       */
      Text('已加入下载列表')
        .fontSize(14)
        .fontWeight(400)
        .lineHeight(22)
        .fontColor('#FFFFFF')
      
      /**
       * 空白区域
       * @description 使用Blank组件填充剩余空间
       * 权重为1，确保操作按钮靠右对齐
       */
      Blank(1)
      
      /**
       * 查看按钮
       * @description 橙色文字"查看"，可点击跳转到下载管理
       * 14px字体，400字重，22px行高
       * 使用橙色(#FF9500)突出显示可操作区域
       */
      Text('查看')
        .fontSize(14)
        .fontWeight(400)
        .lineHeight(22)
        .fontColor('#FF9500')
    }
    .height(56)
    .width("100%")
    .padding({
      left: 20,
      right: 20,
      top: 16,
      bottom: 16
    })
    .backgroundColor('#333333')
  }
}

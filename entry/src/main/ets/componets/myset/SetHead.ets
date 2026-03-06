/**
 * SetHead 组件 - 设置页面头部组件
 * 
 * 功能概述：
 * 1. 提供设置页面的标准头部布局，包含返回按钮、标题和右侧文本
 * 2. 实现页面导航功能，点击返回按钮返回上一页
 * 3. 支持自定义标题和右侧文本内容
 * 4. 使用弹性布局实现响应式头部设计
 * 
 * 设计特点：
 * 1. 简洁布局：左返回按钮、中标题、右文本的三段式设计
 * 2. 响应式宽度：使用百分比宽度适配不同屏幕
 * 3. 标准样式：统一的字体大小、颜色和字重
 * 4. 灵活配置：支持通过属性自定义标题和右侧文本
 * 
 * 使用场景：
 * 1. 设置页面的头部导航栏
 * 2. 需要标准头部布局的配置页面
 * 3. 包含返回功能和标题显示的页面
 * 
 * 组件结构：
 * - 返回按钮：左侧返回图标，点击返回上一页
 * - 标题区域：居中显示页面标题，支持自定义文本
 * - 右侧文本：可选的右侧文本区域，用于显示状态或操作
 * 
 * 注意事项：
 * 1. 右侧文本为可选功能，默认显示空字符串
 * 2. 使用固定百分比宽度确保布局一致性
 * 3. 需要正确导入路由模块实现导航功能
 */

import router from '@ohos.router'

@Component
export struct SetHead{


  /**
   * 页面标题文本
   * @type {string}
   * @default '标题'
   * @description 显示在头部中央的页面标题
   * 支持通过组件实例化时传入自定义标题
   */
  titleName: string ='标题'

  /**
   * 右侧文本内容
   * @type {string}
   * @default ''
   * @description 显示在头部右侧的可选文本内容
   * 可用于显示状态信息、操作按钮文本等
   * 可选属性，不设置时显示空字符串
   */
  rightString?: string = ''


  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建设置页面头部的UI结构
   * 使用Flex布局实现左中右三段式设计
   * 应用统一的样式和交互功能
   */
  build() {
    Flex({alignItems:ItemAlign.End}){
      /**
       * 返回按钮
       * @description 左侧返回图标，高度15px
       * 点击触发路由返回功能，导航到上一页面
       */
      Image($r('app.media.return_left'))
        .height(15)
        .onClick(()=>{
          router.back(); // 调用路由返回功能
        })

      /**
       * 标题区域
       * @description 居中显示页面标题，占用80%宽度
       * 使用16px字体大小，黑色文字，600字重
       * 确保标题在头部中央突出显示
       */
      Text(this.titleName).width('80%').textAlign(TextAlign.Center)
        .fontSize(16)
        .fontColor(Color.Black)
        .fontWeight(600)

      /**
       * 右侧文本区域
       * @description 显示可选的右侧文本，占用10%宽度
       * 居中对齐，用于显示状态信息或操作文本
       * 当rightString为空时不显示内容
       */
      Text(this.rightString).width('10%').textAlign(TextAlign.Center)
    }.padding({top:12,bottom:12}) // 上下各12px内边距

  }
}

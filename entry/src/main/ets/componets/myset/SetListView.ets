/**
 * SetListView 组件 - 设置列表项视图组件
 * 
 * 功能概述：
 * 1. 显示设置页面的列表项，支持多种配置选项的展示
 * 2. 提供两种显示模式：带底部文本的详细模式和简单文本模式
 * 3. 支持右侧显示箭头或开关控件，根据配置动态切换
 * 4. 实现圆角边框的可定制化，支持独立设置四个角的圆角
 * 5. 处理触摸事件传递，优化交互体验
 * 
 * 设计特点：
 * 1. 灵活布局：根据数据配置动态调整内容结构
 * 2. 视觉层次：使用不同字体大小和颜色区分主次信息
 * 3. 交互优化：通过触摸事件传递确保点击区域正确响应
 * 4. 样式定制：支持独立设置四个角的圆角半径
 * 
 * 使用场景：
 * 1. 设置页面的配置项列表
 * 2. 需要显示开关或箭头导航的列表项
 * 3. 包含主文本和辅助文本的复杂列表项
 * 
 * 组件结构：
 * - 左侧内容区域：主文本和可选的底部辅助文本
 * - 右侧操作区域：辅助文本、箭头图标或开关控件
 * - 容器样式：白色背景、内边距、可定制圆角
 * 
 * 注意事项：
 * 1. 需要正确处理ObjectLink数据绑定
 * 2. 触摸事件传递需要确保正确的组件ID
 * 3. 圆角设置需要四个参数分别控制
 */

import { SetList } from '../dataList/SetListGroup'

@Component
export struct SetListView{


  /**
   * 左上角圆角半径
   * @type {number}
   * @default 0
   * @description 控制列表项左上角的圆角大小
   * 用于实现自定义边框样式，特别是列表的第一项
   */
  topLeft: number = 0

  /**
   * 右上角圆角半径
   * @type {number}
   * @default 0
   * @description 控制列表项右上角的圆角大小
   * 用于实现自定义边框样式，特别是列表的第一项
   */
  topRight: number = 0

  /**
   * 左下角圆角半径
   * @type {number}
   * @default 0
   * @description 控制列表项左下角的圆角大小
   * 用于实现自定义边框样式，特别是列表的最后一项
   */
  bottomLeft: number = 0

  /**
   * 右下角圆角半径
   * @type {number}
   * @default 0
   * @description 控制列表项右下角的圆角大小
   * 用于实现自定义边框样式，特别是列表的最后一项
   */
  bottomRight: number = 0

  /**
   * 设置列表数据对象
   * @type {SetList}
   * @description 双向绑定的设置列表数据
   * 包含显示文本、开关状态、箭头显示等配置信息
   * @objectlink 使用@ObjectLink装饰器实现对象级别的双向数据绑定
   */
  @ObjectLink setList :SetList


  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建设置列表项的UI结构
   * 根据数据配置动态显示不同内容，支持复杂布局
   */
  build() {
    Row(){
      /**
       * 左侧内容区域
       * @description 根据是否有底部文本决定显示模式
       * 1. 详细模式：显示主文本和底部辅助文本
       * 2. 简单模式：只显示主文本
       */
      if (this.setList.bottomText != null && this.setList.bottomText.length > 0){
        /**
         * 详细模式 - 包含底部文本
         * @description 使用Column布局显示主文本和底部辅助文本
         * 主文本：14px字体，底部10px外边距
         * 底部文本：12px字体，灰色(#8C8C8C)文字
         * 占用75%宽度，确保右侧有足够空间
         */
        Column(){
          Text(this.setList.value).fontSize(14).margin({bottom:10}).width('100%')
          Text(this.setList.bottomText).fontSize(12).fontColor('#8C8C8C').width('100%')
        }.width('75%')

      }else {
        /**
         * 简单模式 - 只显示主文本
         * @description 显示16px字体的主文本
         * 设置ID为'text'，用于触摸事件传递
         */
        Text(this.setList.value).fontSize(16).id('text')
      }



      /**
       * 右侧操作区域
       * @description 包含可选的右侧文本和操作控件
       * 根据配置显示箭头图标或开关控件
       */
      Row(){
        /**
         * 右侧辅助文本
         * @description 可选的右侧文本，显示状态信息等
         * 使用12px字体，灰色(#8C8C8C)文字
         */
        if (this.setList.rightText != null && this.setList.rightText.length > 0){
          Text(this.setList.rightText).fontSize(12).fontColor('#8C8C8C')
        }

        /**
         * 操作控件区域
         * @description 根据showArrow配置显示不同控件
         * 1. 显示箭头：用于导航到下级页面
         * 2. 显示开关：用于启用/禁用功能
         */
        if (this.setList.showArrow){
          /**
           * 箭头图标
           * @description 25x25尺寸的右箭头图标
           * 表示该项可点击进入下级页面
           */
          Image($r("app.media.right")).size({width:25,height:25})
        }else {
          /**
           * 开关控件
           * @description 切换开关，橙色(#F60)选中状态
           * 绑定setList.toggleStatus状态，禁用悬停效果
           */
          Toggle({ type: ToggleType.Switch, isOn: this.setList.toggleStatus})
            .selectedColor("#F60").hoverEffect(HoverEffect.None)
        }
      }.alignItems(VerticalAlign.Center) // 垂直居中


    }.width("100%") // 100%宽度
    .backgroundColor(Color.White) // 白色背景
    .padding({ left:20,right:20,top:12,bottom:12 }) // 四周内边距
    .justifyContent(FlexAlign.SpaceBetween) // 左右两端对齐
    .alignItems(VerticalAlign.Center) // 垂直居中
    .borderRadius({topLeft:this.topLeft,topRight:this.topRight,bottomLeft:this.bottomLeft,bottomRight:this.bottomRight}) // 可定制圆角
    /**
     * 子组件触摸测试处理
     * @description 将触摸事件传递给ID为'text'的子组件处理
     * 如果子组件不处理，则由当前组件处理
     * 优化点击区域响应，确保整个列表项可点击
     */
    .onChildTouchTest((touchinfo) => {
      return { id:'text',strategy: TouchTestStrategy.FORWARD }
    })
  }
}

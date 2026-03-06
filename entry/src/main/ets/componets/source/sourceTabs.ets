/**
 * sourceTabs 组件 - 书源标签切换组件
 * 
 * 功能概述：
 * 1. 提供书源分类标签的切换功能，支持默认显示和隐藏书源
 * 2. 实现滑动指示器动画，点击标签时平滑移动
 * 3. 使用overlay技术实现标签文本和滑动背景的叠加
 * 4. 集成样式系统，统一标签的视觉样式
 * 
 * 设计特点：
 * 1. 叠加布局：使用overlay将标签文本叠加在滑动背景上
 * 2. 动画效果：200ms线性动画实现滑动指示器移动
 * 3. 状态管理：管理当前选中索引和滑动位置
 * 4. 样式复用：使用@Styles装饰器统一标签样式
 * 5. 响应式设计：根据点击位置计算滑动距离
 * 
 * 使用场景：
 * 1. 书源管理页面的分类标签切换
 * 2. 需要滑动指示器的标签切换组件
 * 3. 需要自定义样式的标签组件
 * 
 * 组件结构：
 * - 滑动背景：白色滑动指示器，50%宽度
 * - 标签文本：叠加在背景上的标签文本
 * - 容器：灰色背景的圆角容器
 * 
 * 注意事项：
 * 1. 需要正确处理点击位置和滑动距离的计算
 * 2. 动画效果需要平滑过渡
 * 3. 样式需要保持一致性和可复用性
 */

import CommonConstants from '../../common/constants/CommonConstants'
import { showMessage } from '../common/promptShow'
import { dataItem } from '../dataList/dataItem'

@Component
export struct sourceTabs{
  /**
   * 垂直外边距
   * @type {number}
   * @default 12
   * @description 标签组件的垂直外边距
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop marginY: number = 12
  
  /**
   * 书源列表
   * @type {dataItem[]}
   * @description 书源分类数据列表
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop sourceList:dataItem[]
  
  /**
   * 阅读索引
   * @type {number}
   * @description 当前选中的标签索引，与父组件双向绑定
   * @link 使用@Link装饰器实现与父组件的双向绑定
   */
  @Link read_index:number
  
  /**
   * 平移数值
   * @type {number}
   * @default 0
   * @description 滑动指示器的水平平移距离
   * @state 使用@State装饰器管理组件内部状态
   */
  @State translateNum:number=0
  
  /**
   * 平移X值
   * @type {number}
   * @default 120
   * @description 预留的平移X值，当前未使用
   * @state 使用@State装饰器管理组件内部状态
   */
  @State translateX:number=120
  /**
   * 阅读标签构建器
   * @returns {void}
   * @description 构建标签文本的UI，处理点击事件
   * 每个标签50%宽度，透明背景，居中对齐
   */
  @Builder read_builder(){
    Row(){
      ForEach(this.sourceList,(item:dataItem,index:number)=>{
        Row(){
          Text(item.title) // 标签文本
        }
        .width('50%') // 50%宽度
        .backgroundColor("rgba(0, 0, 0, 0)") // 透明背景
        .justifyContent(FlexAlign.Center) // 居中对齐
        .onClick((event)=>{
          /**
           * 标签点击事件
           * @description 计算滑动距离，更新选中索引
           * 根据点击位置和当前索引计算滑动方向
           */
          let x=event.target.area.position.x?.toString() // 获取点击位置X坐标
          if( this.read_index>index){ // 向左滑动
            if(x!=undefined){
              this.translateNum-=parseInt(x) // 向左平移
            }
            if(index==0){
              this.translateNum=0 // 回到起始位置
            }
          }else if( this.read_index<index){ // 向右滑动
            if(x!=undefined){
              this.translateNum=parseInt(x) // 向右平移
            }
          }
          this.read_index=index // 更新选中索引
        })
      })
    }.height(30) // 30px高度
    .width(CommonConstants.FULL_HEIGHT) // 100%宽度
  }
  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建书源标签组件的完整UI结构
   * 包含滑动背景和叠加的标签文本
   */
  build() {
    Row(){
      /**
       * 滑动指示器背景
       * @description 白色背景，50%宽度，30px高度
       * 根据translateNum进行水平平移
       */
      Row()
        .backgroundColor(Color.White) // 白色背景
        .stateStyles({
          normal:this.readListStyles // 应用样式
        })
        .size({width:"50%",height:30}) // 50%宽度，30px高度
        .translate({x:this.translateNum,y: 0,z: 0}) // 水平平移
        .animation({
          duration:200, // 200ms动画
          curve:Curve.Linear // 线性曲线
        })
    }
    /**
     * 叠加标签文本
     * @description 将标签文本叠加在滑动背景上
     * 居中对齐，无偏移
     */
    .overlay(this.read_builder(), {
      align: Alignment.Center, // 居中对齐
      offset: { x: 0, y:0} // 无偏移
    })
    .width(CommonConstants.FULL_HEIGHT) // 100%宽度
    .backgroundColor("rgba(0, 0, 0, 0.04)") // 4%黑色背景
    .stateStyles({
      normal:this.readListStyles // 应用样式
    })
    .padding(2) // 2px内边距
    .margin({top:this.marginY,bottom:this.marginY}) // 垂直外边距
  }

  /**
   * 阅读列表样式
   * @returns {void}
   * @description 定义标签组件的统一样式
   * 32px高度，30px圆角
   */
  @Styles readListStyles(){
    .height(32) // 32px高度
    .borderRadius(30) // 30px圆角
  }
}

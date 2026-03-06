/**
 * readTabs 组件 - 阅读统计选项卡组件
 * 
 * 功能概述：
 * 1. 提供阅读统计数据的选项卡切换功能，支持多个分类标签
 * 2. 实现平滑的选项卡切换动画，提升用户体验
 * 3. 使用覆盖层技术实现选项卡背景滑动效果
 * 4. 响应点击事件，动态计算并应用平移动画
 * 
 * 设计特点：
 * 1. 视觉层次：使用覆盖层(overlay)实现选项卡背景与文字的分离
 * 2. 动画效果：线性动画实现平滑的选项卡切换
 * 3. 响应式布局：33%等分宽度适配不同数量的选项卡
 * 4. 状态管理：跟踪当前选中索引和平移距离
 * 
 * 使用场景：
 * 1. 我的中心页面中的阅读统计选项卡
 * 2. 需要分类显示阅读数据的界面
 * 3. 多标签切换的统计视图
 * 
 * 组件结构：
 * - 背景层：灰色背景容器，包含滑动白色背景块
 * - 覆盖层：选项卡文字层，响应点击事件
 * - 滑动指示器：白色背景块，根据选中项滑动
 * 
 * 注意事项：
 * 1. 需要正确处理点击事件的位置计算
 * 2. 动画持续时间需要平衡性能和视觉效果
 * 3. 选项卡数量固定为3个（33%宽度）
 */

import CommonConstants from '../../common/constants/CommonConstants'
import { dataItem } from '../dataList/dataItem'

@Component
export struct readTabs{


  /**
   * 阅读选项卡数据列表
   * @type {dataItem[]}
   * @description 选项卡的数据源，包含标题等信息
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop read_list:dataItem[]
  
  /**
   * 当前选中的选项卡索引
   * @type {number}
   * @default 0
   * @description 记录当前激活的选项卡位置，从0开始计数
   */
  @State read_index:number=0
  
  /**
   * 平移距离
   * @type {number}
   * @default 0
   * @description 控制白色背景块的平移距离，实现滑动效果
   */
  @State translateNum:number=0
  
  /**
   * 初始平移距离
   * @type {number}
   * @default 120
   * @description 白色背景块的初始X轴平移距离
   * 注意：此变量在代码中声明但未使用，可能为预留功能
   */
  @State translateX:number=120
  /**
   * 阅读选项卡构建器
   * @returns {void}
   * @description 构建选项卡的文字层，包含所有选项卡标题
   * 使用覆盖层技术显示在背景层上方，响应点击事件
   * 
   * 设计特点：
   * 1. 等分布局：每个选项卡占33%宽度，支持3个选项卡
   * 2. 透明背景：使用rgba(0, 0, 0, 0)实现完全透明
   * 3. 点击计算：根据点击位置计算平移距离
   * 4. 居中显示：文字在选项卡内垂直水平居中
   */
  @Builder read_builder(){
    Row(){
      ForEach(this.read_list,(item:dataItem,index:number)=>{
        Row(){
          Text(item.title)
        }.backgroundColor("rgba(0, 0, 0, 0)") // 完全透明背景
        .justifyContent(FlexAlign.Center) // 内容居中
        .width("33%") // 等分宽度，支持3个选项卡
        .onClick((event)=>{
          /**
           * 选项卡点击事件处理
           * @description 计算点击位置并更新平移距离
           * 实现滑动指示器的平滑移动
           * 
           * 计算逻辑：
           * 1. 获取点击目标的X坐标
           * 2. 如果从右向左切换：减去当前位置
           * 3. 如果从左向右切换：设置为点击位置
           * 4. 点击第一个选项卡时重置为0
           * 5. 更新当前选中索引
           */
          let x=event.target.area.position.x?.toString()
          if( this.read_index>index){
            if(x!=undefined){
              this.translateNum-=parseInt(x)
            }
            if(index==0){
              this.translateNum=0
            }
          }else if( this.read_index<index){
            if(x!=undefined){
              this.translateNum=parseInt(x)
            }
          }
          this.read_index=index
        })
      })
    }.height(30)
    .width(CommonConstants.FULL_HEIGHT)
  }
  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建选项卡的主要UI结构
   * 使用覆盖层技术分离背景和文字，实现滑动效果
   * 
   * 结构层次：
   * 1. 底层：灰色背景容器，提供选项卡整体框架
   * 2. 中间层：白色滑动背景块，表示当前选中项
   * 3. 顶层：透明文字层，响应点击事件
   */
  build() {
    Row(){
      /**
       * 白色滑动背景块
       * @description 表示当前选中的选项卡背景
       * 使用translate实现滑动效果，根据translateNum更新位置
       * 应用200ms线性动画，确保平滑过渡
       */
      Row()
        .backgroundColor(Color.White)
        .stateStyles({
          normal:this.readListStyles
        }).size({width:"33%",height:30}) // 与选项卡等宽
        .translate({x:this.translateNum,y: 0,z: 0}) // 根据计算值平移
        .animation({
          duration:200, // 200毫秒动画时长
          curve:Curve.Linear // 线性动画曲线
        })
    }.overlay(this.read_builder(), {
      align: Alignment.Center, // 覆盖层居中
      offset: { x: 0, y:0}
    })
    .width(CommonConstants.FULL_HEIGHT)
    .backgroundColor("rgba(0, 0, 0, 0.04)") // 浅灰色背景
    .stateStyles({
      normal:this.readListStyles
    })
    .padding(3) // 3px内边距，创建边框效果
    .margin({top:12,bottom:12}) // 上下各12px外边距
  }

  /**
   * 选项卡样式定义
   * @returns {void}
   * @description 定义选项卡的通用样式
   * 使用@Styles装饰器创建可复用的样式规则
   * 
   * 样式特性：
   * 1. 固定高度：32px，确保视觉一致性
   * 2. 大圆角：30px圆角，创建胶囊形状
   * 3. 应用于背景容器和滑动块
   */
  @Styles readListStyles(){
    .height(32)
    .borderRadius(30)
  }
}

/**
 * exportRuleDialog 组件 - 导出规则对话框
 * 
 * 功能概述：
 * 1. 提供书籍规则导出功能，支持两种导出方式：复制链接和导出本地
 * 2. 提供两种有效期选项：2天有效和永久有效
 * 3. 使用主题系统适配应用的整体视觉风格
 * 4. 集成关闭按钮，提供便捷的对话框关闭操作
 * 5. 使用自定义对话框样式，提供良好的用户体验
 * 
 * 设计特点：
 * 1. 分层布局：使用Stack和Column实现内容与关闭按钮的分层
 * 2. 视觉层次：白色背景内容区域，深色背景关闭按钮
 * 3. 主题适配：使用主题颜色系统确保视觉一致性
 * 4. 圆角设计：16px内容圆角，200px按钮圆角，50px关闭按钮圆角
 * 5. 字体规范：使用项目定义的字体家族和大小
 * 
 * 使用场景：
 * 1. 阅读器页面中的规则导出功能
 * 2. 需要分享或备份阅读规则的场景
 * 3. 提供导出选项的自定义对话框
 * 
 * 组件结构：
 * - 内容区域：导出标题、有效期选项、操作按钮
 * - 关闭按钮：位于内容区域下方的圆形关闭按钮
 * - 选项区域：单选框选择有效期
 * - 操作区域：复制链接和导出本地按钮
 * 
 * 注意事项：
 * 1. 需要正确处理主题颜色的动态切换
 * 2. 单选框的选中状态需要正确管理
 * 3. 按钮点击事件需要在父组件中处理
 */

import CommonConstants from '../../common/constants/CommonConstants'
import { ThemeStorageKey } from '../../common/constants/Theme'
import { ThemeItem } from '../../common/model/Theme'

@CustomDialog
@Preview
export default struct exportRuleDialog{
  /**
   * 对话框控制器
   * @type {CustomDialogController}
   * @description 控制对话框的显示和隐藏
   * 可选属性，由调用方传入
   */
  controller?: CustomDialogController
  
  /**
   * 取消回调函数
   * @type {() => void}
   * @default () => {}
   * @description 对话框取消时的回调函数
   * 当前为空实现，可根据需要扩展
   */
  cancel: () => void = () => {
  }
  
  /**
   * 主题配置
   * @type {ThemeItem}
   * @description 从本地存储读取的主题配置
   * @storageprop 使用@StorageProp装饰器读取持久化存储的主题数据
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  /**
   * 构建对话框UI
   * @returns {void}
   * @description 构建导出规则对话框的UI结构
   * 使用Stack布局实现内容区域和关闭按钮的分层
   */
  build() {
      Stack(){
      Column(){
        /**
         * 内容区域
         * @description 使用Flex布局居中显示导出选项
         * 白色背景，16px圆角，24px内边距
         */
        Flex({
          justifyContent:FlexAlign.Center
        }){
          Column({
            space:12 // 12px间距
          }){
            /**
             * 对话框标题
             * @description "导出"标题，18px字体，500字重
             * 使用项目定义的PingFANG字体家族
             */
            Text('导出').font({
              size:18,
              weight:500,
              family: CommonConstants.FAMILY_PingFANG
            })

            /**
             * 有效期选项区域
             * @description 使用Row布局水平排列两个单选框选项
             * 8px间距，使用主题主色作为选中状态背景色
             */
            Row({
              space:8
            }){
              /**
               * 选项1：2天有效
               * @description 默认选中，20x20尺寸的单选框
               * 使用主题主色作为选中状态背景色
               */
              Row({
                space:8
              }){
                Radio({value:'default',group:'exportGroup'})
                  .radioStyle({
                    checkedBackgroundColor: this.theme.mainColor // 主题主色选中状态
                  })
                  .checked(true) // 默认选中
                  .onChange(()=>{
                    // 选项变化处理，当前为空实现
                  })
                  .width(20).height(20)
                Text('2天有效果').font({
                  size:14,
                  weight:400,
                  family:CommonConstants.FAMILY_PingFANG
                })
                  .fontColor($r('app.string.color_black_45')) // 45%黑色
              }

              /**
               * 选项2：永久有效
               * @description 未选中状态，20x20尺寸的单选框
               * 使用主题主色作为选中状态背景色
               */
              Row({
                space:8
              }){
                Radio({value:'default',group:'exportGroup'})
                  .radioStyle({
                    checkedBackgroundColor: this.theme.mainColor
                  })
                  .onChange(()=>{
                    // 选项变化处理，当前为空实现
                  })
                  .width(20).height(20)
                Text('永久有效').font({
                  size:14,
                  weight:400,
                  family:CommonConstants.FAMILY_PingFANG
                })
                  .fontColor($r('app.string.color_black_45'))
              }
            }
            /**
             * 复制链接按钮
             * @description 主题主色背景，白色文字
             * 172px宽度，22px行高，200px大圆角
             */
            Column(){
              Text('复制链接').font({
                size:14,
                weight:500,
                family:CommonConstants.FAMILY_PingFANG
              })
                .fontColor(Color.White) // 白色文字
                .textAlign(TextAlign.Center) // 居中对齐
                .width(172) // 固定宽度
                .lineHeight(22)
            }
            .margin({top:12}) // 顶部12px外边距
            .borderRadius(200) // 200px圆角，创建胶囊形状
            .padding({
              left:32,right:32,
              top:8,bottom:8
            }) // 左右32px，上下8px内边距
            .backgroundColor(this.theme.mainColor) // 主题主色背景

            /**
             * 导出本地按钮
             * @description 透明背景，45%黑色文字
             * 172px宽度，22px行高，200px大圆角
             */
            Column(){
              Text('导出本地').font({
                size:14,
                weight:500,
                family:CommonConstants.FAMILY_PingFANG
              })
                .fontColor($r('app.string.color_black_45')) // 45%黑色文字
                .textAlign(TextAlign.Center)
                .width(172)
                .lineHeight(22)
            }
            .borderRadius(200) // 200px圆角
          }
        }
        .borderRadius(16) // 16px圆角
        .backgroundColor(Color.White) // 白色背景
        .padding(24) // 24px内边距

        /**
         * 关闭按钮区域
         * @description 圆形关闭按钮，位于内容区域下方
         * 48x48尺寸，50px圆角，45%黑色背景
         */
        Column(){
          Image($r('app.media.close')).width(24).height(24).fillColor(Color.White)
        }
        .onClick(()=>{
          this.controller?.close() // 点击关闭对话框
        })
        .margin({
          top:16 // 顶部16px外边距
        })
        .borderRadius(50) // 50px圆角，创建圆形
        .justifyContent(FlexAlign.Center) // 内容居中
        .backgroundColor($r('app.string.color_black_45')) // 45%黑色背景
        .width(48).height(48) // 固定48x48尺寸
      }
      }
  }
}

/**
 * 应用欢迎页面 - 启动画面和初始化页面
 * 
 * 功能概述：
 * 1. 显示应用名称和欢迎标语
 * 2. 初始化应用数据
 * 3. 延迟1.5秒后自动跳转到主页面
 * 4. 清理路由历史记录
 * 
 * 页面流程：
 * 应用启动 → 显示欢迎页面 → 初始化数据 → 延迟跳转 → 进入主页面
 * 
 * 使用说明：
 * 此页面是用户启动应用后看到的第一个界面，主要用于品牌展示和初始化过程。
 */

import CommonConstants from '../common/constants/CommonConstants';
import router from '@ohos.router'; // 引入路由管理器
import { initAppData } from '../storage/appData';

@Entry
@Component
struct Index {
  /**
   * 欢迎页面结构体
   * 
   * 职责：
   * 1. 显示应用启动画面
   * 2. 初始化应用数据
   * 3. 管理页面跳转逻辑
   * 4. 清理路由历史记录
   */
  /** 应用名称，显示在欢迎页面上 */
  @State name: string = '开源阅读'
  
  /** 欢迎标语，显示在应用名称下方 */
  @State Tip: string = '享受阅读时光'
  /**
   * 页面显示时调用的生命周期方法
   * 
   * 功能：
   * 1. 初始化应用数据（从存储中加载配置等）
   * 2. 设置1.5秒延迟后自动跳转到主页面
   * 
   * 延迟跳转的目的：
   * - 给用户足够时间查看欢迎页面
   * - 确保应用数据初始化完成
   * - 提供流畅的启动体验
   */
  onPageShow() {
    // 初始化应用数据（用户配置、主题设置等）
    initAppData()
    
    // 1.5秒后自动跳转到主页面
    setTimeout(() => {
      // 使用路由管理器跳转到主页面
      router.pushUrl({
        url: 'pages/Index' // 主页面的URI
      });
    }, 1500); // 1500毫秒 = 1.5秒
  }
  /**
   * 页面隐藏时调用的生命周期方法
   * 
   * 功能：
   * 1. 清理路由历史记录，防止用户返回到欢迎页面
   * 
   * 设计考虑：
   * 欢迎页面通常只需要显示一次，跳转到主页面后不应允许返回
   * 这样可以提供更流畅的用户体验
   */
  onPageHide() {
    // 清理路由历史记录，防止用户通过返回键回到欢迎页面
    router.clear();
  }
  /**
   * 构建欢迎页面UI的主要方法
   * 
   * 布局结构：
   * 1. 全屏背景图片（应用启动图）
   * 2. 居中的文字区域，包含应用名称和欢迎标语
   * 
   * 设计特点：
   * - 使用Stack布局实现背景图覆盖
   * - 使用Column和Row实现文字居中排列
   * - 应用名称使用大号粗体，标语使用较小字体
   */
  build() {
    Stack() {
      // 全屏背景图片，使用应用启动图资源
      Image($r('app.media.ic_launcher_background'))
        .width(CommonConstants.FULL_WIDTH)  // 使用常量确保全屏宽度
        .height(CommonConstants.FULL_HEIGHT) // 使用常量确保全屏高度

      // 文字内容区域，居中显示
      Column() {
        Row() {
          // 应用名称：大号粗体文字
          Text(this.name)
            .fontSize(45)
            .fontWeight(FontWeight.Bold)
            .width(45)
          
          // 欢迎标语：较小字体，使用markAnchor进行微调位置
          Text(this.Tip)
            .fontSize(20)
            .fontWeight(FontWeight.Normal)
            .width(25)
            .markAnchor({ x: -20, y: -80 })  // 调整文字锚点位置
        }

      }
      .width('100%')  // 文字区域宽度100%
    }
    .height('100%')  // 整个页面高度100%
  }

}

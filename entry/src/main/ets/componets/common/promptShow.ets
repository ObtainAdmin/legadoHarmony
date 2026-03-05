/**
 * @file promptShow.ets
 * @description 提示显示工具函数
 * 
 * 功能概述：
 * 1. 提供统一的Toast提示显示功能
 * 2. 封装系统promptAction.showToast API
 * 3. 支持自定义提示消息和显示时长
 * 
 * 使用场景：
 * - 操作成功/失败的轻量提示
 * - 表单验证提示
 * - 网络状态提示
 * - 需要短暂显示提示信息的场景
 * 
 * 设计特点：
 * - 使用系统原生Toast组件
 * - 默认1秒显示时长
 * - 支持自定义显示时长
 * - 简洁的API设计
 * 
 * 技术特点：
 * - 使用@kit.ArkUI的promptAction模块
 * - 导出showMessage函数供全局使用
 * - 支持TypeScript类型检查
 * 
 * 与系统API的区别：
 * - 封装了默认参数（duration: 1000）
 * - 提供更简洁的调用方式
 * - 统一项目中的提示样式
 */

import { promptAction } from '@kit.ArkUI'

/**
 * @function showMessage
 * @description 显示Toast提示消息
 * 
 * 功能说明：
 * 1. 显示短暂的Toast提示
 * 2. 自动在指定时间后消失
 * 3. 支持自定义消息内容和显示时长
 * 
 * 参数说明：
 * @param {string} message - 要显示的提示消息内容
 * @param {number} [showDuration=1000] - 提示显示时长（毫秒），默认1000毫秒（1秒）
 * 
 * 实现原理：
 * - 调用promptAction.showToast系统API
 * - 传递message和duration参数
 * - 使用默认参数简化调用
 * 
 * 使用示例：
 * ```typescript
 * // 显示默认时长的提示
 * showMessage('操作成功');
 * 
 * // 显示2秒时长的提示
 * showMessage('正在加载...', 2000);
 * ```
 * 
 * 注意事项：
 * - Toast提示是轻量级的，不会阻塞用户操作
 * - 默认1秒时长适合大多数操作反馈场景
 * - 较长的消息可能需要更长的显示时间
 * - 连续调用会覆盖前一个提示
 * 
 * 系统限制：
 * - 依赖于ArkUI的promptAction模块
 * - 在不同设备上可能有不同的样式表现
 * - 显示位置通常为屏幕底部或中部
 * 
 * @returns {void}
 */
export function showMessage(message:string ,showDuration:number = 1000){
  promptAction.showToast({
    message: message,
    duration: showDuration,
  })
}

/**
 * 点击工具类 - 防止重复点击的工具类
 * 
 * @author 2008
 * @datetime 2024/8/21 20:18
 * @className: ClickUtils
 * 
 * 功能：防止按钮或UI元素在短时间内被重复点击，避免重复执行操作
 * 核心特性：
 *   1. 防抖机制：在指定延迟时间内只允许执行一次点击操作
 *   2. 可配置延迟：可以自定义防抖延迟时间
 *   3. 简单易用：提供统一的防点击接口
 * 使用场景：按钮点击、表单提交、导航跳转等需要防止重复操作的场景
 */
class ClickUtils {
  /**
   * 点击状态标志
   * 功能：标记当前是否正在处理点击事件
   * 默认值：false（未点击）
   * 作用：防止在点击处理期间再次触发点击事件
   */
  private isClicking: boolean = false;
  
  /**
   * 防止重复点击
   * 功能：执行点击操作，并在指定延迟时间内防止重复点击
   * @param onClickFunction - 点击时要执行的函数（默认空函数）
   * @param delay - 防抖延迟时间，单位毫秒（默认1000ms）
   * 使用场景：包装需要防重复点击的操作
   * 处理流程：
   *   1. 检查isClicking状态，如果为false（未点击）
   *   2. 设置isClicking为true（标记为点击中）
   *   3. 执行传入的点击函数
   *   4. 设置定时器，在delay毫秒后将isClicking重置为false
   *   5. 如果isClicking为true，则忽略本次点击
   */
  preventClick(onClickFunction: Function = () => {}, delay: number = 1000) {
    if (!this.isClicking) {
      this.isClicking = true;
      onClickFunction();
      setTimeout(() => {
        this.isClicking = false;
      }, delay);
    }
  }
}

// 创建单例实例并导出
const clickUtil = new ClickUtils();
export default clickUtil as ClickUtils;

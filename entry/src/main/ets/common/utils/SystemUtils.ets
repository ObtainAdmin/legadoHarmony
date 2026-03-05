/**
 * 系统工具类 - 提供系统相关功能的工具类
 * 
 * @author 2008
 * @datetime 2024/8/13 22:04
 * @className: SystemUtils
 * 
 * 功能：封装HarmonyOS系统能力调用，提供系统级功能接口
 * 核心特性：
 *   1. 浏览器启动：启动系统浏览器打开指定URL
 *   2. 能力调用：使用Want对象启动系统能力
 * 使用场景：打开外部链接、调用系统浏览器、系统能力调用
 */
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

class SystemUtils {
  /**
   * 启动浏览器能力
   * 功能：启动系统浏览器打开指定的URL
   * @param context - UIAbility上下文，用于启动能力
   * @param uri - 要打开的URL地址
   * 返回值：Promise<void> - 启动操作的结果
   * 使用场景：打开外部网页链接、调用系统浏览器
   * 处理流程：
   *   1. 创建Want对象，配置action为'ohos.want.action.viewData'
   *   2. 设置entities为['entity.system.browsable']，表示浏览器能力
   *   3. 设置uri为要打开的URL
   *   4. 调用context.startAbility启动浏览器能力
   *   5. 处理启动成功或失败的结果
   * Want对象说明：
   *   - action: 'ohos.want.action.viewData' - 表示查看数据的动作
   *   - entities: ['entity.system.browsable'] - 表示浏览器实体
   *   - uri: 要打开的URL地址
   */
  async startBrowsableAbility(context: common.UIAbilityContext, uri: string): Promise<void> {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: uri
    };
    context.startAbility(want)
      .then(() => {
        console.error('Start browsableAbility successfully.');
      })
      .catch((err: BusinessError) => {
        console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
      });
  }
}

// 创建单例实例并导出
const systemUtil = new SystemUtils();
export default systemUtil as SystemUtils;

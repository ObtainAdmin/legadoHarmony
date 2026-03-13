// HarmonyOS 基础能力导入
import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { BusinessError } from '@kit.BasicServicesKit';
import { AbilityConstant, Configuration, Want } from '@kit.AbilityKit';
import display from '@ohos.display';

// 数据库相关导入
import DbUtil from '../common/utils/DbUtil';
import DataBase from '../database'

// Web 组件导入
import { webview } from '@kit.ArkWeb';

// 主题管理导入
import { themeManager, ThemeManager } from '../common/utils/ThemeManager';

// 工具类导入
import { AppUtil } from '@pura/harmony-utils';
import { WindowAbility } from './WindowAbility';
import { deviceInfo } from '@kit.BasicServicesKit';
import BrightnessUtil from '../../common/utils/BrightnessUtil';

/**
 * 应用主入口 Ability 类
 * 
 * @description EntryAbility 是应用的主入口点，继承自 HarmonyOS 的 UIAbility 类。
 * 负责管理应用的生命周期、窗口初始化、数据库初始化、主题管理、屏幕适配等核心功能。
 * 
 * @extends UIAbility HarmonyOS 应用能力基类
 * 
 * @example
 * // EntryAbility 由系统自动创建和管理，开发者无需手动实例化
 * // 系统会在应用启动时自动调用 onCreate、onWindowStageCreate 等方法
 */
export default class EntryAbility extends UIAbility {
  /**
   * 当前断点值，用于响应式布局
   * @private
   * @type {string}
   * @description 记录当前窗口尺寸对应的断点值，可能的值包括：'xs', 'sm', 'md', 'lg'
   */
  private curBp: string = ''

  /**
   * 根据当前窗口尺寸更新断点值
   * 
   * @description 该方法根据窗口宽度计算对应的响应式布局断点，并将结果存储到 AppStorage 中。
   * 断点定义如下：
   * - xs: 窗口宽度 < 320vp (超小屏幕)
   * - sm: 320vp ≤ 窗口宽度 < 600vp (小屏幕)
   * - md: 600vp ≤ 窗口宽度 < 840vp (中等屏幕)
   * - lg: 窗口宽度 ≥ 840vp (大屏幕)
   * 
   * @private
   * @param {number} windowWidth - 当前窗口宽度（单位：px）
   * @returns {void}
   * 
   * @example
   * // 当窗口尺寸变化时调用此方法
   * this.updateBreakpoint(1080); // 假设窗口宽度为1080px
   */
  private updateBreakpoint(windowWidth: number): void {
    // 将长度的单位由px换算为vp（虚拟像素），以适应不同屏幕密度
    let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels
    let newBp: string = ''
    
    // 根据窗口宽度确定断点值
    if (windowWidthVp < 320) {
      newBp = 'xs'  // 超小屏幕
    } else if (windowWidthVp < 600) {
      newBp = 'sm'  // 小屏幕
    } else if (windowWidthVp < 840) {
      newBp = 'md'  // 中等屏幕
    } else {
      newBp = 'lg'  // 大屏幕
    }
    
    // 只有当断点值发生变化时才更新存储
    if (this.curBp !== newBp) {
      this.curBp = newBp
      // 使用状态变量记录当前断点值，供UI组件使用
      AppStorage.setOrCreate('currentBreakpoint', this.curBp)
    }
  }

  /**
   * 应用创建时调用的生命周期方法
   * 
   * @description 当应用首次启动时，系统会调用此方法。在此方法中完成应用级别的初始化工作，
   * 包括Web引擎初始化、工具类初始化和窗口能力上下文初始化。
   * 
   * @param {Want} want - 启动Ability时传递的Want对象，包含启动信息
   * @param {AbilityConstant.LaunchParam} launchParam - 启动参数，包含启动模式等信息
   * @returns {void}
   * 
   * @example
   * // 系统自动调用，无需手动调用
   * // 当用户点击应用图标启动应用时，系统会触发此方法
   */
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // 初始化Web引擎，为后续使用Web组件做准备
    webview.WebviewController.initializeWebEngine()
    
    // 记录应用创建日志
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    
    // 初始化应用工具类，传递当前上下文
    AppUtil.init(this.context);
    
    // 初始化窗口能力单例的上下文
    WindowAbility.getInstance().initContext(this.context)
  }

  /**
   * 应用销毁时调用的生命周期方法
   * 
   * @description 当应用被完全销毁时，系统会调用此方法。在此方法中可以执行资源释放、
   * 数据保存等清理工作。注意：此方法调用后，应用进程将被终止。
   * 
   * @returns {void}
   * 
   * @example
   * // 系统自动调用，无需手动调用
   * // 当用户强制停止应用或系统需要回收资源时，系统会触发此方法
   */
  onDestroy() {
    // 记录应用销毁日志，用于调试和监控
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  /**
   * 窗口阶段创建时调用的生命周期方法
   * 
   * @description 当应用的窗口阶段创建时，系统会调用此方法。这是应用UI初始化的核心方法，
   * 包含了数据库初始化、窗口设置、屏幕适配、文件路径配置、主题初始化等关键操作。
   * 此方法执行后，应用的UI界面将开始显示。
   * 
   * @param {window.WindowStage} windowStage - 窗口阶段对象，用于管理应用窗口
   * @returns {void}
   * 
   * @example
   * // 系统自动调用，无需手动调用
   * // 在应用启动流程中，此方法在onCreate之后被调用
   */
  onWindowStageCreate(windowStage: window.WindowStage) {
    // 1. 初始化数据库 - 异步创建数据库和相关数据表
    DbUtil.initDB(this.context).then(() => {
      DataBase.initAllTable() // 初始化所有数据表结构
    })
    
    // 2. 设置窗口阶段到WindowAbility单例，供其他模块使用
    WindowAbility.getInstance().setWindowStage(windowStage);
    
    // 3. 初始化窗口处理流程（避让区域、系统栏等）
    this.initWindowProcess(windowStage);
    
    // 4. 获取本地文件存储路径并存储到AppStorage中
    const pathDir = this.context.filesDir;
    AppStorage.setOrCreate('pathDir', pathDir); // 应用文件目录
    
    // 5. 配置书源文件存储路径
    AppStorage.setOrCreate('pathBookSource', pathDir + '/bookSource.json');
    
    // 6. 记录窗口阶段创建日志
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    
    // 7. 获取主窗口并进行一系列窗口设置
    windowStage.getMainWindow((err, windowClass) => {
      if (err.code) {
        // 如果获取主窗口失败，记录错误日志并返回
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return
      }
      
      // 7.1 初始化屏幕亮度设置
      BrightnessUtil.initWindow(windowClass);

      // 7.2 设置窗口为全屏模式
      windowClass.setWindowLayoutFullScreen(true)
        .then(() => {
          console.info('Succeeded in setting the window layout to full-screen mode.');
        })
        .catch((err: BusinessError) => {
          console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
        });
      
      // 7.3 获取导航栏避让区域高度（底部遮挡区域）
      let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 导航栏类型
      let avoidArea = windowClass.getWindowAvoidArea(type);
      let bottomRectHeight = avoidArea.bottomRect.height;
      AppStorage.setOrCreate('bottomRectHeight', px2vp(bottomRectHeight)); // 转换为虚拟像素并存储

      // 7.4 获取状态栏避让区域高度（顶部遮挡区域）
      type = window.AvoidAreaType.TYPE_SYSTEM; // 系统栏类型
      avoidArea = windowClass.getWindowAvoidArea(type);
      let topRectHeight = avoidArea.topRect.height;
      AppStorage.setOrCreate('topRectHeight', px2vp(topRectHeight)); // 转换为虚拟像素并存储

      // 7.5 获取手机屏幕的原始高度和宽度（单位：px）
      let defaultDisplay = display.getDefaultDisplaySync()
      let WindowHeight = defaultDisplay.height
      let WindowWidth = defaultDisplay.width

      // 7.6 将屏幕尺寸转换为虚拟像素并存储到AppStorage中
      AppStorage.setOrCreate('WindowHeight', px2vp(WindowHeight));
      AppStorage.setOrCreate('WindowWidth', px2vp(WindowWidth));

      // 7.7 计算总避让区域高度（状态栏+导航栏）
      let avoidAreaSys = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      let navi = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      let total = avoidAreaSys.topRect.height + navi.bottomRect.height;
      AppStorage.setOrCreate('avoidHeight', total); // 总避让高度（px）
      AppStorage.setOrCreate('stateHeight', px2vp(avoidAreaSys.topRect.height)); // 状态栏高度（vp）
      
      // 7.8 注册避让区域变化监听函数，动态响应系统栏变化
      windowClass.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          // 状态栏高度变化
          let topRectHeight = data.area.topRect.height;
          AppStorage.setOrCreate('topRectHeight', px2vp(topRectHeight));
        } else if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          // 导航栏高度变化
          let bottomRectHeight = data.area.bottomRect.height;
          AppStorage.setOrCreate('bottomRectHeight', px2vp(bottomRectHeight));
        }
      });
    })

    // 8. 加载欢迎页面内容
    windowStage.loadContent('/pages/welcomePage'.slice(1), (err, data) => {
      if (err.code) {
        // 如果加载内容失败，记录错误日志
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      
      // 9. 初始化主题管理器
      themeManager.init()
      
      // 10. 记录内容加载成功日志
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  /**
   * 配置更新时调用的生命周期方法
   * 
   * @description 当系统配置发生变化时（如深色/浅色模式切换、语言切换、字体大小变化等），
   * 系统会调用此方法。在此方法中可以响应配置变化，更新应用状态。
   * 
   * @param {Configuration} newConfig - 新的配置对象，包含更新后的系统配置信息
   * @returns {void}
   * 
   * @example
   * // 系统自动调用，无需手动调用
   * // 当用户在系统设置中切换深色/浅色模式时，系统会触发此方法
   */
  onConfigurationUpdate(newConfig: Configuration): void {
    // 更新颜色模式到AppStorage中，供UI组件响应主题变化
    AppStorage.setOrCreate('colorMode', newConfig.colorMode);
  }

  /**
   * 初始化窗口处理流程
   * 
   * @description 该方法负责初始化窗口相关的各种设置，包括避让区域、系统栏属性、
   * 全屏模式、设备方向（针对平板设备）和窗口大小。这些设置确保应用在不同设备上
   * 有良好的显示效果和用户体验。
   * 
   * @param {window.WindowStage} windowStage - 窗口阶段对象，用于获取主窗口
   * @returns {void}
   * 
   * @example
   * // 在onWindowStageCreate方法中调用
   * this.initWindowProcess(windowStage);
   */
  initWindowProcess(windowStage: window.WindowStage): void {
    // 1. 获取主窗口并初始化避让区域和系统栏属性
    windowStage.getMainWindow((err, windowClass: window.Window) => {
      // 1.1 初始化避让区域（状态栏、导航栏等）
      WindowAbility.getInstance().initAvoidArea(windowClass);
      
      // 1.2 设置系统栏属性（状态栏文字颜色）
      let systemBarProperties: window.SystemBarProperties = {
        // 根据当前颜色模式设置状态栏文字颜色：深色模式用白色，浅色模式用黑色
        statusBarContentColor: this.context.config.colorMode ? '#000000' : '#FFFFFF'
      };
      windowClass.setWindowSystemBarProperties(systemBarProperties);
    });
    
    // 2. 设置窗口为全屏模式（隐藏系统栏）
    WindowAbility.getInstance().setWindowLayoutFullScreen(true);
    
    // 3. 针对平板设备设置方向限制
    if (deviceInfo.deviceType === 'tablet') {
      // 限制为自动旋转但有限制（AUTO_ROTATION_RESTRICTED）
      WindowAbility.getInstance().setOrientation(windowStage, window.Orientation.AUTO_ROTATION_RESTRICTED);
    }
    
    // 4. 初始化窗口大小，并注册窗口大小变化监听
    WindowAbility.getInstance().initWindowSize();
  }

  /**
   * 窗口阶段销毁时调用的生命周期方法
   * 
   * @description 当应用的窗口阶段被销毁时，系统会调用此方法。在此方法中可以执行
   * UI相关资源的释放工作，如取消事件监听、清理UI状态等。
   * 
   * @returns {void}
   * 
   * @example
   * // 系统自动调用，无需手动调用
   * // 当应用进入后台或窗口被销毁时，系统会触发此方法
   */
  onWindowStageDestroy() {
    // 记录窗口阶段销毁日志
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  /**
   * 应用切换到前台时调用的生命周期方法
   * 
   * @description 当应用从后台切换到前台时，系统会调用此方法。在此方法中可以执行
   * 恢复UI状态、重新开始动画、恢复数据加载等操作。
   * 
   * @returns {void}
   * 
   * @example
   * // 系统自动调用，无需手动调用
   * // 当用户从多任务界面切换回应用时，系统会触发此方法
   */
  onForeground() {
    // 记录应用切换到前台日志
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  /**
   * 应用切换到后台时调用的生命周期方法
   * 
   * @description 当应用从前台切换到后台时，系统会调用此方法。在此方法中可以执行
   * 暂停动画、保存数据、释放非必要资源等操作以节省系统资源。
   * 
   * @returns {void}
   * 
   * @example
   * // 系统自动调用，无需手动调用
   * // 当用户按下Home键或切换到其他应用时，系统会触发此方法
   */
  onBackground() {
    // 记录应用切换到后台日志
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}

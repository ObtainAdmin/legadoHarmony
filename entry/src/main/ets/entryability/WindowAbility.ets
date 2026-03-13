// HarmonyOS 窗口和显示相关导入
import { window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 日志标签常量，用于标识WindowAbility相关的日志
 * @constant {string}
 */
const TAG = 'WindowAbility';

/**
 * 窗口能力管理类（单例模式）
 * 
 * @description WindowAbility 是一个单例类，负责管理应用窗口的各种操作，
 * 包括避让区域处理、窗口大小管理、系统栏控制、方向设置等。
 * 该类提供了统一的窗口管理接口，供EntryAbility和其他组件使用。
 * 
 * @example
 * // 获取WindowAbility单例实例
 * const windowAbility = WindowAbility.getInstance();
 * 
 * // 初始化上下文
 * windowAbility.initContext(context);
 * 
 * // 设置窗口阶段
 * windowAbility.setWindowStage(windowStage);
 */
export class WindowAbility {
  /**
   * 单例实例（静态只读）
   * @private
   * @static
   * @readonly
   * @type {WindowAbility}
   */
  private static readonly INSTANCE: WindowAbility = new WindowAbility();
  
  /**
   * 应用上下文
   * @private
   * @type {common.UIAbilityContext | null}
   */
  private context: common.UIAbilityContext | null = null;
  
  /**
   * 窗口阶段对象
   * @private
   * @type {window.WindowStage | null}
   */
  private windowStage: window.WindowStage | null = null;
  
  /**
   * 窗口对象
   * @private
   * @type {window.Window | null}
   */
  private windowClass: window.Window | null = null;
  
  /**
   * 窗口状态类型
   * @private
   * @type {window.WindowStatusType | null}
   */
  private windowType: window.WindowStatusType | null = null;

  /**
   * 私有构造函数，确保单例模式
   * @private
   */
  private constructor() {
  }

  /**
   * 获取WindowAbility单例实例
   * 
   * @description 这是获取WindowAbility实例的唯一方式，确保整个应用中只有一个实例。
   * 
   * @static
   * @returns {WindowAbility} WindowAbility单例实例
   * 
   * @example
   * const windowAbility = WindowAbility.getInstance();
   */
  public static getInstance(): WindowAbility {
    return WindowAbility.INSTANCE;
  }

  /**
   * 初始化应用上下文
   * 
   * @description 设置WindowAbility的应用上下文，这是执行窗口操作的前提条件。
   * 通常在EntryAbility的onCreate方法中调用。
   * 
   * @param {common.UIAbilityContext} context - 应用上下文对象
   * @returns {void}
   * 
   * @example
   * // 在EntryAbility的onCreate方法中调用
   * WindowAbility.getInstance().initContext(this.context);
   */
  initContext(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 设置窗口阶段
   * 
   * @description 设置当前窗口阶段对象，用于后续的窗口操作。
   * 窗口阶段是窗口管理的基础，包含了窗口的生命周期信息。
   * 
   * @param {window.WindowStage} windowStage - 窗口阶段对象
   * @returns {void}
   * 
   * @example
   * // 在EntryAbility的onWindowStageCreate方法中调用
   * WindowAbility.getInstance().setWindowStage(windowStage);
   */
  setWindowStage(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
  }

  /**
   * 获取窗口阶段
   * 
   * @description 获取当前设置的窗口阶段对象。如果尚未设置，则返回null。
   * 
   * @returns {window.WindowStage | null} 窗口阶段对象或null
   * 
   * @example
   * const windowStage = WindowAbility.getInstance().getWindowStage();
   * if (windowStage) {
   *   // 执行窗口操作
   * }
   */
  getWindowStage(): window.WindowStage | null {
    return this.windowStage;
  }

  /**
   * 初始化避让区域参数
   * 
   * @description 该方法用于初始化状态栏和导航栏的避让区域参数。
   * 避让区域是指系统UI（状态栏、导航栏）占据的屏幕区域，应用需要避开这些区域显示内容。
   * 该方法会根据设备类型（手机、平板、2合1设备）设置不同的避让区域高度。
   * 
   * @async
   * @param {window.Window} mainWindow - 主窗口对象，用于获取避让区域信息
   * @returns {Promise<void>}
   * 
   * @example
   * // 在窗口初始化时调用
   * await WindowAbility.getInstance().initAvoidArea(mainWindow);
   */
  async initAvoidArea(mainWindow: window.Window): Promise<void> {
    // 记录方法开始日志
    hilog.info(0x0000, TAG, 'initAvoidArea start');
    
    // 1. 初始化默认值（避免在获取系统信息前出现未定义错误）
    AppStorage.setOrCreate<number>('statusBarHeight', 36);        // 默认状态栏高度
    AppStorage.setOrCreate<number>('navigationAiBarHeight', 28);  // 默认导航栏高度
    
    // 2. 获取默认显示信息，用于像素密度换算
    const defaultDisplay = display.getDefaultDisplaySync();
    let scaledDensity = (defaultDisplay.scaledDensity > 0) ? defaultDisplay.scaledDensity : 1;
    
    // 3. 获取系统避让区域（状态栏）
    const systemArea: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    // 4. 获取导航栏避让区域
    const navArea: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    
    // 5. 处理状态栏避让区域
    if (systemArea) {
      // 5.1 计算实际状态栏高度（考虑像素密度）
      const statusBarHeight = systemArea.topRect.height / scaledDensity;
      hilog.info(0x0000, TAG, "initAvoidArea statusBarHeight: " + statusBarHeight);
      
      // 5.2 存储状态栏高度到AppStorage
      AppStorage.setOrCreate<number>('statusBarHeight', statusBarHeight);

      // 5.3 根据设备类型设置顶部高度（用于特定UI组件）
      if (deviceInfo.deviceType === 'tablet') {
        // 平板设备使用固定高度56
        AppStorage.setOrCreate<number>("Paf.TopHeight", 56);
      } else if (deviceInfo.deviceType === '2in1') {
        // 2合1设备不使用顶部高度
        AppStorage.setOrCreate<number>("Paf.TopHeight", 0);
      } else {
        // 手机设备使用实际状态栏高度
        AppStorage.setOrCreate<number>("Paf.TopHeight", systemArea.topRect.height);
      }
    }
    
    // 6. 处理导航栏避让区域
    if (navArea) {
      // 6.1 计算实际导航栏高度（考虑像素密度）
      const navigationAiBarHeight = navArea.bottomRect.height / scaledDensity;
      hilog.info(0x0000, TAG, "initAvoidArea navigationAiBarHeight: " + navigationAiBarHeight);
      
      // 6.2 存储导航栏高度到AppStorage
      AppStorage.setOrCreate<number>('navigationAiBarHeight', navigationAiBarHeight);

      // 6.3 根据设备类型设置导航栏高度
      if (deviceInfo.deviceType === 'tablet') {
        // 平板设备使用实际导航栏高度
        AppStorage.setOrCreate<number>("NavigationBarHeight", navArea.bottomRect.height);
      } else if (deviceInfo.deviceType === '2in1') {
        // 2合1设备不使用导航栏高度
        AppStorage.setOrCreate<number>("NavigationBarHeight", 0);
      } else {
        // 手机设备使用实际导航栏高度
        AppStorage.setOrCreate<number>("NavigationBarHeight", navArea.bottomRect.height);
      }
    }
    
    // 7. 记录方法结束日志
    hilog.info(0x0000, TAG, 'initAvoidArea end');
  }

  /**
   * 初始化窗口大小
   * 
   * @description 该方法用于获取当前窗口的大小，并将窗口宽度和高度存储到AppStorage中。
   * 同时，它会注册窗口大小变化、窗口状态变化和窗口矩形变化的事件监听。
   * 这是窗口适配和响应式布局的基础。
   * 
   * @returns {void}
   * 
   * @example
   * // 在窗口初始化时调用
   * WindowAbility.getInstance().initWindowSize();
   */
  initWindowSize(): void {
    // 1. 获取最后一个窗口（当前活动窗口）
    window.getLastWindow(this.context, (err, windowClass) => {
      if (err.code) {
        // 如果获取窗口失败，记录错误日志并返回
        hilog.error(0x0000, TAG, 'setWindowWidth getLastWindow failed, error is: ' + JSON.stringify(err));
        return;
      }
      
      // 2. 获取窗口属性（包括窗口矩形区域）
      let windowProperty = windowClass.getWindowProperties();
      
      // 3. 将窗口宽度和高度存储到AppStorage中，供UI组件使用
      AppStorage.setOrCreate<number>('windowWidth', windowProperty.windowRect.width);
      AppStorage.setOrCreate<number>('windowHeight', windowProperty.windowRect.height);
      
      // 4. 保存窗口对象引用，供后续使用
      this.windowClass = windowClass;
      
      // 5. 注册窗口大小变化事件监听
      this.onWindowSizeChange();
      
      // 6. 注释掉的窗口状态变化监听（可根据需要启用）
      // this.onWindowStatusChange();
      
      // 7. 注册窗口矩形变化事件监听
      this.onWindowRectChange();
    });
  }

  /**
   * 窗口状态变化事件处理
   * 
   * @description 私有方法，用于监听窗口状态变化事件。当窗口状态发生变化时
   * （如全屏、分屏、浮动窗口等），重新初始化避让区域并更新导航栏高度。
   * 
   * @private
   * @returns {void}
   */
  private onWindowStatusChange(): void {
    if (!this.windowClass) {
      return;
    }
    
    // 注册窗口状态变化事件监听
    this.windowClass.on('windowStatusChange', (type: window.WindowStatusType) => {
      // 1. 保存当前窗口状态类型
      this.windowType = type;
      
      // 2. 记录状态变化日志
      hilog.info(0x0000, TAG, 'onWindowStatusChange type: ', JSON.stringify(type));
      
      // 3. 重新初始化避让区域（状态栏、导航栏高度）
      this.initAvoidArea(this.windowClass!);
      
      // 4. 如果是浮动窗口状态，将导航栏高度设置为0
      if (type === window.WindowStatusType.FLOATING) {
        AppStorage.setOrCreate<number>("NavigationBarHeight", 0);
      }
    })
  }

  /**
   * 窗口矩形变化事件处理
   * 
   * @description 私有方法，用于监听窗口矩形区域变化事件。当窗口矩形发生变化时，
   * 如果窗口处于分屏或全屏状态，重新获取导航栏高度。
   * 
   * @private
   * @returns {void}
   */
  private onWindowRectChange(): void {
    if (!this.windowClass) {
      return;
    }
    
    // 注册窗口矩形变化事件监听
    this.windowClass.on('windowRectChange', (option) => {
      // 只有当窗口处于分屏或全屏状态时才重新获取导航栏高度
      if (this.windowType === window.WindowStatusType.SPLIT_SCREEN ||
        this.windowType === window.WindowStatusType.FULL_SCREEN) {
        // 重新获取导航栏高度
        this.setNavigationBar();
      }
    })
  }

  /**
   * 设置导航栏高度
   * 
   * @description 私有方法，用于获取当前导航栏避让区域的高度，并存储到AppStorage中。
   * 该方法通常在窗口矩形变化或窗口状态变化时调用。
   * 
   * @private
   * @returns {void}
   */
  private setNavigationBar(): void {
    if (!this.windowClass) {
      return;
    }
    
    // 1. 获取导航栏避让区域
    const nav: window.AvoidArea = this.windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    
    // 2. 记录导航栏避让区域信息
    hilog.info(0x0000, TAG, 'setNavigationBar avoidArea: ', JSON.stringify(nav));
    
    // 3. 如果存在导航栏避让区域，将其高度存储到AppStorage中
    if (nav) {
      AppStorage.setOrCreate<number>("NavigationBarHeight", nav.bottomRect.height);
    }
  }

  /**
   * 设置窗口全屏布局
   * 
   * @description 该方法用于设置窗口是否为全屏模式。在全屏模式下，系统栏（状态栏和导航栏）
   * 会被隐藏，应用可以充分利用整个屏幕空间。注意：2合1设备不支持全屏模式。
   * 
   * @async
   * @param {boolean} isFullScreen - 是否设置为全屏模式（true: 全屏, false: 非全屏）
   * @returns {Promise<void>}
   * 
   * @example
   * // 设置窗口为全屏模式
   * await WindowAbility.getInstance().setWindowLayoutFullScreen(true);
   * 
   * // 退出全屏模式
   * await WindowAbility.getInstance().setWindowLayoutFullScreen(false);
   */
  async setWindowLayoutFullScreen(isFullScreen: boolean): Promise<void> {
    // 1. 2合1设备不支持全屏模式，直接返回
    if (deviceInfo.deviceType === '2in1') {
      return;
    }
    
    // 2. 获取最后一个窗口（当前活动窗口）并设置全屏模式
    window.getLastWindow(this.context).then(async (wnd: window.Window) => {
      await wnd.setWindowLayoutFullScreen(isFullScreen);
    });
  }

  /**
   * 窗口大小变化事件处理
   * 
   * @description 该方法用于监听窗口大小变化事件。当窗口大小发生变化时（如窗口调整、旋转等），
   * 会更新AppStorage中的窗口宽度和高度，并执行可选的回调函数。
   * 这是实现响应式布局的关键。
   * 
   * @param {() => void} [callback] - 可选的回调函数，在窗口大小变化时执行
   * @returns {void}
   * 
   * @example
   * // 注册窗口大小变化监听，并指定回调函数
   * WindowAbility.getInstance().onWindowSizeChange(() => {
   *   console.log('窗口大小已变化，更新UI布局');
   * });
   */
  onWindowSizeChange(callback?: () => void): void {
    if (!this.windowClass) {
      return;
    }
    
    try {
      // 注册窗口大小变化事件监听
      this.windowClass.on('windowSizeChange', (size) => {
        // 1. 记录窗口大小变化日志
        hilog.info(0x0000, TAG,
          'onWindowSizeChange windowSizeChange size is: ' + JSON.stringify(size));
        
        // 2. 更新AppStorage中的窗口宽度和高度
        AppStorage.setOrCreate<number>('windowWidth', size.width);
        AppStorage.setOrCreate<number>('windowHeight', size.height);
        
        // 3. 如果提供了回调函数，则执行
        callback && callback();
      });
    } catch (exception) {
      // 捕获并记录异常
      hilog.error(0x0000, TAG,
        'onWindowSizeChange failed, error is ' + JSON.stringify(exception));
    }
  }

  /**
   * 设置窗口方向
   * 
   * @description 该方法用于设置窗口的 preferred orientation（首选方向）。
   * 可以控制窗口的旋转行为，如锁定为竖屏、横屏，或允许自动旋转等。
   * 通常用于平板设备或需要特定方向的应用场景。
   * 
   * @param {window.WindowStage} windowStage - 窗口阶段对象
   * @param {window.Orientation} orientation - 窗口方向设置
   * @returns {void}
   * 
   * @example
   * // 锁定为竖屏方向
   * WindowAbility.getInstance().setOrientation(windowStage, window.Orientation.PORTRAIT);
   * 
   * // 锁定为横屏方向
   * WindowAbility.getInstance().setOrientation(windowStage, window.Orientation.LANDSCAPE);
   * 
   * // 允许自动旋转
   * WindowAbility.getInstance().setOrientation(windowStage, window.Orientation.AUTO_ROTATION);
   */
  setOrientation(windowStage: window.WindowStage, orientation: window.Orientation): void {
    // 1. 获取主窗口
    windowStage.getMainWindow().then((win) => {
      // 2. 设置首选方向
      win.setPreferredOrientation(orientation).then((data) => {
        // 成功设置方向，记录日志
        hilog.info(0x0000, TAG, 'setOrientation succeeded, error is: ' + JSON.stringify(data));
      }).catch((err: Error) => {
        // 设置方向失败，记录错误日志
        hilog.error(0x0000, TAG, 'setOrientation setPreferredOrientation failed. error is: ' + JSON.stringify(err));
      });
    }).catch((err: Error) => {
      // 获取主窗口失败，记录错误日志
      hilog.error(0x0000, TAG, 'setOrientation getMainWindow failed, error is ' + JSON.stringify(err));
    });
  }

  /**
   * 切换系统栏可见性
   * 
   * @description 该方法用于控制状态栏和/或导航栏的显示与隐藏。
   * 可以动态地启用或禁用系统栏，同时更新避让区域监听器的状态。
   * 这对于需要全屏沉浸式体验的应用场景非常有用。
   * 
   * @param {Array<'status' | 'navigation'>} names - 要控制的系统栏类型数组
   *   - 'status': 控制状态栏
   *   - 'navigation': 控制导航栏
   *   - 空数组: 隐藏所有系统栏
   *   - 包含元素的数组: 显示指定的系统栏
   * @param {Context | undefined} windowContext - 窗口上下文，用于获取窗口对象
   * @returns {void}
   * 
   * @example
   * // 隐藏所有系统栏（全屏模式）
   * WindowAbility.getInstance().toggleWindowSystemBar([], context);
   * 
   * // 只显示状态栏
   * WindowAbility.getInstance().toggleWindowSystemBar(['status'], context);
   * 
   * // 显示状态栏和导航栏
   * WindowAbility.getInstance().toggleWindowSystemBar(['status', 'navigation'], context);
   */
  toggleWindowSystemBar(names: Array<'status' | 'navigation'>, windowContext: Context | undefined): void {
    // 1. 获取最后一个窗口（当前活动窗口）
    window.getLastWindow(windowContext, (err, data) => {
      try {
        // 2. 检查是否成功获取窗口
        if (err.code) {
          return;
        }
        
        let windowClass = data;
        
        // 3. 如果names数组为空，表示要隐藏所有系统栏
        if (names.length === 0) {
          // 禁用避让区域监听器，因为系统栏已隐藏
          AppStorage.setOrCreate('Grid.tabPro.enableAvoidAreaListener', false);
        }
        
        // 4. 设置系统栏启用状态
        windowClass.setWindowSystemBarEnable(names).then(() => {
          // 成功设置系统栏，记录日志
          hilog.info(0x0000, TAG, 'toggleWindowSystemBar setWindowSystemBarEnable succeeded');
        }, (error: Error) => {
          // 设置系统栏失败，记录错误日志
          if (error) {
            hilog.error(0x0000, TAG,
              'toggleWindowSystemBar setWindowSystemBarEnable failed, error is:' + JSON.stringify(error));
          }
        })
        
        // 5. 如果names数组不为空，表示要显示系统栏
        if (names.length > 0) {
          // 启用避让区域监听器，因为系统栏已显示
          AppStorage.setOrCreate('Grid.tabPro.enableAvoidAreaListener', true);
        }
        
        // 6. 记录操作成功日志（注意：日志信息与实际操作相反，可能是历史遗留问题）
        hilog.info(0x0000, TAG, 'toggleWindowSystemBar Succeeded in setting the system bar to be invisible.');
      } catch (exception) {
        // 7. 捕获并记录异常
        hilog.error(0x0000, TAG,
          'toggleWindowSystemBar Failed to set the system bar to be invisible. Cause:' + JSON.stringify(exception));
      }
    });
  }
}

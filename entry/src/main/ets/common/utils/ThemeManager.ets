/**
 * 主题管理器类 - 管理应用主题的工具类
 * 
 * 功能：封装主题管理相关功能，包括主题初始化、设置、添加、删除等
 * 核心特性：
 *   1. 主题列表管理：维护预定义主题列表和自定义主题
 *   2. 持久化存储：使用PersistentStorage和AppStorage持久化主题配置
 *   3. 主题切换：支持动态切换应用主题
 *   4. 主题增删：支持添加和删除自定义主题
 * 使用场景：应用主题切换、主题管理、个性化设置
 */
import { ThemeColor, ThemeStorageKey } from "../constants/Theme";
import { ThemeItem } from "../model/Theme";

export class ThemeManager {
  /**
   * 主题列表
   * 功能：预定义的主题列表，包含5个默认主题
   * 主题说明：
   *   - 主题1: 橙色主题
   *   - 主题2: 红色主题
   *   - 主题3: 绿色主题
   *   - 主题4: 黄色主题
   *   - 主题5: 蓝色主题
   */
  themeList: ThemeItem[] = [
    {text: '主题1', mainColor: ThemeColor.ORANGE.mainColor, secondColor: ThemeColor.ORANGE.secondColor},
    {text: '主题2', mainColor: ThemeColor.RED.mainColor, secondColor: ThemeColor.RED.secondColor},
    {text: '主题3', mainColor: ThemeColor.GREEN.mainColor, secondColor: ThemeColor.GREEN.secondColor},
    {text: '主题4', mainColor: ThemeColor.YELLOW.mainColor, secondColor: ThemeColor.YELLOW.secondColor},
    {text: '主题5', mainColor: ThemeColor.BLUE.mainColor, secondColor: ThemeColor.BLUE.secondColor},
  ];

  /**
   * 初始化主题
   * 功能：初始化主题配置，设置默认主题并持久化存储
   * 使用场景：应用启动时调用，初始化主题配置
   * 处理流程：
   *   1. 持久化默认主题到PersistentStorage
   *   2. 持久化主题列表字符串到PersistentStorage
   *   3. 从AppStorage获取主题列表字符串并解析为数组
   *   4. 设置主题列表到AppStorage
   *   5. 持久化当前主题索引（默认为0）
   */
  init() {
    PersistentStorage.persistProp<ThemeItem>(ThemeStorageKey.THEME, {text: '主题1', mainColor: ThemeColor.ORANGE.mainColor, secondColor: ThemeColor.ORANGE.secondColor});
    PersistentStorage.persistProp<string>(ThemeStorageKey.THEMELISTSTR, JSON.stringify(this.themeList));

    // 解析主题数组字符串 加载主题
    const str = AppStorage.get<string>(ThemeStorageKey.THEMELISTSTR);
    const themeList = JSON.parse(str as string) as ThemeItem[];
    AppStorage.setOrCreate<ThemeItem[]>(ThemeStorageKey.THEMELIST, themeList);

    PersistentStorage.persistProp<number>(ThemeStorageKey.THEMEINDEX, 0); // 被选中主题的索引
  }

  /**
   * 设置主题
   * 功能：设置当前应用主题
   * @param newTheme - 新的主题对象
   * @param index - 主题在列表中的索引
   * 使用场景：用户切换主题时调用
   * 处理流程：
   *   1. 设置当前主题到AppStorage
   *   2. 设置当前主题索引到AppStorage
   */
  setTheme(newTheme: ThemeItem, index: number) {
    AppStorage.setOrCreate<ThemeItem>(ThemeStorageKey.THEME, newTheme);
    AppStorage.setOrCreate<number>(ThemeStorageKey.THEMEINDEX, index);
  }

  /**
   * 添加主题
   * 功能：添加新的自定义主题到主题列表
   * @param newTheme - 要添加的新主题对象
   * 使用场景：用户创建自定义主题
   * 处理流程：
   *   1. 从AppStorage获取当前主题列表字符串
   *   2. 解析为主题列表数组
   *   3. 将新主题添加到数组末尾
   *   4. 将更新后的主题列表字符串化并保存到AppStorage
   *   5. 设置更新后的主题列表到AppStorage
   */
  addTheme(newTheme: ThemeItem) {
    const str = AppStorage.get<string>(ThemeStorageKey.THEMELISTSTR);
    const themeList = JSON.parse(str as string) as ThemeItem[];
    themeList.push(newTheme);
    AppStorage.setOrCreate(ThemeStorageKey.THEMELISTSTR, JSON.stringify(themeList));
    AppStorage.setOrCreate<ThemeItem[]>(ThemeStorageKey.THEMELIST, themeList);
  }

  /**
   * 删除主题
   * 功能：从主题列表中删除指定索引的主题
   * @param index - 要删除的主题索引
   * 使用场景：用户删除自定义主题
   * 处理流程：
   *   1. 从AppStorage获取当前主题列表字符串
   *   2. 解析为主题列表数组
   *   3. 获取当前活动主题索引
   *   4. 调整活动主题索引（如果删除的是当前活动主题之前的主题，索引减1；如果删除的是当前活动主题，索引设为0）
   *   5. 过滤掉指定索引的主题
   *   6. 设置新的活动主题
   *   7. 将更新后的主题列表字符串化并保存到AppStorage
   *   8. 设置更新后的主题列表到AppStorage
   */
  deleteTheme(index: number) {
    const str = AppStorage.get<string>(ThemeStorageKey.THEMELISTSTR);
    let themeList = JSON.parse(str as string) as ThemeItem[];
    let activeIndex: number = AppStorage.get<number>(ThemeStorageKey.THEMEINDEX) as number;
    
    if (activeIndex > index) {
      --activeIndex;
    } else if (activeIndex == index) {
      activeIndex = 0;
    }
    
    themeList = themeList.filter((item, i) => i != index);
    this.setTheme(themeList[activeIndex], activeIndex);
    AppStorage.setOrCreate(ThemeStorageKey.THEMELISTSTR, JSON.stringify(themeList));
    AppStorage.setOrCreate<ThemeItem[]>(ThemeStorageKey.THEMELIST, themeList);
  }
}

// 单例模式 - 创建并导出全局唯一的ThemeManager实例
export const themeManager = new ThemeManager();

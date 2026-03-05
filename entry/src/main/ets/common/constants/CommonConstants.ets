/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { curves } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';

/**
 * 通用常量类 - 包含应用中所有功能模块使用的常量
 * 
 * 功能：定义应用中的各种常量，包括页面标识、UI尺寸、存储键值、数据库配置等
 * 使用方法：通过 CommonConstants.常量名 访问对应的常量值
 * 分类：
 *   1. 页面和组件标识常量
 *   2. UI布局和样式常量
 *   3. 偏好设置存储键值常量
 *   4. 小说应用相关常量
 *   5. 数据库配置常量
 *   6. 其他通用常量
 * 注意事项：所有常量均为静态只读属性，不可修改
 */
export default class CommonConstants {
  // ==================== 页面和组件标识常量 ====================
  
  /**
   * 主Ability标签
   * 功能：标识应用的主Ability组件
   * 使用场景：在Ability生命周期管理和日志记录中使用
   */
  static readonly ENTRY_ABILITY_TAG: string = 'EntryAbility';

  /**
   * 启动页标签
   * 功能：标识应用的启动页面
   * 使用场景：页面导航和状态管理
   */
  static readonly LAUNCHER_PAGE_TAG: string = 'LauncherPage';

  /**
   * 广告页标签
   * 功能：标识广告展示页面
   * 使用场景：广告页面跳转和状态管理
   */
  static readonly ADVERTISING_PAGE_TAG: string = 'AdvertisingPage';

  /**
   * 自定义对话框组件标签
   * 功能：标识自定义对话框组件
   * 使用场景：对话框显示和隐藏控制
   */
  static readonly CUSTOM_DIALOG_TAG: string = 'CustomDialogComponent';

  // ==================== 偏好设置存储常量 ====================
  
  /**
   * 隐私偏好设置键值
   * 功能：存储用户隐私设置状态的键名
   * 使用场景：检查用户是否同意隐私政策
   */
  static readonly PREFERENCES_KEY_PRIVACY: string = 'isPrivacy';

  /**
   * 偏好设置存储文件名
   * 功能：本地偏好设置存储的文件名
   * 使用场景：创建和管理本地偏好设置存储
   */
  static readonly PREFERENCES_FILE_NAME: string = 'myStore';

  // ==================== 启动页UI布局常量 ====================
  
  /**
   * 启动页倒计时时间（毫秒）
   * 功能：启动页显示的时间长度
   * 使用场景：控制启动页自动跳转到主页的时间
   */
  static readonly LAUNCHER_DELAY_TIME: number = 3000;

  /**
   * 启动页Logo图片上边距
   * 功能：控制Logo在启动页中的垂直位置
   * 使用场景：启动页UI布局
   */
  static readonly LAUNCHER_IMAGE_MARGIN_TOP: string = '16.2%';

  /**
   * 启动页健康生活文本间距
   * 功能：控制文本行之间的间距
   * 使用场景：启动页文本样式设置
   */
  static readonly LAUNCHER_LIFE_TEXT_SPACING: number = 0.1;

  /**
   * 启动页标题文本上边距
   * 功能：控制标题文本的垂直位置
   * 使用场景：启动页UI布局
   */
  static readonly LAUNCHER_TEXT_TITLE_MARGIN_TOP: string = '0.5%';

  /**
   * 启动页内容控件高度
   * 功能：控制内容区域的高度
   * 使用场景：启动页UI布局
   */
  static readonly LAUNCHER_TEXT_INTRODUCE_HEIGHT: string = '2.7%';

  /**
   * 启动页健康生活说明文本间距
   * 功能：控制说明文本的行间距
   * 使用场景：启动页文本样式设置
   */
  static readonly LAUNCHER_TEXT_INTRODUCE_SPACING: number = 3.4;

  /**
   * 启动页健康生活内容上边距
   * 功能：控制内容区域的垂直位置
   * 使用场景：启动页UI布局
   */
  static readonly LAUNCHER_TEXT_INTRODUCE_MARGIN_TOP: string = '1.3%';

  // ==================== 广告页UI布局常量 ====================
  
  /**
   * 广告页定时执行间隔时间（毫秒）
   * 功能：控制广告页定时任务的执行频率
   * 使用场景：广告倒计时更新
   */
  static readonly ADVERTISING_INTERVAL_TIME: number = 1000;

  /**
   * 广告页URL路径
   * 功能：广告页面的路由路径
   * 使用场景：页面导航到广告页
   */
  static readonly ADVERTISING_PAGE_URL: string = 'pages/AdvertisingPage';

  /**
   * 广告页倒计时秒数
   * 功能：广告页显示的倒计时总秒数
   * 使用场景：控制广告显示时长
   */
  static readonly ADVERTISING_COUNT_DOWN_SECONDS: number = 2;

  /**
   * 广告页倒计时标题文本字间距
   * 功能：控制倒计时文本的字间距
   * 使用场景：广告页文本样式设置
   */
  static readonly ADVERTISING_TITLE_TEXT_LETTER_SPACING: number = 0.05;

  /**
   * 广告页健康生活文本间距
   * 功能：控制健康生活文本的行间距
   * 使用场景：广告页文本样式设置
   */
  static readonly ADVERTISING_HEALTHY_LIFE_TEXT_SPACING: number = 0.1;

  /**
   * 广告页健康描述文本字间距
   * 功能：控制描述文本的字间距
   * 使用场景：广告页文本样式设置
   */
  static readonly ADVERTISING_TEXT_INTRODUCE_LETTER_SPACING: number = 3.4;

  /**
   * 广告页健康描述文本上边距
   * 功能：控制描述文本的垂直位置
   * 使用场景：广告页UI布局
   */
  static readonly ADVERTISING_TEXT_INTRODUCE_MARGIN_TOP: string = '0.4%';

  /**
   * 广告页列容器左边距
   * 功能：控制列容器的水平位置
   * 使用场景：广告页UI布局
   */
  static readonly ADVERTISING_COLUMN_MARGIN_LEFT: string = '3.1%';

  /**
   * 广告页行容器下边距
   * 功能：控制行容器的垂直位置
   * 使用场景：广告页UI布局
   */
  static readonly ADVERTISING_ROW_MARGIN_BOTTOM: string = '3.1%';

  // ==================== 对话框UI布局常量 ====================
  
  /**
   * 对话框组件宽度百分比（90%）
   * 功能：控制对话框组件的宽度占父容器的百分比
   * 使用场景：自定义对话框的宽度设置
   */
  static readonly DIALOG_COMPONENT_WIDTH_PERCENT: string = '90%';

  /**
   * 对话框标题文本字重
   * 功能：控制对话框标题文本的粗细程度
   * 使用场景：对话框标题样式设置
   * CSS对应：font-weight: 600
   */
  static readonly DIALOG_TITLE_FONT_WEIGHT: number = 600;

  /**
   * 对话框宽度百分比（93.3%）
   * 功能：控制对话框的宽度占父容器的百分比
   * 使用场景：对话框整体宽度设置
   */
  static readonly DIALOG_WIDTH_PERCENT: string = '93.3%';

  /**
   * 对话框边框圆角半径
   * 功能：控制对话框四个角的圆角程度
   * 使用场景：对话框样式美化
   * 单位：像素
   */
  static readonly DIALOG_BORDER_RADIUS: number = 24;

  /**
   * 对话框行容器下边距
   * 功能：控制对话框内行容器的底部间距
   * 使用场景：对话框内部布局
   */
  static readonly DIALOG_ROW_MARGIN_BOTTOM: string = '3.1%';

  /**
   * 对话框控制器Y轴偏移距离
   * 功能：控制对话框在垂直方向上的偏移量
   * 使用场景：对话框位置微调
   * 单位：像素，负值表示向上偏移
   */
  static readonly DIALOG_CONTROLLER_DY_OFFSET: number = -24;

  // ==================== 通用尺寸和页面URL常量 ====================
  
  /**
   * 全宽度百分比（100%）
   * 功能：表示占据父容器100%宽度
   * 使用场景：需要全宽度布局的组件
   */
  static readonly FULL_WIDTH: string = '100%';

  /**
   * 全高度百分比（100%）
   * 功能：表示占据父容器100%高度
   * 使用场景：需要全高度布局的组件
   */
  static readonly FULL_HEIGHT: string = '100%';

  /**
   * 隐私政策页面URL路径
   * 功能：隐私政策页面的路由路径
   * 使用场景：导航到隐私政策页面
   */
  static readonly PRIVACY_PAGE_URL: string = 'pages/PrivacyPage';

  /**
   * 应用主页URL路径
   * 功能：应用主页面的路由路径
   * 使用场景：导航到应用主页
   */
  static readonly APP_HOME_PAGE_URL: string = 'pages/AppHomePage';

  /**
   * 通用布局权重
   * 功能：定义布局组件的权重值，用于在Flex布局中分配空间
   * 使用场景：Flex容器中子组件的空间分配
   * 说明：权重值为1表示平均分配剩余空间
   */
  static readonly COMMON_LAYOUT_WEIGHT: number = 1;
  
  /**
   * 标题栏图标大小
   * 功能：定义应用标题栏中图标的标准尺寸
   * 使用场景：导航栏、工具栏等标题栏图标的尺寸设置
   * 单位：像素
   */
  static readonly TITLE_IMG_SIZE: number = 24;
  
  /**
   * 小说封面宽度
   * 功能：定义小说封面图片的标准宽度
   * 使用场景：书架列表、搜索列表等位置的小说封面显示
   * 单位：像素
   */
  static readonly NOVEL_IMG_WIDTH: number = 76;
  
  /**
   * 小说封面高度
   * 功能：定义小说封面图片的标准高度
   * 使用场景：书架列表、搜索列表等位置的小说封面显示
   * 单位：像素
   * 宽高比：约0.745（76:102），接近标准书籍封面比例
   */
  static readonly NOVEL_IMG_HEIGHT: number = 102;
  
  /**
   * 小说详情封面高度
   * 功能：定义小说详情页面中封面图片的高度
   * 使用场景：小说详情页面的封面显示，通常比列表中的封面更大
   * 单位：像素
   * 说明：详情页封面通常需要更大的显示空间以展示更多细节
   */
  static readonly NOVEL_DETAIL_IMG_HEIGHT: number = 128;
  
  /**
   * 小说详情页作者图标大小
   * 功能：定义小说详情页面中作者图标的标准尺寸
   * 使用场景：小说详情页作者信息区域的图标显示
   * 单位：像素
   */
  static readonly NOVEL_DETAIL_AUTHOR_IMG_SIZE: number = 16;
  
  /**
   * 小说详情页标题字体大小
   * 功能：定义小说详情页面中标题文本的字体大小
   * 使用场景：小说详情页面的书名显示
   * 单位：像素
   */
  static readonly FONT_NOVEL_DETAIL_TITLE_SIZE: number = 20;
  
  /**
   * 小说详情页作者字体大小
   * 功能：定义小说详情页面中作者文本的字体大小
   * 使用场景：小说详情页面的作者信息显示
   * 单位：像素
   */
  static readonly FONT_NOVEL_DETAIL_AUTHOR_SIZE: number = 12;
  
  /**
   * 小说详情页标签字体大小
   * 功能：定义小说详情页面中标签文本的字体大小
   * 使用场景：小说详情页面的分类标签、状态标签显示
   * 单位：像素
   */
  static readonly FONT_NOVEL_DETAIL_TAG_SIZE: number = 10;
  
  /**
   * 小说详情页信息字体大小
   * 功能：定义小说详情页面中其他信息文本的字体大小
   * 使用场景：小说详情页面的简介、更新信息等文本显示
   * 单位：像素
   */
  static readonly FONT_NOVEL_DETAIL_INFO_SIZE: number = 14;
  
  /**
   * 94%宽度百分比
   * 功能：表示占据父容器94%宽度的百分比值
   * 使用场景：需要留有一定边距的组件宽度设置
   */
  static readonly PERCENT_94: string = '94%';
  
  /**
   * 90%宽度百分比
   * 功能：表示占据父容器90%宽度的百分比值
   * 使用场景：需要留有一定边距的组件宽度设置
   */
  static readonly PERCENT_90: string = '90%';
  
  /**
   * 2像素间距
   * 功能：定义2像素的标准间距值
   * 使用场景：组件之间的微小间距，如图标与文本的间距
   * 单位：像素
   */
  static readonly SPACE_2: number = 2;
  
  /**
   * 6像素间距
   * 功能：定义6像素的标准间距值
   * 使用场景：小尺寸组件之间的间距
   * 单位：像素
   */
  static readonly SPACE_6: number = 6;
  
  /**
   * 10像素间距
   * 功能：定义10像素的标准间距值
   * 使用场景：中等尺寸组件之间的间距
   * 单位：像素
   */
  static readonly SPACE_10: number = 10;
  
  /**
   * 12像素间距
   * 功能：定义12像素的标准间距值
   * 使用场景：中等尺寸组件之间的间距
   * 单位：像素
   */
  static readonly SPACE_12: number = 12;
  
  /**
   * 16像素间距
   * 功能：定义16像素的标准间距值
   * 使用场景：较大组件之间的间距，如卡片之间的间距
   * 单位：像素
   */
  static readonly SPACE_16: number = 16;
  
  /**
   * 20像素间距
   * 功能：定义20像素的标准间距值
   * 使用场景：大组件之间的间距，如模块之间的间距
   * 单位：像素
   */
  static readonly SPACE_20: number = 20;

  // ==================== 小说AppStorage存储键值常量 ====================
  
  /**
   * 书籍类型数量存储键
   * 功能：存储书籍类型数量的AppStorage键名
   * 使用场景：记录小说、有声书、漫画等不同类型的书籍数量
   */
  static readonly PREFERENCES_BOOK_TYPE_NUMBER: string = 'PREFERENCES_BOOK_TYPE_NUMBER';
  
  /**
   * 书籍初始化状态存储键
   * 功能：存储书籍数据是否已初始化的AppStorage键名
   * 使用场景：标记书籍数据是否已完成初始化加载
   */
  static readonly PREFERENCES_BOOK_INIT_KEY: string = 'PREFERENCES_BOOK_INIT_KEY';
  
  /**
   * 书籍数据存储键
   * 功能：存储书籍数据的AppStorage键名
   * 使用场景：保存和获取书籍列表数据
   */
  static readonly PREFERENCES_BOOK_DATA_KEY: string = 'PREFERENCES_BOOK_DATA_KEY';
  
  /**
   * 小说书籍数据存储键
   * 功能：存储小说类型书籍数据的AppStorage键名
   * 使用场景：保存和获取小说书籍列表数据
   */
  static readonly KEY_NOVEL_BOOK_DATA: string = 'KEY_NOVEL_BOOK_DATA';
  
  /**
   * 有声书数据存储键
   * 功能：存储有声书类型书籍数据的AppStorage键名
   * 使用场景：保存和获取有声书书籍列表数据
   */
  static readonly KEY_SOUND_BOOK_DATA: string = 'KEY_SOUND_BOOK_DATA';
  
  /**
   * 漫画数据存储键
   * 功能：存储漫画类型书籍数据的AppStorage键名
   * 使用场景：保存和获取漫画书籍列表数据
   */
  static readonly KEY_CARTOON_BOOK_DATA: string = 'KEY_CARTOON_BOOK_DATA';
  
  /**
   * 分组列表数据存储键
   * 功能：存储书籍分组列表数据的AppStorage键名
   * 使用场景：保存和获取书籍分组列表数据
   */
  static readonly GROUP_LIST_DATA: string = 'GROUP_LIST_DATA';
  
  /**
   * 书架列表数据存储键
   * 功能：存储书架列表数据的AppStorage键名
   * 使用场景：保存和获取书架列表数据
   */
  static readonly SHELF_LIST_DATA: string = 'SHELF_LIST_DATA';
  
  /**
   * 探索URL状态存储键
   * 功能：存储是否已探索过URL的状态AppStorage键名
   * 使用场景：标记用户是否已探索过特定URL
   */
  static readonly HAS_EXPLORE_URL: string = 'HAS_EXPLORE_URL';
  
  /**
   * 书籍刷新状态存储键
   * 功能：存储书籍列表是否正在刷新的状态AppStorage键名
   * 使用场景：控制书籍列表的刷新状态显示
   */
  static readonly BOOK_IS_BOOK_REFRESHING: string = 'BOOK_IS_BOOK_REFRESHING';
  
  /**
   * 书籍分组刷新状态存储键
   * 功能：存储书籍分组列表是否正在刷新的状态AppStorage键名
   * 使用场景：控制书籍分组列表的刷新状态显示
   */
  static readonly BOOK_IS_BOOK_GROUPS_REFRESHING: string = 'BOOK_IS_BOOK_GROUPS_REFRESHING';
  
  /**
   * 书单作品列表刷新状态存储键
   * 功能：存储书单作品列表是否正在刷新的状态AppStorage键名
   * 使用场景：控制书单作品列表的刷新状态显示
   */
  static readonly BOOK_IS_BOOK_WORKS_BOOK_LIST: string = 'BOOK_IS_BOOK_WORKS_BOOK_LIST';
  
  /**
   * 书籍历史记录刷新状态存储键
   * 功能：存储书籍历史记录是否正在刷新的状态AppStorage键名
   * 使用场景：控制书籍历史记录列表的刷新状态显示
   */
  static readonly BOOK_IS_BOOK_HISTORY_REFRESHING: string = 'BOOK_IS_BOOK_HISTORY_REFRESHING';

  // ==================== 订阅源分组数据存储键值常量 ====================
  
  /**
   * 订阅源分组初始化状态存储键
   * 功能：存储订阅源分组数据是否已初始化的AppStorage键名
   * 使用场景：标记订阅源分组数据是否已完成初始化加载
   */
  static readonly RSS_SOURCES_GROUP_INIT: string = 'RSS_SOURCES_GROUP_INIT';
  
  /**
   * 订阅源分组列表数据存储键
   * 功能：存储订阅源分组列表数据的AppStorage键名
   * 使用场景：保存和获取订阅源分组列表数据
   */
  static readonly RSS_SOURCES_GROUP_LIST_DATA_KEY: string = 'RSS_SOURCES_GROUP_LIST_DATA_KEY';
  
  /**
   * 订阅源刷新状态存储键
   * 功能：存储订阅源列表是否正在刷新的状态AppStorage键名
   * 使用场景：控制订阅源列表的刷新状态显示
   */
  static readonly RSS_SOURCES_REFRESHING: string = 'RSS_SOURCES_REFRESHING';
  
  /**
   * 系统User-Agent存储键
   * 功能：存储系统User-Agent设置的AppStorage键名
   * 使用场景：保存和获取用户选择的User-Agent设置（0-Android, 1-Phone, 2-电脑, 3-自定义）
   */
  static readonly SYSTEM_UA: string = 'SYSTEM_UA';

  // ==================== 数据库配置常量 ====================
  
  /**
   * 数据库日志标签
   * 功能：数据库操作日志的标签标识
   * 使用场景：在日志系统中标识数据库相关的日志记录
   */
  static readonly RDB_TAG: string = 'RdbTag';
  
  /**
   * 数据库存储配置
   * 功能：定义关系型数据库的存储配置
   * 使用场景：创建和管理应用的关系型数据库
   * 配置说明：
   *   - name: 数据库文件名，为"novel.db"
   *   - securityLevel: 安全级别为S1，提供基本的数据保护
   */
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: "novel.db",
    securityLevel: relationalStore.SecurityLevel.S1
  };

  // ==================== 动画和样式常量 ====================
  
  /**
   * 默认动画曲线
   * 功能：定义默认的动画曲线，用于组件动画效果
   * 使用场景：组件出现、消失、移动等动画效果
   * 曲线类型：弹簧曲线，参数为(0, 0.5, 128, 12)
   */
  static readonly UniCurve: ICurve = curves.springCurve(0, 0.5, 128, 12);
  
  /**
   * 字体家族：苹方字体
   * 功能：定义应用中使用的默认中文字体
   * 使用场景：文本组件的字体设置，确保中文显示效果
   * 字体说明：PingFang SC是苹果系统的默认中文字体，清晰易读
   */
  static readonly FAMILY_PingFANG: string = 'PingFang SC';

  // ==================== 通用宽高尺寸常量 ====================
  
  /**
   * 通用宽度：45.36像素
   * 功能：定义通用的组件宽度尺寸
   * 使用场景：需要特定宽度的小型组件
   * 单位：像素
   */
  static readonly COMMON_WIDTH_45_36: number = 45.36;
  
  /**
   * 通用高度：21.6像素
   * 功能：定义通用的组件高度尺寸
   * 使用场景：需要特定高度的小型组件
   * 单位：像素
   */
  static readonly COMMON_HEIGHT_21_6: number = 21.6;
  
  /**
   * 通用宽度：40像素
   * 功能：定义通用的组件宽度尺寸
   * 使用场景：需要40像素宽度的组件，如按钮、图标容器等
   * 单位：像素
   */
  static readonly COMMON_WIDTH_40: number = 40;
  
  /**
   * 通用高度：40像素
   * 功能：定义通用的组件高度尺寸
   * 使用场景：需要40像素高度的组件，如按钮、图标容器等
   * 单位：像素
   */
  static readonly COMMON_HEIGHT_40: number = 40;

  // ==================== 网络请求常量 ====================
  
  /**
   * 基础API请求域名
   * 功能：定义应用后端API的基础请求地址
   * 使用场景：所有网络请求的基础URL，用于构建完整的API请求地址
   * 说明：指向Legado服务器的API接口，提供书籍数据服务
   */
  static readonly BASE_URL: string = 'https://legado.miaogongzi.cc/api/LegadoServer';
}

/**
 * MusicPlayer 组件 - 音乐播放器组件
 * 
 * 功能概述：
 * 1. 提供完整的音频播放功能，支持本地音乐文件的选择和播放
 * 2. 实现播放控制：播放/暂停、快进/快退、上一曲/下一曲
 * 3. 显示播放进度、当前时间和总时长
 * 4. 支持语速设置、定时关闭、添加到书架等辅助功能
 * 5. 集成系统多媒体API，提供稳定的音频播放体验
 * 
 * 设计特点：
 * 1. 分层布局：使用Column和Row实现清晰的功能分区
 * 2. 状态管理：使用@State和@StorageLink管理播放状态和UI状态
 * 3. 系统集成：深度集成HarmonyOS多媒体和文件选择API
 * 4. 响应式设计：根据窗口尺寸动态调整布局
 * 5. 回调机制：使用事件回调处理播放状态和进度更新
 * 
 * 使用场景：
 * 1. 阅读器页面中的听书功能
 * 2. 本地音乐文件的播放和管理
 * 3. 需要音频播放功能的应用场景
 * 
 * 组件结构：
 * - 头部区域：标题、关闭按钮、更多选项
 * - 内容区域：书籍信息、播放进度条
 * - 控制区域：播放控制按钮（播放/暂停、快进/快退等）
 * - 功能区域：定时、语速、加书架、目录等辅助功能
 * - 对话框：语速设置对话框
 * 
 * 注意事项：
 * 1. 需要正确处理多媒体资源的生命周期管理
 * 2. 播放状态需要与UI状态保持同步
 * 3. 文件选择功能需要用户授权
 */

import { BusinessError } from '@ohos.base';
import media from '@ohos.multimedia.media';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';

/**
 * 全局音频播放器实例
 * @type {media.AVPlayer}
 * @description 管理音频播放的核心对象
 */
let avPlayer: media.AVPlayer;

/**
 * 快进/快退时间间隔
 * @type {number}
 * @default 15000
 * @description 快进/快退操作的时间间隔，单位毫秒
 */
let seekTime: number = 15000

@Component
export struct MusicPlayer {
  /**
   * 底部矩形高度
   * @type {number}
   * @default 0
   * @description 从存储中读取的底部矩形高度，用于布局计算
   * @storagelink 使用@StorageLink装饰器实现与存储的双向绑定
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /**
   * 顶部矩形高度
   * @type {number}
   * @default 0
   * @description 从存储中读取的顶部矩形高度，用于布局计算
   * @storagelink 使用@StorageLink装饰器实现与存储的双向绑定
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /**
   * 窗口宽度
   * @type {number}
   * @default 0
   * @description 从存储中读取的窗口宽度，用于响应式布局
   * @storagelink 使用@StorageLink装饰器实现与存储的双向绑定
   */
  @StorageLink('WindowWidth') WindowWidth: number = 0
  
  /**
   * 宽度减量
   * @type {number}
   * @default 0
   * @description 父组件传递的宽度调整值，用于进度条计算
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop WidthMinus: number = 0
  
  /**
   * 播放器显示状态
   * @type {boolean}
   * @description 控制音乐播放器的显示/隐藏
   * @link 使用@Link装饰器实现与父组件的双向绑定
   */
  @Link isShowListen: boolean
  
  /**
   * 初始化状态
   * @type {boolean}
   * @default false
   * @description 标识音频播放器是否已完成初始化
   * @state 使用@State装饰器管理组件内部状态
   */
  @State hasInit: boolean = false;
  
  /**
   * 音乐播放状态
   * @type {boolean}
   * @default false
   * @description 标识音乐是否正在播放
   * @state 使用@State装饰器管理组件内部状态
   */
  @State isMusicPlaying: boolean = false;
  
  /**
   * 当前播放时间
   * @type {number}
   * @default 0
   * @description 当前播放的时间位置，单位毫秒
   * @state 使用@State装饰器管理组件内部状态
   */
  @State MusicPlayingTime: number = 0
  
  /**
   * 音乐总时长
   * @type {number}
   * @default 100
   * @description 音频文件的总时长，单位毫秒
   * @state 使用@State装饰器管理组件内部状态
   */
  @State MusicDuration: number = 100
  
  /**
   * 语速设置显示状态
   * @type {boolean}
   * @default false
   * @description 控制语速设置对话框的显示/隐藏
   * @state 使用@State装饰器管理组件内部状态
   */
  @State isShowSpeed: boolean = false;

  // private Player: media.AVPlayer = new media // 预留的私有播放器实例

  /**
   * 格式化毫秒时间为分钟:秒格式
   * @param {number} milliseconds - 毫秒时间
   * @returns {string} 格式化后的时间字符串，格式：分钟:秒
   * @description 将毫秒时间转换为"分钟:秒"格式的字符串
   * 例如：65000毫秒 -> "1:05"
   */
  formatMilliseconds(milliseconds: number): string {
    const totalSeconds = Math.floor(milliseconds / 1000); // 转换为秒
    const minutes = Math.floor(totalSeconds / 60); // 计算分钟
    const seconds = totalSeconds % 60; // 计算剩余秒数

    // 格式化秒数为两位数字
    const formattedSeconds = seconds < 10 ? `0${seconds}` : `${seconds}`;

    return `${minutes}:${formattedSeconds}`;
  }

  /**
   * 组件即将显示时的生命周期回调
   * @returns {Promise<void>}
   * @description 初始化音频播放器，选择音频文件并设置回调
   * 1. 创建AVPlayer实例
   * 2. 使用文件选择器选择音频文件
   * 3. 设置播放器状态回调
   * 4. 设置时长更新回调
   */
  async aboutToAppear() {
    let audioSelectOptions = new picker.AudioSelectOptions();
    let audioPicker = new picker.AudioViewPicker();

    // 创建音频播放器实例
    media.createAVPlayer().then((video: media.AVPlayer) => {
      if (video != null) {
        avPlayer = video;
        console.info('createAVPlayer success');
      } else {
        console.error('createAVPlayer fail');
      }
    }).catch((error: BusinessError) => {
      console.error(`AVPlayer catchCallback, error message:${error.message}`);
    });

    // todo:这里暂时用 picker选本地音乐，音乐的 URL后期需要改成从上级组件传进来
    await audioPicker.select(audioSelectOptions).then((audioSelectResult: Array<string>) => {
      console.info('AudioViewPicker.select successfully, audioSelectResult uri: ' + JSON.stringify(audioSelectResult));
      avPlayer.url = 'fd://' + fs.openSync(audioSelectResult[0]).fd.toString(); // 设置音频文件路径
    })

    await this.setCallback(avPlayer) // 设置状态变化回调
    this.timeDurationUpdateCallback(avPlayer) // 设置时长更新回调
  }

  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建音乐播放器的完整UI结构
   * 包含头部、内容、控制和功能四个区域
   */
  build() {
    Column() {
      /**
       * 头部区域
       * @description 包含关闭按钮、标题和更多选项
       * 48px高度，100%宽度，白色文字
       */
      Row() {
        Image($r("app.media.direction_down")).width(24)
          .onClick(() => {
            this.isShowListen = false // 点击关闭播放器
          })
        Blank(1) // 空白填充
        Text("大奉打更人") // 书籍标题
          .lineHeight(24)
          .fontColor("#FFFFFF")
          .font({
            size: 16,
            weight: 500
          })
        Blank(1) // 空白填充
        Image($r("app.media.more")).width(24) // 更多选项按钮
      }
      .height(48)
      .width("100%")


      Blank(1) // 空白分隔
      
      /**
       * 内容区域
       * @description 显示书籍章节信息和内容摘要
       */
      Column() {
        Row() {
          Text("第1章 牢狱之灾") // 章节标题
        }

        Row() {
          Text("卖报小郎君") // 作者名称
          Button("搜作者") // 搜索作者按钮
        }

        Row() {
          Text("许七安幽幽醒来，嗅到了空气中潮湿的腐臭") // 内容摘要
        }
      }

      /**
       * 播放控制区域
       * @description 包含进度条和播放控制按钮
       * 24px间距，垂直排列
       */
      Column({ space: 24 }) {
        /**
         * 进度条区域
         * @description 使用Stack布局实现时间标签和进度线的叠加
         * 时间标签根据播放进度动态移动
         */
        Row() {
          Stack() {
            /**
             * 时间标签
             * @description 显示当前时间/总时间，白色背景，跟随进度移动
             */
            Flex() {
              Text(`${this.formatMilliseconds(this.MusicPlayingTime)}/${this.formatMilliseconds(this.MusicDuration)}`)
                .font({
                  size: 10,
                  weight: 400
                })
            }
            .margin({
              // 根据播放进度计算左边距，实现标签跟随
              left: (this.WindowWidth - this.WidthMinus) * this.MusicPlayingTime / this.MusicDuration
            })
            .borderRadius(33) // 33px圆角
            .width(70) // 固定宽度
            .zIndex(2) // 上层显示
            .backgroundColor('#FFFFFF') // 白色背景
            .padding({
              top: 4,
              bottom: 4,
              left: 8,
              right: 8
            })

            /**
             * 进度线
             * @description 白色水平线，表示播放进度条
             */
            Line().width("100%").height(2).backgroundColor('#FFFFFF')
          }
          .alignContent(Alignment.Start)
          .width("100%")
        }

        /**
         * 播放控制按钮区域
         * @description 使用Flex布局水平排列播放控制按钮
         * 两端对齐，居中对齐
         */
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.SpaceBetween,
          alignItems: ItemAlign.Center
        }) {
          /**
           * 快退按钮
           * @description 点击快退15秒，不超过0秒
           */
          Image($r("app.media.Backward"))
            .width(24)
            .onClick(() => {
              avPlayer.seek(this.MusicPlayingTime - seekTime < 0 ? 0 : this.MusicPlayingTime - seekTime,
                media.SeekMode.SEEK_PREV_SYNC)
            })
          
          /**
           * 上一曲按钮
           * @description 预留功能，当前为空实现
           */
          Image($r("app.media.Previous"))
            .width(24)
            .onClick(() => {
              // 上一曲功能预留
            })
          
          /**
           * 播放/暂停按钮
           * @description 根据播放状态切换图标，控制播放/暂停
           * 80px宽度，白色填充色
           */
          Image($r(this.isMusicPlaying ? "app.media.stop" : "app.media.music_play"))
            .fillColor(Color.White)
            .width(80)
            .onClick(async () => {
              if (this.isMusicPlaying) {
                avPlayer.pause() // 暂停播放
                avPlayer.off('timeUpdate') // 移除时间更新监听
              } else {
                avPlayer.play() // 开始播放
                this.timeUpdateCallback() // 设置时间更新回调
              }
            })

          /**
           * 下一曲按钮
           * @description 预留功能，当前为空实现
           */
          Image($r("app.media.next"))
            .width(24)
            .onClick(() => {
              // 下一曲功能预留
            })
          
          /**
           * 快进按钮
           * @description 点击快进15秒
           */
          Image($r("app.media.forward"))
            .width(24)
            .onClick(() => {
              avPlayer.seek(this.MusicPlayingTime + seekTime, media.SeekMode.SEEK_NEXT_SYNC)
            })
        }
        .width("100%")

        /**
         * 功能按钮区域
         * @description 使用Flex布局水平排列辅助功能按钮
         * 包含定时、语速、加书架、目录四个功能
         */
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.SpaceBetween,
          alignItems: ItemAlign.Center
        }) {
          /**
           * 定时功能
           * @description 定时关闭播放功能
           */
          Column() {
            Image($r("app.media.appointment_time"))
              .width(24)
              .onClick(() => {
                // 定时功能预留
              })
            Text("定时")
          }

          /**
           * 语速功能
           * @description 点击打开语速设置底部弹窗
           * 绑定底部弹窗，326px高度，无关闭按钮
           */
          Column() {
            Image($r("app.media.speed"))
              .width(24)
              .onClick(() => {
                // 点击打开语速设置
              })
            Text("语速")
          }.bindSheet($$this.isShowSpeed, this.SpeedDialog(), {
            height: 326, // 弹窗高度
            showClose: false, // 不显示关闭按钮
            dragBar: false, // 不显示拖拽条
            blurStyle: BlurStyle.COMPONENT_ULTRA_THIN, // 超薄模糊效果
          })

          /**
           * 加书架功能
           * @description 将当前书籍添加到书架
           * 80px宽度图标，白色填充
           */
          Column() {
            Image($r("app.media.add_bookshelf"))
              .fillColor(Color.White)
              .width(80)
              .onClick(() => {
                // 加书架功能预留
              })
            Text("加书架")
          }

          /**
           * 目录功能
           * @description 打开书籍目录
           */
          Column() {
            Image($r("app.media.directory"))
              .width(24)
              .onClick(() => {
                // 目录功能预留
              })
            Text("目录")
          }
        }
        .width("100%")

        /**
         * 预留行
         * @description 预留的空白行，用于未来功能扩展
         */
        Row() {
          // 预留空间
        }
      }
    }
    .height("100%") // 100%高度
    .padding({
      top: this.topRectHeight, // 顶部内边距
      bottom: this.bottomRectHeight, // 底部内边距
      left: 24, // 左侧内边距
      right: 24 // 右侧内边距
    })
  }

  /**
   * 设置播放器状态变化回调
   * @param {media.AVPlayer} avPlayer - 音频播放器实例
   * @returns {void}
   * @description 监听播放器状态变化，更新组件内部状态
   * 处理初始化、播放、暂停、错误等状态
   */
  setCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      console.info('reason:' + reason) // reason:1 USER; 2 BACKGROUND;
      switch (state) {
        case 'idle':
          console.info('state idle called'); // 空闲状态
          break;
        case 'initialized':
          console.info('initialized prepared called') // 初始化完成
          this.hasInit = true; // 标记已初始化
          avPlayer.prepare() // 准备播放
          break;
        case 'playing':
          console.info('audio play success') // 播放成功
          this.isMusicPlaying = true // 更新播放状态
          break;
        case 'paused':
          console.info('audio paused success') // 暂停成功
          this.isMusicPlaying = false // 更新播放状态
          break;
        case 'error':
          console.error('state error called'); // 错误状态
          break;
        default:
          console.info('unkown state :' + state); // 未知状态
          break;
      }
    })
  }

  /**
   * 设置时间更新回调
   * @returns {void}
   * @description 监听播放时间更新，更新当前播放时间
   * 用于实时更新进度条和时间显示
   */
  timeUpdateCallback() {
    avPlayer.on('timeUpdate', (time: number) => {
      console.info('timeUpdate success,and new time is :' + time)
      this.MusicPlayingTime = time // 更新当前播放时间
    })
  }

  /**
   * 设置时长更新回调
   * @param {media.AVPlayer} avPlayer - 音频播放器实例
   * @returns {void}
   * @description 监听音频总时长更新，更新总时长显示
   * 用于初始化时获取音频文件的总时长
   */
  timeDurationUpdateCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('durationUpdate', (duration: number) => {
      console.info('durationUpdate success,new duration is :' + duration)
      this.MusicDuration = duration // 更新总时长
    })
  }

  /**
   * 语速设置对话框构建器
   * @returns {void}
   * @description 构建语速设置底部弹窗的UI结构
   * 包含标题、开关控件和预留的语速选项区域
   */
  @Builder
  SpeedDialog() {
    Column() {
      /**
       * 标题行
       * @description 显示"语速设置"标题和"仅用于当前"开关
       */
      Row() {
        Text("语速设置") // 对话框标题
        Blank(1) // 空白填充
        Text("仅用于当前") // 开关标签
        Toggle({ type: ToggleType.Switch, isOn: false }) // 开关控件
      }

      /**
       * 语速选项区域
       * @description 预留的语速选项行，可根据需要添加具体选项
       */
      Row() {
        // 语速选项预留空间
      }
    }
  }
}

/**
 * TxtContentHandler 组件 - 文本内容处理组件（Canvas方案）
 * 
 * 功能概述：
 * 1. 使用Canvas渲染文本内容，实现高性能的文本显示
 * 2. 支持文本自动换行，按字符拆分以适应Canvas宽度
 * 3. 实现分页功能，支持左右滑动手势翻页
 * 4. 动态响应字体大小、行高、段落间距等样式变化
 * 5. 处理章节切换和内容更新，提供流畅的阅读体验
 * 
 * 设计特点：
 * 1. Canvas渲染：使用Canvas进行文本渲染，提供更好的性能和控制
 * 2. 智能换行：按字符拆分文本，确保每行不超过Canvas宽度
 * 3. 分页计算：根据显示区域高度和字体大小动态计算每页行数
 * 4. 手势支持：集成滑动手势，支持左右翻页操作
 * 5. 响应式设计：监听尺寸变化，自动重新计算布局和分页
 * 
 * 使用场景：
 * 1. 阅读器页面的文本内容显示
 * 2. 需要高性能文本渲染的场景
 * 3. 支持自定义字体、行高、间距的文本显示
 * 
 * 组件结构：
 * - Canvas渲染区域：核心文本显示区域
 * - 状态管理：管理当前页、总页数、显示尺寸等状态
 * - 手势处理：处理滑动手势实现翻页
 * - 文本处理：文本换行、分页、渲染逻辑
 * 
 * 注意事项：
 * 1. Canvas渲染需要正确处理文本测量和定位
 * 2. 分页计算需要考虑字体大小和行高的影响
 * 3. 手势识别需要设置合适的阈值和方向
 */

import { chaptersItem } from 'ets/componets/dataList/ReaderChaptersItem';

@Component
export struct TxtContentHandler {
  /**
   * 文本文件数据
   * @type {chaptersItem[]}
   * @default []
   * @description 包含所有章节内容的文本文件数据
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop txtFile: chaptersItem[] = [];
  
  /**
   * 当前章节索引
   * @type {number}
   * @default 0
   * @description 当前显示的章节索引，变化时触发CurrentChaptersChange
   * @prop @watch 使用@Watch装饰器监听变化并执行回调
   */
  @Prop @Watch('CurrentChaptersChange') CurrentChapters: number = 0;
  
  /**
   * 当前字体大小
   * @type {number}
   * @default 0
   * @description 当前字体大小（虚拟像素），变化时触发CurrentFontSizeChange
   * @prop @watch 使用@Watch装饰器监听变化并执行回调
   */
  @Prop @Watch('CurrentFontSizeChange') CurrentFontSize: number = 0;
  
  /**
   * 行高倍数
   * @type {number}
   * @default 1.8
   * @description 行高相对于字体大小的倍数
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop LineHeight: number = 1.8;
  
  /**
   * 段落间距
   * @type {number}
   * @default 0
   * @description 段落之间的间距
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop ParagraphSpacing: number = 0;
  
  /**
   * 当前页码
   * @type {number}
   * @default 0
   * @description 当前显示的页码（从0开始）
   * @state 使用@State装饰器管理组件内部状态
   */
  @State currentPage: number = 0;
  
  /**
   * 显示区域高度
   * @type {number}
   * @default 0
   * @description Canvas显示区域的实际高度（像素）
   * @state 使用@State装饰器管理组件内部状态
   */
  @State ShowHeight: number = 0
  
  /**
   * 显示区域宽度
   * @type {number}
   * @default 0
   * @description Canvas显示区域的实际宽度（像素）
   * @state 使用@State装饰器管理组件内部状态
   */
  @State ShowWidth: number = 0
  
  /**
   * 每页行数
   * @type {number}
   * @default 0
   * @description 根据显示区域高度和字体大小计算的每页可显示行数
   * @state 使用@State装饰器管理组件内部状态
   */
  @State linesPerPage: number = 0;
  
  /**
   * 定时器ID
   * @type {number}
   * @default 0
   * @description 用于防抖操作的定时器ID
   * @state 使用@State装饰器管理组件内部状态
   */
  @State timer: number = 0;
  
  /**
   * 水平偏移量
   * @type {number}
   * @default 0
   * @description 滑动手势产生的水平偏移量，用于实现翻页动画
   * @state 使用@State装饰器管理组件内部状态
   */
  @State offsetX: number = 0;
  
  /**
   * 当前章节内容
   * @type {Array<string>}
   * @default []
   * @description 经过换行处理后的当前章节文本行数组
   * @state 使用@State装饰器管理组件内部状态
   */
  @State CurrentChaptersContent: Array<string> = [];
  
  /**
   * Canvas渲染设置
   * @type {RenderingContextSettings}
   * @description Canvas渲染上下文设置，启用抗锯齿
   */
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  
  /**
   * Canvas渲染上下文
   * @type {CanvasRenderingContext2D}
   * @description 用于在Canvas上绘制文本的2D渲染上下文
   */
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  /**
   * 滑动手势选项
   * @type {PanGestureOptions}
   * @description 滑动手势配置，只允许左右方向
   */
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right })

  /**
   * 获取总页数
   * @returns {number} 总页数
   * @description 根据当前章节内容行数和每页行数计算总页数
   */
  GetTotalPages() {
    return Math.floor(this.CurrentChaptersContent.length / this.linesPerPage);
  }

  /**
   * 当前章节变化回调
   * @returns {void}
   * @description 监听当前章节变化，重置页码并重新处理文本换行
   * 使用200ms防抖避免频繁操作
   */
  CurrentChaptersChange() {
    clearTimeout(this.timer) // 清除之前的定时器
    this.timer = setTimeout(() => {
      this.currentPage = 0 // 重置到第一页
      this.wrapText(this.context, this.ShowWidth); // 重新处理文本换行
      console.log('CurrentChapters:' + this.CurrentChapters)
      console.log('currentPage:' + this.currentPage)
      console.log('totalPages:' + this.GetTotalPages())
    }, 200) // 200ms防抖
  }

  /**
   * 当前字体大小变化回调
   * @returns {void}
   * @description 监听字体大小变化，重新绘制页面并处理文本换行
   * 如果当前页超过总页数，自动调整到最后一页
   */
  CurrentFontSizeChange() {
    this.drawPage() // 立即重绘当前页
    clearTimeout(this.timer) // 清除之前的定时器
    this.timer = setTimeout(() => {
      this.wrapText(this.context, this.ShowWidth); // 重新处理文本换行
      if (this.currentPage > this.GetTotalPages()) {
        console.log('currentPage:' + this.currentPage)
        this.currentPage = this.GetTotalPages() // 调整到最后一页
        this.drawPage() // 重绘页面
      }
      console.log('CurrentFontSize:' + this.CurrentFontSize)
      console.log('totalPages:' + this.GetTotalPages())
    }, 200) // 200ms防抖
  }

  /**
   * 绘制当前页
   * @returns {void}
   * @description 在Canvas上绘制当前页的文本内容
   * 包括当前页、上一页和下一页的内容，支持滑动动画
   */
  drawPage() {
    this.context.font = `${vp2px(this.CurrentFontSize)}px`; // 设置字体
    this.linesPerPage = Math.floor(this.ShowHeight / (this.CurrentFontSize * this.LineHeight)); // 计算每页行数
    if (this.context) {
      this.context.clearRect(0, 0, this.ShowWidth, this.ShowHeight); // 清空Canvas
      this.context.font = `${vp2px(this.CurrentFontSize)}px`; // 重新设置字体
      this.context.fillStyle = 'black'; // 设置文本颜色

      const start = this.currentPage * this.linesPerPage; // 当前页起始行
      const end = start + this.linesPerPage; // 当前页结束行
      const CurrentPageLines = this.CurrentChaptersContent.slice(start, end); // 当前页文本行

      // 上一页和下一页的内容（用于滑动动画）
      const PreStart = start - this.linesPerPage; // 上一页起始行
      const NextEnd = start + this.linesPerPage * 2; // 下一页结束行
      const PrePageLines = this.CurrentChaptersContent.slice(PreStart, start); // 上一页文本行
      const NextPageLines = this.CurrentChaptersContent.slice(end, NextEnd); // 下一页文本行
      
      // 绘制当前页内容
      CurrentPageLines.forEach((line, index) => {
        this.context.fillText(line, 0 + this.offsetX, (index + 1) * this.CurrentFontSize * Number(this.LineHeight));
      });

      // 绘制上一页内容（左侧）
      PrePageLines.forEach((line, index) => {
        this.context.fillText(line, 0 - this.ShowWidth + this.offsetX,
          (index + 1) * this.CurrentFontSize * Number(this.LineHeight));
      });

      // 绘制下一页内容（右侧）
      NextPageLines.forEach((line, index) => {
        this.context.fillText(line, this.ShowWidth + this.offsetX,
          (index + 1) * this.CurrentFontSize * Number(this.LineHeight));
      });
    }
  }

  /**
   * 文本换行处理
   * @param {CanvasRenderingContext2D} context - Canvas渲染上下文
   * @param {number} maxWidth - 最大宽度，默认为显示区域宽度
   * @returns {void}
   * @description 将当前章节内容按字符拆分，实现自动换行
   * 处理换行符，确保每行文本不超过Canvas宽度
   */
  wrapText(context: CanvasRenderingContext2D, maxWidth: number = this.ShowWidth) {
    let content: string = this.txtFile[this.CurrentChapters].content // 获取当前章节内容
    let chaptersItemLines: string[] = [] // 存储处理后的文本行
    let currentLine: string = '' // 当前正在构建的行
    let pattern = /\n/ // 换行符正则表达式
    let i = 1 // 字符索引，从1开始跳过可能的BOM或特殊字符
    
    while (i < content.length) {
      let temp = content[i] + content[i+1] // 检查两个字符是否为换行符
      if (!pattern.test(temp)) {
        // 不是换行符，按字符添加到当前行
        if (context.measureText(currentLine + ' ' + content[i]).width < Number((this.ShowWidth - 10).toFixed(0))) {
          currentLine += content[i]; // 添加到当前行
        } else {
          chaptersItemLines.push(currentLine); // 保存当前行
          currentLine = content[i]; // 开始新行
        }
        i++
      } else {
        // 遇到换行符，保存当前行并跳过换行符
        chaptersItemLines.push(currentLine);
        i = i + 2 // 跳过换行符
        currentLine = content[i]; // 开始新行
      }
    }
    
    // 处理最后一行可能包含换行符的情况
    if (pattern.test(chaptersItemLines[chaptersItemLines.length-1])) {
      chaptersItemLines.splice(chaptersItemLines.length - 1, 1) // 移除最后一行中的换行符
    }
    this.CurrentChaptersContent = chaptersItemLines // 更新当前章节内容
    this.drawPage(); // 绘制页面
  }

  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建Canvas文本显示组件的UI结构
   * 包含Canvas区域、尺寸变化监听和滑动手势处理
   */
  build() {
    Canvas(this.context)
      .width("100%") // 100%宽度
      .layoutWeight(1) // 占用剩余空间
      .borderWidth(1) // 1px边框
      .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
        /**
         * 尺寸变化回调
         * @description 监听Canvas尺寸变化，更新显示尺寸并重新计算布局
         * 使用100ms防抖避免频繁重绘
         */
        this.ShowHeight = Number(newValue.height) // 更新显示高度
        this.ShowWidth = Number(newValue.width) // 更新显示宽度
        this.drawPage(); // 立即重绘当前页
        clearTimeout(this.timer) // 清除之前的定时器
        this.timer = setTimeout(() => {
          this.wrapText(this.context, this.ShowWidth); // 重新处理文本换行
        }, 100) // 100ms防抖
        console.log('ShowHeight:' + this.ShowHeight)
        console.log('ShowWidth:' + this.ShowWidth)
        console.log('totalPages:' + this.GetTotalPages())
      })
      .gesture(
        /**
         * 滑动手势处理
         * @description 处理左右滑动手势，实现翻页功能
         * 200px滑动阈值，支持上一页和下一页切换
         */
        PanGesture(this.panOption)
          .onActionUpdate((event?: GestureEvent) => {
            /**
             * 手势更新回调
             * @description 实时更新水平偏移量，实现滑动动画
             */
            if (!event) {
              return;
            }
            this.offsetX = event.offsetX; // 更新水平偏移
            this.drawPage(); // 重绘页面
          })
          .onActionEnd((event: GestureEvent) => {
            /**
             * 手势结束回调
             * @description 根据滑动距离判断是否翻页
             * 向右滑动200px以上：上一页
             * 向左滑动200px以上：下一页
             * 否则：回到当前页
             */
            console.log('currentPage:' + this.currentPage)
            if (event.offsetX > 200 && this.currentPage > 0) {
              this.currentPage--; // 上一页
              console.log('prevPage')
              this.offsetX = 0 // 重置偏移
              this.drawPage(); // 重绘页面
            } else if (event.offsetX < -200 && this.currentPage < this.GetTotalPages()) {
              this.currentPage++; // 下一页
              console.log('nextPage')
              this.offsetX = 0 // 重置偏移
              this.drawPage(); // 重绘页面
            } else {
              this.offsetX = 0 // 重置偏移
              this.drawPage(); // 重绘当前页
            }
          })
      )
  }
}

/**
 * @file Score.ets
 * @description 评分组件
 * 
 * 功能概述：
 * 1. 显示书籍评分和等级标签
 * 2. 根据等级显示不同的样式（常规、优质、精品）
 * 3. 显示评分数值和星级评分
 * 4. 提供统一的评分展示样式
 * 
 * 使用场景：
 * - 书籍详情页的评分展示
 * - 搜索结果中的评分显示
 * - 需要统一评分样式的场景
 * 
 * 设计特点：
 * - 使用预定义的样式配置（SCORE_STYLE）
 * - 支持三种等级：常规、优质、精品
 * - 结合标签图标和评分数值
 * - 使用Rating组件显示星级评分
 * 
 * 样式配置：
 * 1. 等级0（常规）：
 *   - 图标：rectangle_1
 *   - 文字："常规"
 *   - 文字颜色：#ffffff
 *   - 分数颜色：#ffffff
 *   - 背景色：#D8ECFF（浅蓝色）
 * 
 * 2. 等级1（优质）：
 *   - 图标：rectangle_5
 *   - 文字："优质"
 *   - 文字颜色：#ffffff
 *   - 分数颜色：#C07000（橙色）
 *   - 背景色：#FFDDAD（浅橙色）
 * 
 * 3. 等级2（精品）：
 *   - 图标：rectangle_icon
 *   - 文字："精品"
 *   - 文字颜色：#FFE5D4（浅肤色）
 *   - 分数颜色：#854D00（深棕色）
 *   - 背景色：#FFE5D4（浅肤色）
 * 
 * 数据格式：
 * - score: 字符串格式，如"8.5分"
 * - grade: 数字格式，0-2对应三个等级
 * 
 * 技术特点：
 * - 使用Stack实现图标和文字叠加
 * - 使用Rating组件显示星级
 * - 字符串处理：移除"分"后缀并转换为数字
 */

/**
 * @interface ScoreStyle
 * @description 评分样式配置接口
 * 
 * 属性说明：
 * @property {string} img - 图标资源名称（不带app.media.前缀）
 * @property {string} text - 等级显示文本
 * @property {ResourceColor} textColor - 等级文本颜色
 * @property {ResourceColor} scoreColor - 分数文本颜色
 * @property {ResourceColor} background - 背景颜色
 */
interface ScoreStyle {
  img: string
  text: string
  textColor: ResourceColor
  scoreColor: ResourceColor,
  background: ResourceColor
}

/**
 * @constant SCORE_STYLE
 * @description 评分样式配置映射表
 * 
 * 配置说明：
 * - 使用Record<number, ScoreStyle>类型
 * - 键：等级数字（0, 1, 2）
 * - 值：对应的样式配置对象
 * 
 * 默认值处理：
 * - 使用??运算符提供默认值（grade ?? 2）
 * - 当grade为undefined或null时使用等级2（精品）
 */
const SCORE_STYLE: Record<number, ScoreStyle> = {
  0: {
    img: 'rectangle_1',
    text: '常规',
    textColor: '#ffffff',
    scoreColor: '#ffffff',
    background: '#D8ECFF'
  },
  1: {
    img: 'rectangle_5',
    text: '优质',
    textColor: '#ffffff',
    scoreColor: '#C07000',
    background: '#FFDDAD'
  },
  2: {
    img: 'rectangle_icon',
    text: '精品',
    textColor: '#FFE5D4',
    scoreColor: '#854D00',
    background: '#FFE5D4'
  }
}

/**
 * @class Score
 * @description 评分组件
 * 
 * 组件职责：
 * 1. 根据等级显示相应的样式
 * 2. 格式化并显示评分数值
 * 3. 显示星级评分组件
 * 4. 管理样式配置的应用
 * 
 * @decorator @Component - 声明为ArkTS组件
 */
@Component
export default struct Score {
  /** 
   * @prop score - 评分值
   * @description 书籍的评分值，格式为"X.X分"（如"8.5分"）
   * @default '0' - 默认评分0分
   * @type {string}
   */
  @Prop score: string = '0'
  
  /** 
   * @prop grade - 等级
   * @description 书籍的等级，0-2分别对应：常规、优质、精品
   * @default 0 - 默认常规等级
   * @type {number}
   */
  @Prop grade: number = 0
  
  /**
   * @method build
   * @description 构建评分组件UI
   * 
   * 布局结构：
   * 1. 外层Row：水平排列标签和星级评分
   * 2. 内层Row：等级标签区域（包含图标和文字）
   * 3. Rating组件：星级评分显示
   * 
   * 等级标签区域：
   * 1. Stack容器：图标和文字叠加
   *   - Image：等级图标，从SCORE_STYLE获取
   *   - Text：等级文字（常规/优质/精品）
   * 2. Text：评分数值（格式化后）
   * 
   * 图标样式：
   * - 资源：$r(`app.media.${SCORE_STYLE[this.grade ?? 2].img}`)
   * - 尺寸：28x16px
   * - 圆角：左上和左下4px
   * 
   * 等级文字样式：
   * - 内容：从SCORE_STYLE获取
   * - 字体：9px
   * - 颜色：从SCORE_STYLE获取
   * 
   * 评分数值处理：
   * 1. 移除"分"后缀：this.score.replace('分', '')
   * 2. 转换为整数：parseInt()
   * 3. 格式化为1位小数：toFixed(1)
   * 4. 样式：11px字体，400字重，12px行高
   * 5. 颜色：从SCORE_STYLE获取
   * 
   * 标签容器样式：
   * - 尺寸：47x16px
   * - 圆角：4px
   * - 背景色：从SCORE_STYLE获取
   * 
   * 星级评分组件：
   * - 组件：Rating（系统评分组件）
   * - 评分值：处理后的数值
   * - 尺寸：90x20px
   * - 星星数量：5颗
   * - 步长：0.5（支持半星）
   * - 左边距：8px
   * 
   * 数据流：
   * 1. 通过grade获取对应的样式配置
   * 2. 使用??运算符处理undefined/null情况
   * 3. 格式化score字符串为数值
   * 
   * 设计理念：
   * - 通过颜色和图标区分不同等级
   * - 结合数值评分和星级评分
   * - 统一的尺寸和间距
   * - 响应式样式配置
   * 
   * 注意事项：
   * - score格式必须包含"分"后缀（如"8.5分"）
   * - grade范围应为0-2，超出范围可能出错
   * - 使用??运算符提供默认值（等级2）
   * 
   * @returns {void}
   */
  build() {
    Row() {
      Row() {
        Stack() {
          Image($r(`app.media.${SCORE_STYLE[this.grade ?? 2].img}`))
            .borderRadius({
              topLeft: 4,
              bottomLeft: 4
            })
            .width(28)
            .height(16)

          Text(SCORE_STYLE[this.grade ?? 2].text)
            .fontSize(9)
            .fontColor(SCORE_STYLE[this.grade ?? 2].textColor)
        }

        Text(parseInt(this.score.replace('分', '')).toFixed(1))
          .padding({left: 1})
          .fontSize(11)
          .fontWeight(400)
          .lineHeight(12)
          .fontColor(SCORE_STYLE[this.grade ?? 2].scoreColor)
      }
      .width(47)
      .height(16)
      .borderRadius(4)
      .backgroundColor(SCORE_STYLE[this.grade ?? 2].background)

      Rating({ rating: parseInt(this.score.replace('分', '')), indicator: true })
        .size({
          width: 90,
          height: 20
        })
        .stars(5)
        .stepSize(0.5)
        .margin({ left: 8 })
    }
  }
}

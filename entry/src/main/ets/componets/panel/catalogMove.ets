/**
 * catalogMove 组件 - 目录移动面板组件
 * 
 * 功能概述：
 * 1. 提供书籍目录移动功能，支持将选中的书籍移动到不同的分组
 * 2. 显示现有书籍分组列表，支持添加新的分组
 * 3. 实现分组选择、确认移动、取消操作等完整流程
 * 4. 集成对话框系统，提供用户友好的交互体验
 * 5. 处理书籍数据的更新和同步
 * 
 * 设计特点：
 * 1. 面板布局：使用全屏面板显示分组选择界面
 * 2. 分组网格：使用Flex布局实现分组标签的网格显示
 * 3. 对话框集成：集成添加分组和确认移动两个对话框
 * 4. 数据绑定：使用@Link和@Prop实现组件间数据通信
 * 5. 交互反馈：提供提示消息和确认机制
 * 
 * 使用场景：
 * 1. 书籍管理页面中的批量移动分组功能
 * 2. 需要重新分类书籍的界面
 * 3. 书籍分组管理操作
 * 
 * 组件结构：
 * - 标题区域：显示"移动分组"标题
 * - 分组列表区域：可滚动的分组标签网格
 * - 操作区域：取消按钮
 * - 对话框系统：添加分组对话框和确认移动对话框
 * 
 * 注意事项：
 * 1. 需要正确处理书籍数据的双向绑定
 * 2. 对话框状态管理需要确保数据一致性
 * 3. 分组名称需要避免重复
 */

import CommonConstants from '../../common/constants/CommonConstants'
import addBookTypeDialog from '../common/addBookTypeDialog'
import confirmDialogExample from '../common/confirmDialog'
import { showMessage } from '../common/promptShow'
import { BookList } from '../dataList/bookList'

@Component

export default struct catalogMove{
  /**
   * 面板显示状态
   * @type {boolean}
   * @description 控制移动面板的显示/隐藏
   * @link 使用@Link装饰器实现与父组件的双向绑定
   */
  @Link isShow:boolean
  
  /**
   * 书籍类型列表
   * @type {string[]}
   * @default ['玄幻','修真', '都市', '穿越', '网游', '科幻', '历史']
   * @description 预定义的书籍分组类型列表
   * @state 使用@State装饰器管理组件内部状态
   */
  @State BooTypeList:string[] = ['玄幻','修真', '都市', '穿越', '网游', '科幻', '历史']
  
  /**
   * 选中书籍数量
   * @type {number}
   * @default 0
   * @description 当前选中的书籍数量，用于验证操作条件
   * @prop 使用@Prop装饰器接收父组件传递的数据
   */
  @Prop checkNumber:number = 0
  
  /**
   * 选中书籍列表
   * @type {BookList[]}
   * @description 双向绑定的选中书籍数据列表
   * @link 使用@Link装饰器实现与父组件的双向绑定
   */
  @Link checkBookList:BookList[]

  /**
   * 点击的书籍类型
   * @type {string}
   * @default ''
   * @description 记录用户点击的分组类型，用于后续移动操作
   */
  @State clickBookType:string = ''

  /**
   * 构建组件UI
   * @returns {void}
   * @description 构建目录移动面板的主要UI结构
   * 包含标题区域、分组列表区域和操作区域
   */
  build() {
    Column() {
      /**
       * 标题区域
       * @description 显示"移动分组"标题，使用加粗字体
       * 四周内边距提供舒适的视觉间距
       */
      Column(){
        Text('移动分组').fontSize(16).fontWeight(700)
      }.padding({right:20,left:20,top:12,bottom:12})
      
      /**
       * 分组列表滚动区域
       * @description 使用Scroll容器包裹Flex布局的分组标签
       * 65%高度，关闭滚动条，20px内边距
       */
      Scroll(){
        Flex({
          direction: FlexDirection.Row, wrap: FlexWrap.Wrap,alignContent:FlexAlign.Center,
          justifyContent:FlexAlign.Start
        }){
          this.title('') // 添加分组按钮
          ForEach(this.BooTypeList,(item:string)=>{
            this.title(item) // 分组标签
          })
        }
        .padding(20)
      }
      .height('65%')
      .scrollBar(BarState.Off) // 关闭滚动条
      
      /**
       * 取消按钮区域
       * @description 点击隐藏面板，返回上一级
       * 使用16px字体，400字重，24px行高
       */
      Column() {
        Text('取消').fontSize(16).fontWeight(400)
          .lineHeight(24)
      }
      .onClick(()=>{
        this.isShow = false // 隐藏面板
      })
      .alignItems(HorizontalAlign.Center)
      .padding({
        left: 32,
        right:32,
        top: 16
      })
    }
    .width(CommonConstants.FULL_WIDTH) // 使用全宽常量
    .height(CommonConstants.FULL_HEIGHT) // 使用全高常量
  }
  /**
   * 分组标签构建器
   * @param {string} title - 分组标题，空字符串表示添加按钮
   * @returns {void}
   * @description 构建单个分组标签的UI，支持添加按钮和分组标签两种模式
   * 
   * 设计特点：
   * 1. 添加按钮模式：显示加号图标
   * 2. 分组标签模式：显示分组名称，支持文本溢出处理
   * 3. 统一样式：固定尺寸、背景色和内边距
   * 4. 点击事件：根据模式触发不同操作
   */
  @Builder title(title:string) {
    Column() {
      if (title === ''){
        /**
         * 添加分组按钮
         * @description 显示加号图标，点击打开添加分组对话框
         */
        Image($r('app.media.add')).width(24)
      } else {
        /**
         * 分组标签
         * @description 显示分组名称，使用省略号处理长文本
         * 14px字体，单行显示，溢出显示省略号
         */
        Text(title).fontSize(14).textOverflow({
          overflow:TextOverflow.Ellipsis
        }).ellipsisMode(EllipsisMode.END).maxLines(1)
      }
    }
    .onClick(()=>{
      /**
       * 标签点击事件处理
       * @description 根据标签类型执行不同操作
       * 1. 添加按钮：打开添加分组对话框
       * 2. 分组标签：验证选中数量，打开确认移动对话框
       */
      if(title === ''){
        this.addBookType?.open() // 打开添加分组对话框
        return
      }
      if (this.checkNumber === 0) {
        showMessage('请选择要移动的内容') // 提示未选择内容
        return
      }
      console.log(JSON.stringify(this.checkBookList)) // 调试日志
      this.clickBookType = title // 记录选中的分组
      this.clickBookTypeDialog?.open() // 打开确认移动对话框
    })
    .margin({ left: 16, bottom: 16 }) // 左和底部外边距
    .width(85).height(36) // 固定尺寸
    .backgroundColor('rgba(0, 0, 0,0.06)') // 浅灰色背景
    .padding({
      left:16,
      right:16,
      top:8,
      bottom:8
    }) // 内边距
  }

  /**
   * 新分组名称
   * @type {string}
   * @default '哈哈哈'
   * @description 用于添加新分组时输入的分组名称
   * 注意：默认值'哈哈哈'可能为测试用途，实际使用时应为空字符串
   */
  @State bookType:string = '哈哈哈'

  /**
   * 添加分组对话框控制器
   * @type {CustomDialogController | null}
   * @description 控制添加分组对话框的显示和隐藏
   * 配置对话框的构建器、取消回调、自动关闭等属性
   */
  addBookType: CustomDialogController | null = new CustomDialogController({
    builder: addBookTypeDialog({
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
      bookType: this.bookType
    }),
    cancel: this.exitDialog, // 对话框取消回调
    autoCancel: true, // 点击外部自动关闭
    alignment: DialogAlignment.Center, // 居中显示
    // offset: { dx: 0, dy: '-40%' }, // 垂直偏移（注释状态）
    gridCount: 4, // 网格数量
    customStyle: false, // 不使用自定义样式
    cornerRadius: 25 // 25px圆角
  })

  /**
   * 退出对话框回调
   * @returns {void}
   * @description 对话框关闭时清空分组名称
   */
  exitDialog(){
    this.bookType = ''
  }
  
  /**
   * 取消添加分组
   * @returns {void}
   * @description 用户取消添加分组操作，清空分组名称
   */
  onCancel(){
    this.bookType = ''
  }
  
  /**
   * 确认添加分组
   * @returns {void}
   * @description 用户确认添加分组，验证并添加新分组
   * 
   * 处理逻辑：
   * 1. 检查分组是否已存在
   * 2. 如果存在：显示提示消息
   * 3. 如果不存在：添加到分组列表，显示成功消息
   * 4. 清空分组名称输入
   */
  onAccept(){
    console.log(this.bookType) // 调试日志
    //对比bookType看是否BooTypeList数组中存在
    if (this.BooTypeList.includes(this.bookType)) {
      showMessage(`已存${this.bookType}分组`)
      this.bookType= ''
      return
    } else{
      this.BooTypeList.push(this.bookType)
      this.bookType= ''
      showMessage(`已添加${this.bookType}分组`)
    }
  }

  /**
   * 删除缓存标志
   * @type {boolean}
   * @default false
   * @description 用于确认对话框的删除缓存选项
   * 当前代码中声明但未使用，可能为预留功能
   */
  @State delCache:boolean = false
  
  /**
   * 确认移动分组对话框控制器
   * @type {CustomDialogController | null}
   * @description 控制确认移动分组对话框的显示和隐藏
   * 配置对话框标题、确认和取消回调等属性
   */
  clickBookTypeDialog: CustomDialogController | null = new CustomDialogController({
    builder: confirmDialogExample({
      cancel: ()=> { this.clickBookCancel() },
      confirm: ()=> { this.clickBookAccept() },
      title:`移动到${this.clickBookType}`, // 动态标题
      delCache:this.delCache
    }),
    cancel: this.clickExitDialog, // 对话框取消回调
    autoCancel: true, // 点击外部自动关闭
    alignment: DialogAlignment.Center, // 居中显示
    gridCount: 4, // 网格数量
    customStyle: false, // 不使用自定义样式
    cornerRadius: 25, // 25px圆角
  })

  /**
   * 取消移动分组
   * @returns {void}
   * @description 用户取消移动分组操作，清空选中的分组类型
   */
  clickBookCancel() {
    this.clickBookType = ''
  }

  /**
   * 确认移动分组
   * @returns {void}
   * @description 用户确认移动分组，执行书籍移动操作
   */
  clickBookAccept() {
    this.mobileBookType()
  }

  /**
   * 退出确认对话框回调
   * @returns {void}
   * @description 对话框关闭时清空选中的分组类型
   */
  clickExitDialog() {
    this.clickBookType = ''
  }
  
  /**
   * 显示书籍列表
   * @type {BookList[]}
   * @description 双向绑定的显示书籍列表数据
   * @link 使用@Link装饰器实现与父组件的双向绑定
   * 用于更新书籍的分组信息
   */
  @Link showBookList:BookList[]
  
  /**
   * 移动书籍分组
   * @returns {void}
   * @description 将选中的书籍移动到指定的分组
   * 
   * 处理逻辑：
   * 1. 遍历选中的书籍列表
   * 2. 在显示书籍列表中查找匹配的书籍ID
   * 3. 更新匹配书籍的分组类型为点击的分组
   * 4. 清空选中书籍列表
   * 
   * 注意：找到第一个匹配项后即返回，可能需要优化以处理多个匹配
   */
  mobileBookType(){
    //循环遍历checkBookList当bookId和showBookList中的bookId相同时，将showBookList bookType改为clickBookType
    for (let i = 0; i < this.checkBookList.length; i++) {
      for (let j = 0; j < this.showBookList.length; j++) {
        if (this.checkBookList[i].bookId === this.showBookList[j].bookId) {
          this.showBookList[j].bookType = this.clickBookType
          console.log(JSON.stringify(this.showBookList) + 'test')
          return
        }
      }
    }
    this.checkBookList = []
  }
}

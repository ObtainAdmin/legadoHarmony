/**
 * 添加书籍到书单组件
 * 
 * 功能概述：
 * 1. 提供搜索功能，方便用户查找书籍
 * 2. 显示可添加的书籍列表，支持多选操作
 * 3. 支持全选/取消全选功能，提高操作效率
 * 4. 集成分组搜索功能，可按分组筛选书籍
 * 5. 提供添加确认功能，将选中的书籍添加到书单
 * 
 * 使用场景：
 * - 在新建书单时添加书籍
 * - 在修改书单时添加更多书籍
 * - 在其他需要批量选择书籍的场景中使用
 * 
 * 组件特点：
 * - 使用弹窗或全屏覆盖形式显示
 * - 顶部包含搜索栏和关闭按钮
 * - 中部显示书籍列表，支持滚动浏览
 * - 底部提供全选和添加操作按钮
 * - 支持主题颜色适配，保持UI一致性
 */
import { ThemeStorageKey } from '../../../../../common/constants/Theme'
import { ThemeItem } from '../../../../../common/model/Theme'
import { showMessage } from '../../../../../componets/common/promptShow'
import groupTypeSearch from '../../../../../componets/group/GroupTypeSearch'
import booksDao from '../../../../../database/dao/BooksDao'
import { Books } from '../../../../../database/entities/Books'
import BookInfoManage from './BookInfoManage'

@Component
export default struct newAddShelf{
  /** 
   * 搜索关键词，用于筛选书籍
   * 通过@State装饰器管理组件内部状态
   */
  @State searchValue:string = ''
  
  /** 
   * 当前索引，用于区分不同的书籍类型或分类
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop currentIndex:number
  
  /** 
   * 书籍列表数据，包含搜索到的所有书籍
   * 通过@State装饰器管理组件内部状态
   */
  @State bookList:Books[] = []
  
  /** 
   * 添加书籍回调函数，当用户点击添加按钮时触发
   * 参数：选中的书籍ID数组
   * 默认为空函数，父组件需要覆盖此函数以处理添加逻辑
   */
  addBookList:Function = (_selectBookId:number[])=>{

  }
  
  /** 
   * 上次已选择的书籍ID数组，用于初始化选中状态
   * 通过@Prop装饰器从父组件传递，单向绑定
   */
  @Prop lastBookIds:number []
  
  /** 
   * 关闭回调函数，当用户点击关闭按钮时触发
   * 默认为空函数，父组件需要覆盖此函数以关闭弹窗
   */
  close:Function = ()=>{}
  
  /** 
   * 选中书籍状态记录，键为书籍ID，值为是否选中
   * 通过@State装饰器管理组件内部状态
   * 使用@Watch装饰器监听变化，变化时触发dataCheckList方法
   */
  @State @Watch('dataCheckList')selectBookId:Record<number, boolean> = {}
  
  /** 
   * 选中书籍ID列表，从selectBookId中提取的选中项
   * 通过@State装饰器管理组件内部状态
   */
  @State selectBookIdList:number[] = []
  
  /** 
   * 顶部矩形高度，用于适配不同屏幕的安全区域
   * 通过@StorageLink与AppStorage同步，自动响应屏幕变化
   */
  @StorageLink('topRectHeight') topRectHeight: number = 0
  
  /** 
   * 底部矩形高度，用于适配不同屏幕的安全区域
   * 通过@StorageLink与AppStorage同步，自动响应屏幕变化
   */
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0
  
  /** 
   * 书籍类型编号，用于分组筛选
   * 通过@State装饰器管理组件内部状态
   * 使用@Watch装饰器监听变化，变化时触发getBookList方法
   */
  @State @Watch('getBookList')bookTypeNumber:number = 2
  
  /** 
   * 是否显示分组搜索弹窗
   * true: 显示分组搜索界面
   * false: 隐藏分组搜索界面
   */
  @State groupCoverShow: boolean = false
  
  /** 
   * 搜索到的书籍ID列表，用于分组搜索功能
   * 通过@State装饰器管理组件内部状态
   * 使用@Watch装饰器监听变化，变化时触发searchBook方法
   */
  @State @Watch('searchBook')searchBookList:number[] = []

  /** 
   * 主题颜色配置
   * 通过@StorageProp从AppStorage获取，自动响应主题变化
   */
  @StorageProp(ThemeStorageKey.THEME) theme: ThemeItem = {} as ThemeItem
  
  /**
   * 处理分组搜索结果的书籍选择
   * 
   * 功能：将分组搜索到的书籍ID添加到选中列表
   * 逻辑：
   * 1. 检查searchBookList是否为空，为空则直接返回
   * 2. 遍历searchBookList，将每个书籍ID添加到selectBookId中
   * 3. 清空searchBookList，关闭分组搜索弹窗
   */
  searchBook(){
    if (this.searchBookList.length === 0 ) return
    if (this.searchBookList.length > 0) {
      this.searchBookList.forEach((item)=>{
        this.selectBookId[item] = true  // 将搜索到的书籍标记为选中
      })
      this.searchBookList = []          // 清空搜索列表
      this.groupCoverShow = false       // 关闭分组搜索弹窗
    }
  }
  
  /**
   * 组件显示时初始化数据
   * 
   * 功能：初始化选中状态和书籍列表
   * 逻辑：
   * 1. 如果lastBookIds存在，将其中的书籍ID添加到选中状态
   * 2. 调用getBookList方法加载初始书籍列表
   */
  aboutToAppear(): void {
    if (this.lastBookIds) {
      this.lastBookIds.forEach((item)=>{
        this.selectBookId[item] = true  // 初始化选中状态
      })
    }
    this.getBookList()  // 加载书籍列表
  }
  
  /**
   * 获取书籍列表
   * 
   * 功能：根据搜索条件和类型从数据库查询书籍
   * 使用booksDao.search方法，支持类型筛选和关键词搜索
   * 查询完成后更新bookList和全选状态
   */
  getBookList(){
    booksDao.search({
      type:this.currentIndex,        // 书籍类型
      searchKey:this.searchValue,    // 搜索关键词
      bookGroup:this.bookTypeNumber  // 分组类型
    }).then((val)=>{
      this.bookList = val  // 更新书籍列表
      this.allSelect = this.bookList.length === this.selectBookIdList.length  // 更新全选状态
    })
  }
  
  /**
   * 构建组件UI
   * 
   * 布局结构：
   * 1. 使用Flex布局，垂直方向，两端对齐
   * 2. 顶部：标题栏（关闭按钮、标题、搜索栏）
   * 3. 中部：书籍列表区域（包含分组搜索弹窗）
   * 4. 底部：操作栏（全选/取消全选、添加按钮）
   * 
   * 设计特点：
   * - 适配屏幕安全区域（topRectHeight和bottomRectHeight）
   * - 支持分组搜索功能，可按分组筛选书籍
   * - 书籍列表支持滚动浏览
   * - 底部操作栏固定显示
   */
  build() {
    Flex({
      justifyContent:FlexAlign.SpaceBetween,  // 两端对齐
      direction:FlexDirection.Column          // 垂直方向
    }
    ){
     // 顶部：标题栏区域
     Column(){
       Column({
         space:5  // 子元素间距5px
       }) {
         // 标题栏：关闭按钮和标题
         Flex({
           alignItems:ItemAlign.Center,      // 垂直居中对齐
           justifyContent:FlexAlign.Center   // 水平居中对齐
         }){
           // 关闭按钮
           Image($r('app.media.close'))      // 资源引用：关闭图标
             .width(25)
             .height(25)
             .fillColor('rgba(0, 0, 0, 0.88)')  // 黑色，88%透明度
             .onClick(()=>{
               this.close()  // 触发关闭回调
             })
           
           // 标题
           Column(){
             Text('添加书籍')
               .fontSize(16)
               .lineHeight(24)
               .fontWeight(500)
               .textAlign(TextAlign.Center)      // 居中对齐
               .fontColor('rgba(0, 0, 0, 0.88)') // 黑色，88%透明度
           }
           .margin({right:20})  // 右边距20px
           .width('100%')       // 宽度100%
         }
         
         // 搜索栏
         Search({placeholder:'搜索',value:this.searchValue})
           .onChange((value:string)=>{
             // 搜索关键词变化时触发
             if (this.searchValue !== value) {
               this.searchValue = value  // 更新搜索关键词
               this.getBookList()        // 重新加载书籍列表
             }
             // 清空搜索时更新全选状态
             if(value.length === 0){
               this.allSelect = this.bookList.length === this.selectBookIdList.length
             }
           })
       }
       .padding({left:20,right:20,top:12,bottom:12})  // 内边距
       .align(Alignment.Center)  // 居中对齐
     }
     
    // 中部：书籍列表区域（包含分组搜索弹窗）
    Stack(){
      // 分组搜索弹窗组件
      groupTypeSearch({
        bookTypeNumber:this.bookTypeNumber,  // 书籍类型编号
        groupCoverShow:this.groupCoverShow,  // 是否显示弹窗
        searchBookList:this.searchBookList   // 搜索到的书籍ID列表
      })
        .zIndex(9)  // 确保弹窗在最上层
      
      // 书籍列表区域
      Column(){
        // 滚动区域：书籍列表
        Scroll(){
          Column(){
            // 遍历书籍列表，渲染每个书籍项
            ForEach(this.bookList, (item: Books,index:number) => {
              BookInfoManage({
                bookData:item,           // 当前书籍数据
                isManage:true,           // 显示复选框（管理模式）
                checkGroup:this.selectBookId  // 选中状态记录
              })
            })
          }
        }
        .layoutWeight(1)  // 占据剩余空间
        .align(Alignment.TopStart)  // 顶部对齐
        .scrollBar(BarState.Off)    // 关闭滚动条
        .padding({left:15,right:15})  // 左右内边距
        
        Divider().strokeWidth(0.5)  // 分割线
        
        // 底部操作栏
        this.footerTitle()
      }
      .margin({top:30})  // 顶部边距30px
    }
    .layoutWeight(1)
    .alignContent(Alignment.Top)
    }
    .padding({
      top:this.topRectHeight,
      bottom:this.bottomRectHeight
    })
  }
  /** 
   * 全选状态标识
   * true: 所有书籍都已选中
   * false: 不是所有书籍都选中
   */
  @State allSelect:boolean = false
  
  /**
   * 底部操作栏构建器
   * 
   * 功能：构建底部操作栏，包含全选/取消全选和添加按钮
   * 布局结构：
   * 1. 左侧：全选/取消全选按钮，根据allSelect状态显示不同文本
   * 2. 右侧：添加按钮，显示选中数量和添加功能
   * 
   * 交互功能：
   * - 点击全选按钮：切换全选状态，更新所有书籍的选中状态
   * - 点击添加按钮：将选中的书籍ID传递给父组件处理
   * 
   * 设计特点：
   * - 全选按钮宽度50%，添加按钮宽度50%
   * - 添加按钮根据选中数量显示不同颜色（无选中时使用次要颜色）
   * - 显示选中数量，方便用户确认选择
   */
  @Builder
  footerTitle() {
      Flex({
        justifyContent:FlexAlign.SpaceBetween  // 两端对齐
      }){
        // 左侧：全选/取消全选按钮
        Column(){
          Text(!this.allSelect?'全选':'取消全选')  // 根据状态显示不同文本
            .fontSize(16)
            .fontWeight(400)
            .fontColor('rgba(0, 0, 0, 0.88)')
        }
        .onClick(()=>{
          if (this.bookList.length === 0) {
            showMessage('页面暂无操作数据')  // 无数据时提示
            return
          }
           this.allSelect = !this.allSelect  // 切换全选状态
           this.dataMoveCheckList(this.allSelect)  // 更新所有书籍的选中状态
        })
        .justifyContent(FlexAlign.Center)  // 居中对齐
        .width('50%')  // 宽度50%
        
        // 右侧：添加按钮
        Row(){
          Text('添加').fontSize(16)
            .fontWeight(400)
            .fontColor(this.selectBookIdList.length === 0?this.theme.secondColor:this.theme.mainColor)  // 无选中时使用次要颜色
          Text(`(${this.selectBookIdList.length??0})`)  // 显示选中数量
            .fontSize(16)
            .fontWeight(400)
            .fontColor(this.selectBookIdList.length === 0?this.theme.secondColor:this.theme.mainColor)  // 无选中时使用次要颜色
        }
        .justifyContent(FlexAlign.Center)  // 居中对齐
        .width('50%')  // 宽度50%
        .onClick(()=>{
          this.dataCheckList()  // 更新选中列表
          this.addBookList(this.selectBookIdList)  // 触发添加回调
        })
      }
      .padding({
        top:16,
        bottom:16,
        left:32,
        right:32
      })
      .backgroundColor(Color.White)  // 白色背景
  }

  /**
   * 批量更新书籍选中状态
   * 
   * 功能：根据全选状态批量更新所有书籍的选中状态
   * 逻辑：
   * 1. 清空现有的选中状态记录
   * 2. 遍历书籍列表，为每个有ID的书籍设置选中状态
   * 3. 调用dataCheckList方法更新选中列表和全选状态
   * 
   * @param value 是否选中（true-全选，false-取消全选）
   */
  dataMoveCheckList(value:boolean){
    this.selectBookId = {};  // 清空选中状态记录
    this.bookList.forEach((item)=>{
      item.id?this.selectBookId[item.id] = value:''  // 为有ID的书籍设置选中状态
    })
    this.dataCheckList()  // 更新选中列表和全选状态
  }

  /**
   * 更新选中书籍ID列表
   * 
   * 功能：从selectBookId中提取选中的书籍ID，更新selectBookIdList
   * 逻辑：
   * 1. 获取selectBookId的所有键（书籍ID）
   * 2. 过滤出值为true（选中）的键
   * 3. 将字符串键转换为数字ID
   * 4. 更新selectBookIdList数组
   * 5. 更新全选状态（allSelect）
   */
  dataCheckList(){
    const keys = Object.keys(this.selectBookId)
      .filter(key => this.selectBookId[Number(key)])  // 过滤选中的书籍
      .map(key => Number(key));  // 转换为数字ID
    this.selectBookIdList = keys  // 更新选中书籍ID列表
    this.allSelect = this.bookList.length === this.selectBookIdList.length  // 更新全选状态
  }
}

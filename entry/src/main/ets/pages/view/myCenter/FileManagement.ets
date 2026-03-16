// ============ 导入模块 ============
import { MyCenterTitle } from '../../../componets/myCenter/MyCenterTitle' // 我的页面标题栏组件
import MyCenterFileSearch from  '../../../componets/myCenter/MyCenterFileSearch' // 文件搜索组件
import FolderFileDataSource from '../../../common/LazyIDataSource/FileListDataSource' // 文件列表数据源
import FolderFileListItem from '../../../componets/myCenter/FolderFileListItem' // 文件列表项组件
import FolderAndFileItem from '../../../componets/dataList/FolderAndFileItem' // 文件夹和文件项模型
import RenameDialog from '../dialog/RenameDialog' // 重命名对话框组件
import { hilog } from '@kit.PerformanceAnalysisKit' // HILOG 日志打印工具（性能分析包）

/**
 * @author 惟草木之零落兮
 * @date 2024/5/22 14:33
 * @description: 文件管理页面 - WebDav/本地文件浏览和管理
 */

// ============ 持久化存储定义 ============

/** PersistentStorage.persistProp('onSelect', 0)
 * 持久化属性：当前选中的索引，默认值 0
 * 用于在页面切换时保持选中状态
 */
PersistentStorage.persistProp('onSelect', 0);

/** PersistentStorage.persistProp('webDavTitle', "坚果云")
 * 持久化属性：WebDav 服务标题，默认"坚果云"
 * 可在用户自定义后保持不变
 */
PersistentStorage.persistProp('webDavTitle', "坚果云");

/**
 * @Entry - 页面入口装饰器
 * @Component - 组件装饰器
 * @struct FileManagement - 文件管理页面组件类
 * 
 * 功能说明：
 *   - WebDav 云服务文件浏览
 *   - 本地文件浏览
 *   - 文件搜索
 *   - 文件夹和文件管理（重命名等）
 *   - 支持 LazyForEach 懒加载优化大列表
 */
@Entry
@Component
struct FileManagement {
    
    // ============ 状态变量 ============
    
    /** @State title: string = AppStorage.get("webDavTitle") || "坚果云"
     * 当前显示的服务名称
     * 从全局 AppStorage 获取持久化的 webDavTitle
     * 若不存在则使用默认值"坚果云"
     */
    @State title: string = AppStorage.get("webDavTitle") || "坚果云"

    /** @State fileList: FolderFileDataSource = new FolderFileDataSource()
     * 文件和文件夹数据源
     * FolderFileDataSource: 支持 LazyForEach 的自定义数据源类
     * 包含 pushData 方法用于动态添加数据
     */
    @State fileList: FolderFileDataSource = new FolderFileDataSource()

    /** @StorageLink("onSelect") onSelect: number = 0
     * 持久化绑定的选中索引
     * StorageLink: 跨页面共享状态，自动同步
     */
    @StorageLink("onSelect") onSelect: number = 0

    // ============ 对话框控制器 ============
    
    /** dialogController: CustomDialogController | null - 重命名对话框控制器
     * 配置重命名弹窗：
     *   - builder: RenameDialog 组件
     *   - oldName: 原始文件名（坚果云）
     *   - confirm: 确认回调函数
     *   - alignment: 居中对齐
     *   - offset: 无偏移
     *   - customStyle: 启用自定义样式
     */
    dialogController: CustomDialogController | null = new CustomDialogController({
        builder: RenameDialog({
            oldName: "坚果云",
            confirm: this.confirm
        }),
        //autoCancel: true, // 注释掉：不允许点击外部关闭
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: 0 },
        customStyle: true
    })

    /**
     * confirm - 重命名确认处理
     * 
     * @param value - 新名称字符串
     * TODO: 待实现实际的重命名逻辑
     */
    confirm(value: string){
        // 新名字
        // TODO: 更新 title 并持久化保存
    }

    /**
     * aboutToAppear - 组件即将出现时调用
     * 初始化模拟数据用于测试展示
     * 创建 20 个虚拟文件/文件夹项
     */
    aboutToAppear(): void {
        for (let i=0; i < 20; i++){
            this.fileList.pushData({
                title: i < 3 ? `文件夹 ${i}` : `文件 ${i}`, // 前 3 项为文件夹
                icon: i < 3 ? $r("app.media.ic_folder") : $r("app.media.ic_zip") , // 不同图标
                size: i < 3 ? "12 项" : "30M", // 文件夹显示内容数，文件显示大小
                date: "2021/8/13", // 统一日期
                isFolder: i < 3 ? true: false // 标记是否为文件夹
            })
        }
    }

    // ============ UI 构建方法 - build() ============
    
    /**
     * build() - 页面 UI 构建入口
     * 
     * 布局层次：
     * Column
     * ├─ MyCenterTitle (标题栏 + 编辑 + 更多按钮)
     * ├─ MyCenterFileSearch (搜索框)
     * ├─ Row (目录层级栏 - TODO)
     * └─ Column (文件列表区域)
     *    └─ List
     *       └─ LazyForEach(fileList)
     *          └─ FolderFileListItem
     */
    build() {
        Column(){

            // ========== 标题栏 ==========
            MyCenterTitle({
                title: this.title, // 动态标题（可编辑）
                isShowEdit: true, // 显示编辑按钮
                isShowMore: true, // 显示更多按钮
                onEditClickEvent: ()=>{
                    this.dialogController?.open() // 点击编辑打开重命名弹窗
                }
            })

            // ========== 搜索栏 ==========
            MyCenterFileSearch({
                onResultCallBack: (value: string)=>{
                    // value 搜索框值发生变化和提交搜索会触发
                    // TODO 执行搜索，此处应做防抖处理
                    // 建议在 300ms 延迟后执行搜索避免频繁请求
                }
            })

            // ========== 目录层级栏 ==========
            Row(){
                Text("TODO 目录层级") // TODO: 待实现面包屑导航
            }
            .margin({top: 12, bottom: 12})

            // ========== 文件 + 文件夹列表 ==========
            Column(){
                List({space: 20}){ // 列表容器，子项间距 20
                    LazyForEach(this.fileList, (item: FolderAndFileItem, index: number)=>{
                        ListItem(){
                            FolderFileListItem({
                                data: item // 传递数据项到列表组件
                            })
                        }
                    })
                }
                .width("100%") // 占满宽度
                .height("100%") // 占满高度
            }
            .width("100%")
            .layoutWeight(1) // 占据剩余空间（在 Scroll 中有效）
        }
        .padding({left: 20, right: 20}) // 左右内边距 20 像素
    }
}

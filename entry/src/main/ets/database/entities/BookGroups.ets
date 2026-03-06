/**
 * @author 2008
 * @datetime 2024/7/22 22:39
 * @className: BookGroup
 * 
 * 书籍分组实体类 (Book Groups Entity)
 * 
 * 功能说明：
 * 1. 定义书籍分组的数据结构
 * 2. 提供业务层使用的分组对象模型
 * 3. 支持分组与数据库实体之间的转换
 * 4. 管理分组的基本属性和业务逻辑
 * 
 * 核心属性：
 * - 分组基本信息：ID、名称、描述、封面
 * - 分组显示控制：是否显示、是否置顶、排序
 * - 分组类型：小说、漫画、有声
 * - 分组权限：是否可删除、是否系统分组
 * - 分组内容：包含的书籍ID列表
 * 
 * 使用场景：
 * - 书架分组管理
 * - 分组创建和编辑
 * - 分组显示控制
 * - 书籍分组关联管理
 */
@Observed
export class BookGroups {
  //分组Id
  groupId?:number;
  //分组名称
  groupName:string = "";
  //封面是否仅用当前分组
  coverOnly:boolean = false;
  //封面样式类型 0默认1自定义2全图
  coverType:number = 0;
  //分组封面
  coverUrl?:string;
  //分组描述
  groupDescribe?:string;
  //排序
  sort:number = 1;
  //是否自动刷新
  enableRefresh:boolean = true;
  //是否显示
  show:boolean = true;
  //小说0/漫画1/有声2
  groupType:number = 0;
  //创建时间
  createTime:number = 0;
  //更新时间
  updateTime:number = 0;
  //书籍排序
  bookSort:number = -1;
  //更新提醒
  canUpdate:boolean = false
  //是否可删除
  canDelete:boolean = true
  //是否置顶
  isTop:boolean = false
  //是否系统参数
  isSystem:boolean = false
  //书籍Id
  bookIds?:string[]
}

export interface BookGroupDb extends Omit<BookGroups, 'bookIds'> {
  // 存在当前分组下的书籍id
  bookIds?: string
}

export const ToBookGroups = (bookGroupsDb: BookGroupDb) => {
  let bookIds = bookGroupsDb.bookIds?.split(',')
  const bookGroups: BookGroups = {
    groupId: bookGroupsDb.groupId,
    groupName: bookGroupsDb.groupName,
    coverOnly: bookGroupsDb.coverOnly,
    coverType: bookGroupsDb.coverType,
    coverUrl: bookGroupsDb.coverUrl,
    groupDescribe: bookGroupsDb.groupDescribe,
    sort: bookGroupsDb.sort,
    enableRefresh: bookGroupsDb.enableRefresh,
    show: bookGroupsDb.show,
    groupType: bookGroupsDb.groupType,
    createTime: bookGroupsDb.createTime,
    updateTime: bookGroupsDb.updateTime,
    bookSort: bookGroupsDb.bookSort,
    canUpdate: bookGroupsDb.canUpdate,
    canDelete: bookGroupsDb.canDelete,
    isTop: bookGroupsDb.isTop,
    isSystem: bookGroupsDb.isSystem,
    bookIds
  }
  return bookGroups
}

export const ToBookGroupsDb = (bookGroups: BookGroups) => {
  let bookIds:string = ''
  if (Array.isArray(bookGroups.bookIds)) {
    bookIds = bookGroups.bookIds.join(',')
  } else {
    if (bookGroups.bookIds) {
      bookIds = bookGroups.bookIds
    }
  }
  const bookGroupsDb: BookGroupDb = {
    groupId: bookGroups.groupId,
    groupName: bookGroups.groupName,
    coverOnly: bookGroups.coverOnly,
    coverType: bookGroups.coverType,
    coverUrl: bookGroups.coverUrl,
    groupDescribe: bookGroups.groupDescribe,
    sort: bookGroups.sort,
    enableRefresh: bookGroups.enableRefresh,
    show: bookGroups.show,
    groupType: bookGroups.groupType,
    createTime: bookGroups.createTime,
    updateTime: bookGroups.updateTime,
    bookSort: bookGroups.bookSort,
    canUpdate: bookGroups.canUpdate,
    canDelete: bookGroups.canDelete,
    isTop: bookGroups.isTop,
    isSystem: bookGroups.isSystem,
    bookIds
  }
  return bookGroupsDb
}

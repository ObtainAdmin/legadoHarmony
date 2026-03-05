/**
 * RSS源工具类 - 管理RSS源历史记录和分组的工具类
 * 
 * 功能：封装RSS源相关的数据库操作，提供RSS源历史记录管理和分组管理功能
 * 核心特性：
 *   1. 历史记录管理：记录RSS源的访问历史，包括最后更新时间
 *   2. 分组管理：管理RSS源的分组，支持添加、查询分组
 *   3. 重复检查：添加分组时检查名称是否重复
 * 使用场景：RSS订阅管理、源分组管理、访问历史记录
 */
import { showMessage } from '../../componets/common/promptShow';
import rssSourceGroupDao from '../../database/dao/rssSourceGroupDao';
import rssSourcesHistoryDao from '../../database/dao/RssSourcesHistoryDao';
import { rssSources } from '../../database/entities/rssSources';
import { rssSourcesHistory } from '../../database/entities/rssSourcesHistory';

export class rssSourcesUtils {
  /**
   * 推送RSS源历史记录
   * 功能：将RSS源信息保存到历史记录中
   * @param item - RSS源对象或RSS源历史记录对象
   * 使用场景：用户访问RSS源后记录访问历史
   * 处理流程：
   *   1. 创建rssSourcesHistory对象，复制item的属性
   *   2. 设置lastUpdateTime为当前时间戳
   *   3. 插入到历史记录数据库
   */
  async pushRssSourcesHistory(item: rssSources | rssSourcesHistory) {
    let rssSourcesHistory: rssSourcesHistory = {
      sourceType: item.sourceType,
      sourceName: item.sourceName,
      sourceUrl: item.sourceUrl,
      sourceIcon: item.sourceIcon || '',
      sourceIconIsUrl: item.sourceIconIsUrl,
      sourceGroup: item.sourceGroup,
      lastUpdateTime: Date.now(),  // 使用当前时间作为最后更新时间
      showRecentIcon: item.showRecentIcon,
      customizeTitle: item.customizeTitle || ''
    };
    rssSourcesHistoryDao.insert(rssSourcesHistory);
  }

  /**
   * 添加分组类型
   * 功能：添加新的RSS源分组，检查分组名称是否重复
   * @param newGroupType - 新的分组名称
   * 返回值：Promise<boolean> - 添加是否成功
   * 使用场景：用户创建新的RSS源分组
   * 处理流程：
   *   1. 获取现有分组列表
   *   2. 检查新分组名称是否已存在
   *   3. 如果存在，显示错误消息并返回false
   *   4. 如果不存在，插入新分组并显示成功消息，返回true
   */
  async addGroupType(newGroupType: string) {
    let isInsert = false;
    let group = await this.getRssSourcesGroup();
    group.map((data: string) => {
      if (data === newGroupType) {
        isInsert = true;
      }
    });
    if (isInsert) {
      showMessage('分组名称重复');
      isInsert = false;
      return false;
    } else {
      this.insertRssSourceGroup(newGroupType);
      showMessage(`添加分组${newGroupType}成功!`);
      return true;
    }
  }

  /**
   * 获取订阅分组
   * 功能：获取所有RSS源分组的名称列表
   * 返回值：Promise<string[]> - 分组名称数组
   * 使用场景：显示分组列表、分组选择
   * 处理流程：
   *   1. 从数据库查询所有分组
   *   2. 提取分组名称到数组中
   *   3. 返回分组名称数组
   */
  async getRssSourcesGroup() {
    let rssSourcesGroup = await rssSourceGroupDao.search();
    // 根据排序顺序存储到string[]
    let rssSourcesGroupName: string[] = [];
    for (let i = 0; i < rssSourcesGroup.length; i++) {
      rssSourcesGroupName.push(rssSourcesGroup[i].rssGroupName);
    }
    return rssSourcesGroupName;
  }

  /**
   * 新增分组
   * 功能：向数据库插入新的RSS源分组
   * @param rssGroupName - 分组名称
   * 使用场景：内部方法，由addGroupType调用
   * 分组属性说明：
   *   - rssGroupName: 分组名称
   *   - isTop: 是否置顶，默认false
   *   - isDelete: 是否可删除，默认true（表示可删除）
   */
  async insertRssSourceGroup(rssGroupName: string) {
    await rssSourceGroupDao.insert({
      rssGroupName: rssGroupName,
      isTop: false,
      isDelete: true
    });
  }
}

// 创建单例实例并导出
let rssSourcesUtil = new rssSourcesUtils();
export default rssSourcesUtil as rssSourcesUtils;

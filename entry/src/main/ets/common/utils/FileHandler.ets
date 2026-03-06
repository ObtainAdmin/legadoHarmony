/**
 * 文件处理工具类 - 提供文件操作相关功能的工具类
 * 
 * 功能：封装HarmonyOS文件系统API，提供统一的文件操作接口
 * 核心特性：
 *   1. 文件复制：将外部文件复制到应用沙箱
 *   2. 文件读取：读取文本文件、JSON文件、解析章节内容
 *   3. 文件写入：写入JSON数据到文件
 *   4. 文件选择：使用系统文档选择器选择文件
 *   5. 文件删除：删除指定文件
 * 使用场景：本地书籍导入、配置文件读写、数据备份恢复
 */
import { BusinessError } from '@ohos.base';
import fs, { Options } from '@ohos.file.fs';
import { common, Context } from '@kit.AbilityKit';
import { chaptersItem } from 'ets/componets/dataList/ReaderChaptersItem';
import { showMessage } from '../../componets/common/promptShow';
import { picker } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { buffer } from '@kit.ArkTS'
import { Books } from '../../database/entities/Books';
import booksUtil from './booksUtils';

let context = getContext(this) as common.UIAbilityContext;
let filePath = context.filesDir;

let options: Options = {
  encoding: 'utf-8'
};

export class FileHandler {
  /**
   * 复制文件到应用沙箱
   * 功能：将外部文件复制到应用沙箱目录，并添加到书架
   * @param srcUrl - 源文件路径
   * @param currentIndex - 书籍类型索引（0:小说, 1:有声书, 2:漫画）
   * 使用场景：用户导入本地书籍文件
   * 处理流程：
   *   1. 打开源文件
   *   2. 构建目标路径（应用沙箱目录 + 文件名）
   *   3. 创建书籍对象，设置本地书籍属性
   *   4. 调用booksUtil.addBooks添加到书架
   *   5. 复制文件到沙箱目录
   * 注意：文件名为中文时可能包含特殊字符，需要确保路径正确
   */
  static CopyFile(srcUrl: string, currentIndex: number) {
    let file = fs.openSync(srcUrl, fs.OpenMode.READ_WRITE);
    let dstPath = filePath + '/' + file.name; // file.name:《幽影之冰》.txt
    let book: Books = {
      bookName: file.name,
      bookUrl: dstPath,
      author: '暂无',
      bookGroup: 4,
      latestChapterTime: 0,
      totalChapterNum: 0,
      durChapterIndex: 0,
      durChapterPos: 0,
      durChapterTime: 0,
      canUpdate: false,
      sort: 0,
      originOrder: 0,
      syncTime: 0,
      bookType: currentIndex,
      isTop: false,
      isJoin: true,
      isLocalBook: true
    }
    booksUtil.addBooks(book)
    showMessage('添加到书架成功')
    fs.copyFile(file.fd, dstPath, 0).then(() => {
      showMessage('导入沙箱成功')
      console.info("copy file success");
    }).catch((err: BusinessError) => {
      showMessage('导入失败')
      console.error("copy file failed with error message: " + err.message + ", error code: " + err.code);
    });
  }

  /**
   * 读取JSON文件（动态获取文件大小）
   * 功能：读取JSON文件内容并返回字符串，动态分配缓冲区大小
   * @param srcUrl - JSON文件路径
   * 返回值：Promise<string> - JSON字符串，如果读取失败返回空字符串
   * 使用场景：读取配置文件、数据备份文件
   * 处理流程：
   *   1. 打开文件并获取文件大小
   *   2. 创建对应大小的ArrayBuffer
   *   3. 读取文件内容到ArrayBuffer
   *   4. 使用buffer.from转换为字符串
   * 优势：动态获取文件大小，避免预分配过大缓冲区
   * 注意：此方法适用于大文件，可以动态获取文件大小
   */
  static async ReadJSONFile(srcUrl: string) {
    try {
      let file = fs.openSync(srcUrl, fs.OpenMode.READ_WRITE);
      let stat = fs.statSync(file.path)
      let arrayBuffer = new ArrayBuffer(stat.size);
      let readLen: number = await fs.read(file.fd, arrayBuffer)
      let JSONString = buffer.from(arrayBuffer, 0, readLen).toString();
      return JSONString
    } catch (e) {
      console.error(`读取失败：${e}`);
      return ''
    }
  }

  /**
   * 读取文本文件并解析章节
   * 功能：读取文本文件，使用正则表达式解析章节结构
   * @param readFileUrl - 文本文件路径
   * 返回值：Promise<chaptersItem[]> - 章节列表
   * 使用场景：解析本地小说文本文件，提取章节信息
   * 处理流程：
   *   1. 使用正则表达式匹配章节标题
   *   2. 遍历文件每一行，识别章节标题
   *   3. 将章节内容累积到对应的章节对象
   *   4. 过滤掉内容过少的章节（少于5个字符）
   * 正则表达式说明：匹配中文章节标题，支持多种章节格式（章、回、话、节、卷、篇）
   *   支持格式：序章、楔子、番外、第X章、第X回、第X话、第X节、第X卷、第X篇
   *   支持数字：中文数字、阿拉伯数字、大写数字
   */
  static async readFile(readFileUrl: string) {
    let chapterNumber = 0
    const chapters: chaptersItem[] = [];
    console.info('readFileUrl:' + readFileUrl)
    //const regex = /===第(.*?)章 (.*?)===/g;
    const regex =
      /^[=|<]{0,4}((?:序章|楔子|番外|第\s{0,4})([\d〇零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟]+?\s{0,4})(?:章|回(?!合)|话(?!说)|节(?!课)|卷|篇(?!张)))(.{0,30})/g;
    await fs.readLines(readFileUrl, options).then((readerIterator: fs.ReaderIterator) => {
      for (let it = readerIterator.next();!it.done; it = readerIterator.next()) {
        const match = regex.exec(it.value);
        if (match) {
          const chapterTitleNumber = match[1]; // 书源内部章节
          const chapterTitle = match[3];
          chapterNumber++
          chapters.push(new chaptersItem(chapterNumber, chapterTitle, chapterTitleNumber, ''))
        } else {
          if (chapters.length > 0) {
            chapters[chapters.length - 1].content += it.value
          }
        }
      }
    }).catch((err: BusinessError) => {
      console.error("readLines failed with error message: " + err.message + ", error code: " + err.code);
    });
    // 移除chapters中content内容字符不超过5个字符的删除
    for (let i = 0; i < chapters.length; i++) {
      if (chapters[i].content.length < 5) {
        chapters.splice(i, 1)
        i--
      }
    }
    return chapters
  }

  /**
   * 文档选择器（通用）
   * 功能：打开系统文档选择器，选择指定类型的文件
   * @param maxSelectNumber - 最大选择数量（可选，默认无限制）
   * @param fileSuffixFilters - 文件后缀过滤器数组（如['.txt', '.json']）
   * 返回值：Promise<Array<string>> - 选择的文件路径数组
   * 使用场景：用户选择要导入的文件
   * 处理流程：
   *   1. 创建DocumentSelectOptions配置
   *   2. 设置最大选择数量和文件后缀过滤器
   *   3. 创建DocumentViewPicker并打开选择器
   *   4. 返回用户选择的文件路径
   * 注意：此方法提供通用的文件选择功能，可配置选择参数
   */
  static async documentPickerFile(maxSelectNumber: number | undefined = undefined, fileSuffixFilters: Array<string>) {
    // 尝试写一个通用的picker
    try {
      const documentSelectOptions = new picker.DocumentSelectOptions();
      // 选择文档的最大数目（可选）
      documentSelectOptions.maxSelectNumber = maxSelectNumber;
      // 选择文件的后缀类型，若选择项存在多个后缀名，则每一个后缀名之间用英文逗号进行分隔（可选），后缀类型名不能超过100
      documentSelectOptions.fileSuffixFilters = fileSuffixFilters;
      let documentViewPicker = new picker.DocumentViewPicker(context);
      const documentSelectResult: Array<string> = await documentViewPicker.select(documentSelectOptions)
      return documentSelectResult
    } catch (err) {
      console.error(`读取失败：${err}`);
      return Promise.reject(err)
    }
  }

  /**
   * JSON文件选择器（专用）
   * 功能：打开系统文档选择器，选择JSON文件并解析内容
   * @param context - 应用上下文，用于创建文档选择器
   * 返回值：Promise<any> - 解析后的JSON对象
   * 使用场景：用户选择JSON配置文件进行导入
   * 处理流程：
   *   1. 配置选择器只允许选择.json文件
   *   2. 打开文档选择器
   *   3. 读取选择的文件内容
   *   4. 使用TextDecoder解码UTF-8编码
   *   5. 解析JSON字符串为对象
   * 缓冲区大小：预分配40MB缓冲区（40960000字节），适用于大多数JSON文件
   * 注意：此方法专门用于选择JSON文件，文件大小限制为40MB
   * 与documentPickerFile的区别：此方法专用于JSON文件，自动解析内容
   */
  static async pickerFile(context: Context) {
    try {
      const documentSelectOptions = new picker.DocumentSelectOptions();
      // 选择文档的最大数目（可选）
      documentSelectOptions.maxSelectNumber = 1;
      // 选择文件的后缀类型，若选择项存在多个后缀名，则每一个后缀名之间用英文逗号进行分隔（可选），后缀类型名不能超过100
      documentSelectOptions.fileSuffixFilters = ['.json'];
      let documentViewPicker = new picker.DocumentViewPicker(context);
      const documentSelectResult: Array<string> = await documentViewPicker.select(documentSelectOptions)
      const pathUrl = documentSelectResult[0];
      console.info('文件目录：' + pathUrl);
      let file = fs.openSync(pathUrl, fs.OpenMode.READ_WRITE);
      let buf = new ArrayBuffer(40960000);
      fs.readSync(file.fd, buf);
      fs.closeSync(file);
      let uint8View = new Uint8Array(buf);
      // 设置编码格式为“utf-8”
      let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      // 解码输后获取对应文本
      let readString = textDecoder.decodeWithStream(uint8View, { stream: false });
      console.log('读取的数据内容：' + readString);
      return JSON.parse(readString)
    } catch (err) {
      console.error(`读取失败：${err}`);
      return Promise.reject(err)
    }
  }

  /**
   * 读取JSON文件（泛型版本）
   * 功能：读取JSON文件并解析为指定类型的对象
   * @param pathUrl - JSON文件路径
   * 返回值：Promise<T | undefined> - 解析后的对象，如果读取失败返回undefined
   * 使用场景：读取类型安全的JSON配置文件、数据文件
   * 处理流程：
   *   1. 使用fs.readText读取文件内容
   *   2. 使用JSON.parse解析字符串为对象
   *   3. 返回指定类型的对象
   * 类型安全：使用泛型T确保返回类型与预期一致
   * 优势：比ReadJSONFile方法更简洁，使用高级API
   * 注意：文件路径必须是应用沙箱内的路径
   */
  static async readJsonFile<T>(pathUrl: string): Promise<T | undefined> {
    console.info('TagInfo', '文件路径：' + pathUrl);
    try {
      const readString = await fs.readText(pathUrl);
      console.info('TagInfo', '读取的数据内容：' + readString);
      const data: T = JSON.parse(readString)
      return data
    } catch (err) {
      console.error('TagInfo', `未读取到：${err}`);
      return undefined
    }
  }

  /**
   * 写入JSON文件
   * 功能：将数据写入JSON文件，支持字符串或ArrayBuffer格式
   * @param pathUrl - 文件路径
   * @param context - 要写入的内容，可以是字符串或ArrayBuffer
   * 返回值：string - 操作结果描述（'写入成功'或'写入失败' + 错误信息）
   * 使用场景：保存配置文件、数据备份、用户设置
   * 处理流程：
   *   1. 检查文件是否存在
   *   2. 如果文件存在，以覆盖模式打开；如果不存在，以创建模式打开
   *   3. 写入内容到文件
   *   4. 关闭文件
   * 文件模式：
   *   - WRITE_ONLY | TRUNC: 只写模式，清空文件内容
   *   - READ_WRITE | CREATE: 读写模式，如果文件不存在则创建
   * 注意：此方法返回操作结果字符串，而非Promise
   */
  static writeJsonFile(pathUrl: string, context: ArrayBuffer | string) {
    console.info('TagInfo', '文件地址：' + pathUrl);
    try {
      // 创建文件，并且写入内容，若是存在则重写内容
      let res = fs.accessSync(pathUrl);
      let file: fs.File
      if (res) {
        file = fs.openSync(pathUrl, fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      } else {
        file = fs.openSync(pathUrl, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      }
      fs.writeSync(file.fd, context)
      fs.close(file);
      return '写入成功'
    } catch (e) {
      console.error('TagInfo', '写入失败' + JSON.stringify(e))
      return '写入失败' + JSON.stringify(e)
    }
  }

  /**
   * 删除JSON文件
   * 功能：删除指定的JSON文件
   * @param pathUrl - 要删除的文件路径
   * 返回值：string - 操作结果描述（'删除成功'或'删除失败'）
   * 使用场景：清理临时文件、删除配置文件、数据清理
   * 处理流程：
   *   1. 调用fs.unlinkSync删除文件
   *   2. 返回操作结果
   * 注意：此操作不可逆，会永久删除文件
   * 安全考虑：删除前应确认文件是否重要
   */
  static deleteJsonFile(pathUrl: string) {
    try {
      fs.unlinkSync(pathUrl);
      return '删除成功'
    } catch (e) {
      console.error('TagError', '删除失败' + JSON.stringify(e))
      return '删除失败'
    }
  }
}
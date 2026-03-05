/**
 * 图片选择工具 - 提供系统相册图片选择功能的工具函数
 * 
 * @author 2008
 * @datetime 2024/5/27 0:09
 * @className: photoViewPicker
 * 
 * 功能：封装HarmonyOS图片选择器API，提供简单的图片选择功能
 * 核心特性：
 *   1. 图片类型过滤：只允许选择图片类型文件
 *   2. 数量限制：最多选择一张图片
 *   3. 异步操作：使用async/await处理异步选择过程
 * 使用场景：用户头像选择、图片上传、相册图片选择
 */
import picker from '@ohos.file.picker';

/**
 * 选择头像图片
 * 功能：打开系统相册选择器，让用户选择一张图片
 * 返回值：Promise<picker.PhotoSelectResult | undefined> - 选择的图片结果，如果未选择则返回undefined
 * 使用场景：用户选择头像、选择图片进行上传等
 * 处理流程：
 *   1. 创建PhotoSelectOptions配置对象
 *   2. 设置MIMEType为IMAGE_TYPE，限制只能选择图片
 *   3. 设置maxSelectNumber为1，限制只能选择一张图片
 *   4. 创建PhotoViewPicker实例
 *   5. 调用select方法打开图片选择器
 *   6. 检查选择结果，如果没有选择图片则返回undefined
 * 返回值说明：
 *   - 成功选择图片：返回picker.PhotoSelectResult对象，包含photoUris数组
 *   - 未选择图片：返回undefined
 */
export const pickerAvatar = async (): Promise<picker.PhotoSelectResult | undefined> => {
  // 实例化选项对象
  const options = new picker.PhotoSelectOptions();
  
  // 过滤选择媒体文件类型为IMAGE——只能选择图片类型的资源
  options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
  
  // 只能选择一张系统相册中的照片
  options.maxSelectNumber = 1;

  // 利用PhotoViewPicker对象实例中的select自动获取到用户选择的那张图片的地址
  const pickerView = new picker.PhotoViewPicker();
  let urls = await pickerView.select(options);
  
  if (urls.photoUris.length <= 0) {
    return;
  }
  
  return urls;
};

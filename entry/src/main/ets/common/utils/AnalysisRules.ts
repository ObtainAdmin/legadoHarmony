/**
 * 解析简单数据
 * 功能：解析格式为"标题::URL"的简单规则数据
 * @param data - 要解析的字符串数据，每行格式为"标题::URL"
 * 返回值：数组，每个元素包含title和api对象（url、空body、空header）
 * 使用场景：解析简单的API规则配置，其中只包含URL
 * 处理流程：
 *   1. 按换行符分割数据为多行
 *   2. 对每一行按"::"分割为标题和API部分
 *   3. 替换API中的时间模板字符串为当前时间
 *   4. 构建结果对象并添加到结果数组
 * 特殊处理：替换{{String$new Date$$$.replace$'$GMT\+08:00$','$中国标准时间$'$}}模板为当前时间字符串
 */
function parseData(data: string): Array<{title: string, api: {url: string, body: any, header: any}}> {
  const lines = data.split('\n');
  const result: Array<{title: string, api: {url: string, body: any, header: any}}> = [];

  lines.forEach((line) => {
    const parts = line.split('::');
    if (parts.length === 2) {
      const title = parts[0];
      // 替换时间模板字符串为当前时间
      const api = parts[1].replace(/{{String$new Date$$$.replace$'$GMT\+08:00$','$中国标准时间$'$}}/g, new Date().toString());

      result.push({
        title: title,
        api: {
          url: api,
          body: {},
          header: {}
        }
      });
    }
  });

  return result;
}
/**
 * 解析带方法的数据
 * 功能：解析格式为"标题::URL,{method:'GET',body:'...'}"的复杂规则数据
 * @param data - 要解析的字符串数据，每行格式为"标题::URL,JSON配置"
 * 返回值：数组，每个元素包含title和api对象（url、method、body、空header）
 * 使用场景：解析复杂的API规则配置，包含HTTP方法和请求体
 * 处理流程：
 *   1. 按换行符分割数据为多行
 *   2. 对每一行按"::"分割为标题和API数据部分
 *   3. 将API数据部分按逗号分割为URL和JSON配置
 *   4. 将JSON配置中的单引号替换为双引号
 *   5. 解析JSON获取method和body
 *   6. 构建结果对象并添加到结果数组
 * 注意：JSON配置必须包含method和body字段
 */
function parseDataWithMethod(data: string): Array<{title: string, api: {url: string, method: string, body: string, header: any}}> {
  const lines = data.split('\n');
  const result: Array<{title: string, api: {url: string, method: string, body: string, header: any}}> = [];

  lines.forEach((line) => {
    const parts = line.split('::');
    if (parts.length === 2) {
      const title = parts[0];
      const apiData = parts[1].split(',');
      if (apiData.length === 2) {
        const url = apiData[0];
        const apiInfo = apiData[1];

        // 将单引号替换为双引号以便JSON解析
        let parsedInfo = apiInfo.replace(/'/g, '"');
        parsedInfo = JSON.parse(parsedInfo);
        const { method, body } = parsedInfo;

        result.push({
          title: title,
          api: {
            url: url.trim(),
            method: method.trim(),
            body: body.trim(),
            header: {}
          }
        });
      }
    }
  });

  return result;
}

/**
 * 自动解析数据
 * 功能：根据数据内容自动选择解析方法
 * @param data - 要解析的字符串数据
 * 返回值：解析后的API配置数组
 * 使用场景：智能解析API规则，根据内容格式选择合适解析器
 * 判断逻辑：
 *   - 如果数据中包含"method"字符串，使用parseDataWithMethod解析
 *   - 否则，使用parseData解析
 */
export const autoParseData = (data: string): Array<{title: string, api: {url: string, body: any, header: any}}> => {
  if (data.includes('method')) {
    return parseDataWithMethod(data);
  } else {
    return parseData(data);
  }
}

/**
 * 分析规则主函数
 * 功能：提供统一的规则分析接口
 * @param data - 要解析的字符串数据
 * 返回值：解析后的API配置数组
 * 使用场景：外部调用规则分析功能
 * 实现：直接调用autoParseData函数
 */
export const AnalysisRules = (data: string): Array<{title: string, api: {url: string, body: any, header: any}}> => {
  return autoParseData(data);
}

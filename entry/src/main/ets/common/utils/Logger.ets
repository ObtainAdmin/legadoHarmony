/**
 * 日志工具类 - 封装HarmonyOS日志系统的工具类
 * 
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * 功能：封装hilog日志系统，提供统一的日志记录接口
 * 核心特性：
 *   1. 多级别日志：支持debug、info、warn、error四个日志级别
 *   2. 域隔离：使用domain参数隔离不同服务的日志
 *   3. 格式化输出：统一日志格式，便于日志分析
 *   4. 默认配置：提供合理的默认值，简化使用
 * 使用场景：应用调试、错误追踪、性能监控、用户行为分析
 */
import hilog from '@ohos.hilog';

class Logger {
  /**
   * 日志域
   * 功能：标识服务域，用于日志分类和过滤
   * 范围：0x0到0xFFFFF的十六进制整数
   * 默认值：0xFF00
   */
  private domain: number;
  
  /**
   * 日志前缀
   * 功能：标识日志标签，用于区分不同模块的日志
   * 默认值：'MyApp'
   */
  private prefix: string;
  
  /**
   * 日志格式
   * 功能：定义日志输出的格式
   * 默认值：'%{public}s, %{public}s'（两个公共字符串）
   * 说明：使用hilog的格式化语法，%{public}s表示公共字符串
   */
  private format: string = '%{public}s, %{public}s';

  /**
   * 构造函数
   * 功能：初始化Logger实例，配置日志域和前缀
   * @param prefix - 日志前缀，标识日志标签（默认'MyApp'）
   * @param domain - 日志域，标识服务域（默认0xFF00）
   * 使用场景：创建自定义Logger实例时使用
   */
  constructor(prefix: string = 'MyApp', domain: number = 0xFF00) {
    this.prefix = prefix;
    this.domain = domain;
  }

  /**
   * 调试日志
   * 功能：记录调试信息，用于开发调试
   * @param args - 可变参数，要记录的调试信息
   * 使用场景：变量值查看、流程跟踪、调试信息输出
   */
  debug(...args: string[]): void {
    hilog.debug(this.domain, this.prefix, this.format, args);
  }

  /**
   * 信息日志
   * 功能：记录一般信息，用于正常流程记录
   * @param args - 可变参数，要记录的信息
   * 使用场景：业务流程记录、状态变更、用户操作记录
   */
  info(...args: string[]): void {
    hilog.info(this.domain, this.prefix, this.format, args);
  }

  /**
   * 警告日志
   * 功能：记录警告信息，用于潜在问题提示
   * @param args - 可变参数，要记录的警告信息
   * 使用场景：非致命错误、性能警告、配置问题
   */
  warn(...args: string[]): void {
    hilog.warn(this.domain, this.prefix, this.format, args);
  }

  /**
   * 错误日志
   * 功能：记录错误信息，用于错误追踪
   * @param args - 可变参数，要记录的错误信息
   * 使用场景：异常捕获、错误处理、系统故障
   */
  error(...args: string[]): void {
    hilog.error(this.domain, this.prefix, this.format, args);
  }
}

// 导出默认Logger实例，使用'FirstStartDemo'作为前缀，0xFF00作为域
export default new Logger('FirstStartDemo', 0xFF00);

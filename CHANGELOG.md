# 变更记录

## 2.0.0

当前源码版本为 2.0.0，配套 PHP 库版本为 2.0.0。本地更新不代表已创建或发布 `v2.0.0` 标签。

### 新增与调整

- 根据 proto 的 client/server streaming 标志生成三类流式接口，参数使用 `\GRpcStream`，流式返回值使用 `iterable`。
- PHPDoc 说明流中的请求类型及 `iterable<Reply>` 响应元素类型，普通 unary 签名保持不变。
- 增加 `--version`，源码和 Makefile 的默认版本统一为 2.0.0；正常 protoc 二进制输入/输出协议保持不变。
- Go 模块和内部导入路径升级为 `/v2`，依赖版本不变。
- Makefile 的测试目标改为运行 `go test ./...`。
- 修正旧测试的 protoc 插件别名，并将遗留 RoadRunner 样本同步为本项目既有 unary 输出。
- 文档统一说明配套 PHP 库、Composer 加载、Swoole 传输和协议生成步骤，替换旧弃用提示与未固定版本的安装命令。

升级步骤见 [UPGRADE.md](UPGRADE.md)。

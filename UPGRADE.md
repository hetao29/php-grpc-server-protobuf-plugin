# 升级到 php-grpc-server-protobuf-plugin 2.0.0

配套运行库使用 `hetao29/php-grpc-server-protobuf 2.0.0`。完整命令见 [README.md](README.md)，生成与实现约定见 [MANUAL.md](MANUAL.md)。

## Go 模块与工具版本

Go 模块路径从 `github.com/hetao29/php-grpc-server-protobuf-plugin` 改为 `github.com/hetao29/php-grpc-server-protobuf-plugin/v2`。若在 Go 中导入 `php` 子包，也改为 `/v2/php`。Go 依赖版本保持不变。

当前源码可用 `make build` 构建，`--version` 应输出 `2.0.0`。发布 `v2.0.0` 标签后才可使用带 `/v2@v2.0.0` 的 `go install` 命令。不要继续使用旧的不带 `/v2` 的安装路径期待得到此主版本。构建没有创建标签或执行发布。

## 替换插件并重新生成

将消费项目中 `--plugin=protoc-gen-php-grpc=...` 指向新二进制；若仓库保存了插件副本，同步更新该副本并检查 `--version`。插件别名 `php-grpc`、输出选项 `--php-grpc_out` 和二进制名称保持不变。

重新执行 protoc 或消费项目的生成目标，核对生成接口和业务实现。普通 unary 方法仍使用消息类参数及返回值；流式方法改为：

| RPC | 2.0.0 接口变化 |
| --- | --- |
| 服务端流 | 返回值为 `iterable`，PHPDoc 描述响应消息元素类型 |
| 客户端流 | 参数为 `\GRpcStream`，返回单条响应消息 |
| 双向流 | 参数为 `\GRpcStream`，返回值为 `iterable` |

服务实现用 `recv(Request::class)` 读到 `null`，用 `yield` 逐条产生响应。不要保留旧版将 stream 当作单条消息的签名，也不要手工改写生成接口以绕过类型错误。官方原生客户端仍由 `grpc_php_plugin` 生成，其生成命令保持独立。

## 同步运行库与传输

服务入口统一使用 `GRpcServer::serve($request, $response, ...构造参数)`，旧 `run()` 调用须迁移。流式运行依赖配套 Swoole 的增量 HTTP/2 支持，同时更新接口插件、PHP 库及扩展；只重新生成 PHP 接口不会自动获得传输能力。

消息、接口及业务类统一交给 Composer 加载。验证四类 RPC、半关闭和最终 gRPC 状态；JSON 仅验证 unary。升级工具不要求提交、打标签或启动业务进程。

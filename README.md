# php-grpc-server-protobuf-plugin 2.0.0

为 Protobuf service 生成 PHP 服务端接口，配套 `hetao29/php-grpc-server-protobuf` **2.0.0**。支持 unary、服务端流、客户端流和双向流；消息类与原生客户端分别由 protoc 的 PHP 生成器和官方 `grpc_php_plugin` 生成。

[使用手册](MANUAL.md) · [1.x 升级指南](UPGRADE.md) · [变更记录](CHANGELOG.md) · [PHP 运行库](https://github.com/hetao29/php-grpc-server-protobuf)

## 安装与构建

本目录的源码版本为 **2.0.0**，Go 模块路径为 `github.com/hetao29/php-grpc-server-protobuf-plugin/v2`，构建需要 Go 1.21 或更高版本，生成代码需要 `protoc`。

当前本地版本声明不代表已经创建或发布 `v2.0.0` Git 标签。标签发布后可安装固定版本：

```bash
go install github.com/hetao29/php-grpc-server-protobuf-plugin/v2@v2.0.0
```

从当前源码构建并核对版本：

```bash
make build
./php-grpc-server-protobuf-plugin --version
# php-grpc-server-protobuf-plugin 2.0.0
```

`make build BINARY=/path/to/php-grpc-server-protobuf-plugin` 可指定输出位置；`go build` 或 `go install` 的直接构建也默认报告 2.0.0。`make test` 运行现有 Go/protoc 测试，需要 `protoc` 位于 PATH 中。

## 生成接口和消息

下面命令在消费项目中执行，假定 proto 位于 `proto/src`，先创建输出目录并将插件路径替换为实际位置：

```bash
mkdir -p proto_generated
protoc -I proto \
  --plugin=protoc-gen-php-grpc=/path/to/php-grpc-server-protobuf-plugin \
  --php-grpc_out=proto_generated \
  --php_out=proto_generated \
  proto/src/helloworld.proto
```

官方原生客户端另用 `grpc_php_plugin` 生成：

```bash
protoc -I proto \
  --plugin=protoc-gen-grpc=/path/to/grpc_php_plugin \
  --grpc_out=proto_generated \
  proto/src/helloworld.proto
```

PHP 运行库仓库的 `samples` 已提供 `make plugin` 和 `make proto`，可一次生成消息、服务接口和原生客户端。生成文件不要手工修改，服务实现单独放在应用目录，并通过 Composer PSR-4 加载。

## RPC 签名

| Proto 输入 / 输出 | 生成的 PHP 签名 |
| --- | --- |
| 单条 / 单条 | `Method(Request $request): Reply` |
| 单条 / 流 | `Method(Request $request): iterable` |
| 流 / 单条 | `Method(\GRpcStream $request): Reply` |
| 流 / 流 | `Method(\GRpcStream $request): iterable` |

流参数用 `$request->recv(Request::class)` 读取，干净半关闭时返回 `null`；流式返回值使用 `yield` 或其他 iterable，元素为响应消息。生成的 PHPDoc 记录 `iterable<Reply>` 和流中的请求类型，接口保留服务 `NAME` 常量。

普通 unary 签名保持不变。三类流须使用配套库的 `GRpcServer::serve($request, $response, ...构造参数)`，并开启匹配 Swoole 扩展的 `http2_stream_mode`。JSON 仍仅支持 unary；生成接口本身不会启动 Server 或实现传输层。

本项目源于 SpiralScout/RoadRunner 的 protoc 插件实现，保留原源码许可证说明；当前 2.0.0 手册以本仓库的生成规则及配套 PHP 库为准。

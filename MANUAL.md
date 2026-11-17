# php-grpc-server-protobuf-plugin 2.0.0 使用手册

本工具作为 protoc 插件，从 CodeGeneratorRequest 生成 PHP 服务接口。无命令行参数时从标准输入读取 Protobuf 请求，在标准输出写入二进制 CodeGeneratorResponse；不要将普通日志写入标准输出。显式执行 `--version` 时仅输出版本文本。

## 工具与输出分工

| 工具 / 参数 | 负责内容 |
| --- | --- |
| protoc `--php_out` | Protobuf 消息类和 GPBMetadata |
| 本插件 `--php-grpc_out` | 服务的 `ServiceInterface.php` |
| 官方 `grpc_php_plugin` / `--grpc_out` | 基于原生 PHP grpc 扩展的客户端 |
| PHP 库 `GRpcServer / GRpcStream / GRpcClient` | 运行时调度、消息流和协程客户端 |

插件本身只需 Go 构建环境和 protoc，不需要 PHP/Swoole。生成代码运行时须满足 PHP 库 2.0.0 的要求。不要将本插件的 2.0.0 版本号当作官方 grpc 或 Swoole 的版本号。

## 构建与版本

```bash
make build
./php-grpc-server-protobuf-plugin --version
```

输出应为 `php-grpc-server-protobuf-plugin 2.0.0`。Makefile 的 `VERSION` 默认 2.0.0，通过 linker 参数注入；直接 `go build` / `go install` 也使用源码默认版本。发布构建保持该值，避免生成不同版本标识的同名工具。

Go 模块路径带 `/v2`，从标签安装的写法为 `go install github.com/hetao29/php-grpc-server-protobuf-plugin/v2@v2.0.0`，须等标签发布后执行。二进制名称仍为 `php-grpc-server-protobuf-plugin`，protoc 插件别名仍为 `php-grpc`。

## 生成步骤

在消费项目中准备 proto 文件、输出目录和插件路径，命令见 [README.md](README.md)。`-I` 指定 proto import 根目录，各输入文件相对该目录解析；输出目录须预先存在。实际构建二进制路径通过 `--plugin=protoc-gen-php-grpc=...` 显式指定，避免 PATH 中旧插件抢先运行。

例如默认 `package test.helloworld` 的服务 `Greeter` 会生成 `Test\Helloworld\GreeterInterface`。输出保留服务名和方法名，命名空间按 proto package 或显式 `php_namespace` 处理，跨文件消息导入也按其声明解析。PHP 业务类和接口必须处于相应命名空间；涉及自定义 `php_namespace` 时，另行核对运行库以 PHP 类名解析的路由，不能只按 proto package 推断。

生成器声明支持 proto3 optional。协议或 stream 标志变更时，用本插件重新生成接口，同步服务实现和调用方；不要只修改生成文件。

## 从 proto 到实现

```proto
syntax = "proto3";
package example;

message Request { string value = 1; }
message Reply { string value = 1; }

service Greeter {
  rpc Unary(Request) returns (Reply);
  rpc Expand(Request) returns (stream Reply);
  rpc Collect(stream Request) returns (Reply);
  rpc Chat(stream Request) returns (stream Reply);
}
```

对应的服务方法约束为：

```php
public function Unary(Request $request): Reply;
public function Expand(Request $request): iterable;
public function Collect(\GRpcStream $request): Reply;
public function Chat(\GRpcStream $request): iterable;
```

服务实现可以逐条读取、逐条回复：

```php
/** @param \GRpcStream $request Stream of Request messages. */
public function Chat(\GRpcStream $request): iterable {
    while (($message = $request->recv(Request::class)) !== null) {
        yield new Reply(['value' => $message->getValue()]);
    }
}
```

生成的 `iterable<Reply>` 是 PHPDoc 元素类型，原生返回声明为 `iterable`。客户端流参数的 PHPDoc 记录流中的消息类型，原生声明为全局 `\GRpcStream`。输入半关闭后 `recv()` 返回 `null`，传输或解码失败抛异常。具体服务与客户端运行流程见配套 PHP 库的 `samples/README.md`。

## 加载与验证

消费项目通过 Composer PSR-4 加载生成的接口、消息和业务实现，库本身通过 Composer classmap 加载。生成器不产生额外的 require、Server 启动文件或业务方法体。注册 `GRpcServer::serve` 后，以二进制 HTTP/2 测试三种流；普通 JSON 只用于 unary。

`make test` 执行现有命名空间、跨文件导入和 Google Empty 等生成测试。发布前还应核对普通 unary 输出兼容性、四种 stream 标志的签名，以及与配套库的实际互通。生成检查成功不等于业务或传输验证成功。

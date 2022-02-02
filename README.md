# php-grpc-server-protobuf-plugin

the php plugin for grpc protobuf to generate php server interface

# install

```bash

go install github.com/hetao29/php-grpc-server-protobuf-plugin@latest

```


# usage

```bash
  
#生成interface（此插件）
protoc --plugin=protoc-gen-php-grpc=proto/php-grpc-server-protobuf-plugin --php-grpc_out=proto_generated --php_out=proto_generated -I proto/ proto/src/*

#生成client(官方插件）
protoc --plugin=protoc-gen-grpc=proto/grpc_php_plugin --grpc_out=proto_generated --php_out=proto_generated -I proto/ proto/src/*

```

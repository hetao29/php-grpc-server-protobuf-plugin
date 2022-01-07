build:
	export GOPROXY=https://goproxy.cn &&  go build -v -ldflags "-X main.version=1.0.0 -X main.build=`date -u +%Y-%m-%d%H:%M:%S`" -o php-grpc-server-protobuf-plugin .
test:
	export GOPROXY=https://goproxy.cn &&  go build -v -ldflags "-X main.version=1.0.0 -X main.build=`date -u +%Y-%m-%d%H:%M:%S`" -o plugin_test plugin_test.go

VERSION ?= 2.0.0
BINARY ?= php-grpc-server-protobuf-plugin

.PHONY: build test
build:
	go build -trimpath -ldflags "-X main.version=$(VERSION)" -o "$(BINARY)" .

test:
	go test ./...

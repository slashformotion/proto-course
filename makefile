requirements:
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5
	go install github.com/envoyproxy/protoc-gen-validate@v1.2
	go install github.com/wasilibs/go-protoc-gen-grpc/cmd/protoc-gen-grpc_python@latest

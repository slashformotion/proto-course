# Proto-course

In this course, we will explore the core concepts of protobuf, including its syntax, message and enum definitions, service definitions, and advanced features like nested types and oneof fields. Beyond serialization, we’ll also dive into how protobuf integrates with Remote Procedure Call frameworks like gRPC, enabling efficient communication in modern cloud-native applications. We will also explore the suite of tools and libraries that support protobuf development, including protoc, prototool, buf, and more.

## Prerequisites

tip: if you use nix with flakes, just use the devShell from `flake.nix`.

- Go 1.24 installed with the GOBIN path in you PATH setup (see this for more: https://michaelcurrin.github.io/dev-cheatsheets/cheatsheets/go/gobin.html) 
    
    The following protoc plugins are required:

    - protoc-gen-openapiv2 : `go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2`
    - protoc-gen-grpc-gateway : `go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2`
    - protoc-gen-go : `go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36`
    - protoc-gen-go-grpc : `go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5`
    - protoc-gen-validate : `go install github.com/envoyproxy/protoc-gen-validate@v1.2`
    
- protoc installed https://protobuf.dev/installation/
- buf  : `go install github.com/bufbuild/buf/cmd/buf@v1.54.0`


PROTO_DIR:=proto
API_PROTO_FILES:=$(shell  find . -path '**.proto')

default: api-python api-go 

api-go: 
	@echo "Generating Go code"
	protoc -I $(PROTO_DIR) \
	--go_out=. \
	--go_opt=paths=source_relative \
	--go-grpc_out=. \
	--go-grpc_opt=paths=source_relative \
	$(API_PROTO_FILES)

api-python:
	@echo "Generating Python code"
	uv run python3 -m grpc_tools.protoc -I $(PROTO_DIR)  \
  	--python_out=. \
	--grpc_python_out=. \
  $(API_PROTO_FILES)



PROTO_DIR:=proto
VENDOR_DIR:=protovendor
VENDOR_GOOGLEAPIS_DIR:=$(VENDOR_DIR)/googleapis
VENDOR_GRPC_GATEWAY_DIR:=$(VENDOR_DIR)/grpc-gateway
API_PROTO_FILES:=$(shell find $(PROTO_DIR) -name "*.proto")

default: api-python api-go 
echo:
	@echo $(PROTO_DIR)
	@echo $(VENDOR_DIR)
	@echo $(VENDOR_GOOGLEAPIS_DIR)
	@echo $(VENDOR_GRPC_GATEWAY_DIR)
	@echo $(API_PROTO_FILES)
api-go: 
	@echo "Generating Go code"
	protoc -I $(PROTO_DIR) \
	-I $(VENDOR_GOOGLEAPIS_DIR) \
	-I $(VENDOR_GRPC_GATEWAY_DIR) \
	--go_out=. \
	--go_opt=paths=source_relative \
	--go-grpc_out=. \
	--go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=. \
	--grpc-gateway_opt=paths=source_relative \
	--openapiv2_out=. \
	$(API_PROTO_FILES)

api-python:
	@echo "Generating Python code"
	uv run python3 -m grpc_tools.protoc \
	-I $(PROTO_DIR) \
	-I $(VENDOR_GOOGLEAPIS_DIR) \
	-I $(VENDOR_GRPC_GATEWAY_DIR) \
  	--python_out=. \
	--grpc_python_out=. \
  	$(API_PROTO_FILES)

vendor:
	rm -rf $(VENDOR_DIR)
	mkdir -p $(VENDOR_DIR)
	git clone https://github.com/googleapis/googleapis $(VENDOR_GOOGLEAPIS_DIR)
	git clone https://github.com/grpc-ecosystem/grpc-gateway $(VENDOR_GRPC_GATEWAY_DIR)

curl-api-with-default-url:
	curl -v \
	-H "Content-Type: application/json" \
	-d '{"amount": 100, "iban": "FR763000100031234567890143", "bic": "COBADEFFXXX", "date": "2023-01-01T00:00:00Z"}' http://localhost:50052/ibanfirst.v0.ApiService/CreatePayment

curl-api-with-custom-url:
	curl -v \
	-H "Content-Type: application/json" \
	-d '{"amount": 100, "iban": "FR763000100031234567890143", "bic": "COBADEFFXXX", "date": "2023-01-01T00:00:00Z"}' http://localhost:50052/api/v1/payment/create

swagger-ui:
	open http://localhost:50052/swagger
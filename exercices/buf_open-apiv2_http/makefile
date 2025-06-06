
PROTO_DIR:=proto
VENDOR_DIR:=protovendor
VENDOR_GOOGLEAPIS_DIR:=$(VENDOR_DIR)/googleapis
VENDOR_GRPC_GATEWAY_DIR:=$(VENDOR_DIR)/grpc-gateway
API_PROTO_FILES:=$(shell find $(PROTO_DIR) -name "*.proto")


curl-api-with-default-url:
	curl -v \
	-H "Content-Type: application/json" \
	-d '{"amount": 100, "iban": "FR763000100031234567890143", "bic": "COBADEFFXXX", "date": "2023-01-01T00:00:00Z"}' http://localhost:50052/ibanfirst.v0.ApiService/CreatePayment

curl-api-with-custom-url:
	curl -v \
	-H "Content-Type: application/json" \
	-d '{"amount": 100, "iban": "FR763000100031234567890143", "bic": "COBADEFFXXX", "date": "2023-01-01T00:00:00Z"}' http://localhost:50052/api/v1/payment/create

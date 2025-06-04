import grpc
import ibanfirst.v0.api_pb2 as v0proto
import ibanfirst.v0.api_pb2_grpc as v0grpc


def run():
    # Connect to gRPC server at localhost:50051
    with grpc.insecure_channel('localhost:50051') as channel:
        # Create stub from generated code
        stub = v0grpc.ApiServiceStub(channel)

        # Create and send a 
        request = v0proto.CreatePaymentRequest(amount=1, iban="FR763000100031234567890143")
        response = stub.CreatePayment(request)

        print(f"Greeter client received: {response}")

if __name__ == '__main__':
    run()
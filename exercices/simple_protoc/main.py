import grpc
from google.protobuf.timestamp_pb2 import Timestamp
from ibanfirst.v0.api_pb2 import ibanfirst_pb2
from ibanfirst.v0.api_pb2_grpc import ibanfirst_pb2_grpc
from datetime import datetime

def create_payment(amount, iban, bic, payment_date: datetime):
    # Create a gRPC channel to the server (adjust host:port)
    channel = grpc.insecure_channel('localhost:50051')
    stub = ibanfirst_pb2_grpc.ApiServiceStub(channel)
    
    # Convert Python datetime to protobuf Timestamp
    timestamp = Timestamp()
    timestamp.FromDatetime(payment_date)
    
    # Build the request message
    request = ibanfirst_pb2.CreatePaymentRequest(
        amount=amount,
        iban=iban,
        bic=bic,
        date=timestamp
    )
    
    # Call the remote procedure
    response = stub.CreatePayment(request)
    
    print(f"Payment created with ID: {response.payment_id}")
    return response

if __name__ == "__main__":
    # Example usage
    dt = datetime.now(datetime.timezone.utc)
    create_payment(100.5, "DE89370400440532013000", "COBADEFFXXX", dt)

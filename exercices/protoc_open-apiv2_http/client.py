import random

import grpc
from google.protobuf.timestamp_pb2 import Timestamp
from google.protobuf.empty_pb2 import Empty
import ibanfirst.v0.api_pb2 as ibanfirst_pb2
import ibanfirst.v0.api_pb2_grpc as ibanfirst_pb2_grpc
from datetime import datetime


def createPayment(stub: ibanfirst_pb2_grpc.ApiServiceServicer):
    timestamp = Timestamp()
    timestamp.FromDatetime(datetime.now())

    # Build the request message
    request = ibanfirst_pb2.CreatePaymentRequest(
        amount=random.randint(1, 100),
        iban="FR763000100031234567890143",
        bic="COBADEFFXXX",
        date=timestamp,
    )

    # Call the remote procedure

    response = stub.CreatePayment(request)

    print(f"Payment created with ID: {response.payment_id}")


if __name__ == "__main__":
    print("Starting client...")
    # open tcp connection to the server
    with grpc.insecure_channel("localhost:50051") as channel:
        # create client
        stub = ibanfirst_pb2_grpc.ApiServiceStub(channel)
        print("create payment request")
        createPayment(stub)

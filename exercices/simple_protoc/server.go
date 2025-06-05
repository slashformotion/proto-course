package main

import (
	"context"
	"log"
	"math/rand"
	"net"
	"sync/atomic"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/reflection"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"

	pb "github.com/slashformotion/proto-course/exercices/simple_protoc/ibanfirst/v0"
)

var paymentCounter uint32 = 0

type server struct {
	pb.UnimplementedApiServiceServer
}

func (s *server) ReturnErrCode(context.Context, *emptypb.Empty) (*emptypb.Empty, error) {

	codesSelect := []codes.Code{
		codes.InvalidArgument,
		codes.NotFound,
		codes.AlreadyExists,
		codes.ResourceExhausted,
		codes.FailedPrecondition,
		codes.OutOfRange,
		codes.Unimplemented,
		codes.Internal,
		codes.DataLoss,
		codes.Unavailable,
	}
	selectedCode := codesSelect[rand.Intn(len(codesSelect))]
	log.Printf("Returning error code: %v", selectedCode)
	return &emptypb.Empty{}, status.Error(selectedCode, "an error occurred on the server")
}

// CreatePayment implements v0.ApiServiceServer.
func (s *server) CreatePayment(context.Context, *pb.CreatePaymentRequest) (*pb.CreatePaymentResponse, error) {
	paymentId := atomic.AddUint32(&paymentCounter, 1)
	return &pb.CreatePaymentResponse{
		PaymentId: paymentId,
	}, nil
}

var _ pb.ApiServiceServer = (*server)(nil)

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer(
		grpc.UnaryInterceptor(LoggerInterceptor),
		grpc.Creds(insecure.NewCredentials()),
	)

	pb.RegisterApiServiceServer(s, &server{})
	reflection.Register(s)

	log.Println("Starting server...")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

// LoggerInterceptor is a UnaryServerInterceptor that logs requests.
func LoggerInterceptor(
	ctx context.Context,
	req interface{},
	info *grpc.UnaryServerInfo,
	handler grpc.UnaryHandler,
) (resp interface{}, err error) {
	start := time.Now()

	// Call the handler to complete the normal execution of the RPC.
	resp, err = handler(ctx, req)

	duration := time.Since(start)

	// Log the method name, duration, and any error.
	log.Printf("gRPC method: %s, duration: %s, error: %v", info.FullMethod, duration, err)
	return resp, err
}

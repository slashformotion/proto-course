package main

import (
	"context"
	_ "embed"
	"log"
	"net"
	"net/http"
	"sync/atomic"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/reflection"

	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	pb "github.com/slashformotion/proto-course/exercices/simple_protoc/ibanfirst/v0"
)

var paymentCounter uint32 = 0

type server struct {
	pb.UnimplementedApiServiceServer
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

	go func() {
		log.Println("Serving gRPC on 0.0.0.0:50051")
		if err := s.Serve(lis); err != nil {
			log.Fatalf("Failed to serve gRPC server: %v", err)
		}
	}()

	// gRPC-Gateway HTTP server
	mux := runtime.NewServeMux(
		runtime.WithMiddlewares(loggerHttpMiddleware),
	)
	err = pb.RegisterApiServiceHandlerServer(context.Background(), mux, &server{})
	if err != nil {
		log.Fatalf("Failed to start HTTP gateway: %v", err)
	}

	log.Println("HTTP server (via gRPC-Gateway) listening on :50052")
	if err := http.ListenAndServe(":50052", mux); err != nil {
		log.Fatalf("Failed to serve HTTP: %v", err)
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

func loggerHttpMiddleware(handle runtime.HandlerFunc) runtime.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request, pathParams map[string]string) {
		start := time.Now()
		handle(w, r, pathParams)
		duration := time.Since(start)
		log.Printf("HTTP method: %s Path: %s, duration: %s", r.Method, r.URL.Path, duration)
	}
}

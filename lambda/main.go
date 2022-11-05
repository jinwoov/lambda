package main

import (
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
)

type Request struct {
	Name  string `json:"name"`
	Age   int    `json:"age"`
	Breed string `json:"breed"`
}

type Response struct {
	Message string `json:"message"`
	Ok      bool   `json:"ok"`
}

func Handler(req Request) (Response, error) {
	if req.Age == 0 || req.Breed == "" || req.Name == "" {
		return Response{
			Message: "Request body was empty",
			Ok:      false,
		}, fmt.Errorf("error did not receive necessary information")
	}

	return Response{
		Message: fmt.Sprintf("Hey %s, I can Arf too! You are %d old and is %s breed", req.Name, req.Age, req.Breed),
		Ok:      true,
	}, nil
}

func main() {
	lambda.Start(Handler)
}

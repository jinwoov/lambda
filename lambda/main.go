package main

import (
	"bytes"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
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
		req.Age = 3
		req.Breed = "golden"
		req.Name = "mochi"
	}

	err := uploadToS3(req)
	if err != nil {
		return Response{}, err
	}

	return Response{
		Message: fmt.Sprintf("Hey %s, I can Arf too! You are %d old and is %s breed", req.Name, req.Age, req.Breed),
		Ok:      true,
	}, nil
}

func main() {
	lambda.Start(Handler)
}

func uploadToS3(r Request) error {
	sesh := session.Must(session.NewSession())

	uploader := s3manager.NewUploader(sesh)

	rb, err := json.Marshal(r)
	if err != nil {
		return fmt.Errorf("unable to marshalize object. Error: %v", err)
	}

	requestReader := bytes.NewReader(rb)

	result, err := uploader.Upload(&s3manager.UploadInput{
		Bucket: aws.String("dogbucket-jk"),
		Key:    aws.String("bowwow/dogworld.txt"),
		Body:   requestReader,
	})
	if err != nil {
		return fmt.Errorf("failed to upload file. Error %v", err)
	}

	fmt.Printf("file uploaded to %v\n", aws.String(result.Location))

	return nil
}

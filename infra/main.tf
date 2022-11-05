resource "aws_lambda_function" "test_lambda" {
  filename         = data.archive_file.lambda_function.output_path
  function_name    = "main"
  role             = aws_iam_role.iam_role_lambda.arn
  handler          = "main"
  runtime          = "go1.x"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  description = "my funny lambda"
  tags = {
    "whereami" = "whoknows"
  }
}

data "archive_file" "lambda_function" {
  type             = "zip"
  source_file      = "${path.module}/../lambda/main"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/main.zip"
}

resource "aws_s3_bucket" "dogbucket" {
  bucket = "dogbucket-jk"
}

resource "aws_s3_bucket_acl" "acl_s3" {
  bucket = aws_s3_bucket.dogbucket.id
  acl    = "private"
}
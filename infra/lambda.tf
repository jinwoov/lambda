resource "aws_iam_role" "iam_role_lambda" {
  name = "iam_role_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "test_lambda" {
  filename         = data.archive_file.lambda_function.output_path
  function_name    = "main"
  role             = aws_iam_role.iam_role_lambda.arn
  handler          = "main"
  runtime          = "go1.x"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
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
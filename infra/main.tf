resource "aws_lambda_function" "test_lambda" {
  filename         = data.archive_file.lambda_function.output_path
  function_name    = var.function_name
  role             = aws_iam_role.iam_role_lambda.arn
  handler          = var.function_name
  runtime          = "go1.x"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  description      = "my funny lambda"
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
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_acl" "acl_s3" {
  bucket = aws_s3_bucket.dogbucket.id
  acl    = "private"
}

resource "aws_cloudwatch_event_rule" "cron_event_rule" {
  name                = var.cron_name
  description         = "Scheduled every 1 min"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "cron_event_target" {
  arn  = aws_lambda_function.test_lambda.arn
  rule = aws_cloudwatch_event_rule.cron_event_rule.name
}
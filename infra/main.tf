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
  source_file      = "${path.module}/main"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/main.zip"
}

resource "aws_s3_bucket" "dogbucket" {
  bucket        = "dogbucket-jk"
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
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "cron_event_target" {
  arn  = aws_lambda_function.test_lambda.arn
  rule = aws_cloudwatch_event_rule.cron_event_rule.name

  lifecycle {
    precondition {
      condition     = aws_lambda_function.test_lambda.runtime == "go1.x"
      error_message = "it has to be go environment"
    }
  }
}

resource "aws_sfn_state_machine" "sfn_to_lambda" {
  name     = var.sfn_name
  role_arn = aws_iam_role.sfn_role.arn

  definition = jsonencode({
    "Comment" : "Invoke AWS lambda from step functions",
    "StartAt" : "doggy",
    "States" : {
      "doggy" : {
        "Type" : "Task",
        "Resource" : "${aws_lambda_function.test_lambda.arn}",
        "End" : true
      }
    }
  })
}
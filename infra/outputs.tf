output "function_name" {
  value = aws_lambda_function.test_lambda.function_name
  description = "function name"
}

output "function_tags" {
  value = aws_lambda_function.test_lambda.tags
  description = "tags"
}
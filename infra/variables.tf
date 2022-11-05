variable "function_name" {
  default     = "main"
  type        = string
  description = "funtion name"
}

variable "cloudwatch_name" {
  default     = "lambda_logs"
  type        = string
  description = "name of the cloudwatch"
}

variable "cron_name" {
  default     = "mochi_trigger"
  type        = string
  description = "cron name"
}
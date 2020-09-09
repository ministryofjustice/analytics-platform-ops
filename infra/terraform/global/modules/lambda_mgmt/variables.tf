variable "lambda_function_name" {
  description = "The default name of all resources"
}

variable "lambda_runtime" {
  default     = "go1.x"
  description = "Runtime language for lambda function. See: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime"
}

variable "handler" {
  description = "Entrypoint filename. For `Golang` this must match `lambda_function_name`"
}

variable "zipfile" {
  description = "Path to zip file containing code"
}

variable "enabled" {
  default = true
  type    = bool
}

variable "timeout" {
  default = 3
}

variable "schedule_expression" {
  default = "rate(1 day)"
}

variable "source_code_hash" {
}

variable "lamda_policy" {
  description = "The IAM policy document.  Usually JSON"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "The environment variables for you lambda function"
}

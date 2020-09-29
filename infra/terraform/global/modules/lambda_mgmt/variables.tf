variable "lambda_function_name" {
  type        = string
  description = "The default name of all resources"
}

variable "lambda_runtime" {
  type        = string
  default     = "go1.x"
  description = "Runtime language for lambda function."
}

variable "handler" {
  type        = string
  description = "The entrypoint into your Lambda function, in the form of `filename.function_name`. For `Golang` this must match `lambda_function_name`"
}

variable "zipfile" {
  type        = string
  description = "Path to zip file containing code"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "(optional) Boolean expression. If false, the lambda function and the cloudwatch schedule are not set."
}

variable "timeout" {
  type        = number
  default     = 3
  description = "(optional) The amount of time your Lambda Function has to run in seconds. Defaults to 3"
}

variable "schedule_expression" {
  type        = string
  default     = "rate(1 day)"
  description = "A valid rate or cron expression"
}

variable "source_code_hash" {
  type        = string
  description = "The base64 encoded sha256 hash of the archive file"
}

variable "lamda_policy" {
  type        = string
  description = "The IAM policy document to attach to the lambda"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "(optional) The environment variables for you lambda function"

}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to resources"
}

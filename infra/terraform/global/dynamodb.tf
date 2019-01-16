resource "aws_dynamodb_table" "terraform-lock-platform-base" {
  name           = "terraform-platform-base"
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "terraform-lock-platform" {
  name           = "terraform-platform"
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}

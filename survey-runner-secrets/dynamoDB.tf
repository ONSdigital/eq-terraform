resource "aws_dynamodb_table" "credential-store" {
  name           = "${var.env}-credential-store"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "name"
  range_key      = "version"

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "version"
    type = "S"
  }

  tags {
    Environment = "${var.env}"
  }
}
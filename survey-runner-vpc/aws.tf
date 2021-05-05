provider "aws" {
  allowed_account_ids = ["${var.aws_account_id}"]
  version = "~> 2.7"
  assume_role {
    role_arn  = "${var.aws_assume_role_arn}"
  }
  region     = "eu-west-1"
}
provider "archive" {
  version = "~> 1.3"
}
provider "null" {
  version = "~> 2.1"
}
provider "template" {
  version = "~> 2.2"
}
terraform {
  backend "s3" {
    region = "eu-west-1"
  }
}
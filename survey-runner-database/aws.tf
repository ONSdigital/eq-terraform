provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "eu-west-1"
}

data "aws_caller_identity" "current" {}

terraform {
  required_version = ">= 0.10.0, < 0.11.0"

  backend "s3" {
    region = "eu-west-1"
  }
}
provider "aws" {
  allowed_account_ids = ["${var.aws_account_id}"]
  assume_role {
    role_arn  = "${var.aws_assume_role_arn}"
  }
  region     = "eu-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  current = true
}

data "aws_route53_zone" "dns_zone" {
  name = "${var.dns_zone_name}"
}

terraform {
  required_version = ">= 0.10.0, < 0.11.0"

  backend "s3" {
    region = "eu-west-1"
  }
}
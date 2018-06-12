provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
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
variable "env" {
  description = "The environment you wish to use"
}

variable "aws_account_id" {
  description = "Amazon Web Service Account ID"
}

variable "aws_assume_role_arn" {
  description = "IAM Role to assume on AWS"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
}

variable "database_cidrs" {
  type        = "list"
  description = "CIDR blocks for database subnets"
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "vpc_name" {
  description = "An unique name for the vpc"
}

variable "database_subnet_group_identifier" {
  description = "A unique identifier to use for aws_db_subnet_group"
  default = ""
}

variable "env" {
  description = "The environment you wish to use"
}

variable "aws_account_id" {
  description = "Amazon Web Service Account ID"
}

variable "aws_assume_role_arn" {
  description = "IAM Role to assume on AWS"
}

variable "vpc_id" {
  description = "An existing VPC ID"
}

variable "internet_gateway_id" {
  description = "An existing VPC Internet Gateway ID"
}

variable "public_cidrs" {
  type        = "list"
  description = "CIDR blocks for public subnets"
}

variable "vpc_peer_connection_id" {
  description = "The conneciton id of the peered VPC, optional"
  default     = ""
}

variable "vpc_peer_cidr_block" {
  description = "The CIDR block of the peered VPC, optional"
  default     = ""
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "database_subnet_ids" {
  type        = "list"
  description = "Ids of the database subnets"
}

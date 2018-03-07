variable "env" {
  description = "The environment you wish to use"
}

variable "aws_secret_key" {
  description = "Amazon Web Service Secret Key"
}

variable "aws_access_key" {
  description = "Amazon Web Service Access Key"
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

variable "database_cidrs" {
  type        = "list"
  description = "CIDR blocks for database subnets"
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
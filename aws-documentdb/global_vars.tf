variable "env" {
  description = "The environment you wish to use"
}

variable "aws_account_id" {
  description = "Amazon Web Service Account ID"
}

variable "aws_assume_role_arn" {
  description = "IAM Role to assume on AWS"
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "master_username" {
  description = "CIDR blocks for applications"
}

variable "master_password" {
  description = "CIDR blocks for applications"
}

variable "vpc_id" {
  description = "The survey runner VPC ID"
}

variable "documentdb_security_group_name" {
  description = "database security group name"
}

variable "documentdb_cluster_name" {
  description = "database security group name"
}

variable "documentdb_instance_size" {
  description = "instance size for db"
  default     = "db.t3.medium"
}

variable "documentdb_subnet_group_name" {
  description = "name for subnet group"
}

variable "application_cidrs" {
  type        = "list"
  description = "CIDR blocks for applications"
}

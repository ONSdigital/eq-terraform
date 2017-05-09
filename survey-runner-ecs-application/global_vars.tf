variable "env" {
  description = "The environment you wish to use"
}

variable "aws_secret_key" {
  description = "Amazon Web Service Secret Key"
}

variable "aws_access_key" {
  description = "Amazon Web Service Access Key"
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "ecs_instance_type" {
  description = "ECS Instance Type"
  default     = "t2.medium"
}

variable "ecs_aws_key_pair" {
  description = "Amazon Web Service Key Pair for use by ecs - in production this value should be empty"
  default     = ""
}

variable "ecs_cluster_min_size" {
  description = "ECS Cluster Minimum number of instances"
  default     = "1"
}

variable "ecs_cluster_max_size" {
  description = "ECS Cluster Maximum number of instances"
  default     = "3"
}

variable "ecs_cluster_desired_size" {
  description = "ECS Cluster Desired number of instances"
  default     = "1"
}

variable "vpc_id" {
  description = "The survey runner VPC ID"
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets for the external ELBs"
}

variable "vpc_peer_cidr_block" {
  description = "The CIDR block of the peered VPC, optional"
  default     = "0.0.0.0/0"
}

variable "application_cidrs" {
  type        = "list"
  description = "CIDR blocks for application subnets"
}

variable "private_route_table_ids" {
  description = "Route tables with route to NAT gateway"
}

# DNS
variable "dns_zone_id" {
  description = "Amazon Route53 DNS zone identifier"
  default     = "Z2XIERRF1SJEYP"
}

variable "dns_zone_name" {
  description = "Amazon Route53 DNS zone name"
  default     = "eq.ons.digital."
}

variable "application_secret_key" {
  description = "The Flask secret key for secure cookie storage"
}

# RabbitMQ
variable "rabbitmq_ip_prime" {
  description = "Static IP of prime rabbitmq server"
}

variable "rabbitmq_ip_failover" {
  description = "Static IP of secondary failover rabbitmq server"
}

variable "rabbitmq_write_user" {
  description = "The 'write-only' user to create for rabbitmq"
}

variable "rabbitmq_write_password" {
  description = "The 'write-only' user password for rabbitmq"
}

# Database
variable "database_address" {
  description = "The address of the postgres database"
}

variable "database_port" {
  description = "The port of the postgres database"
}

variable "database_name" {
  description = "The name of the database"
  default     = "digitaleqrds"
}

variable "database_user" {
  description = "The master username for the database"
  default     = "digitaleq12345"
}

variable "database_password" {
  description = "The password for the master username of the database"
  default     = "digitaleq12345"
}
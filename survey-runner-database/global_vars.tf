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

variable "vpc_id" {
  description = "The survey runner VPC ID"
}

variable "private_route_table_ids" {
  type = "list"
  description = "Route tables with route to NAT gateway"
}

variable "application_cidrs" {
  type        = "list"
  description = "CIDR blocks for application subnets"
}

variable "database_cidrs" {
  type        = "list"
  description = "CIDR blocks for database subnets"
}

variable "database_allocated_storage" {
  description = "The allocated storage for the database (in GB)"
  default     = 640
}

variable "database_engine_version" {
  description = "The Postgres database engine version"
  default     = "9.4.7"
}

variable "allow_major_version_upgrade" {
  description = "Allow major database version upgrades e.g. 9.4.x to 9.5.x"
  default     = false
}

variable "database_instance_class" {
  description = "The size of the DB instance"
  default     = "db.r3.4xlarge"
}

variable "multi_az" {
  description = "Distribute database across multiple availability zones"
  default     = true
}

variable "backup_retention_period" {
  description = "How many days database backup to keep"
  default     = 7
}

variable "database_name" {
  description = "The name of the database"
}

variable "database_user" {
  description = "The master username for the database"
}

variable "database_password" {
  description = "The password for the master username of the database"
}

variable "database_apply_immediately" {
  description = "Apply changes to the database immediately and not during next maintenance window"
  default     = false
}

variable "database_free_memory_alert_level" {
  description = "The level at which to alert about lack of freeable memory (MB)"
  default     = 512
}

variable "database_free_storage_alert_level" {
  description = "The level at which to alert about lack of free storage (GB)"
  default     = 5
}

variable "snapshot_identifier" {
  default     = ""
}

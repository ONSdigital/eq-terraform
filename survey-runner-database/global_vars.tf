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
  description = "The survey runner VPC ID"
}

variable "application_cidrs" {
  type        = "list"
  description = "CIDR blocks for application subnets"
}

variable "database_allocated_storage" {
  description = "The allocated storage for the database (in GB)"
  default     = 640
}

variable "database_engine_version" {
  description = "The Postgres database engine version"
  default     = "9.4.15"
}

variable "allow_major_version_upgrade" {
  description = "Allow major database version upgrades e.g. 9.4.x to 9.5.x"
  default     = false
}

variable "database_instance_class" {
  description = "The size of the DB instance"
  default     = "db.r3.xlarge"
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

variable "preferred_maintenance_window" {
  default   = "Tue:02:00-Tue:02:30"
}

variable "db_subnet_group_name" {
  description = "The name of the database subnet group."
}

variable "database_identifier" {
  description = "An unique identifier for the database."
}

variable "rds_security_group_name" {
  description = "The name of the security group for the rds database."
}
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
  description = "The survey runner VPC ID"
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
}

variable "vpc_peer_cidr_block" {
  description = "The CIDR block of the peered VPC, optional"
  default     = ""
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets for the external ELBs"
}

variable "private_route_table_ids" {
  description = "Route tables with route to NAT gateway"
}

variable "application_cidrs" {
  type        = "list"
  description = "CIDR blocks for application subnets"
}

variable "use_internal_elb" {
  description = "Set to true to use an internal load balancer"
  default     = false
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "ons_access_ips" {
  description = "List of IP's or IP ranges to allow access to eQ"
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

# EB Configuration
variable "aws_elastic_beanstalk_solution_stack_name" {
  description = "Elastic Beanstalk Amazon Linux version"
  default     = "64bit Amazon Linux 2016.09 v2.3.1 running Python 3.4"
}

variable "eb_instance_type" {
  description = "Elastic Beanstalk Instance Type"
  default     = "t2.medium"
}

variable "eb_min_size" {
  description = "Elastic Beanstalk Minimum number of instances"
  default     = "2"
}

variable "eb_max_size" {
  description = "Elastic Beanstalk Maximum number of instances"
  default     = "2"
}

variable "wsgi_number_of_processes" {
  description = "The number of daemon processes that should be started for the process group when running WSGI applications"
  default     = 1
}

variable "wsgi_number_of_threads" {
  description = "The number of threads to be created to handle requests in each daemon process within the process group when running WSGI applications"
  default     = 15
}

variable "elastic_beanstalk_aws_key_pair" {
  description = "Amazon Web Service Key Pair for use by elastic beanstalk - in production this value should be empty"
  default     = ""
}

variable "elastic_beanstalk_iam_role" {
  default = "aws-elasticbeanstalk-ec2-role-runner"
}

variable "certificate_arn" {
  description = "ARN of the IAM loaded TLS certificate for public ELB"
}

# EB Application Configuration
variable "aws_default_region" {
  description = "The default region for AWS Services"
  default     = "eu-west-1"
}

variable "eq_sr_log_level" {
  description = "The Survey Runner logging level (One of ['CRITICAL', 'ERROR', 'WARNING', 'INFO', 'DEBUG'])"
  default     = "ERROR"
}

variable "survey_runner_env" {
  description = "The name of the survey runner environment, which is set as a environment variable."
  default     = "development"
}

variable "eq_server_side_storage_encryption" {
  default = "True"
}

variable "eq_server_side_storage_type" {
  default = "DATABASE"
}

variable "google_analytics_code" {
  description = "The google analytics UA Code"
}

variable "application_secret_key" {
  description = "The Flask secret key for secure cookie storage"
}

variable "dev_mode" {
  description = "Flag to enabled DEV Mode defaulted to False"
  default     = "False"
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

# RabbitMQ
variable "rabbitmq_ip_prime" {
  description = "Static IP of prime rabbitmq server"
}

variable "rabbitmq_ip_failover" {
  description = "Static IP of secondary failover rabbitmq server"
}

variable "rabbitmq_admin_user" {
  description = "The admin user to create for rabbitmq"
}

variable "rabbitmq_admin_password" {
  description = "The admin user password for rabbitmq"
}

variable "rabbitmq_read_user" {
  description = "The 'read-only' user to create for rabbitmq"
}

variable "rabbitmq_read_password" {
  description = "The 'read-only' user password for rabbitmq"
}

variable "rabbitmq_write_user" {
  description = "The 'write-only' user to create for rabbitmq"
}

variable "rabbitmq_write_password" {
  description = "The 'write-only' user password for rabbitmq"
}

variable "message_queue_name" {
  description = "RabbitMQ submission queue name"
  default     = "submit_q"
}

variable "message_test_queue_name" {
  description = "RabbitMQ health check queue name"
  default     = "test_q"
}

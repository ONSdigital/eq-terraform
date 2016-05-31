variable "env" {
     description = "The environment you wish to use."
}

variable "aws_secret_key" {
    description = "Amazon Web Service Secret Key."
}

variable "aws_access_key"  {
    description = "Amazon Web Service Access Key;"
}

variable "aws_key_pair" {
    description = "Amazon Web Service Key Pair;"
    default="pre-prod"
}

variable "dns_zone_id" {
  description = "Amazon Route53 DNS zone identifier"
  default = "Z2XIERRF1SJEYP"
}

variable "dns_zone_name" {
  description = "Amazon Route53 DNS zone name"
  default     = "eq.ons.digital."
}

variable "vpc_ip_block" {
  description = "VPC internal IP cidr block for ec2 machines"
}

variable "ons_access_ips" {
  description = "List of IP's or IP ranges to allow access to our service."
}

variable "application_cidr" {
  description="CIDR block for application subnet"
}

variable "database_1_cidr" {
  description="1st CIDR block for the database"
}

variable "database_2_cidr" {
  description="2nd CIDR block for the database"
}

variable "database_name" {
  description = "The name of the database"
  default="eqauthor"
}

variable "database_user" {
  description = "The master username for the database"
  default = "digitaleq12345"
}

variable "database_password" {
  description = "The password for the master username of the database"
  default = "digitaleq12345"
}

variable "eb_min_size" {
  description = "Elastic Beanstalk Minimum number of instances"
  default     = "2"
}

variable "eb_max_size" {
  description = "Elastic Beanstalk Maximum number of instances"
  default     = "2"
}

variable "aws_elastic_beanstalk_solution_stack_name" {
  description = "Elastic Beanstalk Amazon Linux version"
  default = "64bit Amazon Linux 2016.03 v2.1.0 running Python 3.4"
}

variable "elastic_beanstalk_iam_role" {
  default = "aws-elasticbeanstalk-ec2-role"
}

variable "eb_instance_type" {
  description = "Elastic Beanstalk Instance Type"
  default     = "t2.medium"
}
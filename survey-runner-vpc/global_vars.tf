variable "env" {
     description = "The environment you wish to use"
}

variable "aws_secret_key" {
    description = "Amazon Web Service Secret Key"
}

variable "aws_access_key"  {
    description = "Amazon Web Service Access Key"
}

variable "vpc_ip_block" {
  description = "VPC internal IP cidr block for ec2 machines"
}

variable "tools_cidr" {
  description="CIDR block for tooling subnet"
}
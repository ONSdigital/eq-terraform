# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_ip_block}"
  enable_dns_support = true
  tags {
    Name = "${var.env}-vpc"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
    Name = "${var.env}-igateway"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our ec2 instances and ElasticBeanstalk into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.vpc_ip_block}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.env}-default-subnet"
  }
}


# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "survey_runner"
  description = "Used for eQ"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere.
  # REMOVE in production via AWS console. 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }

  # Rabbitmq
  ## Clustering ports
  ingress {
    from_port = 4369
    to_port   = 4369
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }
  egress {
    from_port = 4369
    to_port   = 4369
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }
  ingress {
    from_port = 25672
    to_port   = 25672
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }
  egress {
    from_port = 25672
    to_port   = 25672
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }
  ## AMQP Connection ports
  ingress {
    from_port = 5672
    to_port   = 5672
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }
  egress {
    from_port = 5672
    to_port   = 5672
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }
  ingress {
    from_port = 5671
    to_port   = 5671
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }
  egress {
    from_port = 5671
    to_port   = 5671
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }
  # End RabbitMQ ports

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# External access security group
# Blocks access to an environment based on a
# set of IP's in tfvars file.
# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "ons_ips" {
  name        = "public_access_ip_restriction"
  description = "Block access to only ONS IPs"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.ons_access_ips)}"]
  }
}

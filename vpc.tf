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
  name        = "${var.env}-survey_runner"
  description = "Used for eQ"
  vpc_id      = "${aws_vpc.default.id}"

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
  name        = "${var.env}-public_access_ip_restriction"
  description = "Block access to only ONS IPs"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.ons_access_ips)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPN services control group
resource "aws_security_group" "vpn_services_logging_auditing" {
  name        = "${var.env}-vpn_services_logging_auditing"
  description = "Allow the VPN provided services to access our VPC"
  vpc_id      = "${aws_vpc.default.id}"

  # Auditing service
  egress {
    from_port   = 601
    to_port     = 601
    protocol    = "tcp"
    cidr_blocks = ["${var.audit_cidr}"]
  }
  egress {
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["${var.audit_cidr}"]
  }
  # Log service
  egress {
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["${var.logserver_cidr}"]
  }
  egress {
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = ["${var.logserver_cidr}"]
  }
}

resource "aws_security_group" "vpn_sdx_access" {
  name        = "${var.env}-vpn_services_sdx_access"
  description = "Allow the sdx system access to RabbitMQ servers."
  vpc_id      = "${aws_vpc.default.id}"

  # RabbitMQ access from SDX to queue servers
  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["${var.sdx_cidr}"]
  }
}

# Subnets for ElasticBeanstalk / Jenkins / WAF
# Create a subnet to launch our ec2 instances and ElasticBeanstalk into
resource "aws_subnet" "sr_application" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.application_cidr}"
  tags {
    Name = "${var.env}-application-subnet"
  }
}
# Create a subnet to launch our deployment tools into
resource "aws_subnet" "tools" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.tools_cidr}"
  tags {
    Name = "${var.env}-tools-subnet"
  }
}
# Create a subnet to launch our WAF into.
resource "aws_subnet" "waf" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.waf_cidr}"
  tags {
    Name = "${var.env}-waf-subnet"
  }
}

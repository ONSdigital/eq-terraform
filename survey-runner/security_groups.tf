# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "survey_runner_default" {
  name        = "${var.env}-survey_runner"
  description = "Used for eQ"
  vpc_id      = "${var.vpc_id}"

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
  tags {
    Name = "${var.env}-survey_runner_security_group"
  }
}


# External access security group
# Blocks access to an environment based on a
# set of IP's in tfvars file.
# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "survey_runner_ons_ips" {
  name        = "${var.env}-public_access_ip_restriction"
  description = "Block access to only ONS IPs"
  vpc_id      = "${var.vpc_id}"

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
  tags {
    Name = "${var.env}-survey_runner_ons_ips"
  }
}

# VPN services control group
resource "aws_security_group" "survey_runner_vpn_services_logging_auditing" {
  name        = "${var.env}-vpn_services_logging_auditing"
  description = "Allow the VPN provided services to access our VPC"
  vpc_id      = "${var.vpc_id}"

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

resource "aws_security_group" "survey_runner_vpn_sdx_access" {
  name        = "${var.env}-vpn_services_sdx_access"
  description = "Allow the sdx system access to RabbitMQ servers."
  vpc_id      = "${var.vpc_id}"

  # RabbitMQ access from SDX to queue servers
  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["${var.sdx_cidr}"]
  }
}

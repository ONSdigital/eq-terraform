# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "survey_runner_default" {
  name        = "${var.env}-survey-runner-application-sg"
  description = "eQ application security group"
  vpc_id      = "${var.vpc_id}"

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.env}-survey-runner-security-group"
  }
}

# External access security group
# Blocks access to an environment based on a
# set of IP's in tfvars file.
# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "survey_runner_ons_ips" {
  name        = "${var.env}-public-access-ip-restriction"
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
    Name = "${var.env}-public-access-ip-restriction"
  }
}

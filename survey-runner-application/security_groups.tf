# Access to the application from either the internet or WAF
# If using an internal ELB, we enable port 80 from the WAF peered VPC 
# If not using an internal ELB, we enable port 443 from the internet
resource "aws_security_group" "survey_runner_access" {
  name        = "${var.env}-survey-runner-access"
  description = "Allow access from the internet or WAF"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.use_internal_elb ? 80 : 443}"
    to_port     = "${var.use_internal_elb ? 80 : 443}"
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.use_internal_elb ? var.vpc_peer_cidr_block : var.ons_access_ips)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.env}-survey-runner-access"
    Environment = "${var.env}"
  }
}

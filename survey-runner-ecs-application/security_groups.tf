resource "aws_security_group" "survey_runner_alb" {
  name        = "${var.env}-survey-runner-alb"
  description = "Allow access from the internet or WAF"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_peer_cidr_block}"]
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

resource "aws_security_group" "survey_runner_ecs" {
  name        = "${var.env}-survey-runner-ecs"
  description = "Allow access from the internet or WAF"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_peer_cidr_block}"]
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

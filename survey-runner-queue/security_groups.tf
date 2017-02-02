resource "aws_security_group" "provision-allow-ssh-REMOVE" {
  name   = "${var.env}-provision-ssh-REMOVE"
  vpc_id = "${var.vpc_id}"

  # SSH access from anywhere.
  # REMOVE in production via AWS console.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rabbit_required" {
  name        = "${var.env}-rabbitmq-required"
  description = "Required for RabbitMQ operation"
  vpc_id      = "${var.vpc_id}"

  # Rabbitmq
  ## Clustering ports
  ingress {
    from_port   = 4369
    to_port     = 4369
    protocol    = "tcp"
    cidr_blocks = "${var.queue_cidrs}"
  }

  egress {
    from_port   = 4369
    to_port     = 4369
    protocol    = "tcp"
    cidr_blocks = "${var.queue_cidrs}"
  }

  ingress {
    from_port   = 25672
    to_port     = 25672
    protocol    = "tcp"
    cidr_blocks = "${var.queue_cidrs}"
  }

  egress {
    from_port   = 25672
    to_port     = 25672
    protocol    = "tcp"
    cidr_blocks = "${var.queue_cidrs}"
  }

  ## AMQP Connection ports
  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = "${var.application_cidrs}"
  }

  # End RabbitMQ ports
}

# VPN services control group
resource "aws_security_group" "survey_runner_vpn_services_logging_auditing" {
  name        = "${var.env}-vpn-logging-auditing"
  description = "Logging and auditing access to RabbitMQ servers"
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
  name        = "${var.env}-vpn-sdx-rabbitmq-access"
  description = "SDX access to RabbitMQ servers"
  vpc_id      = "${var.vpc_id}"

  # RabbitMQ access from SDX to queue servers
  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = "${var.sdx_cidrs}"
  }
}

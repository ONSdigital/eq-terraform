resource "aws_alb" "survey_runner" {
  name            = "survey-runner-alb"
  internal        = false
  security_groups = ["${aws_security_group.survey_runner_alb.id}"]
  subnets         = ["${split(",", var.public_subnet_ids)}"]

  tags {
    Name = "survey-runner-alb"
    Environment = "${var.env}"
  }
}

resource "aws_alb_target_group" "go-launch-a-survey_ecs" {
  name     = "go-launch-a-survey-ecs"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  health_check = {
    interval = 5
    timeout = 2
  }

  tags {
    Environment = "${var.env}"
  }
}

resource "aws_alb_listener" "survey_runner" {
  load_balancer_arn = "${aws_alb.survey_runner.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.go-launch-a-survey_ecs.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "survey_runner_dev" {
  listener_arn = "${aws_alb_listener.survey_runner.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.go-launch-a-survey_ecs.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.launch_survey_runner.name}"]
  }
}

resource "aws_route53_record" "launch_survey_runner" {
  zone_id = "${var.dns_zone_id}"
  name    = "${var.env}-surveys-launch.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_alb.survey_runner.dns_name}"]
}
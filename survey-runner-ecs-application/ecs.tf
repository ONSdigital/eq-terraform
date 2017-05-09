resource "aws_ecs_cluster" "survey_runner" {
  name = "${var.env}-survey_runner"
}

data "template_file" "survey_runner" {
  template = "${file("task-definitions/survey_runner.json")}"

  vars {
    EQ_SECRET_KEY = "${var.application_secret_key}"
    EQ_RABBITMQ_URL = "amqp://${var.rabbitmq_write_user}:${var.rabbitmq_write_password}@${var.rabbitmq_ip_prime}:5672/%2F"
    EQ_RABBITMQ_URL_SECONDARY = "amqp://${var.rabbitmq_write_user}:${var.rabbitmq_write_password}@${var.rabbitmq_ip_failover}:5672/%2F"
    EQ_SERVER_SIDE_STORAGE_DATABASE_URL = "postgresql://${var.database_user}:${var.database_password}@${var.database_address}:${var.database_port}/${var.database_name}"
    LOG_GROUP = "${aws_cloudwatch_log_group.eq-survey-runner.name}"
  }
}

resource "aws_ecs_task_definition" "survey_runner" {
  family                = "${var.env}-survey_runner"
  container_definitions = "${data.template_file.survey_runner.rendered}"
  task_role_arn = "${aws_iam_role.survey_runner.arn}"
}

resource "aws_ecs_service" "survey_runner" {
  depends_on = [
    "aws_alb_target_group.survey_runner_ecs",
    "aws_alb.survey_runner",
    "aws_alb_listener_rule.survey_runner_dev"
  ]
  name            = "${var.env}-survey_runner"
  cluster         = "${aws_ecs_cluster.survey_runner.id}"
  task_definition = "${aws_ecs_task_definition.survey_runner.arn}"
  desired_count   = 0
  iam_role        = "${aws_iam_role.survey_runner.arn}"


  load_balancer {
    target_group_arn = "${aws_alb_target_group.survey_runner_ecs.arn}"
    container_name = "eq-survey-runner"
    container_port = 5000
  }
}

data "template_file" "go-launch-a-survey" {
  template = "${file("task-definitions/go-launch-a-survey.json")}"

  vars {
    SURVEY_RUNNER_URL = "https://${var.env}-surveys.${var.dns_zone_name}"
  }
}

resource "aws_ecs_task_definition" "go-launch-a-survey" {
  family                = "${var.env}-go-launch-a-survey"
  container_definitions = "${data.template_file.go-launch-a-survey.rendered}"
  task_role_arn = "${aws_iam_role.survey_runner.arn}"
}

resource "aws_ecs_service" "go-launch-a-survey" {
  depends_on = ["aws_alb_target_group.go-launch-a-survey_ecs"]
  name            = "${var.env}-go-launch-a-survey"
  cluster         = "${aws_ecs_cluster.survey_runner.id}"
  task_definition = "${aws_ecs_task_definition.go-launch-a-survey.arn}"
  desired_count   = 3
  iam_role        = "${aws_iam_role.survey_runner.arn}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.go-launch-a-survey_ecs.arn}"
    container_name = "go-launch-a-survey"
    container_port = 8000
  }
}

resource "aws_launch_configuration" "ecs" {
  name                   = "${var.env}-survey-runner-ecs"
  image_id               = "ami-175f1964" // Amazon ECS-Optimized AMI
  instance_type          = "${var.ecs_instance_type}"
  key_name               = "${var.ecs_aws_key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.survey_runner.id}"
  security_groups        = ["${aws_security_group.survey_runner_ecs.id}"]
  user_data              = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.survey_runner.name} > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "survey_runner" {
  name                 = "${var.env}-survey-runner-ecs"
  availability_zones   = ["${var.availability_zones}"]
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  vpc_zone_identifier = ["${aws_subnet.application.*.id}"]
  min_size             = "${var.ecs_cluster_min_size}"
  max_size             = "${var.ecs_cluster_max_size}"
  desired_capacity     = "${var.ecs_cluster_desired_size}"
}
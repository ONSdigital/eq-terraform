resource "aws_iam_instance_profile" "survey_runner_ecs" {
  name  = "${var.env}_iam_instance_profile_for_survey_runner_ecs"
  roles = ["${aws_iam_role.survey_runner_ecs.name}"]
}

resource "aws_iam_role" "survey_runner_ecs" {
  name = "${var.env}_iam_instance_profile_for_survey_runner_ecs"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "survey_runner_ecs" {
  "statement" = {
      "effect" = "Allow",
      "actions" = [
        "ecs:CreateCluster",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecs:StartTask"
      ],
      "resources" = [
        "arn:aws:ecs:eu-west-1:${data.aws_caller_identity.current.account_id}:cluster/${aws_ecs_cluster.survey_runner.name}"
      ]
    }

  "statement" = {
      "effect" = "Allow",
      "actions" = [
        "ecs:DeregisterContainerInstance",
        "ecs:RegisterContainerInstance",
      ],
      "resources" = [
        "arn:aws:ecs:eu-west-1:${data.aws_caller_identity.current.account_id}:container-instance/*"
      ]
    }
}

resource "aws_iam_role_policy" "survey_runner_ecs" {
  name = "${var.env}_iam_instance_profile_for_survey_runner_ecs"
  role = "${aws_iam_role.survey_runner_ecs.id}"
  policy = "${data.aws_iam_policy_document.survey_runner_ecs.json}"
}

resource "aws_iam_role" "go_launch_a_survey" {
  name = "${var.env}_iam_for_go_launch_a_survey"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "go_launch_a_survey" {
  "statement" = {
      "effect" = "Allow",
      "actions" = [
        "elasticloadbalancing:*",
      ],
      "resources" = [
        "*"
      ]
    }
}

resource "aws_iam_role_policy" "go_launch_a_survey" {
  name = "${var.env}_iam_for_go_launch_a_survey"
  role = "${aws_iam_role.go_launch_a_survey.id}"
  policy = "${data.aws_iam_policy_document.go_launch_a_survey.json}"
}

resource "aws_iam_instance_profile" "eq_ecs" {
  name  = "${var.env}_iam_instance_profile_for_eq_ecs"
  roles = ["${aws_iam_role.eq_ecs.name}"]
}

resource "aws_iam_role" "eq_ecs" {
  name = "${var.env}_iam_instance_profile_for_eq_ecs"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "eq_ecs" {
  "statement" = {
      "effect" = "Allow",
      "actions" = [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
      ],
      "resources" = [
        "arn:aws:ecs:eu-west-1:${data.aws_caller_identity.current.account_id}:cluster/${aws_ecs_cluster.eq.name}"
      ]
    }

  "statement" = {
      "effect" = "Allow",
      "actions" = [
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:SubmitContainerStateChange",
        "ecs:SubmitTaskStateChange",
      ],
      "resources" = [
        "*"
      ]
    }


}

resource "aws_iam_role_policy" "eq_ecs" {
  name = "${var.env}_iam_instance_profile_for_eq_ecs"
  role = "${aws_iam_role.eq_ecs.id}"
  policy = "${data.aws_iam_policy_document.eq_ecs.json}"
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

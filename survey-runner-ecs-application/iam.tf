resource "aws_iam_instance_profile" "survey_runner" {
  name  = "${var.env}_iam_for_survey_runner_ecs"
  roles = ["${aws_iam_role.survey_runner.name}"]
}

resource "aws_iam_role" "survey_runner" {
  name = "${var.env}_iam_for_survey_runner_ecs"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


data "aws_iam_policy_document" "survey_runner" {
  "statement" = {
      "effect" = "Allow",
      "actions" = [
        "elasticloadbalancing:*",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress"
      ],
      "resources" = [
        "*"
      ]
    }

  "statement" = {
      "effect" = "Allow",
      "actions" = [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecs:StartTask"
      ],
      "resources" = [
        "*"
      ]
    }

  "statement" = {
    "effect" = "Allow",
    "actions" = [
        "logs:PutLogEvents",
        "logs:CreateLogStream"
    ],
    "resources" = [
        "arn:aws:logs:*:*:log-group:*"
    ]
  }
  "statement" = {
    "effect" = "Allow",
    "actions" = [
        "cloudwatch:*"
    ],
    "resources" = [
        "*"
    ]
  }

}

resource "aws_iam_role_policy" "survey_runner" {
  name = "${var.env}_iam_for_survey_runner_ecs"
  role = "${aws_iam_role.survey_runner.id}"
  policy = "${data.aws_iam_policy_document.survey_runner.json}"
}

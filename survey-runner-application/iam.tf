resource "aws_iam_instance_profile" "elasticbeanstalk_survey_runner" {
  name  = "${var.env}_iam_for_elasticbeanstalk_survey_runner"
  roles = ["${aws_iam_role.elasticbeanstalk_survey_runner.name}"]
}

resource "aws_iam_role" "elasticbeanstalk_survey_runner" {
  name = "${var.env}_iam_for_elasticbeanstalk_survey_runner"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


data "aws_iam_policy_document" "elasticbeanstalk_survey_runner" {
  "statement" = {
    "effect" = "Allow",
    "actions" = [
        "s3:Get*",
        "s3:List*",
        "s3:PutObject"
    ],
    "resources" = [
        "arn:aws:s3:::elasticbeanstalk-*",
        "arn:aws:s3:::elasticbeanstalk-*/*"
    ]
  }
  "statement" = {
    "effect" = "Allow",
    "actions" = [
        "dynamodb:Query"
    ],
    "resources" = [
        "arn:aws:dynamodb:${var.aws_default_region}:${data.aws_caller_identity.current.account_id}:table/${var.credstash_dynamodb_table}"
    ]
  }
  "statement" = {
    "effect" = "Allow",
    "actions" = [
        "kms:Decrypt"
    ],
    "resources" = [
        "${var.credstash_kms_key}"
    ]
  }
  "statement" = {
    "effect" = "Allow",
    "actions" = [
        "logs:PutLogEvents",
        "logs:CreateLogStream"
    ],
    "resources" = [
        "arn:aws:logs:*:*:log-group:/aws/elasticbeanstalk*"
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

resource "aws_iam_role_policy" "elasticbeanstalk_survey_runner" {
  name = "${var.env}_iam_for_elasticbeanstalk_survey_runner"
  role = "${aws_iam_role.elasticbeanstalk_survey_runner.id}"
  policy = "${data.aws_iam_policy_document.elasticbeanstalk_survey_runner.json}"
}

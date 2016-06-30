resource "aws_iam_role_policy" "rabbitmq-policy" {
    name = "rabbit-mq-${var.env}-policy"
    role = "${aws_iam_role.rabbitmq-role.name}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:Describe*",
        "cloudwatch:*",
        "logs:*",
        "sns:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "rabbitmq-instance-profile" {
    name = "rabbit-mq-${var.env}-instance-profile"
    roles = ["${aws_iam_role.rabbitmq-role.name}"]
}

resource "aws_iam_role" "rabbitmq-role" {
    name = "rabbit-mq-${var.env}-role"
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



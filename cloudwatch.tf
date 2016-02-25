resource "aws_cloudwatch_metric_alarm" "Rabbitmq1CPU" {
    alarm_name = "${var.env}-Rabbitmq 1 CPU alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "CPUUtilization"
    namespace ="AWS/EC2"
    period ="300"
    statistic ="Average"
    threshold ="80"
    alarm_description = "Alert generated if over 80% CPU usage"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "InstanceId"="${aws_instance.rabbitmq.0.id}"}
}

resource "aws_cloudwatch_metric_alarm" "Rabbitmq2CPU" {
    alarm_name = "${var.env}-Rabbitmq 2 CPU alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "CPUUtilization"
    namespace ="AWS/EC2"
    period ="300"
    statistic ="Average"
    threshold ="80"
    alarm_description = "Alert generated if over 80% CPU usage"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "InstanceId"="${aws_instance.rabbitmq.1.id}"}
}


resource "aws_cloudwatch_metric_alarm" "Submitter1CPU" {
    alarm_name = "${var.env}-Submitter 1 CPU alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "CPUUtilization"
    namespace ="AWS/EC2"
    period ="300"
    statistic ="Average"
    threshold ="80"
    alarm_description = "Alert generated if over 80% CPU usage"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "InstanceId"="${aws_instance.submitter.0.id}"}
}

resource "aws_cloudwatch_metric_alarm" "Submitter2CPU" {
    alarm_name = "${var.env}-Submitter 2 CPU alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "CPUUtilization"
    namespace ="AWS/EC2"
    period ="300"
    statistic ="Average"
    threshold ="80"
    alarm_description = "Alert generated if over 80% CPU usage"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "InstanceId"="${aws_instance.submitter.1.id}"}
}


resource "aws_cloudwatch_metric_alarm" "Rabbitmq1Status" {
    alarm_name = "${var.env}-Rabbitmq 1 Status alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "StatusCheckFailed"
    namespace ="AWS/EC2"
    period ="300"
    statistic ="Maximum"
    threshold ="1"
    alarm_description = "Alert generated if status changes to failure"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "InstanceId"="${aws_instance.rabbitmq.0.id}"}
}

resource "aws_cloudwatch_metric_alarm" "Rabbitmq2Status" {
    alarm_name = "${var.env}-Rabbitmq 2 Status alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "StatusCheckFailed"
    namespace ="AWS/EC2"
    period ="300"
    statistic ="Maximum"
    threshold ="1"
    alarm_description = "Alert generated if status changes to failure"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "InstanceId"="${aws_instance.rabbitmq.1.id}"}
}


resource "aws_cloudwatch_metric_alarm" "Submitter1Status" {
    alarm_name = "${var.env}-Submitter 1 Status alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "StatusCheckFailed"
    namespace ="AWS/EC2"
    period ="300"
    statistic ="Maximum"
    threshold ="1"
    alarm_description = "Alert generated if status changes to failure"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "InstanceId"="${aws_instance.submitter.0.id}"}
}

resource "aws_cloudwatch_metric_alarm" "Submitter2Status" {
    alarm_name = "${var.env}-Submitter 2 Status alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "StatusCheckFailed"
    namespace ="AWS/EC2"
    period ="300"
    statistic ="Maximum"
    threshold ="1"
    alarm_description = "Alert generated if status changes to failure"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "InstanceId"="${aws_instance.submitter.1.id}"}
}









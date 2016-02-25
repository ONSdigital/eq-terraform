resource "aws_cloudwatch_metric_alarm" "rabbitmq1_cpu" {
    alarm_name = "${var.env}-rabbitmq1-cpu-alert"
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

resource "aws_cloudwatch_metric_alarm" "rabbitmq2_cpu" {
    alarm_name = "${var.env}-rabbitmq2-cpu-alert"
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


resource "aws_cloudwatch_metric_alarm" "submitter1_cpu" {
    alarm_name = "${var.env}-submitter1-cpu-alert"
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

resource "aws_cloudwatch_metric_alarm" "submitter2_cpu" {
    alarm_name = "${var.env}-submitter2-cpu-alert"
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


resource "aws_cloudwatch_metric_alarm" "rabbitmq1_status" {
    alarm_name = "${var.env}-rabbitmq-1-status-alert"
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

resource "aws_cloudwatch_metric_alarm" "rabbitmq2_status" {
    alarm_name = "${var.env}-rabbitmq2-status-alert"
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


resource "aws_cloudwatch_metric_alarm" "submitter1_status" {
    alarm_name = "${var.env}-submitter1-status-alert"
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

resource "aws_cloudwatch_metric_alarm" "submitter2_status" {
    alarm_name = "${var.env}-submitter2-status-alert"
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









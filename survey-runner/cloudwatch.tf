resource "aws_cloudwatch_metric_alarm" "rabbitmq1_cluster_status" {
    alarm_name = "${var.env}-rabbitmq1-cluster-alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "${var.env}-rabbitmq1"
    namespace ="RabbitMQClusterStatus"
    period ="300"
    statistic ="Average"
    threshold ="1"
    alarm_description = "${var.env} rabbit mq 1 reporting cluster paritions"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
}

resource "aws_cloudwatch_metric_alarm" "rabbitmq2_cluster_status" {
    alarm_name = "${var.env}-rabbitmq2-cluster-alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "${var.env}-rabbitmq2"
    namespace ="RabbitMQClusterStatus"
    period ="300"
    statistic ="Average"
    threshold ="1"
    alarm_description = "${var.env} rabbit mq 2 reporting cluster paritions"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
}

resource "aws_cloudwatch_metric_alarm" "rabbitmq_cpu" {
    count = 2
    alarm_name = "${var.env}-rabbitmq${count.index + 1}-cpu-alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "CPUUtilization"
    namespace ="AWS/EC2"
    period ="300"
    statistic ="Average"
    threshold ="80"
    alarm_description = "Alert generated if over 80% CPU usage"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "InstanceId"="${element(aws_instance.rabbitmq.*.id,count.index)}" }
}

resource "aws_cloudwatch_metric_alarm" "rabbitmq_status" {
    count = 2
    alarm_name = "${var.env}-rabbitmq-${count.index + 1}-status-alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "StatusCheckFailed"
    namespace ="AWS/EC2"
    period ="300"
    statistic ="Maximum"
    threshold ="1"
    alarm_description = "Alert generated if status changes to failure"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "InstanceId"="${element(aws_instance.rabbitmq.*.id,count.index)}" }
}

resource "aws_cloudwatch_metric_alarm" "database_storage_alert" {
    alarm_name = "${var.env}-database-storage-alert"
    evaluation_periods = "1"
    comparison_operator = "LessThanOrEqualToThreshold"
    metric_name = "FreeStorageSpace"
    namespace ="AWS/RDS"
    period ="300"
    statistic ="Average"
    threshold ="1073741824"
    evaluation_periods="1"
    alarm_description = "Alert generated if the DB has less than a 1gb of spage left"
    alarm_actions = ["arn:aws:sns:eu-west-1:853958762481:slack-alarm"]
    dimensions { "DBInstanceIdentifier"="${aws_db_instance.survey_runner_database.identifier}"}
}

resource "aws_cloudwatch_metric_alarm" "database_cpu_alert" {
    alarm_name = "${var.env}-database-cpu-alert"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name = "CPUUtilization"
    namespace ="AWS/RDS"
    period ="300"
    statistic ="Average"
    threshold ="80"
    evaluation_periods="1"
    alarm_description = "Alert generated if the DB is using more than 80% CPU"
    alarm_actions = ["${var.cloudwatch_alarm_arn}"]
    dimensions { "DBInstanceIdentifier"="${aws_db_instance.survey_runner_database.identifier}"}
}

resource "aws_cloudwatch_metric_alarm" "database_free_memory_alert" {
    alarm_name = "${var.env}-database-free-memory-alert"
    evaluation_periods = "1"
    comparison_operator = "LessThanOrEqualToThreshold"
    metric_name = "FreeableMemory"
    namespace ="AWS/RDS"
    period ="300"
    statistic ="Average"
    threshold ="524288000"
    evaluation_periods="1"
    alarm_description = "Alert generated if the DB has less than a 512MB of memory left"
    alarm_actions = ["arn:aws:sns:eu-west-1:853958762481:slack-alarm"]
    dimensions { "DBInstanceIdentifier"="${aws_db_instance.survey_runner_database.identifier}"}
}
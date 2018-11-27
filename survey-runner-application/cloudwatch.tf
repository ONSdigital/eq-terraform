resource "aws_cloudwatch_metric_alarm" "cpu_usage" {
  alarm_name = "${var.env}-survey-runner-cpu-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "80"
  alarm_description = "Average ElasticBeanstalk CPU usage above Threshold of 80% for past 120 seconds"
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
  dimensions {
    AutoScalingGroupName = "${aws_elastic_beanstalk_environment.survey_runner_prime.autoscaling_groups[0]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "5xx_errors" {
  alarm_name = "${var.env}-survey-runner-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "HTTPCode_Backend_5XX"
  namespace = "AWS/ELB"
  period = "60"
  statistic = "Sum"
  threshold = "1"
  alarm_description = "There have been at least 1 5xx errors in the past 60 seconds"
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
  dimensions {
    LoadBalancerName = "${aws_elastic_beanstalk_environment.survey_runner_prime.load_balancers[0]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "4xx_errors" {
  alarm_name = "${var.env}-survey-runner-4xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "HTTPCode_Backend_4XX"
  namespace = "AWS/ELB"
  period = "60"
  statistic = "Sum"
  threshold = "100"
  alarm_description = "There have been at least 100 4xx errors in the past 120 seconds"
  dimensions {
    LoadBalancerName = "${aws_elastic_beanstalk_environment.survey_runner_prime.load_balancers[0]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "elb_5xx_errors" {
  alarm_name = "${var.env}-survey-runner-elb-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "HTTPCode_ELB_5XX"
  namespace = "AWS/ELB"
  period = "60"
  statistic = "Sum"
  threshold = "1"
  alarm_description = "There have been at least 1 5xx errors from the ELB in the past 60 seconds"
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
  dimensions {
    LoadBalancerName = "${aws_elastic_beanstalk_environment.survey_runner_prime.load_balancers[0]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "max_host_count" {
  alarm_name = "${var.env}-survey-runner-max_host_count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "HealthyHostCount"
  namespace = "AWS/ELB"
  period = "60"
  statistic = "Maximum"
  threshold = "${var.eb_max_size}"
  alarm_description = "The number of ElasticBeanstalk instances is at its Maximum of ${var.eb_max_size}"
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
  dimensions {
    LoadBalancerName = "${aws_elastic_beanstalk_environment.survey_runner_prime.load_balancers[0]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "min_host_count" {
  alarm_name = "${var.env}-survey-runner-min_host_count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "HealthyHostCount"
  namespace = "AWS/ELB"
  period = "60"
  statistic = "Minimum"
  threshold = "${var.eb_min_size}"
  alarm_description = "The number of ElasticBeanstalk instances is below its Minimum of ${var.eb_min_size}"
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
  dimensions {
    LoadBalancerName = "${aws_elastic_beanstalk_environment.survey_runner_prime.load_balancers[0]}"
  }
}

resource "aws_cloudwatch_log_metric_filter" "no_database_connections_remaining" {
  name           = "${var.env}_survey_runner_no_remaining_database_connections"
  pattern        = "\"remaining connection slots are reserved for non-replication superuser connections\""
  log_group_name = "/aws/elasticbeanstalk/${var.env}-prime/var/log/httpd/error_log"

  metric_transformation {
    name      = "${var.env}_survey_runner_no_remaining_database_connections"
    namespace = "${var.env}_SurveyRunner"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "no_remaining_database_connections" {
  alarm_name = "${var.env}-survey-runner-no_remaining_database_connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "${var.env}_survey_runner_no_remaining_database_connections"
  namespace = "${var.env}_SurveyRunner"
  period = "60"
  statistic = "Maximum"
  threshold = "1"
  alarm_description = "The number of database connections has been exhausted"
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
}
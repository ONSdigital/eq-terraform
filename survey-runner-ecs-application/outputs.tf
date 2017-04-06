//output "survey_runner_address" {
//  value = "${aws_route53_record.survey_runner.fqdn}"
//}

output "survey_runner_launcher_address" {
  value = "${aws_route53_record.launch_survey_runner.fqdn}"
}

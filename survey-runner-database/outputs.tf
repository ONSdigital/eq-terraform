output "database_address" {
  value = "${aws_db_instance.survey_runner_database.address}"
}

output "database_port" {
  value = "${aws_db_instance.survey_runner_database.port}"
}
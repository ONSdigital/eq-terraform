output "database_address" {
  value = "${aws_db_instance.survey_runner_database.address}"
}

output "database_port" {
  value = "${aws_db_instance.survey_runner_database.port}"
}

output "secret_id" {
  value = "${aws_secretsmanager_secret.database_credentials.name}"
}
resource "aws_secretsmanager_secret" "database_credentials" {
  name_prefix = "${var.env}/rds/${var.database_identifier}/"
}

resource "aws_secretsmanager_secret_version" "database_credentials" {
  secret_id     = "${aws_secretsmanager_secret.database_credentials.id}"
  secret_string = "${data.template_file.credentials.rendered}"
}

data "template_file" "credentials" {
  template = "${file("${path.module}/templates/credentials.tpl")}"

  vars {
    host = "${aws_db_instance.survey_runner_database.address}"
    port = "${aws_db_instance.survey_runner_database.port}"
    dbname = "${var.database_name}"
    username = "${aws_db_instance.survey_runner_database.username}"
    password = "${aws_db_instance.survey_runner_database.password}"
    engine = "${aws_db_instance.survey_runner_database.engine}"
    dbInstanceIdentifier = "${aws_db_instance.survey_runner_database.identifier}"
  }
}

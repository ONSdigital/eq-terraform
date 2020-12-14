output "vpc_id" {
  value = "${aws_vpc.survey_runner.id}"
}

output "internet_gateway_id" {
  value = "${aws_internet_gateway.igw.id}"
}

output "database_subnet_ids" {
  value = ["${aws_subnet.database.*.id}"]
}

output "database_subnet_group_name" {
  value = "${aws_db_subnet_group.database_subnet.name}"
}

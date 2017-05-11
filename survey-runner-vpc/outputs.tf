output "vpc_id" {
  value = "${aws_vpc.survey_runner.id}"
}

output "internet_gateway_id" {
  value = "${aws_internet_gateway.igw.id}"
}
# Create a VPC to launch our instances into
resource "aws_vpc" "survey_runner_default" {
  cidr_block = "${var.vpc_ip_block}"
  enable_dns_support = true
  tags {
    Name = "${var.env}-vpc"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "survey_runner_default" {
  vpc_id = "${aws_vpc.survey_runner_default.id}"
  tags {
    Name = "${var.env}-igateway"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "survey_runner_internet_access" {
  route_table_id         = "${aws_vpc.survey_runner_default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.survey_runner_default.id}"
}
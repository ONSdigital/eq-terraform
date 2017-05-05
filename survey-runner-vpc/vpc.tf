resource "aws_vpc" "survey_runner" {
  count              = 1
  cidr_block         = "${var.vpc_cidr_block}"
  enable_dns_support = true

  tags {
    Name = "${var.env}-vpc"
    Environment = "${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  count  = 1
  vpc_id = "${aws_vpc.survey_runner.id}"
  tags {
    Name = "${var.env}-internet-gateway"
    Environment = "${var.env}"
  }
}
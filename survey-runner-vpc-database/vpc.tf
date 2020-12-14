resource "aws_vpc" "survey_runner" {
  count              = 1
  cidr_block         = "${var.vpc_cidr_block}"
  enable_dns_support = true

  tags {
    Name = "${var.env}-${var.vpc_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  count  = 1
  vpc_id = "${aws_vpc.survey_runner.id}"
  tags {
    Name = "${var.env}-${var.vpc_name}-internet-gateway"
  }
}

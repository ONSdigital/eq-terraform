# Create a VPC to launch our instances into
resource "aws_vpc" "author-vpc" {
  cidr_block = "${var.vpc_ip_block}"
  enable_dns_support = true
  tags {
    Name = "${var.env}-author-vpc"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "author-gateway" {
  vpc_id = "${aws_vpc.author-vpc.id}"
  tags {
    Name = "${var.env}-author-internet-gateway"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "author_internet_access" {
  route_table_id         = "${aws_vpc.author-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.author-gateway.id}"
}

resource "aws_subnet" "author_application" {
  vpc_id                  = "${aws_vpc.author-vpc.id}"
  cidr_block              = "${var.application_cidr}"
  availability_zone       = "eu-west-1a"
  tags {
    Name = "${var.env}-author-application-subnet"
  }
}

# Create a subnet to launch our database into.
resource "aws_subnet" "database-1b" {
  vpc_id                  = "${aws_vpc.author-vpc.id}"
  cidr_block              = "${var.database_1_cidr}"
  availability_zone       = "eu-west-1b"
  tags {
    Name = "${var.env}-author-database-1b-subnet"
  }
}

resource "aws_subnet" "database-1c" {
  vpc_id                  = "${aws_vpc.author-vpc.id}"
  cidr_block              = "${var.database_2_cidr}"
  availability_zone       = "eu-west-1c"
  tags {
    Name = "${var.env}-author-database-1c-subnet"
  }
}

resource "aws_security_group" "author_ons_ips" {
  name        = "${var.env}-author-public_access_ip_restriction"
  description = "Block access to only ONS IPs"
  vpc_id      = "${aws_vpc.author-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.ons_access_ips)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.env}-author-security-group-whitelist"
  }
}

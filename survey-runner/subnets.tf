# Subnets for ElasticBeanstalk
# Create a subnet to launch our ec2 instances and ElasticBeanstalk into
resource "aws_subnet" "sr_application" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.application_cidr}"
  availability_zone       = "eu-west-1a"
  tags {
    Name = "${var.env}-application-subnet"
  }
}

# Create a subnet to launch our database into.
resource "aws_subnet" "survey_runner_database-1" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.database_1_cidr}"
  availability_zone       = "eu-west-1b"
  tags {
    Name = "${var.env}-database-1-subnet"
  }
}

resource "aws_subnet" "survey_runner_database-2" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.database_2_cidr}"
  availability_zone       = "eu-west-1c"
  tags {
    Name = "${var.env}-database-2-subnet"
  }
}

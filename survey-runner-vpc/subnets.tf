# Create a subnet to launch our deployment tools (Jenkins) into
resource "aws_subnet" "tools" {
  vpc_id                  = "${aws_vpc.survey_runner_default.id}"
  cidr_block              = "${var.tools_cidr}"
  availability_zone       = "eu-west-1a"
  tags {
    Name = "${var.env}-tools-subnet"
  }
}
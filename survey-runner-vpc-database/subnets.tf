# Private database subnets
resource "aws_subnet" "database" {
  count             = "${length(var.database_cidrs)}"
  vpc_id            = "${aws_vpc.survey_runner.id}"
  cidr_block        = "${var.database_cidrs[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Name        = "${var.env}-database-subnet-${count.index+1}"
    Environment = "${var.env}"
    Type        = "Database"
  }
}

resource "aws_db_subnet_group" "database_subnet" {
  name        = "${var.env}-eq-${var.database_subnet_group_identifier}database"
  description = "Database subnet group"
  subnet_ids  = ["${aws_subnet.database.*.id}"]

  tags {
    Name = "${var.env}-${var.vpc_name}-db-subnet-group"
    Environment = "${var.env}"
  }
}

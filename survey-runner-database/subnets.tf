# Private database subnets
resource "aws_subnet" "database" {
  count             = "${length(var.database_cidrs)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.database_cidrs[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Name        = "${var.env}-database-subnet-${count.index+1}"
    Environment = "${var.env}"
    Type        = "Database"
  }
}

# Associate subnets with route table to NAT gateway
resource "aws_route_table_association" "private" {
  count          = "${length(var.database_cidrs)}"
  subnet_id      = "${element(aws_subnet.database.*.id, count.index)}"
  route_table_id = "${element(split(",", var.private_route_table_ids), count.index)}"
}

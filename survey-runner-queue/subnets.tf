# Public queue subnet
resource "aws_subnet" "queue" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.queue_cidrs[0]}"
  availability_zone = "eu-west-1a"

  tags {
    Name        = "${var.env}-queue-subnet"
    Environment = "${var.env}"
    Type        = "Queue"
  }
}

resource "aws_route_table" "queue" {
  vpc_id = "${var.vpc_id}"
  propagating_vgws = "${var.virtual_private_gateway_id}"

  tags {
    Name        = "${var.env}-route-table-queue"
    Environment = "${var.env}"
    Type        = "Queue"
  }
}

resource "aws_route_table_association" "queue" {
  subnet_id      = "${aws_subnet.queue.id}"
  route_table_id = "${aws_route_table.queue.id}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.queue.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${var.internet_gateway_id}"
}

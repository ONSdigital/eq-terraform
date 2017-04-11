resource "aws_kms_key" "credstash" {
  description             = "KMS key for CredStash"

  tags {
    Environment = "${var.env}"
  }
}

resource "aws_kms_alias" "credstash" {
  name          = "alias/${var.env}-credstash"
  target_key_id = "${aws_kms_key.credstash.key_id}"

  tags {
    Environment = "${var.env}"
  }
}
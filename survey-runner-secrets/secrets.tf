resource "null_resource" "secrets" {
  depends_on = [
    "aws_dynamodb_table.credential-store",
    "aws_kms_key.credstash"
  ]
  provisioner "local-exec" {
    command = "sh ./provision_keys.sh ${aws_dynamodb_table.credential-store.name} ${aws_kms_key.credstash.key_id}"
  }

  triggers {
    eq-database-username = "${sha1(file("${path.module}/secrets/eq-database-username.txt"))}"
    eq-database-password = "${sha1(file("${path.module}/secrets/eq-database-password.txt"))}"
  }
}
resource "null_resource" "secrets" {
  depends_on = [
    "aws_dynamodb_table.credential-store",
    "aws_kms_key.credstash"
  ]
  provisioner "local-exec" {
    command = "sh ./provision_keys.sh ${aws_dynamodb_table.credential-store.name} ${aws_kms_key.credstash.key_id} ${var.database_user} ${var.database_password} ${var.rabbitmq_write_user} ${var.rabbitmq_write_password}"
  }
}
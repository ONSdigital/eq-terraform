resource "null_resource" "secrets" {
  depends_on = [
    "aws_dynamodb_table.credential-store",
    "aws_kms_key.credstash"
  ]
  provisioner "local-exec" {
    command = "sh ./provision_keys.sh ${aws_dynamodb_table.credential-store.name} ${aws_kms_key.credstash.key_id}"
  }
}
output "documentdb_cluster_endpoint" {
  value = "${aws_docdb_cluster.docdb.endpoint}"
}

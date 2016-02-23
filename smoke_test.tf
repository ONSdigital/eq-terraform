resource "null_resource" "smoke_test" {
    depends_on = ["aws_elastic_beanstalk_environment.sr_prime","aws_route53_record.survey_runner"]

    provisioner "local-exec" {
      command = "./run_smoke_test.sh ${var.env} ${var.dns_zone_name}"
    }

    provisioner "local-exec" {
      command = "rm -rf tmp"
    }
}

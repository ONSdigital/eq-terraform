# eq-terraform

Terraform project that creates the infrastructure for the EQ project alpha.

## Pre-requisites

The following programs must be installed:

1. Git
2. Ansible

Also the pre-prod.pem key must exist in this directory.

## Setting up Terraform

1. Install terraform(terraform.io) and add the binary to your shell path.

2. Copy `terraform.tfvars.example` to `terraform.tfvars`

4. Run `terraform plan` to check the output of terraform.

5. Run `terraform apply` to create your infrastructure environment.
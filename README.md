# eq-terraform

Terraform project that creates the infrastructure for the EQ project alpha.

## Pre-requisites

The following programs must be installed:

1. Git
2. Ansible

You may also need to explicitly tell Ansible to perform non-host key checking:

	`export ANSIBLE_HOST_KEY_CHECKING=False`

Also the pre-prod.pem key must exist in this directory.

## Setting up Terraform

1. Install terraform(terraform.io) and add the binary to your shell path.

2. Copy `terraform.tfvars.example` to `terraform.tfvars`

4. Run `terraform plan` to check the output of terraform.

5. Run `terraform apply` to create your infrastructure environment.

## Smoke Test
For the smoke test you will need

1. Ruby 2.2.3 (rbenv install 2.2.3)
2. Gem 2.5.2 (gem update --system '2.5.2')
3. Bundle should be 1.10.6 (gem install bundler -v 1.10.6)

## Troubleshooting

1. If your build fails make sure the tmp directory has been deleted.
2. If the build stalls on the ssh step waiting for user input set the following in your ~/.ssh/config file
    `StrictHostKeyChecking no`
    `UserKnownHostsFile /dev/null`

# eq-terraform

Terraform project that creates the infrastructure for the EQ project alpha.

## Pre-requisites

The following programs must be installed:

1. Git
1. Ansible - `brew install ansible`
1. AWS CLI - `brew install awscli`

Install roles required by [eq-messaging](https://github.com/ONSdigital/eq-messaging):

 `ansible-galaxy install -f -r survey-runner-queue/ansible-requirements.yml`

## Setting up your AWS credentials

1. Ensure you have been set up with an AWS account

1. Obtain your AWS credentials - http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html#cli-signup

1. And configure them - http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

## Setting up Terraform

1. Install [Terraform](https://terraform.io) - `brew install terraform`

1. Generate an SSH key pair in AWS with a unique name (e.g. your name) and save it to the top level (eq-terraform) directory

1. Restrict access to the key - `chmod 400 mykey.pem`

1. Copy `terraform.tfvars.example` to `terraform.tfvars`. You'll need to change all values to match your requirements, including the AWS credentials you set up previously. Ask another developer for any values you don't know.

## Running Terraform

  - Run `terraform init` to import the different modules and set up remote state. When asked to provide a name for the state file choose the same name as the `env` value in your `terraform.tfvars`

  - Run `terraform plan` to check the output of terraform

  - Run `terraform apply` to create your infrastructure environment

  - Run `terraform destroy` to destroy your infrastructure environment

## Alerting

A webhook will need to be created for a new integration via https://api.slack.com/incoming-webhooks. Alternatively, your team may already have a webhook url configured to send messages to your slack.  

Create a slack channel with the name `eq-<your-env-name>-alerts`, for example `eq-preprod-alerts`

## Additional Security

Once Terraform has completed successfully, remove the security group `provision-allow-ssh-REMOVE` from the RabbitMQ machines to block their SSH access. This is used to allow provisioning via Ansible.

## Troubleshooting

1. If your build fails make sure the tmp directory has been deleted.
1. If the build stalls on the ssh step waiting for user input set the following in your ~/.ssh/config file
    `UserKnownHostsFile /dev/null`

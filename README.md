# eq-terraform

Terraform project that creates the infrastructure for the EQ project alpha.

## Pre-requisites

The following programs must be installed:

1. Git
1. Ansible
1. AWS CLI

You may also need to explicitly tell Ansible to perform non-host key checking:

  `export ANSIBLE_HOST_KEY_CHECKING=False`

Make sure you've installed all the roles from eq-messaging

 `sudo ansible-galaxy install alexeymedvedchikov.rabbitmq,v0.0.2`

 `sudo ansible-galaxy install jnv.unattended-upgrades`

Also the pre-prod.pem key must exist in this directory.

## Setting up your AWS credentials

1. Ensure you have been set up with an AWS account

1. Obtain your AWS credentials - http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html#cli-signup

1. And configure them - http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

## Setting up Terraform

1. Install terraform(terraform.io) and add the binary to your shell path. If you are using Homebrew:

```
brew install terraform
```

1. Generate ssh key pair in AWS for your AWS user

1. Download and restrict access by executing:

```
chmod 400 mykey.pem
```

1. Move the ssh key to `eq-terraform/survey-runner-queue`

1. Copy `terraform.tfvars.example` to `terraform.tfvars` in both author and all survey-runner-* directories. You'll need to change all values containing an 'X' to match your requirements, including the AWS credentials you set up previously.

1. run `./generate-keys.sh` to generate random passwords

1. Copy `./test-keys` to `./survey-runner-secrets/secrets` to use test keys in a developer environment

1. To deploy survey-runner:

  - Export an `AWS_ENVIRONMENT_NAME` environment variable e.g. `export AWS_ENVIRONMENT_NAME=preprod` or `export AWS_ENVIRONMENT_NAME=$USER`

  - Run `survey-runner.sh plan` to check the output of terraform

  - Run `survey-runner.sh apply` to create your infrastructure environment

  - Run `survey-runner.sh destroy` to destroy your infrastructure environment

Note. If using a named profile ensure you have set the profile e.g. `export AWS_DEFAULT_PROFILE=ons`

1. To deploy author:

  - cd into author

  - Run `terraform plan` to check the output of terraform

  - Run `terraform apply` to create your infrastructure environment

  - Run `terraform destroy` to destroy your infrastructure environment

## Deploying the application
The terraform scripts will only create your elastic beanstalk environment and a holding page for your application. To
deploy either the survey runner or the author follow these steps:
1. eb init  (select your newly created environment)
1. eb list (will give you the environment name)
1. eb deploy <your-env-name>

## Alerting
A webhook will need to be created for a new integration via https://api.slack.com/incoming-webhooks
Alternatively, your team may already have a webhook url created to send messages to your slack.  

You will need to create a slack channel with the name, `eq-<your-env-name>-alerts`

Eg. eq-preprod-alerts

## Additional security

To increase the security of the system, remove the security group `"provision-allow-ssh-REMOVE`
from the rabbitmq machines to block their SSH access. This is retained to allow provisioning
via ansible. In future we may migrate to a bastion machine to provision, which could
be then replicated locally via docker / VM bastion.

## Troubleshooting

1. If your build fails make sure the tmp directory has been deleted.
1. If the build stalls on the ssh step waiting for user input set the following in your ~/.ssh/config file
    `StrictHostKeyChecking no`
    `UserKnownHostsFile /dev/null`

# eq-terraform

Terraform project that creates the infrastructure for the EQ project alpha.

## Pre-requisites

The following programs must be installed:

1. Git
2. Ansible

You may also need to explicitly tell Ansible to perform non-host key checking:

  `export ANSIBLE_HOST_KEY_CHECKING=False`

Make sure you've installed all the roles from eq-messaging

 `sudo ansible-galaxy install alexeymedvedchikov.rabbitmq`

 `sudo ansible-galaxy install jnv.unattended-upgrades`

Also the pre-prod.pem key must exist in this directory.

## Setting up your AWS credentials

1. Ensure you have been set up with an AWS account

2. Obtain your AWS credentials - http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html#cli-signup

3. And configure them - http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

## Setting up Terraform

1. Install terraform(terraform.io) and add the binary to your shell path. If you are using Homebrew:

`brew install terraform`

2. Copy `terraform.tfvars.example` to `terraform.tfvars` in both author and survey-runner. You'll need to change all values containing an 'X' to match your requirements, including the AWS credentials you set up previously.

3. To deploy survey-runner, first cd in survey-runner

4. Run `terraform plan` to check the output of terraform.

5. Run `terraform apply` to create your infrastructure environment.

6. To deploy-author, cd in author

7. Run `terraform plan` to check the output of terraform.

8. Run `terraform apply` to create your infrastructure environment.

## Deploying the application
The terraform scripts will only create your elastic beanstalk environment and a holding page for your application. To
deploy either the survey runner or the author follow these steps:
1. eb init  (select your newly created environment)
2. eb list (will give you the environment name)
3. eb deploy <your-env-name>

## IAM Role
Currently for this to work you need to add the CloudWatchFullAccess policy to the IAM role aws-elasticbeanstalk-ec2-role
using the IAM console in AWS

## Additional security

To increase the security of the system, remove the security group `"provision-allow-ssh-REMOVE`
from the rabbitmq machines to block their SSH access. This is retained to allow provisioning
via ansible. In future we may migrate to a bastion machine to provision, which could
be then replicated locally via docker / VM bastion.

## Troubleshooting

1. If your build fails make sure the tmp directory has been deleted.
2. If the build stalls on the ssh step waiting for user input set the following in your ~/.ssh/config file
    `StrictHostKeyChecking no`
    `UserKnownHostsFile /dev/null`

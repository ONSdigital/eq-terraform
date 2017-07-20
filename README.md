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

 `sudo ansible-galaxy install git+https://github.com/alexey-medvedchikov/ansible-rabbitmq.git,3e3531c0a12e2d5c597f2f45d1fdf8e449730574`

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

1. Move the ssh key to `eq-terraform`

1. Copy `terraform.tfvars.example` to `terraform.tfvars`. You'll need to change all values to match your requirements, including the AWS credentials you set up previously.

1. To deploy survey-runner:

  - Run `terraform get` to import the different modules
  
  - Run `terraform plan` to check the output of terraform

  - Run `terraform apply` to create your infrastructure environment

  - Run `terraform destroy` to destroy your infrastructure environment

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

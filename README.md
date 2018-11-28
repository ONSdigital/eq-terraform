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

1. Install [Terraform Version Manager](https://github.com/kamatama41/tfenv) - `brew install tfenv`

1. Install [Terraform](https://terraform.io) - `tfenv install`

1. In eu-west-1 (Ireland) region, generate an SSH key pair in AWS (Services > EC2 > Key Pairs > Create Key Pair) with a unique name (e.g. your name) and save it to the top level (eq-terraform) directory.

1. Restrict access to the key - `chmod 400 mykey.pem`

1. Copy `terraform.tfvars.example` to `terraform.tfvars`. 

```
env="" # your name (Do not use underscore)
aws_key_pair = "" # your name

# ask somebody on the team to send these values to you
aws_account_id=""
aws_assume_role_arn=""
ons_access_ips=""
certificate_arn=""
slack_webhook_path=""
```

1. Run `aws configure`. Add your AWS access key and secret key when prompted for S3. Use "eu-west-1" as your region name. Leave any other values as default.

## Running Terraform

  - Run `terraform init` to import the different modules and set up remote state. When asked to provide a name for the state file choose the same name as the `env` value in your `terraform.tfvars`

  - Run `terraform plan` to check the output of terraform

  - Run `terraform apply` to create your infrastructure environment

  - Run `terraform destroy` to destroy your infrastructure environment

## Updating infrastructure with new config

After making changes to your terraform config you can update your environment rather than destroying and recreating:

  - Run `terraform get --update` to import the updated modules to your local .terraform dir

  - Run `terraform plan` to check the output of terraform

  - Run `terraform apply` to apply the changes to your infrastructure environment

## Deploying a Survey Runner Branch

  1. You have to submit a github pull request for your branch
  1. Wait for the Travis build to pass
  1. Go to [Docker Hub](https://hub.docker.com/r/onsdigital/eq-survey-runner/tags/)
  1. Copy your tag (should be your branch name)
  1. Open `developer_defaults.tf`
  1. Find the `survey_runner_tag` variable
  1. Set the default to the docker tag you copied
  1. Run `terraform plan`
  1. Run `terraform apply`

## Alerting

A webhook will need to be created for a new integration via https://api.slack.com/incoming-webhooks. Alternatively, your team may already have a webhook url configured to send messages to your slack.

Create a slack channel with the name `eq-<your-env-name>-alerts`, for example `eq-preprod-alerts`

## Additional Security

Once Terraform has completed successfully, remove the security group `provision-allow-ssh-REMOVE` from the RabbitMQ machines to block their SSH access. This is used to allow provisioning via Ansible.

## Troubleshooting

1. If your build fails make sure the tmp directory has been deleted.
1. If the build stalls on the ssh step waiting for user input set the following in your ~/.ssh/config file
    `UserKnownHostsFile /dev/null`

## Runner VPC
cidr_block = `10.30.20.0/24`

| Subnet | CIDR | Size |
| --- | --- | --- |
| ENV-queue-subnet | `10.30.20.0/27` | 32 |
| ENV-ecs-application-subnet-1 | `10.30.20.32/28` | 16 |
| ENV-ecs-application-subnet-2 | `10.30.20.48/28` | 16 |
| ENV-ecs-application-subnet-3 | `10.30.20.64/28` | 16 |
| ENV-database-subnet-1 | `10.30.20.96/28` | 16 |
| ENV-database-subnet-2 | `10.30.20.112/28` | 16 |
| ENV-database-subnet-3 | `10.30.20.128/28` | 16 |
| ENV-public-subnet-1 | `10.30.20.144/28` | 16 |
| ENV-public-subnet-2 | `10.30.20.160/28` | 16 |
| ENV-public-subnet-3 | `10.30.20.176/28` | 16 |
| ENV-application-subnet-1 | `10.30.20.192/28` | 16 |
| ENV-application-subnet-2 | `10.30.20.208/28` | 16 |
| ENV-application-subnet-3 | `10.30.20.224/28` | 16 |
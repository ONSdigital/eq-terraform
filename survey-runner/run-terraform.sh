#!/bin/bash

if [ -z "$AWS_ENVIRONMENT_NAME" ]; then
    echo "Need to set AWS_ENVIRONMENT_NAME environment variable e.g. export AWS_ENVIRONMENT_NAME=preprod"
    exit 1
fi

export ANSIBLE_HOST_KEY_CHECKING=False
action=$1

if [ $action != "apply" ] && [ $action != "plan" ] && [ $action != "destroy" ]; then
    echo "You must provide an action (apply/plan/destroy) e.g. ./run-terraform.sh plan"
    exit 1
fi

vpc_name=${AWS_ENVIRONMENT_NAME}-vpc
VPC_ID=`aws ec2 describe-vpcs --output text --filter Name=tag:Name,Values="${vpc_name}" --query "Vpcs[*].VpcId"`

if [ -z "$VPC_ID" ]; then
    echo "Nothing to ${action}, no vpc exists!"
    exit 1
fi

terraform "$action" -var "env=${AWS_ENVIRONMENT_NAME}" -var "vpc_id=${VPC_ID}"

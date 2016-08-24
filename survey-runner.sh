#!/bin/bash

if [ -z "$AWS_ENVIRONMENT_NAME" ]; then
    echo "Need to set AWS_ENVIRONMENT_NAME environment variable e.g. export AWS_ENVIRONMENT_NAME=preprod"
    exit 1
fi

export ANSIBLE_HOST_KEY_CHECKING=False
export ACTION=$1

if [ $ACTION != 'apply' ] && [ $ACTION != 'plan' ] && [ $ACTION != 'destroy' ]; then
    echo "You must provide an action (apply/plan/destroy) e.g. ./survey-runner.sh plan"
    exit 1
fi

if [ $ACTION == 'plan' ] || [ $ACTION == 'apply' ]; then
    cd survey-runner-vpc
    terraform $ACTION -var "env=${AWS_ENVIRONMENT_NAME}"
    cd -
    cd survey-runner
    ./run-terraform.sh $ACTION
fi

if [ $ACTION == 'destroy' ]; then
    cd survey-runner
    ./run-terraform.sh destroy
    cd -
    cd survey-runner-vpc
    terraform destroy -var "env=${AWS_ENVIRONMENT_NAME}"
fi

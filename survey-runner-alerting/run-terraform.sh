#!/bin/bash

if [ -z "$AWS_ENVIRONMENT_NAME" ]; then
    echo "Need to set AWS_ENVIRONMENT_NAME environment variable e.g. export AWS_ENVIRONMENT_NAME=preprod"
    exit 1
fi

action=$1

if [ $action != "apply" ] && [ $action != "plan" ] && [ $action != "destroy" ]; then
    echo "You must provide an action (apply/plan/destroy) e.g. ./run-terraform.sh plan"
    exit 1
fi

cd lambda

zip -9 -r slack-alert.zip slack-alert/

cd ../

terraform $action -var "env=${AWS_ENVIRONMENT_NAME}"

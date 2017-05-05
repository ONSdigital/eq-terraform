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


if [ ! -d "./secrets" ]; then
    echo "You must provide secrets but putting them in the directory './survey-runner-secrets/secrets'"
    exit 1
fi

terraform $action -var "env=${AWS_ENVIRONMENT_NAME}"


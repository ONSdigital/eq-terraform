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
vpc_id=`aws ec2 describe-vpcs --output text --filter Name=tag:Name,Values=${vpc_name} --query 'Vpcs[*].VpcId'`

internet_gateway_id=`aws ec2 describe-internet-gateways --output text --filter Name=tag:Name,Values=${AWS_ENVIRONMENT_NAME}-internet-gateway --query 'InternetGateways[*].InternetGatewayId'`
if [ -z "$internet_gateway_id" ]; then
    echo "Nothing to ${action}, no internet gateway exists!"
    exit 1
fi

virtual_private_gateway_id=`aws ec2 describe-vpn-gateways --filter Name=tag:Name,Values=${AWS_ENVIRONMENT_NAME}-vgw --query 'VpnGateways[*].VpnGatewayId' --output text`
if [ -z "$virtual_private_gateway_id" ]; then
    virtual_private_gateway_id_value="[]"
else
    virtual_private_gateway_id_value="[\"${virtual_private_gateway_id}\"]"
fi

terraform $action -var "env=${AWS_ENVIRONMENT_NAME}" -var "vpc_id=${vpc_id}" -var "internet_gateway_id=${internet_gateway_id}" -var "virtual_private_gateway_id=${virtual_private_gateway_id_value}"



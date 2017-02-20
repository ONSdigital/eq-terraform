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

vpc_name=${AWS_ENVIRONMENT_NAME}-vpc
vpc_id=`aws ec2 describe-vpcs --output text --filter Name=tag:Name,Values=${vpc_name} --query 'Vpcs[*].VpcId'`

if [ -z "$vpc_id" ]; then
    echo "Nothing to ${action}, no vpc exists!"
    exit 1
fi

# get the private route table ids as a comma separated list
private_route_table_ids=`aws ec2 describe-route-tables --filters "Name=tag:Environment,Values=${AWS_ENVIRONMENT_NAME}" "Name=tag:Type,Values=Private" --query 'RouteTables[*].RouteTableId' --output text | tr '\t' ','`
if [ -z "$private_route_table_ids" ]; then
    echo "Nothing to ${action}, no private route tables exists!"
    exit 1
fi

terraform $action -var "env=${AWS_ENVIRONMENT_NAME}" -var "vpc_id=${vpc_id}" -var "private_route_table_ids=${private_route_table_ids}"


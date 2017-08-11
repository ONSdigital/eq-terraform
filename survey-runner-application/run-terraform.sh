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

vpc_id=`aws ec2 describe-vpcs --output text --filter Name=tag:Name,Values=${AWS_ENVIRONMENT_NAME}-vpc --query 'Vpcs[*].VpcId'`

database_address=`aws rds describe-db-instances --db-instance-identifier=${AWS_ENVIRONMENT_NAME}-digitaleqrds --query 'DBInstances[*].Endpoint.Address' --output text`
database_port=`aws rds describe-db-instances --db-instance-identifier=${AWS_ENVIRONMENT_NAME}-digitaleqrds --query 'DBInstances[*].Endpoint.Port' --output text`
database_name=`aws rds describe-db-instances --db-instance-identifier=${AWS_ENVIRONMENT_NAME}-digitaleqrds --query 'DBInstances[*].DBName' --output text`
if [ -z "$database_address" ]; then
    echo "Nothing to ${action}, no database exists!"
    exit 1
fi

# get the public subnet ids as a comma separated list
public_subnet_ids="[\"$(aws ec2 describe-subnets --filters "Name=tag:Environment,Values=${AWS_ENVIRONMENT_NAME}" "Name=tag:Type,Values=Public" --query 'Subnets[*].SubnetId' --output text | tr '\t' ',' | sed -e 's/,/","/g')\"]"
if [ -z "$public_subnet_ids" ]; then
    echo "Nothing to ${action}, no public subnets exist!"
    exit 1
fi

# get the private route table ids as a comma separated list
private_route_table_ids="[\"$(aws ec2 describe-route-tables --filters "Name=tag:Environment,Values=${AWS_ENVIRONMENT_NAME}" "Name=tag:Type,Values=Private" --query 'RouteTables[*].RouteTableId' --output text | tr '\t' ',' | sed -e 's/,/","/g')\"]"
if [ -z "$private_route_table_ids" ]; then
    echo "Nothing to ${action}, no private route tables exists!"
    exit 1
fi

terraform $action -var "env=${AWS_ENVIRONMENT_NAME}" -var "vpc_id=${vpc_id}" -var "database_address=${database_address}" -var "database_port=${database_port}" -var "database_name=${database_name}" -var "public_subnet_ids=${public_subnet_ids}" -var "private_route_table_ids=${private_route_table_ids}"


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
vpc_cidr_block=`aws ec2 describe-vpcs --output text --filter Name=tag:Name,Values=${AWS_ENVIRONMENT_NAME}-vpc --query 'Vpcs[*].CidrBlock'`
if [ -z "$vpc_id" ]; then
    echo "Nothing to ${action}, no vpc exists!"
    exit 1
fi

database_address=`aws rds describe-db-instances --db-instance-identifier=${AWS_ENVIRONMENT_NAME}-digitaleqrds --query 'DBInstances[*].Endpoint.Address' --output text`
database_port=`aws rds describe-db-instances --db-instance-identifier=${AWS_ENVIRONMENT_NAME}-digitaleqrds --query 'DBInstances[*].Endpoint.Port' --output text`
database_name=`aws rds describe-db-instances --db-instance-identifier=${AWS_ENVIRONMENT_NAME}-digitaleqrds --query 'DBInstances[*].DBName' --output text`
if [ -z "$database_address" ]; then
    echo "Nothing to ${action}, no database exists!"
    exit 1
fi

# get the public subnet ids as a comma separated list
public_subnet_ids=`aws ec2 describe-subnets --filters "Name=tag:Environment,Values=${AWS_ENVIRONMENT_NAME}" "Name=tag:Type,Values=Public" --query 'Subnets[*].SubnetId' --output text | tr '\t' ','`
if [ -z "$public_subnet_ids" ]; then
    echo "Nothing to ${action}, no public subnets exist!"
    exit 1
fi

# get the private route table ids as a comma separated list
private_route_table_ids=`aws ec2 describe-route-tables --filters "Name=tag:Environment,Values=${AWS_ENVIRONMENT_NAME}" "Name=tag:Type,Values=Private" --query 'RouteTables[*].RouteTableId' --output text | tr '\t' ','`
if [ -z "$private_route_table_ids" ]; then
    echo "Nothing to ${action}, no private route tables exists!"
    exit 1
fi

credstash_kms_key=`aws kms describe-key --key-id $(aws kms list-aliases --query 'Aliases[*].AliasArn' --output text  | tr '\t' '\n' | grep ${AWS_ENVIRONMENT_NAME}) --query 'KeyMetadata.Arn' --output text`
if [ -z "$credstash_kms_key" ]; then
    echo "Nothing to ${action}, no KMS key exists!"
    exit 1
fi

terraform $action -var "env=${AWS_ENVIRONMENT_NAME}" -var "vpc_id=${vpc_id}" -var "vpc_cidr_block=${vpc_cidr_block}" -var "database_address=${database_address}" -var "database_port=${database_port}" -var "database_name=${database_name}" -var "public_subnet_ids=${public_subnet_ids}" -var "private_route_table_ids=${private_route_table_ids}" -var "credstash_kms_key=${credstash_kms_key}"

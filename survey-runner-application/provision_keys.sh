#!/usr/bin/env bash

table="$1"
key="$2"

db_user="$3"
db_pass="$4"

rabbit_user="$5"
rabbit_pass="$6"

source "$(which virtualenvwrapper.sh)"
virtual_envs=$(lsvirtualenv -b)

mkvirtualenv --python="$(which python3)" credstash
workon credstash
pip install credstash

credstash --table $table put -k $key "EQ_SECRET_KEY" "SuperSecretDeveloperKey" -a
credstash --table $table put -k $key "EQ_SERVER_SIDE_STORAGE_DATABASE_USERNAME" $db_user -a
credstash --table $table put -k $key "EQ_SERVER_SIDE_STORAGE_DATABASE_PASSWORD" $db_pass -a

credstash --table $table put -k $key "EQ_RABBITMQ_USERNAME" $rabbit_user -a
credstash --table $table put -k $key "EQ_RABBITMQ_PASSWORD" $rabbit_pass -a

credstash --table $table put -k $key "EQ_USER_AUTHENTICATION_RRM_PUBLIC_KEY" "@secrets/sdc-user-authentication-signing-rrm-public-key.pem" -a
credstash --table $table put -k $key "EQ_USER_AUTHENTICATION_SR_PRIVATE_KEY" "@secrets/sdc-user-authentication-encryption-sr-private-key.pem" -a
credstash --table $table put -k $key "EQ_USER_AUTHENTICATION_SR_PRIVATE_KEY_PASSWORD" "@secrets/sdc-user-authentication-encryption-sr-private-key-password.txt" -a

credstash --table $table put -k $key "EQ_SUBMISSION_SDX_PUBLIC_KEY" "@secrets/sdc-submission-encryption-sdx-public-key.pem" -a
credstash --table $table put -k $key "EQ_SUBMISSION_SR_PRIVATE_SIGNING_KEY" "@secrets/sdc-submission-signing-sr-private-key.pem" -a
credstash --table $table put -k $key "EQ_SUBMISSION_SR_PRIVATE_SIGNING_KEY_PASSWORD" "@secrets/sdc-submission-signing-sr-private-key-password.txt" -a

#DEV MODE only
credstash --table $table put -k $key "EQ_USER_AUTHENTICATION_SR_PUBLIC_KEY" "@secrets/sdc-submission-signing-sr-public-key.pem" -a
credstash --table $table put -k $key "EQ_USER_AUTHENTICATION_RRM_PRIVATE_KEY" "@secrets/sdc-user-authentication-signing-rrm-private-key.pem" -a
credstash --table $table put -k $key "EQ_USER_AUTHENTICATION_RRM_PRIVATE_KEY_PASSWORD" "@secrets/sdc-user-authentication-signing-rrm-private-key-password.txt" -a


credstash --table $table put -k $key "EQ_SERVER_SIDE_STORAGE_USER_ID_SALT" "@secrets/sdc-storage-user-id-salt.txt"
credstash --table $table put -k $key "EQ_SERVER_SIDE_STORAGE_USER_IK_SALT" "@secrets/sdc-storage-user-ik-salt.txt"
credstash --table $table put -k $key "EQ_SERVER_SIDE_STORAGE_ENCRYPTION_USER_PEPPER" "@secrets/sdc-storage-encryption-user-pepper.txt"

deactivate
rmvirtualenv credstash

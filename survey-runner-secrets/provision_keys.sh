#!/usr/bin/env bash

table="$1"
key="$2"

algorithm="aes-gcm"

source "$(which virtualenvwrapper.sh)"
virtual_envs=$(lsvirtualenv -b)

mkvirtualenv --python="$(which python3)" credstash
workon credstash
#pip install credstash
pip install -e git+https://github.com/ONSdigital/credstash.git@d70f34bd9994ec626ad59b9c95ad3eb7dd0b0061#egg=credstash

credstash --table $table put --algorithm $algorithm -k $key "EQ_SECRET_KEY" "@secrets/eq-secret-key.txt" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_SERVER_SIDE_STORAGE_DATABASE_USERNAME" "@secrets/eq-database-username.txt" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_SERVER_SIDE_STORAGE_DATABASE_PASSWORD" "@secrets/eq-database-password.txt" -a

credstash --table $table put --algorithm $algorithm -k $key "EQ_RABBITMQ_USERNAME" "@secrets/eq-rabbitmq-username.txt" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_RABBITMQ_PASSWORD" "@secrets/eq-rabbitmq-password.txt" -a

credstash --table $table put --algorithm $algorithm -k $key "EQ_USER_AUTHENTICATION_RRM_PUBLIC_KEY" "@secrets/sdc-user-authentication-signing-rrm-public-key.pem" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_USER_AUTHENTICATION_SR_PRIVATE_KEY" "@secrets/sdc-user-authentication-encryption-sr-private-key.pem" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_USER_AUTHENTICATION_SR_PRIVATE_KEY_PASSWORD" "@secrets/sdc-user-authentication-encryption-sr-private-key-password.txt" -a

credstash --table $table put --algorithm $algorithm -k $key "EQ_SUBMISSION_SDX_PUBLIC_KEY" "@secrets/sdc-submission-encryption-sdx-public-key.pem" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_SUBMISSION_SR_PRIVATE_SIGNING_KEY" "@secrets/sdc-submission-signing-sr-private-key.pem" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_SUBMISSION_SR_PRIVATE_SIGNING_KEY_PASSWORD" "@secrets/sdc-submission-signing-sr-private-key-password.txt" -a

credstash --table $table put --algorithm $algorithm -k $key "EQ_SERVER_SIDE_STORAGE_USER_ID_SALT" "@secrets/sdc-storage-user-id-salt.txt" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_SERVER_SIDE_STORAGE_USER_IK_SALT" "@secrets/sdc-storage-user-ik-salt.txt" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_SERVER_SIDE_STORAGE_ENCRYPTION_KEY_PEPPER" "@secrets/sdc-storage-encryption-user-pepper.txt" -a

#DEV MODE only
credstash --table $table put --algorithm $algorithm -k $key "EQ_USER_AUTHENTICATION_SR_PUBLIC_KEY" "@secrets/sdc-submission-signing-sr-public-key.pem" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_USER_AUTHENTICATION_RRM_PRIVATE_KEY" "@secrets/sdc-user-authentication-signing-rrm-private-key.pem" -a
credstash --table $table put --algorithm $algorithm -k $key "EQ_USER_AUTHENTICATION_RRM_PRIVATE_KEY_PASSWORD" "@secrets/sdc-user-authentication-signing-rrm-private-key-password.txt" -a

deactivate
rmvirtualenv credstash

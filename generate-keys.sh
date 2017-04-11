#!/usr/bin/env bash

echo $(openssl rand -base64 16) > ./test-keys/sdc-storage-encryption-user-pepper.txt
echo $(openssl rand -base64 16) > ./test-keys/sdc-storage-user-id-salt.txt
echo $(openssl rand -base64 16) > ./test-keys/sdc-storage-user-ik-salt.txt

echo $(openssl rand -base64 16) > ./test-keys/eq-rabbitmq-username.txt
echo $(openssl rand -base64 16) > ./test-keys/eq-rabbitmq-password.txt

echo $(openssl rand -base64 16) > ./test-keys/eq-database-username.txt
echo $(openssl rand -base64 16) > ./test-keys/eq-database-password.txt

echo $(openssl rand -base64 16) > ./test-keys/eq-secret-key.txt
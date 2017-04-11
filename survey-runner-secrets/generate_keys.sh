#!/usr/bin/env bash

echo $(openssl rand -base64 16) > secrets/sdc-storage-encryption-user-pepper.txt
echo $(openssl rand -base64 16) > secrets/sdc-storage-user-id-salt.txt
echo $(openssl rand -base64 16) > secrets/sdc-storage-user-ik-salt.txt

echo $(openssl rand -base64 16) > secrets/eq-rabbitmq-username.txt
echo $(openssl rand -base64 16) > secrets/eq-rabbitmq-password.txt

echo $(openssl rand -base64 16) > secrets/eq-database-username.txt
echo $(openssl rand -base64 16) > secrets/eq-database-password.txt

echo $(openssl rand -base64 16) > secrets/eq-secret-key.txt
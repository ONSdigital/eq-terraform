#!/usr/bin/env bash

LC_CTYPE=C 

echo -n $(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16) > ./test-keys/sdc-storage-encryption-user-pepper.txt
echo -n $(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16) > ./test-keys/sdc-storage-user-id-salt.txt
echo -n  $(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16) > ./test-keys/sdc-storage-user-ik-salt.txt

echo -n  $(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16) > ./test-keys/eq-rabbitmq-username.txt
echo -n  $(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16) > ./test-keys/eq-rabbitmq-password.txt

echo -n  $(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16) > ./test-keys/eq-database-username.txt
echo -n  $(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16) > ./test-keys/eq-database-password.txt

echo -n  $(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16) > ./test-keys/eq-secret-key.txt
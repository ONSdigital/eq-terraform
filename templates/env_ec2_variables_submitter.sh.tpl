#! /bin/bash
set -x
ENV_FILE=/root/env.sh
echo "In the userdata script"
mkdir -p `dirname $ENV_FILE`
cat << EOF > $ENV_FILE
#! /bin/bash
export EQ_RABBITMQ_URL=amqp://${rabbitmq_admin_user}:${rabbitmq_admin_password}@${rabbitmq_url}:5672/%2F                          # The URL to the RabbitMQ Load Balancer
export EQ_RABBITMQ_QUEUE_NAME=${rabbitmq_queue}                 # The name of the queue
export EQ_SUBMISSIONS_BUCKET_NAME=${submissions_bucket_name}    # The name of the S3 Bucket
export AWS_ACCESS_KEY=${aws_access_key}
export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
EOF
chmod +x $ENV_FILE
. $ENV_FILE

cat $ENV_FILE >> /etc/environment
./$ENV_FILE

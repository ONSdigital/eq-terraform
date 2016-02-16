#! /bin/bash
set -x -e

# create a launcher script for the submitter
cat << EOF >> /usr/local/bin/run_submitter.sh
#!/bin/bash
export EQ_RABBITMQ_URL=amqp://${rabbitmq_user}:${rabbitmq_pass}@${rabbitmq_host}                   # The URL to the RabbitMQ Load Balancer
export EQ_RABBITMQ_QUEUE_NAME=${rabbitmq_queue}                 # The name of the queue
export EQ_SUBMISSIONS_BUCKET_NAME=${submissions_bucket_name}    # The name of the S3 Bucket
export AWS_ACCESS_KEY=${aws_access_key}
export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}

/usr/bin/python /home/ubuntu/eq-submitter/application.py
EOF

# make our launcher executable
chmod +x /usr/local/bin/run_submitter.sh

# create a file to let observers know this script has run
touch /tmp/user-data-ran

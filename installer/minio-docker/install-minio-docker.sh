#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo "Installing minio docker container on $HOST_PRIVATE_IP..."

cp $ENV_FILE ./.env
docker-compose -f "./wecube-s3.yml" up -d
../wait-for-it.sh -t 60 "$HOST_PRIVATE_IP:$S3_PORT" -- echo "Minio docker container is ready."

echo "Installation of minio docker container completed."

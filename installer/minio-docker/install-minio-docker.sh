#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

DOCKER_COMPOSE_ENV_TEMPLATE_FILE="./wecube-s3.env.template"
DOCKER_COMPOSE_ENV_FILE="./wecube-s3.env"
../substitute-in-file.sh $ENV_FILE $DOCKER_COMPOSE_ENV_TEMPLATE_FILE $DOCKER_COMPOSE_ENV_FILE

sudo -su $WECUBE_USER docker-compose -f "./wecube-s3.yml" --env-file="$DOCKER_COMPOSE_ENV_FILE" up -d

../wait-for-it.sh -t 60 "$HOST_PRIVATE_IP:$S3_PORT" -- echo "Minio docker container is ready."

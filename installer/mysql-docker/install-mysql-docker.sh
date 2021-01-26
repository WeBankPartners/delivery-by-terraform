#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo "Installing mysql docker container on $HOST_PRIVATE_IP"

DOCKER_COMPOSE_ENV_TEMPLATE_FILE="./wecube-db.env.template"
DOCKER_COMPOSE_ENV_FILE="./wecube-db.env"
../substitute-in-file.sh $ENV_FILE $DOCKER_COMPOSE_ENV_TEMPLATE_FILE $DOCKER_COMPOSE_ENV_FILE

sudo -su $WECUBE_USER docker-compose -f "./wecube-db.yml" --env-file="$DOCKER_COMPOSE_ENV_FILE" up -d

../wait-for-it.sh -t 120 "$HOST_PRIVATE_IP:$MYSQL_PORT" -- echo "Mysql docker container is ready."

echo "Installation of mysql docker container completed."

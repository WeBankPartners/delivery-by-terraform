#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo "Installing mysql docker container on $HOST_PRIVATE_IP..."

cp $ENV_FILE ./.env
docker-compose -f "./wecube-db.yml" up -d
../wait-for-it.sh -t 120 "$HOST_PRIVATE_IP:$MYSQL_PORT" -- echo "Mysql docker container is ready."

echo "Installation of mysql docker container completed."

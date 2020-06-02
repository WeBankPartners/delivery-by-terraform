#!/bin/bash

set -e

CONFIG_FILE=$1
WECUBE_IMAGE_VERSION=$2

[ ! -f $CONFIG_FILE ] && echo "Invalid configuration file: $CONFIG_FILE" && exit 1
source $CONFIG_FILE

mkdir -p $wecube_home/plugin

echo "Starting WeCube database..."
./generate_db_compose_file.sh $CONFIG_FILE
docker-compose -f wecube-db.yml up -d
sleep 120

echo "Starting WeCube platform..."
./deploy_generate_compose.sh $CONFIG_FILE $WECUBE_IMAGE_VERSION
docker-compose -f docker-compose.yml up -d

echo -e "\nUpdate WeCube system configurations..."
./update-wecube-sys-config.sh $CONFIG_FILE

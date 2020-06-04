#!/bin/bash

set -e

CONFIG_FILE=$1
WECUBE_IMAGE_VERSION=$2

[ ! -f $CONFIG_FILE ] && echo "Invalid configuration file: $CONFIG_FILE" && exit 1
source $CONFIG_FILE

mkdir -p $wecube_home/plugin

curl -#L https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com/wecube-sql/01.wecube.schema.sql -o database/platform-core/01.wecube.schema.sql
curl -#L https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com/wecube-sql/03.wecube.flow_engine.schema.sql -o database/platform-core/03.wecube.flow_engine.schema.sql
curl -#L https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com/wecube-sql/01.auth.schema.sql -o database/auth-server/01.auth_init.sql

echo "Starting WeCube database..."
./generate_db_compose_file.sh $CONFIG_FILE
docker-compose -f wecube-db.yml up -d
sleep 120

echo "Starting WeCube platform..."
./deploy_generate_compose.sh $CONFIG_FILE $WECUBE_IMAGE_VERSION
docker-compose -f docker-compose.yml up -d

echo -e "\nUpdate WeCube system configurations..."
./update-wecube-sys-config.sh $CONFIG_FILE

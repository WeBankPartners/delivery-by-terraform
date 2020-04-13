#!/bin/sh

set -e

WECUBE_HOST=$1
COLLECTION_DIR=$2
PLUGIN_PKG_DIR=$3

echo -e "\nNow configuring plugins, this may take a few minutes...\n"

docker run --rm -t \
    -v "$COLLECTION_DIR:$COLLECTION_DIR" \
    -v "$PLUGIN_PKG_DIR:$PLUGIN_PKG_DIR" \
    postman/newman \
    run "$COLLECTION_DIR/020_wecube_plugin_register.postman_collection.json" \
    --env-var "domain=$WECUBE_HOST:19090" \
    --env-var "username=umadmin" \
    --env-var "password=umadmin" \
    --env-var "wecube_host=$WECUBE_HOST" \
    --env-var "plugin_host=$WECUBE_HOST" \
    --env-var "next_val_port=20000" \
    -d "$PLUGIN_PKG_DIR/plugin-list.csv" \
    --delay-request 2000 --disable-unicode \
    --reporters cli,json --reporter-json-export "$COLLECTION_DIR/plugin-installer-report.json" \
    --verbose

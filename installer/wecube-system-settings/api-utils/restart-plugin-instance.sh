#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
PLUGIN_PKG_COORDS=$2
source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

ACCESS_TOKEN=$($SCRIPT_DIR/login.sh $SYS_SETTINGS_ENV_FILE)
INSANCE_JSON=$(http --ignore-stdin --check-status --follow \
	--body GET "http://${CORE_HOST}:19090/platform/v1/packages/${PLUGIN_PKG_COORDS}/instances" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	| jq --exit-status '.data[0]'
)
INSTANCE_ID=$(jq --exit-status '.id' <<<"$INSANCE_JSON" | cut -f 2 -d \")
INSTANCE_HOST=$(jq --exit-status '.host' <<<"$INSANCE_JSON" | cut -f 2 -d \")
INSTANCE_PORT=$(jq --exit-status '.port' <<<"$INSANCE_JSON")

echo -e "\nRemoving instance $INSTANCE_ID"
http --ignore-stdin --check-status --follow \
	DELETE "http://${CORE_HOST}:19090/platform/v1/packages/instances/${INSTANCE_ID}/remove" \
	"Authorization:Bearer $ACCESS_TOKEN"

echo -e "\nLaunching new instance for $PLUGIN_PKG_COORDS at $INSTANCE_HOST:$INSTANCE_PORT"
http --ignore-stdin --check-status --follow \
	POST "http://${CORE_HOST}:19090/platform/v1/packages/${PLUGIN_PKG_COORDS}/hosts/${INSTANCE_HOST}/ports/${INSTANCE_PORT}/instance/launch" \
	"Authorization:Bearer $ACCESS_TOKEN"
$SCRIPT_DIR/../../wait-for-it.sh -t 120 $INSTANCE_HOST:$INSTANCE_PORT

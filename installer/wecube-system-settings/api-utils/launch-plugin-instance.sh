#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
PLUGIN_PKG_COORDS=$2
source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "$ACCESS_TOKEN" ] && ACCESS_TOKEN=$($SCRIPT_DIR/login.sh $SYS_SETTINGS_ENV_FILE)

INSTANCE_HOST=$(http --ignore-stdin --check-status --follow \
	--body GET "http://${CORE_HOST}:19090/platform/v1/available-container-hosts" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	| $SCRIPT_DIR/check-status-in-json.sh \
	| jq --exit-status -r '.data[0]'
)

INSTANCE_PORT=$(http --ignore-stdin --check-status --follow \
	--body GET "http://${CORE_HOST}:19090/platform/v1/hosts/${INSTANCE_HOST}/next-available-port" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	| $SCRIPT_DIR/check-status-in-json.sh \
	| jq --exit-status -r '.data'
)

echo -e "\nLaunching new instance for $PLUGIN_PKG_COORDS at $INSTANCE_HOST:$INSTANCE_PORT"
http --ignore-stdin --check-status --follow  --timeout=300 \
	--body POST "http://${CORE_HOST}:19090/platform/v1/packages/${PLUGIN_PKG_COORDS}/hosts/${INSTANCE_HOST}/ports/${INSTANCE_PORT}/instance/launch" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	| $SCRIPT_DIR/check-status-in-json.sh

$SCRIPT_DIR/../../wait-for-it.sh -t 120 $INSTANCE_HOST:$INSTANCE_PORT

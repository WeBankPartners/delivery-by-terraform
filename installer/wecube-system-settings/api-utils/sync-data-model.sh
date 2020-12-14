#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
PLUGIN_PACKAGE_NAME=$2

source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "$ACCESS_TOKEN" ] && ACCESS_TOKEN=$($SCRIPT_DIR/login.sh $SYS_SETTINGS_ENV_FILE)

DATA_MODEL=$(http --ignore-stdin --check-status --follow \
	--body GET "http://${CORE_HOST}:19090/platform/v1/models/package/${PLUGIN_PACKAGE_NAME}" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	| $SCRIPT_DIR/check-status-in-json.sh \
	| jq --exit-status '.data'
)

http --check-status --follow --timeout=120 \
	--body POST "http://${CORE_HOST}:19090/platform/v1/models" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	<<<"$DATA_MODEL" \
	| $SCRIPT_DIR/check-status-in-json.sh

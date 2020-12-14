#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
PLUGIN_PKG_FILE=$2
source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "$ACCESS_TOKEN" ] && ACCESS_TOKEN=$($SCRIPT_DIR/login.sh $SYS_SETTINGS_ENV_FILE)

PACKAGE_ID=$(http --ignore-stdin --check-status --follow \
	--form --body POST "http://${CORE_HOST}:19090/platform/v1/packages" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	zip-file@"$PLUGIN_PKG_FILE" \
	| $SCRIPT_DIR/check-status-in-json.sh \
	| jq --exit-status -r '.data.id'
)

http --ignore-stdin --check-status --follow \
	--form --body POST "http://${CORE_HOST}:19090/platform/v1/packages/register/${PACKAGE_ID}" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	| $SCRIPT_DIR/check-status-in-json.sh \
	| jq --exit-status -r '.data.id'

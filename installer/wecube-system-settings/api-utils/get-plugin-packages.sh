#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

ACCESS_TOKEN=$($SCRIPT_DIR/login.sh $SYS_SETTINGS_ENV_FILE)
http --ignore-stdin --check-status --follow \
	--body GET "http://${CORE_HOST}:19090/platform/v1/packages" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	| $SCRIPT_DIR/check-status-in-json.sh  \
	| jq --exit-status -r '[.data[] | .id] | join(" ")'

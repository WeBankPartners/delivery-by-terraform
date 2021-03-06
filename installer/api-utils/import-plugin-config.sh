#!/bin/bash

set -e
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
PLUGIN_PKG_ID=$2
PLUGIN_CONFIG_FILE=$3

source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "${ACCESS_TOKEN}" ] && ACCESS_TOKEN=$(${SCRIPT_DIR}/login.sh ${SYS_SETTINGS_ENV_FILE})

curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/platform/v1/plugins/packages/import/$PLUGIN_PKG_ID" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	--form xml-file=@"${PLUGIN_CONFIG_FILE}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh

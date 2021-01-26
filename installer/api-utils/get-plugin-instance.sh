#!/bin/bash

set -e
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
PLUGIN_PKG_ID=$2
source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "${ACCESS_TOKEN}" ] && ACCESS_TOKEN=$(${SCRIPT_DIR}/login.sh ${SYS_SETTINGS_ENV_FILE})

curl -sSfL \
	--request GET "http://${CORE_HOST}:19090/platform/v1/packages/${PLUGIN_PKG_ID}/instances" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh \
	| jq --exit-status '.data[0]'

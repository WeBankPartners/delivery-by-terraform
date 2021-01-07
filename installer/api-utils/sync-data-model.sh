#!/bin/bash

set -e
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
PLUGIN_PACKAGE_NAME=$2

source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "${ACCESS_TOKEN}" ] && ACCESS_TOKEN=$(${SCRIPT_DIR}/login.sh ${SYS_SETTINGS_ENV_FILE})

DATA_MODEL=$(curl -sSfL \
	--request GET "http://${CORE_HOST}:19090/platform/v1/models/package/${PLUGIN_PACKAGE_NAME}" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh \
	| jq --exit-status '.data'
)

curl -sSfL --request POST "http://${CORE_HOST}:19090/platform/v1/models" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	--header 'Content-Type: application/json' \
	--data @- <<<"${DATA_MODEL}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh \
	| jq --exit-status '{status: .status, message: .message, data: {id: .data.id, version: .data.version, packageName: .data.packageName}}'

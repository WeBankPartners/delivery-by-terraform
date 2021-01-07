#!/bin/bash

set -e
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
PLUGIN_PKG_FILE=$2
source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "${ACCESS_TOKEN}" ] && ACCESS_TOKEN=$(${SCRIPT_DIR}/login.sh ${SYS_SETTINGS_ENV_FILE})

PACKAGE_ID=$(curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/platform/v1/packages" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	--form zip-file=@"${PLUGIN_PKG_FILE}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh \
	| jq --exit-status -r '.data.id'
)

curl -sSfL --request POST \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	"http://${CORE_HOST}:19090/platform/v1/packages/register/${PACKAGE_ID}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh \
	| jq --exit-status -r '.data.id'

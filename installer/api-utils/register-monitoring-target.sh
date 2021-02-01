#!/bin/bash

set -e
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
REQUEST_BODY_JSON=$2

source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "${ACCESS_TOKEN}" ] && ACCESS_TOKEN=$(${SCRIPT_DIR}/login.sh ${SYS_SETTINGS_ENV_FILE})

if [ -z "${REQUEST_BODY_JSON}" ]; then
	curl -sSfL \
		--request POST "http://${CORE_HOST}:19090/monitor/api/v1/agent/register" \
		--header "Authorization: Bearer ${ACCESS_TOKEN}" \
		--header 'Content-Type: application/json' \
		--data @- \
		| ${SCRIPT_DIR}/check-status-in-json.sh '.code == 200 and .status == "OK"'
else
	curl -sSfL \
		--request POST "http://${CORE_HOST}:19090/monitor/api/v1/agent/register" \
		--header "Authorization: Bearer ${ACCESS_TOKEN}" \
		--header 'Content-Type: application/json' \
		--data "${REQUEST_BODY_JSON}" \
		| ${SCRIPT_DIR}/check-status-in-json.sh '.code == 200 and .status == "OK"'
fi

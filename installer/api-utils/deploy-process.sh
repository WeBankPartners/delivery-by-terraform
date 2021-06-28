#!/bin/bash

set -e
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
PROCESS_DEFINITION_FILE=$2

source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "${ACCESS_TOKEN}" ] && ACCESS_TOKEN=$(${SCRIPT_DIR}/login.sh ${SYS_SETTINGS_ENV_FILE})

SUPER_ADMIN_ROLE_ID=$(curl -sSfL \
	--request GET "http://${CORE_HOST}:19090/platform/v1/users/roles" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh \
	| jq --exit-status -r '.data[] | select(.name == "SUPER_ADMIN") | .name' \
)

PROCESS_DATA=$(curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/platform/v1/process/definitions/import" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	--form uploadFile=@"${PROCESS_DEFINITION_FILE}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh \
	| jq --exit-status --arg super_admin_role_id $SUPER_ADMIN_ROLE_ID \
		'.data | setpath(["permissionToRole","MGMT"]; [$super_admin_role_id]) | setpath(["permissionToRole","USE"]; [$super_admin_role_id])' \
)

curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/platform/v1/process/definitions/deploy" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	--header 'Content-Type: application/json' \
	--data @- <<<"${PROCESS_DATA}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh

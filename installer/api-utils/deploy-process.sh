#!/bin/bash

set -ex
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
PROCESS_DEFINITION_FILE=$2

source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "${ACCESS_TOKEN}" ] && ACCESS_TOKEN=$(${SCRIPT_DIR}/login.sh ${SYS_SETTINGS_ENV_FILE})

#SUPER_ADMIN_ROLE_ID=$(curl -sSfL \
#	--request GET "http://${CORE_HOST}:19090/platform/v1/users/roles" \
#	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
#	| ${SCRIPT_DIR}/check-status-in-json.sh \
#	| jq --exit-status -r '.data[] | select(.name == "SUPER_ADMIN") | .name' \
#)

PROCESS_DEF_ID=$(curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/platform/v1/process/definitions/import" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	--form file=@"${PROCESS_DEFINITION_FILE}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh \
	| jq --exit-status -r '.data.resultList[].procDefId'
)

curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/platform/v1/process/definitions/deploy/${PROCESS_DEF_ID}" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	--header 'Content-Type: application/json' \
	--data @- <<<"{}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh

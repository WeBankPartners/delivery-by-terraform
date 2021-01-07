#!/bin/bash

set -e
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
CMDB_INSTANCE_HOST=$2
CMDB_INSTANCE_PORT=$3
CMDB_INSTANCE_NAME=$4
CI_TYPE_ID=$5
CI_DATA_JSON=$6

source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "${ACCESS_TOKEN}" ] && ACCESS_TOKEN=$(${SCRIPT_DIR}/login.sh ${SYS_SETTINGS_ENV_FILE})

curl -sSfL \
	--request POST "http://${CMDB_INSTANCE_HOST}:${CMDB_INSTANCE_PORT}/${CMDB_INSTANCE_NAME}/ui/v2/ci-types/${CI_TYPE_ID}/ci-data/batch-create" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	--header 'Content-Type: application/json' \
	--data @- <<<"${CI_DATA_JSON}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh '.statusCode == "OK"' \
	| jq '{statusCode: .statusCode}'

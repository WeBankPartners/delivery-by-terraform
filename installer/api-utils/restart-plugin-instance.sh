#!/bin/bash

set -e
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
PLUGIN_PKG_COORDS=$2
source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "${ACCESS_TOKEN}" ] && ACCESS_TOKEN=$(${SCRIPT_DIR}/login.sh ${SYS_SETTINGS_ENV_FILE})

INSANCE_JSON=$(ACCESS_TOKEN="${ACCESS_TOKEN}" ${SCRIPT_DIR}/get-plugin-instance.sh ${SYS_SETTINGS_ENV_FILE} ${PLUGIN_PKG_COORDS})
INSTANCE_ID=$(jq --exit-status -r '.id' <<<"$INSANCE_JSON")
INSTANCE_HOST=$(jq --exit-status -r '.host' <<<"$INSANCE_JSON")
INSTANCE_PORT=$(jq --exit-status '.port' <<<"$INSANCE_JSON")

echo -e "\nRemoving instance $INSTANCE_ID"
curl -sSfL \
	--request DELETE "http://${CORE_HOST}:19090/platform/v1/packages/instances/${INSTANCE_ID}/remove" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh

echo -e "\nLaunching new instance for $PLUGIN_PKG_COORDS at $INSTANCE_HOST:$INSTANCE_PORT"
curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/platform/v1/packages/${PLUGIN_PKG_COORDS}/hosts/${INSTANCE_HOST}/ports/${INSTANCE_PORT}/instance/launch" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh

$SCRIPT_DIR/../wait-for-it.sh -t 120 $INSTANCE_HOST:$INSTANCE_PORT

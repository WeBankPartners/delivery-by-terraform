#!/bin/bash

set -e
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

REQUEST_BODY=$(jq -n \
	--arg username "${DEFAULT_ADMIN_USERNAME}" \
	--arg password "${DEFAULT_ADMIN_PASSWORD}" \
	'{username: $username, password: $password}'
)
curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/auth/v1/api/login" \
	--header 'Content-Type: application/json' \
	--data @- <<<"${REQUEST_BODY}" \
	| ${SCRIPT_DIR}/check-status-in-json.sh '.status == "OK"' \
	| jq -r '.data[] | select(.tokenType == "accessToken") | .token'

#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
PROCESS_DEFINITION_FILE=$2

source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "$ACCESS_TOKEN" ] && ACCESS_TOKEN=$($SCRIPT_DIR/login.sh $SYS_SETTINGS_ENV_FILE)

SUPER_ADMIN_ROLE_ID=$(http --ignore-stdin --check-status --follow \
	--body GET "http://${CORE_HOST}:19090/platform/v1/users/roles" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	| $SCRIPT_DIR/check-status-in-json.sh \
	| jq --exit-status -r '.data[] | select(.name == "SUPER_ADMIN") | .id' \
)

PROCESS_DATA=$(http --ignore-stdin --check-status --follow \
	--form --body POST "http://${CORE_HOST}:19090/platform/v1/process/definitions/import" \
	"Authorization:Bearer $ACCESS_TOKEN" \
	uploadFile@"$PROCESS_DEFINITION_FILE" \
	| $SCRIPT_DIR/check-status-in-json.sh \
	| jq --exit-status --arg super_admin_role_id $SUPER_ADMIN_ROLE_ID \
		'.data | setpath(["permissionToRole","MGMT"]; [$super_admin_role_id]) | setpath(["permissionToRole","USE"]; [])' \
)

http --check-status --follow \
	--body POST "http://${CORE_HOST}:19090/platform/v1/process/definitions/deploy" \
	"Authorization:Bearer $ACCESS_TOKEN" <<<"$PROCESS_DATA" \
	| $SCRIPT_DIR/check-status-in-json.sh

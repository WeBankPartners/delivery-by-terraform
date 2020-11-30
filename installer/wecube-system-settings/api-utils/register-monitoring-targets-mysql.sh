#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "$ACCESS_TOKEN" ] && ACCESS_TOKEN=$($SCRIPT_DIR/login.sh $SYS_SETTINGS_ENV_FILE)

http --check-status --follow --timeout=120 \
	--body POST "http://${CORE_HOST}:19090/monitor/api/v1/agent/export/register/mysql" \
	"Authorization:Bearer $ACCESS_TOKEN" <<-EOF \
	| $SCRIPT_DIR/check-status-in-json.sh '.resultCode == "0"'
		{
		  "requestId": "1",
		  "inputs": [
		    {
		      "callbackParameter": "1",
		      "instance": "plugin_mysql1",
		      "instance_ip": "${PLUGIN_DB_HOST}",
		      "port": "${PLUGIN_DB_PORT}",
		      "user": "${PLUGIN_DB_USERNAME}",
		      "password": "${PLUGIN_DB_PASSWORD}",
		      "group": "default_mysql_group"
		    }
		  ]
		}
	EOF

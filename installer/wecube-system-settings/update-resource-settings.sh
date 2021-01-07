#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
source $SYS_SETTINGS_ENV_FILE

echo "Creating resource server records..."

ACCESS_TOKEN=$(../api-utils/login.sh "$SYS_SETTINGS_ENV_FILE")
[ -z "$ACCESS_TOKEN" ] && echo -e "\n\e[0;31mFailed to get access token from WeCube platform! Installation aborted.\e[0m\n" && exit 1

curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/platform/resource/servers/create" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	--header 'Content-Type: application/json' \
	--data @- <<-EOF \
	| ../api-utils/check-status-in-json.sh
		[
			{
				"name": "mysqlHost",
				"type": "mysql",
				"status": "active",
				"isAllocated": true,
				"host": "${PLUGIN_DB_HOST}",
				"port": "${PLUGIN_DB_PORT}",
				"loginUsername": "${PLUGIN_DB_USERNAME}",
				"loginPassword": "${PLUGIN_DB_PASSWORD}",
				"purpose": "Plugin db hosting"
			},
			{
				"name": "s3Host",
				"type": "s3",
				"status": "active",
				"isAllocated": true,
				"host": "${S3_HOST}",
				"port": "9000",
				"loginUsername": "${S3_ACCESS_KEY}",
				"loginPassword": "${S3_SECRET_KEY}",
				"purpose": "Plugin object storage hosting"
			}
		]
	EOF

echo "Updating global system variables..."
SQL_FILE_TEMPLATE="./update-global-system-variables.sql.tpl"
SQL_FILE="./update-global-system-variables.sql"
../substitute-in-file.sh $SYS_SETTINGS_ENV_FILE $SQL_FILE_TEMPLATE $SQL_FILE
../execute-sql-script-file.sh $CORE_DB_HOST $CORE_DB_PORT \
	$CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
	$SQL_FILE

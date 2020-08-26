#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
PLUGLIN_CONFIG_PKG=$2

source $SYS_SETTINGS_ENV_FILE

echo -e "\nFetching plugin configurations from $PLUGLIN_CONFIG_PKG"
PLUGIN_CONFIG_PKG_FILE="$INSTALLER_DIR/plugin-configs.zip"
PLUGIN_CONFIG_DIR="$INSTALLER_DIR/plugin-configs"
../curl-with-retry.sh -fL $PLUGLIN_CONFIG_PKG -o $PLUGIN_CONFIG_PKG_FILE
unzip -o -q $PLUGIN_CONFIG_PKG_FILE -d $PLUGIN_CONFIG_DIR

find "$PLUGIN_CONFIG_DIR" -type f -name '*.xml' | while read PLUGIN_CONFIG_FILE; do
	echo -e "\nImporting plugin configurations from $PLUGIN_CONFIG_FILE"
	PLUGIN_PKG_COORDS=$(basename $PLUGIN_CONFIG_FILE .xml)
	ACCESS_TOKEN=$(./api-utils/login.sh "$SYS_SETTINGS_ENV_FILE")
	[ -z "$ACCESS_TOKEN" ] && echo -e "\n\e[0;31mFailed to get access token from WeCube platform! Installation aborted.\e[0m\n" && exit 1
	http --ignore-stdin --form POST "http://${CORE_HOST}:19090/platform/v1/plugins/packages/import/$PLUGIN_PKG_COORDS" \
		"Authorization:Bearer $ACCESS_TOKEN" \
		xml-file@"$PLUGIN_CONFIG_FILE"
done

echo -e "\nEnabling all plugin configurations..."
read -d '' SQL_STMT <<-EOF || true
	UPDATE ``plugin_configs``
	   SET ``status`` = 'ENABLED'
	 WHERE ``register_name`` != '';
EOF
../execute-sql-statements.sh $CORE_DB_HOST $CORE_DB_PORT \
  $CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
  "$SQL_STMT"

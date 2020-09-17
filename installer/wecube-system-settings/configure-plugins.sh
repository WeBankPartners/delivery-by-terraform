#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
source $SYS_SETTINGS_ENV_FILE

PLUGIN_INSTALLER_URL="https://github.com/WeBankPartners/wecube-auto/archive/master.zip"
PLUGIN_INSTALLER_PKG="$INSTALLER_DIR/wecube-plugin-installer.zip"
PLUGIN_INSTALLER_DIR="$INSTALLER_DIR/wecube-plugins"
COLLECTION_DIR="$PLUGIN_INSTALLER_DIR/wecube-auto-master"
mkdir -p "$PLUGIN_INSTALLER_DIR"
echo "Fetching wecube-plugin-installer from $PLUGIN_INSTALLER_URL"
../curl-with-retry.sh -fL $PLUGIN_INSTALLER_URL -o $PLUGIN_INSTALLER_PKG
unzip -o -q $PLUGIN_INSTALLER_PKG -d $PLUGIN_INSTALLER_DIR

echo -e "\nFetching plugin packages..."
PLUGIN_PKG_DIR="$PLUGIN_INSTALLER_DIR/plugin-packages"
mkdir -p "$PLUGIN_PKG_DIR"
PLUGIN_LIST_CSV="$PLUGIN_PKG_DIR/plugin-list.csv"
echo "plugin_package_path" > $PLUGIN_LIST_CSV
for PLUGIN_URL in "${PLUGIN_PKGS[@]}"; do
	PLUGIN_PKG_FILE="$PLUGIN_PKG_DIR/${PLUGIN_URL##*'/'}"
	echo -e "\nFetching from $PLUGIN_URL"
	../curl-with-retry.sh -fL $PLUGIN_URL -o $PLUGIN_PKG_FILE
	echo $PLUGIN_PKG_FILE >> $PLUGIN_LIST_CSV
done

echo -e "\nRegistering plugins, this may take a few minutes...\n"
docker run --rm -t \
	-v "$COLLECTION_DIR:$COLLECTION_DIR" \
	-v "$PLUGIN_PKG_DIR:$PLUGIN_PKG_DIR" \
	postman/newman \
	run "$COLLECTION_DIR/020_wecube_plugin_register.postman_collection.json" \
	-d "$PLUGIN_PKG_DIR/plugin-list.csv" \
	--env-var "domain=$PUBLIC_DOMAIN" \
	--env-var "username=$DEFAULT_ADMIN_USERNAME" \
	--env-var "password=$DEFAULT_ADMIN_PASSWORD" \
	--env-var "wecube_host=$CORE_HOST" \
	--env-var "plugin_host=$PLUGIN_HOST" \
	--delay-request 2000 --disable-unicode \
	--reporters cli \
	--reporter-cli-no-banner --reporter-cli-no-console

if [ -z "$PLUGLIN_CONFIG_PKG" ]; then
	echo -e "\nNo plugin configuration package is specified and skipped importing."
else
	echo -e "\nFetching plugin configurations from $PLUGLIN_CONFIG_PKG"
	PLUGIN_CONFIG_PKG_FILE="$INSTALLER_DIR/plugin-configs.zip"
	PLUGIN_CONFIG_DIR="$INSTALLER_DIR/plugin-configs"
	../curl-with-retry.sh -fL $PLUGLIN_CONFIG_PKG -o $PLUGIN_CONFIG_PKG_FILE
	unzip -o -q $PLUGIN_CONFIG_PKG_FILE -d $PLUGIN_CONFIG_DIR

	find "$PLUGIN_CONFIG_DIR" -type f -name '*.sql' | while read SQL_SCRIPT_FILE; do
		echo -e "\nImporting plugin SQL script file $SQL_SCRIPT_FILE"
		PLUGIN_DB_NAME=$(basename $SQL_SCRIPT_FILE .sql)
		../execute-sql-script-file.sh $PLUGIN_DB_HOST $PLUGIN_DB_PORT \
			$PLUGIN_DB_NAME $PLUGIN_DB_USERNAME $PLUGIN_DB_PASSWORD \
			$SQL_SCRIPT_FILE
	done

	find "$PLUGIN_CONFIG_DIR" -type f -name '*.xml' | while read PLUGIN_CONFIG_FILE; do
		PLUGIN_PKG_COORDS=$(basename $PLUGIN_CONFIG_FILE .xml)
		PLUGIN_PKG_NAME="${PLUGIN_PKG_COORDS%%__*}"
		[ "$PLUGINS" != "*" ] && [ "$PLUGINS" == "${PLUGINS/$PLUGIN_PKG_NAME/}" ] && continue

		echo -e "\nImporting plugin configurations for \"$PLUGIN_PKG_NAME\" from $PLUGIN_CONFIG_FILE"
		ACCESS_TOKEN=$(./api-utils/login.sh "$SYS_SETTINGS_ENV_FILE")
		[ -z "$ACCESS_TOKEN" ] && echo -e "\n\e[0;31mFailed to get access token from WeCube platform! Installation aborted.\e[0m\n" && exit 1
		http --ignore-stdin --check-status --follow \
			--form POST "http://${CORE_HOST}:19090/platform/v1/plugins/packages/import/$PLUGIN_PKG_COORDS" \
			"Authorization:Bearer $ACCESS_TOKEN" \
			xml-file@"$PLUGIN_CONFIG_FILE"

		if [ "$PLUGIN_PKG_NAME" == "wecmdb" ]; then
			echo "Restarting WeCMDB instance..."
			./api-utils/restart-plugin-instance.sh $SYS_SETTINGS_ENV_FILE $PLUGIN_PKG_COORDS
		fi
	done
fi

echo -e "\nEnabling all plugin configurations..."
read -d '' SQL_STMT <<-EOF || true
	UPDATE ``plugin_configs``
	   SET ``status`` = 'ENABLED'
	 WHERE ``register_name`` != '';
EOF
../execute-sql-statements.sh $CORE_DB_HOST $CORE_DB_PORT \
	$CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
	"$SQL_STMT"

echo -e "\nConfiguring plugin WeCMDB..."
./configure-wecmdb.sh $SYS_SETTINGS_ENV_FILE $COLLECTION_DIR

echo -e "\nConfigure plugin Open-Monitor..."
./configure-open-monitor.sh $SYS_SETTINGS_ENV_FILE $COLLECTION_DIR $PLUGIN_PKG_DIR

echo -e "\nConfigure plugin Artifacts..."
./configure-artifacts.sh $SYS_SETTINGS_ENV_FILE

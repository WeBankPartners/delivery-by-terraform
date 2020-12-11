#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
source $SYS_SETTINGS_ENV_FILE

[ ${#PLUGIN_PKGS[@]} -eq 0 ] && echo -e "\e[0;33mNo plugins need to be configured, skipped operation.\e[0m" && exit 0;


PLUGIN_INSTALLER_URL="https://github.com/WeBankPartners/wecube-auto/archive/master.zip"
PLUGIN_INSTALLER_PKG="$INSTALLER_DIR/wecube-plugin-installer.zip"
PLUGIN_INSTALLER_DIR="$INSTALLER_DIR/wecube-plugins"
COLLECTION_DIR="$PLUGIN_INSTALLER_DIR/wecube-auto-master"

mkdir -p "$PLUGIN_INSTALLER_DIR"

if [ "$USE_MIRROR_IN_MAINLAND_CHINA" == "true" ]; then
	echo 'Using Gitee as mirror for WeCube code repository in Mainland China.'
	PLUGIN_INSTALLER_URL="https://gitee.com/WeBankPartners/wecube-auto/repository/archive/master.zip"
	COLLECTION_DIR="$PLUGIN_INSTALLER_DIR/wecube-auto"
fi

echo "Fetching wecube-plugin-installer from $PLUGIN_INSTALLER_URL"
../curl-with-retry.sh -fL $PLUGIN_INSTALLER_URL -o $PLUGIN_INSTALLER_PKG
unzip -o -q $PLUGIN_INSTALLER_PKG -d $PLUGIN_INSTALLER_DIR

echo -e "\nInstalling the following WeCube plugin packages..."
printf '  %s\n' "${PLUGIN_PKGS[@]}"
PLUGIN_PKG_DIR="$PLUGIN_INSTALLER_DIR/plugin-packages"
mkdir -p "$PLUGIN_PKG_DIR"
PLUGIN_PKG_FILES=()
PLUGIN_LIST_CSV="$PLUGIN_PKG_DIR/plugin-list.csv"
echo "plugin_package_path" > $PLUGIN_LIST_CSV
for PLUGIN_URL in "${PLUGIN_PKGS[@]}"; do
	PLUGIN_PKG_FILE="$PLUGIN_PKG_DIR/${PLUGIN_URL##*'/'}"
	echo -e "\nFetching from $PLUGIN_URL"
	../curl-with-retry.sh -fL $PLUGIN_URL -o $PLUGIN_PKG_FILE
	PLUGIN_PKG_FILES+=("$PLUGIN_PKG_FILE")
	echo $PLUGIN_PKG_FILE >> $PLUGIN_LIST_CSV
done

echo -e "\nRegistering plugins, this may take a few minutes...\n"
docker run --rm -t \
	-v "$COLLECTION_DIR:$COLLECTION_DIR" \
	-v "$PLUGIN_PKG_DIR:$PLUGIN_PKG_DIR" \
	postman/newman \
	run "$COLLECTION_DIR/020_wecube_plugin_register.postman_collection.json" \
	-d "$PLUGIN_LIST_CSV" \
	--env-var "domain=$PUBLIC_DOMAIN" \
	--env-var "username=$DEFAULT_ADMIN_USERNAME" \
	--env-var "password=$DEFAULT_ADMIN_PASSWORD" \
	--env-var "wecube_host=$CORE_HOST" \
	--env-var "plugin_host=$PLUGIN_HOST" \
	--delay-request 2000 --disable-unicode \
	--reporters cli \
	--reporter-cli-no-banner --reporter-cli-no-console

INSTALLED_PLUGIN_PKGS=$(./api-utils/get-plugin-packages.sh $SYS_SETTINGS_ENV_FILE)
echo -e "\nInstalled plugin packages: $INSTALLED_PLUGIN_PKGS"

if [ -z "$PLUGIN_CONFIG_PKG" ]; then
	echo -e "\n\e[0;33mNo plugin configuration package is specified and skipped importing.\e[0m"
else
	echo -e "\nFetching plugin configurations from $PLUGIN_CONFIG_PKG"
	PLUGIN_CONFIG_PKG_FILE="$INSTALLER_DIR/plugin-configs.zip"
	PLUGIN_CONFIG_DIR="$INSTALLER_DIR/plugin-configs"
	../curl-with-retry.sh -fL $PLUGIN_CONFIG_PKG -o $PLUGIN_CONFIG_PKG_FILE
	unzip -o -q $PLUGIN_CONFIG_PKG_FILE -d $PLUGIN_CONFIG_DIR

	EXTRA_CONFIG_STEP_DEF_FILE="$PLUGIN_CONFIG_DIR/extra-config-steps.sh"
	if [ -f "$EXTRA_CONFIG_STEP_DEF_FILE" ]; then
		echo "Found config steps script file at $EXTRA_CONFIG_STEP_DEF_FILE"
		source "$EXTRA_CONFIG_STEP_DEF_FILE"
	fi

	find "$PLUGIN_CONFIG_DIR" -type f -name '*.sql' | while read SQL_SCRIPT_FILE; do
		echo -e "\nImporting SQL script file $SQL_SCRIPT_FILE"
		PLUGIN_DB_NAME=$(basename $SQL_SCRIPT_FILE .sql)
		../execute-sql-script-file.sh $PLUGIN_DB_HOST $PLUGIN_DB_PORT \
			$PLUGIN_DB_NAME $PLUGIN_DB_USERNAME $PLUGIN_DB_PASSWORD \
			$SQL_SCRIPT_FILE
	done

	find "$PLUGIN_CONFIG_DIR" -type f -name '*.xml' | while read PLUGIN_CONFIG_FILE; do
		PLUGIN_PKG_COORDS=$(basename $PLUGIN_CONFIG_FILE .xml)
		PLUGIN_PKG_NAME="${PLUGIN_PKG_COORDS%__*}"

		if [ "${INSTALLED_PLUGIN_PKGS/$PLUGIN_PKG_COORDS/}" == "$INSTALLED_PLUGIN_PKGS" ]; then
			echo -e "\n\e[0;33mPlugin package \"$PLUGIN_PKG_COORDS\" is not installed, skipped importing plugin configuration from $PLUGIN_CONFIG_FILE\e[0m"
			continue
		fi

		echo -e "\nImporting plugin service config for \"$PLUGIN_PKG_COORDS\" from $PLUGIN_CONFIG_FILE"
		./api-utils/import-plugin-config.sh $SYS_SETTINGS_ENV_FILE $PLUGIN_CONFIG_FILE

		if [ "$PLUGIN_PKG_NAME" == "wecmdb" ]; then
			echo "Restarting WeCMDB instance..."
			./api-utils/restart-plugin-instance.sh $SYS_SETTINGS_ENV_FILE $PLUGIN_PKG_COORDS
		fi
	done

	find "$PLUGIN_CONFIG_DIR" -type f -name '*.pds' | while read PROCESS_DEFINITION_FILE; do
		echo -e "\nImporting and deploying process from file $PROCESS_DEFINITION_FILE"
		./api-utils/deploy-process.sh $SYS_SETTINGS_ENV_FILE $PROCESS_DEFINITION_FILE
	done
fi

echo -e "\nEnabling all plugin service config..."
read -d '' SQL_STMT <<-EOF || true
	UPDATE ``plugin_configs``
	   SET ``status`` = 'ENABLED'
	 WHERE ``register_name`` != '';
EOF
../execute-sql-statements.sh $CORE_DB_HOST $CORE_DB_PORT \
	$CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
	"$SQL_STMT"

echo -e "\nInvoking extra config steps: ${EXTRA_CONFIG_STEPS[*]}"
for CONFIG_STEP in "${EXTRA_CONFIG_STEPS[@]}"; do
	echo -e "\nInvoking config step \"$CONFIG_STEP\""
	source "./config-steps/${CONFIG_STEP}.sh"
done

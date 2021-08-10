#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
source $SYS_SETTINGS_ENV_FILE

[ ${#PLUGIN_PKGS[@]} -eq 0 ] && echo -e "\e[0;33mNo plugins need to be configured, skipped operation.\e[0m" && exit 0;


echo -e "\nInstalling the following WeCube plugin packages..."
printf '  %s\n' "${PLUGIN_PKGS[@]}"
PLUGIN_PKG_DIR="$INSTALLER_DIR/plugin-packages"
mkdir -p "$PLUGIN_PKG_DIR"
for PLUGIN_URL in "${PLUGIN_PKGS[@]}"; do
	PLUGIN_PKG_FILE="$PLUGIN_PKG_DIR/${PLUGIN_URL##*'/'}"
	echo -e "\nFetching plugin package from $PLUGIN_URL"
	../curl-with-retry.sh -fL $PLUGIN_URL -o $PLUGIN_PKG_FILE
	echo -e "\nInstalling plugin package $PLUGIN_PKG_FILE"
	PLUGIN_PKG_ID=$(../api-utils/install-plugin-package.sh $SYS_SETTINGS_ENV_FILE $PLUGIN_PKG_FILE)
	../api-utils/launch-plugin-instance.sh $SYS_SETTINGS_ENV_FILE $PLUGIN_PKG_ID
done

INSTALLED_PLUGIN_PKGS=$(../api-utils/get-plugin-packages.sh $SYS_SETTINGS_ENV_FILE)
echo -e "\nInstalled plugin packages:"
jq <<<"$INSTALLED_PLUGIN_PKGS"

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
		PLUGIN_PKG_ID=$(jq -r --arg name $PLUGIN_PKG_NAME '.[] | select(.name == $name) | .id' <<<"$INSTALLED_PLUGIN_PKGS")

		if [ -z "${PLUGIN_PKG_ID}" ]; then
			echo -e "\n\e[0;33mPlugin package \"$PLUGIN_PKG_NAME\" is not installed, skipped importing plugin configuration from $PLUGIN_CONFIG_FILE\e[0m"
			continue
		fi

		echo -e "\nImporting plugin service config for \"$PLUGIN_PKG_NAME\" from $PLUGIN_CONFIG_FILE"
		../api-utils/import-plugin-config.sh $SYS_SETTINGS_ENV_FILE $PLUGIN_PKG_ID $PLUGIN_CONFIG_FILE

		if [ "$PLUGIN_PKG_NAME" == "wecmdb" ]; then
			echo "Restarting WeCMDB instance..."
			../api-utils/restart-plugin-instance.sh $SYS_SETTINGS_ENV_FILE $PLUGIN_PKG_ID
		fi
		
		if [ "$PLUGIN_PKG_NAME" == "terminal" ]; then
			echo "Restarting terminal instance..."
			../api-utils/restart-plugin-instance.sh $SYS_SETTINGS_ENV_FILE $PLUGIN_PKG_ID
		fi
	done
	echo -e "\nEnabling all plugin service config..."
	read -d '' SQL_STMT <<-EOF || true
		UPDATE ``plugin_configs``
	   	SET ``status`` = 'ENABLED'
	 	WHERE ``register_name`` != '';
	EOF
	../execute-sql-statements.sh $CORE_DB_HOST $CORE_DB_PORT \
		$CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
		"$SQL_STMT"

	find "$PLUGIN_CONFIG_DIR" -type f -name '*.pds' | while read PROCESS_DEFINITION_FILE; do
		echo -e "\nImporting and deploying process from file $PROCESS_DEFINITION_FILE"
		../api-utils/deploy-process.sh $SYS_SETTINGS_ENV_FILE $PROCESS_DEFINITION_FILE
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

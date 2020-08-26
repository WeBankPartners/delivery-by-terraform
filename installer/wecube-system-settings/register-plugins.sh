#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1; shift
PLUGIN_PKGS=( "$@" )

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

echo -e "\nConfiguring plugin WeCMDB..."
./configure-wecmdb.sh $SYS_SETTINGS_ENV_FILE $COLLECTION_DIR

echo -e "\nConfigure plugin Open-Monitor..."
./configure-open-monitor.sh $SYS_SETTINGS_ENV_FILE $COLLECTION_DIR $PLUGIN_PKG_DIR

echo -e "\nConfigure plugin Artifacts..."
./configure-artifacts.sh $SYS_SETTINGS_ENV_FILE


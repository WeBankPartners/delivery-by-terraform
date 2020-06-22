#!/bin/bash

set -e

ENV_FILE=$1; shift
PLUGIN_PKGS=( "$@" )

source $ENV_FILE

SYS_SETTINGS_ENV_TEMPLATE_FILE="./wecube-system-settings.env.tpl"
SYS_SETTINGS_ENV_FILE="./wecube-system-settings.env"
../substitute-in-file.sh $ENV_FILE $SYS_SETTINGS_ENV_TEMPLATE_FILE $SYS_SETTINGS_ENV_FILE
cat $ENV_FILE >>$SYS_SETTINGS_ENV_FILE
source $SYS_SETTINGS_ENV_FILE

echo -e "\nNow starting to configure plugins..."

PLUGIN_INSTALLER_URL="https://github.com/WeBankPartners/wecube-auto/archive/master.zip"
PLUGINS_BUCKET_URL="https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com"
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

echo -e "\nEnabling service configurations for all registered plugins..."
../execute-sql-script-file.sh $CORE_DB_HOST $CORE_DB_PORT \
  $CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
  "./register-all-plugin-services.sql"


echo -e "\nConfiguring plugin WeCMDB...\n"
./configure-wecmdb.sh $SYS_SETTINGS_ENV_FILE $COLLECTION_DIR

echo -e "\nConfigure plugin Open-Monitor...\n"
./configure-open-monitor.sh $SYS_SETTINGS_ENV_FILE $COLLECTION_DIR $PLUGIN_PKG_DIR

echo -e "\nConfigure plugin Artifacts...\n"
./configure-artifacts.sh $SYS_SETTINGS_ENV_FILE

#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

PLUGIN_DEPLOY_DIR="${WECUBE_HOME}/plugin"
echo "Creating plugin deployment directory $PLUGIN_DEPLOY_DIR ..."
mkdir -p "$PLUGIN_DEPLOY_DIR"

echo "Waiting for WeCube platform initialization..."
../wait-for-it.sh -t 300 "$CORE_HOST:19100" -- echo "WeCube platform core is ready."

echo "Creating resource server record..."
SQL_FILE_TEMPLATE="./register-wecube-plugin-container-host.sql.tpl"
SQL_FILE="./register-wecube-plugin-container-host.sql"
../substitute-in-file.sh $ENV_FILE $SQL_FILE_TEMPLATE $SQL_FILE
../execute-sql-script-file.sh $CORE_DB_HOST $CORE_DB_PORT \
  $CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
  $SQL_FILE

echo "Resource server record created."

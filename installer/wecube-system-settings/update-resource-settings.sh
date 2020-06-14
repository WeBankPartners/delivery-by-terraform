#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

SQL_FILE_TEMPLATE="./update-resource-settings.sql.tpl"
SQL_FILE="./update-resource-settings.sql"
../substitute-in-file.sh $ENV_FILE $SQL_FILE_TEMPLATE $SQL_FILE
../execute-sql-script-file.sh $CORE_DB_HOST $CORE_DB_PORT \
  $CORE_DB_NAME $CORE_DB_USERNAME $CORE_DB_PASSWORD \
  $SQL_FILE

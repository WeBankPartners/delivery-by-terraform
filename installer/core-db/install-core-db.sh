#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo "Deploying core-db to $DB_HOST:$DB_PORT..."

echo "Creating database $DB_NAME..."
../execute-sql-expression.sh $DB_HOST $DB_PORT \
  mysql $DB_USERNAME $DB_PASSWORD \
  "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"

echo "Initializing database $DB_NAME..."

SQL_SCRIPT_FILES=(
  "01.wecube.schema.sql"
  "02.wecube.system.data.sql"
  "03.wecube.flow_engine.schema.sql"
)
for SQL_SCRIPT_FILE in "${SQL_SCRIPT_FILES[@]}"; do
  ../execute-sql-script-file.sh $DB_HOST $DB_PORT \
    $DB_NAME $DB_USERNAME $DB_PASSWORD $SQL_SCRIPT_FILE
done

echo "Deployment of core-db completed."

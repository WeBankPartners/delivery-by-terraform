#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo "Creating database $DB_NAME at $DB_HOST:$DB_PORT ..."
../execute-sql-expression.sh $DB_HOST $DB_PORT \
  mysql $DB_USERNAME $DB_PASSWORD \
  "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"

echo "Verifying connectivity to database $DB_NAME ..."
../wait-for-it.sh -t 60 "$DB_HOST:$DB_PORT"
../execute-sql-expression.sh $DB_HOST $DB_PORT \
  $DB_NAME $DB_USERNAME $DB_PASSWORD \
  "SELECT version();"

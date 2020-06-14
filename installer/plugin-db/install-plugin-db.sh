#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo "Deploying plugin-db to $DB_HOST:$DB_PORT..."

echo "Verifying connectivity..."
../execute-sql-expression.sh $DB_HOST $DB_PORT \
  $DB_NAME $DB_USERNAME $DB_PASSWORD \
  "SELECT version();"

echo "Deployment of plugin-db completed."

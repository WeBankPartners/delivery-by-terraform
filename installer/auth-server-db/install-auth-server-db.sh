#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo "Deploying auth-server-db to $DB_HOST:$DB_PORT..."

echo "Creating database $DB_NAME..."
../execute-sql-expression.sh $DB_HOST $DB_PORT \
	mysql $DB_USERNAME $DB_PASSWORD \
	"CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"

echo "Initializing database $DB_NAME..."
../execute-sql-script-file.sh $DB_HOST $DB_PORT \
	$DB_NAME $DB_USERNAME $DB_PASSWORD \
	"./01.auth_init.sql"

echo "Deployment of auth-server-db completed."

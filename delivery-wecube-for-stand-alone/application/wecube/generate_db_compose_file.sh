#!/bin/bash

CONFIG_FILE=$1
DB_COMPOSE_FILE_TEMPLATE="wecube-db.tpl"
DB_COMPOSE_FILE="wecube-db.yml"

source $CONFIG_FILE

cp $DB_COMPOSE_FILE_TEMPLATE $DB_COMPOSE_FILE
sed -i "s~{{WECUBE_HOME}}~$wecube_home~g" $DB_COMPOSE_FILE
sed -i "s~{{MYSQL_USER_PASSWORD}}~$mysql_password~g" $DB_COMPOSE_FILE

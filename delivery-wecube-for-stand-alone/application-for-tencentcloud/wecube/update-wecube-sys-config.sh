#!/bin/bash

set -e

CONFIG_FILE=$1

[ ! -f $CONFIG_FILE ] && echo "Invalid configuration file: $CONFIG_FILE" && exit 1
source $CONFIG_FILE

SQL_FILE_TEMPLATE="$installer_dir/wecube/database/platform-core/04.update_sys_var_for_deployment.sql.tpl"
SQL_FILE="$installer_dir/wecube/database/platform-core/04.update_sys_var_for_deployment.sql"
cp $SQL_FILE_TEMPLATE $SQL_FILE
sed -i "s~{{WECUBE_HOME}}~$wecube_home~g" $SQL_FILE
sed -i "s~{{WECUBE_PLUGIN_HOSTS}}~$wecube_plugin_hosts~g" $SQL_FILE
sed -i "s~{{WECUBE_PLUGIN_HOST_PORT}}~$wecube_plugin_host_port~g" $SQL_FILE
sed -i "s~{{GATEWAY_HOST}}~$gateway_host~g" $SQL_FILE
sed -i "s~{{GATEWAY_PORT}}~$gateway_port~g" $SQL_FILE
sed -i "s~{{MYSQL_SERVER_ADDR}}~$mysql_server_addr~g" $SQL_FILE
sed -i "s~{{MYSQL_SERVER_PORT}}~$mysql_server_port~g" $SQL_FILE
sed -i "s~{{S3_HOST}}~$s3_host~g" $SQL_FILE
sed -i "s~{{S3_PORT}}~$s3_port~g" $SQL_FILE
sed -i "s~{{S3_URL}}~$s3_url~g" $SQL_FILE

./execute_sql_script_file.sh $mysql_server_addr $mysql_server_port \
	$mysql_server_database_name $mysql_user_name $mysql_user_password \
	$SQL_FILE

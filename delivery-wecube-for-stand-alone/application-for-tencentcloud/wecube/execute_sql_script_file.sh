#!/bin/sh

mysql_host=$1
mysql_port=$2
mysql_database=$3
mysql_user=$4
mysql_password=$5
sql_script_file=$6

docker run --rm -t -v "$sql_script_file:$sql_script_file" \
	ccr.ccs.tencentyun.com/webankpartners/mysql:5.6 \
	mysql \
	-h"$mysql_host" -P"$mysql_port" -D"$mysql_database" \
	-u"$mysql_user" -p"$mysql_password" \
	-e"source $sql_script_file"

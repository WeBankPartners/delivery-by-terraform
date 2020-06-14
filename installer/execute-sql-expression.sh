#!/bin/bash

set -e

mysql_host=$1
mysql_port=$2
mysql_database=$3
mysql_user=$4
mysql_password=$5
sql_expression=$6

docker run --rm -t \
	ccr.ccs.tencentyun.com/webankpartners/mysql:5.6 \
	mysql \
	-h"$mysql_host" -P"$mysql_port" -D"$mysql_database" \
	-u"$mysql_user" -p"$mysql_password" \
	-e"$sql_expression"

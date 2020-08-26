#!/bin/bash

set -e

MYSQL_HOST=$1
MYSQL_PORT=$2
MYSQL_DATABASE=$3
MYSQL_USER=$4
MYSQL_PASSWORD=$5
SQL_STATEMENTS=$6

docker run --rm -t \
	ccr.ccs.tencentyun.com/webankpartners/mysql:5.6 \
	mysql \
	-h"$MYSQL_HOST" -P"$MYSQL_PORT" -D"$MYSQL_DATABASE" \
	-u"$MYSQL_USER" -p"$MYSQL_PASSWORD" \
	-e"$SQL_STATEMENTS"

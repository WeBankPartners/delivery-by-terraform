#!/bin/bash

set -e

SYS_SETTINGS_ENV_FILE=$1
source $SYS_SETTINGS_ENV_FILE

http --ignore-stdin --check-status --follow \
	--headers POST "http://${CORE_HOST}:19090/auth/v1/api/login" \
	username="$DEFAULT_ADMIN_USERNAME" \
	password="$DEFAULT_ADMIN_PASSWORD" \
	| awk '/Authorization:/{ print $3 }' \
	| sed 's/\r$//'

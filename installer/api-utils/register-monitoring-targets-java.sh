#!/bin/bash

set -e
set -o pipefail

SYS_SETTINGS_ENV_FILE=$1
source $SYS_SETTINGS_ENV_FILE

SCRIPT_DIR=$(dirname "$0")

[ -z "${ACCESS_TOKEN}" ] && ACCESS_TOKEN=$(${SCRIPT_DIR}/login.sh ${SYS_SETTINGS_ENV_FILE})


ACCESS_TOKEN="${ACCESS_TOKEN}" ${SCRIPT_DIR}/register-monitoring-target.sh \
	${SYS_SETTINGS_ENV_FILE} <<-EOF
		{
			"type": "java",
			"name": "platform-core",
			"ip": "${CORE_HOST}",
			"port": "${WECUBE_SERVER_JMX_PORT}",
			"user": "",
			"password": "",
			"agent_manager": true,
			"exporter": false
		}
	EOF

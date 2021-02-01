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
		    "type": "host",
		    "ip": "${CORE_HOST}",
		    "port": "9100",
		    "agent_manager": false,
		    "exporter": false
		}
	EOF

ACCESS_TOKEN="${ACCESS_TOKEN}" ${SCRIPT_DIR}/register-monitoring-target.sh \
	${SYS_SETTINGS_ENV_FILE} <<-EOF
		{
		    "type": "host",
		    "ip": "${PLUGIN_HOST}",
		    "port": "9100",
		    "agent_manager": false,
		    "exporter": false
		}
	EOF

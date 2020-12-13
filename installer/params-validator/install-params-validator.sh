#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo "Validating installation parameter HOST_PRIVATE_IP=${HOST_PRIVATE_IP}..."

echo -e "\nChecking WeCube installation directory \"${WECUBE_HOME}\"..."
if [ -d "${WECUBE_HOME}" ] && [ -n "$(ls --hide=installer ${WECUBE_HOME})" ]; then
	echo -e "\e[0;31mWeCube home directory is not empty, please clean that directory or use another location.\e[0m"
	exit 1
else
	echo -e "\e[0;32mPASS\e[0m"
fi

echo -e "\nChecking ssh connection to ${HOST_PRIVATE_IP} with provided password for the root user..."
SSH_PASSWORD_FILE="./ssh-password"
(umask 066 && cat <<EOF >"$SSH_PASSWORD_FILE"
${INITIAL_PASSWORD}
EOF
)
yum install -y -q sshpass
if $(sshpass -f "${SSH_PASSWORD_FILE}" ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@"${HOST_PRIVATE_IP}" 'exit 0'); then
	echo -e "\e[0;32mPASS\e[0m"
else
	echo -e "\e[0;31mCannot connect via ssh to host, please check host and password for the root user.\e[0m"
	exit 1
fi

#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

PLUGIN_DEPLOY_DIR="${WECUBE_HOME}/plugin"
echo "Creating plugin deployment directory $PLUGIN_DEPLOY_DIR ..."
mkdir -p "$PLUGIN_DEPLOY_DIR"

echo "Waiting for WeCube platform initialization..."
../wait-for-it.sh -t 300 "$CORE_HOST:19100" -- echo "WeCube platform core is ready."

echo "Creating resource server record..."

ACCESS_TOKEN=$(http -h POST "http://${CORE_HOST}:19090/auth/v1/api/login" username=umadmin password=umadmin | awk '/Authorization:/{ print $3 }' | sed 's/\r$//')
[ -z "$ACCESS_TOKEN" ] && echo -e "\n\e[0;31mFailed to get access token from WeCube platform! Installation aborted.\e[0m\n" && exit 1
http POST "http://${CORE_HOST}:19090/platform/resource/servers/create" "Authorization:Bearer $ACCESS_TOKEN" <<EOF
[
  {
    "name": "containerHost",
    "type": "docker",
    "status": "active",
    "isAllocated": true,
    "host": "${HOST_PRIVATE_IP}",
    "port": "22",
    "loginUsername": "root",
    "loginPassword": "${INITIAL_PASSWORD}",
    "purpose": "Plugin container hosting"
  }
]
EOF
echo "Resource server record created."

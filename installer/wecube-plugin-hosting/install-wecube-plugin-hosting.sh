#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

PLUGIN_DEPLOY_DIR="${WECUBE_HOME}/plugins"
echo "Creating plugin deployment directory $PLUGIN_DEPLOY_DIR"
mkdir -p "$PLUGIN_DEPLOY_DIR"
sudo chown -R $USER:$WECUBE_USER $PLUGIN_DEPLOY_DIR
sudo chmod -R 0770 $PLUGIN_DEPLOY_DIR

echo -e "\nWaiting for WeCube platform initialization..."
../wait-for-it.sh -t 300 "$CORE_HOST:19100" -- echo "WeCube platform core is ready."

echo -e "\nCreating resource server record..."

CREDENTIALS=$(jq -n \
	--arg username "umadmin" \
	--arg password "umadmin" \
	'{username: $username, password: $password}'
)
ACCESS_TOKEN=$(curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/auth/v1/api/login" \
	--header 'Content-Type: application/json' \
	--data @- <<<"${CREDENTIALS}" \
	| ../api-utils/check-status-in-json.sh '.status == "OK" and .message == "success"' \
	| jq -r '.data[] | select(.tokenType == "accessToken") | .token'
)

[ -z "$ACCESS_TOKEN" ] && echo -e "\n\e[0;31mFailed to get access token from WeCube platform! Installation aborted.\e[0m\n" && exit 1

curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/platform/resource/servers/create" \
	--header "Authorization: Bearer ${ACCESS_TOKEN}" \
	--header 'Content-Type: application/json' \
	--data @- <<-EOF \
	| ../api-utils/check-status-in-json.sh
		[
			{
				"name": "containerHost",
				"type": "docker",
				"status": "active",
				"isAllocated": true,
				"host": "${HOST_PRIVATE_IP}",
				"port": "22",
				"loginUsername": "${WECUBE_USER}",
				"loginPassword": "${INITIAL_PASSWORD}",
				"purpose": "Plugin container hosting"
				}
		]
	EOF

echo "Resource server record created."

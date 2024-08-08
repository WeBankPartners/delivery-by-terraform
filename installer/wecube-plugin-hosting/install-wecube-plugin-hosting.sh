#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

PLUGIN_HOSTING_ENV_TEMPLATE_FILE="./wecube-plugin-hosting.env.tpl"
PLUGIN_HOSTING_ENV_FILE="./wecube-plugin-hosting.env"
echo "Building WeCube plugin hosting env file $PLUGIN_HOSTING_ENV_FILE"
../substitute-in-file.sh $ENV_FILE $PLUGIN_HOSTING_ENV_TEMPLATE_FILE $PLUGIN_HOSTING_ENV_FILE
source $PLUGIN_HOSTING_ENV_FILE


echo "Creating WeCube plugin hosting directories..."
PLUGIN_HOSTING_DIRS=(
	"${WECUBE_PLUGIN_DEPLOY_PATH}"
	"${WECUBE_PLUGIN_BASE_MOUNT_PATH}"
)
for PLUGIN_HOSTING_DIR in "${PLUGIN_HOSTING_DIRS[@]}"; do
	echo "  - ${PLUGIN_HOSTING_DIR}"
	mkdir -p $PLUGIN_HOSTING_DIR
	sudo chown -R $USER:$WECUBE_USER $PLUGIN_HOSTING_DIR
	sudo chmod -R 0770 $PLUGIN_HOSTING_DIR
done

#kaline=`grep 'KexAlgorithms' /etc/ssh/sshd_config`
#hellmansha1='diffie-hellman-group-exchange-sha1'
#if [ -z "$kaline" ]
#then
#  echo 'KexAlgorithms line empty'
#else
#  if [[ $kaline =~ $hellmansha1 ]]
#   then
#     echo 'ssh ka check ok'
#  else
#    echo 'ssh ka check,add hellman-sha1'
#    newkaline="${kaline},${hellmansha1}"
#    echo ${newkaline}
#    sed -i "s~${kaline}~${newkaline}~g" /etc/ssh/sshd_config
#    systemctl restart sshd
#  fi
#fi

echo -e "\nWaiting for WeCube platform initialization..."
../wait-for-it.sh -t 120 "$CORE_HOST:19090" -- echo "WeCube platform core is ready."

echo -e "\nCreating resource server record..."

CREDENTIALS=$(jq -n \
	--arg username "$DEFAULT_ADMIN_USERNAME" \
	--arg password "$DEFAULT_ADMIN_PASSWORD" \
	'{username: $username, password: $password}'
)
ACCESS_TOKEN=$(curl -sSfL \
	--request POST "http://${CORE_HOST}:19090/auth/v1/api/login" \
	--header 'Content-Type: application/json' \
	--data @- <<<"${CREDENTIALS}" \
	| ../api-utils/check-status-in-json.sh '.status == "OK"' \
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

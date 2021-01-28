#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

read -d '' PROXY_SETTINGS_ENV <<-EOF || true
	export HTTP_PROXY="http://$PROXY_HOST:$PROXY_PORT"
	export http_proxy="http://$PROXY_HOST:$PROXY_PORT"

	export HTTPS_PROXY="http://$PROXY_HOST:$PROXY_PORT"
	export https_proxy="http://$PROXY_HOST:$PROXY_PORT"

	export NO_PROXY="localhost,127.0.0.1,$VPC_CIDR_IP"
	export no_proxy="localhost,127.0.0.1,$VPC_CIDR_IP"
EOF

echo -e "\nConfiguring environment variables for proxy settings..."
cat <<<"$PROXY_SETTINGS_ENV" | sudo tee /etc/profile.d/proxy_settings_for_wecube.sh
cat <<<"$PROXY_SETTINGS_ENV" >>~/.bashrc

echo -e "\nConfiguring sudo to keep environment variables for proxy settings..."
cat <<-EOF | sudo tee "/etc/sudoers.d/zzz-allow-group-${WECUBE_USER}-with-no-password"
	Defaults    env_keep += "HTTP_PROXY http_proxy HTTPS_PROXY https_proxy NO_PROXY no_proxy"
EOF

echo -e "\nConfiguring yum proxy..."
cat <<-EOF  | sudo tee -a /etc/yum.conf
	proxy=http://$PROXY_HOST:$PROXY_PORT
EOF

../wait-for-it.sh -t 60 "$PROXY_HOST:$PROXY_PORT" -- echo "Connection to proxy is ready."

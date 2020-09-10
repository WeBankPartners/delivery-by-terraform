#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo "Installing proxy settings on $HOST_PRIVATE_IP"

PROFILE_FILE="/etc/profile.d/proxy_settings_for_wecube.sh"

cat >$PROFILE_FILE <<EOF
export HTTP_PROXY="http://$PROXY_HOST:$PROXY_PORT"
export http_proxy="http://$PROXY_HOST:$PROXY_PORT"

export HTTPS_PROXY="http://$PROXY_HOST:$PROXY_PORT"
export https_proxy="http://$PROXY_HOST:$PROXY_PORT"

export NO_PROXY="localhost,127.0.0.1,$VPC_CIDR_IP"
export no_proxy="localhost,127.0.0.1,$VPC_CIDR_IP"
EOF
cat $PROFILE_FILE >>~/.bashrc
echo "Proxy settings are saved into $PROFILE_FILE"

../wait-for-it.sh -t 60 "$PROXY_HOST:$PROXY_PORT" -- echo "Connection to proxy is ready."

echo "Installation of proxy settings completed."

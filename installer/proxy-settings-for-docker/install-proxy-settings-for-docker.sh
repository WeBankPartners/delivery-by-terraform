#!/bin/bash

set -e

ENV_FILE=$1
source $ENV_FILE

DOCKER_CONF_DIR="/etc/systemd/system/docker.service.d"
DOCKER_CONF_FILE="$DOCKER_CONF_DIR/docker-wecube-override-02-proxy.conf"
sudo mkdir -p "$DOCKER_CONF_DIR"
echo "Saving proxy settings for Docker daemon into \"$DOCKER_CONF_FILE\"..."
cat <<-EOF | sudo tee "$DOCKER_CONF_FILE"
	[Service]
	Environment="HTTP_PROXY=http://$PROXY_HOST:$PROXY_PORT"
	Environment="HTTPS_PROXY=http://$PROXY_HOST:$PROXY_PORT"
	Environment="NO_PROXY=localhost,127.0.0.1,$VPC_CIDR_IP"
EOF

../wait-for-it.sh -t 60 "$PROXY_HOST:$PROXY_PORT" -- echo "Connection to proxy is ready."

sudo systemctl daemon-reload
sudo systemctl restart docker

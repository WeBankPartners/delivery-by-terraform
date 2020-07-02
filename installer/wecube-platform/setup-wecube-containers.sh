#!/bin/bash

set -e

ENV_FILE=$1
WECUBE_IMAGE_VERSION=$2

source $ENV_FILE

WECUBE_ENV_TEMPLATE_FILE="./wecube-platform.env.tpl"
WECUBE_ENV_FILE="./wecube-platform.env"
echo "Building WeCube env file $WECUBE_ENV_FILE"
WECUBE_IMAGE_VERSION=$WECUBE_IMAGE_VERSION \
  ../substitute-in-file.sh $ENV_FILE $WECUBE_ENV_TEMPLATE_FILE $WECUBE_ENV_FILE
source $WECUBE_ENV_FILE

echo "Starting WeCube containers..."
docker-compose -f docker-compose.yml --env-file=$WECUBE_ENV_FILE up -d
PORTS_TO_CHECK=(
  "$AUTH_SERVER_PORT"
  "$WECUBE_SERVER_PORT"
  "$WECUBE_SERVER_JMX_PORT"
  "$GATEWAY_PORT"
  "$PORTAL_PORT"
)
for PORT_TO_CHECK in "${PORTS_TO_CHECK[@]}"; do
  ../wait-for-it.sh -t 120 "$HOST_PRIVATE_IP:$PORT_TO_CHECK" -- echo "Server listening at port $PORT_TO_CHECK is ready."
done
echo -e "\nAll server containers are ready."

# 再次启用IP转发并配置桥接来解决Docker容器对外部网络的通信问题
cat <<EOF >/etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p /etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf
sysctl net.ipv4.ip_forward

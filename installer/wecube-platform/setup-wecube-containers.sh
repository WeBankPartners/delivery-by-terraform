#!/bin/bash

set -e

WECUBE_ENV_FILE=$1
source $WECUBE_ENV_FILE

echo "Starting WeCube containers..."
DOCKER_COMPOSE_ENV_FILE="./wecube-platform.docker-compose.env"
  ../build-docker-compose-env.sh $WECUBE_ENV_FILE $DOCKER_COMPOSE_ENV_FILE
docker-compose -f docker-compose.yml --env-file=$DOCKER_COMPOSE_ENV_FILE up -d

echo -e "\nChecking service port readiness...\n"
PORTS_TO_CHECK=(
  "$AUTH_SERVER_PORT"
  "$WECUBE_SERVER_PORT"
  "$WECUBE_SERVER_JMX_PORT"
  "$GATEWAY_PORT"
  "$PORTAL_PORT"
)
for PORT_TO_CHECK in "${PORTS_TO_CHECK[@]}"; do
	../wait-for-it.sh -t 120 "$HOST_PRIVATE_IP:$PORT_TO_CHECK" -- echo -e "Server listening at port $PORT_TO_CHECK is ready.\n"
done

# 再次启用IP转发并配置桥接来解决Docker容器对外部网络的通信问题
cat <<EOF >/etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p /etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf
sysctl net.ipv4.ip_forward

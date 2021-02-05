#!/bin/bash

set -e

WECUBE_ENV_FILE=$1
source $WECUBE_ENV_FILE

echo "Creating WeCube directories..."
VOLUME_DIRECTORIES=(
	"${STATIC_RESOURCE_SERVER_PATH}"
	"${APP_LOG_PATH}"
	"${WECUBE_PORTAL_LOG_PATH}"
	"${WECUBE_GATEWAY_LOG_PATH}"
	"${AUTH_SERVER_LOG_PATH}"
)
for VOLUME_DIR in "${VOLUME_DIRECTORIES[@]}"; do
	echo "  - ${VOLUME_DIR}"
	mkdir -p $VOLUME_DIR
	sudo chown -R $USER:$WECUBE_USER $VOLUME_DIR
	sudo chmod -R 0770 $VOLUME_DIR
done

echo "Starting WeCube containers..."

DOCKER_COMPOSE_ENV_FILE="./wecube-platform.docker-compose.env"
../build-docker-compose-env.sh $WECUBE_ENV_FILE $DOCKER_COMPOSE_ENV_FILE

sudo -su $WECUBE_USER docker-compose -f docker-compose.yml --env-file=$DOCKER_COMPOSE_ENV_FILE up -d

echo -e "\nChecking service port readiness...\n"
PORTS_TO_CHECK=(
  "$AUTH_SERVER_PORT"
  "$WECUBE_SERVER_PORT"
  "$WECUBE_SERVER_JMX_PORT"
  "$GATEWAY_PORT"
  "$PORTAL_PORT"
)
for PORT_TO_CHECK in "${PORTS_TO_CHECK[@]}"; do
	../wait-for-it.sh -t 120 "$HOST_PRIVATE_IP:$PORT_TO_CHECK" -- echo -e "Service listening at port $PORT_TO_CHECK is ready.\n"
done

# 再次启用IP转发并配置桥接来解决Docker容器对外部网络的通信问题
cat <<-EOF | sudo tee /etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf >/dev/null
	net.ipv4.ip_forward = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl -p /etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf
sudo sysctl net.ipv4.ip_forward

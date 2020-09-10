#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo "Installing docker on $HOST_PRIVATE_IP"

echo -e "\nChecking Docker...\n"
PREREQUISITES_SATISFIED=''
if [ "$PREREQUISITES_SATISFIED" != 'false' ] && ! $(docker version >/dev/null 2>&1); then
  echo 'Docker Engine is not properly installed!'
  PREREQUISITES_SATISFIED='false'
fi
if [ "$PREREQUISITES_SATISFIED" != 'false' ] && ! $(docker-compose version >/dev/null 2>&1); then
  echo 'Docker Compose is not properly installed!'
  PREREQUISITES_SATISFIED='false'
fi
if [ "$PREREQUISITES_SATISFIED" != 'false' ] && ! $(curl -sSLf "http://$HOST_PRIVATE_IP:$DOCKER_PORT/version" >/dev/null 2>&1); then
  echo 'Docker Engine is not listening on port $DOCKER_PORT!'
  PREREQUISITES_SATISFIED='false'
fi

if [ "$PREREQUISITES_SATISFIED" != 'false' ]; then
  echo "Congratulations, Docker is properly installed."
  exit 0
fi


echo -e "\nInstalling Docker Engine...\n"

# 移除已安装的旧版本Docker
yum remove docker \
           docker-client \
           docker-client-latest \
           docker-common \
           docker-latest \
           docker-latest-logrotate \
           docker-logrotate \
           docker-engine

# 安装工具组件
yum install -y yum-utils device-mapper-persistent-data lvm2

# 安装Docker Engine
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
if [ "$USE_MIRROR_IN_MAINLAND_CHINA" == "true" ]; then
  echo 'Using mirror for docker yum repository in Mainland China.'
  sed -i 's+download.docker.com+mirrors.cloud.tencent.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
fi
yum makecache fast
yum install -y docker-ce docker-ce-cli containerd.io

# 安装Docker Compose
echo "Installing Docker Compose..."
DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/1.25.4/run.sh"
DOCKER_COMPOSE_BIN="/usr/local/bin/docker-compose"
../curl-with-retry.sh -fL $DOCKER_COMPOSE_URL -o $DOCKER_COMPOSE_BIN
chmod +x "$DOCKER_COMPOSE_BIN"

# 配置Docker Engine以监听远程API请求
mkdir -p /etc/systemd/system/docker.service.d
DOCKER_START_CMD="/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:$DOCKER_PORT"
if [ "$USE_MIRROR_IN_MAINLAND_CHINA" == "true" ]; then
  echo 'Using mirror for docker image registry in Mainland China.'
  DOCKER_START_CMD="$DOCKER_START_CMD --registry-mirror=https://mirror.ccs.tencentyun.com"
fi
cat >/etc/systemd/system/docker.service.d/docker-wecube-override-01-port.conf <<EOF
[Service]
ExecStart=
ExecStart=$DOCKER_START_CMD
EOF

# 启动Docker服务
systemctl enable docker.service
systemctl start docker.service
../wait-for-it.sh -t 60 "$HOST_PRIVATE_IP:$DOCKER_PORT" -- echo "Docker Engine is ready."
docker run --rm -t hello-world

# 启用IP转发并配置桥接来解决Docker容器对外部网络的通信问题
modprobe overlay
modprobe br_netfilter
cat <<EOF >/etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p /etc/sysctl.d/zzz.net-forward-and-bridge-for-docker.conf
sysctl net.ipv4.ip_forward

echo -e "\nVerifying Docker installation...\n"
docker version || (echo -e '\n\e[0;31mDocker Engine is not properly installed!\e[0m\n' && exit 1)
docker-compose version || (echo -e '\n\e[0;31mDocker Compose is not properly installed!\e[0m\n' && exit 1)
curl -sSLf "http://$HOST_PRIVATE_IP:$DOCKER_PORT/version" || (echo -e '\n\e[0;31mDocker Engine is not listening on TCP port $DOCKER_PORT!\e[0m\n' && exit 1)

echo "Docker installation completed."

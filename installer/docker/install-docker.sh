#!/bin/bash

set -e

ENV_FILE=$1

source $ENV_FILE

echo -e "\nChecking Docker...\n"
PREREQUISITES_SATISFIED=''
if [ "$PREREQUISITES_SATISFIED" != 'false' ] && ! $(sudo docker version >/dev/null 2>&1); then
	echo 'Docker Engine is not properly installed!'
	PREREQUISITES_SATISFIED='false'
fi
if [ "$PREREQUISITES_SATISFIED" != 'false' ] && ! $(sudo docker-compose version >/dev/null 2>&1); then
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
sudo yum remove docker \
				docker-client \
				docker-client-latest \
				docker-common \
				docker-latest \
				docker-latest-logrotate \
				docker-logrotate \
				docker-engine

# 安装工具组件
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# 安装Docker Engine
#sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#if [ "$USE_MIRROR_IN_MAINLAND_CHINA" == "true" ]; then
#	echo 'Using mirror for docker yum repository in Mainland China https://mirrors.cloud.tencent.com/docker-ce'
#	sudo sed -i 's+download.docker.com+mirrors.cloud.tencent.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
#fi
#sudo yum makecache fast
#sudo yum install -y docker-ce docker-ce-cli containerd.io
echo "Installing Docker ..."
DOCKER_PACKAGE_URL="https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com/docker-19.03.15.tgz"
sudo ../curl-with-retry.sh -fL $DOCKER_PACKAGE_URL -o /tmp/docker-19.03.15.tgz
sudo tar xzvf /tmp/docker-19.03.15.tgz -C /tmp
sudo chmod +x /tmp/docker/*
sudo mv /tmp/docker/* /usr/bin

# 安装Docker Compose
echo "Installing Docker Compose..."
DOCKER_COMPOSE_URL="https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com/docker-compose-Linux-x86_64_1_25_4"
DOCKER_COMPOSE_BIN="/usr/bin/docker-compose"
sudo ../curl-with-retry.sh -fL $DOCKER_COMPOSE_URL -o $DOCKER_COMPOSE_BIN
sudo chmod +x "$DOCKER_COMPOSE_BIN"

# 配置Docker Engine以监听远程API请求
echo "Configuring Docker daemon..."
sudo mkdir -p /etc/systemd/system/docker.service.d /etc/docker
sudo cp daemon.json /etc/docker/
DOCKER_START_CMD="/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://0.0.0.0:$DOCKER_PORT"
#if [ "$USE_MIRROR_IN_MAINLAND_CHINA" == "true" ]; then
#	echo 'Using mirror for docker image registry in Mainland China https://mirror.ccs.tencentyun.com'
#	DOCKER_START_CMD="$DOCKER_START_CMD --registry-mirror=https://mirror.ccs.tencentyun.com"
#fi
#cat <<-EOF | sudo tee /etc/systemd/system/docker.service.d/docker-wecube-override-01-port.conf
#	[Service]
#	ExecStart=
#	ExecStart=$DOCKER_START_CMD
#EOF

cat <<-EOF | sudo tee /lib/systemd/system/dockerd.service
	[Unit]
  Description=dockerd

  [Service]
  Environment=QCLOUD_NORM_URL=
  Type=notify
  ExecStart=$DOCKER_START_CMD
  ExecStartPre=/bin/rm -f /var/run/docker.pid
  ExecStartPost=-/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
  ExecReload=/bin/kill -s HUP $MAINPID
  LimitNOFILE=1048576
  LimitNPROC=1048576
  LimitCORE=infinity
  TimeoutStartSec=0
  Delegate=yes
  KillMode=process
  Restart=always
  RestartSec=10

  [Install]
  WantedBy=multi-user.target
EOF

# 启动Docker服务
sudo systemctl enable dockerd.service
sudo systemctl start dockerd.service
../wait-for-it.sh -t 60 "$HOST_PRIVATE_IP:$DOCKER_PORT" -- echo "Docker Engine is ready."
sudo docker run --rm -t hello-world

# 启用IP转发并配置桥接来解决Docker容器对外部网络的通信问题
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<-EOF | sudo tee /etc/sysctl.d/w01.net-forward-and-bridge-for-docker.conf >/dev/null
	net.ipv4.ip_forward = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl -p /etc/sysctl.d/w01.net-forward-and-bridge-for-docker.conf
sudo sysctl net.ipv4.ip_forward

# 配置可执行Docker的用户组及用户
echo "Creating group \"docker\"..."
sudo groupadd -f docker

echo "Adding users \"$USER\" and \"$WECUBE_USER\" to group \"docker\"..."
sudo usermod -aG docker $USER
sudo usermod -aG docker $WECUBE_USER

echo -e "\nVerifying Docker installation...\n"
sudo docker version || (echo -e '\n\e[0;31mDocker Engine is not properly installed!\e[0m\n' && exit 1)
sudo docker-compose version || (echo -e '\n\e[0;31mDocker Compose is not properly installed!\e[0m\n' && exit 1)
curl -sSLf "http://$HOST_PRIVATE_IP:$DOCKER_PORT/version" || (echo -e '\n\e[0;31mDocker Engine is not listening on TCP port $DOCKER_PORT!\e[0m\n' && exit 1)

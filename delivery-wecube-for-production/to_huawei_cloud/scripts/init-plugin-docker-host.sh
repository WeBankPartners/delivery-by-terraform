#!/bin/bash

echo "Starting WeCube plugin docker host ..."

echo "remoteHost=$1,password=$2"
echo `pwd`
remoteHost=$1
password=$2
source $3

sshpass -p ${password} ssh -o "StrictHostKeyChecking no" root@${remoteHost}  > /dev/null 2>&1 << remoteCmd

if [ ! -d ${wecube_plugin_deploy_path} ];then
      mkdir -p ${wecube_plugin_deploy_path}
fi

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf 
sysctl -p 

chmod +x /root/init-host.sh && ./init-host.sh

yum install docker -y

echo "OPTIONS='-H unix://var/run/docker.sock -H tcp://0.0.0.0:2375'" >> /etc/sysconfig/docker

systemctl start docker.service
systemctl enable docker.service

sudo systemctl daemon-reload
sudo service docker restart

echo "export http_proxy='http://10.128.199.3:3128'" >> /etc/profile
echo "export https_proxy='http://10.128.199.3:3128'" >> /etc/profile

source /etc/profile

exit
remoteCmd

echo "Start WeCube plugin docker host success !"
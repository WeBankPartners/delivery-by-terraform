#!/bin/bash

echo "Starting WeCube platform ..."

echo "remoteHost=$1,password=$2,image_version=$3"

echo `pwd`
remoteHost=$1
password=$2
image_version=$3

sshpass -p ${password} ssh -o "StrictHostKeyChecking no" root@${remoteHost}  > /dev/null 2>&1 << remoteCmd

chmod +x /root/init-host.sh && ./init-host.sh

chmod +x /root/wecube-platform-scripts/*
yum install -y dos2unix
dos2unix /root/wecube-platform-scripts/*
cd /root/wecube-platform-scripts/
./install-wecube-platform.sh wecube-platform.cfg ${image_version} > install-wecube.log 2>&1


echo "export http_proxy='http://10.128.194.2:3128'" >> /etc/profile
echo "export https_proxy='http://10.128.194.2:3128'" >> /etc/profile

source /etc/profile

exit
remoteCmd

echo "Start WeCube platform success !"

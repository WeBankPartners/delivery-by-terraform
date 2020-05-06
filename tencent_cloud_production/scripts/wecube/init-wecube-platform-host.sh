#!/bin/bash

echo "Starting WeCube platform ..."

echo "remoteHost=$1,password=$2,image_version=$3"

echo `pwd`
remoteHost=$1
password=$2
image_version=$3
config_file=$4
s3_port=$5

sshpass -p ${password} ssh -o "StrictHostKeyChecking no" root@${remoteHost}  > /dev/null 2>&1 << remoteCmd

chmod +x /root/wecube-platform-scripts/*
yum install -y dos2unix
dos2unix /root/wecube-platform-scripts/*
cd /root/wecube-platform-scripts/
./install-wecube-platform.sh $config_file ${image_version} $s3_port > install-wecube.log 2>&1

exit
remoteCmd

echo "Start WeCube platform success !"

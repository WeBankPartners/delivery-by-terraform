#!/bin/bash

echo "Starting WeCube platform ..."

echo "remoteHost=$1,password=$2,image_version=$3"

echo `pwd`
remoteHost=$1
password=$2
image_version=$3

curl -L https://github.com/WeBankPartners/wecube-platform/archive/master.zip -o wecube-source.zip

unzip -o -q wecube-source.zip -d wecube-source

mkdir -p wecube-platform/database/auth-server
mkdir -p wecube-platform/database/platform-core

cp -f wecube-source/wecube-platform-master/platform-core/src/main/resources/database/01.wecube.schema.sql wecube-platform/database/auth-server/01.wecube.schema.sql

cp -f wecube-source/wecube-platform-master/platform-core/src/main/resources/database/03.wecube.flow_engine.schema.sql wecube-platform/database/platform-core/03.wecube.flow_engine.schema.sql


sshpass -p ${password} ssh -o "StrictHostKeyChecking no" root@${remoteHost}  > /dev/null 2>&1 << remoteCmd

chmod +x /root/init-host.sh && ./init-host.sh

chmod +x /root/wecube-platform-scripts/*
yum install -y dos2unix
dos2unix /root/wecube-platform-scripts/*
dos2unix /root/wecube-platform-scripts/auto-plugin-installer/*
cd /root/wecube-platform-scripts/

./install-wecube-platform.sh wecube-platform.cfg ${image_version} > install-wecube.log 2>&1


exit
remoteCmd

echo "Start WeCube platform success !"

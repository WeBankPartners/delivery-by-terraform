#!/bin/bash

echo "Starting WeCube platform ..."

echo "remoteHost=$1,password=$2,image_version=$3"

echo `pwd`
remoteHost=$1
password=$2
image_version=$3

mkdir -p wecube-platform/database/auth-server
mkdir -p wecube-platform/database/platform-core

curl -#L https://github.com/WeBankPartners/wecube-platform/raw/master/platform-core/src/main/resources/database/01.wecube.schema.sql -o wecube-platform/database/platform-core/01.wecube.schema.sql
curl -#L https://github.com/WeBankPartners/wecube-platform/raw/master/platform-core/src/main/resources/database/03.wecube.flow_engine.schema.sql -o wecube-platform/database/platform-core/03.wecube.flow_engine.schema.sql
curl -#L https://github.com/WeBankPartners/wecube-platform/raw/master/platform-auth-server/src/main/resources/database/01.auth.schema.sql -o wecube-platform/database/auth-server/01.auth_init.sql


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

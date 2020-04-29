#!/bin/bash

echo "Starting WeCube plugin S3 ..."

echo `pwd`
remoteHost=$1
password=$2
s3_port=9001
s3_access_key="access_key"
s3_secret_key="secret_key"

sshpass -p ${password} ssh -o "StrictHostKeyChecking no" root@${remoteHost}  > /dev/null 2>&1 << remoteCmd

ls /root/  > install.log 2>&1
chmod +x /root/init-host.sh && ./init-host.sh  >> install.log 2>&1


yum install docker -y  >> install.log 2>&1
yum install docker-compose -y >> install.log 2>&1

mkdir -p /data/wecube/plugin
sed "s~{{S3_PORT}}~$s3_port~g" wecube-s3.tpl > wecube-s3.yml
sed -i "s~{{S3_ACCESS_KEY}}~$s3_access_key~g" wecube-s3.yml
sed -i "s~{{S3_SECRET_KEY}}~$s3_secret_key~g" wecube-s3.yml

systemctl start docker.service >> install.log 2>&1
systemctl enable docker.service >> install.log 2>&1
docker-compose -f wecube-s3.yml up -d >> install.log 2>&1
sleep 30
exit
remoteCmd

echo "Start WeCube plugin S3 success !"

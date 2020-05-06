#!/bin/bash

echo "Starting WeCube plugin S3 ..."

echo "remoteHost=$1,password=$2,s3_port=$3,s3_access_key=$4,s3_secret_key=$5"
echo `pwd`
remoteHost=$1
password=$2
s3_port=$3

echo "sshpass -p ${password} scp /root/scripts/wecube/wecube-s3.tpl root@${remoteHost}:/root/"
sshpass -p ${password} ssh -o "StrictHostKeyChecking no" root@${remoteHost}  > /dev/null 2>&1 << remoteCmd

yum install docker -y
yum install docker-compose -y

mkdir -p /data/wecube/plugin
sed "s~{{S3_PORT}}~$s3_port~g" wecube-s3.tpl > wecube-s3.yml

systemctl start docker.service
systemctl enable docker.service

docker-compose -f wecube-s3.yml up -d
sleep 30
exit
remoteCmd

echo "Start WeCube plugin S3 success !"

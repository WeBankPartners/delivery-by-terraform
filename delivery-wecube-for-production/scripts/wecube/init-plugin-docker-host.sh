#!/bin/bash

echo "Starting WeCube plugin docker host ..."

echo "remoteHost=$1,password=$2"
echo `pwd`
remoteHost=$1
password=$2
s3_port=$3

sshpass -p ${password} ssh -o "StrictHostKeyChecking no" root@${remoteHost}  > /dev/null 2>&1 << remoteCmd

yum install docker -y

echo "OPTIONS='-H unix://var/run/docker.sock -H tcp://0.0.0.0:2375'" >> /etc/sysconfig/docker

systemctl start docker.service
systemctl enable docker.service

mkdir -p /data/wecube/plugin
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/https-proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=http://10.128.199.3:3128" "HTTPS_PROXY=http://10.128.199.3:3128" "NO_PROXY=localhost,127.0.0.1,docker-registry.example.com,"
EOF
systemctl daemon-reload
systemctl restart docker

yum install docker-compose -y

cd /root/
sed "s~{{S3_PORT}}~$s3_port~g" wecube-s3.tpl > wecube-s3.yml
docker-compose -f wecube-s3.yml up -d

echo "export http_proxy='http://10.128.199.3:3128'" >> /etc/profile
echo "export https_proxy='http://10.128.199.3:3128'" >> /etc/profile

source /etc/profile

exit
remoteCmd

echo "Start WeCube plugin docker host success !"
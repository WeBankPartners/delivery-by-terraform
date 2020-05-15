#!/bin/bash

wecube_version=$2
source $1
s3_port=$3

echo "Starting wecube platform ..."


echo "${mysql_user_name}@${mysql_server_addr}:${mysql_server_port}  ${mysql_user_password}"
yum install docker -y
yum install unzip -y
systemctl start docker.service
systemctl enable docker.service


yum install mysql -y
mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -e "CREATE DATABASE IF NOT EXISTS ${mysql_server_database_name}"

mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -D${mysql_server_database_name} -e "source /root/wecube-platform-scripts/database/platform-core/01.wecube.schema.sql" 

mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -D${mysql_server_database_name} -e "source /root/wecube-platform-scripts/database/platform-core/02.wecube.system.data.sql" 

mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -D${mysql_server_database_name} -e "source /root/wecube-platform-scripts/database/platform-core/03.wecube.flow_engine.schema.sql" 

mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -e "CREATE DATABASE IF NOT EXISTS ${auth_server_database_name}"

mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -D${auth_server_database_name} -e "source /root/wecube-platform-scripts/database/auth-server/01.auth_init.sql" 

yum install docker-compose -y
./wecube-platform-generate-compose-yml.sh $1 ${wecube_version}

echo "export http_proxy='http://10.40.220.3:3128'" >> /etc/profile
echo "export https_proxy='http://10.40.220.3:3128'" >> /etc/profile

source /etc/profile
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/https-proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=http://10.40.220.3:3128" "HTTPS_PROXY=http://10.40.220.3:3128" "NO_PROXY=localhost,127.0.0.1"
EOF
systemctl daemon-reload
systemctl restart docker

sed "s~{{S3_PORT}}~$s3_port~g" wecube-s3.tpl > wecube-s3.yml
docker-compose -f wecube-s3.yml up -d

docker-compose -f docker-compose.yml up -d

docker run --name minio-client-mb -itd --entrypoint=/bin/sh ccr.ccs.tencentyun.com/webankpartners/mc
docker exec minio-client-mb mc config host add wecubeS3 $s3_url $s3_access_key $s3_secret_key wecubeS3
docker exec minio-client-mb mc mb wecubeS3/wecube-plugin-package-bucket
docker rm -f minio-client-mb

cat > /etc/systemd/system/docker.service.d/https-proxy.conf << EOF
EOF
systemctl daemon-reload
systemctl restart docker

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf 
sysctl -p 

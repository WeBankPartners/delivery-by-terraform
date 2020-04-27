#!/bin/bash


source $1
wecube_version=$2

echo "Starting wecube platform ..."

echo "${mysql_user_name}@${mysql_server_addr}:${mysql_server_port}  ${mysql_user_password}"
yum install docker -y

systemctl start docker.service
systemctl enable docker.service

yum install mysql -y
mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -e "CREATE DATABASE IF NOT EXISTS ${mysql_server_database_name}"

mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -D${mysql_server_database_name} -e "source /root/wecube-platform-scripts/database/platform-core/01.wecube.schema.sql" 
mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -D${mysql_server_database_name} -e "source /root/wecube-platform-scripts/database/platform-core/03.core_flow_engine_init.sql"
mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -D${mysql_server_database_name} -e "source /root/wecube-platform-scripts/database/platform-core/02.wecube.system.data.sql" 

mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -e "CREATE DATABASE IF NOT EXISTS ${auth_server_database_name}"

mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -D${auth_server_database_name} -e "source /root/wecube-platform-scripts/database/auth-server/01.auth_init.sql" 
mysql -h${mysql_server_addr} -P${mysql_server_port} -u${mysql_user_name} -p${mysql_user_password} -D${auth_server_database_name} -e "source /root/wecube-platform-scripts/database/auth-server/02.auth.system.data.sql" 
 
yum install docker-compose -y
./wecube-platform-generate-compose-yml.sh wecube-platform.cfg ${wecube_version}
docker-compose -f docker-compose.yml up -d

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf 
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf 
sysctl -p 

echo "export http_proxy='http://10.128.199.3:3128'" >> /etc/profile
echo "export https_proxy='http://10.128.199.3:3128'" >> /etc/profile

source /etc/profile


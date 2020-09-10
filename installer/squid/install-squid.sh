#!/bin/bash

set -e

ENV_FILE=$1

echo "Installing squid on $HOST_PRIVATE_IP"

source $ENV_FILE

yum install squid -y

sed -i "1i\cache_mem 64 MB" /etc/squid/squid.conf
sed -i "1i\http_access deny wecubehosts all" /etc/squid/squid.conf
sed -i "1i\http_access allow wecubehosts whitelist" /etc/squid/squid.conf
sed -i "1i\http_access allow wecubehosts whitelist_url" /etc/squid/squid.conf
sed -i "1i\http_access allow wecubehosts internal" /etc/squid/squid.conf

sed -i "1i\acl whitelist dstdomain -i .amazonaws.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i .github.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i .aliyun.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i .docker.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i .myqcloud.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i .qcloud.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i .tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i .tencentyun.com" /etc/squid/squid.conf

sed -i "1i\acl internal dst $VPC_CIDR_IP " /etc/squid/squid.conf
sed -i "1i\acl whitelist_url url_regex -i http://ccr-.*" /etc/squid/squid.conf

sed -i "1i\acl wecubehosts src $VPC_CIDR_IP      #vpc" /etc/squid/squid.conf
sed -i "1i\# squid config for WeCube" /etc/squid/squid.conf

systemctl enable squid
systemctl start squid
../wait-for-it.sh -t 60 "$HOST_PRIVATE_IP:$PROXY_PORT" -- echo "Squid is ready."

echo "Installation of squid completed."

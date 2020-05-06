#!/bin/bash

echo "Starting squid ..."

yum install squid -y

sed -i "1i\cache_mem 64 MB" /etc/squid/squid.conf
sed -i "1i\http_access deny wecubehosts all" /etc/squid/squid.conf
sed -i "1i\http_access allow wecubehosts whitelist" /etc/squid/squid.conf
sed -i "1i\http_access allow wecubehosts whitelist_url" /etc/squid/squid.conf
sed -i "1i\http_access allow wecubehosts internal" /etc/squid/squid.conf

sed -i "1i\acl whitelist dstdomain -i cvm.tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i cbs.tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i redis.tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i vpc.tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i mariadb.tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i cdb.tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i clb.tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i bmlb.tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i bm.tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i mongodb.tencentcloudapi.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i ccr.ccs.tencentyun.com" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain -i mirrors.tencentyun.com" /etc/squid/squid.conf
sed -i "1i\acl internal dst 10.40.192.0/19 " /etc/squid/squid.conf
sed -i "1i\acl whitelist_url url_regex -i http://ccr-.*" /etc/squid/squid.conf

#sed -i "1i\acl whitelist_url url_regex -i *.myqcloud.com" /etc/squid/squid.conf

sed -i "1i\acl whitelist dstdomain –i github.com" /etc/squid/squid.conf
sed -i "1i\acl wecubehosts src 10.40.192.0/19      #vpc" /etc/squid/squid.conf
sed -i "1i\# squid config for WeCube" /etc/squid/squid.conf

service squid reload
squid -z

squid -k reconfigure

systemctl start squid.service
systemctl enable squid.service

echo "Start squid success !"
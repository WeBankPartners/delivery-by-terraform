#!/bin/bash

echo "Starting squid ..."

yum install squid -y

sed -i "1i\cache_mem 64 MB" /etc/squid/squid.conf
#sed -i "1i\http_access deny wecubehosts all" /etc/squid/squid.conf
sed -i "1i\http_access allow wecubehosts whitelist" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdomain all" /etc/squid/squid.conf
sed -i "1i\acl wecubehosts src 0.0.0.0/0.0.0.0    #db subnet" /etc/squid/squid.conf
sed -i "1i\# squid config for WeCube" /etc/squid/squid.conf

service squid reload
squid -z

squid -k reconfigure

systemctl start squid.service
systemctl enable squid.service

echo "Start squid success !"
#!/bin/bash

echo "Starting squid ..."

chmod +x /root/wecube/*
chmod +x /root/wecube/auto-plugin-installer/*
yum install -y dos2unix
dos2unix /root/wecube/*
dos2unix /root/wecube/auto-plugin-installer/*

yum install squid -y

sed -i "1i\cache_mem 64 MB" /etc/squid/squid.conf
sed -i "1i\http_access deny wecubehosts all" /etc/squid/squid.conf
sed -i "1i\http_access allow wecubehosts whitelist" /etc/squid/squid.conf
sed -i "1i\acl whitelist dstdom_regex myhuaweicloud.com$" /etc/squid/squid.conf
sed -i "1i\acl wecubehosts src 10.128.192.0/19    #vpc " /etc/squid/squid.conf
sed -i "1i\# squid config for WeCube" /etc/squid/squid.conf

service squid reload
# squid -z
# squid -k reconfigure
systemctl start squid.service
systemctl enable squid.service

echo "Start squid success !"



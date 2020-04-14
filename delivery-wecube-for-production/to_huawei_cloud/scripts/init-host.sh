#!/bin/bash

echo "Starting init host ..."

echo "Starting replace CentOS yum repo..."
mkdir -p /etc/yum.repos.d/repo_bak/ && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/repo_bak/
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.myhuaweicloud.com/repo/CentOS-Base-7.repo 

echo "Starting install epel yum repo..."
rpm -ivh http://mirrors.myhuaweicloud.com/epel/epel-release-latest-7.noarch.rpm
wget -qO /etc/yum.repos.d/epel.repo http://mirrors.myhuaweicloud.com/repo/epel-7.repo
yum clean metadata
yum makecache
yum install epel-release -y >/dev/null 2>&1

echo 'nameserver {{HW_DNS}}'>>/etc/resolv.conf

echo "Starting init host success..."
#!/bin/bash

is_install_plugins=$1
wecube_host=$2
plugin_mysql_pwd=$3
wecube_home=${4:-/data/wecube}
plugin_db_host=$5
plugin_host=$6

INSTALLER_DIR="$wecube_home/installer"

echo "wecube_host=$wecube_host"
echo "plugin_mysql_pwd=$plugin_mysql_pwd"
echo "wecube_home=$wecube_home"
echo "plugin_db_host=$plugin_db_host"
echo "plugin_host=$plugin_host"
echo "INSTALLER_DIR=$INSTALLER_DIR"

if [ ${is_install_plugins} != "Y" ];then
  exit;
fi

echo "Starting install plugins ..."

yum install docker -y
# 启动Docker服务
systemctl enable docker.service
systemctl start docker.service

if [ ! -d $INSTALLER_DIR ]; then
    mkdir -p $INSTALLER_DIR
fi

#插件自动上传并注册
echo -e "\nNow starting to configure plugins...\n"

PLUGIN_INSTALLER_URL="https://github.com/kanetz/wecube-auto/archive/master.zip"
PLUGINS_BUCKET_URL="https://wecube-plugins.obs.ap-southeast-3.myhuaweicloud.com"
PLUGIN_PKGS=(
    "wecube-plugins-wecmdb-v1.4.3.2.zip"
    "wecube-plugins-huaweicloud-v1.1.4.9.zip"
    "wecube-plugins-saltstack-v1.8.4.zip"
    "wecube-plugins-notifications-v0.1.0.zip"
    "wecube-monitor-v1.3.4.zip"
    "wecube-plugins-artifacts-v0.2.0.zip"
    "wecube-plugins-service-mgmt-v0.4.1.zip"
)
PLUGIN_INSTALLER_PKG="$INSTALLER_DIR/wecube-plugin-installer.zip"

PLUGIN_INSTALLER_DIR="$INSTALLER_DIR/wecube-plugin-installer"
mkdir -p "$PLUGIN_INSTALLER_DIR"

echo "Fetching wecube-plugin-installer from $PLUGIN_INSTALLER_URL"
curl -L $PLUGIN_INSTALLER_URL -o $PLUGIN_INSTALLER_PKG
unzip -o -q $PLUGIN_INSTALLER_PKG -d $PLUGIN_INSTALLER_DIR

echo -e "\nFetching plugin packages...."
PLUGIN_PKG_DIR="$PLUGIN_INSTALLER_DIR/plugins"
mkdir -p "$PLUGIN_PKG_DIR"
PLUGIN_LIST_CSV="$PLUGIN_PKG_DIR/plugin-list.csv"
echo "plugin_package_path" > $PLUGIN_LIST_CSV
for PLUGIN_PKG in "${PLUGIN_PKGS[@]}"; do
    PLUGIN_URL="$PLUGINS_BUCKET_URL/v2.3.0/$PLUGIN_PKG"
    PLUGIN_PKG_FILE="$PLUGIN_PKG_DIR/$PLUGIN_PKG"
    echo -e "\nFetching from $PLUGIN_URL"
    curl -L $PLUGIN_URL -o $PLUGIN_PKG_FILE
    echo $PLUGIN_PKG_FILE >> $PLUGIN_LIST_CSV
done

sh `pwd`/configure-plugins.sh $wecube_host "$PLUGIN_INSTALLER_DIR/wecube-auto-master" $PLUGIN_PKG_DIR $plugin_mysql_pwd ${plugin_host}

echo -e "\nRegistering CMDB asset Ids..."
sh `pwd`/execute-sql-script-file.sh 

echo "Start install plugins success !"
#!/bin/bash

is_install_plugins=$1
wecube_host=$2
plugin_mysql_pwd=$3
wecube_home=${4:-/data/wecube}
plugin_db_host=$5
plugin_host=$6
wecube_host2=$7

source ./auto-run.cfg
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
echo -e "\nNow starting to launch plugins...\n"

PLUGINS_BUCKET_URL="https://wecube-plugins-1258470876.cos.ap-guangzhou.myqcloud.com"


PLUGIN_INSTALLER_DIR="$INSTALLER_DIR/wecube-plugin-installer"
mkdir -p "$PLUGIN_INSTALLER_DIR"

echo -e "\nFetching plugin packages...."
PLUGIN_PKG_DIR="$PLUGIN_INSTALLER_DIR/plugins"
mkdir -p "$PLUGIN_PKG_DIR"
PLUGIN_LIST_CSV="$PLUGIN_PKG_DIR/plugin-list.csv"
echo "plugin_package_path" > $PLUGIN_LIST_CSV


#run wecmdb
sh download-plugin.sh "$PLUGINS_BUCKET_URL/$WECUBE_VERSION" $PKG_WECMDB ${PLUGIN_PKG_DIR} $PLUGIN_LIST_CSV
#run qcloud
sh download-plugin.sh "$PLUGINS_BUCKET_URL/$WECUBE_VERSION" $PKG_QCLOUD ${PLUGIN_PKG_DIR} $PLUGIN_LIST_CSV
#run qcloud
sh download-plugin.sh "$PLUGINS_BUCKET_URL/$WECUBE_VERSION" $PKG_SALTSTACK ${PLUGIN_PKG_DIR} $PLUGIN_LIST_CSV
#run notifications
sh download-plugin.sh "$PLUGINS_BUCKET_URL/$WECUBE_VERSION" $PKG_NOTIFICATIONS ${PLUGIN_PKG_DIR} $PLUGIN_LIST_CSV
#run monitor
sh download-plugin.sh "$PLUGINS_BUCKET_URL/$WECUBE_VERSION" $PKG_MONITOR ${PLUGIN_PKG_DIR} $PLUGIN_LIST_CSV
#run artifacts
sh download-plugin.sh "$PLUGINS_BUCKET_URL/$WECUBE_VERSION" $PKG_ARTIFACTS ${PLUGIN_PKG_DIR} $PLUGIN_LIST_CSV
#run service-mgmt
sh download-plugin.sh "$PLUGINS_BUCKET_URL/$WECUBE_VERSION" $PKG_SERVICE_MGMT ${PLUGIN_PKG_DIR} $PLUGIN_LIST_CSV


sh `pwd`/configure-plugins.sh $wecube_host "wecube-auto-master" $PLUGIN_PKG_DIR $plugin_mysql_pwd ${plugin_host} ${wecube_host2}

echo -e "\nRegistering CMDB asset Ids..."
sh `pwd`/execute-sql-script-file.sh 

echo "Start install plugins success !"
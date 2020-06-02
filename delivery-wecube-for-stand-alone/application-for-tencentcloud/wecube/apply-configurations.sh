#!/bin/bash

set -e

CONFIG_FILE=$1
install_target_host=$2
mysql_password=$3
wecube_home=$4

[ ! -f $CONFIG_FILE ] && echo "Invalid configuration file: $CONFIG_FILE" && exit 1

sed -i "s~{{SINGLE_HOST}}~$install_target_host~g" $CONFIG_FILE
sed -i "s~{{SINGLE_PASSWORD}}~$mysql_password~g" $CONFIG_FILE
sed -i "s~{{WECUBE_HOME}}~$wecube_home~g" $CONFIG_FILE

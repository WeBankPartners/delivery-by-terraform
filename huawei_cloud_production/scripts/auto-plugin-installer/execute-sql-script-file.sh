#!/bin/bash

source ./db.cfg


sed -i "s~{{project_id}}~$project_id~g" $cmdb_sql_file

sed -i "s~{{az_master}}~$az_master~g" $cmdb_sql_file
sed -i "s~{{az_slave}}~$az_slave~g" $cmdb_sql_file

sed -i "s~{{wecube_vpc_asset_id}}~$wecube_vpc_asset_id~g" $cmdb_sql_file
sed -i "s~{{vpc_name}}~$vpc_name~g" $cmdb_sql_file

sed -i "s~{{security_group_asset_id}}~$security_group_asset_id~g" $cmdb_sql_file

sed -i "s~{{app1_subnet_asset_id}}~$app1_subnet_asset_id~g" $cmdb_sql_file
sed -i "s~{{app2_subnet_asset_id}}~$app2_subnet_asset_id~g" $cmdb_sql_file
sed -i "s~{{subnet_app1_name}}~$subnet_app1_name~g" $cmdb_sql_file
sed -i "s~{{subnet_app2_name}}~$subnet_app2_name~g" $cmdb_sql_file

sed -i "s~{{db1_subnet_asset_id}}~$db1_subnet_asset_id~g" $cmdb_sql_file
sed -i "s~{{db2_subnet_asset_id}}~$db2_subnet_asset_id~g" $cmdb_sql_file
sed -i "s~{{subnet_db1_name}}~$subnet_db1_name~g" $cmdb_sql_file
sed -i "s~{{subnet_db2_name}}~$subnet_db2_name~g" $cmdb_sql_file

sed -i "s~{{lb1_subnet_asset_id}}~$lb1_subnet_asset_id~g" $cmdb_sql_file
sed -i "s~{{lb2_subnet_asset_id}}~$lb2_subnet_asset_id~g" $cmdb_sql_file
sed -i "s~{{subnet_lb2_name}}~$subnet_lb2_name~g" $cmdb_sql_file
sed -i "s~{{subnet_lb1_name}}~$subnet_lb1_name~g" $cmdb_sql_file

sed -i "s~{{vdi_subnet_asset_id}}~$vdi_subnet_asset_id~g" $cmdb_sql_file
sed -i "s~{{proxy_subnet_asset_id}}~$proxy_subnet_asset_id~g" $cmdb_sql_file
sed -i "s~{{subnet_vdi_name}}~$subnet_vdi_name~g" $cmdb_sql_file
sed -i "s~{{subnet_proxy_name}}~$subnet_proxy_name~g" $cmdb_sql_file

sed -i "s~{{wecube_host1_id}}~$wecube_host1_id~g" $cmdb_sql_file
sed -i "s~{{wecube_host2_id}}~$wecube_host2_id~g" $cmdb_sql_file
sed -i "s~{{ecs_wecube_host1_name}}~$ecs_wecube_host1_name~g" $cmdb_sql_file
sed -i "s~{{ecs_wecube_host2_name}}~$ecs_wecube_host2_name~g" $cmdb_sql_file

sed -i "s~{{pluign_host1_id}}~$pluign_host1_id~g" $cmdb_sql_file
sed -i "s~{{pluign_host2_id}}~$pluign_host2_id~g" $cmdb_sql_file
sed -i "s~{{ecs_plugin_host1_name}}~$ecs_plugin_host1_name~g" $cmdb_sql_file
sed -i "s~{{ecs_plugin_host2_name}}~$ecs_plugin_host2_name~g" $cmdb_sql_file

sed -i "s~{{squid_host_id}}~$squid_host_id~g" $cmdb_sql_file
sed -i "s~{{vdi_host_id}}~$vdi_host_id~g" $cmdb_sql_file
sed -i "s~{{ecs_squid_name}}~$ecs_squid_name~g" $cmdb_sql_file
sed -i "s~{{ecs_vdi_name}}~$ecs_vdi_name~g" $cmdb_sql_file

sed -i "s~{{rdb_wecubecore_id}}~$rdb_wecubecore_id~g" $cmdb_sql_file
sed -i "s~{{rdb_wecubeplugin_id}}~$rdb_wecubeplugin_id~g" $cmdb_sql_file
sed -i "s~{{rds_core_name}}~$rds_core_name~g" $cmdb_sql_file
sed -i "s~{{rds_plugin_name}}~$rds_plugin_name~g" $cmdb_sql_file

yum install -y mysql

cat $cmdb_sql_file
mysql -h${plugin_mysql_host} -P${plugin_mysql_port} -u${mysql_user} -p${mysql_password} -Dwecmdb_embedded -e "source  $cmdb_sql_file"

cat $wecube_sql_script_file
mysql -h${wecube_mysql_host} -P${wecube_mysql_port} -u${mysql_user} -p${mysql_password} -Dwecube -e "source  $wecube_sql_script_file"
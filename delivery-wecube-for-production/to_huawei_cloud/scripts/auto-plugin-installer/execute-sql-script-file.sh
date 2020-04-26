#!/bin/bash

source ./db.cfg

sed -i "s~{{wecube_vpc_asset_id}}~$wecube_vpc_asset_id~g" $cmdb_sql_file
sed -i "s~{{security_group_asset_id}}~$security_group_asset_id~g" $cmdb_sql_file
sed -i "s~{{PRD1_MG_APP}}~$subnet_app_asset_id~g" $cmdb_sql_file
sed -i "s~{{PRD1_MG_RDB}}~$subnet_rdb_asset_id~g" $cmdb_sql_file
sed -i "s~{{PRD1_MG_VDI}}~$subnet_vdi_asset_id~g" $cmdb_sql_file
sed -i "s~{{PRD1_MG_PROXY}}~$subnet_proxy_asset_id~g" $cmdb_sql_file
sed -i "s~{{wecube_core_host_id}}~$wecube_core_host_id~g" $cmdb_sql_file
sed -i "s~{{pluign_host_id}}~$pluign_host_id~g" $cmdb_sql_file
sed -i "s~{{squid_host_id}}~$squid_host_id~g" $cmdb_sql_file
sed -i "s~{{vdi_host_id}}~$vdi_host_id~g" $cmdb_sql_file
sed -i "s~{{rdb_wecubecore}}~$rdb_wecube_id~g" $cmdb_sql_file
sed -i "s~{{rdb_wecubeplugin}}~$rdb_plugin_id~g" $cmdb_sql_file
sed -i "s~{{SG_RULE_PRD_SF_IN}}~$prd_sf_in~g" $cmdb_sql_file
sed -i "s~{{SG_RULE_PRD_SF_OUT}}~$prd_sf_out~g" $cmdb_sql_file
sed -i "s~{{SG_RULE_PRD_MG_IN}}~$prd_mg_in~g" $cmdb_sql_file
sed -i "s~{{SG_RULE_PRD_MG_OUT}}~$prd_mg_out~g" $cmdb_sql_file
sed -i "s~{{project_id}}~$project_id~g" $cmdb_sql_file


#sed -i "s~{{project_id}}~$project_id~g" $wecube_sql_script_file


yum install -y mysql
mysql -h${plugin_mysql_host} -P${plugin_mysql_port} -u${mysql_user} -p${mysql_password} -Dwecmdb_embedded -e "source  $cmdb_sql_file" 
mysql -h${wecube_mysql_host} -P${wecube_mysql_port} -u${mysql_user} -p${mysql_password} -Dwecube -e "source  $wecube_sql_script_file" 

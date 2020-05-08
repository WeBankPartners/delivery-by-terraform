SET NAMES utf8 ;
update `wecmdb_embedded`.`data_center` set location = 'Region={{region}}' where key_name = '{{region_name}}';
update `wecmdb_embedded`.`data_center` set location = 'Region={{region}};AvailableZone={{az_1}}' where key_name ='{{az_1_name}}';  
update `wecmdb_embedded`.`data_center` set location = 'Region={{region}};AvailableZone={{az_2}}' where key_name ='{{az_2_name}}';

update `wecmdb_embedded`.`network_segment` set vpc_asset_id= '{{wecube_vpc_asset_id}}' where key_name='{{vpc_name}}';
update `wecmdb_embedded`.`network_segment` set security_group_asset_id= '{{security_group_asset_id}}' where  key_name='{{vpc_name}}';
update `wecmdb_embedded`.`network_segment` set route_table_asset_id= '{{route_table_asset_id}}' where  key_name='{{vpc_name}}';

update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{app1_subnet_asset_id}}' where  key_name='{{subnet_app1_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{app2_subnet_asset_id}}' where  key_name='{{subnet_app2_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{db1_subnet_asset_id}}' where  key_name='{{subnet_db1_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{vdi_subnet_asset_id}}' where  key_name='{{subnet_vdi_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{proxy_subnet_asset_id}}' where  key_name='{{subnet_proxy_name}}';

update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{wecube_host1_id}}' where  key_name='{{ecs_wecube_host1_name}}';
update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{wecube_host2_id}}' where  key_name='{{ecs_wecube_host2_name}}';

update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{pluign_host1_id}}' where  key_name='{{ecs_plugin_host1_name}}';
update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{pluign_host2_id}}' where  key_name='{{ecs_plugin_host2_name}}';

update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{squid_host_id}}' where  key_name='{{ecs_squid_name}}';
update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{vdi_host_id}}' where  key_name='{{ecs_vdi_name}}';

update `wecmdb_embedded`.`rdb_resource_instance` set asset_id= '{{rdb_wecubecore_id}}',ip_address='{{rdb_wecubecore_ip}}' where  key_name='{{rds_core_name}}';
update `wecmdb_embedded`.`rdb_resource_instance` set asset_id= '{{rdb_wecubeplugin_id}}',ip_address='{{rdb_wecubeplugin_ip}}' where  key_name='{{rds_plugin_name}}';

update `wecmdb_embedded`.`lb_resource_instance` set asset_id= '{{lb1_asset_id}}',ip_address='{{lb1_ip}}'  where  key_name='{{lb1_name}}';
update `wecmdb_embedded`.`lb_resource_instance` set asset_id= '{{lb2_asset_id}}',ip_address='{{lb2_ip}}'  where  key_name='{{lb2_name}}';


SET NAMES utf8 ;
update `wecmdb_embedded`.`data_center` set location = 'CloudApiDomainName=myhuaweicloud.com;Region=ap-southeast-3;ProjectId={{project_id}}' where key_name in ('PRD','PRD1','PRD2');

update `wecmdb_embedded`.`data_center` set available_zone= '{{az_master}}' where  key_name='PRD1';
update `wecmdb_embedded`.`data_center` set available_zone= '{{az_slave}}' where  key_name='PRD2';

update `wecmdb_embedded`.`network_segment` set vpc_asset_id= '{{wecube_vpc_asset_id}}' where name='{{vpc_name}}';
update `wecmdb_embedded`.`network_segment` set security_group_asset_id= '{{security_group_asset_id}}' where  name='{{vpc_name}}';

update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{app1_subnet_asset_id}}' where  name='{{subnet_app1_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{app2_subnet_asset_id}}' where  name='{{subnet_app2_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{db1_subnet_asset_id}}' where  name='{{subnet_db1_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{db2_subnet_asset_id}}' where  name='{{subnet_db2_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{lb1_subnet_asset_id}}' where  name='{{subnet_lb1_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{lb2_subnet_asset_id}}' where  name='{{subnet_lb2_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{vdi_subnet_asset_id}}' where  name='{{subnet_vdi_name}}';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{proxy_subnet_asset_id}}' where  name='{{subnet_proxy_name}}';

update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{wecube_host1_id}}' where  name='{{ecs_wecube_host1_name}}';
update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{wecube_host2_id}}' where  name='{{ecs_wecube_host2_name}}';

update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{pluign_host1_id}}' where  name='{{ecs_plugin_host1_name}}';
update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{pluign_host2_id}}' where  name='{{ecs_plugin_host2_name}}';

update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{squid_host_id}}' where  name='{{ecs_squid_name}}';
update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{vdi_host_id}}' where  name='{{ecs_vdi_name}}';

update `wecmdb_embedded`.`rdb_resource_instance` set asset_id= '{{rdb_wecubecore_id}}' where  name='{{rds_core_name}}';
update `wecmdb_embedded`.`rdb_resource_instance` set asset_id= '{{rdb_wecubeplugin_id}}' where  name='{{rds_plugin_name}}';

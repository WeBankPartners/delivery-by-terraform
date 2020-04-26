SET NAMES utf8 ;
update `wecmdb_embedded`.`data_center` set location = 'CloudApiDomainName=myhuaweicloud.com;Region=ap-southeast-3;ProjectId={{project_id}}' where  key_name in ('PRD','PRD1','PRD2');

update `wecmdb_embedded`.`data_center` set available_zone= 'ap-southeast-3a' where  key_name='PRD1';
update `wecmdb_embedded`.`data_center` set available_zone= 'ap-southeast-3b' where  key_name='PRD2';

update `wecmdb_embedded`.`network_segment` set vpc_asset_id= '{{wecube_vpc_asset_id}}' where  name='PRD_MG';
update `wecmdb_embedded`.`network_segment` set security_group_asset_id= '{{security_group_asset_id}}' where  name='PRD_MG';

update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{PRD1_MG_APP}}' where  name='PRD1_MG_APP';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{PRD1_MG_RDB}}' where  name='PRD1_MG_RDB';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{PRD1_MG_VDI}}' where  name='PRD1_MG_VDI';
update `wecmdb_embedded`.`network_segment` set subnet_asset_id= '{{PRD1_MG_PROXY}}' where  name='PRD1_MG_PROXY';

update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{wecube_core_host_id}}' where  name='wecubecore1';
update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{pluign_host_id}}' where  name='wecubeplugin1';
update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{squid_host_id}}' where  name='wecubesquid1';
update `wecmdb_embedded`.`host_resource_instance` set asset_id= '{{vdi_host_id}}' where  name='wecubevdi1';
update `wecmdb_embedded`.`rdb_resource_instance` set asset_id= '{{rdb_wecubecore}}' where  name='wecubecore';
update `wecmdb_embedded`.`rdb_resource_instance` set asset_id= '{{rdb_wecubeplugin}}' where  name='wecubeplugin';

update `wecmdb_embedded`.`default_security_policy` set security_policy_asset_id= '{{SG_RULE_PRD_SF_IN}}' where  key_name='PRD_MG ACCEPT PRD_SF ingress 1-65535';
update `wecmdb_embedded`.`default_security_policy` set security_policy_asset_id= '{{SG_RULE_PRD_SF_OUT}}' where  key_name='PRD_MG ACCEPT PRD_SF egress 1-65535';
update `wecmdb_embedded`.`default_security_policy` set security_policy_asset_id= '{{SG_RULE_PRD_MG_IN}}' where  key_name='PRD_MG ACCEPT PRD_MG ingress 1-65535';
update `wecmdb_embedded`.`default_security_policy` set security_policy_asset_id= '{{SG_RULE_PRD_MG_OUT}}' where  key_name='PRD_MG ACCEPT PRD_MG egress 1-65535';
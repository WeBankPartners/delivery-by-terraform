SET NAMES utf8 ;

UPDATE `network_segment` SET `vpc_asset_id`='${wecube_vpc_asset_id}' WHERE `name`='GZP_MGMT';

UPDATE `network_segment` SET `route_table_asset_id`='${wecube_route_table_asset_id}' WHERE `name`='GZP_MGMT';

UPDATE `network_segment` SET `subnet_asset_id`='${wecube_subnet_asset_id}' WHERE `name`='GZP2_MGMT_MT_APP';

UPDATE `host_resource_instance` SET `asset_id`='${wecube_host_asset_id}' WHERE `code`='host2_10.128.202.3';

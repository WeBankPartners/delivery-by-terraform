SET NAMES utf8 ;

UPDATE `network_segment`
SET `vpc_asset_id`='${WECUBE_VPC_ASSET_ID}',
    `route_table_asset_id`='${WECUBE_ROUTE_TABLE_ASSET_ID}',
    `security_group_asset_id`='${WECUBE_SECURITY_GROUP_ASSET_ID}'
WHERE `name`='TX_BJ_PRD_MGMT';

UPDATE `network_segment` SET `route_table_asset_id`='${WECUBE_ROUTE_TABLE_ASSET_ID}' WHERE `name`='TX_BJ_PRD_MGMT';

UPDATE `network_segment` SET `subnet_asset_id`='${WECUBE_SUBNET_ASSET_ID}' WHERE `name`='TX_BJ_PRD1_MGMT_APP';

UPDATE `host_resource_instance` SET `asset_id`='${WECUBE_HOST_ASSET_ID}' WHERE `name`='txbjwecubehost';

UPDATE `host_resource_instance` SET `ip_address`='${HOST_PRIVATE_IP}' WHERE `name`='txbjwecubehost';

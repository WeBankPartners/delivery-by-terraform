SET NAMES utf8 ;

UPDATE `network_segment`
   SET `vpc_asset_id`='${WECUBE_VPC_ASSET_ID}',
       `route_table_asset_id`='${WECUBE_ROUTE_TABLE_ASSET_ID}',
       `security_group_asset_id`='${WECUBE_SECURITY_GROUP_ASSET_ID}'
 WHERE `name`='${WECUBE_VPC_ASSET_NAME}';

UPDATE `network_segment`
   SET `subnet_asset_id`='${WECUBE_SUBNET_ASSET_ID}'
 WHERE `name`='${WECUBE_SUBNET_ASSET_NAME}';

UPDATE `host_resource_instance`
   SET `asset_id`='${WECUBE_HOST_ASSET_ID}',
       `ip_address`='${HOST_PRIVATE_IP}'
 WHERE `name`='${WECUBE_HOST_ASSET_NAME}';

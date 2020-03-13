SET NAMES utf8 ;

UPDATE `system_variables` SET `value`='{{S3_URL}}'
WHERE `id`='system__global__S3_SERVER_URL' AND `name`='S3_SERVER_URL';

UPDATE `system_variables` SET `value`='http://{{GATEWAY_HOST}}:{{GATEWAY_PORT}}'
WHERE `id`='system__global__CORE_ADDR' AND `name`='CORE_ADDR';

UPDATE `system_variables` SET `value`='{{WECUBE_HOME}}'
WHERE `id`='system__global__BASE_MOUNT_PATH' AND `name`='BASE_MOUNT_PATH';

UPDATE `resource_server` SET `host`='{{WECUBE_PLUGIN_HOSTS}}', `port`='{{WECUBE_PLUGIN_HOST_PORT}}'
WHERE `id`='10.128.202.3__docker__containerHost' AND `name`='containerHost';

UPDATE `resource_server` SET `host`='{{MYSQL_SERVER_ADDR}}', `port`='{{MYSQL_SERVER_PORT}}'
WHERE `id`='10.128.202.3__mysql__mysqlHost' AND `name`='mysqlHost';

UPDATE `resource_server` SET `host`='{{S3_HOST}}', `port`='{{S3_PORT}}'
WHERE `id`='10.128.202.3__s3__s3Host' AND `name`='s3Host';

SET NAMES utf8 ;


UPDATE `system_variables`
   SET `value`='${WECUBE_HOME}'
 WHERE `id`='system__global__BASE_MOUNT_PATH'
   AND `name`='BASE_MOUNT_PATH';

UPDATE `system_variables`
   SET `value`='http://${S3_HOST}:9000'
 WHERE `id`='system__global__S3_SERVER_URL'
   AND `name`='S3_SERVER_URL';

UPDATE `system_variables`
   SET `value`='http://${PORTAL_HOST}:19090'
 WHERE `id`='system__global__CORE_ADDR'
   AND `name`='CORE_ADDR';

UPDATE `system_variables`
   SET `value`='http://${PORTAL_HOST}:19110'
 WHERE `id`='system__global__GATEWAY_URL'
   AND `name`='GATEWAY_URL';

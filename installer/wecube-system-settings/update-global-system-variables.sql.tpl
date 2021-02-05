SET NAMES utf8 ;


UPDATE `system_variables`
   SET `value`='${WECUBE_PLUGIN_BASE_MOUNT_PATH}'
 WHERE `id`='system__global__BASE_MOUNT_PATH'
   AND `name`='BASE_MOUNT_PATH';

UPDATE `system_variables`
   SET `value`='http://${S3_HOST}:9000'
 WHERE `id`='system__global__S3_SERVER_URL'
   AND `name`='S3_SERVER_URL';

UPDATE `system_variables`
   SET `value`='http://${GATEWAY_ENTRYPOINT}:19110'
 WHERE `id`='system__global__GATEWAY_URL'
   AND `name`='GATEWAY_URL';

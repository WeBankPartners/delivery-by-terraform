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
   SET `value`='http://${PORTAL_HOST}:19090'
 WHERE `id`='system__global__GATEWAY_URL'
   AND `name`='GATEWAY_URL';


INSERT INTO `resource_server`
            (
              `id`,
              `created_by`,
              `created_date`,
              `host`,
              `is_allocated`,
              `login_password`,
              `login_username`,
              `name`,
              `port`,
              `purpose`,
              `status`,
              `type`,
              `updated_by`,
              `updated_date`
            )
     VALUES (
              '${PLUGIN_DB_HOST}__mysql__mysqlHost',
              'umadmin',
              '${DATE_TIME}',
              '${PLUGIN_DB_HOST}',
              1,
              'eNgy+i8zfJOUHeCS3te+UA==',
              'root',
              'mysqlHost',
              '${PLUGIN_DB_PORT}',
              'ss',
              'active',
              'mysql',
              'umadmin',
              '${DATE_TIME}'
            );

INSERT INTO `resource_server`
            (
              `id`,
              `created_by`,
              `created_date`,
              `host`,
              `is_allocated`,
              `login_password`,
              `login_username`,
              `name`,
              `port`,
              `purpose`,
              `status`,
              `type`,
              `updated_by`,
              `updated_date`
            )
     VALUES (
              '${S3_HOST}__s3__s3Host',
              'umadmin',
              '${DATE_TIME}',
              '${S3_HOST}',
              1,
              'CqXwzhKmoPOTssB6JUrEOw==',
              'access_key',
              's3Host',
              '9000',
              'ss',
              'active',
              's3',
              'umadmin',
              '${DATE_TIME}'
            );

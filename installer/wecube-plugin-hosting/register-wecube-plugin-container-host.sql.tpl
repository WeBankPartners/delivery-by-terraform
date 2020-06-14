SET NAMES utf8 ;

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
              '${HOST_PRIVATE_IP}__docker__containerHost',
              'umadmin',
              '${DATE_TIME}',
              '${HOST_PRIVATE_IP}',
              1,
              'eB/+3lIm55fJdG3XX9l03w==',
              'root',
              'containerHost',
              '22',
              'Plugins hosting',
              'active',
              'docker',
              'umadmin',
              '${DATE_TIME}'
            );

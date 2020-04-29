SET NAMES utf8 ;

SET FOREIGN_KEY_CHECKS = 0;

delete from menu_items;
insert into menu_items (id,parent_code,code,source,menu_order,description,local_display_name) values
('JOBS',null,'JOBS','SYSTEM', 1, '', '任务')
,('DESIGNING',null,'DESIGNING','SYSTEM', 2, '', '设计')
,('IMPLEMENTATION',null,'IMPLEMENTATION','SYSTEM', 3, '', '执行')
,('MONITORING',null,'MONITORING','SYSTEM', 4, '', '监测')
,('ADJUSTMENT',null,'ADJUSTMENT','SYSTEM', 5, '', '调整')
,('INTELLIGENCE_OPS',null,'INTELLIGENCE_OPS','SYSTEM', 6, '', '智慧')
,('COLLABORATION',null,'COLLABORATION','SYSTEM', 7, '', '协同')
,('ADMIN',null,'ADMIN','SYSTEM', 8, '', '系统')
,('IMPLEMENTATION__IMPLEMENTATION_WORKFLOW_EXECUTION','IMPLEMENTATION','IMPLEMENTATION_WORKFLOW_EXECUTION','SYSTEM', 9, '', '任务编排执行')
,('COLLABORATION__COLLABORATION_PLUGIN_MANAGEMENT','COLLABORATION','COLLABORATION_PLUGIN_MANAGEMENT','SYSTEM', 10, '', '插件注册')
,('COLLABORATION__COLLABORATION_WORKFLOW_ORCHESTRATION','COLLABORATION','COLLABORATION_WORKFLOW_ORCHESTRATION','SYSTEM', 11, '', '任务编排')
,('ADMIN__ADMIN_SYSTEM_PARAMS','ADMIN','ADMIN_SYSTEM_PARAMS','SYSTEM', 12, '', '系统参数')
,('ADMIN__ADMIN_RESOURCES_MANAGEMENT','ADMIN','ADMIN_RESOURCES_MANAGEMENT','SYSTEM', 13, '', '资源管理')
,('ADMIN__ADMIN_USER_ROLE_MANAGEMENT', 'ADMIN', 'ADMIN_USER_ROLE_MANAGEMENT', 'SYSTEM', 14, '', '用户管理')
,('IMPLEMENTATION__IMPLEMENTATION_BATCH_EXECUTION', 'IMPLEMENTATION', 'IMPLEMENTATION_BATCH_EXECUTION', 'SYSTEM', 15, '', '批量执行');

delete from role_menu;
insert into role_menu (id, role_name, menu_code) values
('SUPER_ADMIN__IMPLEMENTATION_WORKFLOW_EXECUTION','SUPER_ADMIN','IMPLEMENTATION_WORKFLOW_EXECUTION'),
('SUPER_ADMIN__COLLABORATION_PLUGIN_MANAGEMENT','SUPER_ADMIN','COLLABORATION_PLUGIN_MANAGEMENT'),
('SUPER_ADMIN__COLLABORATION_WORKFLOW_ORCHESTRATION','SUPER_ADMIN','COLLABORATION_WORKFLOW_ORCHESTRATION'),
('SUPER_ADMIN__ADMIN_SYSTEM_PARAMS','SUPER_ADMIN','ADMIN_SYSTEM_PARAMS'),
('SUPER_ADMIN__ADMIN_RESOURCES_MANAGEMENT','SUPER_ADMIN','ADMIN_RESOURCES_MANAGEMENT'),
('SUPER_ADMIN__ADMIN_USER_ROLE_MANAGEMENT','SUPER_ADMIN','ADMIN_USER_ROLE_MANAGEMENT'),
('SUPER_ADMIN__IMPLEMENTATION_BATCH_EXECUTION','SUPER_ADMIN','IMPLEMENTATION_BATCH_EXECUTION');


INSERT INTO `system_variables` (`id`,`package_name`, `name`, `value`, `default_value`, `scope`, `source`, `status`) VALUES ('system__global__S3_SERVER_URL', NULL, 'S3_SERVER_URL', NULL, 'http://{{S3_1_RESOURCE_SERVER_IP}}:9001', 'global', 'system', 'active');
INSERT INTO `system_variables` (`id`,`package_name`, `name`, `value`, `default_value`, `scope`, `source`, `status`) VALUES ('system__global__S3_ACCESS_KEY', NULL, 'S3_ACCESS_KEY', NULL, 'access_key', 'global', 'system', 'active');
INSERT INTO `system_variables` (`id`,`package_name`, `name`, `value`, `default_value`, `scope`, `source`, `status`) VALUES ('system__global__S3_SECRET_KEY', NULL, 'S3_SECRET_KEY', NULL, 'secret_key', 'global', 'system', 'active');
INSERT INTO `system_variables` (`id`,`package_name`, `name`, `value`, `default_value`, `scope`, `source`, `status`) VALUES ('system__global__CORE_ADDR', NULL, 'CORE_ADDR', NULL, 'http://{{GATEWAY_IP}}:19110', 'global', 'system', 'active');
INSERT INTO `system_variables` (`id`,`package_name`, `name`, `value`, `default_value`, `scope`, `source`, `status`) VALUES ('system__global__BASE_MOUNT_PATH', NULL, 'BASE_MOUNT_PATH', NULL, '/data', 'global', 'system', 'active');
INSERT INTO `system_variables` (`id`,`package_name`, `name`, `value`, `default_value`, `scope`, `source`, `status`) VALUES ('system__global__ENCRYPT_SEED', NULL, 'ENCRYPT_SEED', NULL, 'seed-wecube2.1-2020', 'global', 'system', 'active');
INSERT INTO `system_variables` (`id`,`package_name`, `name`, `value`, `default_value`, `scope`, `source`, `status`) VALUES ('system__global__CALLBACK_URL', NULL, 'CALLBACK_URL', NULL, '/platform/v1/process/instances/callback', 'global', 'system', 'active');
INSERT INTO `system_variables` (`id`,`package_name`, `name`, `value`, `default_value`, `scope`, `source`, `status`) VALUES ('global__GATEWAY_URL', NULL, 'GATEWAY_URL', NULL, 'http://{{GATEWAY_IP}}:19110', 'global', 'system', 'active');


INSERT INTO `resource_server` (`id`,`created_by`, `created_date`, `host`, `is_allocated`, `login_password`, `login_username`, `name`, `port`, `purpose`, `status`, `type`, `updated_by`,`updated_date`) VALUES ('{{MYSQL_RESOURCE_SERVER_IP}}__mysql__mysqlHost','umadmin','2020-01-21 12:37:03','{{MYSQL_RESOURCE_SERVER_IP}}',1,'eNgy+i8zfJOUHeCS3te+UA==','root','mysqlHost','3306','ss','active','mysql','umadmin','2020-01-21 12:37:03');
INSERT INTO `resource_server` (`id`,`created_by`, `created_date`, `host`, `is_allocated`, `login_password`, `login_username`, `name`, `port`, `purpose`, `status`, `type`, `updated_by`,`updated_date`) VALUES ('{{DOCKER1_RESOURCE_SERVER_IP}}__docker__containerHost','umadmin','2020-01-21 12:36:00','{{DOCKER1_RESOURCE_SERVER_IP}}',1,'eB/+3lIm55fJdG3XX9l03w==','root','containerHost','22','ss','active','docker','umadmin','2020-01-21 12:36:00');
INSERT INTO `resource_server` (`id`,`created_by`, `created_date`, `host`, `is_allocated`, `login_password`, `login_username`, `name`, `port`, `purpose`, `status`, `type`, `updated_by`,`updated_date`) VALUES ('{{S3_1_RESOURCE_SERVER_IP}}__s3__s3Host','umadmin','2020-01-21 14:10:31','{{S3_1_RESOURCE_SERVER_IP}}',1,'CqXwzhKmoPOTssB6JUrEOw==','access_key','s3Host','9001','ss','active','s3','umadmin','2020-01-21 14:10:31');
INSERT INTO `resource_server` (`id`,`created_by`, `created_date`, `host`, `is_allocated`, `login_password`, `login_username`, `name`, `port`, `purpose`, `status`, `type`, `updated_by`,`updated_date`) VALUES ('{{DOCKER2_RESOURCE_SERVER_IP}}__docker__containerHost','umadmin','2020-01-21 12:36:00','{{DOCKER2_RESOURCE_SERVER_IP}}',1,'eB/+3lIm55fJdG3XX9l03w==','root','containerHost','22','ss','active','docker','umadmin','2020-01-21 12:36:00');
INSERT INTO `resource_server` (`id`,`created_by`, `created_date`, `host`, `is_allocated`, `login_password`, `login_username`, `name`, `port`, `purpose`, `status`, `type`, `updated_by`,`updated_date`) VALUES ('{{S3_2_RESOURCE_SERVER_IP}}__s3__s3Host','umadmin','2020-01-21 14:10:31','{{S3_2_RESOURCE_SERVER_IP}}',1,'CqXwzhKmoPOTssB6JUrEOw==','access_key','s3Host','9001','ss','active','s3','umadmin','2020-01-21 14:10:31');

SET FOREIGN_KEY_CHECKS = 1;

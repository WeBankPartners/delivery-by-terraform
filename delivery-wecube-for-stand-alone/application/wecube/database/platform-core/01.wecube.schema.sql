SET NAMES utf8 ;

SET FOREIGN_KEY_CHECKS = 0;

--
-- Table structure for table `batch_execution_jobs`
--

DROP TABLE IF EXISTS `batch_execution_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `batch_execution_jobs` (
  `id` varchar(255) NOT NULL,
  `create_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `complete_timestamp` timestamp NULL DEFAULT NULL,
  `creator` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blob_data`
--

DROP TABLE IF EXISTS `blob_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `blob_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` longblob,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_operation_event`
--

DROP TABLE IF EXISTS `core_operation_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `core_operation_event` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `event_seq_no` varchar(255) DEFAULT NULL,
  `event_type` varchar(255) DEFAULT NULL,
  `is_notified` bit(1) DEFAULT NULL,
  `notify_endpoint` varchar(255) DEFAULT NULL,
  `is_notify_required` bit(1) DEFAULT NULL,
  `oper_data` varchar(255) DEFAULT NULL,
  `oper_key` varchar(255) DEFAULT NULL,
  `oper_user` varchar(255) DEFAULT NULL,
  `proc_def_id` varchar(255) DEFAULT NULL,
  `proc_inst_id` varchar(255) DEFAULT NULL,
  `src_sub_system` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `proc_inst_key` varchar(255) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_re_proc_def_info`
--

DROP TABLE IF EXISTS `core_re_proc_def_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `core_re_proc_def_info` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `active` bit(1) DEFAULT NULL,
  `rev` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `proc_def_data` text,
  `proc_def_data_fmt` varchar(255) DEFAULT NULL,
  `proc_def_kernel_id` varchar(255) DEFAULT NULL,
  `proc_def_key` varchar(255) DEFAULT NULL,
  `proc_def_name` varchar(255) DEFAULT NULL,
  `proc_def_ver` int(11) DEFAULT NULL,
  `root_entity` varchar(255) DEFAULT NULL,
  `is_deleted` bit(1) DEFAULT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `owner_grp` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_re_task_node_def_info`
--

DROP TABLE IF EXISTS `core_re_task_node_def_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `core_re_task_node_def_info` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `active` bit(1) DEFAULT NULL,
  `rev` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `node_id` varchar(255) DEFAULT NULL,
  `node_name` varchar(255) DEFAULT NULL,
  `node_type` varchar(255) DEFAULT NULL,
  `ordered_no` varchar(255) DEFAULT NULL,
  `prev_node_ids` varchar(255) DEFAULT NULL,
  `proc_def_id` varchar(255) DEFAULT NULL,
  `proc_def_kernel_id` varchar(255) DEFAULT NULL,
  `proc_def_key` varchar(255) DEFAULT NULL,
  `proc_def_ver` int(11) DEFAULT NULL,
  `routine_exp` varchar(255) DEFAULT NULL,
  `routine_raw` varchar(255) DEFAULT NULL,
  `service_id` varchar(255) DEFAULT NULL,
  `service_name` varchar(255) DEFAULT NULL,
  `succeed_node_ids` varchar(255) DEFAULT NULL,
  `timeout_exp` varchar(255) DEFAULT NULL,
  `task_category` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_re_task_node_param`
--

DROP TABLE IF EXISTS `core_re_task_node_param`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `core_re_task_node_param` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `active` bit(1) DEFAULT NULL,
  `rev` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `bind_node_id` varchar(255) DEFAULT NULL,
  `bind_param_name` varchar(255) DEFAULT NULL,
  `bind_param_type` varchar(255) DEFAULT NULL,
  `node_id` varchar(255) DEFAULT NULL,
  `param_name` varchar(255) DEFAULT NULL,
  `proc_def_id` varchar(255) DEFAULT NULL,
  `task_node_def_id` varchar(255) DEFAULT NULL,
  `bind_type` varchar(255) DEFAULT NULL,
  `bind_val` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_ru_proc_exec_binding`
--

DROP TABLE IF EXISTS `core_ru_proc_exec_binding`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `core_ru_proc_exec_binding` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `bind_type` varchar(255) DEFAULT NULL,
  `entity_id` varchar(255) DEFAULT NULL,
  `node_def_id` varchar(255) DEFAULT NULL,
  `proc_def_id` varchar(255) DEFAULT NULL,
  `proc_inst_id` int(11) DEFAULT NULL,
  `task_node_inst_id` int(11) DEFAULT NULL,
  `entity_data_id` varchar(255) DEFAULT NULL,
  `entity_type_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=999 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_ru_proc_inst_info`
--

DROP TABLE IF EXISTS `core_ru_proc_inst_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `core_ru_proc_inst_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `oper` varchar(255) DEFAULT NULL,
  `oper_grp` varchar(255) DEFAULT NULL,
  `rev` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `proc_def_id` varchar(255) DEFAULT NULL,
  `proc_def_key` varchar(255) DEFAULT NULL,
  `proc_def_name` varchar(255) DEFAULT NULL,
  `proc_inst_kernel_id` varchar(255) DEFAULT NULL,
  `proc_inst_key` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=152 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_ru_proc_role_binding`
--

DROP TABLE IF EXISTS `core_ru_proc_role_binding`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `core_ru_proc_role_binding` (
  `id` varchar(255) NOT NULL,
  `proc_id` varchar(255) NOT NULL,
  `role_id` varchar(255) DEFAULT NULL,
  `permission` varchar(255) NOT NULL,
  `role_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_ru_task_node_exec_param`
--

DROP TABLE IF EXISTS `core_ru_task_node_exec_param`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `core_ru_task_node_exec_param` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `obj_id` varchar(255) DEFAULT NULL,
  `param_data_type` varchar(255) DEFAULT NULL,
  `param_data_value` varchar(10255) DEFAULT NULL,
  `param_name` varchar(255) DEFAULT NULL,
  `param_type` varchar(255) DEFAULT NULL,
  `req_id` varchar(255) DEFAULT NULL,
  `root_entity_id` varchar(255) DEFAULT NULL,
  `entity_data_id` varchar(255) DEFAULT NULL,
  `entity_type_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36600 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_ru_task_node_exec_req`
--

DROP TABLE IF EXISTS `core_ru_task_node_exec_req`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `core_ru_task_node_exec_req` (
  `req_id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `is_completed` bit(1) DEFAULT NULL,
  `is_current` bit(1) DEFAULT NULL,
  `err_code` varchar(255) DEFAULT NULL,
  `err_msg` varchar(255) DEFAULT NULL,
  `node_inst_id` int(11) DEFAULT NULL,
  `req_url` varchar(255) DEFAULT NULL,
  `execution_id` varchar(255) DEFAULT NULL,
  `node_id` varchar(255) DEFAULT NULL,
  `node_name` varchar(255) DEFAULT NULL,
  `proc_def_kernel_id` varchar(255) DEFAULT NULL,
  `proc_def_kernel_key` varchar(255) DEFAULT NULL,
  `proc_def_ver` int(11) DEFAULT NULL,
  `proc_inst_kernel_id` varchar(255) DEFAULT NULL,
  `proc_inst_kernel_key` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`req_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `core_ru_task_node_inst_info`
--

DROP TABLE IF EXISTS `core_ru_task_node_inst_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `core_ru_task_node_inst_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `oper` varchar(255) DEFAULT NULL,
  `oper_grp` varchar(255) DEFAULT NULL,
  `rev` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `node_def_id` varchar(255) DEFAULT NULL,
  `node_id` varchar(255) DEFAULT NULL,
  `node_name` varchar(255) DEFAULT NULL,
  `node_type` varchar(255) DEFAULT NULL,
  `ordered_no` varchar(255) DEFAULT NULL,
  `proc_def_id` varchar(255) DEFAULT NULL,
  `proc_def_key` varchar(255) DEFAULT NULL,
  `proc_inst_id` int(11) DEFAULT NULL,
  `proc_inst_key` varchar(255) DEFAULT NULL,
  `err_msg` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1195 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `execution_job_parameters`
--

DROP TABLE IF EXISTS `execution_job_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `execution_job_parameters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `execution_job_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `data_type` varchar(50) NOT NULL,
  `mapping_type` varchar(50) DEFAULT NULL,
  `mapping_entity_expression` varchar(1024) DEFAULT NULL,
  `mapping_system_variable_name` varchar(500) DEFAULT NULL,
  `required` varchar(5) DEFAULT NULL,
  `constant_value` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_execution_job_parameters_execution_jobs` (`execution_job_id`),
  CONSTRAINT `FK_execution_job_parameters_execution_jobs` FOREIGN KEY (`execution_job_id`) REFERENCES `execution_jobs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `execution_jobs`
--

DROP TABLE IF EXISTS `execution_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `execution_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_execution_job_id` varchar(255) NOT NULL,
  `package_name` varchar(63) NOT NULL,
  `entity_name` varchar(100) NOT NULL,
  `business_key` varchar(255) NOT NULL,
  `root_entity_id` varchar(255) NOT NULL,
  `execute_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `complete_time` timestamp NULL DEFAULT NULL,
  `error_code` varchar(1) DEFAULT NULL,
  `error_message` text,
  `return_json` longtext,
  `plugin_config_interface_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_id_and_root_entity_id` (`batch_execution_job_id`,`root_entity_id`),
  CONSTRAINT `FK534bth9hibanrjd5fqdel8u9c` FOREIGN KEY (`batch_execution_job_id`) REFERENCES `batch_execution_jobs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `menu_items`
--

DROP TABLE IF EXISTS `menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `menu_items` (
  `id` varchar(255) NOT NULL,
  `parent_code` varchar(64) DEFAULT NULL,
  `code` varchar(64) NOT NULL,
  `source` varchar(255) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `local_display_name` varchar(200) DEFAULT NULL,
  `menu_order` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`),
  KEY `menu_item_order` (`menu_order`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_config_interface_parameters`
--

DROP TABLE IF EXISTS `plugin_config_interface_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_config_interface_parameters` (
  `id` varchar(255) NOT NULL,
  `plugin_config_interface_id` varchar(255) NOT NULL,
  `type` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `data_type` varchar(50) NOT NULL,
  `mapping_type` varchar(50) DEFAULT NULL,
  `mapping_entity_expression` varchar(1024) DEFAULT NULL,
  `mapping_system_variable_name` varchar(500) DEFAULT NULL,
  `required` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKcts32sje8a1dru05ge28rmk2l` (`plugin_config_interface_id`),
  CONSTRAINT `FKcts32sje8a1dru05ge28rmk2l` FOREIGN KEY (`plugin_config_interface_id`) REFERENCES `plugin_config_interfaces` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_config_interfaces`
--

DROP TABLE IF EXISTS `plugin_config_interfaces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_config_interfaces` (
  `id` varchar(255) NOT NULL,
  `plugin_config_id` varchar(255) NOT NULL,
  `action` varchar(100) NOT NULL,
  `service_name` varchar(500) NOT NULL,
  `service_display_name` varchar(500) NOT NULL,
  `path` varchar(500) NOT NULL,
  `http_method` varchar(10) NOT NULL,
  `is_async_processing` varchar(1) DEFAULT 'N',
  `type` varchar(16) DEFAULT 'EXECUTION',
  `filter_rule` VARCHAR(1024) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK6rev06d32q4yhjn77cv2bsy1u` (`plugin_config_id`),
  CONSTRAINT `FK6rev06d32q4yhjn77cv2bsy1u` FOREIGN KEY (`plugin_config_id`) REFERENCES `plugin_configs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_configs`
--

DROP TABLE IF EXISTS `plugin_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_configs` (
  `id` varchar(255) NOT NULL,
  `plugin_package_id` varchar(255) NOT NULL,
  `name` varchar(100) NOT NULL,
  `target_package` varchar(63) DEFAULT NULL,
  `target_entity` varchar(100) DEFAULT NULL,
  `target_entity_filter_rule` VARCHAR(1024) NULL,
  `register_name` varchar(100) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'DISABLED',
  PRIMARY KEY (`id`),
  KEY `FKgc8ififrqh52srtwgbwdglija` (`plugin_package_id`),
  CONSTRAINT `FKgc8ififrqh52srtwgbwdglija` FOREIGN KEY (`plugin_package_id`) REFERENCES `plugin_packages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_instances`
--

DROP TABLE IF EXISTS `plugin_instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_instances` (
  `id` varchar(255) NOT NULL,
  `host` varchar(255) DEFAULT NULL,
  `container_name` varchar(255) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `container_status` varchar(255) DEFAULT NULL,
  `package_id` varchar(255) DEFAULT NULL,
  `docker_instance_resource_id` varchar(128) DEFAULT NULL,
  `instance_name` varchar(255) DEFAULT NULL,
  `plugin_mysql_instance_resource_id` varchar(128) DEFAULT NULL,
  `s3bucket_resource_id` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKn8124r2uvtipsy1hfkjmd4jts` (`package_id`),
  KEY `FKbqqlg3wrp1n0h926v5cojcjk7` (`s3bucket_resource_id`),
  CONSTRAINT `FKbqqlg3wrp1n0h926v5cojcjk7` FOREIGN KEY (`s3bucket_resource_id`) REFERENCES `resource_item` (`id`),
  CONSTRAINT `FKn8124r2uvtipsy1hfkjmd4jts` FOREIGN KEY (`package_id`) REFERENCES `plugin_packages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_mysql_instances`
--

DROP TABLE IF EXISTS `plugin_mysql_instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_mysql_instances` (
  `id` varchar(255) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `plugun_package_id` varchar(255) DEFAULT NULL,
  `resource_item_id` varchar(255) DEFAULT NULL,
  `schema_name` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK6twufg10tr0fk81uyf9tdtxf1` (`plugun_package_id`),
  KEY `FKn5plb1x3qnwxla4mixdhawo2o` (`resource_item_id`),
  CONSTRAINT `FK6twufg10tr0fk81uyf9tdtxf1` FOREIGN KEY (`plugun_package_id`) REFERENCES `plugin_packages` (`id`),
  CONSTRAINT `FKn5plb1x3qnwxla4mixdhawo2o` FOREIGN KEY (`resource_item_id`) REFERENCES `resource_item` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_package_attributes`
--

DROP TABLE IF EXISTS `plugin_package_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_package_attributes` (
  `id` varchar(255) NOT NULL,
  `entity_id` varchar(255) NOT NULL,
  `reference_id` varchar(255) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(256) DEFAULT NULL,
  `data_type` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK5x19ifhg97xwaa7skcsaf5n1i` (`entity_id`,`name`),
  KEY `FKe6fxg16b2982jqg0u85hyrmkd` (`reference_id`),
  CONSTRAINT `FK2o1bvf4mi511k374qrgjueb9l` FOREIGN KEY (`entity_id`) REFERENCES `plugin_package_entities` (`id`),
  CONSTRAINT `FKe6fxg16b2982jqg0u85hyrmkd` FOREIGN KEY (`reference_id`) REFERENCES `plugin_package_attributes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_package_authorities`
--

DROP TABLE IF EXISTS `plugin_package_authorities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_package_authorities` (
  `id` varchar(255) NOT NULL,
  `plugin_package_id` varchar(255) NOT NULL,
  `role_name` varchar(64) NOT NULL,
  `menu_code` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKh1sye8c6getl3ocjl02swt8ww` (`plugin_package_id`),
  CONSTRAINT `FKh1sye8c6getl3ocjl02swt8ww` FOREIGN KEY (`plugin_package_id`) REFERENCES `plugin_packages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_package_data_model`
--

DROP TABLE IF EXISTS `plugin_package_data_model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_package_data_model` (
  `id` varchar(255) NOT NULL,
  `version` int(11) NOT NULL DEFAULT '1',
  `package_name` varchar(63) NOT NULL,
  `is_dynamic` bit(1) DEFAULT b'0',
  `update_path` varchar(256) DEFAULT NULL,
  `update_method` varchar(10) DEFAULT NULL,
  `update_source` varchar(32) DEFAULT NULL,
  `update_time` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_plugin_package_data_model` (`package_name`,`version`),
  UNIQUE KEY `UK7w72dgvxcbvg1pucyc5g7122m` (`package_name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_package_dependencies`
--

DROP TABLE IF EXISTS `plugin_package_dependencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_package_dependencies` (
  `id` varchar(255) NOT NULL,
  `plugin_package_id` varchar(255) NOT NULL,
  `dependency_package_name` varchar(63) NOT NULL,
  `dependency_package_version` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKkftw3ls89woopc0elrgt45sh4` (`plugin_package_id`),
  CONSTRAINT `FKkftw3ls89woopc0elrgt45sh4` FOREIGN KEY (`plugin_package_id`) REFERENCES `plugin_packages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_package_entities`
--

DROP TABLE IF EXISTS `plugin_package_entities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_package_entities` (
  `id` varchar(255) NOT NULL,
  `data_model_id` varchar(255) NOT NULL,
  `data_model_version` int(11) NOT NULL,
  `package_name` varchar(63) NOT NULL,
  `name` varchar(100) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKpx6hn8sfkmmw4vj4udvuw2ytj` (`data_model_id`,`name`),
  CONSTRAINT `FKcpat6gldjt76mrxdeajr03wqf` FOREIGN KEY (`data_model_id`) REFERENCES `plugin_package_data_model` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_package_menus`
--

DROP TABLE IF EXISTS `plugin_package_menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_package_menus` (
  `id` varchar(255) NOT NULL,
  `plugin_package_id` varchar(255) NOT NULL,
  `code` varchar(64) NOT NULL,
  `category` varchar(64) NOT NULL,
  `source` varchar(255) DEFAULT 'PLUGIN',
  `display_name` varchar(256) NOT NULL,
  `local_display_name` varchar(256) NOT NULL,
  `menu_order` int(11) NOT NULL AUTO_INCREMENT,
  `path` varchar(256) NOT NULL,
  `active` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  KEY `plugin_package_menu_order` (`menu_order`),
  KEY `FK1uu0asbg2s3rx2jtw8gvtgabe` (`plugin_package_id`),
  CONSTRAINT `FK1uu0asbg2s3rx2jtw8gvtgabe` FOREIGN KEY (`plugin_package_id`) REFERENCES `plugin_packages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_package_resource_files`
--

DROP TABLE IF EXISTS `plugin_package_resource_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_package_resource_files` (
  `id` varchar(255) NOT NULL,
  `plugin_package_id` varchar(255) NOT NULL,
  `package_name` varchar(63) NOT NULL,
  `package_version` varchar(20) NOT NULL,
  `source` varchar(64) NOT NULL,
  `related_path` varchar(1024) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKt4nvt2rg6sr7gvhsf6ft1anbp` (`plugin_package_id`),
  CONSTRAINT `FKt4nvt2rg6sr7gvhsf6ft1anbp` FOREIGN KEY (`plugin_package_id`) REFERENCES `plugin_packages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_package_runtime_resources_docker`
--

DROP TABLE IF EXISTS `plugin_package_runtime_resources_docker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_package_runtime_resources_docker` (
  `id` varchar(255) NOT NULL,
  `plugin_package_id` varchar(255) NOT NULL,
  `image_name` varchar(256) NOT NULL,
  `container_name` varchar(128) NOT NULL,
  `port_bindings` varchar(64) NOT NULL,
  `volume_bindings` varchar(1024) NOT NULL,
  `env_variables` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKbcs2nhnmpm4xy3wdrfr3ainik` (`plugin_package_id`),
  CONSTRAINT `FKbcs2nhnmpm4xy3wdrfr3ainik` FOREIGN KEY (`plugin_package_id`) REFERENCES `plugin_packages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_package_runtime_resources_mysql`
--

DROP TABLE IF EXISTS `plugin_package_runtime_resources_mysql`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_package_runtime_resources_mysql` (
  `id` varchar(255) NOT NULL,
  `plugin_package_id` varchar(255) NOT NULL,
  `schema_name` varchar(128) NOT NULL,
  `init_file_name` varchar(256) DEFAULT NULL,
  `upgrade_file_name` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKxlust8prnl6y887e7ll31svb` (`plugin_package_id`),
  CONSTRAINT `FKxlust8prnl6y887e7ll31svb` FOREIGN KEY (`plugin_package_id`) REFERENCES `plugin_packages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_package_runtime_resources_s3`
--

DROP TABLE IF EXISTS `plugin_package_runtime_resources_s3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_package_runtime_resources_s3` (
  `id` varchar(255) NOT NULL,
  `plugin_package_id` varchar(255) NOT NULL,
  `bucket_name` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK2cowx4l100jk13x6k4xs2l1il` (`plugin_package_id`),
  CONSTRAINT `FK2cowx4l100jk13x6k4xs2l1il` FOREIGN KEY (`plugin_package_id`) REFERENCES `plugin_packages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plugin_packages`
--

DROP TABLE IF EXISTS `plugin_packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `plugin_packages` (
  `id` varchar(255) NOT NULL,
  `name` varchar(63) NOT NULL,
  `version` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'UNREGISTERED',
  `upload_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ui_package_included` bit(1) DEFAULT b'0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resource_item`
--

DROP TABLE IF EXISTS `resource_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `resource_item` (
  `id` varchar(255) NOT NULL,
  `additional_properties` varchar(2048) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `is_allocated` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `resource_server_id` varchar(64) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK2g8cf9beg7msqry6cmqedvv9n` (`resource_server_id`),
  CONSTRAINT `FK2g8cf9beg7msqry6cmqedvv9n` FOREIGN KEY (`resource_server_id`) REFERENCES `resource_server` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resource_server`
--

DROP TABLE IF EXISTS `resource_server`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `resource_server` (
  `id` varchar(64) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `is_allocated` int(11) DEFAULT NULL,
  `login_password` varchar(255) DEFAULT NULL,
  `login_username` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `port` varchar(255) DEFAULT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role_menu`
--

DROP TABLE IF EXISTS `role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `role_menu` (
  `id` varchar(255) NOT NULL,
  `role_name` varchar(64) NOT NULL,
  `menu_code` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_variables`
--

DROP TABLE IF EXISTS `system_variables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `system_variables` (
  `id` varchar(255) NOT NULL,
  `package_name` varchar(63) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `value` varchar(2000) DEFAULT NULL,
  `default_value` varchar(2000) DEFAULT NULL,
  `scope` varchar(50) NOT NULL DEFAULT 'global',
  `source` varchar(500) DEFAULT 'system',
  `status` varchar(50) DEFAULT 'active',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `favorites`;
CREATE TABLE `favorites` (
  `favorites_id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `collection_name` varchar(255) NOT NULL,
  `data` blob,
  PRIMARY KEY (`favorites_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `favorites_role`;
CREATE TABLE `favorites_role` (
  `id` varchar(255) NOT NULL,
  `favorites_id` varchar(255) DEFAULT NULL,
  `permission` varchar(255) DEFAULT NULL,
  `role_id` varchar(255) DEFAULT NULL,
  `role_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS = 1;

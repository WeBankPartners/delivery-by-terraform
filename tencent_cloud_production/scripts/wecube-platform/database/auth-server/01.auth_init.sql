/*
Navicat MariaDB Data Transfer

Source Server         : smoke1
Source Server Version : 100109
Source Host           : tdsql-66a3mko1.sql.tencentcdb.com:75
Source Database       : smoke2_auth_server

Target Server Type    : MariaDB
Target Server Version : 100109
File Encoding         : 65001

Date: 2020-02-06 16:29:24
*/

CREATE DATABASE IF NOT EXISTS `auth_server` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `auth_server`;

SET FOREIGN_KEY_CHECKS=0;
SET NAMES utf8;
-- ----------------------------
-- Table structure for auth_sys_api
-- ----------------------------
DROP TABLE IF EXISTS `auth_sys_api`;
CREATE TABLE `auth_sys_api` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `api_url` varchar(255) DEFAULT NULL,
  `http_method` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `system_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for auth_sys_authority
-- ----------------------------
DROP TABLE IF EXISTS `auth_sys_authority`;
CREATE TABLE `auth_sys_authority` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `is_deleted` bit(1) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `scope` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for auth_sys_role
-- ----------------------------
DROP TABLE IF EXISTS `auth_sys_role`;
CREATE TABLE `auth_sys_role` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `is_deleted` bit(1) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `email_addr` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for auth_sys_role_authority
-- ----------------------------
DROP TABLE IF EXISTS `auth_sys_role_authority`;
CREATE TABLE `auth_sys_role_authority` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `is_deleted` bit(1) DEFAULT NULL,
  `authority_code` varchar(255) DEFAULT NULL,
  `authority_id` varchar(255) DEFAULT NULL,
  `role_id` varchar(255) DEFAULT NULL,
  `role_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for auth_sys_sub_system
-- ----------------------------
DROP TABLE IF EXISTS `auth_sys_sub_system`;
CREATE TABLE `auth_sys_sub_system` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `api_key` varchar(500) DEFAULT NULL,
  `is_blocked` bit(1) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `pub_api_key` varchar(500) DEFAULT NULL,
  `system_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for auth_sys_sub_system_authority
-- ----------------------------
DROP TABLE IF EXISTS `auth_sys_sub_system_authority`;
CREATE TABLE `auth_sys_sub_system_authority` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `is_deleted` bit(1) DEFAULT NULL,
  `authority_code` varchar(255) DEFAULT NULL,
  `authority_id` varchar(255) DEFAULT NULL,
  `sub_system_code` varchar(255) DEFAULT NULL,
  `sub_system_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for auth_sys_user
-- ----------------------------
DROP TABLE IF EXISTS `auth_sys_user`;
CREATE TABLE `auth_sys_user` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `is_blocked` bit(1) DEFAULT NULL,
  `cell_phone_no` varchar(255) DEFAULT NULL,
  `is_deleted` bit(1) DEFAULT NULL,
  `dept` varchar(255) DEFAULT NULL,
  `email_addr` varchar(255) DEFAULT NULL,
  `english_name` varchar(255) DEFAULT NULL,
  `local_name` varchar(255) DEFAULT NULL,
  `office_tel_no` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for auth_sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `auth_sys_user_role`;
CREATE TABLE `auth_sys_user_role` (
  `id` varchar(255) NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `is_deleted` bit(1) DEFAULT NULL,
  `role_id` varchar(255) DEFAULT NULL,
  `role_name` varchar(255) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `auth_sys_role` VALUES ('2c9280827019695c01701dc555e60042', 'system', '2020-02-07 11:50:36', null, null, '', '\0', '系统管理员', '系统管理员', null, 'SUPER_ADMIN');
INSERT INTO `auth_sys_role` VALUES ('2c9280836f78a84b016f794c3a270000', 'system', '2020-01-06 13:20:36', null, null, '', '\0', 'CMDB管理员', 'CMDB管理员', null, 'CMDB_ADMIN');
INSERT INTO `auth_sys_role` VALUES ('2c9280836f78a84b016f794cd6dd0001', 'system', '2020-01-06 13:21:16', null, null, '', '\0', '监控管理员', '监控管理员', null, 'MONITOR_ADMIN');
INSERT INTO `auth_sys_role` VALUES ('2c9280836f78a84b016f794d6bb50002', 'system', '2020-01-06 13:21:54', null, null, '', '\0', '生产运维', '生产运维', null, 'PRD_OPS');
INSERT INTO `auth_sys_role` VALUES ('2c9280836f78a84b016f794e0d3b0003', 'system', '2020-01-06 13:22:35', null, null, '', '\0', '测试运维', '测试运维', null, 'STG_OPS');
INSERT INTO `auth_sys_role` VALUES ('2c9280836f78a84b016f794e9b170004', 'system', '2020-01-06 13:23:12', null, null, '', '\0', '应用架构师', '应用架构师', null, 'APP_ARC');
INSERT INTO `auth_sys_role` VALUES ('2c9280836f78a84b016f794f20440005', 'system', '2020-01-06 13:23:46', null, null, '', '\0', '基础架构师', '基础架构师', null, 'IFA_ARC');
INSERT INTO `auth_sys_role` VALUES ('2c9280836f78a84b016f794ff45e0006', 'system', '2020-01-06 13:24:40', null, null, '', '\0', '应用开发人员', '应用开发人员', null, 'APP_DEV');
INSERT INTO `auth_sys_role` VALUES ('2c9280836f78a84b016f795068870007', 'system', '2020-01-06 13:25:10', null, null, '', '\0', '基础架构运维人员', '基础架构运维人员', null, 'IFA_OPS');
INSERT INTO `auth_sys_role` (`id`, `created_by`, `created_time`, `updated_by`, `updated_time`, `is_active`, `is_deleted`, `description`, `display_name`, `email_addr`, `name`) VALUES ('8ab86ba0723a78fe01723a790ceb0000', 'system', '2020-5-22 11:48:37', NULL, NULL, '', '\0', '子系统', '子系统', NULL, 'SUB_SYSTEM');

-- ----------------------------
-- Records of auth_sys_authority
-- ----------------------------
INSERT INTO `auth_sys_authority` VALUES ('2c9280827019695c017019c28b0f001e', 'system', '2020-02-06 17:09:04', null, null, '', '\0', 'IMPLEMENTATION_WORKFLOW_EXECUTION', null, 'IMPLEMENTATION_WORKFLOW_EXECUTION', 'GLOBAL');
INSERT INTO `auth_sys_authority` VALUES ('2c9280827019695c017019c28b130020', 'system', '2020-02-06 17:09:04', null, null, '', '\0', 'IMPLEMENTATION_BATCH_EXECUTION', null, 'IMPLEMENTATION_BATCH_EXECUTION', 'GLOBAL');
INSERT INTO `auth_sys_authority` VALUES ('2c9280827019695c017019c2a086002e', 'system', '2020-02-06 17:09:10', null, null, '', '\0', 'COLLABORATION_PLUGIN_MANAGEMENT', null, 'COLLABORATION_PLUGIN_MANAGEMENT', 'GLOBAL');
INSERT INTO `auth_sys_authority` VALUES ('2c9280827019695c017019c2a08a0030', 'system', '2020-02-06 17:09:10', null, null, '', '\0', 'COLLABORATION_WORKFLOW_ORCHESTRATION', null, 'COLLABORATION_WORKFLOW_ORCHESTRATION', 'GLOBAL');
INSERT INTO `auth_sys_authority` VALUES ('2c9280827019695c017019c2a8690032', 'system', '2020-02-06 17:09:12', null, null, '', '\0', 'ADMIN_SYSTEM_PARAMS', null, 'ADMIN_SYSTEM_PARAMS', 'GLOBAL');
INSERT INTO `auth_sys_authority` VALUES ('2c9280827019695c017019c2a86d0034', 'system', '2020-02-06 17:09:12', null, null, '', '\0', 'ADMIN_RESOURCES_MANAGEMENT', null, 'ADMIN_RESOURCES_MANAGEMENT', 'GLOBAL');
INSERT INTO `auth_sys_authority` VALUES ('2c9280827019695c017019c2a8700036', 'system', '2020-02-06 17:09:12', null, null, '', '\0', 'ADMIN_USER_ROLE_MANAGEMENT', null, 'ADMIN_USER_ROLE_MANAGEMENT', 'GLOBAL');

-- ----------------------------
-- Records of auth_sys_role_authority
-- ----------------------------

INSERT INTO `auth_sys_role_authority` VALUES ('2c928082701ec1ec01701f04e7190038', 'umadmin', '2020-02-07 17:39:39', null, null, '', '\0', 'IMPLEMENTATION_WORKFLOW_EXECUTION', '2c9280827019695c017019c28b0f001e', '2c9280827019695c01701dc555e60042', 'SUPER_ADMIN');
INSERT INTO `auth_sys_role_authority` VALUES ('2c928082701ec1ec01701f04e71c0039', 'umadmin', '2020-02-07 17:39:39', null, null, '', '\0', 'IMPLEMENTATION_BATCH_EXECUTION', '2c9280827019695c017019c28b130020', '2c9280827019695c01701dc555e60042', 'SUPER_ADMIN');
INSERT INTO `auth_sys_role_authority` VALUES ('2c928082701ec1ec01701f05104e0040', 'umadmin', '2020-02-07 17:39:50', null, null, '', '\0', 'COLLABORATION_PLUGIN_MANAGEMENT', '2c9280827019695c017019c2a086002e', '2c9280827019695c01701dc555e60042', 'SUPER_ADMIN');
INSERT INTO `auth_sys_role_authority` VALUES ('2c928082701ec1ec01701f0510510041', 'umadmin', '2020-02-07 17:39:50', null, null, '', '\0', 'COLLABORATION_WORKFLOW_ORCHESTRATION', '2c9280827019695c017019c2a08a0030', '2c9280827019695c01701dc555e60042', 'SUPER_ADMIN');
INSERT INTO `auth_sys_role_authority` VALUES ('2c928082701ec1ec01701f051d660042', 'umadmin', '2020-02-07 17:39:53', null, null, '', '\0', 'ADMIN_SYSTEM_PARAMS', '2c9280827019695c017019c2a8690032', '2c9280827019695c01701dc555e60042', 'SUPER_ADMIN');
INSERT INTO `auth_sys_role_authority` VALUES ('2c928082701ec1ec01701f051d6a0043', 'umadmin', '2020-02-07 17:39:53', null, null, '', '\0', 'ADMIN_RESOURCES_MANAGEMENT', '2c9280827019695c017019c2a86d0034', '2c9280827019695c01701dc555e60042', 'SUPER_ADMIN');
INSERT INTO `auth_sys_role_authority` VALUES ('2c928082701ec1ec01701f051d6d0044', 'umadmin', '2020-02-07 17:39:53', null, null, '', '\0', 'ADMIN_USER_ROLE_MANAGEMENT', '2c9280827019695c017019c2a8700036', '2c9280827019695c01701dc555e60042', 'SUPER_ADMIN');

-- ----------------------------
-- Records of auth_sys_sub_system
-- ----------------------------
INSERT INTO `auth_sys_sub_system` (`id`, `created_by`, `created_time`, `updated_by`, `updated_time`, `is_active`, `api_key`, `is_blocked`, `description`, `name`, `pub_api_key`, `system_code`) VALUES ('2c9280827019695c0170197b79470000', 'system', '2020-1-6 20:04:25', NULL, NULL, '', 'MIIBVQIBADANBgkqhkiG9w0BAQEFAASCAT8wggE7AgEAAkEAwnTN7JDXFcSoikXuNOQDtAjic1Wu6oAtCQJquCJmXrBTqB7hwS2mK6TuT8P7Jx60BQcaRL12hPLi6cOiCawuVwIDAQABAkB9NORazDARjhzPW5OzbpWL2KSmiqcjywA0at/4S/4KPPM8vwRjzEMs7pV9nSJ2M+/YOqPMBDl8iBUSLpfKf/uxAiEA52UroIvo2URlmAycaJm7+e4QqqfhEnM9wlGCJwL2jTsCIQDXIh2zwN7KQEIypmOL+uXvlZUjmx0Tj29mWOwP/fBBlQIhAI9+VLSlror1eE73GxNeqoxNznYVz2RCpLzZEO4iT0S7AiARg0Z1tpKsVjTNWLwrzf3f1gZxApSIXhnMdBqrZpmjTQIhAJhgYctlaydmggTPCqWLGub9WqEyH2HrrcabRvpWdEcV', '\0', NULL, 'Wecube Platform Core', 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAMJ0zeyQ1xXEqIpF7jTkA7QI4nNVruqALQkCargiZl6wU6ge4cEtpiuk7k/D+ycetAUHGkS9doTy4unDogmsLlcCAwEAAQ==', 'SYS_PLATFORM');
INSERT INTO `auth_sys_sub_system` (`id`, `created_by`, `created_time`, `updated_by`, `updated_time`, `is_active`, `api_key`, `is_blocked`, `description`, `name`, `pub_api_key`, `system_code`) VALUES ('2c9280827019695c0170199c2375001a', 'system', '2020-1-6 20:04:44', NULL, NULL, '', 'MIIBVgIBADANBgkqhkiG9w0BAQEFAASCAUAwggE8AgEAAkEAhErKNhmx4o7apVfYxPEDOxaOkKe7lwk2uLzigW5NTLlhZRLJ4d7qXqAdBEFgUwj5KvzGtlp+v5c120X+JYFYUwIDAQABAkAFYSkx4/+Yz+hSOu1ErOxNtdAcT8XQEX7ZKk0nqD2adgw/fjUCdeVCde/bzEVyhdguT+cSAHVicyvRU8o4/r0xAiEA1Uv8EYtayyo0vMz5caR1uOhJDBoBgi1IsHF/+WMhPSsCIQCexxsXLl9DAD1tsJejfJiQEkef6kwsaw+TfHJkvnDNeQIhANDbh6bySuR3no5lM7hYrsFyCt0jtehvSSck7IgZzlljAiEAmgKFO4IGcwX7j7c4DyNfFHg2s13fj0I1tJiEmUXEQvkCIQC+nepLywSWr/XDIcRHnATReCfytK7+d3wDiy4d4YaVhQ==', '\0', NULL, 'WeCMDB Plugin', 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAIRKyjYZseKO2qVX2MTxAzsWjpCnu5cJNri84oFuTUy5YWUSyeHe6l6gHQRBYFMI+Sr8xrZafr+XNdtF/iWBWFMCAwEAAQ==', 'SYS_WECMDB');
INSERT INTO `auth_sys_sub_system` (`id`, `created_by`, `created_time`, `updated_by`, `updated_time`, `is_active`, `api_key`, `is_blocked`, `description`, `name`, `pub_api_key`, `system_code`) VALUES ('8ab86ba0723a776201723a7772a10000', 'system', '2020-5-22 11:53:34', NULL, NULL, '', 'MIIBUwIBADANBgkqhkiG9w0BAQEFAASCAT0wggE5AgEAAkEAiV9cxCoaixsNg2ItLcmxwIT3dTuRlY4EIlM1ytwnbxO1912i4gMddCWcwLMJdpdMLsCBp9nJRQ/4pJeIppLm7QIDAQABAkAVs3PjJUeWLArhc3PxpMgowpiY83UXLB0pEv4PcuHj4Pr1Op/mBIL8sRrfEcOr1V5HRxNACTSdiPwqFuflnU99AiEA87csRj/hs1+KX293rlouLtVA1qhwqgAlEHRv4+vfoJcCIQCQS/knZ5dc2LC2pidh/rywiMSrGAcQHi4ZGLY4b7KhGwIgN5KtJderP5upkdl5EOi/Xy6BenEuP5WI3heu6+n9NEECIHtyw+HWWkRwjh5039SSntNY7wiBMem0KDQIVDzMMsJpAiA+2F3+x+QuV09Dz826IRV639XKhp0J9aDsxRsypS6PRA==', '\0', NULL, 'Wecube Monitor', 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAIlfXMQqGosbDYNiLS3JscCE93U7kZWOBCJTNcrcJ28TtfddouIDHXQlnMCzCXaXTC7AgafZyUUP+KSXiKaS5u0CAwEAAQ==', 'SYS_MONITOR');
INSERT INTO `auth_sys_sub_system` (`id`, `created_by`, `created_time`, `updated_by`, `updated_time`, `is_active`, `api_key`, `is_blocked`, `description`, `name`, `pub_api_key`, `system_code`) VALUES ('8ab86ba0723a785001723a7860670000', 'system', '2020-5-22 11:55:51', NULL, NULL, '', 'MIIBUwIBADANBgkqhkiG9w0BAQEFAASCAT0wggE5AgEAAkEAl3pjii24Rof+0EiEeez5P4ZxKeUccE933qmyiZgKwdcwaesMrTSf833OQsS2LzfqSkHq+Vm/mhlDOyTMSsw36wIDAQABAkAGmebMlsF5EWQhX4emaJVUF1/HG5zpqAzpPyvwoxeU6uKcBPLphRmzOgpUOxA7yDddZLLydG7UGolHiwXmyIABAiEAzM1xOdPTooiPeRpWESAf1ANM9YnExI+bicWyBkvj7+sCIQC9WGRoI/Rr0dswvdHrb9xJZ5QfGk3fvluJ8dX14O7YAQIgezca6OSljkLEtuJ+Z31BSOfXdF43sN6JgGEdkyYzc5MCIAQtfRmnIW93k+SBa65MK4obFPOSuwEizBZBFb11FxABAiBfQlaOi6OJ0m3qc2e9iaOQaJEbkydUCX0QasNelklu0g==', '\0', NULL, 'Wecube Saltstack', 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAJd6Y4otuEaH/tBIhHns+T+GcSnlHHBPd96psomYCsHXMGnrDK00n/N9zkLEti836kpB6vlZv5oZQzskzErMN+sCAwEAAQ==', 'SYS_SALTSTACK');

-- ----------------------------
-- Records of auth_sys_user
-- ----------------------------
INSERT INTO `auth_sys_user` VALUES ('2c9280827019695c017019a2d5ac001b', 'system', '2020-02-06 12:05:03', null, null, '', '\0', '13912345678', '\0', 'OPT', null, 'UM ADMIN', 'UM管理员', '0755-12345678', '$2a$10$XH7kL/aIjCKwZZ2CXd5Nk.dFxyP4UubHa7vqekT1IYB1dX./0Hr8m', '运维岗', 'umadmin');
INSERT INTO `auth_sys_user` VALUES ('2c9280827019695c017019dac0ea0040', 'umadmin', '2020-02-06 17:35:31', null, null, '', '\0', null, '\0', null, null, 'ADMIN', '管理员', null, '$2a$10$YOyZUonK23qiPS03MeZQL.T.4LHje8FRbp6dhV2wHBGeVWdm9hwtu', null, 'admin');

-- ----------------------------
-- Records of auth_sys_user_role
-- ----------------------------
INSERT INTO `auth_sys_user_role` VALUES ('2c928082701ec1ec01701f04b58d0014', 'umadmin', '2020-02-07 17:39:27', null, null, '', '\0', '2c9280827019695c01701dc555e60042', 'SUPER_ADMIN', '2c9280827019695c017019a2d5ac001b', 'umadmin');
INSERT INTO `auth_sys_user_role` VALUES ('2c928082701ec1ec01701f04b5950015', 'umadmin', '2020-02-07 17:39:27', null, null, '', '\0', '2c9280827019695c01701dc555e60042', 'SUPER_ADMIN', '2c9280827019695c017019dac0ea0040', 'admin');



SET FOREIGN_KEY_CHECKS=1;
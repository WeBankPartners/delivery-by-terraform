variable "secret_id" {
}
variable "secret_key" {
}
variable "region" { default = "ap-hongkong" }

variable "availability_zone_1" {
  description = "You can override the value by setup os env variable - 'TF_VAR_availability_zone_1'"
  default     = "ap-hongkong-1"
}
variable "availability_zone_2" {
  description = "You can override the value by setup os env variable - 'TF_VAR_availability_zone_2'"
  default     = "ap-hongkong-2"
}

#Specified password of ECS/RDS
variable "default_password" {
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_default_password'"
  default     = "Wecube@123456"
}

#Specified WeCube version
variable "wecube_version" {
  description = "You can override the value by setup os env variable - 'TF_VAR_wecube_version'"
  default     = "20200424131349-c32549a"
}

#Specified the WeCube install home folder
variable "wecube_home_folder" {
  description = "You can override the value by setup os env variable - 'TF_VAR_wecube_install_folder'"
  default     = "/data/wecube"
}

#If "Y", it will auto launch plugins;
variable "is_install_plugins" {
  description = "You can override the value by setup os env variable - 'TF_VAR_is_install_plugins'"
   default     = "Y"
}

#please input your ip which run 'terraform apply'
variable "current_ip" {
  description = "You can override the value by setup os env variable - 'TF_VAR_current_ip'"
  default     = "0.0.0.0/0"
}


#for resource name
variable "vpc_name" {}
variable "region_name" {}
variable "az_1_name" {}
variable "az_2_name" {}
variable "subnet_vdi_name" {}
variable "subnet_proxy_name" {}
variable "subnet_app1_name" {}
variable "subnet_app2_name" {}
variable "subnet_db1_name" {}

variable "rds_core_name" {}
variable "rds_plugin_name" {}
variable "ecs_plugin_host1_name" {}
variable "ecs_plugin_host2_name" {}
variable "ecs_wecube_host1_name" {}
variable "ecs_wecube_host2_name" {}
variable "ecs_squid_name" {}
variable "ecs_vdi_name" {}
variable "lb1_name" {}
variable "lb2_name" {}

#自动注册插件包信息，若不需要自动注册插件包，则以下参数无意义
variable "WECUBE_PLUGIN_URL_PREFIX" {}
variable "PKG_WECMDB" {}
variable "PKG_QCLOUD" {}
variable "PKG_SALTSTACK" {}
variable "PKG_NOTIFICATIONS" {}
variable "PKG_MONITOR" {}
variable "PKG_ARTIFACTS" {}
variable "PKG_SERVICE_MGMT" {}
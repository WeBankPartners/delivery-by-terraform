variable "hw_access_key" {
  description = "Please input your Huawei cloud Access_key"
}
variable "hw_secret_key" {
  description = "Please input your Huawei cloud Secret_key"
}

#Your Domain ID(Account ID)
variable "hw_domain_id" {
  default     = "hw_domain_id"
  description = "Just for output, not for other purposes"
}

#Your Project ID
variable "hw_project_id" {
  default     = "hw_project_id"
  description = "Just for output, not for other purposes"
}

#Specified the region which wecube deployed
variable "hw_region" {
  default     = "ap-southeast-3"
  description = "The region name where the resource will be created"
}

#This DNS is ref from https://support.huaweicloud.com/dns_faq/dns_faq_002.html by the region
variable "hw_dns1" {
  default     = "100.125.1.250"
  description = "This DNS is ref from https://support.huaweicloud.com/dns_faq/dns_faq_002.html by the region"
}
variable "hw_dns2" {
  default     = "100.125.128.250"
  description = "This DNS is ref from https://support.huaweicloud.com/dns_faq/dns_faq_002.html by the region"
}

#Specified master availability zone for resource creation
variable "hw_az_master" {
  default     = "ap-southeast-3b"
  description = "Specified master availability zone for resource creation"
}
#Specified slave availability zone for resource creation
variable "hw_az_slave" {
  default     = "ap-southeast-3c"
  description = "Specified slave availability zone for resource creation"
}
variable "hw_tenant_name" {
  default     = "ap-southeast-3"
  description = "Specified tenant name"
}

variable "default_password" {
  description = "Please input your password of ECS/RDS and other resources"
}

variable "wecube_version" {
  description = "Specified WeCube version"
  default     = "20200424131349-c32549a"
}

variable "wecube_home_folder" {
  description = "Specified WeCube install folder"
  default     = "/data/wecube"
}

variable "is_install_plugins" {
  description = "Only 'Y' will be accepted to auto install plugins"
  #  default     = "Y"
}

variable "current_ip" {
  description = "Please input your current ip or network segment(CIDR)"
  #  default     = "127.0.0.1"
}



#自动注册插件包信息，若不需要自动注册插件包，则以下参数无意义
variable "WECUBE_PLUGIN_URL_PREFIX" {}
variable "PKG_WECMDB" {}
variable "PKG_HUAWEICLOUD" {}
variable "PKG_SALTSTACK" {}
variable "PKG_NOTIFICATIONS" {}
variable "PKG_MONITOR" {}
variable "PKG_ARTIFACTS" {}
variable "PKG_SERVICE_MGMT" {}

#for resource name
variable "vpc_name" {}
variable "subnet_vdi_name" {}
variable "subnet_proxy_name" {}
variable "subnet_lb1_name" {}
variable "subnet_lb2_name" {}
variable "subnet_app1_name" {}
variable "subnet_app2_name" {}
variable "subnet_db1_name" {}
variable "subnet_db2_name" {}

variable "rds_parametergroup_name" {}
variable "rds_core_name" {}
variable "rds_plugin_name" {}
variable "ecs_plugin_host1_name" {}
variable "s3_bucket_name" {}
variable "ecs_plugin_host2_name" {}
variable "ecs_wecube_host1_name" {}
variable "ecs_wecube_host2_name" {}
variable "ecs_squid_name" {}
variable "ecs_vdi_name" {}
variable "lb1_name" {}
variable "lb1_listener1_name" {}
variable "lb1_listener2_name" {}
variable "lb1_listener3_name" {}
variable "lb1_listener4_name" {}
variable "lb2_name" {}
variable "lb2_listener1_name" {}
variable "lb2_listener2_name" {}
variable "lb2_listener3_name" {}
variable "lb2_listener4_name" {}
variable "hw_access_key" {
  # Warn: please input it command line or setup real password by using os env variable - 'TF_VAR_hw_access_key'
  description = "Please input your Huawei cloud Access_key"
}
variable "hw_secret_key" {
  # Warn: to be safety, please input it command line or setup real password by using os env variable - 'TF_VAR_hw_secret_key'
  description = "Please input your Huawei cloud Secret_key"
}

#Your Domain ID(Account ID)
variable "hw_domain_id" {
  default     = "hw_domain_id"
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_hw_secret_key'"
}

#Your Project ID
variable "hw_project_id" {
  default     = "hw_project_id"
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_hw_secret_key'"
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
#  default     = "Y"
}

#please input your ip which run 'terraform apply'
variable "current_ip" {
  description = "You can override the value by setup os env variable - 'TF_VAR_current_ip'"
#  default     = "127.0.0.1"
}


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
variable "hw_access_key" {
  default = "hw_access_key"
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_hw_access_key'"
}
variable "hw_secret_key" {
  default = "hw_secret_key"
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_hw_secret_key'"
}
variable "hw_region" {
  default     = "ap-southeast-3"
  description = "The region name where the resource will be created"
}
variable "hw_dns1" {
  default     = "100.125.1.250"
  description = "This DNS is ref from https://support.huaweicloud.com/dns_faq/dns_faq_002.html by the region"
}
variable "hw_dns2" {
  default     = "100.125.3.250"
  description = "This DNS is ref from https://support.huaweicloud.com/dns_faq/dns_faq_002.html by the region"
}
variable "hw_az_master" {
  default     = "ap-southeast-3a"
  description = "Specified master availability zone for resource creation"
}
variable "hw_az_slave" {
  default     = "ap-southeast-3b"
  description = "Specified slave availability zone for resource creation"
}
variable "hw_tenant_name" {
  default     = "ap-southeast-3"
  description = "Specified tenant name"
}
variable "default_password" {
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_default_password'"
  default     = "Wecube@123456"
}
variable "wecube_version" {
  description = "You can override the value by setup os env variable - 'TF_VAR_wecube_version'"
  default     = "20200408103508-3155567"
}
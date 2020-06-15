variable "cloud_provider" {
  default = "TencentCloud"
}

variable "secret_id" {}

variable "secret_key" {}

variable "region" {
  default = "ap-guangzhou"
}

variable "availability_zones" {
  type    = list(string)
  default = [
    "ap-guangzhou-4",
    "ap-guangzhou-3",
  ]
}

variable "idc_prefix" {
  default = "TC_GZ_PRD"
}

variable "wecube_release_version" {
  default = "customized"
}

variable "wecube_home" {
  default = "/data/wecube"
}

variable "initial_password" {
  default = "Wecube@123456"
}

variable "default_mysql_port" {
  default = "3307"
}

variable "should_install_plugins" {
  type    = bool
  default = true
}

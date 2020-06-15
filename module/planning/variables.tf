variable "availability_zones" {}
variable "idc_prefix" {}
variable "wecube_release_version" {}
variable "initial_password" {}
variable "default_mysql_port" {}


locals {
  cluster_mode                = length(var.availability_zones) > 1
  primary_availability_zone   = var.availability_zones[0]
  secondary_availability_zone = local.cluster_mode ? var.availability_zones[0] : null
}

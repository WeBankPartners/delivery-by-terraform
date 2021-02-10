variable "secret_id" {}
variable "secret_key" {}
variable "region" {}
variable "availability_zones" {}
variable "initial_password" {}
variable "default_mysql_port" {}


locals {
  cluster_mode                = length(var.availability_zones) > 1
  primary_availability_zone   = var.availability_zones[0]
  secondary_availability_zone = local.cluster_mode ? var.availability_zones[1] : ""
}

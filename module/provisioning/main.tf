terraform {
  required_version = "~> 0.14.0"

  required_providers {
    tencentcloud = {
      source = "tencentcloudstack/tencentcloud"
      version = "1.53.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "3.24.1"
    }
  }
}

locals {
  is_tencentcloud_enabled = var.cloud_provider == "TencentCloud"
  is_aws_enabled          = var.cloud_provider == "AWS"
}

module "tencentcloud" {
  count  = local.is_tencentcloud_enabled ? 1 : 0

  source = "../cloud_resources/tencentcloud"

  availability_zones           = var.availability_zones
  wecube_home                  = var.wecube_home
  initial_password             = var.initial_password
  default_mysql_port           = var.default_mysql_port
  use_mirror_in_mainland_china = var.use_mirror_in_mainland_china
  resource_plan                = var.resource_plan
}

module "aws" {
  count  = local.is_aws_enabled ? 1 : 0

  source = "../cloud_resources/aws"

  availability_zones           = var.availability_zones
  wecube_home                  = var.wecube_home
  initial_password             = var.initial_password
  default_mysql_port           = var.default_mysql_port
  use_mirror_in_mainland_china = var.use_mirror_in_mainland_china
  resource_plan                = var.resource_plan
}

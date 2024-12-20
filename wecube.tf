terraform {
  required_providers {
    tencentcloud = {
      source = "tencentcloudstack/tencentcloud"
    }
  }
}

# Timing stuff
resource "time_static" "start_time" {}
resource "time_static" "end_time" {
  triggers = {
    update = length(module.provisioning.resource_map) + length(module.deployment.deployment_step_ids)
  }
}
locals {
  elapsed_time_unix    = time_static.end_time.unix - time_static.start_time.unix
  elapsed_time_hours   = floor(local.elapsed_time_unix / 3600)
  elapsed_time_minutes = floor(local.elapsed_time_unix % 3600 / 60)
  elapsed_time_seconds = local.elapsed_time_unix % 60
  elapsed_time_text    = format("%s%s%s",
    local.elapsed_time_hours > 0 ? "${local.elapsed_time_hours}h" : "",
    (local.elapsed_time_hours > 0 || local.elapsed_time_minutes > 0) ? "${local.elapsed_time_minutes}m" : "",
    "${local.elapsed_time_seconds}s"
  )
}

# Copy customized version spec files to installer directories if it exists
resource "local_file" "wecub_platform_version_spec" {
  count    = try(fileexists("${path.root}/${var.wecube_release_version}") ? 1 : 0, 0)

  content  = file("${path.root}/${var.wecube_release_version}")
  filename = "${path.root}/installer/wecube-platform/${var.wecube_release_version}"
}
resource "local_file" "wecube_system_settings_version_spec" {
  count    = try(fileexists("${path.root}/${var.wecube_release_version}") ? 1 : 0, 0)

  content  = file("${path.root}/${var.wecube_release_version}")
  filename = "${path.root}/installer/wecube-system-settings/${var.wecube_release_version}"
}

provider "tencentcloud" {
  secret_id  = var.secret_id
  secret_key = var.secret_key
  region     = var.region
}

module "planning" {
  source = "./module/planning"

  secret_id              = var.secret_id
  secret_key             = var.secret_key
  region                 = var.region
  availability_zones     = var.availability_zones
  initial_password       = var.initial_password
  default_mysql_port     = var.default_mysql_port
}

module "provisioning" {
  source = "./module/provisioning"

  cloud_provider               = var.cloud_provider
  wecube_release_version       = var.wecube_release_version
  wecube_settings              = var.wecube_settings
  wecube_home                  = var.wecube_home
  wecube_user                  = var.wecube_user
  initial_password             = var.initial_password
  public_key_file              = var.public_key_file
  default_mysql_port           = var.default_mysql_port
  use_mirror_in_mainland_china = var.use_mirror_in_mainland_china

  resource_plan = module.planning.resource_plan
}

module "deployment" {
  source = "./module/deployment"

  cloud_provider               = var.cloud_provider
  wecube_release_version       = var.wecube_release_version
  wecube_settings              = var.wecube_settings
  wecube_home                  = var.wecube_home
  wecube_user                  = var.wecube_user
  initial_password             = var.initial_password
  public_key_file              = var.public_key_file
  default_mysql_port           = var.default_mysql_port
  use_mirror_in_mainland_china = var.use_mirror_in_mainland_china

  bastion_host_name = module.planning.bastion_host_name
  deployment_plan   = module.planning.deployment_plan
  resource_map      = module.provisioning.resource_map
}

output "region" {
  value = var.region
}

output "total_elapsed_time" {
  value = local.elapsed_time_text
}

output "wecube_website_url" {
  value = "http://${lookup(module.provisioning.resource_map.entrypoint_ip_by_name, module.planning.entrypoint_host_name, "")}:19090"
}

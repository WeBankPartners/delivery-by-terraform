# Copy customized version spec files to installer directories if it exists
resource "local_file" "wecub_platform_version_spec" {
    count    = fileexists("${path.root}/${var.wecube_release_version}") ? 1 : 0

    content  = file("${path.root}/${var.wecube_release_version}")
    filename = "${path.root}/installer/wecube-platform/${var.wecube_release_version}"
}
resource "local_file" "wecube_system_settings_version_spec" {
    count    = fileexists("${path.root}/${var.wecube_release_version}") ? 1 : 0

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
  wecube_release_version = var.wecube_release_version
  initial_password       = var.initial_password
  default_mysql_port     = var.default_mysql_port
}

module "provisioning" {
  source = "./module/provisioning"

  cloud_provider       = var.cloud_provider
  wecube_home          = var.wecube_home
  initial_password     = var.initial_password
  default_mysql_port   = var.default_mysql_port

  resource_plan        = module.planning.resource_plan
}

module "deployment" {
  source = "./module/deployment"

  wecube_home            = var.wecube_home
  wecube_release_version = var.wecube_release_version
  should_install_plugins = var.should_install_plugins
  initial_password       = var.initial_password

  bastion_host_name      = module.planning.bastion_host_name
  deployment_plan        = module.planning.deployment_plan
  resource_map           = module.provisioning.resource_map

}

output "wecube_website_url" {
  value="http://${module.provisioning.resource_map.entrypoint_ip_by_name[module.planning.entrypoint_host_name]}:19090"
}

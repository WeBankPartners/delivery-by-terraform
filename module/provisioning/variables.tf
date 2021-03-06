variable "cloud_provider" {}
variable "wecube_release_version" {}
variable "wecube_settings" {}
variable "wecube_home" {}
variable "wecube_user" {}
variable "initial_password" {}
variable "public_key_file" {}
variable "default_mysql_port" {}
variable "use_mirror_in_mainland_china" {}

variable "resource_plan" {}


locals {
  is_tencent_cloud_enabled = var.cloud_provider == "TencentCloud"

  subnet_id_map = {for s in tencentcloud_subnet.subnets : s.name => s.id}

  use_bastion_host = length(var.resource_plan.bastion_hosts) > 0
  bastion_host_ip  = local.use_bastion_host ? tencentcloud_instance.bastion_hosts[0].public_ip : null

  proxy_host_ip = length(var.resource_plan.waf_hosts) > 0 ? var.resource_plan.waf_hosts[0].private_ip : ""

  combined_vm_instances = concat(tencentcloud_instance.bastion_hosts,
                                 tencentcloud_instance.waf_hosts,
                                 tencentcloud_instance.vm_instances)
}

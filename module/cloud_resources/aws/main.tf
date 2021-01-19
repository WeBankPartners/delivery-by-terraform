terraform {
  required_version = "~> 0.14.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.24.1"
    }
    tencentcloud = {
      source = "tencentcloudstack/tencentcloud"
      version = "1.53.0"
    }
  }
}

locals {
  subnet_id_map = {for s in aws_subnet.subnets : s.tags.Name => s.id}

  use_bastion_host = length(var.resource_plan.bastion_hosts) > 0
  bastion_host_ip  = null#local.use_bastion_host ? tencentcloud_instance.bastion_hosts[0].public_ip : null

  proxy_host_ip = ""#length(var.resource_plan.waf_hosts) > 0 ? var.resource_plan.waf_hosts[0].private_ip : ""

  combined_vm_instances = []#concat(tencentcloud_instance.bastion_hosts,
                           #      tencentcloud_instance.waf_hosts,
                            #     tencentcloud_instance.vm_instances)
}

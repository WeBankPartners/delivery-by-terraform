output "bastion_host_name" {
  value = local.cluster_mode ? local.bastion_hosts_cluster[0].name : null
}

output "resource_plan" {
  value = {
    vpcs                 = local.cluster_mode ? [local.vpc_cluster]                : [local.vpc_standalone]
    subnets              = local.cluster_mode ? local.subnets_cluster              : [local.subnet_standalone]
    route_tables         = local.cluster_mode ? [local.route_table_cluster]        : [local.route_table_standalone]
    security_groups      = local.cluster_mode ? [local.security_group_cluster]     : [local.security_group_standalone]
    security_group_rules = local.cluster_mode ? local.security_group_rules_cluster : local.security_group_rules_standalone

    bastion_hosts        = local.cluster_mode ? local.bastion_hosts_cluster        : []
    waf_hosts            = local.cluster_mode ? local.waf_hosts_cluster            : []
    vm_instances         = local.cluster_mode ? local.hosts_cluster                : [local.host_standalone]
    core_db_instance     = local.cluster_mode ? [local.core_db_instance_cluster]   : []
    plugin_db_instance   = local.cluster_mode ? [local.plugin_db_instance_cluster] : []
    lb_instances         = local.cluster_mode ? local.lb_instances_cluster         : []
  }
}

output "deployment_plan" {
  value = local.cluster_mode ? local.deployment_plan_cluster : local.deployment_plan_standalone
}

output "entrypoint_host_name" {
  value = local.cluster_mode ? local.lb_internal_1_cluster.name : local.host_standalone.name
}

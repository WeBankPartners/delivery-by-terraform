locals {
  private_key_pem  = try(file(pathexpand(trimsuffix(var.public_key_file, ".pub"))), null)
  use_bastion_host = var.bastion_host_name != null

  db_plan_env_by_name = {
    for db_plan in var.deployment_plan.db : db_plan.name => (db_plan.db_resource_name == null ? db_plan : {
      db_host     = lookup(var.resource_map.db_by_name, db_plan.db_resource_name, {intranet_ip=null}).intranet_ip
      db_port     = lookup(var.resource_map.db_by_name, db_plan.db_resource_name, {intranet_port=null}).intranet_port
      db_name     = db_plan.db_name
      db_username = "root"
      db_password = lookup(var.resource_map.db_by_name, db_plan.db_resource_name, {root_password=null}).root_password
    })
  }

  lb_listener_by_name            = {for l in tencentcloud_clb_listener.lb_listeners           : l.listener_name => l}
  lb_listener_rule_by_lisener_id = {for r in tencentcloud_clb_listener_rule.lb_listener_rules : r.listener_id   => r}
  lb_back_ends = flatten([
    for lb_plan in var.deployment_plan.lb : [
      for back_end in lb_plan.back_ends : merge(back_end, {
        clb_id      = lookup(var.resource_map.lb_by_name, lb_plan.resource_name, {id=null}).id
        listener_id = lookup(local.lb_listener_by_name, lb_plan.name, {listener_id=null}).listener_id
        rule_id     = lookup(local.lb_listener_rule_by_lisener_id, lookup(local.lb_listener_by_name, lb_plan.name, {listener_id=""}).listener_id, {rule_id=null}).rule_id
        instance_id = lookup(var.resource_map.vm_by_name, back_end.resource_name, {id=null}).id
      })
    ]
  ])
}

resource "null_resource" "db_deployments" {
  count = length(var.deployment_plan.db)

  connection {
    type         = "ssh"
    bastion_host = local.use_bastion_host ? var.resource_map.vm_by_name[var.bastion_host_name].public_ip : null
    host         = local.use_bastion_host ? var.resource_map.vm_by_name[var.deployment_plan.db[count.index].client_resource_name].private_ip : var.resource_map.vm_by_name[var.deployment_plan.db[count.index].client_resource_name].public_ip
    user         = "root"
    private_key  = local.private_key_pem
    password     = var.resource_map.vm_by_name[var.deployment_plan.db[count.index].client_resource_name].password
  }

  provisioner "file" {
    content = <<-EOT
      DATE_TIME=${timestamp()}
      HOST_RESOURCE_NAME=${var.deployment_plan.db[count.index].client_resource_name}
      HOST_PRIVATE_IP=${var.resource_map.vm_by_name[var.deployment_plan.db[count.index].client_resource_name].private_ip}

      WECUBE_RELEASE_VERSION=${var.wecube_release_version}
      WECUBE_SETTINGS=${var.wecube_settings}
      WECUBE_HOME='${var.wecube_home}'
      WECUBE_USER='${var.wecube_user}'
      INITIAL_PASSWORD=${var.initial_password}
      USE_MIRROR_IN_MAINLAND_CHINA=${var.use_mirror_in_mainland_china}

      DB_HOST=${local.db_plan_env_by_name[var.deployment_plan.db[count.index].name].db_host}
      DB_PORT=${local.db_plan_env_by_name[var.deployment_plan.db[count.index].name].db_port}
      DB_NAME=${local.db_plan_env_by_name[var.deployment_plan.db[count.index].name].db_name}
      DB_USERNAME=${local.db_plan_env_by_name[var.deployment_plan.db[count.index].name].db_username}
      DB_PASSWORD=${local.db_plan_env_by_name[var.deployment_plan.db[count.index].name].db_password}
    EOT
    destination = "${var.wecube_home}/installer/db-deployment-${var.deployment_plan.db[count.index].name}.env"
  }

  provisioner "remote-exec" {
    inline = [
      "find ${var.wecube_home}/installer -name \"*.env\" -exec chmod 600 {} +",
      "${var.wecube_home}/installer/invoke-installer.sh ${var.wecube_home}/installer/db-deployment-${var.deployment_plan.db[count.index].name}.env ${var.deployment_plan.db[count.index].installer}"
    ]
  }
}


resource "null_resource" "app_deployments" {
  count = length(var.deployment_plan.app)

  depends_on = [null_resource.db_deployments]

  connection {
    type         = "ssh"
    bastion_host = local.use_bastion_host ? var.resource_map.vm_by_name[var.bastion_host_name].public_ip : null
    host         = local.use_bastion_host ? var.resource_map.vm_by_name[var.deployment_plan.app[count.index].resource_name].private_ip : var.resource_map.vm_by_name[var.deployment_plan.app[count.index].resource_name].public_ip
    user         = "root"
    private_key  = local.private_key_pem
    password     = var.resource_map.vm_by_name[var.deployment_plan.app[count.index].resource_name].password
  }

  provisioner "file" {
    content = <<-EOT
      DATE_TIME=${timestamp()}
      HOST_RESOURCE_NAME=${var.deployment_plan.app[count.index].resource_name}
      HOST_PRIVATE_IP=${var.resource_map.vm_by_name[var.deployment_plan.app[count.index].resource_name].private_ip}

      WECUBE_RELEASE_VERSION=${var.wecube_release_version}
      WECUBE_SETTINGS=${var.wecube_settings}
      WECUBE_HOME='${var.wecube_home}'
      WECUBE_USER='${var.wecube_user}'
      INITIAL_PASSWORD=${var.initial_password}
      USE_MIRROR_IN_MAINLAND_CHINA=${var.use_mirror_in_mainland_china}

      # PRIVATE IP
      %{ for var_name, host_names in var.deployment_plan.app[count.index].inject_private_ip }
      # ${var_name}
      ${var_name}=${join(",", [for host_name in split(",", host_names) : lookup(var.resource_map.private_ip_by_name, host_name, "")])}
      %{ endfor }

      # DB ENV
      %{ for var_prefix, db_plan_name in var.deployment_plan.app[count.index].inject_db_plan_env }
      # ${var_prefix}
      ${var_prefix}_HOST=${local.db_plan_env_by_name[db_plan_name].db_host}
      ${var_prefix}_PORT=${local.db_plan_env_by_name[db_plan_name].db_port}
      ${var_prefix}_NAME=${local.db_plan_env_by_name[db_plan_name].db_name}
      ${var_prefix}_USERNAME=${local.db_plan_env_by_name[db_plan_name].db_username}
      ${var_prefix}_PASSWORD=${local.db_plan_env_by_name[db_plan_name].db_password}
      %{ endfor }
    EOT
    destination = "${var.wecube_home}/installer/app-deployment-${var.deployment_plan.app[count.index].name}.env"
  }

  provisioner "remote-exec" {
    inline = [
      "find ${var.wecube_home}/installer -name \"*.env\" -exec chmod 600 {} +",
      "${var.wecube_home}/installer/invoke-installer.sh ${var.wecube_home}/installer/app-deployment-${var.deployment_plan.app[count.index].name}.env ${var.deployment_plan.app[count.index].installer}"
    ]
  }
}


resource "tencentcloud_clb_listener" "lb_listeners" {
  count = length(var.deployment_plan.lb)

  depends_on = [null_resource.app_deployments]

  clb_id        = var.resource_map.lb_by_name[var.deployment_plan.lb[count.index].resource_name].id
  listener_name = var.deployment_plan.lb[count.index].name
  protocol      = var.deployment_plan.lb[count.index].protocol
  port          = var.deployment_plan.lb[count.index].port
}
resource "tencentcloud_clb_listener_rule" "lb_listener_rules" {
  count = length(var.deployment_plan.lb)

  clb_id                     = var.resource_map.lb_by_name[var.deployment_plan.lb[count.index].resource_name].id
  listener_id                = local.lb_listener_by_name[var.deployment_plan.lb[count.index].name].listener_id
  domain                     = var.resource_map.lb_by_name[var.deployment_plan.lb[count.index].resource_name].clb_vips[0]
  url                        = var.deployment_plan.lb[count.index].path
  health_check_switch        = true
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  health_check_http_code     = 2
  health_check_http_domain   = var.resource_map.lb_by_name[var.deployment_plan.lb[count.index].resource_name].clb_vips[0]
  health_check_http_path     = var.deployment_plan.lb[count.index].health_check_path
  health_check_http_method   = "GET"
  session_expire_time        = 180
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "lb_attachments" {
  count = length(local.lb_back_ends)

  clb_id      = local.lb_back_ends[count.index].clb_id
  listener_id = local.lb_back_ends[count.index].listener_id
  rule_id     = local.lb_back_ends[count.index].rule_id
  targets {
    instance_id = local.lb_back_ends[count.index].instance_id
    port        = local.lb_back_ends[count.index].port
    weight      = local.lb_back_ends[count.index].weight
  }
}


resource "null_resource" "post_deployment_steps" {
  count = length(var.deployment_plan.post_deploy)

  depends_on = [
    null_resource.db_deployments,
    null_resource.app_deployments,
    tencentcloud_clb_listener.lb_listeners,
    tencentcloud_clb_listener_rule.lb_listener_rules,
    tencentcloud_clb_attachment.lb_attachments,
  ]

  connection {
    type         = "ssh"
    bastion_host = local.use_bastion_host ? var.resource_map.vm_by_name[var.bastion_host_name].public_ip : null
    host         = local.use_bastion_host ? var.resource_map.vm_by_name[var.deployment_plan.post_deploy[count.index].resource_name].private_ip : var.resource_map.vm_by_name[var.deployment_plan.post_deploy[count.index].resource_name].public_ip
    user         = "root"
    private_key  = local.private_key_pem
    password     = var.resource_map.vm_by_name[var.deployment_plan.post_deploy[count.index].resource_name].password
  }

  provisioner "file" {
    content = <<-EOT
      DATE_TIME=${timestamp()}
      HOST_RESOURCE_NAME=${var.deployment_plan.post_deploy[count.index].resource_name}
      HOST_PRIVATE_IP=${var.resource_map.vm_by_name[var.deployment_plan.post_deploy[count.index].resource_name].private_ip}

      WECUBE_RELEASE_VERSION=${var.wecube_release_version}
      WECUBE_SETTINGS=${var.wecube_settings}
      WECUBE_HOME='${var.wecube_home}'
      WECUBE_USER='${var.wecube_user}'
      INITIAL_PASSWORD=${var.initial_password}
      USE_MIRROR_IN_MAINLAND_CHINA=${var.use_mirror_in_mainland_china}

      %{ for var_name, var_value in var.deployment_plan.post_deploy[count.index].inject_env }
      ${var_name}=${var_value}
      %{ endfor }

      # ASSETS
      %{ for var_name, resource_names in var.deployment_plan.post_deploy[count.index].inject_asset_data }
      # ${var_name}
      ${var_name}_ASSET_NAME=${join(",", [for resource_name in split(",", resource_names) : split("/", resource_name)[1]])}
      ${var_name}_ASSET_ID=${join(",", [for resource_name in split(",", resource_names) : var.resource_map.asset_id_by_name[resource_name]])}
      ${var_name}_PRIVATE_IP=${join(",", [for resource_name in split(",", resource_names) : lookup(var.resource_map.private_ip_by_name, split("/", resource_name)[1], "")])}
      %{ endfor }

      # PRIVATE IP
      %{ for var_name, host_names in var.deployment_plan.post_deploy[count.index].inject_private_ip }
      # ${var_name}
      ${var_name}=${join(",", [for host_name in split(",", host_names) : lookup(var.resource_map.private_ip_by_name, host_name, "")])}
      %{ endfor }

      # DB ENV
      %{ for var_prefix, db_plan_name in var.deployment_plan.post_deploy[count.index].inject_db_plan_env }
      # ${var_prefix}
      ${var_prefix}_HOST=${local.db_plan_env_by_name[db_plan_name].db_host}
      ${var_prefix}_PORT=${local.db_plan_env_by_name[db_plan_name].db_port}
      ${var_prefix}_NAME=${local.db_plan_env_by_name[db_plan_name].db_name}
      ${var_prefix}_USERNAME=${local.db_plan_env_by_name[db_plan_name].db_username}
      ${var_prefix}_PASSWORD=${local.db_plan_env_by_name[db_plan_name].db_password}
      %{ endfor }
    EOT
    destination = "${var.wecube_home}/installer/app-deployment-${var.deployment_plan.post_deploy[count.index].name}.env"
  }

  provisioner "remote-exec" {
    inline = [
      "find ${var.wecube_home}/installer -name \"*.env\" -exec chmod 600 {} +",
      "${var.wecube_home}/installer/invoke-installer.sh ${var.wecube_home}/installer/app-deployment-${var.deployment_plan.post_deploy[count.index].name}.env ${var.deployment_plan.post_deploy[count.index].installer}"
    ]
  }
}

resource "null_resource" "post_gen_asset_json" {
  depends_on = [
    null_resource.post_deployment_steps,
  ]

  provisioner "local-exec" {
      command = "./gen_asset_json.sh"
  }
}
output "resource_map" {
  value = local.is_tencentcloud_enabled ? module.tencentcloud[0].resource_map : module.aws[0].resource_map
}

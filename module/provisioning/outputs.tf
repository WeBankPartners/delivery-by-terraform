output "resource_map" {
  value = {
    vm_by_name = {for vm in local.combined_vm_instances              : vm.instance_name => vm}
    db_by_name = {for db in tencentcloud_mysql_instance.db_instances : db.instance_name => db}
    lb_by_name = {for lb in tencentcloud_clb_instance.lb_instances   : lb.clb_name      => lb}

    asset_id_by_name = merge({
        for vpc in tencentcloud_vpc.vpcs : vpc.name => vpc.id
      }, merge({
        for sn in tencentcloud_subnet.subnets : sn.name => sn.id
      }, {
        for rt in tencentcloud_route_table.route_tables : rt.name => rt.id
      }, merge({
        for sg in tencentcloud_security_group.security_groups : sg.name => sg.id
      }, merge({
        for vm in local.combined_vm_instances : vm.instance_name => vm.id
      }, merge({
        for db in tencentcloud_mysql_instance.db_instances : db.instance_name => db.id
      }, merge({
        for lb in tencentcloud_clb_instance.lb_instances : lb.clb_name => lb.id
      }
    ))))))

    private_ip_by_name = merge({
        for vm in local.combined_vm_instances : vm.instance_name => vm.private_ip
      }, merge({
        for lb in tencentcloud_clb_instance.lb_instances : lb.clb_name => lb.clb_vips[0]
      }
    ))

    entrypoint_ip_by_name = merge({
        for vm in local.combined_vm_instances : vm.instance_name => lookup(vm, "public_ip", "")
      }, merge({
        for lb in tencentcloud_clb_instance.lb_instances : lb.clb_name => lb.clb_vips[0]
      }
    ))
  }
}

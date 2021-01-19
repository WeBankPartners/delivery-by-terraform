output "resource_map" {
  value = {
    vm_by_name = {for vm in local.combined_vm_instances              : vm.instance_name => vm}
    db_by_name = {}#{for db in tencentcloud_mysql_instance.db_instances : db.instance_name => db}
    lb_by_name = {}#{for lb in tencentcloud_clb_instance.lb_instances   : lb.clb_name      => lb}

    asset_id_by_name = merge({
        for vpc in aws_vpc.vpcs : "vpc/${vpc.tags.Name}" => vpc.id
      }, {
        for sn in aws_subnet.subnets : "sn/${sn.tags.Name}" => sn.id
      }, {
        for rt in aws_route_table.route_tables : "rt/${rt.tags.Name}" => rt.id
      }, {
        for sg in aws_security_group.security_groups : "sg/${sg.name}" => sg.id
      }, {
        #for vm in local.combined_vm_instances : "vm/${vm.instance_name}" => vm.id
      }, {
        #for db in tencentcloud_mysql_instance.db_instances : "db/${db.instance_name}" => db.id
      }, {
        #for lb in tencentcloud_clb_instance.lb_instances : "lb/${lb.clb_name}" => lb.id
      }
    )

    private_ip_by_name = merge({
        #for vm in local.combined_vm_instances : vm.instance_name => vm.private_ip
      }, {
        #for db in tencentcloud_mysql_instance.db_instances : db.instance_name => db.intranet_ip
      }, {
        #for lb in tencentcloud_clb_instance.lb_instances : lb.clb_name => lb.clb_vips[0]
      }
    )

    entrypoint_ip_by_name = merge({
        #for vm in local.combined_vm_instances : vm.instance_name => lookup(vm, "public_ip", "")
      }, {
        #for lb in tencentcloud_clb_instance.lb_instances : lb.clb_name => lb.clb_vips[0]
      }
    )
  }
}

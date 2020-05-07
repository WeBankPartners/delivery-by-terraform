#创建VPC
resource "huaweicloud_vpc_v1" "vpc_mg" {
  name = "${var.vpc_name}"
  cidr = "10.128.192.0/19"
}

#创建子网 - VDI Windows运行子网
resource "huaweicloud_vpc_subnet_v1" "subnet_vdi" {
  name              = "${var.subnet_vdi_name}"
  cidr              = "10.128.196.0/24"
  gateway_ip        = "10.128.196.1"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_master}"
}
#创建子网 - subnet_proxy
resource "huaweicloud_vpc_subnet_v1" "subnet_proxy" {
  name              = "${var.subnet_proxy_name}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.199.0/24"
  gateway_ip        = "10.128.199.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_master}"
}
#创建子网 - PRD1_MG_LB
resource "huaweicloud_vpc_subnet_v1" "subnet_lb1" {
  name              = "${var.subnet_lb1_name}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.200.0/24"
  gateway_ip        = "10.128.200.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_master}"
}
#创建子网 - PRD2_MG_LB
resource "huaweicloud_vpc_subnet_v1" "subnet_lb2" {
  name              = "${var.subnet_lb2_name}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.216.0/24"
  gateway_ip        = "10.128.216.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_slave}"
}
#创建子网- Wecube Platform组件运行的实例 PRD1_MG_APP
resource "huaweicloud_vpc_subnet_v1" "subnet_app1" {
  name              = "${var.subnet_app1_name}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.202.0/24"
  gateway_ip        = "10.128.202.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_master}"
}
#创建子网- Wecube Platform组件运行的实例 PRD2_MG_APP
resource "huaweicloud_vpc_subnet_v1" "subnet_app2" {
  name              = "${var.subnet_app2_name}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.218.0/24"
  gateway_ip        = "10.128.218.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_slave}"
}
#创建子网 - WeCube持久化存储的子网 PRD1_MG_RDB
resource "huaweicloud_vpc_subnet_v1" "subnet_db1" {
  name              = "${var.subnet_db1_name}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.206.0/24"
  gateway_ip        = "10.128.206.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_master}"
}
#创建子网 - WeCube持久化存储的子网 PRD2_MG_RDB
resource "huaweicloud_vpc_subnet_v1" "subnet_db2" {
  name              = "${var.subnet_db2_name}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.222.0/24"
  gateway_ip        = "10.128.222.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_slave}"
}


#创建安全组 - for PRD_MG
resource "huaweicloud_networking_secgroup_v2" "sg_mg" {
  name        = "${var.vpc_name}"
  description = "Wecube Security Group"
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_all_mg_tcp_in" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_mg.id}"
  direction         = "ingress"
  remote_ip_prefix  = "10.128.192.0/19"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_all_mg_tcp_out" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_mg.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.192.0/19"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
#for LB health-check
resource "huaweicloud_networking_secgroup_rule_v2" "allow_lb_tcp_in19090" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_mg.id}"
  direction         = "ingress"
  remote_ip_prefix  = "100.125.0.0/16"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 19090
  port_range_max    = 19090
}


#创建安全组 - for PRD1_MG_PROXY
resource "huaweicloud_networking_secgroup_v2" "sg_proxy" {
  name        = "PRD1_MG_PROXY"
  description = "Wecube PRD1_MG_PROXY"
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_PROXY_ACCEPT_NDC_WAN_ingress22" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_proxy.id}"
  direction         = "ingress"
  remote_ip_prefix  = "${var.current_ip}"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_PROXY_ACCEPT_NDC_WAN_egress80-443" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_proxy.id}"
  direction         = "egress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 443
}

#创建安全组 - for PRD1_MG_OVDI
resource "huaweicloud_networking_secgroup_v2" "sg_ovdi" {
  name        = "PRD1_MG_OVDI"
  description = "Wecube PRD1_MG_OVDI"
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_OVDI_ACCEPT_NDC_WAN_egress1-65535" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_ovdi.id}"
  direction         = "egress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_OVDI_ACCEPT_NDC_WAN_ingress22" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_ovdi.id}"
  direction         = "ingress"
  remote_ip_prefix  = "${var.current_ip}"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 3389
  port_range_max    = 3389
}

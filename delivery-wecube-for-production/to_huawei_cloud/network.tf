#创建VPC
resource "huaweicloud_vpc_v1" "vpc_mg" {
  name = "PRD_MG"
  cidr = "10.128.192.0/19"
}

#创建子网 - VDI Windows运行子网
resource "huaweicloud_vpc_subnet_v1" "subnet_vdi" {
  name              = "PRD1_MG_OVDI"
  cidr              = "10.128.196.0/24"
  gateway_ip        = "10.128.196.1"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_master}"
}
#创建子网 - subnet_proxy
resource "huaweicloud_vpc_subnet_v1" "subnet_proxy" {
  name              = "PRD1_MG_PROXY"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.199.0/24"
  gateway_ip        = "10.128.199.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_master}"
}
#创建子网 - PRD1_MG_LB
resource "huaweicloud_vpc_subnet_v1" "subnet_lb1" {
  name              = "PRD1_MG_LB"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.200.0/24"
  gateway_ip        = "10.128.200.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_master}"
}
#创建子网 - PRD2_MG_LB
resource "huaweicloud_vpc_subnet_v1" "subnet_lb2" {
  name              = "PRD2_MG_LB"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.216.0/24"
  gateway_ip        = "10.128.216.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_slave}"
}
#创建子网- Wecube Platform组件运行的实例 PRD1_MG_APP
resource "huaweicloud_vpc_subnet_v1" "subnet_app1" {
  name              = "PRD1_MG_APP"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.202.0/24"
  gateway_ip        = "10.128.202.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_master}"
}
#创建子网- Wecube Platform组件运行的实例 PRD2_MG_APP
resource "huaweicloud_vpc_subnet_v1" "subnet_app2" {
  name              = "PRD1_MG_APP"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.218.0/24"
  gateway_ip        = "10.128.218.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_slave}"
}
#创建子网 - WeCube持久化存储的子网 PRD1_MG_RDB
resource "huaweicloud_vpc_subnet_v1" "subnet_db1" {
  name              = "PRD1_MG_RDB"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.206.0/24"
  gateway_ip        = "10.128.206.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_master}"
}
#创建子网 - WeCube持久化存储的子网 PRD2_MG_RDB
resource "huaweicloud_vpc_subnet_v1" "subnet_db2" {
  name              = "PRD2_MG_RDB"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  cidr              = "10.128.222.0/24"
  gateway_ip        = "10.128.222.1"
  primary_dns       = "${var.hw_dns1}"
  secondary_dns     = "${var.hw_dns2}"
  availability_zone = "${var.hw_az_slave}"
}


#创建安全组 - for PRD_MG
resource "huaweicloud_networking_secgroup_v2" "sg_mg" {
  name        = "PRD_MG"
  description = "Wecube PRD_MG"
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
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_PROXY_ACCEPT_PRD_MG_egress22" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_proxy.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.192.0/19"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
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
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_OVDI_ACCEPT_PRD1_MG_APP_egress80-19999" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_ovdi.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.202.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 19999
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_OVDI_ACCEPT_PRD2_MG_APP_egress80-19999" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_ovdi.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.218.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 19999
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_OVDI_ACCEPT_PRD1_MG_LB_egress80-19999" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_ovdi.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.200.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 19999
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_OVDI_ACCEPT_PRD2_MG_LB_egress80-19999" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_ovdi.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.216.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 19999
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


#创建安全组 - for PRD1_MG_APP
resource "huaweicloud_networking_secgroup_v2" "sg_app1" {
  name        = "PRD1_MG_APP"
  description = "Wecube PRD1_MG_APP"
}
#LB的健康检查
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_APP_ACCEPT_LB_ingress1-65535" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app1.id}"
  direction         = "ingress"
  remote_ip_prefix  = "100.125.0.0/16"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_APP_ACCEPT_PRD1_MG_PROXY_egress3128" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app1.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.199.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 3128
  port_range_max    = 3128
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_APP_ACCEPT_PRD1_MG_RDB_egress3306" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app1.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.206.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 3306
  port_range_max    = 3306
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_APP_ACCEPT_PRD2_MG_RDB_egress3306" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app1.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.222.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 3306
  port_range_max    = 3306
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_APP_ACCEPT_PRD1_MG_APP_egress1-65535" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app1.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.202.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_APP_ACCEPT_PRD2_MG_APP_egress1-65535" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app1.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.218.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_APP_ACCEPT_PRD1_MG_LB_egress80-19999" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app1.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.200.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 19999
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD1_MG_APP_ACCEPT_PRD2_MG_LB_egress80-19999" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app1.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.216.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 19999
}

#创建安全组 - for PRD2_MG_APP
resource "huaweicloud_networking_secgroup_v2" "sg_app2" {
  name        = "PRD2_MG_APP"
  description = "Wecube PRD2_MG_APP"
}
#LB的健康检查
resource "huaweicloud_networking_secgroup_rule_v2" "PRD2_MG_APP_ACCEPT_LB_ingress1-65535" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app2.id}"
  direction         = "ingress"
  remote_ip_prefix  = "100.125.0.0/16"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD2_MG_APP_ACCEPT_PRD1_MG_PROXY_egress3128" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app2.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.199.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 3128
  port_range_max    = 3128
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD2_MG_APP_ACCEPT_PRD1_MG_RDB_egress3306" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app2.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.206.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 3306
  port_range_max    = 3306
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD2_MG_APP_ACCEPT_PRD2_MG_RDB_egress3306" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app2.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.222.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 3306
  port_range_max    = 3306
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD2_MG_APP_ACCEPT_PRD1_MG_APP_egress1-65535" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app2.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.202.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD2_MG_APP_ACCEPT_PRD2_MG_APP_egress1-65535" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app2.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.218.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD2_MG_APP_ACCEPT_PRD1_MG_LB_egress80-19999" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app2.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.200.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 19999
}
resource "huaweicloud_networking_secgroup_rule_v2" "PRD2_MG_APP_ACCEPT_PRD2_MG_LB_egress80-19999" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_app2.id}"
  direction         = "egress"
  remote_ip_prefix  = "10.128.216.0/24"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 19999
}
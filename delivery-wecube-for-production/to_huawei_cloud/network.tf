#创建VPC
resource "huaweicloud_vpc_v1" "wecube_vpc" {
  name = "WECUBE_VPC"
  cidr = "10.128.192.0/19"
}

#创建子网 - VDI Windows运行子网
resource "huaweicloud_vpc_subnet_v1" "subnet_vdi" {
  name       = "SUBNET_VDI"
  cidr       = "10.128.195.0/24"
  gateway_ip = "10.128.195.1"
  vpc_id     = "${huaweicloud_vpc_v1.wecube_vpc.id}"
  primary_dns = "${var.hw_dns1}"
  secondary_dns = "${var.hw_dns2}"
}
#创建子网- Wecube Platform组件运行的实例
resource "huaweicloud_vpc_subnet_v1" "subnet_app" {
  name       = "SUBNET_WECUBE_APP"
  vpc_id     = "${huaweicloud_vpc_v1.wecube_vpc.id}"
  cidr       = "10.128.194.0/25"
  gateway_ip = "10.128.194.1"
  primary_dns = "${var.hw_dns1}"
  secondary_dns = "${var.hw_dns2}"
}
#创建子网 - WeCube持久化存储的子网
resource "huaweicloud_vpc_subnet_v1" "subnet_db" {
  name       = "SUBNET_WECUBE_DB"
  vpc_id     = "${huaweicloud_vpc_v1.wecube_vpc.id}"
  cidr       = "10.128.194.128/26"
  gateway_ip = "10.128.194.129"
  primary_dns = "${var.hw_dns1}"
  secondary_dns = "${var.hw_dns2}"
}


#创建安全组 - for WeCube Storage(sg_group_wecube_db)
resource "huaweicloud_networking_secgroup_v2" "sg_group_wecube_db" {
  name        = "SG_WECUBE_DB"
  description = "Wecube Security Group"
}
#创建安全组规则
resource "huaweicloud_networking_secgroup_rule_v2" "allow_all_tcp_for_db" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_db.id}"
  direction         = "ingress"
  remote_ip_prefix  = "10.128.192.0/19"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
#创建安全组规则
resource "huaweicloud_networking_secgroup_rule_v2" "allow_3306_tcp" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_db.id}"
  direction         = "ingress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 3306
  port_range_max    = 3307
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_9001_tcp" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_db.id}"
  direction         = "ingress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 9001
  port_range_max    = 9001
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_22_tcp_db" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_db.id}"
  direction         = "ingress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_all_db_tcp_out" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_db.id}"
  direction         = "egress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}



#创建安全组  -- for WeCube APP
resource "huaweicloud_networking_secgroup_v2" "sg_group_wecube_app" {
  name        = "SG_WECUBE_APP"
  description = "Wecube Security Group"
}
#创建安全组规则
resource "huaweicloud_networking_secgroup_rule_v2" "allow_all_tcp_for_app" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_app.id}"
  direction         = "ingress"
  remote_ip_prefix  = "10.128.192.0/19"
  protocol          = "tcp"
  ethertype         = "IPv4"
  port_range_min    = 1
  port_range_max    = 65535
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_2375_tcp" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_app.id}"
  direction         = "ingress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  port_range_min    = 2375
  port_range_max    = 2375
  ethertype         = "IPv4"
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_22_tcp" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_app.id}"
  direction         = "ingress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  ethertype         = "IPv4"
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_19090_tcp" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_app.id}"
  direction         = "ingress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  port_range_min    = 19090
  port_range_max    = 19090
  ethertype         = "IPv4"
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_3128_tcp_for_app" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_app.id}"
  direction         = "ingress"
  remote_ip_prefix  = "10.128.192.0/19"
  protocol          = "tcp"
  port_range_min    = 3128
  port_range_max    = 3128
  ethertype         = "IPv4"
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_all_tcp_out" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_app.id}"
  direction         = "egress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  ethertype         = "IPv4"
}



#创建安全组  -- for VDI-windows
resource "huaweicloud_networking_secgroup_v2" "sg_group_wecube_vdi" {
  name        = "SG_WECUBE_VDI"
  description = "Wecube Security Group"
}
#创建安全组规则
resource "huaweicloud_networking_secgroup_rule_v2" "allow_3389_tcp" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_vdi.id}"
  direction         = "ingress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  port_range_min    = 3389
  port_range_max    = 3389
  ethertype         = "IPv4"
}
resource "huaweicloud_networking_secgroup_rule_v2" "allow_all_vdi_tcp_out" {
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_vdi.id}"
  direction         = "egress"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  ethertype         = "IPv4"
}

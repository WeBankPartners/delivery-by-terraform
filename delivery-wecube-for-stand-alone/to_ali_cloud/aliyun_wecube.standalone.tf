#全局变量
variable "instance_root_password" {
  default = "Wecube@123456"
}

variable "mysql_root_password" {
  default = "Wecube@123456"
}

variable "wecube_version" {
  default = "v2.3.1"
}

variable "wecube_home" {
  default = "/data/wecube"
}
variable "region" {
  default = "cn-hangzhou"
}
variable "access_key" {
}
variable "secret_key" {
}
variable "is_install_plugins" {
    description = "Only 'Y' will be accepted to auto install plugins"
}

provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

#创建VPC
resource "alicloud_vpc" "vpc" {
  name       = "HZ_MGMT"
  cidr_block = "10.128.192.0/19"
}

#创建交换机（子网）- Wecube Platform组件运行的实例
resource "alicloud_vswitch" "switch_app" {
  name              = "HZPB_MGMT_MT_APP"
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "10.128.202.0/25"
  availability_zone = "cn-hangzhou-i"
}

#创建安全组
resource "alicloud_security_group" "sc_group" {
  name        = "SG_WECUBE"
  description = "Wecube Security Group"
  vpc_id      = "${alicloud_vpc.vpc.id}"
}

#创建安全规则入站
resource "alicloud_security_group_rule" "allow_19090_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "19090/19090"
  priority          = 1
  security_group_id = "${alicloud_security_group.sc_group.id}"
  cidr_ip           = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "allow_22_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 2
  security_group_id = "${alicloud_security_group.sc_group.id}"
  cidr_ip           = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "allow_9000_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "9000/9000"
  priority          = 3
  security_group_id = "${alicloud_security_group.sc_group.id}"
  cidr_ip           = "0.0.0.0/0"
}

#创建安全规则出站
resource "alicloud_security_group_rule" "allow_all_tcp_out" {
  type              = "egress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = "${alicloud_security_group.sc_group.id}"
  cidr_ip           = "0.0.0.0/0"
}

#创建WeCube Platform主机
resource "alicloud_instance" "instance_wecube_platform" {
  availability_zone = "cn-hangzhou-i"  
  security_groups   = "${alicloud_security_group.sc_group.*.id}"
  instance_type              = "ecs.g6.xlarge"
  image_id          = "centos_7_7_x64_20G_alibase_20191225.vhd"
  system_disk_category       = "cloud_efficiency"
  instance_name              = "instance_wecube_platform"
  vswitch_id                 = "${alicloud_vswitch.switch_app.id}"
  private_ip         ="10.128.202.3"
  internet_max_bandwidth_out = 10
  password ="${var.instance_root_password}"

#初始化配置
  connection {
    type     = "ssh"
    user     = "root"
    password = "${var.instance_root_password}"
    host     = "${alicloud_instance.instance_wecube_platform.public_ip}"
  }
  
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.wecube_home}/installer"
    ]
  }

  provisioner "file" {
    source      = "../application/"
    destination = "${var.wecube_home}/installer"
  }

  provisioner "remote-exec" {
    inline = [
    "chmod +x ${var.wecube_home}/installer/wecube/*.sh",
	  "yum install dos2unix -y",
    "dos2unix ${var.wecube_home}/installer/wecube/*",
	  "cd ${var.wecube_home}/installer/wecube",
	  "./install-wecube.sh ${alicloud_instance.instance_wecube_platform.private_ip} ${var.mysql_root_password} ${var.wecube_version} ${var.wecube_home} ${var.is_install_plugins}"
    ]
  }

  provisioner "local-exec" {
    command = "rm -rf application"
  }
}

output "wecube_website" {
  value="http://${alicloud_instance.instance_wecube_platform.public_ip}:19090"
}

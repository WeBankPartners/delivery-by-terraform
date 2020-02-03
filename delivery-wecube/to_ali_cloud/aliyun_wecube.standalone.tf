#全局变量
variable "docker_registry_password" {
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_docker_registry_password'"
  default = "Wecube123"
}

variable "instance_root_password" {
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_instance_root_password'"
  default = "Wecube123"
}

variable "mysql_root_password" {
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_mysql_root_password'"
  default = "Wecube123"
}

variable "wecube_version" {
  description = "You can override the value by setup os env variable - 'TF_VAR_wecube_version'"
  default = "20200110114202-f6daac4"
}

#创建VPC
resource "alicloud_vpc" "vpc" {
  name       = "VPC_WECUBE"
  cidr_block = "10.0.0.0/21"
}

#创建交换机（子网）- Wecube Platform组件运行的实例
resource "alicloud_vswitch" "switch_app" {
  name              = "SWITCH_WECUBE_APP"
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "cn-hangzhou-b"
}

#创建交换机（子网）- Wecube Platform数据持久化的实例
resource "alicloud_vswitch" "switch_db" {
  name              = "SWITCH_WECUBE_DB"
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "cn-hangzhou-b"
}

#创建安全组
resource "alicloud_security_group" "sc_group" {
  name        = "SG_WECUBE"
  description = "Wecube Security Group"
  vpc_id      = "${alicloud_vpc.vpc.id}"
}

#创建安全规则入站
resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = "${alicloud_security_group.sc_group.id}"
  cidr_ip           = "0.0.0.0/0"
}

#创建安全规则
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
  availability_zone = "cn-hangzhou-b"  
  security_groups   = "${alicloud_security_group.sc_group.*.id}"
  instance_type              = "ecs.n4.large"
  #image_id          = "centos_8_0_x64_20G_alibase_20191225.vhd"
  image_id          = "centos_7_7_x64_20G_alibase_20191225.vhd"
  system_disk_category       = "cloud_efficiency"
  instance_name              = "instance_wecube_platform"
  vswitch_id                 = "${alicloud_vswitch.switch_app.id}"
  private_ip         ="10.0.0.7"
  internet_max_bandwidth_out = 10
  password ="${var.instance_root_password}"

#初始化配置
  connection {
    type     = "ssh"
    user     = "root"
    password = "${var.instance_root_password}"
    host     = "${alicloud_instance.instance_wecube_platform.public_ip}"
  }

  provisioner "local-exec" {
    command = "cp -r ../application application"
  }

  provisioner "file" {
    source      = "../application"
    destination = "/root/application"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/application/wecube/*.sh",
	  "yum install dos2unix -y",
      "dos2unix /root/application/wecube/*",
	  "cd /root/application/wecube",
	  "./install-wecube.sh ${alicloud_instance.instance_wecube_platform.private_ip} ${var.docker_registry_password} ${var.mysql_root_password} ${var.wecube_version}"
    ]
  }

  provisioner "local-exec" {
    command = "rm -rf application"
  }
}

output "wecube_website" {
  value="http://${alicloud_instance.instance_wecube_platform.public_ip}:19090"
}
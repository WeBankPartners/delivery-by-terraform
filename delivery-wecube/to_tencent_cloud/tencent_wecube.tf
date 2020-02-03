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
  default = "20200122120309-d199812"
}

#创建VPC
resource "tencentcloud_vpc" "vpc" {
  name       = "VPC_WECUBE"
  cidr_block = "10.0.0.0/21"
}

#创建交换机（子网）- Wecube Platform组件运行的实例
resource "tencentcloud_subnet" "subnet_app" {
  name              = "SUBNET_WECUBE_APP"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-chengdu-1"
}

#创建安全组
resource "tencentcloud_security_group" "sc_group" {
  name        = "SG_WECUBE"
  description = "Wecube Security Group"
}

#创建安全规则入站
resource "tencentcloud_security_group_rule" "allow_all_tcp" {
  security_group_id = "${tencentcloud_security_group.sc_group.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "1-65535"
  policy            = "accept"

}

#创建安全规则
resource "tencentcloud_security_group_rule" "allow_all_tcp_out" {
  security_group_id = "${tencentcloud_security_group.sc_group.id}"
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "1-65535"
  policy            = "accept"
}

#创建WeCube Platform主机
resource "tencentcloud_instance" "instance_wecube_platform" {
  availability_zone = "ap-chengdu-1"  
  security_groups   = "${tencentcloud_security_group.sc_group.*.id}"
  #instance_type     = "S5.SMALL2"
  instance_type     = "S5.LARGE8"
  image_id          = "img-oikl1tzv"
  instance_name     = "instance_wecube_platform"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  subnet_id         = "${tencentcloud_subnet.subnet_app.id}"
  system_disk_type  = "CLOUD_PREMIUM"
  allocate_public_ip = true
  private_ip        ="10.0.0.7"
  internet_max_bandwidth_out = 10
  password ="${var.instance_root_password}"

#初始化配置
  connection {
    type     = "ssh"
    user     = "root"
    password = "${var.instance_root_password}"
    host     = "${tencentcloud_instance.instance_wecube_platform.public_ip}"
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
	  "./install-wecube.sh ${tencentcloud_instance.instance_wecube_platform.private_ip} ${var.docker_registry_password} ${var.mysql_root_password} ${var.wecube_version}"
    ]
  }
}

output "wecube_website" {
  value="http://${tencentcloud_instance.instance_wecube_platform.public_ip}:19090"
}
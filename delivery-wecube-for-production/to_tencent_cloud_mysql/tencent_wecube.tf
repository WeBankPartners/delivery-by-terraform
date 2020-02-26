#全局变量
variable "default_password" {
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_default_password'"
  default = "WeCube1qazXSW@"
}
variable "wecube_version" {
  description = "You can override the value by setup os env variable - 'TF_VAR_wecube_version'"
  default = "20200212234110-08d00fc"
}
variable "deploy_availability_zone" {
  description = "You can override the value by setup os env variable - 'TF_VAR_deploy_availability_zone'"
  default = "ap-guangzhou-4"
}
variable "plugin_resource_s3_port" {
  description = "You can override the value by setup os env variable - 'TF_VAR_plugin_resource_s3_port'"
  default = "9001"
}
variable "plugin_resource_s3_access_key" {
  description = "You can override the value by setup os env variable - 'TF_VAR_plugin_resource_s3_access_key'"
  default = "s3_access"
}
variable "plugin_resource_s3_secret_key" {
  description = "You can override the value by setup os env variable - 'TF_VAR_plugin_resource_s3_secret_key'"
  default = "s3_secret"
}


#创建VPC
resource "tencentcloud_vpc" "vpc" {
  name       = "GZ_MGMT"
  cidr_block = "10.128.192.0/19"
}


#创建子网 - VDI Windows运行子网
resource "tencentcloud_subnet" "subnet_vdi" {
  name              = "SUBNET_VDI"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  cidr_block        = "10.128.195.0/24"
  availability_zone = "${var.deploy_availability_zone}"
}
#创建子网- Wecube Platform组件运行的实例
resource "tencentcloud_subnet" "subnet_app" {
  name              = "SUBNET_WECUBE_APP"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  cidr_block        = "10.128.194.0/25"
  availability_zone = "${var.deploy_availability_zone}"
}
#创建子网 - WeCube持久化存储的子网
resource "tencentcloud_subnet" "subnet_db" {
  name              = "SUBNET_WECUBE_DB"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  cidr_block        = "10.128.194.128/26"
  availability_zone = "${var.deploy_availability_zone}"
}



#创建安全组 - sg_group_wecube_db
resource "tencentcloud_security_group" "sg_group_wecube_db" {
  name        = "SG_WECUBE"
  description = "Wecube Security Group"
}
#创建安全规则入站
resource "tencentcloud_security_group_rule" "allow_3306_tcp" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_db.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "3306"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_3307_tcp" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_db.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "3307"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_9001_tcp" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_db.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "9001"
  policy            = "accept"
}


#创建安全组
resource "tencentcloud_security_group" "sg_group_wecube_app" {
  name        = "SG_WECUBE"
  description = "Wecube Security Group"
}
#创建安全规则入站
resource "tencentcloud_security_group_rule" "allow_2375_tcp" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_app.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "2375"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_22_tcp" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_app.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "22"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_19090_tcp" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_app.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "19090"
  policy            = "accept"
}
#创建安全规则出站
resource "tencentcloud_security_group_rule" "allow_all_tcp_out" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_app.id}"
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "1-65535"
  policy            = "accept"
}

#创建WeCube plugin resource主机
resource "tencentcloud_instance" "instance_wecube_plugin_resource" {
  availability_zone = "${var.deploy_availability_zone}"
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_db.*.id}"
  #instance_type     = "S5.LARGE16"
  instance_type     = "S5.MEDIUM4"
  image_id          = "img-oikl1tzv"
  instance_name     = "pluginResourceHost"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  subnet_id         = "${tencentcloud_subnet.subnet_db.id}"
  system_disk_type  = "CLOUD_PREMIUM"
  private_ip        ="10.128.194.130"
  internet_max_bandwidth_out = 10
  password ="${var.default_password}"
}

#创建Squid主机
resource "tencentcloud_instance" "instance_squid" {
  availability_zone = "${var.deploy_availability_zone}"  
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_app.*.id}"
  #instance_type     = "S5.LARGE16"
  instance_type     = "S5.MEDIUM4"
  image_id          = "img-oikl1tzv"
  instance_name     = "instanceSquid"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  subnet_id         = "${tencentcloud_subnet.subnet_app.id}"
  system_disk_type  = "CLOUD_PREMIUM"
  allocate_public_ip = true
  private_ip        ="10.128.194.2"
  internet_max_bandwidth_out = 10
  password ="${var.default_password}"

#初始化配置
  connection {
    type     = "ssh"
    user     = "root"
    password = "${var.default_password}"
    host     = "${tencentcloud_instance.instance_squid.public_ip}"
  }

  provisioner "file" {
    source      = "../scripts"
    destination = "/root/scripts"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/scripts/wecube/*.sh",
	  "yum install dos2unix -y",
	  "yum install -y sshpass",
      "dos2unix /root/scripts/wecube/*",
	  "cd /root/scripts/wecube",
	  "pwd",
	  
	  #初始化pluginResource主机
	  "echo 'sshpass -p ${var.default_password} scp /root/scripts/wecube/wecube-s3.tpl root@${tencentcloud_instance.instance_wecube_plugin_resource.private_ip}:/root/'",
	  "./init-plugin-resource-host.sh ${tencentcloud_instance.instance_wecube_plugin_resource.private_ip} ${var.default_password} ${var.plugin_resource_s3_port} ${var.plugin_resource_s3_access_key} ${var.plugin_resource_s3_secret_key} > init.log 2>&1",
    ]
  }
}


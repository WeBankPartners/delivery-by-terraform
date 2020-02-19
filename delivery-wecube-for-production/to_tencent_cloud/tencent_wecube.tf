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
  cidr_block        = "10.128.202.0/25"
  availability_zone = "${var.deploy_availability_zone}"
}

#创建子网 - WeCube持久化存储的子网
resource "tencentcloud_subnet" "subnet_storage" {
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
resource "tencentcloud_security_group_rule" "allow_19090_tcp_db" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_db.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "3306"
  policy            = "accept"
}

#创建WeCube数据库mysql实例
resource "tencentcloud_mysql_instance" "mysql_instance_wecube_core" {
  internet_service = 1
  engine_version   = "5.6"
  root_password     = "${var.default_password}"
  slave_deploy_mode = 0
  first_slave_zone  = "${var.deploy_availability_zone}"
  second_slave_zone = "${var.deploy_availability_zone}"
  slave_sync_mode   = 1
  availability_zone = "${var.deploy_availability_zone}"
  instance_name     = "WecubeDbInstance"
  mem_size          = 1000
  volume_size       = 25
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  subnet_id         = "${tencentcloud_subnet.subnet_storage.id}"
  intranet_port     = 3306
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_db.*.id}"

  tags = {
    name = "WecubeDbName"
  }

  parameters = {
    max_connections = 1000
	lower_case_table_names = 1
	max_allowed_packet = 4194304
	character_set_server = "UTF8MB4"
    time_zone = "+8:00"
  }
}

#创建WeCube COS存储桶
resource "tencentcloud_cos_bucket" "cos_wecube" {
  bucket = "wecube-bucket-1253231672"
  acl    = "private"
}

#创建安全组 - sg_group_wecube_app
resource "tencentcloud_security_group" "sg_group_wecube_app" {
  name        = "SG_WECUBE"
  description = "Wecube Security Group"
}
#创建安全规则入站
resource "tencentcloud_security_group_rule" "allow_19090_tcp" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_app.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "19090"
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
resource "tencentcloud_security_group_rule" "allow_9000_tcp" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_app.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "9000"
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

#创建WeCube Platform主机
resource "tencentcloud_instance" "instance_wecube_platform" {
  availability_zone = "${var.deploy_availability_zone}"  
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_app.*.id}"
  #instance_type     = "S5.LARGE16"
  instance_type     = "S5.MEDIUM4"
  image_id          = "img-oikl1tzv"
  instance_name     = "instance_wecube_platform"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  subnet_id         = "${tencentcloud_subnet.subnet_app.id}"
  system_disk_type  = "CLOUD_PREMIUM"
  allocate_public_ip = true
  private_ip        ="10.128.202.3"
  internet_max_bandwidth_out = 10
  password ="${var.default_password}"

#初始化配置
  connection {
    type     = "ssh"
    user     = "root"
    password = "${var.default_password}"
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
	  "./install-wecube.sh ${tencentcloud_instance.instance_wecube_platform.private_ip} ${var.default_password} ${var.wecube_version} ${tencentcloud_mysql_instance.mysql_instance_wecube_core.intranet_ip} ${tencentcloud_mysql_instance.mysql_instance_wecube_core.intranet_port} ${tencentcloud_cos_bucket.cos_wecube.bucket}"
    ]
  }
}

output "wecube_website" {
  value="http://${tencentcloud_instance.instance_wecube_platform.public_ip}:19090"
}

output "wecube_mysql" {
  value="mysql=${tencentcloud_mysql_instance.mysql_instance_wecube_core.intranet_ip}"
}

output "wecube_cos" {
  value="cos=${tencentcloud_cos_bucket.cos_wecube.bucket}"
}

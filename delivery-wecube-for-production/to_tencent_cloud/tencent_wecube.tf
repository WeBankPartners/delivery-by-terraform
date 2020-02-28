#全局变量
variable "default_password" {
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_default_password'"
  default = "Wecube@123456"
}
variable "wecube_version" {
  description = "You can override the value by setup os env variable - 'TF_VAR_wecube_version'"
  default = "v2.1.1"
}
variable "deploy_availability_zone" {
  description = "You can override the value by setup os env variable - 'TF_VAR_deploy_availability_zone'"
  default = "ap-guangzhou-4"
}
variable "plugin_resource_s3_access_key" {
  description = "You can override the value by setup os env variable - 'TF_VAR_plugin_resource_s3_access_key'"
  default = "s3_access"
}
variable "plugin_resource_s3_secret_key" {
  description = "You can override the value by setup os env variable - 'TF_VAR_plugin_resource_s3_secret_key'"
  default = "s3_secret"
}
variable "cos_name" {
  description = "You can override the value by setup os env variable - 'TF_VAR_cos_name'"
  
  ####################################################################
  #---NOTICE---NOTICE---NOTICE---NOTICE---NOTICE---NOTICE---NOTICE---#
  #this name should end with '-appid', please use your own APP ID    #
  default = "wecube-bucket-1234567890"
  ####################################################################
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
  name        = "SG_WECUBE_DB"
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
resource "tencentcloud_security_group_rule" "allow_22_tcp_db" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_db.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "22"
  policy            = "accept"
}
#创建安全规则出站
resource "tencentcloud_security_group_rule" "allow_all_db_tcp_out" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_db.id}"
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "1-65535"
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
  mem_size          = 2000
  volume_size       = 200
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  subnet_id         = "${tencentcloud_subnet.subnet_db.id}"
  intranet_port     = 3306
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_db.*.id}"

  tags = {
    name = "WecubeDbInstance"
  }

  parameters = {
    max_connections = 1000
	lower_case_table_names = 1
	max_allowed_packet = 4194304
	character_set_server = "UTF8MB4"
    #time_zone = "+8:00"
  }
}

#创建WeCubePlugin数据库mysql实例
resource "tencentcloud_mysql_instance" "mysql_instance_plugin" {
  internet_service = 1
  engine_version   = "5.6"
  root_password     = "${var.default_password}"
  slave_deploy_mode = 0
  first_slave_zone  = "${var.deploy_availability_zone}"
  second_slave_zone = "${var.deploy_availability_zone}"
  slave_sync_mode   = 1
  availability_zone = "${var.deploy_availability_zone}"
  instance_name     = "PluginDbInstance"
  mem_size          = 2000
  volume_size       = 200
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  subnet_id         = "${tencentcloud_subnet.subnet_db.id}"
  intranet_port     = 3307
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_db.*.id}"

  tags = {
    name = "PluginDbInstance"
  }

  parameters = {
    max_connections = 1000
	lower_case_table_names = 1
	max_allowed_packet = 4194304
	character_set_server = "UTF8MB4"
    #time_zone = "+8:00"
  }
}

#创建WeCube COS存储桶
resource "tencentcloud_cos_bucket" "cos_wecube" {
  bucket = "${var.cos_name}"
  acl    = "private"
}

#创建WeCube plugin resource主机
resource "tencentcloud_instance" "instance_wecube_plugin_resource" {
  availability_zone = "${var.deploy_availability_zone}"
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_db.*.id}"
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

#创建安全组
resource "tencentcloud_security_group" "sg_group_wecube_app" {
  name        = "SG_WECUBE_APP"
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
resource "tencentcloud_security_group_rule" "allow_3128_tcp_for_app" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_app.id}"
  type              = "ingress"
  cidr_ip           = "10.128.194.0/25"
  ip_protocol       = "tcp"
  port_range        = "3128"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_3128_tcp_for_db" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_app.id}"
  type              = "ingress"
  cidr_ip           = "10.128.194.128/26"
  ip_protocol       = "tcp"
  port_range        = "3128"
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

#创建WeCube plugin docker主机
resource "tencentcloud_instance" "instance_plugin_docker_host" {
  availability_zone = "${var.deploy_availability_zone}"  
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_app.*.id}"
  instance_type     = "S5.LARGE8"
  image_id          = "img-oikl1tzv"
  instance_name     = "pluginDockerHost"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  subnet_id         = "${tencentcloud_subnet.subnet_app.id}"
  system_disk_type  = "CLOUD_PREMIUM"
  private_ip        ="10.128.194.4"
  internet_max_bandwidth_out = 10
  password ="${var.default_password}"
}

#创建WeCube Platform主机
resource "tencentcloud_instance" "instance_wecube_platform" {
  availability_zone = "${var.deploy_availability_zone}"  
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_app.*.id}"
  instance_type     = "S5.LARGE8"
  image_id          = "img-oikl1tzv"
  instance_name     = "instance_wecube_platform"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  subnet_id         = "${tencentcloud_subnet.subnet_app.id}"
  system_disk_type  = "CLOUD_PREMIUM"
  private_ip        ="10.128.194.3"
  internet_max_bandwidth_out = 10
  password ="${var.default_password}"
}

#创建Squid主机
resource "tencentcloud_instance" "instance_squid" {
  availability_zone = "${var.deploy_availability_zone}"  
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_app.*.id}"
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
	  "yum install -y expect",
      "dos2unix /root/scripts/wecube/*",
	  "cd /root/scripts/wecube",
	  "pwd",
	  
	  #初始化pluginResource主机
	  "./utils-scp.sh root ${tencentcloud_instance.instance_wecube_plugin_resource.private_ip} ${var.default_password} wecube-s3.tpl /root/",
	  "./init-plugin-resource-host.sh ${tencentcloud_instance.instance_wecube_plugin_resource.private_ip} ${var.default_password} 9001 ${var.plugin_resource_s3_access_key} ${var.plugin_resource_s3_secret_key} > init.log 2>&1",

	  #初始化pluginDocker主机
	  "./init-plugin-docker-host.sh ${tencentcloud_instance.instance_plugin_docker_host.private_ip} ${var.default_password} >> init.log 2>&1",

	  #初始化WeCube主机
	  "./utils-sed.sh '{{S3_ENDPOINT}}' 'https://'${tencentcloud_cos_bucket.cos_wecube.bucket}'.cos.ap-guangzhou.myqcloud.com'${tencentcloud_cos_bucket.cos_wecube.bucket} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
	  "./utils-sed.sh '{{WECUBE_HOST}}' ${tencentcloud_instance.instance_wecube_platform.private_ip} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
	  "./utils-sed.sh '{{PLUGIN_HOST}}' ${tencentcloud_instance.instance_plugin_docker_host.private_ip} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
	  "./utils-sed.sh '{{PLUGIN_HOST_PASSWORD}}' ${var.default_password} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
	  "./utils-sed.sh '{{STATIC_RESOURCE_SERVER_PASSWORD}}' ${var.default_password} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
	  "./utils-sed.sh '{{MYSQL_ADDR}}' ${tencentcloud_mysql_instance.mysql_instance_wecube_core.intranet_ip} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
	  "./utils-sed.sh '{{MYSQL_PORT}}' ${tencentcloud_mysql_instance.mysql_instance_wecube_core.intranet_port} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
	  "./utils-sed.sh '{{MYSQL_PASSWORD}}' ${var.default_password} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
	  "./utils-sed.sh '{{WECUBE_BUCKET}}' ${tencentcloud_cos_bucket.cos_wecube.bucket} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
	  
	  "cp -r /root/scripts/wecube/wecube-platform /root/scripts/wecube/wecube-platform-scripts", 
      "dos2unix /root/scripts/wecube/wecube-platform-scripts/*",
	  
	  "./utils-scp.sh root ${tencentcloud_instance.instance_wecube_platform.private_ip} ${var.default_password} '-r /root/scripts/wecube/wecube-platform-scripts' /root/",

	  "./init-wecube-platform-host.sh ${tencentcloud_instance.instance_wecube_platform.private_ip} ${var.default_password} ${var.wecube_version} >> init.log 2>&1",
	  
	  #初始化Squid主机
	  "./install-squid.sh >> init.log 2>&1"
    ]
  }
}

#创建安全组
resource "tencentcloud_security_group" "sg_group_wecube_vdi" {
  name        = "SG_WECUBE_VDI"
  description = "Wecube Security Group"
}
#创建安全规则入站
resource "tencentcloud_security_group_rule" "allow_3389_tcp" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_vdi.id}"
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "3389"
  policy            = "accept"
}
#创建安全规则出站
resource "tencentcloud_security_group_rule" "allow_all_vdi_tcp_out" {
  security_group_id = "${tencentcloud_security_group.sg_group_wecube_vdi.id}"
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "1-65535"
  policy            = "accept"
}

#创建VDI-windows主机
resource "tencentcloud_instance" "instance_vdi" {
  availability_zone = "${var.deploy_availability_zone}"  
  security_groups   = "${tencentcloud_security_group.sg_group_wecube_vdi.*.id}"
  instance_type     = "S5.MEDIUM4"
  image_id          = "img-9id7emv7"
  instance_name     = "instanceVdi"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  subnet_id         = "${tencentcloud_subnet.subnet_vdi.id}"
  system_disk_type  = "CLOUD_PREMIUM"
  allocate_public_ip = true
  private_ip        ="10.128.195.2"
  internet_max_bandwidth_out = 10
  password ="${var.default_password}"
}

output "Outputs" {
  value="\n Please follow below steps:\n 1.Login your Windows VDI[IP:${tencentcloud_instance.instance_vdi.public_ip}] with [User/Password：Administrator/${var.default_password}] ;\n 2.Use browser to access 'http://10.128.194.3:19090';\n \n \n Thank you in advance for your kind support and continued business.\n More Info: https://github.com/WeBankPartners/delivery-by-terraform"
}
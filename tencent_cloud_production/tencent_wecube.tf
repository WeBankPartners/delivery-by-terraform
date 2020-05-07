provider "tencentcloud" {
  secret_id  = var.secret_id
  secret_key = var.secret_key
  region     = var.region
}

#创建VPC
resource "tencentcloud_vpc" "TC_HK_PRD_MGMT" {
  name       = "TC_HK_PRD_MGMT"
  cidr_block = "10.40.192.0/19"
}

resource "tencentcloud_route_table" "default_route_table" {
  vpc_id = tencentcloud_vpc.TC_HK_PRD_MGMT.id
  name   = "default_route_table"
}

#创建子网 - TC_HK_PRD1_MGMT_VDI
resource "tencentcloud_subnet" "TC_HK_PRD1_MGMT_VDI" {
  name              = "TC_HK_PRD1_MGMT_VDI"
  vpc_id            = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  cidr_block        = "10.40.196.0/24"
  availability_zone = "${var.availability_zone_1}"
}
#创建子网 - TC_HK_PRD1_MGMT_PROXY
resource "tencentcloud_subnet" "TC_HK_PRD1_MGMT_PROXY" {
  name              = "TC_HK_PRD1_MGMT_PROXY"
  vpc_id            = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  cidr_block        = "10.40.220.0/24"
  availability_zone = "${var.availability_zone_1}"
}
#创建子网 - TC_HK_PRD1_MGMT_APP
resource "tencentcloud_subnet" "TC_HK_PRD1_MGMT_APP" {
  name              = "TC_HK_PRD1_MGMT_APP"
  vpc_id            = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  cidr_block        = "10.40.200.0/24"
  availability_zone = "${var.availability_zone_1}"
}
#创建子网 - TC_HK_PRD2_MGMT_APP
resource "tencentcloud_subnet" "TC_HK_PRD2_MGMT_APP" {
  name              = "TC_HK_PRD2_MGMT_APP"
  vpc_id            = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  cidr_block        = "10.40.201.0/24"
  availability_zone = "${var.availability_zone_2}"
}

#创建子网 - WeCube持久化存储的子网
resource "tencentcloud_subnet" "TC_HK_PRD1_MGMT_DB" {
  name              = "TC_HK_PRD1_MGMT_DB"
  vpc_id            = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  cidr_block        = "10.40.212.0/24"
  availability_zone = "${var.availability_zone_1}"
}


#创建安全组 - TC_HK_PRD_MGMT
resource "tencentcloud_security_group" "TC_HK_PRD_MGMT" {
  name        = "TC_HK_PRD_MGMT"
  description = "Wecube TC_HK_PRD_MGMT"
}
#创建安全规则入站
resource "tencentcloud_security_group_rule" "TC_HK_PRD_MGMT_ACCEPT_TC_HK_PRD_MGMT_ingress1-65535" {
  security_group_id = "${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"
  type              = "ingress"
  cidr_ip           = "10.40.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "1-65535"
  policy            = "accept"
}
#创建安全规则出站
resource "tencentcloud_security_group_rule" "TC_HK_PRD_MGMT_ACCEPT_TC_HK_PRD_MGMT_egress1-65535" {
  security_group_id = "${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"
  type              = "egress"
  cidr_ip           = "10.40.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "1-65535"
  policy            = "accept"
}



#创建安全规则入站
resource "tencentcloud_security_group_rule" "TC_HK_PRD_MGMT_ACCEPT_NDC_WAN_ingress22" {
  security_group_id = "${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"
  type              = "ingress"
  cidr_ip           = "${var.current_ip}"
  ip_protocol       = "tcp"
  port_range        = "22"
  policy            = "accept"
}


#创建安全规则出站
resource "tencentcloud_security_group_rule" "TC_HK_PRD_MGMT_ACCEPT_NDC_WAN_egress80-443" {
  security_group_id = "${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "80,443"
  policy            = "accept"
}


#创建安全规则入站
resource "tencentcloud_security_group_rule" "TC_HK_PRD1_MGMT_VDI_ACCEPT_NDC_WAN_ingress3389" {
  security_group_id = "${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"
  type              = "ingress"
  cidr_ip           = "${var.current_ip}"
  ip_protocol       = "tcp"
  port_range        = "3389"
  policy            = "accept"
}



#创建WeCube数据库mysql实例
resource "tencentcloud_mysql_instance" "TC_HK_PRD1_MGMT_DB_wecubecore" {
  internet_service  = 1
  engine_version    = "5.6"
  root_password     = "${var.default_password}"
  slave_deploy_mode = 0
  first_slave_zone  = "${var.availability_zone_1}"
  second_slave_zone = "${var.availability_zone_2}"
  slave_sync_mode   = 1
  availability_zone = "${var.availability_zone_1}"
  instance_name     = "TC_HK_PRD_MGMT_1M1_MYSQL1__wecubecore"
  mem_size          = 2000
  volume_size       = 40
  vpc_id            = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  subnet_id         = "${tencentcloud_subnet.TC_HK_PRD1_MGMT_DB.id}"
  intranet_port     = 3306
  security_groups   = ["${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"]

  tags = {
    name = "TC_HK_PRD1_MGMT_DB_wecubecore"
  }

  parameters = {
    max_connections        = 1000
    lower_case_table_names = 1
    max_allowed_packet     = 4194304
    character_set_server   = "UTF8MB4"
    #time_zone = "+8:00"
  }
}

#创建WeCube plugin docker主机
resource "tencentcloud_instance" "docker_host_1" {
  availability_zone          = "${var.availability_zone_1}"
  security_groups            = ["${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"]
  instance_type              = "S2.LARGE8"
  image_id                   = "img-oikl1tzv"
  instance_name              = "TC_HK_PRD_MGMT_1M1_DOCKER1__wecubeplugin01"
  vpc_id                     = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  subnet_id                  = "${tencentcloud_subnet.TC_HK_PRD1_MGMT_APP.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  private_ip                 = "10.40.200.3"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"
}

#创建WeCube plugin docker主机
resource "tencentcloud_instance" "docker_host_2" {
  availability_zone          = "${var.availability_zone_2}"
  security_groups            = ["${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"]
  instance_type              = "S2.LARGE8"
  image_id                   = "img-oikl1tzv"
  instance_name              = "TC_HK_PRD_MGMT_1M1_DOCKER1__wecubeplugin02"
  vpc_id                     = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  subnet_id                  = "${tencentcloud_subnet.TC_HK_PRD2_MGMT_APP.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  private_ip                 = "10.40.201.3"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"
}

#创建WeCube Platform主机
resource "tencentcloud_instance" "wecube_host_1" {
  availability_zone          = "${var.availability_zone_1}"
  security_groups            = ["${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"]
  instance_type              = "S2.MEDIUM4"
  image_id                   = "img-oikl1tzv"
  instance_name              = "TC_HK_PRD_MGMT_1M1_DOCKER1__wecubecore01"
  vpc_id                     = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  subnet_id                  = "${tencentcloud_subnet.TC_HK_PRD1_MGMT_APP.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  private_ip                 = "10.40.200.2"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"
}

#创建WeCube Platform主机
resource "tencentcloud_instance" "wecube_host_2" {
  availability_zone          = "${var.availability_zone_2}"
  security_groups            = ["${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"]
  instance_type              = "S2.MEDIUM4"
  image_id                   = "img-oikl1tzv"
  instance_name              = "TC_HK_PRD_MGMT_1M1_DOCKER1__wecubecore02"
  vpc_id                     = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  subnet_id                  = "${tencentcloud_subnet.TC_HK_PRD2_MGMT_APP.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  private_ip                 = "10.40.201.2"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"
}

resource "tencentcloud_clb_instance" "internal_clb_1" {
  network_type = "INTERNAL"
  clb_name     = "TC_HK_PRD_MGMT_1M1_ILB1__wecubelb01"
  project_id   = 0
  vpc_id       = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  subnet_id    = "${tencentcloud_subnet.TC_HK_PRD1_MGMT_APP.id}"
}
#http listener 1 - for wecube-portal
resource "tencentcloud_clb_listener" "http_listener_portal1" {
  clb_id        = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_name = "http_listener_portal1"
  port          = 19090
  protocol      = "HTTP"
}
resource "tencentcloud_clb_listener_rule" "http_listener_portal1_rule" {
  listener_id                = "${tencentcloud_clb_listener.http_listener_portal1.id}"
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_1.id}"
  domain                     = "${tencentcloud_clb_instance.internal_clb_1.clb_vips.0}"
  url                        = "/"
  health_check_switch        = true
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  health_check_http_code     = 2
  health_check_http_path     = "/platform/v1/health-check"
  health_check_http_domain   = "${tencentcloud_clb_instance.internal_clb_1.clb_vips.0}"
  health_check_http_method   = "GET"
  session_expire_time        = 180
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "http_listener_portal1_rule_attachment1" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.http_listener_portal1.id}"
  rule_id     = "${tencentcloud_clb_listener_rule.http_listener_portal1_rule.id}"
  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19090
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "http_listener_portal1_rule_attachment2" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.http_listener_portal1.id}"
  rule_id     = "${tencentcloud_clb_listener_rule.http_listener_portal1_rule.id}"
  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19090
    weight      = 10
  }
}

#http listener 2 - for platform-gateway
resource "tencentcloud_clb_listener" "http_listener_gateway1" {
  clb_id        = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_name = "http_listener_gateway1"
  port          = 19110
  protocol      = "HTTP"
}
resource "tencentcloud_clb_listener_rule" "http_listener_gateway1_rule" {
  listener_id                = "${tencentcloud_clb_listener.http_listener_gateway1.id}"
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_1.id}"
  domain                     = "${tencentcloud_clb_instance.internal_clb_1.clb_vips.0}"
  url                        = "/"
  health_check_switch        = true
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  health_check_http_code     = 2
  health_check_http_path     = "/platform/v1/health-check"
  health_check_http_domain   = "${tencentcloud_clb_instance.internal_clb_1.clb_vips.0}"
  health_check_http_method   = "GET"
  session_expire_time        = 180
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "http_listener_gateway1_rule_attachment1" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.http_listener_gateway1.id}"
  rule_id     = "${tencentcloud_clb_listener_rule.http_listener_gateway1_rule.id}"
  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19110
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "http_listener_gateway1_rule_attachment2" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.http_listener_gateway1.id}"
  rule_id     = "${tencentcloud_clb_listener_rule.http_listener_gateway1_rule.id}"
  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19110
    weight      = 10
  }
}



resource "tencentcloud_clb_instance" "internal_clb_2" {
  network_type = "INTERNAL"
  clb_name     = "TC_HK_PRD_MGMT_1M1_ILB1__wecubelb02"
  project_id   = 0
  vpc_id       = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  subnet_id    = "${tencentcloud_subnet.TC_HK_PRD2_MGMT_APP.id}"
}
#http listener 2_1 - for wecube-portal
resource "tencentcloud_clb_listener" "http_listener_portal2" {
  clb_id        = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_name = "http_listener_portal2"
  port          = 19090
  protocol      = "HTTP"
}
resource "tencentcloud_clb_listener_rule" "http_listener_portal2_rule" {
  listener_id                = "${tencentcloud_clb_listener.http_listener_portal2.id}"
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_2.id}"
  domain                     = "${tencentcloud_clb_instance.internal_clb_2.clb_vips.0}"
  url                        = "/"
  health_check_switch        = true
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  health_check_http_code     = 2
  health_check_http_path     = "/platform/v1/health-check"
  health_check_http_domain   = "${tencentcloud_clb_instance.internal_clb_2.clb_vips.0}"
  health_check_http_method   = "GET"
  session_expire_time        = 180
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "http_listener_portal2_rule_attachment1" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.http_listener_portal2.id}"
  rule_id     = "${tencentcloud_clb_listener_rule.http_listener_portal2_rule.id}"
  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19090
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "http_listener_portal2_rule_attachment2" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.http_listener_portal2.id}"
  rule_id     = "${tencentcloud_clb_listener_rule.http_listener_portal2_rule.id}"
  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19090
    weight      = 10
  }
}
#http listener 2_1 - for platform-gateway
resource "tencentcloud_clb_listener" "http_listener_gateway2" {
  clb_id        = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_name = "http_listener_gateway2"
  port          = 19110
  protocol      = "HTTP"
}
resource "tencentcloud_clb_listener_rule" "http_listener_gateway2_rule" {
  listener_id                = "${tencentcloud_clb_listener.http_listener_gateway2.id}"
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_2.id}"
  domain                     = "${tencentcloud_clb_instance.internal_clb_2.clb_vips.0}"
  url                        = "/"
  health_check_switch        = true
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  health_check_http_code     = 2
  health_check_http_path     = "/platform/v1/health-check"
  health_check_http_domain   = "${tencentcloud_clb_instance.internal_clb_2.clb_vips.0}"
  health_check_http_method   = "GET"
  session_expire_time        = 180
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "http_listener_gateway2_rule_attachment1" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.http_listener_gateway2.id}"
  rule_id     = "${tencentcloud_clb_listener_rule.http_listener_gateway2_rule.id}"
  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19090
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "http_listener_gateway2_rule_attachment2" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.http_listener_gateway2.id}"
  rule_id     = "${tencentcloud_clb_listener_rule.http_listener_gateway2_rule.id}"
  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19090
    weight      = 10
  }
}

#创建VDI-windows主机
resource "tencentcloud_instance" "instance_vdi" {
  availability_zone = "${var.availability_zone_1}"
  security_groups   = ["${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"]
  instance_type     = "S2.MEDIUM4"
  # image_id          = "img-9id7emv7"
  image_id                   = "img-nmgxso98"
  instance_name              = "TC_HK_PRD_MGMT_1M1_VDI1__mgmtvdi01"
  vpc_id                     = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  subnet_id                  = "${tencentcloud_subnet.TC_HK_PRD1_MGMT_VDI.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  allocate_public_ip         = true
  private_ip                 = "10.40.196.3"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"
}


#创建WeCubePlugin数据库mysql实例
resource "tencentcloud_mysql_instance" "TC_HK_PRD1_MGMT_DB_wecubeplugin" {
  internet_service  = 1
  engine_version    = "5.6"
  root_password     = "${var.default_password}"
  slave_deploy_mode = 0
  first_slave_zone  = "${var.availability_zone_1}"
  second_slave_zone = "${var.availability_zone_2}"
  slave_sync_mode   = 1
  availability_zone = "${var.availability_zone_1}"
  instance_name     = "TC_HK_PRD_MGMT_1M1_MYSQL1__wecubeplugin"
  mem_size          = 4000
  volume_size       = 50
  vpc_id            = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  subnet_id         = "${tencentcloud_subnet.TC_HK_PRD1_MGMT_DB.id}"
  intranet_port     = 3306
  security_groups   = ["${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"]

  tags = {
    name = "TC_HK_PRD1_MGMT_DB_wecubeplugin"
  }

  parameters = {
    max_connections        = 1000
    lower_case_table_names = 1
    max_allowed_packet     = 4194304
    character_set_server   = "UTF8MB4"
    #time_zone = "+8:00"
  }
}

#创建Squid主机
resource "tencentcloud_instance" "instance_squid" {
  availability_zone          = "${var.availability_zone_1}"
  security_groups            = ["${tencentcloud_security_group.TC_HK_PRD_MGMT.id}"]
  instance_type              = "S2.SMALL1"
  image_id                   = "img-oikl1tzv"
  instance_name              = "TC_HK_PRD_MGMT_1M1_SQUID1__mgmtsquid01"
  vpc_id                     = "${tencentcloud_vpc.TC_HK_PRD_MGMT.id}"
  subnet_id                  = "${tencentcloud_subnet.TC_HK_PRD1_MGMT_PROXY.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  allocate_public_ip         = true
  private_ip                 = "10.40.220.3"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"

  #初始化配置
  connection {
    type     = "ssh"
    user     = "root"
    password = "${var.default_password}"
    host     = "${tencentcloud_instance.instance_squid.public_ip}"
  }

  provisioner "file" {
    source      = "scripts"
    destination = "/root/scripts"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/scripts/*.sh",
      "yum install dos2unix -y",
      "yum install -y sshpass",
      "yum install -y expect",
      # "dos2unix /root/scripts/*",
      "dos2unix /root/scripts/*",
      "dos2unix /root/scripts/wecube-platform/*",
      "dos2unix /root/scripts/auto-plugin-installer/*",
      "mkdir -p ${var.wecube_home_folder}",
      "cp -r /root/scripts/* ${var.wecube_home_folder}",
      "chmod -R +x ${var.wecube_home_folder}/*",
      "cd ${var.wecube_home_folder}",


      # "cd /root/scripts",
      # "dos2unix /root/scripts/*",
      # "./dos2unis-all.sh",

      #初始化Squid主机
      "./install-squid.sh >> init.log 2>&1",

      #初始化pluginDocker主机
      "./utils-scp.sh root ${tencentcloud_instance.docker_host_1.private_ip} ${var.default_password} wecube-s3.tpl /root/",
      "./utils-scp.sh root ${tencentcloud_instance.docker_host_2.private_ip} ${var.default_password} wecube-s3.tpl /root/",
      "./init-plugin-docker-host.sh ${tencentcloud_instance.docker_host_1.private_ip} ${var.default_password} 9001 >> init.log 2>&1",
      "./init-plugin-docker-host.sh ${tencentcloud_instance.docker_host_2.private_ip} ${var.default_password} 9001 >> init.log 2>&1",

      #初始化WeCube主机
      "cp /root/scripts/wecube-platform/wecube-platform.cfg /root/scripts/wecube-platform/wecube-platform-2.cfg",

      "./utils-sed.sh '{{PLUGIN_MYSQL_IP}}' ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubeplugin.intranet_ip} /root/scripts/wecube-platform/database/platform-core/02.wecube.system.data.sql",
      "./utils-sed.sh '{{GATEWAY_HOST}}' ${tencentcloud_clb_instance.internal_clb_1.clb_vips.0} /root/scripts/wecube-platform/database/platform-core/02.wecube.system.data.sql",


      "./utils-sed.sh '{{S3_ENDPOINT}}' 'http://'${tencentcloud_instance.wecube_host_1.private_ip}':9000' /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{WECUBE_HOST}}' ${tencentcloud_instance.wecube_host_1.private_ip} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{RESOURCE_HOST1}}' ${tencentcloud_instance.wecube_host_1.private_ip} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{RESOURCE_HOST2}}' ${tencentcloud_instance.wecube_host_2.private_ip} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{STATIC_RESOURCE_SERVER_PASSWORD}}' ${var.default_password} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_ADDR}}' ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubecore.intranet_ip} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_PORT}}' ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubecore.intranet_port} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_PASSWORD}}' ${var.default_password} /root/scripts/wecube-platform/wecube-platform.cfg",

      "./utils-sed.sh '{{S3_ENDPOINT}}' 'http://'${tencentcloud_instance.wecube_host_2.private_ip}':9000' /root/scripts/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{WECUBE_HOST}}' ${tencentcloud_instance.wecube_host_2.private_ip} /root/scripts/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{RESOURCE_HOST1}}' ${tencentcloud_instance.wecube_host_1.private_ip} /root/scripts/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{RESOURCE_HOST2}}' ${tencentcloud_instance.wecube_host_2.private_ip} /root/scripts/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{STATIC_RESOURCE_SERVER_PASSWORD}}' ${var.default_password} /root/scripts/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{MYSQL_ADDR}}' ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubecore.intranet_ip} /root/scripts/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{MYSQL_PORT}}' ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubecore.intranet_port} /root/scripts/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{MYSQL_PASSWORD}}' ${var.default_password} /root/scripts/wecube-platform/wecube-platform-2.cfg",

      "cp -r /root/scripts/wecube-platform /root/scripts/wecube-platform-scripts",
      "dos2unix /root/scripts/wecube-platform-scripts/*",

      "./utils-scp.sh root ${tencentcloud_instance.wecube_host_1.private_ip} ${var.default_password} '-r /root/scripts/wecube-platform-scripts' /root/",
      "./init-wecube-platform-host.sh ${tencentcloud_instance.wecube_host_1.private_ip} ${var.default_password} ${var.wecube_version} 'wecube-platform.cfg' 9000 >> init.log 2>&1",

      "./utils-scp.sh root ${tencentcloud_instance.wecube_host_2.private_ip} ${var.default_password} '-r /root/scripts/wecube-platform-scripts' /root/",
      "./init-wecube-platform-host.sh ${tencentcloud_instance.wecube_host_2.private_ip} ${var.default_password} ${var.wecube_version} 'wecube-platform-2.cfg' 9000 >> init.log 2>&1",


      #CMDB数据回写前 - 变量替换
      "./utils-sed.sh '{{mysql_password}}' ${var.default_password} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{plugin_mysql_host}}' ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubeplugin.intranet_ip} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{cmdb_sql_file}}' '${var.wecube_home_folder}/auto-plugin-installer/database/cmdb/01.register_cmdb_asset_ids.sql' ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{region_name}}' ${var.region_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{region}}' ${var.region} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{az_1}}' ${var.availability_zone_1} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{az_2}}' ${var.availability_zone_2} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{az_1_name}}' ${var.az_1_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{az_2_name}}' ${var.az_2_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{wecube_vpc_asset_id}}' ${tencentcloud_vpc.TC_HK_PRD_MGMT.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{vpc_name}}' ${var.vpc_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{security_group_asset_id}}' ${tencentcloud_security_group.TC_HK_PRD_MGMT.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{route_table_asset_id}}' ${tencentcloud_route_table.default_route_table.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{app1_subnet_asset_id}}' ${tencentcloud_subnet.TC_HK_PRD1_MGMT_APP.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{app2_subnet_asset_id}}' ${tencentcloud_subnet.TC_HK_PRD2_MGMT_APP.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{subnet_app1_name}}' ${var.subnet_app1_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{subnet_app2_name}}' ${var.subnet_app2_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{db1_subnet_asset_id}}' ${tencentcloud_subnet.TC_HK_PRD1_MGMT_DB.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{db2_subnet_asset_id}}' ${tencentcloud_subnet.TC_HK_PRD1_MGMT_DB.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{subnet_db1_name}}' ${var.subnet_db1_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{vdi_subnet_asset_id}}' ${tencentcloud_subnet.TC_HK_PRD1_MGMT_VDI.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{subnet_vdi_name}}' ${var.subnet_vdi_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{proxy_subnet_asset_id}}' ${tencentcloud_subnet.TC_HK_PRD1_MGMT_PROXY.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{subnet_proxy_name}}' ${var.subnet_proxy_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{wecube_host1_id}}' ${tencentcloud_instance.wecube_host_1.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{wecube_host2_id}}' ${tencentcloud_instance.wecube_host_2.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{ecs_wecube_host1_name}}' ${var.ecs_wecube_host1_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{ecs_wecube_host2_name}}' ${var.ecs_wecube_host2_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{pluign_host1_id}}' ${tencentcloud_instance.docker_host_1.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{pluign_host2_id}}' ${tencentcloud_instance.docker_host_2.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{ecs_plugin_host1_name}}' ${var.ecs_plugin_host1_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{ecs_plugin_host2_name}}' ${var.ecs_plugin_host2_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{squid_host_id}}' ${tencentcloud_instance.instance_squid.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{vdi_host_id}}' ${tencentcloud_instance.instance_vdi.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{ecs_squid_name}}' ${var.ecs_squid_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{ecs_vdi_name}}' ${var.ecs_vdi_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{rdb_wecubecore_id}}' ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubecore.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{rdb_wecubeplugin_id}}' ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubeplugin.id} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{rds_core_name}}' ${var.rds_core_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{rds_plugin_name}}' ${var.rds_plugin_name} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{wecube_mysql_host}}' ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubecore.intranet_ip} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{wecube_mysql_port}}' 3306 ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{wecube_sql_script_file}}' '${var.wecube_home_folder}/auto-plugin-installer/database/wecube/01.update_system_variables.sql' ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      "./utils-sed.sh '{{WECUBE_VERSION}}' ${var.wecube_version} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

      #auto run plugins
      "cd auto-plugin-installer",
      "./auto-run-plugins.sh 'Y' ${tencentcloud_instance.wecube_host_1.private_ip} ${var.default_password} ${var.wecube_home_folder} ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubeplugin.intranet_ip} ${tencentcloud_instance.docker_host_1.private_ip} ${tencentcloud_instance.wecube_host_2.private_ip}"

    ]
  }
}

output "Tips" {
  value = " \n -------------------cloud-------------------- \n   QCloud_SECRET_KEY   SecretKey=${var.secret_key};AccessKey=${var.secret_id};DomainId=*** \n   QCLOUD_LOCATION   CloudApiDomainName=myqcloud.com;Region=${var.region};ProjectId=*** \n    \n   -------------------vpc---------------------- \n   ${tencentcloud_vpc.TC_HK_PRD_MGMT.name}  ${tencentcloud_vpc.TC_HK_PRD_MGMT.id} \n    \n   -------------------subnet------------------- \n   ${tencentcloud_subnet.TC_HK_PRD1_MGMT_APP.name}  ${tencentcloud_subnet.TC_HK_PRD1_MGMT_APP.id} \n   ${tencentcloud_subnet.TC_HK_PRD2_MGMT_APP.name}  ${tencentcloud_subnet.TC_HK_PRD2_MGMT_APP.id} \n   ${tencentcloud_subnet.TC_HK_PRD1_MGMT_DB.name}  ${tencentcloud_subnet.TC_HK_PRD1_MGMT_DB.id} \n    \n   ${tencentcloud_subnet.TC_HK_PRD1_MGMT_APP.name}  ${tencentcloud_subnet.TC_HK_PRD1_MGMT_APP.id} \n   ${tencentcloud_subnet.TC_HK_PRD2_MGMT_APP.name}  ${tencentcloud_subnet.TC_HK_PRD2_MGMT_APP.id} \n   ${tencentcloud_subnet.TC_HK_PRD1_MGMT_VDI.name}  ${tencentcloud_subnet.TC_HK_PRD1_MGMT_VDI.id} \n   ${tencentcloud_subnet.TC_HK_PRD1_MGMT_PROXY.name}  ${tencentcloud_subnet.TC_HK_PRD1_MGMT_PROXY.id} \n    \n   -------------------host---------------------- \n   ${tencentcloud_instance.wecube_host_1.instance_name} ${tencentcloud_instance.wecube_host_1.id} \n   ${tencentcloud_instance.wecube_host_2.instance_name} ${tencentcloud_instance.wecube_host_2.id} \n   ${tencentcloud_instance.docker_host_1.instance_name} ${tencentcloud_instance.docker_host_1.id} \n   ${tencentcloud_instance.docker_host_2.instance_name} ${tencentcloud_instance.docker_host_2.id} \n   ${tencentcloud_instance.instance_squid.instance_name} ${tencentcloud_instance.instance_squid.id} \n   ${tencentcloud_instance.instance_vdi.instance_name} ${tencentcloud_instance.instance_vdi.id} \n    \n   -------------------mysqldb------------------ \n   ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubecore.instance_name} ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubecore.id} \n   ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubeplugin.instance_name} ${tencentcloud_mysql_instance.TC_HK_PRD1_MGMT_DB_wecubeplugin.id} \n    \n   ------------------------------------------ \n    \n    \n   \n Please follow below steps:\n 1.Login your Windows VDI[IP:${tencentcloud_instance.instance_vdi.public_ip}] with [User/Password：Administrator/${var.default_password}];\n 2.Install Chrome browser;\n 3.Use Chrome browser to access WeCube: \n  http://${tencentcloud_clb_instance.internal_clb_1.clb_vips.0}:19090  -- for normal user \n  http://${tencentcloud_clb_instance.internal_clb_2.clb_vips.0}:19090  -- for normal user \n  http://${tencentcloud_instance.wecube_host_1.private_ip}:19090  -- for admin role \n  http://${tencentcloud_instance.wecube_host_2.private_ip}:19090  -- for admin role  \n \n \n Thank you in advance for your kind support and continued business.\n More Info: https://github.com/WeBankPartners/delivery-by-terraform "
}

#全局变量
variable "secret_id" {
  default = ""
}
variable "secret_key" {
  default = ""
}
variable "region" {
  default = ""
}
variable "default_password" {
  description = "Warn: to be safety, please setup real password by using os env variable - 'TF_VAR_default_password'"
  default     = "Wecube@123456"
}
variable "wecube_version" {
  description = "You can override the value by setup os env variable - 'TF_VAR_wecube_version'"
  default     = "v2.1.1"
}
variable "availability_zone_1" {
  description = "You can override the value by setup os env variable - 'TF_VAR_availability_zone_1'"
  default     = "ap-guangzhou-4"
}
variable "availability_zone_2" {
  description = "You can override the value by setup os env variable - 'TF_VAR_availability_zone_2'"
  default     = "ap-guangzhou-3"
}

provider "tencentcloud" {
  secret_id  = var.secret_id
  secret_key = var.secret_key
  region     = var.region
}

#创建VPC
resource "tencentcloud_vpc" "PRD_MG" {
  name       = "PRD_MG"
  cidr_block = "10.128.192.0/19"
}

#创建子网 - PRD1_MG_VDI
resource "tencentcloud_subnet" "PRD1_MG_VDI" {
  name              = "PRD1_MG_VDI"
  vpc_id            = "${tencentcloud_vpc.PRD_MG.id}"
  cidr_block        = "10.128.192.0/24"
  availability_zone = "${var.availability_zone_1}"
}
#创建子网 - PRD1_MG_PROXY
resource "tencentcloud_subnet" "PRD1_MG_PROXY" {
  name              = "PRD1_MG_PROXY"
  vpc_id            = "${tencentcloud_vpc.PRD_MG.id}"
  cidr_block        = "10.128.199.0/24"
  availability_zone = "${var.availability_zone_1}"
}

#创建子网 - PRD1_MG_LB
resource "tencentcloud_subnet" "PRD1_MG_LB" {
  name              = "PRD1_MG_LB"
  vpc_id            = "${tencentcloud_vpc.PRD_MG.id}"
  cidr_block        = "10.128.200.0/24"
  availability_zone = "${var.availability_zone_1}"
}
#创建子网 - PRD2_MG_LB
resource "tencentcloud_subnet" "PRD2_MG_LB" {
  name              = "PRD2_MG_LB"
  vpc_id            = "${tencentcloud_vpc.PRD_MG.id}"
  cidr_block        = "10.128.216.0/24"
  availability_zone = "${var.availability_zone_2}"
}
#创建子网- PRD1_MG_APP
resource "tencentcloud_subnet" "PRD1_MG_APP" {
  name              = "PRD1_MG_APP"
  vpc_id            = "${tencentcloud_vpc.PRD_MG.id}"
  cidr_block        = "10.128.202.0/24"
  availability_zone = "${var.availability_zone_1}"
}
#创建子网- PRD2_MG_APP
resource "tencentcloud_subnet" "PRD2_MG_APP" {
  name              = "PRD2_MG_APP"
  vpc_id            = "${tencentcloud_vpc.PRD_MG.id}"
  cidr_block        = "10.128.218.0/24"
  availability_zone = "${var.availability_zone_2}"
}
#创建子网 - WeCube持久化存储的子网
resource "tencentcloud_subnet" "PRD1_MG_RDB" {
  name              = "PRD1_MG_RDB"
  vpc_id            = "${tencentcloud_vpc.PRD_MG.id}"
  cidr_block        = "10.128.206.0/24"
  availability_zone = "${var.availability_zone_1}"
}

#创建子网 - WeCube持久化存储的子网
resource "tencentcloud_subnet" "PRD2_MG_RDB" {
  name              = "PRD2_MG_RDB"
  vpc_id            = "${tencentcloud_vpc.PRD_MG.id}"
  cidr_block        = "10.128.222.0/24"
  availability_zone = "${var.availability_zone_2}"
}


#创建安全组 - PRD_MG
resource "tencentcloud_security_group" "PRD_MG" {
  name        = "PRD_MG"
  description = "Wecube PRD_MG"
}
#创建安全规则入站
resource "tencentcloud_security_group_rule" "allow_20000_tcp_1" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.218.0/24"
  ip_protocol       = "tcp"
  port_range        = "20000-30000"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_20000_tcp_2" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.202.0/24"
  ip_protocol       = "tcp"
  port_range        = "20000-30000"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_3389_tcp_internet" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "218.17.197.195"
  ip_protocol       = "tcp"
  port_range        = "3389"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_22_tcp_internet" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "218.17.197.195"
  ip_protocol       = "tcp"
  port_range        = "22"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_3306_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "3306"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_3307_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "3307"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_9000_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "9000"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_9001_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "9001"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_22_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "22"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_3128_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "3128"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_19090_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "19090"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_19110_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "19110"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_2375_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "2375"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_80_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "80"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_443_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "443"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_19120_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "19120"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_19100_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "19100"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_19101_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.192.0/19"
  ip_protocol       = "tcp"
  port_range        = "19101"
  policy            = "accept"
}
resource "tencentcloud_security_group_rule" "allow_sf_tcp" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "ingress"
  cidr_ip           = "10.128.0.0/17"
  ip_protocol       = "tcp"
  port_range        = "1-65535"
  policy            = "accept"
}

#创建安全规则出站
resource "tencentcloud_security_group_rule" "allow_all_tcp_out" {
  security_group_id = "${tencentcloud_security_group.PRD_MG.id}"
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "tcp"
  port_range        = "1-65535"
  policy            = "accept"
}


#创建WeCube数据库mysql实例
resource "tencentcloud_mysql_instance" "PRD1_MG_RDB_wecubecore" {
  internet_service  = 1
  engine_version    = "5.6"
  root_password     = "${var.default_password}"
  slave_deploy_mode = 0
  first_slave_zone  = "${var.availability_zone_1}"
  second_slave_zone = "${var.availability_zone_2}"
  slave_sync_mode   = 1
  availability_zone = "${var.availability_zone_1}"
  instance_name     = "PRD1_MG_RDB_wecubecore"
  mem_size          = 2000
  volume_size       = 40
  vpc_id            = "${tencentcloud_vpc.PRD_MG.id}"
  subnet_id         = "${tencentcloud_subnet.PRD1_MG_RDB.id}"
  intranet_port     = 3306
  security_groups   = "${tencentcloud_security_group.PRD_MG.*.id}"

  tags = {
    name = "PRD1_MG_RDB_wecubecore"
  }

  parameters = {
    max_connections        = 1000
    lower_case_table_names = 1
    max_allowed_packet     = 4194304
    character_set_server   = "UTF8MB4"
    #time_zone = "+8:00"
  }
}

#创建WeCubePlugin数据库mysql实例
resource "tencentcloud_mysql_instance" "PRD1_MG_RDB_wecubeplugin" {
  internet_service  = 1
  engine_version    = "5.6"
  root_password     = "${var.default_password}"
  slave_deploy_mode = 0
  first_slave_zone  = "${var.availability_zone_1}"
  second_slave_zone = "${var.availability_zone_2}"
  slave_sync_mode   = 1
  availability_zone = "${var.availability_zone_1}"
  instance_name     = "PRD1_MG_RDB_wecubeplugin"
  mem_size          = 4000
  volume_size       = 50
  vpc_id            = "${tencentcloud_vpc.PRD_MG.id}"
  subnet_id         = "${tencentcloud_subnet.PRD1_MG_RDB.id}"
  intranet_port     = 3307
  security_groups   = "${tencentcloud_security_group.PRD_MG.*.id}"

  tags = {
    name = "PRD1_MG_RDB_wecubeplugin"
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
  security_groups            = "${tencentcloud_security_group.PRD_MG.*.id}"
  instance_type              = "S2.LARGE8"
  image_id                   = "img-oikl1tzv"
  instance_name              = "PRD1_MG_APP_10.128.202.3_wecubeplugin"
  vpc_id                     = "${tencentcloud_vpc.PRD_MG.id}"
  subnet_id                  = "${tencentcloud_subnet.PRD1_MG_APP.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  private_ip                 = "10.128.202.3"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"
}

#创建WeCube plugin docker主机
resource "tencentcloud_instance" "docker_host_2" {
  availability_zone          = "${var.availability_zone_2}"
  security_groups            = "${tencentcloud_security_group.PRD_MG.*.id}"
  instance_type              = "S2.LARGE8"
  image_id                   = "img-oikl1tzv"
  instance_name              = "PRD1_MG_APP_10.128.218.3_wecubeplugin"
  vpc_id                     = "${tencentcloud_vpc.PRD_MG.id}"
  subnet_id                  = "${tencentcloud_subnet.PRD2_MG_APP.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  private_ip                 = "10.128.218.3"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"
}

#创建WeCube Platform主机
resource "tencentcloud_instance" "wecube_host_1" {
  availability_zone          = "${var.availability_zone_1}"
  security_groups            = "${tencentcloud_security_group.PRD_MG.*.id}"
  instance_type              = "S2.MEDIUM4"
  image_id                   = "img-oikl1tzv"
  instance_name              = "PRD1_MG_APP_10.128.202.2_wecubecore"
  vpc_id                     = "${tencentcloud_vpc.PRD_MG.id}"
  subnet_id                  = "${tencentcloud_subnet.PRD1_MG_APP.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  private_ip                 = "10.128.202.2"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"
}

#创建WeCube Platform主机
resource "tencentcloud_instance" "wecube_host_2" {
  availability_zone          = "${var.availability_zone_2}"
  security_groups            = "${tencentcloud_security_group.PRD_MG.*.id}"
  instance_type              = "S2.MEDIUM4"
  image_id                   = "img-oikl1tzv"
  instance_name              = "PRD1_MG_APP_10.128.218.2_wecubecore"
  vpc_id                     = "${tencentcloud_vpc.PRD_MG.id}"
  subnet_id                  = "${tencentcloud_subnet.PRD2_MG_APP.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  private_ip                 = "10.128.218.2"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"
}


resource "tencentcloud_clb_instance" "internal_clb_1" {
  network_type = "INTERNAL"
  clb_name     = "PRD1_MG_LB_1"
  project_id   = 0
  vpc_id       = "${tencentcloud_vpc.PRD_MG.id}"
  subnet_id    = "${tencentcloud_subnet.PRD1_MG_LB.id}"
}
resource "tencentcloud_clb_listener" "TCP_listener_1_1" {
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_name              = "TCP_listener_1_1"
  port                       = 19090
  protocol                   = "TCP"
  health_check_switch        = true
  health_check_time_out      = 2
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  session_expire_time        = 30
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "clb_attachment_19090_1" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_1_1.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19090
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "clb_attachment_19090_2" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_1_1.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19090
    weight      = 10
  }
}
resource "tencentcloud_clb_listener" "TCP_listener_1_2" {
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_name              = "TCP_listener_1_2"
  port                       = 19110
  protocol                   = "TCP"
  health_check_switch        = true
  health_check_time_out      = 2
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  session_expire_time        = 30
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "clb_attachment_81_1" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_1_2.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19110
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "clb_attachment_81_2" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_1_2.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19110
    weight      = 10
  }
}
resource "tencentcloud_clb_listener" "TCP_listener_1_3" {
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_name              = "TCP_listener_1_3"
  port                       = 19100
  protocol                   = "TCP"
  health_check_switch        = true
  health_check_time_out      = 2
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  session_expire_time        = 30
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "clb_attachment_19100_1" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_1_3.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19100
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "clb_attachment_19100_2" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_1_3.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19100
    weight      = 10
  }
}
resource "tencentcloud_clb_listener" "TCP_listener_1_4" {
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_name              = "TCP_listener_1_4"
  port                       = 19120
  protocol                   = "TCP"
  health_check_switch        = true
  health_check_time_out      = 2
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  session_expire_time        = 30
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "clb_attachment_19100_3" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_1_4.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19120
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "clb_attachment_19100_4" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_1.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_1_4.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19120
    weight      = 10
  }
}

resource "tencentcloud_clb_instance" "internal_clb_2" {
  network_type = "INTERNAL"
  clb_name     = "PRD1_MG_LB_2"
  project_id   = 0
  vpc_id       = "${tencentcloud_vpc.PRD_MG.id}"
  subnet_id    = "${tencentcloud_subnet.PRD2_MG_LB.id}"
}
resource "tencentcloud_clb_listener" "TCP_listener_2_1" {
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_name              = "TCP_listener_2_1"
  port                       = 19090
  protocol                   = "TCP"
  health_check_switch        = true
  health_check_time_out      = 2
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  session_expire_time        = 30
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_listener" "TCP_listener_2_2" {
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_name              = "TCP_listener_2_2"
  port                       = 19110
  protocol                   = "TCP"
  health_check_switch        = true
  health_check_time_out      = 2
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  session_expire_time        = 30
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "clb_attachment_19090_3" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_2_1.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19090
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "clb_attachment_19110_3" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_2_2.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19110
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "clb_attachment_19090_4" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_2_1.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19090
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "clb_attachment_19110_4" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_2_2.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19110
    weight      = 10
  }
}

resource "tencentcloud_clb_listener" "TCP_listener_2_3" {
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_name              = "TCP_listener_2_3"
  port                       = 19100
  protocol                   = "TCP"
  health_check_switch        = true
  health_check_time_out      = 2
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  session_expire_time        = 30
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "clb_attachment_2_19100_1" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_2_3.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19100
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "clb_attachment_2_19100_2" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_2_3.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19100
    weight      = 10
  }
}
resource "tencentcloud_clb_listener" "TCP_listener_2_4" {
  clb_id                     = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_name              = "TCP_listener_2_4"
  port                       = 19120
  protocol                   = "TCP"
  health_check_switch        = true
  health_check_time_out      = 2
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  session_expire_time        = 30
  scheduler                  = "WRR"
}
resource "tencentcloud_clb_attachment" "clb_attachment_2_19100_3" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_2_4.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_1.id}"
    port        = 19120
    weight      = 10
  }
}
resource "tencentcloud_clb_attachment" "clb_attachment_2_19100_4" {
  clb_id      = "${tencentcloud_clb_instance.internal_clb_2.id}"
  listener_id = "${tencentcloud_clb_listener.TCP_listener_2_4.id}"

  targets {
    instance_id = "${tencentcloud_instance.wecube_host_2.id}"
    port        = 19120
    weight      = 10
  }
}

#创建VDI-windows主机
resource "tencentcloud_instance" "instance_vdi" {
  availability_zone          = "${var.availability_zone_1}"
  security_groups            = "${tencentcloud_security_group.PRD_MG.*.id}"
  instance_type              = "S2.MEDIUM4"
  image_id                   = "img-9id7emv7"
  instance_name              = "PRD1_MG_VDI_10.128.192.3_wecubevdi"
  vpc_id                     = "${tencentcloud_vpc.PRD_MG.id}"
  subnet_id                  = "${tencentcloud_subnet.PRD1_MG_VDI.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  allocate_public_ip         = true
  private_ip                 = "10.128.192.3"
  internet_max_bandwidth_out = 10
  password                   = "${var.default_password}"
}

#创建Squid主机
resource "tencentcloud_instance" "instance_squid" {
  availability_zone          = "${var.availability_zone_1}"
  security_groups            = "${tencentcloud_security_group.PRD_MG.*.id}"
  instance_type              = "S2.SMALL1"
  image_id                   = "img-oikl1tzv"
  instance_name              = "PRD1_MG_PROXY_10.128.199.3_wecubesquid"
  vpc_id                     = "${tencentcloud_vpc.PRD_MG.id}"
  subnet_id                  = "${tencentcloud_subnet.PRD1_MG_PROXY.id}"
  system_disk_type           = "CLOUD_PREMIUM"
  allocate_public_ip         = true
  private_ip                 = "10.128.199.3"
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

      #初始化Squid主机
      "./install-squid.sh >> init.log 2>&1",

      #初始化pluginDocker主机
      "./utils-scp.sh root ${tencentcloud_instance.docker_host_1.private_ip} ${var.default_password} wecube-s3.tpl /root/",
      "./utils-scp.sh root ${tencentcloud_instance.docker_host_2.private_ip} ${var.default_password} wecube-s3.tpl /root/",
      "./init-plugin-docker-host.sh ${tencentcloud_instance.docker_host_1.private_ip} ${var.default_password} 9001 >> init.log 2>&1",
      "./init-plugin-docker-host.sh ${tencentcloud_instance.docker_host_2.private_ip} ${var.default_password} 9001 >> init.log 2>&1",

      #初始化WeCube主机
      "cp /root/scripts/wecube/wecube-platform/wecube-platform.cfg /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",

      "./utils-sed.sh '{{PLUGIN_MYSQL_IP}}' ${tencentcloud_mysql_instance.PRD1_MG_RDB_wecubeplugin.intranet_ip} /root/scripts/wecube/wecube-platform/database/platform-core/02.wecube.system.data.sql",

      "./utils-sed.sh '{{S3_ENDPOINT}}' 'http://'${tencentcloud_instance.wecube_host_1.private_ip}':9000' /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{WECUBE_LB_HOST}}' ${tencentcloud_clb_instance.internal_clb_1.clb_vips.0} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{RESOURCE_HOST1}}' ${tencentcloud_instance.wecube_host_1.private_ip} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{RESOURCE_HOST2}}' ${tencentcloud_instance.wecube_host_2.private_ip} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{PLUGIN_HOST}}' ${tencentcloud_instance.docker_host_1.private_ip} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{PLUGIN_HOST_PASSWORD}}' ${var.default_password} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{STATIC_RESOURCE_SERVER_PASSWORD}}' ${var.default_password} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_ADDR}}' ${tencentcloud_mysql_instance.PRD1_MG_RDB_wecubecore.intranet_ip} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_PORT}}' ${tencentcloud_mysql_instance.PRD1_MG_RDB_wecubecore.intranet_port} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_PASSWORD}}' ${var.default_password} /root/scripts/wecube/wecube-platform/wecube-platform.cfg",

      "./utils-sed.sh '{{S3_ENDPOINT}}' 'http://'${tencentcloud_instance.wecube_host_2.private_ip}':9000' /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{WECUBE_LB_HOST}}' ${tencentcloud_clb_instance.internal_clb_1.clb_vips.0} /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{RESOURCE_HOST1}}' ${tencentcloud_instance.wecube_host_1.private_ip} /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{RESOURCE_HOST2}}' ${tencentcloud_instance.wecube_host_2.private_ip} /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{PLUGIN_HOST}}' ${tencentcloud_instance.docker_host_2.private_ip} /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{PLUGIN_HOST_PASSWORD}}' ${var.default_password} /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{STATIC_RESOURCE_SERVER_PASSWORD}}' ${var.default_password} /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{MYSQL_ADDR}}' ${tencentcloud_mysql_instance.PRD1_MG_RDB_wecubecore.intranet_ip} /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{MYSQL_PORT}}' ${tencentcloud_mysql_instance.PRD1_MG_RDB_wecubecore.intranet_port} /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{MYSQL_PASSWORD}}' ${var.default_password} /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",

      "cp -r /root/scripts/wecube/wecube-platform /root/scripts/wecube/wecube-platform-scripts",
      "dos2unix /root/scripts/wecube/wecube-platform-scripts/*",

      "./utils-scp.sh root ${tencentcloud_instance.wecube_host_1.private_ip} ${var.default_password} '-r /root/scripts/wecube/wecube-platform-scripts' /root/",
      "./init-wecube-platform-host.sh ${tencentcloud_instance.wecube_host_1.private_ip} ${var.default_password} ${var.wecube_version} 'wecube-platform.cfg' 9000 >> init.log 2>&1",

      "./utils-scp.sh root ${tencentcloud_instance.wecube_host_2.private_ip} ${var.default_password} '-r /root/scripts/wecube/wecube-platform-scripts' /root/",
      "./init-wecube-platform-host.sh ${tencentcloud_instance.wecube_host_2.private_ip} ${var.default_password} ${var.wecube_version} 'wecube-platform-2.cfg' 9000 >> init.log 2>&1"
    ]
  }
}

output "Tips" {
  value = " \n -------------------cloud-------------------- \n   HWCLOUD_API_SECRET   SecretKey=${var.secret_key};AccessKey=${var.secret_id};DomainId=*** \n   HWCLOUD_LOCATION   CloudApiDomainName=myhuaweicloud.com;Region=${var.region};ProjectId=*** \n    \n   -------------------vpc---------------------- \n   ${tencentcloud_vpc.PRD_MG.name}  ${tencentcloud_vpc.PRD_MG.id} \n    \n   -------------------subnet------------------- \n   ${tencentcloud_subnet.PRD1_MG_APP.name}  ${tencentcloud_subnet.PRD1_MG_APP.id} \n   ${tencentcloud_subnet.PRD2_MG_APP.name}  ${tencentcloud_subnet.PRD2_MG_APP.id} \n   ${tencentcloud_subnet.PRD1_MG_RDB.name}  ${tencentcloud_subnet.PRD1_MG_RDB.id} \n   ${tencentcloud_subnet.PRD2_MG_RDB.name}  ${tencentcloud_subnet.PRD2_MG_RDB.id} \n   ${tencentcloud_subnet.PRD1_MG_LB.name}  ${tencentcloud_subnet.PRD1_MG_LB.id} \n   ${tencentcloud_subnet.PRD2_MG_LB.name}  ${tencentcloud_subnet.PRD2_MG_LB.id} \n   ${tencentcloud_subnet.PRD1_MG_VDI.name}  ${tencentcloud_subnet.PRD1_MG_VDI.id} \n   ${tencentcloud_subnet.PRD1_MG_PROXY.name}  ${tencentcloud_subnet.PRD1_MG_PROXY.id} \n    \n   -------------------host---------------------- \n   ${tencentcloud_instance.wecube_host_1.instance_name} ${tencentcloud_instance.wecube_host_1.id} \n   ${tencentcloud_instance.wecube_host_2.instance_name} ${tencentcloud_instance.wecube_host_2.id} \n   ${tencentcloud_instance.docker_host_1.instance_name} ${tencentcloud_instance.docker_host_1.id} \n   ${tencentcloud_instance.docker_host_2.instance_name} ${tencentcloud_instance.docker_host_2.id} \n   ${tencentcloud_instance.instance_squid.instance_name} ${tencentcloud_instance.instance_squid.id} \n   ${tencentcloud_instance.instance_vdi.instance_name} ${tencentcloud_instance.instance_vdi.id} \n    \n   -------------------mysqldb------------------ \n   ${tencentcloud_mysql_instance.PRD1_MG_RDB_wecubecore.instance_name} ${tencentcloud_mysql_instance.PRD1_MG_RDB_wecubecore.id} \n   ${tencentcloud_mysql_instance.PRD1_MG_RDB_wecubeplugin.instance_name} ${tencentcloud_mysql_instance.PRD1_MG_RDB_wecubeplugin.id} \n    \n   ------------------------------------------ \n    \n    \n   \n Please follow below steps:\n 1.Login your Windows VDI[IP:${tencentcloud_instance.instance_vdi.public_ip}] with [User/Password：Administrator/${var.default_password}];\n 2.Install Chrome browser;\n 3.Use Chrome browser to access 'http://${tencentcloud_clb_instance.internal_clb_1.clb_vips.0}:19090';\n \n \n Thank you in advance for your kind support and continued business.\n More Info: https://github.com/WeBankPartners/delivery-by-terraform "
}

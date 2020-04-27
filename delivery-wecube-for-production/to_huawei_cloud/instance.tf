#mysql参数模板
resource "huaweicloud_rds_parametergroup_v3" "wecube_db" {
  name        = "wecube_db"
  description = "description_1"
  values = {
    character_set_server = "utf8mb4"
    time_zone            = "Asia/Shanghai"
  }
  datastore {
    type    = "mysql"
    version = "5.6"
  }
}

#创建WeCube数据库mysql实例
resource "huaweicloud_rds_instance_v3" "mysql_instance_wecube_core" {
  availability_zone = ["${var.hw_az_master}", "${var.hw_az_slave}"]
  db {
    password = "${var.default_password}"
    type     = "MySQL"
    version  = "5.6"
    port     = "3306"
  }
  name              = "PRD1_MG_RDB_wecubecore"
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_mg.id}"
  subnet_id         = "${huaweicloud_vpc_subnet_v1.subnet_db1.id}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  volume {
    type = "ULTRAHIGH"
    size = 40
  }

  # 2C4G 
  flavor = "rds.mysql.c6.large.2.ha"
  # “async”为异步模式。“semisync”为半同步模式。
  ha_replication_mode = "semisync"
  backup_strategy {
    # UTC time
    start_time = "23:00-00:00"
    keep_days  = 7
  }
  param_group_id = "${huaweicloud_rds_parametergroup_v3.wecube_db.id}"
}

#创建WeCubePlugin数据库mysql实例
resource "huaweicloud_rds_instance_v3" "mysql_instance_plugin" {
  availability_zone = ["${var.hw_az_master}", "${var.hw_az_slave}"]
  db {
    password = "${var.default_password}"
    type     = "MySQL"
    version  = "5.6"
    port     = "3306"
  }
  name              = "PRD1_MG_RDB_wecubeplugin"
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_mg.id}"
  subnet_id         = "${huaweicloud_vpc_subnet_v1.subnet_db1.id}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  volume {
    type = "ULTRAHIGH"
    size = 40
  }

  # 2C4G 
  flavor = "rds.mysql.c6.large.2.ha"
  # “async”为异步模式。“semisync”为半同步模式。
  ha_replication_mode = "semisync"
  backup_strategy {
    # UTC time
    start_time = "23:00-00:00"
    keep_days  = 7
  }
  param_group_id = "${huaweicloud_rds_parametergroup_v3.wecube_db.id}"
}

#创建WeCube S3存储桶
resource "huaweicloud_s3_bucket" "s3-wecube" {
  bucket        = "${var.obs_bucket_name}"
  acl           = "private"
  force_destroy = true
}

#创建WeCube plugin docker 主机
resource "huaweicloud_ecs_instance_v1" "docker_host_1" {
  name     = "PRD1_MG_APP_10.128.202.3_wecubeplugin"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 4C8G
  #flavor = "s6.xlarge.2"

  # for 4C16G
  flavor = "s3.xlarge.4"
  vpc_id = "${huaweicloud_vpc_v1.vpc_mg.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_app1.id}"
    ip_address = "10.128.202.3"
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}", "${huaweicloud_networking_secgroup_v2.sg_app1.id}"]
  system_disk_size  = 40
  password          = "${var.default_password}"
}
resource "huaweicloud_ecs_instance_v1" "docker_host_2" {
  name     = "PRD2_MG_APP_10.128.218.3_wecubeplugin"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 4C8G
  #flavor = "s6.xlarge.2"

  # for 4C16G
  flavor = "s3.xlarge.4"
  vpc_id = "${huaweicloud_vpc_v1.vpc_mg.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_app2.id}"
    ip_address = "10.128.218.3"
  }
  availability_zone = "${var.hw_az_slave}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}", "${huaweicloud_networking_secgroup_v2.sg_app2.id}"]
  system_disk_size  = 40
  password          = "${var.default_password}"
}

#创建WeCube Platform主机
resource "huaweicloud_ecs_instance_v1" "wecube_host_1" {
  name     = "PRD1_MG_APP_10.128.202.2_wecubecore"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 2C4G
  flavor = "s6.large.2"
  vpc_id = "${huaweicloud_vpc_v1.vpc_mg.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_app1.id}"
    ip_address = "10.128.202.2"
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}", "${huaweicloud_networking_secgroup_v2.sg_app1.id}"]
  system_disk_size  = 40
  password          = "${var.default_password}"
}
resource "huaweicloud_ecs_instance_v1" "wecube_host_2" {
  name     = "PRD2_MG_APP_10.128.218.2_wecubecore"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 2C4G
  flavor = "s6.large.2"
  vpc_id = "${huaweicloud_vpc_v1.vpc_mg.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_app2.id}"
    ip_address = "10.128.218.2"
  }
  availability_zone = "${var.hw_az_slave}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}", "${huaweicloud_networking_secgroup_v2.sg_app2.id}"]
  system_disk_size  = 40
  password          = "${var.default_password}"
}

#创建 负载均衡 internal_elb_1
resource "huaweicloud_lb_loadbalancer_v2" "internal_elb_1" {
  vip_subnet_id = "${huaweicloud_vpc_subnet_v1.subnet_lb1.id}"
  name          = "PRD1_MG_LB_1"
  vip_address   = "10.128.200.2"
}
#19090 portal监听器
resource "huaweicloud_lb_listener_v2" "http_listener_portal1" {
  protocol        = "HTTP"
  protocol_port   = 19090
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_1.id}"
  name            = "http_listener_portal1"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb1_portal" {
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${huaweicloud_lb_listener_v2.http_listener_portal1.id}"
  persistence {
    type = "HTTP_COOKIE"
  }
}
#创建后端服务器
resource "huaweicloud_lb_member_v2" "member_host1_portal1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address}"
  protocol_port = 19090
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_portal.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_lb1.id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_portal1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19090
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_portal.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_lb1.id}"
}
#创建健康检查
resource "huaweicloud_lb_monitor_v2" "monitor_host1_portal" {
  pool_id      = "${huaweicloud_lb_pool_v2.pool_lb1_portal.id}"
  type         = "HTTP"
  delay        = 20
  timeout      = 10
  max_retries  = 5
  url_path     = "/platform/v1/health-check"
  expected_codes = "200"
}
#19110 gateway监听器
resource "huaweicloud_lb_listener_v2" "http_listener_gateway1" {
  protocol        = "TCP"
  protocol_port   = 19110
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_1.id}"
  name            = "http_listener_gateway1"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb1_gateway" {
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${huaweicloud_lb_listener_v2.http_listener_gateway1.id}"
  persistence {
    type = "HTTP_COOKIE"
  }
}
#创建后端服务器
resource "huaweicloud_lb_member_v2" "member_host1_gateway1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_gateway.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_lb1.id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_gateway1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_gateway.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_lb1.id}"
}
#19100 core监听器
resource "huaweicloud_lb_listener_v2" "http_listener_core1" {
  protocol        = "TCP"
  protocol_port   = 19110
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_1.id}"
  name            = "http_listener_core1"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb1_core" {
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${huaweicloud_lb_listener_v2.http_listener_core1.id}"
  persistence {
    type = "HTTP_COOKIE"
  }
}
#创建后端服务器
resource "huaweicloud_lb_member_v2" "member_host1_core1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_core.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_lb1.id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_core1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_core.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_lb1.id}"
}
#19120 auth监听器
resource "huaweicloud_lb_listener_v2" "http_listener_auth1" {
  protocol        = "TCP"
  protocol_port   = 19110
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_1.id}"
  name            = "http_listener_auth1"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb1_auth" {
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${huaweicloud_lb_listener_v2.http_listener_auth1.id}"
  persistence {
    type = "HTTP_COOKIE"
  }
}
#创建后端服务器
resource "huaweicloud_lb_member_v2" "member_host1_auth1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_auth.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_lb1.id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_auth1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_auth.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_lb1.id}"
}


#创建 负载均衡 internal_elb_2
resource "huaweicloud_lb_loadbalancer_v2" "internal_elb_2" {
  vip_subnet_id = "${huaweicloud_vpc_subnet_v1.subnet_lb2.id}"
  name          = "PRD2_MG_LB_2"
  vip_address   = "10.128.216.2"
}



#创建Squid主机
resource "huaweicloud_compute_instance_v2" "instance_squid" {
  name     = "PRD1_MG_PROXY_wecubesquid"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 1C1G
  #flavor_name = "s6.small.1"

  # for 1C4G
  flavor_name = "s3.medium.4"
  network {
    uuid           = "${huaweicloud_vpc_subnet_v1.subnet_proxy.id}"
    fixed_ip_v4    = "10.128.199.3"
    access_network = true
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}", "${huaweicloud_networking_secgroup_v2.sg_proxy.id}"]
  admin_pass        = "${var.default_password}"
}

resource "huaweicloud_networking_floatingip_v2" "squid_public_ip" {
}

resource "huaweicloud_compute_floatingip_associate_v2" "squid_public_ip" {
  floating_ip = "${huaweicloud_networking_floatingip_v2.squid_public_ip.address}"
  instance_id = "${huaweicloud_compute_instance_v2.instance_squid.id}"
  fixed_ip    = "${huaweicloud_compute_instance_v2.instance_squid.network.0.fixed_ip_v4}"
}

#创建VDI-windows主机
resource "huaweicloud_ecs_instance_v1" "instance_vdi" {
  name     = "PRD1_MG_OVDI_wecubevdi"
  image_id = "921808eb-6cde-46cc-8e22-87df97b099a0"
  # for 2C4G
  flavor = "s6.large.2"
  vpc_id = "${huaweicloud_vpc_v1.vpc_mg.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_vdi.id}"
    ip_address = "10.128.196.3"
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}", "${huaweicloud_networking_secgroup_v2.sg_ovdi.id}"]
  #system_disk_type  = "co-p1"
  system_disk_size = 40
  password         = "${var.default_password}"
}

resource "huaweicloud_networking_floatingip_v2" "vdi_public_ip" {
}

resource "huaweicloud_compute_floatingip_associate_v2" "vdi_public_ip" {
  floating_ip = "${huaweicloud_networking_floatingip_v2.vdi_public_ip.address}"
  instance_id = "${huaweicloud_ecs_instance_v1.instance_vdi.id}"
  fixed_ip    = "${huaweicloud_ecs_instance_v1.instance_vdi.nics.0.ip_address}"
}

resource "null_resource" "null_instance" {
  triggers = {
    public_ip = "${huaweicloud_networking_floatingip_v2.squid_public_ip.address}"
  }

  connection {
    type     = "ssh"
    user     = "root"
    password = "${var.default_password}"
    host     = "${huaweicloud_networking_floatingip_v2.squid_public_ip.address}"
  }

  provisioner "file" {
    source      = "scripts"
    destination = "/root/wecube"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/yum.repos.d/repo_bak/ && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/repo_bak/",
      "curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.myhuaweicloud.com/repo/CentOS-Base-7.repo",
      "rpm -ivh http://mirrors.myhuaweicloud.com/epel/epel-release-latest-7.noarch.rpm",
      "wget -qO /etc/yum.repos.d/epel.repo http://mirrors.myhuaweicloud.com/repo/epel-7.repo",
      "yum clean metadata",
      "yum makecache",
      "yum install epel-release -y >/dev/null 2>&1",
      "yum install dos2unix -y",
      "yum install -y sshpass",
      "yum install -y expect",

      "dos2unix /root/wecube/*",
      "dos2unix /root/wecube/wecube-platform/*",
      "dos2unix /root/wecube/auto-plugin-installer/*",
      "mkdir -p ${var.wecube_home_folder}",
      "cp -r /root/wecube/* ${var.wecube_home_folder}",
      "chmod -R +x ${var.wecube_home_folder}/*",
      "cd ${var.wecube_home_folder}",

      #差异化变量替换
      "./utils-sed.sh '{{MYSQL_RESOURCE_SERVER_IP}}' ${huaweicloud_rds_instance_v3.mysql_instance_plugin.private_ips.0} ${var.wecube_home_folder}/wecube-platform/database/platform-core/02.wecube.system.data.sql",
      "./utils-sed.sh '{{GATEWAY_IP}}' ${huaweicloud_lb_loadbalancer_v2.internal_elb_1.vip_address} ${var.wecube_home_folder}/wecube-platform/database/platform-core/02.wecube.system.data.sql",

      "./utils-sed.sh '{{S3_ACCESS_KEY}}' ${var.hw_access_key} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{S3_SECRET_KEY}}' ${var.hw_secret_key} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{S3_ENDPOINT}}' 'obs.'${var.hw_region}'.myhuaweicloud.com' ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{STATIC_RESOURCE_SERVER_PASSWORD}}' ${var.default_password} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_ADDR}}' ${huaweicloud_rds_instance_v3.mysql_instance_wecube_core.private_ips.0} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_PORT}}' ${huaweicloud_rds_instance_v3.mysql_instance_wecube_core.db.0.port} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_PASSWORD}}' ${var.default_password} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{WECUBE_BUCKET}}' ${huaweicloud_s3_bucket.s3-wecube.bucket} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",

      "cp /root/scripts/wecube/wecube-platform/wecube-platform.cfg /root/scripts/wecube/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{WECUBE_HOST}}' ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{LB_IP}}' ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      #"./utils-sed.sh '{{LB_IP}}' ${huaweicloud_lb_loadbalancer_v2.internal_elb_1.vip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",

      "./utils-sed.sh '{{WECUBE_HOST}}' ${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{LB_IP}}' ${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform-2.cfg",
      #"./utils-sed.sh '{{LB_IP}}' ${huaweicloud_lb_loadbalancer_v2.internal_elb_1.vip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform-2.cfg",


      #CMDB数据回写前 - 变量替换
      "./utils-sed.sh '{{mysql_password}}' ${var.default_password} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{plugin_mysql_host}}' ${huaweicloud_rds_instance_v3.mysql_instance_plugin.private_ips.0} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{plugin_mysql_port}}' 3306 ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{cmdb_sql_file}}' '${var.wecube_home_folder}/auto-plugin-installer/database/cmdb/01.register_cmdb_asset_ids.sql' ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{wecube_vpc_asset_id}}' ${huaweicloud_vpc_v1.vpc_mg.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{security_group_asset_id}}' ${huaweicloud_networking_secgroup_v2.sg_mg.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_app1_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_app1.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_rdb_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_db1.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_vdi_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_vdi.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_proxy_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_proxy.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{wecube_core_host_id}}' ${huaweicloud_ecs_instance_v1.wecube_host_1.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{pluign_host_id}}' ${huaweicloud_ecs_instance_v1.docker_host_1.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{squid_host_id}}' ${huaweicloud_compute_instance_v2.instance_squid.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{vdi_host_id}}' ${huaweicloud_ecs_instance_v1.instance_vdi.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{rdb_wecube_id}}' ${huaweicloud_rds_instance_v3.mysql_instance_wecube_core.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{rdb_plugin_id}}' ${huaweicloud_rds_instance_v3.mysql_instance_plugin.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{allow_all_mg_tcp_in}}' ${huaweicloud_networking_secgroup_rule_v2.allow_all_mg_tcp_in.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_PROXY_ACCEPT_NDC_WAN_ingress22}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_PROXY_ACCEPT_NDC_WAN_ingress22.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_PROXY_ACCEPT_NDC_WAN_egress80-443}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_PROXY_ACCEPT_NDC_WAN_egress80-443.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_PROXY_ACCEPT_PRD_MG_egress22}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_PROXY_ACCEPT_PRD_MG_egress22.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_OVDI_ACCEPT_NDC_WAN_egress1-65535}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_OVDI_ACCEPT_NDC_WAN_egress1-65535.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_OVDI_ACCEPT_PRD1_MG_APP_egress80-19999}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_OVDI_ACCEPT_PRD1_MG_APP_egress80-19999.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_OVDI_ACCEPT_PRD2_MG_APP_egress80-19999}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_OVDI_ACCEPT_PRD2_MG_APP_egress80-19999.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_OVDI_ACCEPT_PRD1_MG_LB_egress80-19999}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_OVDI_ACCEPT_PRD1_MG_LB_egress80-19999.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_OVDI_ACCEPT_PRD2_MG_LB_egress80-19999}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_OVDI_ACCEPT_PRD2_MG_LB_egress80-19999.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_OVDI_ACCEPT_NDC_WAN_ingress22}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_OVDI_ACCEPT_NDC_WAN_ingress22.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_APP_ACCEPT_PRD1_MG_PROXY_egress3128}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_APP_ACCEPT_PRD1_MG_PROXY_egress3128.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_APP_ACCEPT_PRD1_MG_RDB_egress3306}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_APP_ACCEPT_PRD1_MG_RDB_egress3306.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_APP_ACCEPT_PRD2_MG_RDB_egress3306}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_APP_ACCEPT_PRD2_MG_RDB_egress3306.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_APP_ACCEPT_PRD1_MG_APP_egress1-65535}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_APP_ACCEPT_PRD1_MG_APP_egress1-65535.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_APP_ACCEPT_PRD2_MG_APP_egress1-65535}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_APP_ACCEPT_PRD2_MG_APP_egress1-65535.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_APP_ACCEPT_PRD1_MG_LB_egress80-19999}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_APP_ACCEPT_PRD1_MG_LB_egress80-19999.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD1_MG_APP_ACCEPT_PRD2_MG_LB_egress80-19999}}' ${huaweicloud_networking_secgroup_rule_v2.PRD1_MG_APP_ACCEPT_PRD2_MG_LB_egress80-19999.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD2_MG_APP_ACCEPT_PRD1_MG_PROXY_egress3128}}' ${huaweicloud_networking_secgroup_rule_v2.PRD2_MG_APP_ACCEPT_PRD1_MG_PROXY_egress3128.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD2_MG_APP_ACCEPT_PRD1_MG_RDB_egress3306}}' ${huaweicloud_networking_secgroup_rule_v2.PRD2_MG_APP_ACCEPT_PRD1_MG_RDB_egress3306.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD2_MG_APP_ACCEPT_PRD2_MG_RDB_egress3306}}' ${huaweicloud_networking_secgroup_rule_v2.PRD2_MG_APP_ACCEPT_PRD2_MG_RDB_egress3306.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD2_MG_APP_ACCEPT_PRD1_MG_APP_egress1-65535}}' ${huaweicloud_networking_secgroup_rule_v2.PRD2_MG_APP_ACCEPT_PRD1_MG_APP_egress1-65535.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD2_MG_APP_ACCEPT_PRD2_MG_APP_egress1-65535}}' ${huaweicloud_networking_secgroup_rule_v2.PRD2_MG_APP_ACCEPT_PRD2_MG_APP_egress1-65535.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD2_MG_APP_ACCEPT_PRD1_MG_LB_egress80-19999}}' ${huaweicloud_networking_secgroup_rule_v2.PRD2_MG_APP_ACCEPT_PRD1_MG_LB_egress80-19999.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{PRD2_MG_APP_ACCEPT_PRD2_MG_LB_egress80-19999}}' ${huaweicloud_networking_secgroup_rule_v2.PRD2_MG_APP_ACCEPT_PRD2_MG_LB_egress80-19999.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",


      "./utils-sed.sh '{{wecube_mysql_host}}' ${huaweicloud_rds_instance_v3.mysql_instance_wecube_core.private_ips.0} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{wecube_mysql_port}}' 3306 ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{wecube_sql_script_file}}' '${var.wecube_home_folder}/auto-plugin-installer/database/wecube/01.update_system_variables.sql' ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{project_id}}' ${var.hw_project_id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      #初始化Squid主机
      "./utils-scp.sh root ${huaweicloud_compute_instance_v2.instance_squid.network.0.fixed_ip_v4} ${var.default_password} '-r ${var.wecube_home_folder}/auto-plugin-installer' /root/",
      "./install-squid.sh  ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.default_password} ${var.wecube_home_folder} ${huaweicloud_rds_instance_v3.mysql_instance_plugin.private_ips.0} ${huaweicloud_ecs_instance_v1.docker_host_1.nics.0.ip_address} >> init.log 2>&1",

      #安装S3，并且初始化pluginDocker主机
      "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.docker_host_1.nics.0.ip_address} ${var.default_password} wecube-s3.tpl /root/",
      "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.docker_host_1.nics.0.ip_address} ${var.default_password} init-host.sh /root/",
      "./init-plugin-resource-host.sh ${huaweicloud_ecs_instance_v1.docker_host_1.nics.0.ip_address} ${var.default_password} > init.log 2>&1",
      "./init-plugin-docker-host.sh ${huaweicloud_ecs_instance_v1.docker_host_1.nics.0.ip_address} ${var.default_password} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg >> init.log 2>&1",

      "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.docker_host_2.nics.0.ip_address} ${var.default_password} init-host.sh /root/",
      "./init-plugin-docker-host.sh ${huaweicloud_ecs_instance_v1.docker_host_2.nics.0.ip_address} ${var.default_password} ${var.wecube_home_folder}/wecube-platform/wecube-platform-2.cfg >> init.log 2>&1",

      #init WeCube host
      "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.default_password} init-host.sh /root/",
      "cp -r ${var.wecube_home_folder}/wecube-platform ${var.wecube_home_folder}/wecube-platform-scripts",
      "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.default_password} '-r ${var.wecube_home_folder}/wecube-platform-scripts' /root/",
      "./init-wecube-platform-host.sh ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.default_password} ${var.wecube_version} >> init.log 2>&1",

      #auto run plugins
      "cd auto-plugin-installer",
      "./auto-run-plugins.sh 'Y' ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.default_password} ${var.wecube_home_folder} ${huaweicloud_rds_instance_v3.mysql_instance_plugin.private_ips.0} ${huaweicloud_ecs_instance_v1.docker_host_1.nics.0.ip_address}"

    ]

  }
}




#mysql参数模板
resource "huaweicloud_rds_parametergroup_v3" "wecube_db" {
  name        = "${var.rds_parametergroup_name}"
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
  name              = "${var.rds_core_name}"
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_mg.id}"
  subnet_id         = "${huaweicloud_vpc_subnet_v1.subnet_db1.id}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  volume {
    type = "ULTRAHIGH"
    size = 40
  }

  # 2C4G HA
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
  name              = "${var.rds_plugin_name}"
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_mg.id}"
  subnet_id         = "${huaweicloud_vpc_subnet_v1.subnet_db1.id}"
  vpc_id            = "${huaweicloud_vpc_v1.vpc_mg.id}"
  volume {
    type = "ULTRAHIGH"
    size = 40
  }

  # 2C4G HA
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
  bucket        = "${var.s3_bucket_name}"
  acl           = "private"
  force_destroy = true
}

#创建WeCube plugin docker 主机
resource "huaweicloud_ecs_instance_v1" "docker_host_1" {
  name     = "${var.ecs_plugin_host1_name}"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 4C8G
  flavor = "s3.xlarge.2"

  vpc_id = "${huaweicloud_vpc_v1.vpc_mg.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_app1.id}"
    ip_address = "10.128.202.3"
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}"]
  system_disk_size  = 40
  system_disk_type  = "SAS"
  password          = "${var.default_password}"
}
resource "huaweicloud_ecs_instance_v1" "docker_host_2" {
  name     = "${var.ecs_plugin_host2_name}"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 4C8G
  flavor = "s3.xlarge.2"

  vpc_id = "${huaweicloud_vpc_v1.vpc_mg.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_app2.id}"
    ip_address = "10.128.218.3"
  }
  availability_zone = "${var.hw_az_slave}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}"]
  system_disk_size  = 40
  system_disk_type  = "SAS"
  password          = "${var.default_password}"
}

#创建WeCube Platform主机
resource "huaweicloud_ecs_instance_v1" "wecube_host_1" {
  name     = "${var.ecs_wecube_host1_name}"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 2C4G
  flavor = "s3.large.2"
  vpc_id = "${huaweicloud_vpc_v1.vpc_mg.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_app1.id}"
    ip_address = "10.128.202.2"
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}"]
  system_disk_size  = 40
  system_disk_type  = "SAS"
  password          = "${var.default_password}"
}
resource "huaweicloud_ecs_instance_v1" "wecube_host_2" {
  name     = "${var.ecs_wecube_host2_name}"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 2C4G
  flavor = "s3.large.2"
  vpc_id = "${huaweicloud_vpc_v1.vpc_mg.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_app2.id}"
    ip_address = "10.128.218.2"
  }
  availability_zone = "${var.hw_az_slave}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}"]
  system_disk_size  = 40
  system_disk_type  = "SAS"
  password          = "${var.default_password}"
}

#创建 负载均衡 internal_elb_1
resource "huaweicloud_lb_loadbalancer_v2" "internal_elb_1" {
  vip_subnet_id = "${huaweicloud_vpc_subnet_v1.subnet_lb1.subnet_id}"
  name          = "${var.lb1_name}"
  vip_address   = "10.128.200.2"
}
#19090 portal监听器
resource "huaweicloud_lb_listener_v2" "http_listener_portal1" {
  protocol        = "HTTP"
  protocol_port   = 19090
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_1.id}"
  name            = "${var.lb1_listener1_name}"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb1_portal" {
  name        = "WeCube-Portal"
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
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app1.subnet_id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_portal1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19090
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_portal.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app2.subnet_id}"
}
#创建健康检查
resource "huaweicloud_lb_monitor_v2" "monitor_host1_portal" {
  pool_id        = "${huaweicloud_lb_pool_v2.pool_lb1_portal.id}"
  type           = "HTTP"
  delay          = 20
  timeout        = 10
  max_retries    = 5
  url_path       = "/platform/v1/health-check"
  expected_codes = "200"
}
#19110 gateway监听器
resource "huaweicloud_lb_listener_v2" "http_listener_gateway1" {
  protocol        = "HTTP"
  protocol_port   = 19110
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_1.id}"
  name            = "${var.lb1_listener2_name}"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb1_gateway" {
  name        = "WeCube-Gateway"
  protocol    = "HTTP"
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
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app1.subnet_id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_gateway1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_gateway.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app2.subnet_id}"
}
#19100 core监听器
resource "huaweicloud_lb_listener_v2" "http_listener_core1" {
  protocol        = "HTTP"
  protocol_port   = 19100
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_1.id}"
  name            = "${var.lb1_listener3_name}"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb1_core" {
  name        = "WeCube-Core"
  protocol    = "HTTP"
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
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app1.subnet_id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_core1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_core.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app2.subnet_id}"
}
#19120 auth监听器
resource "huaweicloud_lb_listener_v2" "http_listener_auth1" {
  protocol        = "HTTP"
  protocol_port   = 19120
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_1.id}"
  name            = "${var.lb1_listener4_name}"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb1_auth" {
  name        = "WeCube-Auth"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${huaweicloud_lb_listener_v2.http_listener_auth1.id}"
  persistence {
    type = "HTTP_COOKIE"
  }
}
#创建后端服务器
resource "huaweicloud_lb_member_v2" "member_host1_auth1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address}"
  protocol_port = 19120
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_auth.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app1.subnet_id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_auth1" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19120
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb1_auth.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app2.subnet_id}"
}


#创建 负载均衡 internal_elb_2
resource "huaweicloud_lb_loadbalancer_v2" "internal_elb_2" {
  vip_subnet_id = "${huaweicloud_vpc_subnet_v1.subnet_lb2.subnet_id}"
  name          = "${var.lb2_name}"
  vip_address   = "10.128.216.2"
}
#19090 portal监听器
resource "huaweicloud_lb_listener_v2" "http_listener_portal2" {
  protocol        = "HTTP"
  protocol_port   = 19090
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_2.id}"
  name            = "${var.lb2_listener1_name}"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb2_portal" {
  name        = "WeCube-Portal"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${huaweicloud_lb_listener_v2.http_listener_portal2.id}"
  persistence {
    type = "HTTP_COOKIE"
  }
}
#创建后端服务器
resource "huaweicloud_lb_member_v2" "member_host1_portal2" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address}"
  protocol_port = 19090
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb2_portal.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app1.subnet_id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_portal2" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19090
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb2_portal.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app2.subnet_id}"
}
#创建健康检查
resource "huaweicloud_lb_monitor_v2" "monitor_host1_portal2" {
  pool_id        = "${huaweicloud_lb_pool_v2.pool_lb2_portal.id}"
  type           = "HTTP"
  delay          = 20
  timeout        = 10
  max_retries    = 5
  url_path       = "/platform/v1/health-check"
  expected_codes = "200"
}
#19110 gateway监听器
resource "huaweicloud_lb_listener_v2" "http_listener_gateway2" {
  protocol        = "HTTP"
  protocol_port   = 19110
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_2.id}"
  name            = "${var.lb2_listener2_name}"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb2_gateway" {
  name        = "WeCube-Gateway"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${huaweicloud_lb_listener_v2.http_listener_gateway2.id}"
  persistence {
    type = "HTTP_COOKIE"
  }
}
#创建后端服务器
resource "huaweicloud_lb_member_v2" "member_host1_gateway2" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb2_gateway.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app1.subnet_id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_gateway2" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb2_gateway.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app2.subnet_id}"
}
#19100 core监听器
resource "huaweicloud_lb_listener_v2" "http_listener_core2" {
  protocol        = "HTTP"
  protocol_port   = 19100
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_2.id}"
  name            = "${var.lb2_listener3_name}"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb2_core" {
  name        = "WeCube-Core"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${huaweicloud_lb_listener_v2.http_listener_core2.id}"
  persistence {
    type = "HTTP_COOKIE"
  }
}
#创建后端服务器
resource "huaweicloud_lb_member_v2" "member_host1_core2" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb2_core.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app1.subnet_id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_core2" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19110
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb2_core.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app2.subnet_id}"
}
#19120 auth监听器
resource "huaweicloud_lb_listener_v2" "http_listener_auth2" {
  protocol        = "HTTP"
  protocol_port   = 19120
  loadbalancer_id = "${huaweicloud_lb_loadbalancer_v2.internal_elb_2.id}"
  name            = "${var.lb2_listener4_name}"
}
#创建后端服务组
resource "huaweicloud_lb_pool_v2" "pool_lb2_auth" {
  name        = "WeCube-Auth"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${huaweicloud_lb_listener_v2.http_listener_auth2.id}"
  persistence {
    type = "HTTP_COOKIE"
  }
}
#创建后端服务器
resource "huaweicloud_lb_member_v2" "member_host1_auth2" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address}"
  protocol_port = 19120
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb2_auth.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app1.subnet_id}"
}
resource "huaweicloud_lb_member_v2" "member_host2_auth2" {
  address       = "${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}"
  protocol_port = 19120
  pool_id       = "${huaweicloud_lb_pool_v2.pool_lb2_auth.id}"
  subnet_id     = "${huaweicloud_vpc_subnet_v1.subnet_app2.subnet_id}"
}


#创建Squid主机
resource "huaweicloud_compute_instance_v2" "instance_squid" {
  name     = "${var.ecs_squid_name}"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 1C1G
  flavor_name = "s3.small.1"

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
  name     = "${var.ecs_vdi_name}"
  image_id = "921808eb-6cde-46cc-8e22-87df97b099a0"
  #image_id = "fc5f6efb-882b-40d7-92a5-89d6e8b5ceee"
  # for 2C4G
  flavor = "s3.large.2"
  vpc_id = "${huaweicloud_vpc_v1.vpc_mg.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_vdi.id}"
    ip_address = "10.128.196.3"
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_mg.id}", "${huaweicloud_networking_secgroup_v2.sg_ovdi.id}"]
  #system_disk_type  = "SAS"
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
      "./utils-sed.sh '{{DOCKER1_RESOURCE_SERVER_IP}}' ${huaweicloud_ecs_instance_v1.docker_host_1.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/database/platform-core/02.wecube.system.data.sql",
      "./utils-sed.sh '{{DOCKER2_RESOURCE_SERVER_IP}}' ${huaweicloud_ecs_instance_v1.docker_host_2.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/database/platform-core/02.wecube.system.data.sql",
      "./utils-sed.sh '{{S3_1_RESOURCE_SERVER_IP}}' ${huaweicloud_ecs_instance_v1.docker_host_1.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/database/platform-core/02.wecube.system.data.sql",
      "./utils-sed.sh '{{S3_2_RESOURCE_SERVER_IP}}' ${huaweicloud_ecs_instance_v1.docker_host_2.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/database/platform-core/02.wecube.system.data.sql",


      "./utils-sed.sh '{{RESOURCE_HOST1}}' ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{RESOURCE_HOST2}}' ${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address}  ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{S3_ACCESS_KEY}}' ${var.hw_access_key} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{S3_SECRET_KEY}}' ${var.hw_secret_key} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{S3_ENDPOINT}}' 'obs.'${var.hw_region}'.myhuaweicloud.com' ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{STATIC_RESOURCE_SERVER_PASSWORD}}' ${var.default_password} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_ADDR}}' ${huaweicloud_rds_instance_v3.mysql_instance_wecube_core.private_ips.0} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_PORT}}' ${huaweicloud_rds_instance_v3.mysql_instance_wecube_core.db.0.port} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_PASSWORD}}' ${var.default_password} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{WECUBE_BUCKET}}' ${huaweicloud_s3_bucket.s3-wecube.bucket} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",

      "cp ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg ${var.wecube_home_folder}/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{WECUBE_HOST}}' ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{LB_IP}}' ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform.cfg",

      "./utils-sed.sh '{{WECUBE_HOST}}' ${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform-2.cfg",
      "./utils-sed.sh '{{LB_IP}}' ${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address} ${var.wecube_home_folder}/wecube-platform/wecube-platform-2.cfg",

      #CMDB数据回写前 - 变量替换
      "./utils-sed.sh '{{mysql_password}}' ${var.default_password} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{plugin_mysql_host}}' ${huaweicloud_rds_instance_v3.mysql_instance_plugin.private_ips.0} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{cmdb_sql_file}}' '${var.wecube_home_folder}/auto-plugin-installer/database/cmdb/01.register_cmdb_asset_ids.sql' ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{project_id}}' ${var.hw_project_id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{az_master}}' ${var.hw_az_master} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{az_slave}}' ${var.hw_az_slave} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{wecube_vpc_asset_id}}' ${huaweicloud_vpc_v1.vpc_mg.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{vpc_name}}' ${var.vpc_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{security_group_asset_id}}' ${huaweicloud_networking_secgroup_v2.sg_mg.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{app1_subnet_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_app1.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{app2_subnet_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_app2.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_app1_name}}' ${var.subnet_app1_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_app2_name}}' ${var.subnet_app2_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{db1_subnet_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_db1.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{db2_subnet_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_db2.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_db1_name}}' ${var.subnet_db1_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_db2_name}}' ${var.subnet_db2_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{lb1_subnet_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_lb1.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{lb2_subnet_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_lb2.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_lb1_name}}' ${var.subnet_lb1_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_lb2_name}}' ${var.subnet_lb2_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{vdi_subnet_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_vdi.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_vdi_name}}' ${var.subnet_vdi_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{proxy_subnet_asset_id}}' ${huaweicloud_vpc_subnet_v1.subnet_proxy.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{subnet_proxy_name}}' ${var.subnet_proxy_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{wecube_host1_id}}' ${huaweicloud_ecs_instance_v1.wecube_host_1.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{wecube_host2_id}}' ${huaweicloud_ecs_instance_v1.wecube_host_2.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{ecs_wecube_host1_name}}' ${var.ecs_wecube_host1_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{ecs_wecube_host2_name}}' ${var.ecs_wecube_host2_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{pluign_host1_id}}' ${huaweicloud_ecs_instance_v1.docker_host_1.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{pluign_host2_id}}' ${huaweicloud_ecs_instance_v1.docker_host_2.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{ecs_plugin_host1_name}}' ${var.ecs_plugin_host1_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{ecs_plugin_host2_name}}' ${var.ecs_plugin_host2_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{squid_host_id}}' ${huaweicloud_compute_instance_v2.instance_squid.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{vdi_host_id}}' ${huaweicloud_ecs_instance_v1.instance_vdi.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{ecs_squid_name}}' ${var.ecs_squid_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{ecs_vdi_name}}' ${var.ecs_vdi_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{rdb_wecubecore_id}}' ${huaweicloud_rds_instance_v3.mysql_instance_wecube_core.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{rdb_wecubeplugin_id}}' ${huaweicloud_rds_instance_v3.mysql_instance_plugin.id} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{rds_core_name}}' ${var.rds_core_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{rds_plugin_name}}' ${var.rds_plugin_name} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{wecube_mysql_host}}' ${huaweicloud_rds_instance_v3.mysql_instance_wecube_core.private_ips.0} ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{wecube_mysql_port}}' 3306 ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",
      "./utils-sed.sh '{{wecube_sql_script_file}}' '${var.wecube_home_folder}/auto-plugin-installer/database/wecube/01.update_system_variables.sql' ${var.wecube_home_folder}/auto-plugin-installer/db.cfg",

      "./utils-sed.sh '{{WECUBE_PLUGIN_URL_PREFIX}}' ${var.WECUBE_PLUGIN_URL_PREFIX} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{PKG_WECMDB}}' ${var.PKG_WECMDB} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{PKG_HUAWEICLOUD}}' ${var.PKG_HUAWEICLOUD} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{PKG_SALTSTACK}}' ${var.PKG_SALTSTACK} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{PKG_NOTIFICATIONS}}' ${var.PKG_NOTIFICATIONS} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{PKG_MONITOR}}' ${var.PKG_MONITOR} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{PKG_ARTIFACTS}}' ${var.PKG_ARTIFACTS} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",
      "./utils-sed.sh '{{PKG_SERVICE_MGMT}}' ${var.PKG_SERVICE_MGMT} ${var.wecube_home_folder}/auto-plugin-installer/auto-run.cfg",

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
      "./init-wecube-platform-host.sh ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.default_password} ${var.wecube_version} 'wecube-platform.cfg' 'Y' >> init.log 2>&1",

      "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address} ${var.default_password} init-host.sh /root/",
      "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address} ${var.default_password} '-r ${var.wecube_home_folder}/wecube-platform-scripts' /root/",
      "./init-wecube-platform-host.sh ${huaweicloud_ecs_instance_v1.wecube_host_2.nics.0.ip_address} ${var.default_password} ${var.wecube_version} 'wecube-platform-2.cfg' 'N' >> init.log 2>&1",

      #auto run plugins
      "cd auto-plugin-installer",
      "./auto-run-plugins.sh 'Y' ${huaweicloud_ecs_instance_v1.wecube_host_1.nics.0.ip_address} ${var.default_password} ${var.wecube_home_folder} ${huaweicloud_rds_instance_v3.mysql_instance_plugin.private_ips.0} ${huaweicloud_ecs_instance_v1.docker_host_1.nics.0.ip_address}"

    ]

  }
}




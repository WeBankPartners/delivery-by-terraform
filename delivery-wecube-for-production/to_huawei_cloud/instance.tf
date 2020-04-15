#mysql参数模板
resource "huaweicloud_rds_parametergroup_v3" "pg_1" {
  name        = "pg_1"
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
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_db.id}"
  subnet_id         = "${huaweicloud_vpc_subnet_v1.subnet_db.id}"
  vpc_id            = "${huaweicloud_vpc_v1.wecube_vpc.id}"
  volume {
    type = "ULTRAHIGH"
    size = 40
  }

  # 4C16G 
  #flavor = "rds.mysql.s1.xlarge.ha"
  # 2C4G 
  flavor = "rds.mysql.c6.large.2.ha"
  # “async”为异步模式。“semisync”为半同步模式。
  ha_replication_mode = "async"
  backup_strategy {
    # UTC time
    start_time = "23:00-00:00"
    keep_days  = 7
  }
  param_group_id = "${huaweicloud_rds_parametergroup_v3.pg_1.id}"
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
  security_group_id = "${huaweicloud_networking_secgroup_v2.sg_group_wecube_db.id}"
  subnet_id         = "${huaweicloud_vpc_subnet_v1.subnet_db.id}"
  vpc_id            = "${huaweicloud_vpc_v1.wecube_vpc.id}"
  volume {
    type = "ULTRAHIGH"
    size = 40
  }

  # 4C16G 
  #flavor = "rds.mysql.s1.xlarge.ha"
  # 2C4G 
  flavor = "rds.mysql.c6.large.2.ha"
  # “async”为异步模式。“semisync”为半同步模式。
  ha_replication_mode = "async"
  backup_strategy {
    # UTC time
    start_time = "23:00-00:00"
    keep_days  = 7
  }
  param_group_id = "${huaweicloud_rds_parametergroup_v3.pg_1.id}"
}

#创建WeCube S3存储桶
resource "huaweicloud_s3_bucket" "s3-wecube" {
  bucket = "sg-s3-wecube"
  acl    = "private"
  force_destroy = true
}

#创建WeCube plugin docker 主机
resource "huaweicloud_ecs_instance_v1" "instance_plugin_docker_host_a" {
  name     = "PRD1_MG_APP_10.128.202.2_wecubeplugin"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 4C8G, use 'c3.2xlarge.2' if need 8C16G. 
  flavor = "c3.xlarge.2"
  vpc_id = "${huaweicloud_vpc_v1.wecube_vpc.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_app.id}"
    ip_address = "10.128.202.3"
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_group_wecube_app.id}"]
  system_disk_size = 40
  password         = "${var.default_password}"
}

#创建WeCube Platform主机
resource "huaweicloud_ecs_instance_v1" "instance_wecube_platform" {
  name     = "PRD1_MG_APP_10.128.202.3_wecubecore"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 4C8G, use 'c3.2xlarge.2' if need 8C16G. 
  flavor = "c3.xlarge.2"
  vpc_id = "${huaweicloud_vpc_v1.wecube_vpc.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_app.id}"
    ip_address = "10.128.202.2"
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_group_wecube_app.id}"]
  system_disk_size = 40
  password         = "${var.default_password}"
}

#创建Squid主机
resource "huaweicloud_compute_instance_v2" "instance_squid" {
  name     = "PRD1_MG_PROXY_10.128.199.3_wecubesquid"
  image_id = "bb352f17-03a8-4782-8429-6cdc1fc5207e"
  # for 4C8G, use 'c3.2xlarge.2' if need 8C16G. 
  flavor_name = "c3.xlarge.2"
  network {
    uuid           = "${huaweicloud_vpc_subnet_v1.subnet_proxy.id}"
    fixed_ip_v4    = "10.128.199.3"
    access_network = true
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_group_wecube_vdi.id}"]
  admin_pass = "${var.default_password}"
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
  name     = "PRD1_MG_VDI_10.128.192.3_wecubevdi"
  image_id = "921808eb-6cde-46cc-8e22-87df97b099a0"
  # for 4C8G, use 'c3.2xlarge.2' if need 8C16G. 
  flavor = "c3.xlarge.2"
  vpc_id = "${huaweicloud_vpc_v1.wecube_vpc.id}"
  nics {
    network_id = "${huaweicloud_vpc_subnet_v1.subnet_vdi.id}"
    ip_address = "10.128.192.3"
  }
  availability_zone = "${var.hw_az_master}"
  security_groups   = ["${huaweicloud_networking_secgroup_v2.sg_group_wecube_vdi.id}"]
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
    destination = "/root/scripts"
  }

  provisioner "remote-exec" {
    inline = [
	  "echo 'nameserver ${var.hw_dns1}'>>/etc/resolv.conf",
	  "mkdir -p /etc/yum.repos.d/repo_bak/ && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/repo_bak/",
	  "curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.myhuaweicloud.com/repo/CentOS-Base-7.repo",
	  "rpm -ivh http://mirrors.myhuaweicloud.com/epel/epel-release-latest-7.noarch.rpm",
	  "wget -qO /etc/yum.repos.d/epel.repo http://mirrors.myhuaweicloud.com/repo/epel-7.repo",
	  "yum clean metadata",
	  "yum makecache",
	  "yum install epel-release -y >/dev/null 2>&1",
      "chmod -R +x /root/scripts/*",
	  #"/root/scripts/init-host.sh",
      "yum install dos2unix -y",
      "yum install -y sshpass",
      "yum install -y expect",
      "dos2unix /root/scripts/*",
      "dos2unix /root/scripts/wecube-platform/*",
      "cd /root/scripts",
	  
      #初始化pluginDocker主机，并且安装S3
      "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.instance_plugin_docker_host_a.nics.0.ip_address} ${var.default_password} wecube-s3.tpl /root/",
	  "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.instance_plugin_docker_host_a.nics.0.ip_address} ${var.default_password} init-host.sh /root/",
      "./init-plugin-resource-host.sh ${huaweicloud_ecs_instance_v1.instance_plugin_docker_host_a.nics.0.ip_address} ${var.default_password} > init.log 2>&1",

	  "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.instance_plugin_docker_host_a.nics.0.ip_address} ${var.default_password} init-host.sh /root/",
      "./init-plugin-docker-host.sh ${huaweicloud_ecs_instance_v1.instance_plugin_docker_host_a.nics.0.ip_address} ${var.default_password} /root/scripts/wecube-platform/wecube-platform.cfg >> init.log 2>&1",

      #初始化WeCube主机
	  "./utils-sed.sh '{{MYSQL_RESOURCE_SERVER_IP}}' ${huaweicloud_rds_instance_v3.mysql_instance_plugin.private_ips.0} /root/scripts/wecube-platform/database/platform-core/02.wecube.system.data.sql",
      "./utils-sed.sh '{{S3_ACCESS_KEY}}' ${var.hw_access_key} /root/scripts/wecube-platform/wecube-platform.cfg",
	  "./utils-sed.sh '{{S3_SECRET_KEY}}' ${var.hw_secret_key} /root/scripts/wecube-platform/wecube-platform.cfg",
	  "./utils-sed.sh '{{S3_ENDPOINT}}' 'obs.'${var.hw_region}'.myhuaweicloud.com' /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{WECUBE_HOST}}' ${huaweicloud_ecs_instance_v1.instance_wecube_platform.nics.0.ip_address} /root/scripts/wecube-platform/wecube-platform.cfg",

      "./utils-sed.sh '{{PLUGIN_HOST_PASSWORD}}' ${var.default_password} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{STATIC_RESOURCE_SERVER_PASSWORD}}' ${var.default_password} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_ADDR}}' ${huaweicloud_rds_instance_v3.mysql_instance_wecube_core.private_ips.0} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_PORT}}' ${huaweicloud_rds_instance_v3.mysql_instance_wecube_core.db.0.port} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{MYSQL_PASSWORD}}' ${var.default_password} /root/scripts/wecube-platform/wecube-platform.cfg",
      "./utils-sed.sh '{{WECUBE_BUCKET}}' ${huaweicloud_s3_bucket.s3-wecube.bucket} /root/scripts/wecube-platform/wecube-platform.cfg",


	  "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.instance_wecube_platform.nics.0.ip_address} ${var.default_password} init-host.sh /root/",
      "cp -r /root/scripts/wecube-platform /root/scripts/wecube-platform-scripts",

      "./utils-scp.sh root ${huaweicloud_ecs_instance_v1.instance_wecube_platform.nics.0.ip_address} ${var.default_password} '-r /root/scripts/wecube-platform-scripts' /root/",

      "./init-wecube-platform-host.sh ${huaweicloud_ecs_instance_v1.instance_wecube_platform.nics.0.ip_address} ${var.default_password} ${var.wecube_version} >> init.log 2>&1",

      #初始化Squid主机
      "./install-squid.sh >> init.log 2>&1"
    ]

  }
}




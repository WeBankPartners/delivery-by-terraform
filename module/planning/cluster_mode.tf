# Retrieve Public IP
data "http" "my_public_ip" {
  url = "http://ipv4.icanhazip.com"
}

#####################
# Network Resources #
#####################
locals {
  my_public_ip = chomp(data.http.my_public_ip.body)

  vpc_cluster = {
    name       = "TX_GZ_PRD_MGMT"
    cidr_block = "10.40.192.0/19"
  }

  subnets_cluster = [
    local.subnet_vdi_cluster,
    local.subnet_proxy_cluster,
    local.subnet_app_1_cluster,
    local.subnet_app_2_cluster,
    local.subnet_db_cluster
  ]
  subnet_vdi_cluster = {
    name              = "TX_GZ_PRD_MGMT_VDI"
    cidr_block        = "10.40.196.0/24"
    availability_zone = local.primary_availability_zone
  }
  subnet_proxy_cluster = {
    name              = "TX_GZ_PRD_MGMT_PROXY"
    cidr_block        = "10.40.220.0/24"
    availability_zone = local.primary_availability_zone
  }
  subnet_app_1_cluster = {
    name              = "TX_GZ_PRD1_MGMT_APP"
    cidr_block        = "10.40.200.0/24"
    availability_zone = local.primary_availability_zone
  }
  subnet_app_2_cluster = {
    name              = "TX_GZ_PRD2_MGMT_APP"
    cidr_block        = "10.40.201.0/24"
    availability_zone = local.secondary_availability_zone
  }
  subnet_db_cluster = {
    name              = "TX_GZ_PRD1_MGMT_DB"
    cidr_block        = "10.40.212.0/24"
    availability_zone = local.primary_availability_zone
  }

  route_table_cluster = {
    name = "vpc_default_route_table"
  }

  security_group_cluster = {
    name        = local.vpc_cluster.name
    description = "Security Group for WeCube VPC"
  }
  security_group_rules_cluster = [
    {
      type              = "ingress"
      cidr_ip           = local.vpc_cluster.cidr_block
      ip_protocol       = "tcp"
      port_range        = "1-65535"
      policy            = "accept"
    },
    {
      type              = "egress"
      cidr_ip           = local.vpc_cluster.cidr_block
      ip_protocol       = "tcp"
      port_range        = "1-65535"
      policy            = "accept"
    },
    {
      type              = "ingress"
      cidr_ip           = "0.0.0.0/0"
      #cidr_ip           = local.my_public_ip
      ip_protocol       = "tcp"
      port_range        = "22,3389"
      policy            = "accept"
    },
    {
      type              = "egress"
      cidr_ip           = "0.0.0.0/0"
      ip_protocol       = "tcp"
      port_range        = "80,443"
      policy            = "accept"
    }
  ]
}

#######################
# Computing Resources #
#######################
locals {
  bastion_hosts_cluster = [
    local.bastion_host_cluster,
    local.vdi_host_cluster,
  ]

  waf_hosts_cluster = [
    local.waf_host_cluster,
  ]

  hosts_cluster = [
    local.core_host_1_cluster,
    local.core_host_2_cluster,
    local.plugin_host_1_cluster,
    local.plugin_host_2_cluster,
  ]

  db_instances_cluster = [
    local.core_db,
    local.plugin_db,
  ]

  lb_instances_cluster = [
    local.lb_internal_1_cluster,
    local.lb_internal_2_cluster,
  ]


  bastion_host_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_VDI1__mgmtbastion01"
    availability_zone          = local.primary_availability_zone
    subnet_name                = local.subnet_vdi_cluster.name
    instance_type              = "S2.SMALL1"
    image_id                   = "img-oikl1tzv"
    system_disk_type           = "CLOUD_PREMIUM"
    password                   = var.initial_password
    private_ip                 = "10.40.196.4"
    allocate_public_ip         = true
    internet_max_bandwidth_out = 10
  }
  vdi_host_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_VDI1__mgmtvdi01"
    availability_zone          = local.primary_availability_zone
    subnet_name                = local.subnet_vdi_cluster.name
    instance_type              = "S2.MEDIUM4"
    image_id                   = "img-9id7emv7"
    system_disk_type           = "CLOUD_PREMIUM"
    password                   = var.initial_password
    private_ip                 = "10.40.196.3"
    allocate_public_ip         = true
    internet_max_bandwidth_out = 10
  }

  waf_host_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_SQUID1__mgmtsquid01"
    availability_zone          = local.primary_availability_zone
    subnet_name                = local.subnet_proxy_cluster.name
    instance_type              = "S2.SMALL1"
    image_id                   = "img-oikl1tzv"
    system_disk_type           = "CLOUD_PREMIUM"
    password                   = var.initial_password
    private_ip                 = "10.40.220.3"
    allocate_public_ip         = true
    internet_max_bandwidth_out = 10
    provisioned_with           = ["squid", "open-monitor-agent"]
  }

  core_host_1_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_DOCKER1__wecubecore01"
    availability_zone          = local.primary_availability_zone
    subnet_name                = local.subnet_app_1_cluster.name
    instance_type              = "S2.MEDIUM4"
    image_id                   = "img-oikl1tzv"
    system_disk_type           = "CLOUD_PREMIUM"
    password                   = var.initial_password
    private_ip                 = "10.40.200.2"
    allocate_public_ip         = false
    internet_max_bandwidth_out = 10
    provisioned_with           = local.host_provisioners
  }
  core_host_2_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_DOCKER1__wecubecore02"
    availability_zone          = local.secondary_availability_zone
    subnet_name                = local.subnet_app_2_cluster.name
    instance_type              = "S2.MEDIUM4"
    image_id                   = "img-oikl1tzv"
    system_disk_type           = "CLOUD_PREMIUM"
    password                   = var.initial_password
    private_ip                 = "10.40.201.2"
    allocate_public_ip         = false
    internet_max_bandwidth_out = 10
    provisioned_with           = local.host_provisioners
  }
  plugin_host_1_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_DOCKER1__wecubeplugin01"
    availability_zone          = local.primary_availability_zone
    subnet_name                = local.subnet_app_1_cluster.name
    instance_type              = "S2.LARGE8"
    image_id                   = "img-oikl1tzv"
    system_disk_type           = "CLOUD_PREMIUM"
    password                   = var.initial_password
    private_ip                 = "10.40.200.3"
    allocate_public_ip         = false
    internet_max_bandwidth_out = 10
    provisioned_with           = local.host_provisioners
  }
  plugin_host_2_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_DOCKER1__wecubeplugin02"
    availability_zone          = local.secondary_availability_zone
    subnet_name                = local.subnet_app_2_cluster.name
    instance_type              = "S2.LARGE8"
    image_id                   = "img-oikl1tzv"
    system_disk_type           = "CLOUD_PREMIUM"
    password                   = var.initial_password
    private_ip                 = "10.40.201.3"
    allocate_public_ip         = false
    internet_max_bandwidth_out = 10
    provisioned_with           = local.host_provisioners
  }
  host_provisioners = [
    "proxy-settings",
    "docker",
    "proxy-settings-for-docker",
    "minio-docker",
    "open-monitor-agent",
  ]

  # DB Instances
  core_db = {
    name              = "TX_GZ_PRD_MGMT_1M1_MYSQL1__wecubecore"
    availability_zone = local.primary_availability_zone
    subnet_name       = local.subnet_db_cluster.name
    engine_version    = "5.6"
    mem_size          = 2000
    volume_size       = 40
    root_password     = var.initial_password
    intranet_port     = 3306
    internet_service  = 1
    slave_deploy_mode = 0
    slave_sync_mode   = 1
    first_slave_zone  = local.primary_availability_zone
    second_slave_zone = local.secondary_availability_zone
    parameters = {
      max_connections        = 1000
      lower_case_table_names = 1
      max_allowed_packet     = 4194304
      character_set_server   = "UTF8MB4"
    }
  }
  plugin_db = {
    name              = "TX_GZ_PRD_MGMT_1M1_MYSQL1__wecubeplugin"
    availability_zone = local.primary_availability_zone
    subnet_name       = local.subnet_db_cluster.name
    engine_version    = "5.6"
    mem_size          = 4000
    volume_size       = 50
    root_password     = var.initial_password
    intranet_port     = 3306
    internet_service  = 1
    slave_deploy_mode = 0
    slave_sync_mode   = 1
    first_slave_zone  = local.primary_availability_zone
    second_slave_zone = local.secondary_availability_zone
    parameters = {
      max_connections        = 1000
      lower_case_table_names = 1
      max_allowed_packet     = 4194304
      character_set_server   = "UTF8MB4"
    }
  }

  lb_internal_1_cluster = {
    name         = "TX_GZ_PRD_MGMT_1M1_ILB1__wecubelb01"
    subnet_name  = local.subnet_app_1_cluster.name
    network_type = "INTERNAL"
  }
  lb_internal_2_cluster = {
    name         = "TX_GZ_PRD_MGMT_1M1_ILB1__wecubelb02"
    subnet_name  = local.subnet_app_2_cluster.name
    network_type = "INTERNAL"
  }
}



###################
# Deployment Plan #
###################
locals {
  deployment_plan_cluster = {
    db = [
      {
        name                 = "core-db-cluster"
        installer            = "core-db"
        client_resource_name = local.core_host_1_cluster.name
        db_resource_name     = local.core_db.name
        db_name              = "wecube"
      },
      {
        name                 = "auth-server-db-cluster"
        installer            = "auth-server-db"
        client_resource_name = local.core_host_1_cluster.name
        db_resource_name     = local.core_db.name
        db_name              = "auth_server"
      },
      {
        name                 = "plugin-db-cluster"
        installer            = "plugin-db"
        client_resource_name = local.plugin_host_1_cluster.name
        db_resource_name     = local.plugin_db.name
        db_name              = "mysql"
      },
    ]

    app = [
      {
        name          = "wecube-platform-1-cluster"
        installer     = "wecube-platform"
        resource_name = local.core_host_1_cluster.name
        inject_private_ip = {
          STATIC_RESOURCE_HOSTS = "${local.core_host_1_cluster.name},${local.core_host_2_cluster.name}"
          S3_HOST               = local.core_host_1_cluster.name
        }
        inject_db_plan_env = {
          CORE_DB        = "core-db-cluster"
          AUTH_SERVER_DB = "auth-server-db-cluster"
          PLUGIN_DB      = "plugin-db-cluster"
        }
      },
      {
        name          = "wecube-platform-2-cluster"
        installer     = "wecube-platform"
        resource_name = local.core_host_2_cluster.name
        inject_private_ip = {
          STATIC_RESOURCE_HOSTS = "${local.core_host_1_cluster.name},${local.core_host_2_cluster.name}"
          S3_HOST               = local.core_host_1_cluster.name
        }
        inject_db_plan_env = {
          CORE_DB        = "core-db-cluster"
          AUTH_SERVER_DB = "auth-server-db-cluster"
          PLUGIN_DB      = "plugin-db-cluster"
        }
      },
      {
        name          = "wecube-plugin-hosting-1-cluster"
        installer     = "wecube-plugin-hosting"
        resource_name = local.plugin_host_1_cluster.name
        inject_private_ip = {}
        inject_db_plan_env = {
          CORE_DB = "core-db-cluster"
        }
      },
      {
        name          = "wecube-plugin-hosting-2-cluster"
        installer     = "wecube-plugin-hosting"
        resource_name = local.plugin_host_2_cluster.name
        inject_private_ip = {}
        inject_db_plan_env = {
          CORE_DB = "core-db-cluster"
        }
      },
    ]

    lb = [
      {
        name              = "http-19090-wecube-portal-1-cluster"
        resource_name     = local.lb_internal_1_cluster.name
        protocol          = "HTTP"
        port              = 19090
        path              = "/"
        health_check_path = "/platform/v1/health-check"
        back_ends         = [
          {
            resource_name = local.core_host_1_cluster.name
            port          = 19090
            weight        = 90
          },
          {
            resource_name = local.core_host_2_cluster.name
            port          = 19090
            weight        = 10
          },
        ]
      },
      {
        name              = "http-19090-wecube-portal-2-cluster"
        resource_name     = local.lb_internal_2_cluster.name
        protocol          = "HTTP"
        port              = 19090
        path              = "/"
        health_check_path = "/platform/v1/health-check"
        back_ends         = [
          {
            resource_name = local.core_host_1_cluster.name
            port          = 19090
            weight        = 10
          },
          {
            resource_name = local.core_host_2_cluster.name
            port          = 19090
            weight        = 90
          },
        ]
      },
      {
        name              = "http-19110-wecube-gateway-1-cluster"
        resource_name     = local.lb_internal_1_cluster.name
        protocol          = "HTTP"
        port              = 19110
        path              = "/"
        health_check_path = "/platform/v1/health-check"
        back_ends         = [
          {
            resource_name = local.core_host_1_cluster.name
            port          = 19110
            weight        = 90
          },
          {
            resource_name = local.core_host_2_cluster.name
            port          = 19110
            weight        = 10
          },
        ]
      },
      {
        name              = "http-19110-wecube-gateway-2-cluster"
        resource_name     = local.lb_internal_2_cluster.name
        protocol          = "HTTP"
        port              = 19110
        path              = "/"
        health_check_path = "/platform/v1/health-check"
        back_ends         = [
          {
            resource_name = local.core_host_1_cluster.name
            port          = 19110
            weight        = 10
          },
          {
            resource_name = local.core_host_2_cluster.name
            port          = 19110
            weight        = 90
          },
        ]
      },
    ]

    post_deploy = [
      {
        name          = "wecube-system-settings-cluster"
        installer     = "wecube-system-settings"
        resource_name = local.core_host_1_cluster.name
        inject_asset_id = {
          WECUBE_VPC            = local.vpc_cluster.name
          WECUBE_SUBNET         = local.subnet_app_1_cluster.name
          WECUBE_ROUTE_TABLE    = local.route_table_cluster.name
          WECUBE_SECURITY_GROUP = local.security_group_cluster.name
          WECUBE_HOST           = local.core_host_1_cluster.name
        }
        inject_private_ip = {
          CORE_HOST   = local.core_host_1_cluster.name
          S3_HOST     = local.core_host_1_cluster.name
          PLUGIN_HOST = local.plugin_host_1_cluster.name
          PORTAL_HOST = local.core_host_1_cluster.name
        }
        inject_db_plan_env = {
          CORE_DB        = "core-db-cluster"
          AUTH_SERVER_DB = "auth-server-db-cluster"
          PLUGIN_DB      = "plugin-db-cluster"
        }
      },
    ]
  }
}

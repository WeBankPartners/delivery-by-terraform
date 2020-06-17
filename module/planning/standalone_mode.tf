#####################
# Network Resources #
#####################
locals {
  # VPC
  vpc_standalone = {
    name       = "TX_BJ_PRD_MGMT"
    cidr_block = "10.128.200.0/22"
  }

  # Subnets
  subnet_standalone = {
    name       = "TX_BJ_PRD1_MGMT_APP"
    cidr_block = "10.128.202.0/24"
    availability_zone = local.primary_availability_zone
  }

  # Route Tables
  route_table_standalone = {
    name = "vpc_default_route_table"
  }

  # Security Group and Rules
  security_group_standalone = {
    name        = local.vpc_standalone.name
    description = "Security Group for WeCube VPC"
  }
  security_group_rules_standalone = [
    {
      type              = "ingress"
      cidr_ip           = local.vpc_standalone.cidr_block
      ip_protocol       = "tcp"
      port_range        = "1-65535"
      policy            = "accept"
    },
    {
      type              = "ingress"
      cidr_ip           = "0.0.0.0/0"
      ip_protocol       = "tcp"
      port_range        = "22,19090,9000"
      policy            = "accept"
    },
    {
      type              = "egress"
      cidr_ip           = "0.0.0.0/0"
      ip_protocol       = "tcp"
      port_range        = "1-65535"
      policy            = "accept"
    }
  ]
}

#######################
# Computing Resources #
#######################
locals {
  host_standalone = {
    name                       = "txbjwecubehost"
    availability_zone          = local.primary_availability_zone
    subnet_name                = local.subnet_standalone.name
    instance_type              = "S4.LARGE16"
    image_id                   = "img-oikl1tzv"
    system_disk_type           = "CLOUD_PREMIUM"
    password                   = var.initial_password
    private_ip                 = "10.128.202.3"
    allocate_public_ip         = true
    internet_max_bandwidth_out = 10

    provisioned_with = ["docker", "mysql-docker", "minio-docker", "open-monitor-agent"]
  }
}

###################
# Deployment Plan #
###################
locals {
  deployment_plan_standalone = {
    db = [
      {
        name                 = "core-db-standalone"
        installer            = "core-db"
        client_resource_name = local.host_standalone.name
        db_resource_name     = null
        db_host              = local.host_standalone.private_ip
        db_port              = var.default_mysql_port
        db_name              = "wecube"
        db_username          = "root"
        db_password          = var.initial_password
      },
      {
        name                 = "auth-server-db-standalone"
        installer            = "auth-server-db"
        client_resource_name = local.host_standalone.name
        db_resource_name     = null
        db_host              = local.host_standalone.private_ip
        db_port              = var.default_mysql_port
        db_name              = "auth_server"
        db_username          = "root"
        db_password          = var.initial_password
      },
      {
        name                 = "plugin-db-standalone"
        installer            = "plugin-db"
        client_resource_name = local.host_standalone.name
        db_resource_name     = null
        db_host              = local.host_standalone.private_ip
        db_port              = var.default_mysql_port
        db_name              = "mysql"
        db_username          = "root"
        db_password          = var.initial_password
      },
    ]

    app = [
      {
        name          = "wecube-platform-standalone"
        installer     = "wecube-platform"
        resource_name = local.host_standalone.name
        inject_private_ip = {
          STATIC_RESOURCE_HOSTS = local.host_standalone.name
          S3_HOST               = local.host_standalone.name
        }
        inject_db_plan_env = {
          CORE_DB        = "core-db-standalone"
          AUTH_SERVER_DB = "auth-server-db-standalone"
          PLUGIN_DB      = "plugin-db-standalone"
        }
      },
      {
        name          = "wecube-plugin-hosting-standalone"
        installer     = "wecube-plugin-hosting"
        resource_name = local.host_standalone.name
        inject_private_ip = {}
        inject_db_plan_env = {
          CORE_DB  = "core-db-standalone"
        }
      },
    ]

    lb = []

    post_deploy = [
      {
        name          = "wecube-system-settings-standalone"
        installer     = "wecube-system-settings"
        resource_name = local.host_standalone.name
        inject_asset_id = {
          WECUBE_VPC            = local.vpc_standalone.name
          WECUBE_SUBNET         = local.subnet_standalone.name
          WECUBE_ROUTE_TABLE    = local.route_table_standalone.name
          WECUBE_SECURITY_GROUP = local.security_group_standalone.name
          WECUBE_HOST           = local.host_standalone.name
        }
        inject_private_ip = {
          CORE_HOST   = local.host_standalone.name
          S3_HOST     = local.host_standalone.name
          PLUGIN_HOST = local.host_standalone.name
          PORTAL_HOST = local.host_standalone.name
        }
        inject_db_plan_env = {
          CORE_DB        = "core-db-standalone"
          AUTH_SERVER_DB = "auth-server-db-standalone"
          PLUGIN_DB      = "plugin-db-standalone"
        }
      },
    ]
  }
}

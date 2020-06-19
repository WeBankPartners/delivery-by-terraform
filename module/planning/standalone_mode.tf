#######################################
# 单机模式下的资源规划及WeCube部署计划定义 #
######################################

###########
# 网络资源 #
###########
locals {
  # 私有网络
  vpc_standalone = {
    # 私有网络名称
    name       = "TX_BJ_PRD_MGMT"
    # 私有网络CIDR IP地址空间块
    cidr_block = "10.128.200.0/22"
  }

  # 子网
  subnet_standalone = {
    # 子网名称
    name       = "TX_BJ_PRD1_MGMT_APP"
    # 子网的CIDR IP地址空间块
    cidr_block = "10.128.202.0/24"
    # 子网所在的可用区
    availability_zone = local.primary_availability_zone
  }

  # 私有网络默认路由表
  route_table_standalone = {
    # 路由表名称
    name = "vpc_default_route_table"
  }

  # 安全组
  security_group_standalone = {
    # 安全组名称
    name        = local.vpc_standalone.name
    # 安全组描述
    description = "Security Group for WeCube VPC"
  }

  # 安全规则
  security_group_rules_standalone = [
    {
      # 规则类型：入向 - ingress, 出向 - egress
      type              = "ingress"
      # 规则匹配的CIDR IP地址
      cidr_ip           = local.vpc_standalone.cidr_block
      # 规则应用的网络协议
      ip_protocol       = "tcp"
      # 规则匹配的端口范围
      port_range        = "1-65535"
      # 规则匹配后的动作策略
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

###########
# 计算资源 #
###########
locals {
  # 主机
  host_standalone = {
    # 主机实例名称
    name                       = "txbjwecubehost"
    # 主机所在的可用区名称
    availability_zone          = local.primary_availability_zone
    # 主机所在的私有网络中的子网名称
    subnet_name                = local.subnet_standalone.name
    # 主机规格类型
    instance_type              = "S4.LARGE16"
    # 主机初始化使用的虚拟机镜像名称
    image_id                   = "img-oikl1tzv"
    # 主机存储系统使用的磁盘类型
    system_disk_type           = "CLOUD_PREMIUM"
    # 主机root用户的初始密码
    password                   = var.initial_password
    # 主机使用的私有网络IP
    private_ip                 = "10.128.202.3"
    # 是否为主机分配公共网络IP
    allocate_public_ip         = true
    # 主机公共网络出向流量带宽
    internet_max_bandwidth_out = 10

    # 主机初始化时需要额外执行的安装程序名称（位于目录installer下）
    provisioned_with = ["docker", "mysql-docker", "minio-docker", "open-monitor-agent"]
  }
}

###########
# 部署计划 #
###########
locals {
  # 单机模式下的WeCube部署计划
  deployment_plan_standalone = {
    # 数据库组件部署计划
    db = [
      {
        # 数据库组件部署计划名称
        name                 = "core-db-standalone"
        # 部署数据库组件时需要执行的安装程序名称（位于目录installer下）
        installer            = "core-db"
        # 部署数据库组件时需要作为客户端使用的主机资源名称
        client_resource_name = local.host_standalone.name
        # 部署数据库组件的目标数据库资源名称（单机模式下没有单独创建的数据库资源，但需要指定后续的部署目标数据库的5项参数）
        db_resource_name     = null
        # 目标数据库实例所在的主机
        db_host              = local.host_standalone.private_ip
        # 目标数据库实例的监听端口
        db_port              = var.default_mysql_port
        # 目标数据库实例的数据库名称
        db_name              = "wecube"
        # 目标数据库实例的用户名
        db_username          = "root"
        # 目标数据库实例的用户密码
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

    # 应用组件部署计划
    app = [
      {
        # 应用组件部署计划名称
        name            = "wecube-platform-standalone"
        # 部署应用组件时需要执行的安装程序名称（位于installer目录下）
        installer       = "wecube-platform"
        # 应用组件部署的目标主机资源名称
        resource_name   = local.host_standalone.name
        # 在应用组件部署使用的环境变量配置文件中注入以下资源的私有网络IP地址
        inject_private_ip = {
          # 定义格式：变量名称 = 资源名称[,资源名称]...
          STATIC_RESOURCE_HOSTS = local.host_standalone.name
          S3_HOST               = local.host_standalone.name
        }
        # 在应用组件部署使用的环境变量配置文件中注入以下已完成部署的数据库组件环境参数（数据库实例所在主机、端口、数据库名称、用户名、密码）
        inject_db_plan_env = {
          # 定义格式：变量名称前缀 = 数据库组件部署计划名称
          CORE_DB        = "core-db-standalone"
          AUTH_SERVER_DB = "auth-server-db-standalone"
          PLUGIN_DB      = "plugin-db-standalone"
        }
      },
      {
        name            = "wecube-plugin-hosting-standalone"
        installer       = "wecube-plugin-hosting"
        resource_name   = local.host_standalone.name
        inject_private_ip = {}
        inject_db_plan_env = {
          CORE_DB  = "core-db-standalone"
        }
      },
    ]

    # 负载均衡组件部署计划（单机模式下并不需要）
    lb = []

    # 部署后需要执行的步骤
    post_deploy = [
      # 部署后执行步骤：WeCube系统参数配置
      {
        # 部署后执行步骤的名称
        name            = "wecube-system-settings-standalone"
        # 部署后执行步骤中需要执行的安装程序名称（位于目录installer下）
        installer       = "wecube-system-settings"
        # 执行部署后步骤时使用的主机资源名称
        resource_name   = local.host_standalone.name
        # 在部署后执行步骤使用的环境变量配置文件中注入以下变量和值
        inject_env = {
          REGION_ASSET_NAME = "TX_BJ_PRD"
          REGION            = var.region
          AZ_ASSET_NAME     = "TX_BJ_PRD1"
          AZ                = local.primary_availability_zone

          COS_SECRETID      = var.secret_id
          COS_SECRETKEY     = var.secret_key
          COS_REGION        = "ap-guangzhou"
          COS_BUCKET        = "wecube-artifacts-1259008868"
          S3_ACCESS_KEY     = "access_key"
          S3_SECRET_KEY     = "secret_key"
          S3_BUCKET_NAME    = "wecube-artifacts"
        }
        # 在部署后执行步骤使用的环境变量配置文件中注入以下资源的资产名称、资产ID和私有网络IP地址（如有）
        inject_asset_data = {
          # 定义格式：变量名称前缀 = 资源名称[,资源名称]...
          WECUBE_VPC            = local.vpc_standalone.name
          WECUBE_SUBNET         = local.subnet_standalone.name
          WECUBE_ROUTE_TABLE    = local.route_table_standalone.name
          WECUBE_SECURITY_GROUP = local.security_group_standalone.name
          WECUBE_HOST           = local.host_standalone.name
        }
        # 在部署后执行步骤使用的环境变量配置文件中注入以下资源的私有网络IP地址
        inject_private_ip = {
          # 定义格式：变量名称 = 资源名称[,资源名称]...
          CORE_HOST   = local.host_standalone.name
          S3_HOST     = local.host_standalone.name
          PLUGIN_HOST = local.host_standalone.name
          PORTAL_HOST = local.host_standalone.name
        }
        # 在部署后执行步骤使用的环境变量配置文件中注入以下已完成部署的数据库组件环境参数（数据库实例所在主机、端口、数据库名称、用户名、密码）
        inject_db_plan_env = {
          # 定义格式：变量名称前缀 = 数据库组件部署计划名称
          CORE_DB        = "core-db-standalone"
          AUTH_SERVER_DB = "auth-server-db-standalone"
          PLUGIN_DB      = "plugin-db-standalone"
        }
      }
    ]
  }
}

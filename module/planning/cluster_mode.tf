#######################################
# 集群模式下的资源规划及WeCube部署计划定义 #
######################################

# 获取当前主机的公共网络IP地址，以供安全策略定义使用
# data "http" "my_public_ip" {
#   url = "http://ipv4.icanhazip.com"
# }

###########
# 网络资源 #
###########
locals {
  # 当前主机的公共网络IP地址
  # my_public_ip = chomp(data.http.my_public_ip.body)

  # 私有网络
  vpc_cluster = {
    # 私有网络名称
    name       = "TX_GZ_PRD_MGMT"
    # 私有网络CIDR IP地址空间块
    cidr_block = "10.40.192.0/19"
  }

  # 子网
  subnets_cluster = [
    local.subnet_vdi_cluster,
    local.subnet_proxy_cluster,
    local.subnet_app_1_cluster,
    local.subnet_app_2_cluster,
    local.subnet_db_cluster
  ]
  subnet_vdi_cluster = {
    # 子网名称
    name              = "TX_GZ_PRD1_MGMT_VDI01"
    # 子网的CIDR IP地址空间块
    cidr_block        = "10.40.196.0/24"
    # 子网所在的可用区
    availability_zone = local.primary_availability_zone
  }
  subnet_proxy_cluster = {
    name              = "TX_GZ_PRD1_MGMT_PROXY01"
    cidr_block        = "10.40.220.0/24"
    availability_zone = local.primary_availability_zone
  }
  subnet_app_1_cluster = {
    name              = "TX_GZ_PRD1_MGMT_APP01"
    cidr_block        = "10.40.200.0/24"
    availability_zone = local.primary_availability_zone
  }
  subnet_app_2_cluster = {
    name              = "TX_GZ_PRD2_MGMT_APP01"
    cidr_block        = "10.40.201.0/24"
    availability_zone = local.secondary_availability_zone
  }
  subnet_db_cluster = {
    name              = "TX_GZ_PRD1_MGMT_DB01"
    cidr_block        = "10.40.212.0/24"
    availability_zone = local.primary_availability_zone
  }

  # 私有网络默认路由表
  route_table_cluster = {
    # 路由表名称
    name = "vpc_default_route_table"
  }

  # 安全组
  security_group_cluster = {
    # 安全组名称
    name        = local.vpc_cluster.name
    # 安全组描述
    description = "Security Group for WeCube VPC"
  }

  # 安全规则
  security_group_rules_cluster = [
    {
      # 规则类型：入向 - ingress, 出向 - egress
      type              = "ingress"
      # 规则匹配的CIDR IP地址
      cidr_ip           = local.vpc_cluster.cidr_block
      # 规则应用的网络协议
      ip_protocol       = "tcp"
      # 规则匹配的端口范围
      port_range        = "1-65535"
      # 规则匹配后的动作策略
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

###########
# 计算资源 #
###########
locals {
  # 跳板机
  bastion_hosts_cluster = [
    local.bastion_host_cluster,
    local.vdi_host_cluster,
  ]

  # 应用防火墙
  waf_hosts_cluster = [
    local.waf_host_cluster,
  ]

  # 主机
  hosts_cluster = [
    local.core_host_1_cluster,
    local.core_host_2_cluster,
    local.plugin_host_1_cluster,
    local.plugin_host_2_cluster,
  ]

  # 数据库
  db_instances_cluster = [
    local.core_db,
    local.plugin_db,
  ]

  # 负载均衡器
  lb_instances_cluster = [
    local.lb_internal_1_cluster,
    local.lb_internal_2_cluster,
  ]


  # 跳板机
  bastion_host_cluster = {
    # 主机实例名称
    name                       = "TX_GZ_PRD_MGMT_1M1_VDI1__mgmtbastion01"
    # 主机所在的可用区名称
    availability_zone          = local.primary_availability_zone
    # 主机所在的私有网络中的子网名称
    subnet_name                = local.subnet_vdi_cluster.name
    # 主机规格类型
    instance_type              = "S2.SMALL1"
    # 主机初始化使用的虚拟机镜像名称
    image_id                   = "img-oikl1tzv"
    # 主机存储系统使用的磁盘类型
    system_disk_type           = "CLOUD_PREMIUM"
    # 主机存储系统磁盘大小
    system_disk_size           = 50
    # 主机root用户的初始密码
    password                   = var.initial_password
    # 主机使用的私有网络IP
    private_ip                 = "10.40.196.4"
    # 是否为主机分配公共网络IP
    allocate_public_ip         = true
    # 主机公共网络出向流量带宽
    internet_max_bandwidth_out = 10
  }
  vdi_host_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_VDI1__mgmtvdi01"
    availability_zone          = local.primary_availability_zone
    subnet_name                = local.subnet_vdi_cluster.name
    instance_type              = "S2.MEDIUM4"
    image_id                   = "img-9id7emv7"
    system_disk_type           = "CLOUD_PREMIUM"
    system_disk_size           = 50
    password                   = var.initial_password
    private_ip                 = "10.40.196.3"
    allocate_public_ip         = true
    internet_max_bandwidth_out = 10
  }

  # 应用防火墙
  waf_host_cluster = {
    # 主机实例名称
    name                       = "TX_GZ_PRD_MGMT_1M1_SQUID1__mgmtsquid01"
    # 主机所在的可用区名称
    availability_zone          = local.primary_availability_zone
    # 主机所在的私有网络中的子网名称
    subnet_name                = local.subnet_proxy_cluster.name
    # 主机规格类型
    instance_type              = "S2.SMALL1"
    # 主机初始化使用的虚拟机镜像名称
    image_id                   = "img-oikl1tzv"
    # 主机存储系统使用的磁盘类型
    system_disk_type           = "CLOUD_PREMIUM"
    # 主机存储系统磁盘大小
    system_disk_size           = 50
    # 主机root用户的初始密码
    password                   = var.initial_password
    # 主机使用的私有网络IP
    private_ip                 = "10.40.220.3"
    # 是否为主机分配公共网络IP
    allocate_public_ip         = true
    # 主机公共网络出向流量带宽
    internet_max_bandwidth_out = 100
    # 主机初始化时需要额外执行的安装程序名称（位于目录installer下）
    provisioned_with           = ["yum-packages", "squid", "open-monitor-agent"]
  }

  # 主机
  core_host_1_cluster = {
    # 主机实例名称
    name                       = "TX_GZ_PRD_MGMT_1M1_DOCKER1__wecubecore01"
    # 主机所在的可用区名称
    availability_zone          = local.primary_availability_zone
    # 主机所在的私有网络中的子网名称
    subnet_name                = local.subnet_app_1_cluster.name
    # 主机规格类型
    instance_type              = "S2.MEDIUM4"
    # 主机初始化使用的虚拟机镜像名称
    image_id                   = "img-oikl1tzv"
    # 主机存储系统使用的磁盘类型
    system_disk_type           = "CLOUD_PREMIUM"
    # 主机存储系统磁盘大小
    system_disk_size           = 50
    # 主机root用户的初始密码
    password                   = var.initial_password
    # 主机使用的私有网络IP
    private_ip                 = "10.40.200.2"
    # 是否为主机分配公共网络IP
    allocate_public_ip         = false
    # 主机公共网络出向流量带宽
    internet_max_bandwidth_out = 100
    # 主机初始化时需要额外执行的安装程序名称（位于目录installer下）
    provisioned_with           = local.host_provisioners
  }
  core_host_2_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_DOCKER1__wecubecore02"
    availability_zone          = local.secondary_availability_zone
    subnet_name                = local.subnet_app_2_cluster.name
    instance_type              = "S2.MEDIUM4"
    image_id                   = "img-oikl1tzv"
    system_disk_type           = "CLOUD_PREMIUM"
    system_disk_size           = 50
    password                   = var.initial_password
    private_ip                 = "10.40.201.2"
    allocate_public_ip         = false
    internet_max_bandwidth_out = 100
    provisioned_with           = local.host_provisioners
  }
  plugin_host_1_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_DOCKER1__wecubeplugin01"
    availability_zone          = local.primary_availability_zone
    subnet_name                = local.subnet_app_1_cluster.name
    instance_type              = "S2.LARGE8"
    image_id                   = "img-oikl1tzv"
    system_disk_type           = "CLOUD_PREMIUM"
    system_disk_size           = 50
    password                   = var.initial_password
    private_ip                 = "10.40.200.3"
    allocate_public_ip         = false
    internet_max_bandwidth_out = 100
    provisioned_with           = local.host_provisioners
  }
  plugin_host_2_cluster = {
    name                       = "TX_GZ_PRD_MGMT_1M1_DOCKER1__wecubeplugin02"
    availability_zone          = local.secondary_availability_zone
    subnet_name                = local.subnet_app_2_cluster.name
    instance_type              = "S2.LARGE8"
    image_id                   = "img-oikl1tzv"
    system_disk_type           = "CLOUD_PREMIUM"
    system_disk_size           = 50
    password                   = var.initial_password
    private_ip                 = "10.40.201.3"
    allocate_public_ip         = false
    internet_max_bandwidth_out = 100
    provisioned_with           = local.host_provisioners
  }
  host_provisioners = [
    "proxy-settings",
    "yum-packages",
    "docker",
    "proxy-settings-for-docker",
    "minio-docker",
    "open-monitor-agent",
  ]

  # 数据库
  core_db = {
    # 数据库实例名称
    name              = "TX_GZ_PRD_MGMT_1M1_MYSQL1__wecubecore"
    # 数据库实例所在的可用区
    availability_zone = local.primary_availability_zone
    # 数据库实例所在的子网名称
    subnet_name       = local.subnet_db_cluster.name
    # 数据库实例的MySQL版本
    engine_version    = "5.6"
    # 数据库实例使用的内存大小（MB）
    mem_size          = 2000
    # 数据库实例使用的存储磁盘大小（GB）
    volume_size       = 40
    # 数据库实例root用户的初始密码
    root_password     = var.initial_password
    # 数据库实例的内网监听端口
    intranet_port     = var.default_mysql_port
    # 数据库实例是否允许通过公共网络访问
    internet_service  = 0
    # 数据复制模式：0 - 异步复制，1 - 半同步复制，2 - 强同步复制
    slave_sync_mode   = 1
    # 数据库从节点部署模式：0 - 单可用区，1 - 多可用区
    slave_deploy_mode = 0
    # 
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
    intranet_port     = var.default_mysql_port
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



###########
# 部署计划 #
###########
locals {
  # 集群模式下的WeCube部署计划
  deployment_plan_cluster = {
    # 数据库组件部署计划
    db = [
      {
        # 数据库组件部署计划名称
        name                 = "core-db-cluster"
        # 部署数据库组件时需要执行的安装程序名称（位于目录installer下）
        installer            = "db-connectivity"
        # 部署数据库组件时需要作为客户端使用的主机资源名称
        client_resource_name = local.core_host_1_cluster.name
        # 部署数据库组件的目标数据库资源名称
        db_resource_name     = local.core_db.name
        # 目标数据库实例的数据库名称
        db_name              = "wecube"
      },
      {
        name                 = "auth-server-db-cluster"
        installer            = "db-connectivity"
        client_resource_name = local.core_host_1_cluster.name
        db_resource_name     = local.core_db.name
        db_name              = "auth_server"
      },
      {
        name                 = "plugin-db-cluster"
        installer            = "db-connectivity"
        client_resource_name = local.plugin_host_1_cluster.name
        db_resource_name     = local.plugin_db.name
        db_name              = "mysql"
      },
    ]

    # 应用组件部署计划
    app = [
      {
        # 应用组件部署计划名称
        name            = "wecube-platform-1-cluster"
        # 部署应用组件时需要执行的安装程序名称（位于installer目录下）
        installer       = "wecube-platform"
        # 应用组件部署的目标主机资源名称
        resource_name   = local.core_host_1_cluster.name
        # 在应用组件部署使用的环境变量配置文件中注入以下资源的私有网络IP地址
        inject_private_ip = {
          # 定义格式：变量名称 = 资源名称[,资源名称...]
          STATIC_RESOURCE_HOSTS = "${local.core_host_1_cluster.name},${local.core_host_2_cluster.name}"
          S3_HOST               = local.core_host_1_cluster.name
        }
        # 在应用组件部署使用的环境变量配置文件中注入以下已完成部署的数据库组件环境参数（数据库实例所在主机、端口、数据库名称、用户名、密码）
        inject_db_plan_env = {
          # 定义格式：变量名称前缀 = 数据库组件部署计划名称
          CORE_DB        = "core-db-cluster"
          AUTH_SERVER_DB = "auth-server-db-cluster"
          PLUGIN_DB      = "plugin-db-cluster"
        }
      },
      {
        name            = "wecube-platform-2-cluster"
        installer       = "wecube-platform"
        resource_name   = local.core_host_2_cluster.name
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
        name            = "wecube-plugin-hosting-1-cluster"
        installer       = "wecube-plugin-hosting"
        resource_name   = local.plugin_host_1_cluster.name
        inject_private_ip = {
          CORE_HOST = local.core_host_1_cluster.name
        }
        inject_db_plan_env = {
          CORE_DB = "core-db-cluster"
        }
      },
      {
        name            = "wecube-plugin-hosting-2-cluster"
        installer       = "wecube-plugin-hosting"
        resource_name   = local.plugin_host_2_cluster.name
        inject_private_ip = {
          CORE_HOST = local.core_host_1_cluster.name
        }
        inject_db_plan_env = {
          CORE_DB = "core-db-cluster"
        }
      },
    ]

    # 负载均衡组件部署计划
    lb = [
      {
        # 负载均衡组件部署计划名称
        name              = "http-19090-wecube-portal-1-cluster"
        # 负载均衡器资源名称
        resource_name     = local.lb_internal_1_cluster.name
        # 负载均衡时使用的协议类型
        protocol          = "HTTP"
        # 负载均衡对外服务监听的端口
        port              = 19090
        # 负载均衡对外服务的访问路径
        path              = "/"
        # 健康检查的访问路径
        health_check_path = "/platform/v1/health-check"
        # 后端服务器实例定义
        back_ends         = [
          {
            # 后端服务器所在的主机资源名称
            resource_name = local.core_host_1_cluster.name
            # 后端服务器监听的端口
            port          = 19090
            # 加权轮训时后端服务器所占权重
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

    # 部署后需要执行的步骤：WeCube系统参数配置
    post_deploy = [
      {
        # 部署后执行步骤的名称
        name            = "wecube-system-settings-cluster"
        # 部署后执行步骤中需要执行的安装程序名称（位于目录installer下）
        installer       = "wecube-system-settings"
        # 执行部署后步骤时使用的主机资源名称
        resource_name   = local.core_host_1_cluster.name
        # 在部署后执行步骤使用的环境变量配置文件中注入以下变量和值
        inject_env = {
          REGION_ASSET_NAME        = "TX_GZ_PRD"
          REGION                   = var.region
          AZ_ASSET_NAME            = "TX_GZ_PRD1,TX_GZ_PRD2"
          AZ                       = "${local.primary_availability_zone},${local.secondary_availability_zone}"

          ARTIFACTS_COS_SECRETID   = var.secret_id
          ARTIFACTS_COS_SECRETKEY  = var.secret_key

          S3_ACCESS_KEY            = "access_key"
          S3_SECRET_KEY            = "secret_key"
          AGENT_S3_BUCKET_NAME     = "wecube-agent"
          ARTIFACTS_S3_BUCKET_NAME = "wecube-artifacts"
        }
        # 在部署后执行步骤使用的环境变量配置文件中注入以下资源的资产名称、资产ID和私有网络IP地址（如有）
        inject_asset_data = {
          # 定义格式：变量名称前缀 = 资源名称[,资源名称]...
          WECUBE_VPC            = "vpc/${local.vpc_cluster.name}"
          WECUBE_ROUTE_TABLE    = "rt/${local.route_table_cluster.name}"
          WECUBE_SECURITY_GROUP = "sg/${local.security_group_cluster.name}"
          WECUBE_SUBNET         = join(",", [for sn in local.subnets_cluster : "sn/${sn.name}"])
          WECUBE_HOST           = join(",", concat([
                                      for h in local.bastion_hosts_cluster : "vm/${h.name}"
                                    ], [
                                      for h in local.waf_hosts_cluster     : "vm/${h.name}"
                                    ], [
                                      for h in local.hosts_cluster         : "vm/${h.name}"
                                    ]
                                  ))
          WECUBE_DB             = join(",", [for db in local.db_instances_cluster : "db/${db.name}"])
          WECUBE_LB             = join(",", [for lb in local.lb_instances_cluster : "lb/${lb.name}"])
        }
        # 在部署后执行步骤使用的环境变量配置文件中注入以下资源的私有网络IP地址
        inject_private_ip = {
          # 定义格式：变量名称 = 资源名称[,资源名称]...
          CORE_HOST   = local.core_host_1_cluster.name
          S3_HOST     = local.core_host_1_cluster.name
          PLUGIN_HOST = local.plugin_host_1_cluster.name
          PORTAL_HOST = local.core_host_1_cluster.name
        }
        # 在部署后执行步骤使用的环境变量配置文件中注入以下已完成部署的数据库组件环境参数（数据库实例所在主机、端口、数据库名称、用户名、密码）
        inject_db_plan_env = {
          # 定义格式：变量名称前缀 = 数据库组件部署计划名称
          CORE_DB        = "core-db-cluster"
          AUTH_SERVER_DB = "auth-server-db-cluster"
          PLUGIN_DB      = "plugin-db-cluster"
        }
      },
    ]
  }
}

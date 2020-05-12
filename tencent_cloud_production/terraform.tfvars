# you can define your resource KEY_NAME as below
#vpc
vpc_name = "TC_HK_PRD_MGMT"
region_name = "PRD"
az_1_name = "PRD1"
az_2_name = "PRD2"

#subnet
subnet_vdi_name   = "TC_HK_PRD1_MGMT_VDI"
subnet_proxy_name = "TC_HK_PRD1_MGMT_PROXY"
subnet_app1_name  = "TC_HK_PRD1_MGMT_APP"
subnet_app2_name  = "TC_HK_PRD2_MGMT_APP"
subnet_db1_name   = "TC_HK_PRD1_MGMT_DB"
#rds
rds_core_name           = "TC_HK_PRD_MGMT_1M1_MYSQL1__wecubecore"
rds_plugin_name         = "TC_HK_PRD_MGMT_1M1_MYSQL1__wecubeplugin"
#ecs
ecs_plugin_host1_name = "TC_HK_PRD_MGMT_1M1_DOCKER1__wecubeplugin01"
ecs_plugin_host2_name = "TC_HK_PRD_MGMT_1M1_DOCKER1__wecubeplugin02"
ecs_wecube_host1_name = "TC_HK_PRD_MGMT_1M1_DOCKER1__wecubecore01"
ecs_wecube_host2_name = "TC_HK_PRD_MGMT_1M1_DOCKER1__wecubecore02"
ecs_squid_name        = "TC_HK_PRD_MGMT_1M1_SQUID1__mgmtsquid01"
ecs_vdi_name          = "TC_HK_PRD_MGMT_1M1_VDI1__mgmtvdi01"
#lb
lb1_name           = "TC_HK_PRD_MGMT_1M1_ILB1__wecubelb01"
lb2_name           = "TC_HK_PRD_MGMT_1M1_ILB1__wecubelb02"

#自动注册插件包信息，若不需要自动注册插件包，则以下参数无意义
#插件包所在地址前缀
WECUBE_PLUGIN_URL_PREFIX="https://wecube-plugins-1258470876.cos.ap-guangzhou.myqcloud.com/v2.3.0"
#各个插件包包名
PKG_WECMDB="wecube-plugins-wecmdb-v1.4.3.26.zip"
PKG_QCLOUD="wecube-plugins-qcloud-v1.8.4.zip"
PKG_SALTSTACK="wecube-plugins-saltstack-v1.8.4.zip"
PKG_NOTIFICATIONS="wecube-plugins-notifications-v0.1.0.zip"
PKG_MONITOR="wecube-monitor-v1.3.4.zip"
PKG_ARTIFACTS="wecube-plugins-artifacts-v0.2.0.zip"
PKG_SERVICE_MGMT="wecube-plugins-service-mgmt-v0.4.1.zip"
# you can define your resource name as below
#vpc
vpc_name = "PRD_MG"
#subnet
subnet_vdi_name   = "PRD1_MG_OVDI"
subnet_proxy_name = "PRD1_MG_PROXY"
subnet_lb1_name   = "PRD1_MG_LB"
subnet_lb2_name   = "PRD2_MG_LB"
subnet_app1_name  = "PRD1_MG_APP"
subnet_app2_name  = "PRD2_MG_APP"
subnet_db1_name   = "PRD1_MG_RDB"
subnet_db2_name   = "PRD2_MG_RDB"
#rds
rds_parametergroup_name = "wecube_db"
rds_core_name           = "PRD1_MG_RDB_wecubecore"
rds_plugin_name         = "PRD1_MG_RDB_wecubeplugin"
#s3/OBS
s3_bucket_name = "sg-s3-wecube" #Must be globally unique in HuaweiCloud
#ecs
ecs_plugin_host1_name = "PRD1_MG_APP_10.128.202.3_wecubeplugin"
ecs_plugin_host2_name = "PRD2_MG_APP_10.128.218.3_wecubeplugin"
ecs_wecube_host1_name = "PRD1_MG_APP_10.128.202.2_wecubecore"
ecs_wecube_host2_name = "PRD2_MG_APP_10.128.218.2_wecubecore"
ecs_squid_name        = "PRD1_MG_PROXY_wecubesquid"
ecs_vdi_name          = "PRD1_MG_OVDI_wecubevdi"
#lb
lb1_name           = "PRD1_MG_LB_1"
lb2_name           = "PRD2_MG_LB_2"

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


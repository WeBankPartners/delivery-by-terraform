#(Required) Specified your Huawei cloud tenant name
hw_tenant_name = "ap-southeast-3"

#(Required) Specified the region which wecube deployed
hw_region = "ap-southeast-3"

#(Required) This DNS is ref from https://support.huaweicloud.com/dns_faq/dns_faq_002.html by the region
hw_dns1 = "100.125.1.250"
hw_dns2 = "100.125.128.250"

#(Required) Specified master&slave availability zone for resource creation
hw_az_master = "ap-southeast-3b"
hw_az_slave  = "ap-southeast-3c"

#(Required) Specified password of ECS/RDS
#default_password = "Wecube@123456"

#(Required) Specified the WeCube install home folder
wecube_home_folder = "/data/wecube"

#(Required) Specified WeCube version
wecube_version = "20200424131349-c32549a"

#(Optional) Your Domain ID(Account ID)
#hw_domain_id = "hw_domain_id"

#(Optional) Your Project ID
#hw_project_id = "hw_project_id"

#自动注册插件包信息，若不需要自动注册插件包，则以下参数无意义
#插件包所在地址前缀
WECUBE_PLUGIN_URL_PREFIX = "https://wecube-1259801214.cos.ap-guangzhou.myqcloud.com/v2.3.1"
#各个插件包包名
PKG_WECMDB        = "wecube-plugins-wecmdb-v1.4.4.zip"
PKG_HUAWEICLOUD   = "wecube-plugins-huaweicloud-v1.2.0.zip"
PKG_SALTSTACK     = "wecube-plugins-saltstack-v1.8.5.zip"
PKG_NOTIFICATIONS = "wecube-plugins-notifications-v0.1.0.zip"
PKG_MONITOR       = "wecube-plugins-monitor-v1.3.5.zip"
PKG_ARTIFACTS     = "wecube-plugins-artifacts-v0.2.5.zip"
PKG_SERVICE_MGMT  = "wecube-plugins-service-mgmt-v0.4.1.zip"


####################################################################


#(Optional) Define your resource name as below
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


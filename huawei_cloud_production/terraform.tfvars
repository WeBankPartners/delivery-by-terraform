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
lb1_listener1_name = "http_listener_portal1"
lb1_listener2_name = "http_listener_gateway1"
lb1_listener3_name = "http_listener_core1"
lb1_listener4_name = "http_listener_auth1"
lb2_name           = "PRD2_MG_LB_2"
lb2_listener1_name = "http_listener_portal2"
lb2_listener2_name = "http_listener_gateway2"
lb2_listener3_name = "http_listener_core2"
lb2_listener4_name = "http_listener_auth2"


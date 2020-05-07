#Your Access Key
# hw_access_key = "hw_access_key"

#Your Secret Key
# hw_secret_key = "hw_secret_key"

#Your Domain ID(Account ID)
hw_domain_id = "hw_domain_id"

#Your Project ID
hw_project_id = "hw_project_id"

#Specified the region which wecube deployed
hw_region = "ap-southeast-3"

#This DNS is ref from https://support.huaweicloud.com/dns_faq/dns_faq_002.html by the region
hw_dns1 = "100.125.1.250"
hw_dns2 = "100.125.128.250"

#Specified master availability zone for resource creation
hw_az_master = "ap-southeast-3b"
hw_az_slave  = "ap-southeast-3c"

#Specified tenant name
hw_tenant_name = "ap-southeast-3"

#Specified password of ECS/RDS
default_password = "Wecube@123456"

#Specified WeCube version
wecube_version = "20200424131349-c32549a"

#Specified the WeCube install home folder
wecube_home_folder = "/data/wecube"

#If "Y", it will auto launch plugins
is_install_plugins = "Y"

#please input your ip which run 'terraform apply'
current_ip = "0.0.0.0/0"


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


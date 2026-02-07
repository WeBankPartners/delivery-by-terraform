WeCube安装
双实例部署硬件资源说明
资源	数量	配置	用途
平台主机	2	4C8G300G	容器部署CORE、AUTHSERVER、GATEWAY、PORTAL四个子系统，部署完平台后把主机录进资源管理，给除monitor之外的插件运行使用
插件主机	2	4C8G300G	给monitor插件运行的主机
存储主机	2	2C4G50G*2 + 500GB共享磁盘CFS	部署minio与nexus存储服务，两者的数据目录通过容器映射出来并挂到共享磁盘上，minio双实例负载均衡，nexus单实例做冷备
平台mysql	1	2C4G10G硬盘	数据库wecube、auth_server
插件mysql	1	2C4G10G硬盘	数据库wecmdb_pro、monitor、artifacts、taskman、terminal、adaptor、itsdangerous
负载均衡	1	 	WECUBE-GATEWAY负载均衡
负载均衡	1	 	WECUBE-PORTAL负载均衡
负载均衡	1	 	minio负载均衡
负载均衡	1	 	nexus负载均衡
双实例部署软件资源说明，程序是容器docker方式运行，请先准备好容器环境，装好docker与docker-compose，并依赖如下几个系统命令：ssh、scp、tar、unzip、netstat
docker version docker-compose version 
软件资源说明(新加坡S3源)
●- 基础依赖docker/docker-compose
https://wecube-package.s3.ap-southeast-1.amazonaws.com/docker/docker-24.09.tar.gz 
https://wecube-package.s3.ap-southeast-1.amazonaws.com/docker/docker-compose-Linux-x86_64_2_31_0 
●- 存储服务minio/nexus
https://wecube-package.s3.ap-southeast-1.amazonaws.com/storage/minio.tar 
https://wecube-package.s3.ap-southeast-1.amazonaws.com/storage/nexus_3_84_0.tar.gz 
●- 平台镜像
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/platform.zip https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/wecube_v4.5.7_config.tar.gz 
●- 平台yaml配置
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/wecube_v4.5.7_config.tar.gz 
●- 平台数据库
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/mysql.tar 
●- 插件
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/wecube-plugins-wecmdb-v2.4.2.zip 
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/wecube-plugins-saltstack-v1.16.1.zip 
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/wecube-plugins-monitor-v3.7.3.zip 
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/wecube-plugins-artifacts-v1.5.3.zip 
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/wecube-plugins-adaptor-v1.1.2.zip 
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/wecube-plugins-itsdangerous-v0.2.5.zip 
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/wecube-plugins-terminal-v1.1.1.zip 
https://wecube-package.s3.ap-southeast-1.amazonaws.com/v4.5.7/wecube-plugins-taskman-v1.5.0.zip 
 
2、部署步骤
 把如下物料包传到两台平台主机和两台存储主机存储主机放下面三个
wecube_v4.5.7_config.tar.gz
minio.tar
nexus_3_84_0.tar.gz
#平台主机放下面两个
wecube_v4.5.7_config.tar.gz
wecube_v4.5.7_image.tar.gz

 存储主机(共享磁盘挂载到目录/data/share，两台机共用)
nexus_3_84_0.tar.gz
wecube_v4.5.7_config.tar.gz
minio.tar
#把上述三个包传到/data/wecube下，然后解压wecube_v4.5.7_config.tar.gz和nexus_3_84_0.tar.gz
 cd /data/wecube
 tar zxf nexus_3_84_0.tar.gz
 tar zxf wecube_v4.5.7_config.tar.gz
#加载镜像
 docker load --input nexus_3_84_0.tar
 docker load --input minio.tar
#创建部署路径和授权日志目录
mkdir -p /data/app/minio
 mkdir -p /data/share/wecube-minio
 mkdir -p /data/app/nexus
 mkdir -p /data/share/nexus-data
 chmod 777 /data/share/nexus-data
 cd …/wecube_v4.5.7_config/yml
 cp nexus.yml /data/app/nexus/
 cp wecube-minio.yml /data/app/minio
#拉起minio进程
cd /data/app/minio
 docker-compose -f wecube-minio.yml up -d
#需要新建minio数据目录
mkdir -p /data/share/wecube-minio/data/wecube-plugin-package-bucket
mkdir -p /data/share/wecube-minio/data/salt-tmp
mkdir -p /data/share/wecube-minio/data/taskman-file
mkdir -p /data/share/wecube-minio/data/terminal
mkdir -p /data/share/wecube-minio/data/wecube-agent
mkdir -p /data/share/wecube-minio/data/wecube-artifacts
#拉起nexus进程，注意nexus只启一台
cd /data/app/nexus
 docker-compose -f wecube-minio.yml up -d
#访问该主机8081端口初始化nexus
#在nexus里建一个row(hosted)类型的repo，命名成artifacts，然后创建个artifacts用户授权读写该repo，密码最好也叫artifacts

负载均衡
#minio负载均衡 转发到两台存储主机的9000端口
#nexus负载均衡 转发到两台存储主机的8081端口

数据库初始化
#数据库sql文件在/data/wecube/wecube_v4.5.7_config/sql下
cd /data/wecube/wecube_v4.5.7_config/sql
#把auth_server_v4.5.7_db.sql导进平台mysql的auth_server数据库中，把下面的连接信息修改下
mysql -h127.0.0.1 -uroot -P3306 -p -D auth_server < auth_server_v4.5.7_db.sql
#把wecube_v4.5.7_db.sql导进平台mysql的wecube数据库中，把下面的连接信息修改下
mysql -h127.0.0.1 -uroot -P3306 -p -D wecube < wecube_v4.5.7_db.sql

平台主机(两台机分别做，替换变量时主机ip不一样)：
wecube_v4.5.7_image.tar.gz
wecube_v4.5.7_config.tar.gz
#把上述两个包传到/data/wecube下然后解压
 cd /data/wecube
 tar zxf wecube_v4.5.7_image.tar.gz
 tar zxf wecube_v4.5.7_config.tar.gz
 cd wecube_v4.5.7_image
#加载镜像
 docker load --input platform-auth-server_v4.5.7.tar
 docker load --input platform-core_v4.5.7.tar
 docker load --input platform-gateway_v4.5.7.tar
 docker load --input wecube-portal_v4.5.7.tar
cd …/wecube_v4.5.7_config/yml
#配置主机环境变量文件 evn_variable
#配置好后执行下面命令替换变量
 ./replace_env.sh
#创建部署路径和授权日志目录
mkdir -p /data/app/platform/platform-auth-server/logs
mkdir -p /data/app/platform/platform-core/logs
mkdir -p /data/app/platform/platform-gateway/logs
mkdir -p /data/app/platform/wecube-portal/log
chmod 777 /data/app/platform/platform-auth-server/logs /data/app/platform/platform-core/logs /data/app/platform/platform-gateway/logs /data/app/platform/wecube-portal/log
mkdir -p /data/app/plugin-image
#把docker-compose文件放进目录中
cp wecube-auth-server.yml /data/app/platform/platform-auth-server/
cp wecube-platform-core.yml /data/app/platform/platform-core/
cp wecube-platform-gateway.yml /data/app/platform/platform-gateway/
cp wecube-portal.yml /data/app/platform/wecube-portal/
#如果有秘钥文件的话放到该目录下
mkdir -p /data/app/platform/platform-auth-server/certs
mkdir -p /data/app/platform/platform-core/certs
#插件前端静态文件目录，需要授权给上面配置的 host_wecube_username 用户读写
mkdir -p /data/app/platform/wecube-portal/data/ui-resources
chmod 777 /data/app/platform/wecube-portal/data/ui-resources
#拉起平台容器进程
cd /data/app/platform/platform-auth-server/
docker-compose -f wecube-auth-server.yml up -d
cd /data/app/platform/platform-core/
docker-compose -f wecube-platform-core.yml up -d
cd /data/app/platform/platform-gateway/
docker-compose -f wecube-platform-gateway.yml up -d
cd /data/app/platform/wecube-portal/
docker-compose -f wecube-portal.yml up -d
#访问该主机的8080端口验证wecube功能

负载均衡
#WECUBE-GATEWAY负载均衡 转发到两台平台主机的8005端口
#WECUBE-PORTAL负载均衡 转发到两台存储主机的8080端口

3.配置wecube
一、页面：系统-系统参数(先用名称搜索，如果没有就新建，有就更新默认值)
名称	value
GATEWAY_URL	http://{{lb_gateway_ip}}:{{lb_gateway_port}} 
S3_SERVER_URL	http://{{s3_host}}:{{s3_port}} 
S3_ACCESS_KEY	取存储主机上wecube-minio.yml配置的MINIO_ACCESS_KEY值
S3_SECRET_KEY	取存储主机上wecube-minio.yml配置的MINIO_SECRET_KEY值

二、页面：系统-资源管理

    
1.照上图添加s3资源，类型选s3，填写连接的ip与端口，如果s3前面有负载均衡，请填写负载均衡的ip端口，认证的key：
2.照上图添加添加docker类型资源，填平台主机1、平台主机2、插件主机1、插件主机2的ip与ssh端口，和ssh用户密码(需要该ssh用户有运行docker容器权限，并要求主机上面有目录/data/app/plugin-image，ssh用户有读写该目录权限)
3.照上图添加mysql类型资源，填插件mysql的数据库连接信息。如果插件数据库的连接用户已自行创建好，并且每个插件的连接用户名密码不一样，那在这里需要录入多条mysql类型资源，名称可以按插件名来区分，分别录入每个插件连接的用户名和密码。如果插件数据库的database已自行创建好，那么需要在资源实例那里录入已建好database的插件实例，其中名称必须要和插件名一致，比如monitor、artifacts、taskman、terminal、adaptor、itsdangerous，其中wecmdb的名称需要使用wecmdb_pro，如下图。
 
 
三、页面：协同-插件注册
去插件注册页面挨个注册插件，部分插件有依赖顺序，建议按该顺序注册插件wecmdb、saltstack、artifacts、monitor、taskman、terminal、adaptor、itsdangerous
插件注册页面有注册指引，按指引完成注册步骤。
 
四、(如果非一键迁移)插件服务配置注册与cmdb模型初始化
下载模型交付压缩包，比如 coe_a_20250219.zip，里面会有三类文件，以后缀来认分别是 sql后缀的是 wecmdb的模型初始化sql，需要导入进插件数据库wecmdb_pro里。后缀是xml的是插件服务配置文件，需要在协同-插件注册里，点如下的上传按钮上传给对应的插件

比如wecmdb-v2.2.0-xxxx.xml导入给wecmdb插件、saltstack-v1.12.0-xxxx.xml导入给saltstack插件。
后缀是json的文件是编排设计文件，需要在协同-编排设计 里挨个导入。
 
五、(如果非一键迁移)物料插件系统参数配置
artifacts插件要配置好nexus的地址，主要注意如下几个系统参数配置
系统参数	值	说明
USE_REMOTE_NEXUS_ONLY	true	是否使用远程nexus
LOCAL_NEXUS_SERVER_URL	{{远程nexus连接地址}}	格式http://172.21.10.202:8081 
LOCAL_NEXUS_USERNAME	{{远程nexus连接用户名}}	 
LOCAL_NEXUS_PASSWORD	{{远程nexus连接密码}}	 
LOCAL_NEXUS_REPOSITORY	{{远程nexus仓库}}	 
NEXUS_SERVER_URL	{{远程nexus连接地址}}	格式http://172.21.10.202:8081 
NEXUS_USERNAME	{{远程nexus连接用户名}}	 
NEXUS_PASSWORD	{{远程nexus连接密码}}	 
NEXUS_REPOSITORY	{{远程nexus仓库}}	 
ARTIFACTS_CITYPE_SYSTEM_DESIGN	system_design	 
HOST_EXPORTER_S3_PATH	http://{{s3_host}}:{{s3_port}}/wecube-agent/node_exporter.tar.gz 	 
配置好系统参数后，要重启artifacts插件才生效。


| agent_manager                |
| alarm                        |
| alarm_condition              |
| alarm_condition_rel          |
| alarm_custom                 |
| alarm_firing                 |
| alarm_notify                 |
| alarm_strategy               |
| alarm_strategy_metric        |
| alarm_strategy_tag           |
| alarm_strategy_tag_value     |
| alert_window                 |
| alive_check_queue            |
| business_monitor             |
| business_monitor_cfg         |
| button                       |
| chart                        |
| cluster                      |
| cluster_new                  |
| custom_chart                 |
| custom_chart_permission      |
| custom_chart_series          |
| custom_chart_series_config   |
| custom_chart_series_tag      |
| custom_chart_series_tagvalue |
| custom_dashboard             |
| custom_dashboard_chart_rel   |
| custom_dashboard_role_rel    |
| dashboard                    |
| db_keyword_alarm             |
| db_keyword_endpoint_rel      |
| db_keyword_monitor           |
| db_keyword_notify_rel        |
| db_metric_endpoint_rel       |
| db_metric_monitor            |
| db_monitor                   |
| endpoint                     |
| endpoint_group               |
| endpoint_group_rel           |
| endpoint_http                |
| endpoint_metric              |
| endpoint_new                 |
| endpoint_service_rel         |
| endpoint_telnet              |
| grp                          |
| grp_endpoint                 |
| history_alarm_custom         |
| kubernetes_cluster           |
| kubernetes_endpoint_rel      |
| log_keyword_alarm            |
| log_keyword_config           |
| log_keyword_endpoint_rel     |
| log_keyword_monitor          |
| log_keyword_notify_rel       |
| log_metric_config            |
| log_metric_endpoint_rel      |
| log_metric_group             |
| log_metric_json              |
| log_metric_monitor           |
| log_metric_param             |
| log_metric_string_map        |
| log_metric_template          |
| log_monitor                  |
| log_monitor_template         |
| log_monitor_template_role    |
| log_param_template           |
| main_dashboard               |
| maintain                     |
| metric                       |
| metric_comparison            |
| monitor_type                 |
| notify                       |
| notify_role_rel              |
| option                       |
| panel                        |
| panel_recursive              |
| process_monitor              |
| prom_metric                  |
| rel_role_grp                 |
| rel_role_user                |
| remote_write_config          |
| role                         |
| role_new                     |
| search                       |
| service_group                |
| service_group_role_rel       |
| snmp_endpoint_rel            |
| snmp_exporter                |
| strategy                     |
| sys_parameter                |
| tpl                          |
| user                         |
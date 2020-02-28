中文 / [English](README_EN.md)

# 公有云软件系统一键交付 (Delivery By Terraform)
使用Terraform一键交付公有云软件系统

## 使用方法:
### 1. 下载 Terraform
官方下载地址:
[https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)
>根据操作系统类型下载
e.g.  
Windows 64: [https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_windows_amd64.zip](https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_windows_amd64.zip)  
Linux 64: [https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip](https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip)

### 2. 配置 Terraform (以Windows为例)
#### 2.1 下载后解压至任一目录（如d:\terraform)
![terraform location](docs/images/terraform_location.png) 
#### 2.2 配置Path，可在任何目录执行terraform
![terraform env path](docs/images/terraform_env_path.png)

### 3. 下载本仓库
```
$cd d:\dev
$git clone https://github.com/WeBankPartners/delivery-by-terraform.git
```

### 4. 运行Terraform部署WeCube
为方便用户体验，我们提供了单机版和生产版两种部署方案。

### 5. 单机版
单机版目前提供了阿里云和腾讯云两个云服务商的版本。
顾名思义，单机版只需要一台云服务器即可部署WeCube。

部署之前，可以修改下面terraform变量值，否则会使用默认值；

变量名 | 默认值 |  描述  
-|-|-
instance_root_password | WeCube1qazXSW@ | 云主机的root密码 |
mysql_root_password | WeCube1qazXSW@ | mysql数据库的root密码 |
wecube_version | v2.1.1 | wecube的版本 |

也可以通过修改环境变量的方式来设置terraform变量
WeCube主机的密码至环境变量（不改默认为WeCube1qazXSW@）：  
![terraform app password](docs/images/instance_root_password.png) 

配置mysql的root密码（不改默认为WeCube1qazXSW@）：  
![terraform app password](docs/images/mysql_root_password.png) 

配置wecube的version，即镜像tag（不改默认为v2.1.1）：  
![terraform app password](docs/images/wecube_version.png) 

#### 5.1 部署阿里云
##### 5.1.1 配置Access Key/Secret Key至本地环境变量（默认使用region为cn-hangzhou） 
![terraform ali cloud key](docs/images/terraform_ali_cloud_key.png)
>注意: Access Key/Secret Key是敏感信息，建议配置到本地环境变量，不要配置在Terraform的模板文件*.tf里

>注意: 若配置的region不为"cn-hangzhou"，则需要相应的修改delivery-by-terraform\delivery-wecube-for-stand-alone\to_ali_cloud\aliyun_wecube.standalone.tf中出现的所有"availability_zone"的值。例如region配置为"cn-shenzhen",availability_zone则需要修改为"cn-shenzhen-a"或者深圳地域下的其他可用区。

##### 5.1.2 初始化Terraform
```
$cd d:\dev\delivery-by-terraform\delivery-wecube-for-stand-alone\to_ali_cloud
$terraform init    -- 安装阿里云的插件, 需要点时间，因国内网速较慢
```
##### 5.1.3 执行部署(一键部署)
```
$cd d:\dev\delivery-by-terraform\delivery-wecube-for-stand-alone\to_ali_cloud
$terraform apply   -- 执行部署
$.....
$Enter a value: yes  -- 确认执行
$.....
```
![terraform apply ](docs/images/terraform_ali_cloud_apply.png)
>如果你看到这个，说明已部署成功，拷贝输出的URL至浏览器即可访问Wecube
![wecube ](docs/images/wecube.png)


#### 5.1.4 销毁部署 (一键销毁)
```
$cd d:\dev\delivery-by-terraform\delivery-wecube-for-stand-alone\to_ali_cloud
$terraform destroy   -- 销毁部署
$.....
$Enter a value: yes  -- 确认执行
$.....
```
![terraform deploy   ](docs/images/terraform_ali_cloud_destroy.png)

#### 5.2 部署腾讯云
##### 5.2.1 配置Access Key/Secret Key至本地环境变量 
![terraform tencent cloud key](docs/images/terraform_tencent_cloud_key.png)
>注意: Access Key/Secret Key是敏感信息，建议配置到本地环境变量，不要配置在Terraform的模板文件*.tf里  
>注意: 若配置的region不为"ap-guangzhou"，则需要相应的修改delivery-by-terraform\delivery-wecube-for-stand-alone\to_tencent_cloud\tencent_wecube.tf中出现的所有"availability_zone"的值。例如region配置为"ap-chengdu",availability_zone则需要修改为"ap-chengdu-1"或成都地域下的其他可用区。

##### 5.2.2 初始化Terraform
```
$cd d:\dev\delivery-by-terraform\delivery-wecube-for-stand-alone\to_tencent_cloud
$terraform init    -- 安装腾讯云的插件, 需要点时间，因国内网速较慢
```

##### 剩余的步骤跟上面的阿里云部署的步骤5.1.3， 5.1.4类似。


### 6. 生产版
生产版是使用云服务提供的持久化存储，可满足一般的生产需求。
目前提供了腾讯云的版本。  

此版本规划如下：  
1.所有资源都部署在一个vpc中  
2.在vpc中划分三个子网  
    - 10.128.195.0/24 subnet_vdi
    - 10.128.194.0/25 subnet_app
    - 10.128.194.128/26 subnet_db
3.每个子网建立一个安全组  
sg_group_wecube_db  

入站/出站 |  规则协议 | 端口 |  来源  |  策略     
-|-|-|-|-  
入站|TCP|3306|0.0.0.0/0|允许  
入站|TCP|3307|0.0.0.0/0|允许  
入站|TCP|9001|0.0.0.0/0|允许  
入站|TCP|22|0.0.0.0/0|允许  
出站|TCP|1-65535|0.0.0.0/0|允许  

sg_group_wecube_app  

入站/出站 |  规则协议 | 端口 |  来源  |  策略    
-|-|-|-|-
入站|TCP|2375|0.0.0.0/0|允许
入站|TCP|22|0.0.0.0/0|允许
入站|TCP|19090|0.0.0.0/0|允许
入站|TCP|3128|10.128.194.0/25|允许
入站|TCP|3128|10.128.194.128/26|允许
出站|TCP|1-65535|0.0.0.0/0|允许

sg_group_wecube_vdi  

入站/出站 |  规则协议 | 端口 |  来源  |  策略    
-|-|-|-|-
入站|TCP|3389|0.0.0.0/0|允许
出站|TCP|1-65535|0.0.0.0/0|允许  
 
4.云数据库MySQL：  

实例名 | 默认规格 |  所属子网 |  绑定安全组 |  部署组件      
-|-|-|-|-
WecubeDbInstance | 1核2000M，200G | subnet_db  |  sg_group_wecube_db |  WeCube数据库  |
PluginDbInstance | 1核2000M，200G | subnet_db  |  sg_group_wecube_db |  插件数据库  |

5.对象存储COS
申请COS存储桶（名字为terraform变量名cos_name所配置的值）作为WeCube的S3存储。

5.主机部署规划如下：  

云主机内网IP | 默认规格 |  所属子网 |  绑定安全组 |  部署组件      
-|-|-|-|-  
10.128.194.130 | 2C4G | subnet_db  |  sg_group_wecube_db |  插件资源（S3对象存储）  |  
10.128.194.4 | 4C8G | subnet_app  |  sg_group_wecube_app |  插件容器  |  
10.128.194.3 | 4C8G | subnet_app  |  sg_group_wecube_app |  WeCube（含platform-core、platform-gateway、wecube-portal、auth-server）  |  
10.128.194.2 | 2C4G | subnet_app  |  sg_group_wecube_app |  Squid  |  
10.128.195.2 | 2C4G | subnet_vdi  |  sg_group_wecube_vdi |  Windows VDI主机 |  

部署之前，可以修改下面terraform变量值，否则会使用默认值；

变量名 | 默认值 |  描述  
-|-|-
default_password | Wecube@123456 | 云主机的root密码 |
wecube_version | v2.1.1 | wecube的版本 |
deploy_availability_zone | ap-guangzhou-4 | mysql数据库的root密码 |
plugin_resource_s3_access_key | s3_access | mysql数据库的root密码 |
plugin_resource_s3_secret_key | s3_secret | mysql数据库的root密码 |
cos_name | wecube-bucket-1234567890 | '1234567890' 必须替换成自己的[APPID](url:https://console.cloud.tencent.com/capi) |

#### 6.1 配置Access Key/Secret Key
参考5.2.1 配置Access Key/Secret Key至本地环境变量，不配置的话也可以在执行terraform apply命令的时候输入。

#### 6.2 初始化Terraform
参考5.2.2 初始化Terraform。
 
#### 6.3 执行部署(一键部署)
```
$cd d:\dev\delivery-by-terraform\delivery-wecube-for-production\to_tencent_cloud
$terraform apply   -- 执行部署
$.....
$Enter a value: yes  -- 确认执行
$.....
```
![terraform apply ](docs/images/terraform_tencent_cloud_apply_production.png)
>根据上图步骤，如果你看到这个，说明已部署成功
![wecube ](docs/images/wecube.png)


#### 6.4 销毁部署 (一键销毁)
参考5.1.4 销毁部署。

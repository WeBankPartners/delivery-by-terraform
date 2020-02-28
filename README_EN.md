English / [中文](README.md)

# Delivery By Terraform
Delivery your application public cloud by using terraform

## Usage:
### 1. Download Terraform
Official Download Address:
[https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)
>Download the version according to your OS type
e.g. 
Windows 64: [https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_windows_amd64.zip](https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_windows_amd64.zip)
Linux 64: [https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip](https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip)

### 2. Config Terraform (Windows as example)
#### 2.1 Unzip to d:\terraform
![terraform location](docs/images/terraform_location.png) 
#### 2.2 Config Path
![terraform env path](docs/images/terraform_env_path.png)

### 3. Download Source Code
```
$cd d:\dev
$git clone https://github.com/jordanzhangsz/delivery-by-terraform.git
```

### 4. Deploy WeCube
For users' convenience, we provide two deployment version: stand-alone and production.

### 5. Stand-alone
#### 5.1 Steps for delivering Wecube to AliCloud
##### 5.1.1 Config Ali Cloud Access Key/Secret Key 
![terraform ali cloud key](docs/images/terraform_ali_cloud_key.png)
>Warn: AccessKey and SecretKey keep in local as env variable is more safty then config in *.tf file. 
##### 5.1.2 Terraform init
```
$cd d:\dev\delivery-by-terraform\delivery-wecube\to_ali_cloud
$terraform init    -- Install ali cloud terraform plugins
```
##### 5.1.3 Terraform apply (One Click Deploy)
```
$cd d:\dev\delivery-by-terraform\delivery-wecube\to_ali_cloud
$terraform apply   -- Deploy wecube to alicloud
$.....
$Enter a value: yes  -- Confirm to apply
$.....
```
![terraform apply ](docs/images/terraform_ali_cloud_apply.png)
>Conguration if you see this, your add is up and serivce at the output URL
![wecube ](docs/images/wecube.png)


##### 5.1.4 Terraform destroy (One Click Destroy)
```
$cd d:\dev\delivery-by-terraform\delivery-wecube\to_ali_cloud
$terraform destroy   -- Destroy wecube if no need
```
![terraform deploy   ](docs/images/terraform_ali_cloud_destroy.png)

#### 5.2 Steps for delivering to Tencent Cloud
##### 5.2.1 Config Tencent Cloud Access Key/Secret Key 
![terraform tencent cloud key](docs/images/terraform_tencent_cloud_key.png)
>Warn: AccessKey and SecretKey keep in local as env variable is more safty then config in *.tf file. 

##### 5.2.2 Terraform init
```
$cd d:\dev\delivery-by-terraform\delivery-wecube\to_tencent_cloud
$terraform init    -- Install tencent cloud terraform plugins
```

##### The remaining steps as same as deliverying Ali Cloud above.

### 6. Production
The production version is using cloud services for persistent storage, which can meet the base production requirements. For now, we prepare solution for Tencent cloud.

deploy plan as below：  
1.All resources deploy in a VPC    
2.Divide 3 subnet in the VPC: 
    - 10.128.195.0/24 subnet_vdi
    - 10.128.194.0/25 subnet_app
    - 10.128.194.128/26 subnet_db
3.create a security group for each subnet  
sg_group_wecube_db  

ingress/egress |  protocol | port |  source CIDR |  policy     
-|-|-|-|-  
ingress|TCP|3306|0.0.0.0/0|allow  
ingress|TCP|3307|0.0.0.0/0|allow  
ingress|TCP|9001|0.0.0.0/0|allow  
ingress|TCP|22|0.0.0.0/0|allow  
egress|TCP|1-65535|0.0.0.0/0|allow  

sg_group_wecube_app  

ingress/egress |  protocol | port |  source CIDR  |  policy    
-|-|-|-|-
ingress|TCP|2375|0.0.0.0/0|allow
ingress|TCP|22|0.0.0.0/0|allow
ingress|TCP|19090|0.0.0.0/0|allow
ingress|TCP|3128|10.128.194.0/25|allow
ingress|TCP|3128|10.128.194.128/26|allow
egress|TCP|1-65535|0.0.0.0/0|allow

sg_group_wecube_vdi  
ingress/egress |  protocol | port |  source CIDR  |  policy    
-|-|-|-|-
ingress|TCP|3389|0.0.0.0/0|allow
egress|TCP|1-65535|0.0.0.0/0|allow  
 
4.Create Tencent Cloud MySQL：  

Name | Type |  Subnet |  Security group |  porpose      
-|-|-|-|-
WecubeDbInstance | 1C2000M，200G | subnet_db  |  sg_group_wecube_db |  WeCube database  |
PluginDbInstance | 1C2000M，200G | subnet_db  |  sg_group_wecube_db |  plugin database  |

5.Tencent Cloud Object Storage(COS)
Apply COS bucket(use value of terraform var ${cos_name} as bucket name) for WeCube S3 storage。

6.Hosts deploy plan  

Intranet IP | Default instance type |  Subnet |  Security group |  module      
-|-|-|-|-  
10.128.194.130 | 2C4G | subnet_db  |  sg_group_wecube_db |  plugin S3 resource  |  
10.128.194.4 | 4C8G | subnet_app  |  sg_group_wecube_app |  plugin container  |  
10.128.194.3 | 4C8G | subnet_app  |  sg_group_wecube_app |  WeCube（platform-core、platform-gateway、wecube-portal、auth-server）  |  
10.128.194.2 | 2C4G | subnet_app  |  sg_group_wecube_app |  Squid  |  
10.128.195.2 | 2C4G | subnet_vdi  |  sg_group_wecube_vdi |  Windows VDI |  

7.Configure variables
Modify below variables' value before deploy, or it will use default value.

Variable | Default value |  description  
-|-|-
default_password | Wecube@123456 | default password for all resources |
wecube_version | v2.1.1 | the image tag of WeCube |
deploy_availability_zone | ap-guangzhou-4 | availability zone |
plugin_resource_s3_access_key | s3_access | plugin S3 resource access key |
plugin_resource_s3_secret_key | s3_secret | plugin S3 resource secret key |
cos_name | wecube-bucket-1234567890 | '1234567890' must replace to your [APPID](url:https://console.cloud.tencent.com/capi) |

##### 6.1 Config Ali Cloud Access Key/Secret Key 
Reference 5.1.1  
##### 6.2 Terraform init 
Reference 5.1.2  
##### 6.3 Terraform apply (One Click Deploy) 
Reference 5.1.3  
##### 6.4 Terraform destroy (One Click Destroy) 
Reference 5.1.4    


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

### 4. Deploy App
#### 4.1 Steps for delivering Wecube to AliCloud
##### 4.1.1 Config Ali Cloud Access Key/Secret Key 
![terraform ali cloud key](docs/images/terraform_ali_cloud_key.png)
>Warn: AccessKey and SecretKey keep in local as env variable is more safty then config in *.tf file. 
##### 4.1.2 Terraform init
```
$cd d:\dev\delivery-by-terraform\delivery-wecube\to_ali_cloud
$terraform init    -- Install ali cloud terraform plugins
```
##### 4.1.3 Terraform apply (One Click Deploy)
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


##### 4.1.4 Terraform destroy (One Click Destroy)
```
$cd d:\dev\delivery-by-terraform\delivery-wecube\to_ali_cloud
$terraform destroy   -- Destroy wecube if no need
```
![terraform deploy   ](docs/images/terraform_ali_cloud_destroy.png)

#### 4.2 Steps for delivering to Tencent Cloud
##### 4.2.1 Config Tencent Cloud Access Key/Secret Key 
![terraform tencent cloud key](docs/images/terraform_tencent_cloud_key.png)
>Warn: AccessKey and SecretKey keep in local as env variable is more safty then config in *.tf file. 

##### 4.2.2 Terraform init
```
$cd d:\dev\delivery-by-terraform\delivery-wecube\to_tencent_cloud
$terraform init    -- Install tencent cloud terraform plugins
```

##### The remaining steps as same as deliverying Ali Cloud above.

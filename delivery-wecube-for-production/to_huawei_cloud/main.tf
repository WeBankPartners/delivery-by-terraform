#User name + Password
#provider "huaweicloud" {
#  user_name   = "${var.user_name}"
#  password    = "${var.password}"
#  domain_name = "${var.domain_name}"
#  tenant_name = "${var.tenant_name}"
#  region      = "${var.region}"
#  auth_url    = "https://iam.myhwclouds.com:443/v3"
#}

#AKSK
provider "huaweicloud" {
  access_key = "${var.hw_access_key}"
  secret_key = "${var.hw_secret_key}"
  #  domain_name = "${var.domain_name}"
  tenant_name = "${var.hw_tenant_name}"
  region      = "${var.hw_region}"
  auth_url    = "https://iam.cn-south-1.myhwclouds.com/v3"
}
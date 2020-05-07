provider "huaweicloud" {
  access_key  = "${var.hw_access_key}"
  secret_key  = "${var.hw_secret_key}"
  tenant_name = "${var.hw_tenant_name}"
  region      = "${var.hw_region}"
  auth_url    = "https://iam.myhuaweicloud.com/v3"
}
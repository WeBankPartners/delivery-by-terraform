terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
    tencentcloud = {
      source = "tencentcloudstack/tencentcloud"
    }
  }
  required_version = ">= 0.13"
}

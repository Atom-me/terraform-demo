terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.214.0"
    }
  }
}

# Configure the Alicloud Provider
provider "alicloud" {
  region = "cn-zhangjiakou"
}
# 定义provider，定义云厂商
terraform {
  required_providers {
    alicloud = {
      source  = "registry.terraform.io/hashicorp/alicloud"
      version = "1.213.1"
    }
  }
}
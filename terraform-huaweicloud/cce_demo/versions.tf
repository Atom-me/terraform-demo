terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "1.59.1"
    }
  }
}

provider "huaweicloud" {
  # Configuration options
  region = "ap-southeast-3"
}
#https://support.huaweicloud.com/intl/zh-cn/qs-terraform/index.html
#https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs
terraform {
  required_providers {
    huaweicloud = {
      source = "huaweicloud/huaweicloud"
      version = "1.59.1"
    }
  }
}

terraform {
  backend "s3" {
    bucket    = "liuyamingtfbuckeet"
    key       = "terraform.tfstate"
    region    = "cn-north-1"
    endpoints = {
      s3 = "https://obs.cn-north-1.myhuaweicloud.com"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
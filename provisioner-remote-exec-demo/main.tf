# 定义provider，定义云厂商
terraform {
  required_providers {
    alicloud = {
      source  = "registry.terraform.io/hashicorp/alicloud"
      version = "1.213.1"
    }
  }
 #定义backend
 	backend "oss" {
    bucket = "atom-bucket-for-terraform-state"
    prefix   = "atom-dir/mystate"
    #tfstate这个文件的名称
    key   = "terraform.tfstate"
    region = "cn-shanghai"
  }
}

#配置provider
provider "alicloud" {
  region     = "cn-shanghai"
  access_key = "LTAI5tMd9tpWEX8gVFdfnjfy"
  secret_key = "TAMwqE5PTPNUQrRy4jD7AW8jFp2nMS"
}

#创建vpc
resource "alicloud_vpc" "vpc" {
  vpc_name   = "vpc_1"
  cidr_block = "10.0.0.0/16"
}

# 创建交换机 vsw_aliyun1
# alicloud_vswitch是阿里云的资源字段，vsw_1字段是tf文件中的自定义唯一资源名称,vswitch_name字段是在阿里云上的自定义备注名
resource "alicloud_vswitch" "vsw_1" {
  vswitch_name = "vsw_aliyun1"
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "10.0.0.0/24"
  zone_id      = "cn-shanghai-b"
}
#创建VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = "ack_vpc"
  cidr_block = "172.16.0.0/12"
}

#创建交换机
resource "alicloud_vswitch" "vsw" {
  vswitch_name = "ack_vsw"
  cidr_block   = "172.16.0.0/21"
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = "cn-zhangjiakou-a"
}
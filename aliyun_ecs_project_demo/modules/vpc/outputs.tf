#输出VSWITCH ID，供别的模块使用
output "vswitch_id" {
  value = alicloud_vswitch.vsw_1.id
}

#输出VPC ID，供别的模块使用
output "vpc_id" {
  value = alicloud_vpc.vpc.id
}
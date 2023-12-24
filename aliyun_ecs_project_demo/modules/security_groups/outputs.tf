#输出安全组ID，供别的模块使用
output "nsg_id" {
  value = alicloud_security_group.nsg1.*.id
}
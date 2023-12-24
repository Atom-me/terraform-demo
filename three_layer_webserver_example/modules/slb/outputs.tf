#输出SLB的公网IP
output "slb_public_ip" {
  value = alicloud_slb_load_balancer.slb.address
}
output "ecs_password" {
  value     = huaweicloud_compute_instance.atominstance.admin_pass
  sensitive = true
}

output "ecs_eip" {
  value = huaweicloud_vpc_eip.atom_eip.address
}
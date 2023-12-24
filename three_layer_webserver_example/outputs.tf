output "slb_public_ip" {
  value = module.slb.slb_public_ip

}

output "ecs_private_ip1" {
  value = module.ecs[0].this_private_ip[0]

}

output "ecs_private_ip2" {
  value = module.ecs[1].this_private_ip[0]
}
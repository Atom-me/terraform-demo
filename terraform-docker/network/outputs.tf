# 定义输出信息
output "network" {
  # value = docker_network.network
  #可以筛选输出结果
  value = [for net in docker_network.network : tomap({ "name" : net.name, "subnet" : tolist(net.ipam_config)[0].subnet })]
}
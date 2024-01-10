provider "docker" {
  # Configuration options
  host = "tcp://8.140.195.225:2375"
}

#创建docker 网络
resource "docker_network" "network" {
  #使用count创建多个network
  count  = length(local.network_settings)
  name   = local.network_settings[count.index]["name"]
  driver = local.network_settings[count.index]["driver"]
  ipam_config {
    subnet = local.network_settings[count.index]["subnet"]
  }
}

locals {
  network_settings = [
    {
      name   = "devops1"
      driver = "bridge"
      subnet = "10.10.10.0/24"
    }
  ]
}
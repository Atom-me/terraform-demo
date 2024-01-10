#VPC
resource "huaweicloud_vpc" "atom_vpc" {
  name = "atom_cce_vpc"
  cidr = "192.168.0.0/16"
}

#Subnet
resource "huaweicloud_vpc_subnet" "atom_subnet" {
  name       = "atom_cce_subnet"
  cidr       = "192.168.0.0/16"
  gateway_ip = "192.168.0.1"


  vpc_id = huaweicloud_vpc.atom_vpc.id
  //dns is required for cce node installing

  dns_list = ["100.125.1.250", "100.125.128.250"]
}


#EIP
resource "huaweicloud_vpc_eip" "atom_eip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "mybandwidth"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

#CCE
resource "huaweicloud_cce_cluster" "atomcce" {
  name                   = "atomcce"
  flavor_id              = "cce.s1.small"
  vpc_id                 = huaweicloud_vpc.atom_vpc.id
  subnet_id              = huaweicloud_vpc_subnet.atom_subnet.id
  container_network_type = "overlay_l2"
  # 若不使用弹性公网ip，忽略此行
  eip = huaweicloud_vpc_eip.atom_eip.address
}



data "huaweicloud_availability_zones" "myaz" {}

# resource "huaweicloud_compute_keypair" "mykeypair" {
#   name       = "mykeypair"
# }

#直接创建节点，会使用默认节点池，（自动创建一个默认节点池）
resource "huaweicloud_cce_node" "mynode" {
  cluster_id        = huaweicloud_cce_cluster.atomcce.id
  name              = "atom-cce-node001"
  flavor_id         = "t6.large.2"
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  os                = "EulerOS 2.9"
  # key_pair          = huaweicloud_compute_keypair.mykeypair.name
  password = "Abc.!@123"

  root_volume {
    size       = 40
    volumetype = "SAS"
  }
  data_volumes {
    size       = 100
    volumetype = "SAS"
  }

  # Assign EIP
  iptype                = "5_bgp"
  bandwidth_charge_mode = "traffic"
  sharetype             = "PER"
  bandwidth_size        = 100
}


#单独创建节点池
resource "huaweicloud_cce_node_pool" "node_pool" {
  cluster_id         = huaweicloud_cce_cluster.atomcce.id
  name               = "atomtestpool"
  os                 = "CentOS 7.6"
  initial_node_count = 4
  flavor_id          = "s3.large.4"
  # availability_zone        = var.availability_zone
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]

  # key_pair                 = var.keypair
  password = "Abc.!@123"

  scall_enable             = true
  min_node_count           = 1
  max_node_count           = 10
  scale_down_cooldown_time = 100
  priority                 = 1
  type                     = "vm"
  charging_mode            = "postPaid"

  root_volume {
    size       = 40
    volumetype = "SAS"
  }
  data_volumes {
    size       = 100
    volumetype = "SAS"
  }
}

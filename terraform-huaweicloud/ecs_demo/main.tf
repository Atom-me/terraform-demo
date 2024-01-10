data "huaweicloud_availability_zones" "myaz" {}

#Flavor：虚拟机规格模板，用于定义一种虚拟机类型，如一种具有2个VCPU、4GB内存、40GB本地存储空间的虚拟机。Flavor由系统管理员创建，供普通用户在创建虚拟机时使用。
data "huaweicloud_compute_flavors" "myflavor" {
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  performance_type  = "normal"
  cpu_core_count    = 4
  memory_size       = 8
}

data "huaweicloud_images_image" "centos-1" {
  architecture = "x86"
  os_version   = "CentOS 7.7 64bit"
  visibility   = "public"
  most_recent  = true
}

# data "huaweicloud_networking_secgroup" "mysecgroup" {
#   name = "default"
# }

#VPC
resource "huaweicloud_vpc" "vpc" {
  name = "vpc-web"
  cidr = "192.168.0.0/16"
  tags = {
    Creator = "Atom"
  }
}
#交换机
resource "huaweicloud_vpc_subnet" "subnet2" {
  name       = "subnet-app"
  cidr       = "192.168.20.0/24"
  gateway_ip = "192.168.20.1"
  vpc_id     = huaweicloud_vpc.vpc.id
  dns_list   = ["100.125.1.250", "100.125.128.250"]
  tags = {
    Creator = "Atom"
  }
}
#安全组
resource "huaweicloud_networking_secgroup" "mysecgroup" {
  name                 = "secgroup"
  description          = "My security group"
  delete_default_rules = true
}
# 安全组规则
resource "huaweicloud_networking_secgroup_rule" "secgroup_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.mysecgroup.id
}

#随机密码
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%*"
}

#ECS
resource "huaweicloud_compute_instance" "atominstance" {
  name = "atom-ecs001"
  # admin_pass         = random_password.password.result
  admin_pass         = "Abc.!@123"
  image_id           = data.huaweicloud_images_image.centos-1.id
  flavor_id          = data.huaweicloud_compute_flavors.myflavor.ids[0]
  availability_zone  = data.huaweicloud_availability_zones.myaz.names[0]
  security_group_ids = [huaweicloud_networking_secgroup.mysecgroup.id]

  #系统盘
  system_disk_type = "SAS"
  system_disk_size = 40

  #多块数据盘,更改磁盘，服务器会销毁重建
  data_disks {
    type = "SAS"
    size = "10"
  }
  data_disks {
    type = "SSD"
    size = "20"
  }

  delete_disks_on_termination = true

  network {
    # uuid = data.huaweicloud_vpc_subnet.mynet.id
    uuid = huaweicloud_vpc_subnet.subnet2.id
  }
  tags = {
    Creator = "Atom"
  }
}

#EIP
resource "huaweicloud_vpc_eip" "atom_eip" {
  name = "atom_ecs_eip"
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "atom_ecs_bandwidth"
    size        = 10
    share_type  = "PER"
    charge_mode = "traffic"
  }
}
#EIP associated
resource "huaweicloud_compute_eip_associate" "associated" {
  public_ip   = huaweicloud_vpc_eip.atom_eip.address
  instance_id = huaweicloud_compute_instance.atominstance.id
}
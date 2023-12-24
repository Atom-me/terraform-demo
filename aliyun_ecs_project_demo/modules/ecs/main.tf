
#创建ECS实例1
resource "alicloud_instance" "instance1" {
  availability_zone          = "cn-shanghai-b"
  instance_type              = "ecs.n1.small"
  system_disk_category       = "cloud_ssd"
  image_id                   = "centos_7_9_x64_20G_alibase_20220824.vhd"
  instance_name              = "atom-test001"
  internet_max_bandwidth_out = 1
  password                   = "2LhaIA3sqlgHHr6rUVX"

  security_groups            = var.nsgid
  vswitch_id                 = var.vswitchid
}

#创建ECS实例2
resource "alicloud_instance" "instance2" {
  availability_zone          = "cn-shanghai-b"
  instance_type              = "ecs.n1.small"
  system_disk_category       = "cloud_ssd"
  image_id                   = "centos_7_9_x64_20G_alibase_20220824.vhd"
  instance_name              = "liuyaming-atom-test002"
  internet_max_bandwidth_out = 1
  password                   = "2LhaIA3sqlgHHr6rUVX"
  security_groups            = var.nsgid
  vswitch_id                 = var.vswitchid
}

#创建ECS实例3
resource "alicloud_instance" "instance3" {
  availability_zone          = "cn-shanghai-b"
  instance_type              = "ecs.n1.small"
  system_disk_category       = "cloud_ssd"
  image_id                   = "centos_7_9_x64_20G_alibase_20220824.vhd"
  instance_name              = "atom-test003"
  internet_max_bandwidth_out = 1
  password                   = "2LhaIA3sqlgHHr6rUVX"

  security_groups            = var.nsgid
  vswitch_id                 = var.vswitchid
}
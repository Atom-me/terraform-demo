#定义云厂商
#配置provider
provider "alicloud" {
  region     = "cn-shanghai"
  access_key = "LTAI5tMd9tpWEX8gVFdfnjfy"       #修改成自己的ak
  secret_key = "TAMwqE5PTPNUQrRy4jD7AW8jFp2nMS" #修改成自己的sk
}

#创建vpc
resource "alicloud_vpc" "vpc" {
  vpc_name   = "vpc_1"
  cidr_block = "10.0.0.0/16"
}

# 创建vswitch
# alicloud_vswitch是阿里云的资源字段，vsw_1字段是tf文件中的自定义唯一资源名称,vswitch_name字段是在阿里云上的自定义备注名
resource "alicloud_vswitch" "vsw_1" {
  vswitch_name = "vsw_aliyun1"
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "10.0.0.0/24"
  zone_id      = "cn-shanghai-b"
}

#新建安全组
resource "alicloud_security_group" "nsg1" {
  name   = "atom_aliyun_nsg1"
  vpc_id = alicloud_vpc.vpc.id
}

#将nsg_rule1加入安全组 atom_aliyun_nsg1 中
resource "alicloud_security_group_rule" "nsg_rule1" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.nsg1.id
  cidr_ip           = "0.0.0.0/0"
}


# #创建ECS实例
# resource "alicloud_instance" "instance" {
#   availability_zone          = "cn-shanghai-b"
#   security_groups            = ["${alicloud_security_group.nsg1.id}"]
#   instance_type              = "ecs.n1.small"
#   system_disk_category       = "cloud_ssd"
#   image_id                   = "centos_7_9_x64_20G_alibase_20220824.vhd"
#   instance_name              = "liuyaming-atom-test001"
#   vswitch_id                 = alicloud_vswitch.vsw_1.id
#   internet_max_bandwidth_out = 1
#   password                   = "2LhaIA3sqlgHHr6rUVX"
# }

##使用阿里云公有模块创建ECS
#
data "alicloud_images" "ubuntu" {
  most_recent = true
  name_regex  = "^ubuntu_18.*64"
}

#module，命名 ecs_cluster
module "ecs_cluster" {
  source = "alibaba/ecs-instance/alicloud"

  number_of_instances = 5
  #每个ECS实例的名字
  name = "atom-ecs-cluster"
  #ECS实例名称是否添加数字后缀
  use_num_suffix = true
  #ECS实例操作系统镜像ID，使用data块查询，使用查询到的结果的第0个
  image_id                    = data.alicloud_images.ubuntu.ids.0
  instance_type               = "ecs.sn1ne.large"
  vswitch_id                  = alicloud_vswitch.vsw_1.id
  security_group_ids          = [alicloud_security_group.nsg1.id]
  associate_public_ip_address = true
  internet_max_bandwidth_out  = 10
  #ECS实例root账户密码
  password = "Test!@123"

  system_disk_category = "cloud_ssd"
  system_disk_size     = 50

  tags = {
    Created     = "Atom"
    Environment = "dev"
  }
}
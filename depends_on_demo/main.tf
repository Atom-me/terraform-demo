#定义云厂商
#配置provider
provider "alicloud" {
  region     = "cn-shanghai"
  access_key = "sdfghfgd"
  secret_key = "sagasfasdf"
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
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.nsg1.id
  cidr_ip           = "0.0.0.0/0"
}

# OSS bucket ossbucket001
resource "alicloud_oss_bucket" "ossbucket001" {
  bucket = "ossbucket001-atom-test"
  acl    = "private"
  # 要求ossbucket001资源必须等待ECS资源创建成功之后才能创建。
  depends_on = [alicloud_instance.instance]
}


# OSS bucket ossbucket002
resource "alicloud_oss_bucket" "ossbucket002" {
  bucket = "ossbucket002-atom-test"
  acl    = "private"
  # 要求ossbucket002资源必须等待ossbucket001资源创建成功之后才能创建。
  depends_on = [alicloud_oss_bucket.ossbucket001]
}

# OSS bucket ossbucket003
resource "alicloud_oss_bucket" "ossbucket003" {
  bucket = "ossbucket003-atom-test"
  acl    = "private"
  # 要求ossbucket003资源必须等待ossbucket002资源创建成功之后才能创建。
  depends_on = [alicloud_oss_bucket.ossbucket002]
}



#创建ECS实例
resource "alicloud_instance" "instance" {
  availability_zone          = "cn-shanghai-b"
  security_groups            = ["${alicloud_security_group.nsg1.id}"]
  instance_type              = "ecs.n1.small"
  system_disk_category       = "cloud_ssd"
  image_id                   = "centos_7_9_x64_20G_alibase_20220824.vhd"
  instance_name              = "liuyaming-atom-test001"
  vswitch_id                 = alicloud_vswitch.vsw_1.id
  internet_max_bandwidth_out = 1
  password                   = "2LhaIA3sqlgHHr6rUVX"
}

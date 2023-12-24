#创建一个VPC，两个VSwitch
module "vpc" {
  source = "alibaba/vpc/alicloud"

  create   = true
  vpc_name = "three_layer_webserver_vpc"
  vpc_cidr = "10.0.0.0/16"

  availability_zones = ["cn-shanghai-l", "cn-shanghai-m"]
  vswitch_cidrs      = ["10.0.0.0/24", "10.0.1.0/24"]

  vpc_tags = {
    Owner       = "Atom"
    Environment = "dev"
  }

}


module "sg" {
  source = "./modules/security_group"
  #vpc_id输入的值，是vpc moudle的输出，可在VPC公有模块文档中找到
  vpc_id = module.vpc.this_vpc_id
}


module "ecs" {
  source = "alibaba/ecs-instance/alicloud"

  # number_of_instances = 5

  #两台ECS
  count          = 2
  name           = "web-${count.index + 1}"
  # use_num_suffix = true
  image_id       = "centos_7_9_x64_20G_alibase_20220824.vhd"
  instance_type  = "ecs.c7.large"
  vswitch_id     = module.vpc.this_vswitch_ids[count.index]

  security_group_ids          = [module.sg.sg_id]
  associate_public_ip_address = true
  internet_max_bandwidth_out  = 10
  password                    = "2LhaIA3sqlgHHr6rUVX"
  system_disk_category        = "cloud_essd"
  system_disk_size            = 50
  host_name                   = "web-${count.index + 1}"

  tags = {
    Created     = "Atom"
    Environment = "dev"
  }

  #添加磁盘，使用输入参数 data_disks
  #data_disks内容怎么写，参考公共模块的demo，示例
  data_disks = [
    {
      name     = "data_diskB"
      category = "cloud_essd"
      size     = "20"
    },
    {
      name     = "data_diskC"
      category = "cloud_essd"
      size     = "40"
    }
  ]

  user_data = local.user_data
}


locals {
  user_data = <<EOF
#!/bin/bash
#格式化磁盘并设置开机自动挂载
mkfs.ext4 /dev/vdb && mkdir -p /dataB && /bin/mount /dev/vdb /dataB
echo `blkid /dev/vdb | awk '{print $2}' | sed 's/\"//g'` /dataB ext4 defaults 0 0 >> /etc/fstab

mkfs.ext4 /dev/vdc && mkdir -p /dataC && /bin/mount /dev/vdc /dataC
echo `blkid /dev/vdc | awk '{print $2}' | sed 's/\"//g'` /dataC ext4 defaults 0 0 >> /etc/fstab

#安装nginx
yum install -y nginx
private_ip=`curl http://100.100.100.200/latest/meta-data/private-ipv4`
sed -i "1i$private_ip" /usr/share/nginx/html/index.html
systemctl start nginx

EOF
}


module "slb" {
  source             = "./modules/slb"
  load_balancer_name = "web_slb"
  address_type       = "internet"
  load_balancer_spec = "slb.s2.small"
  #我们是使用count定义的ECS，所以是module.ecs[0]，module.ecs[1]这么写
  server_id  = module.ecs[0].this_instance_id[0]
  server_id2 = module.ecs[1].this_instance_id[0]
}


#创建RDS
module "mysql" {
  source = "terraform-alicloud-modules/rds/alicloud"

  engine         = "MySQL"
  engine_version = "8.0"
  # connection_prefix = "developmentabc"
  #不分配外网连接，只允许内网访问
  allocate_public_connection = false
  vswitch_id                 = module.vpc.vswitch_ids[0]
  instance_storage           = 20
  period                     = 1
  instance_type              = "rds.mysql.s1.small"
  instance_name              = "webappDBInstance"
  #后付费
  instance_charge_type = "Postpaid"
  #白名单
  security_ips = [
    "${module.ecs[0].this_private_ip[0]}/32",
    "${module.ecs[1].this_private_ip[0]}/32"
  ]

  tags = {
    Created     = "Atom"
    Environment = "dev"
  }

  ###############
  #backup_policy#
  ###############
  preferred_backup_period     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  preferred_backup_time       = "16:00Z-17:00Z"
  backup_retention_period     = 7
  log_backup_retention_period = 7
  enable_backup_log           = true

  ###########
  #databases#
  ###########
  account_name = "atom"
  password     = "SY9geC3tZdc"
  type         = "Normal"
  privilege    = "ReadWrite"
  #会自动创建对应数据库db1,db2
  databases = [
    {
      name          = "db1"
      character_set = "utf8"
      description   = "db1"
    },
    {
      name          = "db2"
      character_set = "utf8"
      description   = "db2"
    },
  ]
}




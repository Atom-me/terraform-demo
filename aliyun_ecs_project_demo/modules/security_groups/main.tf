#新建安全组 atom_aliyun_nsg1，需要一个输入（vpc id）,安全组是挂在VPC下面的
resource "alicloud_security_group" "nsg1" {
  name   = "atom_aliyun_nsg1"
  vpc_id = var.vpcid
}

#将安全组规则nsg_rule1 加入安全组 atom_aliyun_nsg1 中
resource "alicloud_security_group_rule" "nsg_rule1" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/3306"
  priority          = 1
  security_group_id = alicloud_security_group.nsg1.id
  cidr_ip           = "0.0.0.0/0"
}

#将安全组规则nsg_rule2 加入安全组 atom_aliyun_nsg1 中
resource "alicloud_security_group_rule" "nsg_rule2" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "6379/6379"
  priority          = 1
  security_group_id = alicloud_security_group.nsg1.id
  cidr_ip           = "0.0.0.0/0"
}
locals {
  nodepool_name = "atom-ack-nodepool001"
}

# Kubernetes托管版。
resource "alicloud_cs_managed_kubernetes" "atom-ack-k8s-demo" {
  # Kubernetes集群名称。
  name = var.cluster_name
  # 创建Pro版集群。
  cluster_spec = "ack.pro.small"
  version      = "1.26.3-aliyun.1"
  # 新的Kubernetes集群将位于的vSwitch。指定一个或多个vSwitch的ID。它必须在availability_zone指定的区域中。
  worker_vswitch_ids = split(",", join(",", alicloud_vswitch.vsw.*.id))

  # 是否在创建Kubernetes集群时创建新的NAT网关。默认为true。
  new_nat_gateway = true
  # Pod网络的CIDR块。当cluster_network_type设置为flannel，你必须设定该参数。它不能与VPC CIDR相同，并且不能与VPC中的Kubernetes集群使用的CIDR相同，也不能在创建后进行修改。集群中允许的最大主机数量：256。
  pod_cidr = "10.10.0.0/16"
  # 服务网络的CIDR块。它不能与VPC CIDR相同，不能与VPC中的Kubernetes集群使用的CIDR相同，也不能在创建后进行修改。
  service_cidr = "10.12.0.0/16"
  # 是否为API Server创建Internet负载均衡。默认为false。
  slb_internet_enabled = true

  # Enable Ram Role for ServiceAccount
  enable_rrsa = true

  # 控制平面日志。
  control_plane_log_components = ["apiserver", "kcm", "scheduler", "ccm"]

  # 组件管理。
  dynamic "addons" {
    for_each = var.cluster_addons
    content {
      name   = lookup(addons.value, "name", var.cluster_addons)
      config = lookup(addons.value, "config", var.cluster_addons)
    }
  }

}

# 节点池。
resource "alicloud_cs_kubernetes_node_pool" "atom-ack-nodepool" {
  # Kubernetes集群名称。
  cluster_id = alicloud_cs_managed_kubernetes.atom-ack-k8s-demo.id
  # 节点池名称。
  name = local.nodepool_name
  # 新的Kubernetes集群将位于的vSwitch。指定一个或多个vSwitch的ID。它必须在availability_zone指定的区域中。
  vswitch_ids = split(",", join(",", alicloud_vswitch.vsw.*.id))

  # Worker ECS Type and ChargeType
  instance_types       = ["ecs.g6.large"]
  instance_charge_type = "PrePaid"
  period               = 1
  period_unit          = "Month"
  auto_renew           = true
  auto_renew_period    = 1

  # Kubernetes集群的期望总工作节点数。默认值为3。最大限制为50。
  desired_size = 2
  # SSH登录集群节点的密码。
  password = "Abc.!@123"

  # 是否为Kubernetes的节点安装云监控。
  install_cloud_monitor = true

  # 节点的系统磁盘类别。其有效值为cloud_ssd和cloud_efficiency。默认为cloud_efficiency。
  system_disk_category = "cloud_efficiency"
  system_disk_size     = 40

  # OS Type
  image_type = "CentOS"

  # 节点数据盘配置。
  data_disks {
    # 节点数据盘种类。
    category = "cloud_essd"
    # 节点数据盘大小。
    size = 100
  }
}
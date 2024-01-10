#创建负载均衡器
resource "alicloud_slb_load_balancer" "slb" {
  load_balancer_name = var.load_balancer_name
  address_type       = var.address_type
  load_balancer_spec = var.load_balancer_spec
  #外网的SLB不需要 vswitch
  # vswitch_id         = alicloud_vswitch.load_balancer.id
  tags = {
    info = "create for internet"
  }
  instance_charge_type = "PayBySpec"
}

#创建默认服务器组
resource "alicloud_slb_backend_server" "backend_server" {
  load_balancer_id = alicloud_slb_load_balancer.slb.id

  backend_servers {
    server_id = var.server_id
    weight    = 100
  }

  backend_servers {
    server_id = var.server_id2
    weight    = 100
  }
}

#添加实例的前端监听
resource "alicloud_slb_listener" "listener" {
  load_balancer_id          = alicloud_slb_load_balancer.slb.id
  backend_port              = 80
  frontend_port             = 80
  protocol                  = "http"
}
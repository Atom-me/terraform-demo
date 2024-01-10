# 定义局部变量，规范代码
locals {
  # 定义容器使用镜像
  container_image_name = "nginx:1.25.1"
  # 定义容器名称
  container_name = "nginx"
  # 容器网络，使用上文 network 中定义的输出变量
  container_network = data.terraform_remote_state.network.outputs.network[0].name
  # 容器ip
  container_ip = "10.10.10.10"
}

#创建容器镜像
resource "docker_image" "nginx" {
  name = local.container_image_name
  # 容器删除时是否本地保存镜像
  keep_locally = true
}

# Start a container
resource "docker_container" "nginx" {
  image = docker_image.nginx.name
  name  = local.container_name
  networks_advanced {
    name         = local.container_network
    ipv4_address = local.container_ip
  }
  ports {
    #Port within the container.
    internal = 80
    #Port exposed out of the container.
    external = 80
    ip       = "0.0.0.0"
    protocol = "tcp"
  }
  ports {
    internal = 443
    external = 443
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  #docker api 不支持？
  # volumes {
  #   container_path = "/usr/share/nginx/html/"
  #   host_path      = "/tmp/nginx/"
  # }

  depends_on = [
    docker_image.nginx
  ]
}

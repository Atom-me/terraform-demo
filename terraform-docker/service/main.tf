provider "docker" {
  # Configuration options
  host = "tcp://8.140.195.225:2375"
}

# 获取上文 network 中 output 输出的 network 信息
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}

# 输出 network 中 output 输出的 network 信息，查看确定(调试使用)
output "network_value" {
  value = data.terraform_remote_state.network.outputs
}

output "server_ips" {
  description = "Consul Server 节点的公网 IP"
  value       = aws_instance.consul_server[*].public_ip
}

output "client_ips" {
  description = "Consul Client 节点的公网 IP"
  value       = aws_instance.consul_client[*].public_ip
}

output "consul_ui_urls" {
  description = "Consul Web UI 访问地址"
  value       = [for ip in aws_instance.consul_server[*].public_ip : "http://${ip}:8500"]
}

output "ssh_commands" {
  description = "SSH 连接命令"
  value = {
    servers = [for i, ip in aws_instance.consul_server[*].public_ip : "ssh -i ${var.ssh_private_key} ubuntu@${ip}"]
    clients = [for i, ip in aws_instance.consul_client[*].public_ip : "ssh -i ${var.ssh_private_key} ubuntu@${ip}"]
  }
} 
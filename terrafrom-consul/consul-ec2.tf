data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Consul Server 节点
resource "aws_instance" "consul_server" {
  count                  = local.server_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.server_instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.consul.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.consul_instance_profile.name

  user_data = templatefile("${path.module}/scripts/user-data-server.sh", {
    aws_region            = var.region
    gossip_encryption_key = aws_secretsmanager_secret.consul_gossip_encryption_key.name
    ssh_public_key        = file(var.ssh_public_key)
  })

  tags = merge(local.common_tags, {
    Name           = "consul-server-${count.index + 1}"
    consul-cluster = "server-cluster"
  })
}

# Consul Client 节点
resource "aws_instance" "consul_client" {
  count                  = local.client_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.client_instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.consul.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.consul_instance_profile.name
  depends_on             = [aws_instance.consul_server]

  user_data = templatefile("${path.module}/scripts/user-data-client.sh", {
    aws_region            = var.region
    gossip_encryption_key = aws_secretsmanager_secret.consul_gossip_encryption_key.name
    ssh_public_key        = file(var.ssh_public_key)
  })

  tags = merge(local.common_tags, {
    Name           = "consul-client-${count.index + 1}"
    consul-cluster = "server-cluster"
  })
} 
resource "aws_secretsmanager_secret" "consul_acl_token" {
  name = "${var.prefix}-consul-acl-token"
}

resource "aws_secretsmanager_secret_version" "consul_acl_token" {
  secret_id     = aws_secretsmanager_secret.consul_acl_token.id
  secret_string = "e95b599e-166e-7ce0-b5ed-0689ca1bb95f" # 临时 ACL token，部署后应重新生成
}

resource "aws_secretsmanager_secret" "consul_gossip_encryption_key" {
  name = "${var.prefix}-consul-gossip-key"
}

resource "aws_secretsmanager_secret_version" "consul_gossip_encryption_key" {
  secret_id     = aws_secretsmanager_secret.consul_gossip_encryption_key.id
  secret_string = "K8XucqE+3lJhiYe3UlMYYlQmJ2K+j+rQSYxl+8JKtKM=" # Base64 编码的 32 字节密钥
}

resource "aws_secretsmanager_secret" "consul_dns_request_token" {
  name = "${var.prefix}-consul-dns-request-token"
}

resource "aws_secretsmanager_secret_version" "consul_dns_request_token" {
  secret_id     = aws_secretsmanager_secret.consul_dns_request_token.id
  secret_string = "d63ff516-8aab-4fe5-9a53-7b8e6b2a4d1f" # DNS 请求 token
} 